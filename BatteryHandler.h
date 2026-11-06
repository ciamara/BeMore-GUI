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
    QString level_;
    bool isCharging_;
    QString batteryPath_;
    QString statusPath_;
    QTimer timer_;

    unsigned refresh_rate_ms_ = 60000;
};

#endif // BATTERYHANDLER_H
