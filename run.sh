#!/bin/sh

mkdir -p $HOME/.local/share/gtklash/gtksourceview-4/
cp -f data/clashrule.lang $HOME/.local/share/gtklash/gtksourceview-4/
cp -f data/clashrule-light.xml $HOME/.local/share/gtklash/gtksourceview-4/

if [ "$1" = "--clean" ]; then
    rm -rf build subprojects/libclash/clash.{a,h}
    meson build && ninja -C build && ./build/src/gtklash
else
    meson --reconfigure build && ninja -C build && ./build/src/gtklash
fi
