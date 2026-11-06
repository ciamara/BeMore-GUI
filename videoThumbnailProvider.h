#ifndef VIDEOTHUMBNAILPROVIDER_H
#define VIDEOTHUMBNAILPROVIDER_H

#include <QQuickImageProvider>
#include <QString>
#include <QSize>
#include <QImage>

class VideoThumbnailProvider : public QQuickImageProvider
{
public:
    VideoThumbnailProvider();
    QImage requestImage(const QString &id, QSize *size, const QSize &requestedSize) override;
};

#endif // VIDEOTHUMBNAILPROVIDER_H