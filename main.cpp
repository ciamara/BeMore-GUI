#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>
#include <QGamepadManager>
#include <QDebug>

#include "BatteryHandler.h"
#include "VideoThumbnailProvider.h"

int main(int argc, char *argv[])
{
    qputenv("QT_GAMEPAD", "evdev");

    QGuiApplication app(argc, argv);

    auto *gamepadManager = QGamepadManager::instance();
    qDebug() << "[C++ Gamepad] Connected gamepads:" << gamepadManager->connectedGamepads();

    QObject::connect(gamepadManager, &QGamepadManager::gamepadConnected, [](int deviceId){
        qDebug() << "[C++ Gamepad] Gamepad connected with ID:" << deviceId;
    });

    BatteryHandler batteryHandler;

    QQmlApplicationEngine engine;

    engine.addImageProvider(QLatin1String("vidthumb"), new VideoThumbnailProvider);
    engine.rootContext()->setContextProperty("BatteryContext", &batteryHandler);

    const QUrl url(QStringLiteral("qrc:/main.qml"));
    
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
