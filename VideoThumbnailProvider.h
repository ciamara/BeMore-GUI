#ifndef VIDEOTHUMBNAILPROVIDER_H
#define VIDEOTHUMBNAILPROVIDER_H

#include <QQuickAsyncImageProvider>
#include <QString>

class ThumbnailExtractor;

// Serves the first frame of a video file as an image:
//   Image { source: "image://videothumb/<id>" }
// Build the source with VideoThumbnailProvider::sourceFor() (exposed to QML
// as VideoPlayer.thumbnailSource(path)). Frames are decoded asynchronously,
// a couple at a time, so a folder with many videos doesn't stall the UI.
class VideoThumbnailProvider : public QQuickAsyncImageProvider
{
public:
    static constexpr const char *providerId = "videothumb";

    VideoThumbnailProvider();
    ~VideoThumbnailProvider() override;

    QQuickImageResponse *requestImageResponse(const QString &id,
                                              const QSize &requestedSize) override;

    static QString sourceFor(const QString &filePath);

private:
    ThumbnailExtractor *extractor_;
};

#endif // VIDEOTHUMBNAILPROVIDER_H
