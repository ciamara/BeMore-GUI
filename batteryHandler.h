#ifndef BATTERYHANDLER_H
#define BATTERYHANDLER_H

#include <QObject>
#include <QTimer>
#include <QString>

class BatteryHandler : public QObject
{
    Q_OBJECT
    // exposes battery level
    Q_PROPERTY(QString level READ level NOTIFY levelChanged)

public:
    explicit BatteryHandler(QObject *parent = nullptr);
    QString level() const;

signals:
    void levelChanged();

private slots:
    void updateBattery();

private:
    QString m_level;
    QString m_batteryPath;
    QTimer m_timer;
};

#endif // BATTERYHANDLER_H