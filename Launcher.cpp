#include "Launcher.h"
#include <QDebug>
#include <QFileInfo>
#include <QProcess>

// TODO: SET CORRECT IP AND MOONLIGHT PATH
namespace Config {
    const QString MoonlightBinaryPath = QStringLiteral("/usr/bin/moonlight-qt");
    const QString HostIp = QStringLiteral("192.168.1.100");
}

bool Launcher::launch(const QString &thumbnailPath)
{
    const QFileInfo thumb(thumbnailPath);
    const QString base = thumb.absolutePath() + '/' + thumb.completeBaseName();

    for (const QString &suffix : { QStringLiteral(".sh"), QStringLiteral(".AppImage"), QString() }) {
        const QFileInfo candidate(base + suffix);
        if (candidate.isFile() && candidate.isExecutable()) {
            qInfo() << "[Launcher] starting" << candidate.absoluteFilePath();
            return QProcess::startDetached(candidate.absoluteFilePath(), {}, thumb.absolutePath());
        }
    }
    qWarning() << "[Launcher] no executable found next to" << thumbnailPath;
    return false;
}

bool Launcher::launchMoonlight()
{
    const QFileInfo binInfo(Config::MoonlightBinaryPath);
    if (!binInfo.exists() || !binInfo.isExecutable()) {
        qWarning() << "[Launcher] Error with binary path:" << Config::MoonlightBinaryPath;
        return false;
    }

    QStringList arguments;
    arguments << QStringLiteral("stream") << Config::HostIp;

    qInfo() << "[Launcher] Starting:" << Config::MoonlightBinaryPath << arguments;
    return QProcess::startDetached(Config::MoonlightBinaryPath, arguments);
}