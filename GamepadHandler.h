#ifndef GAMEPAD_HANDLER_H
#define GAMEPAD_HANDLER_H

// Xbox-style gamepad mapper via SDL2's GameController API

#include <QHash>
#include <QObject>
#include <QTimer>

typedef struct _SDL_GameController SDL_GameController;

class GamepadHandler : public QObject
{
    Q_OBJECT
public:
    explicit GamepadHandler(QObject *parent = nullptr);
    ~GamepadHandler() override;

    bool init(); // false if SDL could not be started

signals:
    void keyPressed(int qtKey); // a Qt::Key_* value
    void guidePressed();
    void closeRequested();

private:
    void poll();
    void handleButton(int button, bool down);
    void updateDirection();

    QTimer pollTimer_, repeatTimer_, comboTimer_;
    QHash<int, SDL_GameController *> pads_; // SDL instance id -> controller

    bool dpadUp_ = false;
    bool dpadDown_ = false;
    bool dpadLeft_ = false;
    bool dpadRight_ = false;

    int stickX_ = 0;
    int stickY_ = 0;
    int held_ = 0; // direction key currently held (0 = none)
    bool heldFromStick_ = false;
    bool back_ = false;
    bool start_ = false;
};

#endif // GAMEPAD_HANDLER_H
