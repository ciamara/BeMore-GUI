#!/usr/bin/env bash
# Run from the BeMore-GUI project folder, after copying these files over it.
# Debian/Ubuntu (Qt 6.4+). Other distros: install the Qt6 base/declarative/multimedia/svg dev packages,
# the Qt6 QML modules (Quick, Controls, Labs.FolderListModel, Multimedia), libxcb, libx11, cmake, xterm.
set -e
# sudo apt install -y build-essential cmake pkg-config libxcb1-dev libx11-dev libsdl2-dev \
#     qt6-base-dev qt6-declarative-dev qt6-multimedia-dev qt6-svg-dev libqt6svg6 \
#     qml6-module-qtquick qml6-module-qtquick-controls qml6-module-qtquick-window \
#     qml6-module-qtquick-templates qml6-module-qtquick-layouts \
#     qml6-module-qt-labs-folderlistmodel qml6-module-qtmultimedia \
#     gstreamer1.0-plugins-good gstreamer1.0-libav \
#     xterm xserver-xephyr xinit
# 
# cmake -S . -B build # -DCMAKE_BUILD_TYPE=Release
# cmake --build build -j"$(nproc)"

sudo install -m755 build/BeMore /usr/local/bin/bemore-wm
sudo install -Dm644 bemore-wm.desktop /usr/share/xsessions/bemore-wm.desktop   # login-screen entry
echo "exec /usr/local/bin/bemore-wm" > ~/.xinitrc                              # for startx
sudo usermod -aG input "$USER"      # lets SDL read /dev/input gamepads (log out/in once)
echo "Installed. Test with ./test.sh, or log out and pick 'BeMore Console'."
