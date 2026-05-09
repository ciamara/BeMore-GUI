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
                break;
            }
        }
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

void BatteryHandler::updateBattery()
{
    if (m_batteryPath.isEmpty()) {
        if (m_level != "VM Test") {
            m_level = "VM Test";
            emit levelChanged();
        }
        return;
    }

    QFile file(m_batteryPath);
    if (file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QTextStream in(&file);
        QString currentLevel = in.readLine().trimmed() + "%";
        
        if (m_level != currentLevel) {
            m_level = currentLevel;
            emit levelChanged();
        }
        file.close();
    } else {
        if (m_level != "Error") {
            m_level = "Error";
            emit levelChanged();
        }
    }
}