#include "Launcher.h"
#include <QDebug>
#include <QFileInfo>
#include <QProcess>

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
