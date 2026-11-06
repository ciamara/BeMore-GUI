#!/bin/sh
# Nested test inside your current desktop - no logout needed.
# (Run from the project folder after building: ./test.sh)
Xephyr :2 -screen 1560x720 &
sleep 1
DISPLAY=:2 ./build/BeMore
kill %1
