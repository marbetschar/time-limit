#!/bin/bash
set -e

flatpak-builder build com.github.marbetschar.time-limit.yml --user --install --force-clean

export G_MESSAGES_DEBUG=all
# Uncomment to launch GTK Inspector upon app start:
#export GTK_DEBUG=interactive
flatpak run com.github.marbetschar.time-limit