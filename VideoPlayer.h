#ifndef VIDEOPLAYER_H
#define VIDEOPLAYER_H

#include <QObject>
#include <QString>

class QAudioOutput;
class QMediaPlayer;
class QVideoSink;

class VideoPlayer : public QObject
{
    Q_OBJECT

public:
    explicit VideoPlayer(QObject *parent = nullptr);

    // Accepts a local path
    Q_INVOKABLE void play(const QString &path);
    Q_INVOKABLE QString thumbnailSource(const QString &path) const;
};

#endif // VIDEOPLAYER_H
