#include "WindowManager.h"

#include <QGuiApplication>
#include <QProcess>
#include <QScreen>
#include <QWindow>
#include <QDebug>
#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <cstring>

#include <X11/Xlib.h>
#include <X11/cursorfont.h>
#include <X11/keysym.h>


bool WindowManager::start(QWindow *home)
{
    auto *x11 = qGuiApp->nativeInterface<QNativeInterface::QX11Application>();
    if (!x11) {
        qCritical("bemore-wm: Qt is not running on X11 (xcb); WM mode unavailable\n");
        return false;
    }
    conn_ = x11->connection();
    Display *dpy = x11->display();
    root_ = XDefaultRootWindow(dpy);
    geom_ = qGuiApp->primaryScreen()->geometry();

    //Become the window manager: only one client may select SubstructureRedirect.
    // Keep whatever events Qt already selected on the root window.
    uint32_t mask = XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT | XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY;
    auto *wa = xcb_get_window_attributes_reply(conn_,
                                               xcb_get_window_attributes(conn_, root_),
                                               nullptr);
    if (wa) {
        mask |= wa->your_event_mask;
        free(wa);
    }
    xcb_void_cookie_t cookie = xcb_change_window_attributes_checked(conn_,
                                                                    root_,
                                                                    XCB_CW_EVENT_MASK,
                                                                    &mask);
    if (xcb_generic_error_t *err = xcb_request_check(conn_, cookie)) {
        free(err);
        qWarning("bemore-wm: another window manager is running; starting as a normal window\n");
        return false;
    }

    wmProtocols_ = internAtom("WM_PROTOCOLS");
    wmDelete_    = internAtom("WM_DELETE_WINDOW");

    //  Global hotkeys on Alt, also when NumLock / CapsLock are on.
    kEsc_ = XKeysymToKeycode(dpy, XK_Escape);
    kTab_ = XKeysymToKeycode(dpy, XK_Tab);
    kF4_  = XKeysymToKeycode(dpy, XK_F4);
    kRet_ = XKeysymToKeycode(dpy, XK_Return);
    kQ_   = XKeysymToKeycode(dpy, XK_q);
    const uint16_t extra[] = { 0, XCB_MOD_MASK_LOCK, XCB_MOD_MASK_2, XCB_MOD_MASK_LOCK | XCB_MOD_MASK_2 };
    for (xcb_keycode_t k : { kEsc_, kTab_, kF4_, kRet_, kQ_ })
        for (uint16_t e : extra)
            xcb_grab_key(conn_, 1, root_, XCB_MOD_MASK_1 | e, k, XCB_GRAB_MODE_ASYNC, XCB_GRAB_MODE_ASYNC);

    XFlush(dpy);

    // The QML window belongs to this very process, so its own map/configure
    // requests are never redirected to us: we just size it and focus it.
    home->setGeometry(geom_);
    home_ = static_cast<xcb_window_t>(home->winId());
    focus(home_);
    return true;
}

void WindowManager::toggleHome()
{
    if (focused_ != home_)
        goHome();
    else if (!clients_.empty())
        focus(clients_.front());
}

// Ask nicely (WM_DELETE_WINDOW); kill the connection if the program doesn't support it.
void WindowManager::closeFocused(bool force)
{
    if (focused_ == 0 || focused_ == home_)
        return;
    const xcb_window_t w = focused_;

    bool supportsDelete = false;
    if (auto *r = xcb_get_property_reply(conn_,
            xcb_get_property(conn_, 0, w, wmProtocols_, XCB_ATOM_ATOM, 0, 32), nullptr)) {
        auto *atoms = static_cast<xcb_atom_t *>(xcb_get_property_value(r));
        int n = xcb_get_property_value_length(r) / int(sizeof(xcb_atom_t));
        for (int i = 0; i < n; ++i) {
            if (atoms[i] == wmDelete_)
                supportsDelete = true;
        }
        free(r);
    }

    if (supportsDelete && !force) {
        xcb_client_message_event_t ev = {};
        ev.response_type  = XCB_CLIENT_MESSAGE;
        ev.format         = 32;
        ev.window         = w;
        ev.type           = wmProtocols_;
        ev.data.data32[0] = wmDelete_;
        ev.data.data32[1] = XCB_CURRENT_TIME;
        xcb_send_event(conn_,
                       0, w, XCB_EVENT_MASK_NO_EVENT, reinterpret_cast<const char *>(&ev));
    } else {
        xcb_kill_client(conn_, w);
    }
    xcb_flush(conn_);
}

bool WindowManager::homeFocused() const
{
    return focused_ == home_;
}

bool WindowManager::nativeEventFilter(const QByteArray &eventType,
                                      void *message, qintptr *)
{
    if (!conn_ || eventType != "xcb_generic_event_t")
        return false;
    auto *ev = static_cast<xcb_generic_event_t *>(message);

    switch (ev->response_type & 0x7f) {

    case XCB_MAP_REQUEST: {                     // a program wants to show a window
        auto *e = reinterpret_cast<xcb_map_request_event_t *>(ev);
        if (isClient(e->window)) {
            xcb_map_window(conn_, e->window);
            return true;
        }
        placeFullscreen(e->window);
        xcb_map_window(conn_, e->window);
        clients_.insert(clients_.begin(), e->window);
        focus(e->window);
        return true;
    }

    case XCB_CONFIGURE_REQUEST: {               // programs may not choose their own size
        auto *e = reinterpret_cast<xcb_configure_request_event_t *>(ev);
        if (isClient(e->window)) {
            placeFullscreen(e->window);
        } else {                                // not mapped yet: pass the request through
            uint32_t v[7]; int n = 0;
            if (e->value_mask & XCB_CONFIG_WINDOW_X)            v[n++] = uint32_t(int32_t(e->x));
            if (e->value_mask & XCB_CONFIG_WINDOW_Y)            v[n++] = uint32_t(int32_t(e->y));
            if (e->value_mask & XCB_CONFIG_WINDOW_WIDTH)        v[n++] = e->width;
            if (e->value_mask & XCB_CONFIG_WINDOW_HEIGHT)       v[n++] = e->height;
            if (e->value_mask & XCB_CONFIG_WINDOW_BORDER_WIDTH) v[n++] = e->border_width;
            if (e->value_mask & XCB_CONFIG_WINDOW_SIBLING)      v[n++] = e->sibling;
            if (e->value_mask & XCB_CONFIG_WINDOW_STACK_MODE)   v[n++] = e->stack_mode;
            xcb_configure_window(conn_, e->window, e->value_mask, v);
        }
        xcb_flush(conn_);
        return true;
    }

    case XCB_UNMAP_NOTIFY:                      // a program hid or closed its window
        removeClient(reinterpret_cast<xcb_unmap_notify_event_t *>(ev)->window);
        return false;

    case XCB_DESTROY_NOTIFY:
        removeClient(reinterpret_cast<xcb_destroy_notify_event_t *>(ev)->window);
        return false;

    case XCB_KEY_PRESS: {
        auto *e = reinterpret_cast<xcb_key_press_event_t *>(ev);
        const uint16_t mods = e->state & ~(XCB_MOD_MASK_LOCK | XCB_MOD_MASK_2);  // ignore Caps/NumLock
        if (mods != XCB_MOD_MASK_1)
            return false;
        return handleKey(e->detail);
    }
    }
    return false;
}

// Raise a window to the top and give it the keyboard.
void WindowManager::focus(xcb_window_t w)
{
    const uint32_t above = XCB_STACK_MODE_ABOVE;
    xcb_configure_window(conn_, w, XCB_CONFIG_WINDOW_STACK_MODE, &above);
    xcb_set_input_focus(conn_, XCB_INPUT_FOCUS_POINTER_ROOT, w, XCB_CURRENT_TIME);
    focused_ = w;
    auto it = std::find(clients_.begin(), clients_.end(), w);
    if (it != clients_.end())
        std::rotate(clients_.begin(), it, it + 1);      // move to front
    xcb_flush(conn_);
}

void WindowManager::goHome()
{
    focus(home_);
}

void WindowManager::cycle()
{
    if (clients_.empty())
        return;
    if (focused_ == home_)
        focus(clients_.front());
    else if (clients_.size() > 1)
        focus(clients_[1]);   // toggles between the two latest
}

void WindowManager::removeClient(xcb_window_t w)
{
    auto it = std::find(clients_.begin(), clients_.end(), w);
    if (it == clients_.end())
        return;
    clients_.erase(it);
    if (focused_ == w)
        focus(clients_.empty() ? home_ : clients_.front());
}

void WindowManager::placeFullscreen(xcb_window_t w)
{
    const uint32_t v[5] = { uint32_t(geom_.x()), uint32_t(geom_.y()),
                            uint32_t(geom_.width()), uint32_t(geom_.height()), 0 };
    xcb_configure_window(conn_, w,
        XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_Y | XCB_CONFIG_WINDOW_WIDTH |
        XCB_CONFIG_WINDOW_HEIGHT | XCB_CONFIG_WINDOW_BORDER_WIDTH, v);
}

bool WindowManager::isClient(xcb_window_t w) const
{
    return std::find(clients_.begin(), clients_.end(), w) != clients_.end();
}

bool WindowManager::handleKey(xcb_keycode_t key)
{
    if (key == kEsc_) {
        goHome();
        return true;
    } else if (key == kTab_) {
        cycle();
        return true;
    } else if (key == kF4_) {
        closeFocused();
        return true;
    } else if (key == kRet_) {
        QProcess::startDetached("xterm", {});
        return true;
    } else if (key == kQ_) {
        QGuiApplication::quit();
        return true;
    }
    return false;
}

xcb_atom_t WindowManager::internAtom(const char *name)
{
    xcb_atom_t a = XCB_ATOM_NONE;
    auto *r = xcb_intern_atom_reply(conn_,
                                    xcb_intern_atom(conn_, 0, strlen(name), name),
                                    nullptr);
    if (r) {
        a = r->atom;
        free(r);
    }
    return a;
}
