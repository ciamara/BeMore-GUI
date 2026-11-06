#include "videoThumbnailProvider.h"
#include <QProcess>
#include <QColor>
#include <QStringList>

VideoThumbnailProvider::VideoThumbnailProvider()
    : QQuickImageProvider(QQuickImageProvider::Image)
{
}

QImage VideoThumbnailProvider::requestImage(const QString &id, QSize *size, const QSize &requestedSize)
{
    QString localPath = id;
    if (localPath.startsWith("//")) {
        localPath = localPath.mid(1); 
    }

    QProcess process;
    
    QStringList args = {"-i", localPath, "-ss", "00:00:01", "-vframes", "1", "-f", "mjpeg", "pipe:1"};

    process.start("ffmpeg", args);
    process.waitForFinished(3000);

    QByteArray imageData = process.readAllStandardOutput();
    QImage image;
    
    if (!imageData.isEmpty()) {
        image.loadFromData(imageData, "JPG");
    }

    if (image.isNull()) {
        image = QImage(240, 240, QImage::Format_RGB32);
        image.fill(QColor("#2a2a2a"));
    }

    if (size) {
        *size = image.size();
    }

    if (requestedSize.width() > 0 && requestedSize.height() > 0) {
        image = image.scaled(requestedSize, Qt::KeepAspectRatio, Qt::SmoothTransformation);
    }

    return image;
}