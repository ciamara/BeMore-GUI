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
    qInfo() << "[VideoPlayer] playing" << path;
    QProcess::startDetached("mpv", {path});
}

QString VideoPlayer::thumbnailSource(const QString &path) const
{
    return VideoThumbnailProvider::sourceFor(path);
}
