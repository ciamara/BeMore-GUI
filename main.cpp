#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDirIterator>

#include "batteryHandler.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    BatteryHandler batteryHandler;

    // qDebug() << "qrc:";
    // QDirIterator it(":", QDirIterator::Subdirectories);
    // while (it.hasNext()) {
    //     qDebug() << it.next();
    // }

    QQmlApplicationEngine engine;

    engine.rootContext()->setContextProperty("BatteryContext", &batteryHandler);

    const QUrl url(u"qrc:/ConsoleApp/main.qml"_qs);
    
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}