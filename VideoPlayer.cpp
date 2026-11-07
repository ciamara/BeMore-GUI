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
    qint64 *pid;
    QProcess::startDetached("mpv", {path}, {}, pid);
    qInfo() << "[VideoPlayer] playing" << path << " " << *pid;
}

QString VideoPlayer::thumbnailSource(const QString &path) const
{
    return VideoThumbnailProvider::sourceFor(path);
}
