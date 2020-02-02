#!/bin/bash
set -e

meson build --prefix=/usr
cd build
ninja

sudo ninja install

export G_MESSAGES_DEBUG=all
name.betschart.marco.timer
