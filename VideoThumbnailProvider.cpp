#include "VideoThumbnailProvider.h"

#include <QAtomicInt>
#include <QDebug>
#include <QImage>
#include <QMediaPlayer>
#include <QMetaObject>
#include <QPointer>
#include <QQuickImageResponse>
#include <QQuickTextureFactory>
#include <QQueue>
#include <QTimer>
#include <QUrl>
#include <QVideoFrame>
#include <QVideoSink>
#include <memory>

/**********
 * CONSTANTS
 **********/
namespace {
constexpr int kMaxParallelDecoders = 2;
constexpr int kTimeoutMs = 8000;
constexpr int kMaxThumbnailWidth = 480;
}

/**********
 * HELPERS
 **********/

// Result holder handed to the QML image loader.
class ThumbnailResponse : public QQuickImageResponse
{
public:
    ThumbnailResponse(const QString &path, const QSize &requestedSize)
        : path_(path), requestedSize_(requestedSize) {}

    QQuickTextureFactory *textureFactory() const override
    {
        return image_.isNull() ? nullptr
                                : QQuickTextureFactory::textureFactoryForImage(image_);
    }

    QString errorString() const override
    {
        return error_;
    }

    void cancel() override
    {
        cancelled_.storeRelaxed(1);
    }

    bool cancelled() const
    {
        return cancelled_.loadRelaxed() != 0;
    }

    const QString &path() const
    {
        return path_;
    }

    const QSize &requestedSize() const
    {
        return requestedSize_;
    }

    // Called from the GUI thread by the extractor.
    void setResult(const QImage &image, const QString &error)
    {
        image_ = image;
        error_ = error;
        emit finished();
    }

private:
    QString path_;
    QSize requestedSize_;
    QImage image_;
    QString error_;
    QAtomicInt cancelled_;
};

// Lives in the GUI thread (QMediaPlayer wants an event loop) and decodes the
// first frame of queued videos, at most kMaxParallelDecoders at a time.
class ThumbnailExtractor : public QObject
{
public:
    void enqueue(const QPointer<ThumbnailResponse> &response)
    {
        queue_.enqueue(response);
        pump();
    }

private:
    void pump()
    {
        while (running_ < kMaxParallelDecoders && !queue_.isEmpty()) {
            QPointer<ThumbnailResponse> response = queue_.dequeue();
            if (!response)
                continue;
            if (response->cancelled()) {
                response->setResult({}, QStringLiteral("cancelled"));
                continue;
            }
            start(response);
        }
    }

    void start(const QPointer<ThumbnailResponse> &response)
    {
        running_++;

        auto *player = new QMediaPlayer(this);
        auto *sink = new QVideoSink(player);
        auto *timeout = new QTimer(player);

        auto finished = std::make_shared<bool>(false);
        player->setVideoSink(sink);
        timeout->setSingleShot(true);

        // Finish exactly once, whatever happens first: frame, error or timeout.
        auto finish = [this, player, response, finished](QImage image, const QString &error) {
            if (*finished)
                return;
            *finished = true;
            player->disconnect();
            player->stop();
            player->deleteLater();
            running_--;

            if (response) {
                if (!image.isNull()) {
                    const int maxW = response->requestedSize().width() > 0
                                         ? response->requestedSize().width()
                                         : kMaxThumbnailWidth;
                    if (image.width() > maxW)
                        image = image.scaledToWidth(maxW, Qt::SmoothTransformation);
                }
                response->setResult(image, image.isNull() ? error : QString());
            }
            QTimer::singleShot(0, this, [this] { pump(); });
        };

        connect(sink, &QVideoSink::videoFrameChanged, player,
                [finish](const QVideoFrame &frame) {
                    if (!frame.isValid())
                        return;
                    const QImage image = frame.toImage();
                    if (!image.isNull())
                        finish(image, {});
                });
        connect(player, &QMediaPlayer::errorOccurred, player,
                [finish](QMediaPlayer::Error, const QString &message) { finish({}, message); });
        connect(timeout, &QTimer::timeout, player,
                [finish] { finish({}, QStringLiteral("timed out decoding first frame")); });

        timeout->start(kTimeoutMs);
        player->setSource(QUrl::fromLocalFile(response->path()));
        player->pause(); // paused playback renders the first frame
    }

    QQueue<QPointer<ThumbnailResponse>> queue_;
    int running_ = 0;
};


/****************
 * IMPLEMENTATION
 ****************/

VideoThumbnailProvider::VideoThumbnailProvider()
    : extractor_(new ThumbnailExtractor)
{
}

VideoThumbnailProvider::~VideoThumbnailProvider()
{
    delete extractor_;
}

QQuickImageResponse *VideoThumbnailProvider::requestImageResponse(const QString &id,
                                                                  const QSize &requestedSize)
{
    const QString path = QString::fromUtf8(
        QByteArray::fromBase64(id.toLatin1(), QByteArray::Base64UrlEncoding));

    auto *response = new ThumbnailResponse(path, requestedSize);

    // This may be called from the QML image-loading thread; the extractor
    // (and its media players) must live in the GUI thread.
    QMetaObject::invokeMethod(
        extractor_,
        [this, response = QPointer<ThumbnailResponse>(response)] {
            if (response)
                extractor_->enqueue(response);
        },
        Qt::QueuedConnection);
    return response;
}

QString VideoThumbnailProvider::sourceFor(const QString &filePath)
{
    // base64url keeps arbitrary file names intact inside the URL
    const QByteArray id = filePath.toUtf8().toBase64(QByteArray::Base64UrlEncoding
                                                      | QByteArray::OmitTrailingEquals);
    return QStringLiteral("image://") + QLatin1String(providerId) + QLatin1Char('/')
           + QString::fromLatin1(id);
}

