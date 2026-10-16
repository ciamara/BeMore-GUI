#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>

#include "batteryHandler.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    BatteryHandler batteryHandler;

    QQmlApplicationEngine engine;

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