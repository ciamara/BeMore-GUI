cmake_minimum_required(VERSION 3.16)

project(ConsoleUI VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Gui Qml Quick Svg Multimedia)

# window manager mode talks to X11 directly
find_package(PkgConfig REQUIRED)
pkg_check_modules(XORG REQUIRED IMPORTED_TARGET xcb x11)
# gamepad input
pkg_check_modules(SDL2 REQUIRED IMPORTED_TARGET sdl2)

qt_add_executable(BeMore
    main.cpp
    BatteryHandler.cpp
    BatteryHandler.h
    Launcher.cpp
    Launcher.h
    WindowManager.cpp
    WindowManager.h
    GamepadHandler.cpp
    GamepadHandler.h
    VideoPlayer.cpp
    VideoPlayer.h
    VideoThumbnailProvider.cpp
    VideoThumbnailProvider.h
)

find_package(Qt6 REQUIRED COMPONENTS Gui Qml Quick Svg)

qt_add_qml_module(BeMore
    URI ConsoleApp
    VERSION 1.0
    QML_FILES main.qml
    RESOURCES
        icons/camera.svg
        icons/music.svg
        icons/controller.svg
        icons/poweron.svg
        icons/sprocket.svg
        icons/wallpaper.jpg
        icons/back.svg
        icons/wallpaper_moving.gif
        icons/mode.svg
        icons/battery100.svg
        icons/battery75.svg
        icons/battery50.svg
        icons/battery25.svg
        icons/thunder.svg
        icons/wallpaper.svg
        icons/wallpaper_static.jpg
        icons/pause.svg
)

target_link_libraries(BeMore PRIVATE 
    Qt6::Gui 
    Qt6::Qml 
    Qt6::Quick 
    Qt6::Svg
    Qt6::Multimedia
    PkgConfig::XORG
    PkgConfig::SDL2
)
