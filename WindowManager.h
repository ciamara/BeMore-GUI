#ifndef WINDOW_MANAGER_H
#define WINDOW_MANAGER_H

#include <QAbstractNativeEventFilter>
#include <QRect>
#include <vector>
#include <xcb/xcb.h>

class QWindow;

class WindowManager : public QAbstractNativeEventFilter
{
public:
    // Claims the X root window. Returns false (and changes nothing) if we are
    // not on X11 or another window manager is already running.
    bool start(QWindow *home);

    void toggleHome(); // home <-> most recent program
    void closeFocused(bool force = false); // ask politely, or kill the program if force
    bool homeFocused() const;

    bool nativeEventFilter(const QByteArray &eventType, void *message, qintptr *result) override;

private:
    void focus(xcb_window_t w);
    void goHome();
    void cycle();
    void removeClient(xcb_window_t w);
    void placeFullscreen(xcb_window_t w);
    bool isClient(xcb_window_t w) const;
    bool handleKey(xcb_keycode_t key);
    xcb_atom_t internAtom(const char *name);

    xcb_connection_t *conn_ = nullptr;
    xcb_window_t root_ = 0, home_ = 0, focused_ = 0;
    QRect geom_;
    std::vector<xcb_window_t> clients_; // most recently focused first
    xcb_atom_t wmProtocols_ = XCB_ATOM_NONE, wmDelete_ = XCB_ATOM_NONE;
    xcb_keycode_t kEsc_ = 0, kTab_ = 0, kF4_ = 0, kRet_ = 0, kQ_ = 0;
};

#endif // WINDOW_MANAGER_H
