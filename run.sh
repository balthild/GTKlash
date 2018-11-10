#!/bin/sh
rm -rf build && meson build && ninja -C build && ./build/src/gtklash
