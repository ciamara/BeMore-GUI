cmake_minimum_required(VERSION 3.16)

project(ConsoleUI VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt5 REQUIRED COMPONENTS 
    Core 
    Gui 
    Qml 
    Quick 
    Svg 
    Multimedia
)

add_executable(BeMore
    main.cpp
    batteryHandler.cpp
    batteryHandler.h
    resources.qrc
)

target_link_libraries(BeMore PRIVATE 
    Qt5::Core
    Qt5::Gui 
    Qt5::Qml 
    Qt5::Quick 
    Qt5::Svg
    Qt5::Multimedia
)