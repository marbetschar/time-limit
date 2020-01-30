#!/bin/bash
set -e

meson build --prefix=/usr
cd build
ninja

sudo ninja install
name.betschart.marco.timer
