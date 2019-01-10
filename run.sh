#!/bin/sh

if [ "$1" = "--clean" ]; then
    rm -rf build subprojects/libclash/clash.{a,h}
    meson build && \
    ninja -C build && \
    RULE_SYNTAX_DATA=data/gtksourceview-4 ./build/src/gtklash
else
    meson --reconfigure build && \
    ninja -C build && \
    RULE_SYNTAX_DATA=data/gtksourceview-4 ./build/src/gtklash
fi
