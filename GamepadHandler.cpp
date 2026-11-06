#include "GamepadHandler.h"

#include <QDebug>
#include <algorithm>
#include <cstdlib>

#define SDL_MAIN_HANDLED
#include <SDL2/SDL.h>

GamepadHandler::GamepadHandler(QObject *parent) : QObject(parent) {}

GamepadHandler::~GamepadHandler()
{
    for (SDL_GameController *c : std::as_const(pads_))
        SDL_GameControllerClose(c);

    if (SDL_WasInit(SDL_INIT_GAMECONTROLLER))
        SDL_Quit();
}

bool GamepadHandler::init()
{
    SDL_SetHint(SDL_HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS, "1");
    if (SDL_Init(SDL_INIT_GAMECONTROLLER | SDL_INIT_EVENTS) != 0) {
        qWarning() << "[Gamepad] SDL init failed:" << SDL_GetError();
        return false;
    }

    connect(&pollTimer_, &QTimer::timeout, this, &GamepadHandler::poll);
    pollTimer_.start(10);

    connect(&repeatTimer_, &QTimer::timeout, this, [this] {
        if (held_) {
            emit keyPressed(held_);
        }
        repeatTimer_.setInterval(120);
    });

    comboTimer_.setSingleShot(true);
    comboTimer_.setInterval(1500);
    connect(&comboTimer_, &QTimer::timeout, this, &GamepadHandler::closeRequested);
    return true;
}

void GamepadHandler::poll()
{
    SDL_Event e;
    while (SDL_PollEvent(&e)) {
        switch (e.type) {
        case SDL_CONTROLLERDEVICEADDED: {
            if (SDL_GameController *c = SDL_GameControllerOpen(e.cdevice.which)) {
                pads_.insert(SDL_JoystickInstanceID(SDL_GameControllerGetJoystick(c)), c);
                qInfo() << "[Gamepad] connected:" << SDL_GameControllerName(c);
            }
            break;
        }
        case SDL_CONTROLLERDEVICEREMOVED: {
            if (SDL_GameController *c = pads_.take(e.cdevice.which)) SDL_GameControllerClose(c);
            dpadUp_ = dpadDown_ = dpadLeft_ = dpadRight_ = false;
            stickX_ = stickY_ = 0;
            back_ = start_ = false;
            comboTimer_.stop();
            updateDirection();
            qInfo() << "[Gamepad] disconnected";
            break;
        }
        case SDL_CONTROLLERBUTTONDOWN: {
            handleButton(e.cbutton.button, true);
            break;
        }
        case SDL_CONTROLLERBUTTONUP: {
            handleButton(e.cbutton.button, false);
            break;
        }
        case SDL_CONTROLLERAXISMOTION: {
            if (e.caxis.axis == SDL_CONTROLLER_AXIS_LEFTX) {
                stickX_ = e.caxis.value;
                updateDirection();
            }
            else if (e.caxis.axis == SDL_CONTROLLER_AXIS_LEFTY) {
                stickY_ = e.caxis.value;
                updateDirection();
            }
            break;
        }
        default:
            break;
        }
    }
}

void GamepadHandler::handleButton(int button, bool isDown)
{
    switch (button) {
    case SDL_CONTROLLER_BUTTON_DPAD_UP:
        dpadUp_ = isDown;
        updateDirection();
        break;
    case SDL_CONTROLLER_BUTTON_DPAD_DOWN:
        dpadDown_ = isDown;
        updateDirection();
        break;
    case SDL_CONTROLLER_BUTTON_DPAD_LEFT:
        dpadLeft_ = isDown;
        updateDirection();
        break;
    case SDL_CONTROLLER_BUTTON_DPAD_RIGHT:
        dpadRight_ = isDown;
        updateDirection();
        break;

    case SDL_CONTROLLER_BUTTON_A:
        if (isDown)
            emit keyPressed(Qt::Key_Space);
        break;
    case SDL_CONTROLLER_BUTTON_B:
        if (isDown)
            emit keyPressed(Qt::Key_Escape);
        break;
    case SDL_CONTROLLER_BUTTON_GUIDE:
        if (isDown)
            emit guidePressed();
        break;

    case SDL_CONTROLLER_BUTTON_BACK:
    case SDL_CONTROLLER_BUTTON_START:
        (button == SDL_CONTROLLER_BUTTON_BACK ? back_ : start_) = isDown;
        if (back_ && start_)
            comboTimer_.start();
        else
            comboTimer_.stop();
        break;
    }
}

void GamepadHandler::updateDirection()
{
    int key = 0;
    bool fromStick = false;

    if (dpadUp_)
        key = Qt::Key_Up;
    else if (dpadDown_)
        key = Qt::Key_Down;
    else if (dpadLeft_)
        key = Qt::Key_Left;
    else if (dpadRight_)
        key = Qt::Key_Right;
    else {
        const int threshold = heldFromStick_ ? 10000 : 16000; // hysteresis preventing jitter
        const int ax = std::abs(stickX_), ay = std::abs(stickY_);
        if (std::max(ax, ay) > threshold) {
            fromStick = true;
            key = ax > ay ? (stickX_ < 0 ? Qt::Key_Left : Qt::Key_Right)
                          : (stickY_ < 0 ? Qt::Key_Up   : Qt::Key_Down);
        }
    }

    heldFromStick_ = fromStick;
    if (key == held_)
        return;
    held_ = key;
    repeatTimer_.stop();
    if (key) {
        emit keyPressed(key);
        repeatTimer_.start(350);
    }
}
