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
    Q_PROPERTY(bool isCharging READ isCharging NOTIFY isChargingChanged)

public:
    explicit BatteryHandler(QObject *parent = nullptr);
    QString level() const;
    bool isCharging() const;

signals:
    void levelChanged();
    void isChargingChanged();

private slots:
    void updateBattery();

private:
    QString m_level;
    bool m_isCharging;
    QString m_batteryPath;
    QString m_statusPath;
    QTimer m_timer;
};

#endif // BATTERYHANDLER_H