#include "BatteryHandler.h"
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QDebug>


BatteryHandler::BatteryHandler(QObject *parent)
    : QObject(parent), level_("--%")
{
    // battery folder
    QDir powerSupplyDir("/sys/class/power_supply");
    if (powerSupplyDir.exists()) {
        QStringList entries = powerSupplyDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
        for (const QString &entry : entries) {
            if (entry.contains("BAT") || entry.contains("battery", Qt::CaseInsensitive)) {
                batteryPath_ = powerSupplyDir.absoluteFilePath(entry) + "/capacity";
                statusPath_ = powerSupplyDir.absoluteFilePath(entry) + "/status";
                break;
            }
        }
    }

    if (batteryPath_.isEmpty()) {
        qDebug() << "[BatteryReader] No battery found. Falling back to VM Test mode.";
    } else {
        qDebug() << "[BatteryReader] Battery capacity file detected at:" << batteryPath_;
        qDebug() << "[BatteryReader] Battery status file detected at:" << statusPath_;
    }

    connect(&timer_, &QTimer::timeout, this, &BatteryHandler::updateBattery);
    timer_.start(refresh_rate_ms_);
    updateBattery();
}

QString BatteryHandler::level() const
{
    return level_;
}

bool BatteryHandler::isCharging() const
{
    return isCharging_;
}

void BatteryHandler::updateBattery()
{
    if (batteryPath_.isEmpty()) {
        if (level_ != "VM Test") {
            level_ = "VM Test";
            emit levelChanged();
        }
        if (!isCharging_) {
            isCharging_ = false;
            emit isChargingChanged();
        }
        return;
    }

    QFile file(batteryPath_);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        QString rawValue = in.readLine().trimmed();

        bool ok;
        int intLevel = rawValue.toInt(&ok);

        if (ok) {
            if (intLevel > 100)
                intLevel = 100;

            QString currentLevel = QString::number(intLevel) + "%";

            if (level_ != currentLevel) {
                level_ = currentLevel;
                emit levelChanged();
            }
        }
        file.close();
    } else {
        if (level_ != "Error") {
            level_ = "Error";
            emit levelChanged();
        }
    }

    if (!statusPath_.isEmpty()) {
        QFile statusFile(statusPath_);
        if (statusFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QTextStream in(&statusFile);
            QString status = in.readLine().trimmed();

            bool currentlyCharging = (status == "Charging" || status == "Full");

            if (isCharging_ != currentlyCharging) {
                isCharging_ = currentlyCharging;
                emit isChargingChanged();
            }
            statusFile.close();
        }
    }
}
