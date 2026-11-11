#ifndef LAUNCHER_H
#define LAUNCHER_H

#include <QObject>

class Launcher : public QObject
{
    Q_OBJECT
public:
    using QObject::QObject;
    Q_INVOKABLE bool launch(const QString &thumbnailPath);
    Q_INVOKABLE bool launchMoonlight();
};

#endif // LAUNCHER_H
