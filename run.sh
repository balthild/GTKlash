#!/bin/sh

export RULE_SYNTAX_DATA=$PWD/data/gtksourceview-4
export ICON_DIR=$PWD/data

if [ "$1" = "--clean" ]; then
    rm -rf build subprojects/libclash/clash.{a,h}
    meson build && \
    ninja -C build && \
    build/src/gtklash
else
    meson --reconfigure build && \
    ninja -C build && \
    build/src/gtklash
fi
