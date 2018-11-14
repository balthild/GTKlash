#!/bin/sh
meson --reconfigure build && ninja -C build && ./build/src/gtklash
