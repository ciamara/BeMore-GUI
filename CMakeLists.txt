cmake_minimum_required(VERSION 3.16)

project(ConsoleUI VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Gui Qml Quick)

qt_add_executable(BeMore
    main.cpp
)

qt_add_qml_module(BeMore
    URI ConsoleApp
    VERSION 1.0
    QML_FILES main.qml
    RESOURCES
        icons/kitty1.jpg
        icons/kitty2.jpg
        icons/kitty3.png
        icons/kitty4.jpg
        icons/kitty5.jpg
)

target_link_libraries(BeMore PRIVATE Qt6::Gui Qt6::Qml Qt6::Quick)