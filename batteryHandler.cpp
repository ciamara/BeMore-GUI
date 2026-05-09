#include "batteryHandler.h"
#include <QDir>
#include <QFile>
#include <QTextStream>

BatteryHandler::BatteryHandler(QObject *parent) 
    : QObject(parent), m_level("--%")
{
    // battery folder
    QDir powerSupplyDir("/sys/class/power_supply");
    if (powerSupplyDir.exists()) {
        QStringList entries = powerSupplyDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
        for (const QString &entry : entries) {
            if (entry.contains("BAT") || entry.contains("battery", Qt::CaseInsensitive)) {
                m_batteryPath = powerSupplyDir.absoluteFilePath(entry) + "/capacity";
                m_statusPath = powerSupplyDir.absoluteFilePath(entry) + "/status";
                break;
            }
        }
    }

    if (m_batteryPath.isEmpty()) {
        qDebug() << "[BatteryReader] No battery found. Falling back to VM Test mode.";
    } else {
        qDebug() << "[BatteryReader] Battery capacity file detected at:" << m_batteryPath;
        qDebug() << "[BatteryReader] Battery status file detected at:" << m_statusPath;
    }

    // update every 4min
    connect(&m_timer, &QTimer::timeout, this, &BatteryHandler::updateBattery);
    m_timer.start(240000); 
    updateBattery();
}

QString BatteryHandler::level() const
{
    return m_level;
}

bool BatteryHandler::isCharging() const
{
    return m_isCharging;
}

void BatteryHandler::updateBattery()
{
    if (m_batteryPath.isEmpty()) {
        if (m_level != "VM Test") {
            m_level = "VM Test";
            emit levelChanged();
        }
        if (!m_isCharging) {
            m_isCharging = false;
            emit isChargingChanged();
        }
        return;
    }

    QFile file(m_batteryPath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        QString rawValue = in.readLine().trimmed();

        bool ok;
        int intLevel = rawValue.toInt(&ok);
        
        if (ok) {
            if (intLevel > 100) {
                intLevel = 100;
            }
            
            QString currentLevel = QString::number(intLevel) + "%";
            
            if (m_level != currentLevel) {
                m_level = currentLevel;
                emit levelChanged();
            }
        }
        file.close();
    } else {
        if (m_level != "Error") {
            m_level = "Error";
            emit levelChanged();
        }
    }

    if (!m_statusPath.isEmpty()) {
        QFile statusFile(m_statusPath);
        if (statusFile.open(QIODevice::ReadOnly | QIODevice::Text)) {
            QTextStream in(&statusFile);
            QString status = in.readLine().trimmed();
            
            bool currentlyCharging = (status == "Charging" || status == "Full");
            
            if (m_isCharging != currentlyCharging) {
                m_isCharging = currentlyCharging;
                emit isChargingChanged();
            }
            statusFile.close();
        }
    }
}