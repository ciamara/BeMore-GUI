#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QKeyEvent>
#include <QQmlContext>
#include <QQuickWindow>

#include "BatteryHandler.h"
#include "Launcher.h"
#include "GamepadHandler.h"
#include "WindowManager.h"
#include "VideoPlayer.h"
#include "VideoThumbnailProvider.h"

int main(int argc, char *argv[])
{
    // The window manager needs X11. Prefer xcb whenever an X display exists.
    if (qEnvironmentVariableIsEmpty("QT_QPA_PLATFORM") && !qEnvironmentVariableIsEmpty("DISPLAY"))
        qputenv("QT_QPA_PLATFORM", "xcb");

    QGuiApplication app(argc, argv);

    BatteryHandler batteryHandler;
    Launcher launcher;
    VideoPlayer videoPlayer;

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("BatteryContext", &batteryHandler);
    engine.rootContext()->setContextProperty("Launcher", &launcher);
    engine.rootContext()->setContextProperty("VideoPlayer", &videoPlayer);
    engine.addImageProvider(QLatin1String(VideoThumbnailProvider::providerId),
                            new VideoThumbnailProvider);

    const QUrl url(u"qrc:/ConsoleApp/main.qml"_qs);

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);

    engine.load(url);
    if (engine.rootObjects().isEmpty())
        return -1;

    // Window manager mode: the QML window becomes the fullscreen "home" screen
    // and every program started from it is managed by us.
    // If another WM is already running (e.g. during development on a normal
    // desktop) this silently falls back to the original windowed behaviour.
    WindowManager& wm = WindowManager::GetInstance();
    auto *homeWindow = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
    const bool wmActive = homeWindow && wm.start(homeWindow);
    if (wmActive)
        app.installNativeEventFilter(&wm);

    // Gamepad navigation: pad input is turned into the key events the QML
    // already understands. While a game is in front the launcher stays quiet
    // (the game reads the pad itself); only the Guide button and the
    // Back+Start close-combo are handled by us.
    GamepadHandler pad;
    if (pad.init()) {
        QObject::connect(&pad, &GamepadHandler::keyPressed, &app, [&](int key) {
            if (!homeWindow || (wmActive && !wm.homeFocused()))
                return;
            QKeyEvent press(QEvent::KeyPress, key, Qt::NoModifier);
            QCoreApplication::sendEvent(homeWindow, &press);
            QKeyEvent release(QEvent::KeyRelease, key, Qt::NoModifier);
            QCoreApplication::sendEvent(homeWindow, &release);
        });
        if (wmActive) {
            QObject::connect(&pad, &GamepadHandler::guidePressed, &app, [&] { wm.toggleHome(); });
            QObject::connect(&pad, &GamepadHandler::closeRequested, &app, [&] { wm.closeFocused(true); });
        }
    }

    return app.exec();
}
