#!/bin/sh
if [ "$1" = "--clean" ]; then
    rm -rf build subprojects/libclash/clash.{a,h}
    meson build && ninja -C build && ./build/src/gtklash
else
    meson --reconfigure build && ninja -C build && ./build/src/gtklash
fi
