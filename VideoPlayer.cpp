#include "VideoPlayer.h"
#include "VideoThumbnailProvider.h"

#include <QDebug>
#include <QProcess>
#include <algorithm>

VideoPlayer::VideoPlayer(QObject *parent)
    : QObject(parent)
{
}

void VideoPlayer::play(const QString &path)
{
    qint64 pid;
    bool success = QProcess::startDetached("mpv", {path}, {}, &pid);
    if (success) {
        qInfo() << "[VideoPlayer] playing";
    } else {
        qWarning() << "[VideoPlayer] unable to start";
        return;
    }
}

QString VideoPlayer::thumbnailSource(const QString &path) const
{
    return VideoThumbnailProvider::sourceFor(path);
}
