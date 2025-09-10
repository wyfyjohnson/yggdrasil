#!/usr/bin/env bash

picom -b &

xrandr --output DP-1 --primary --mode 3840x2160 --pos 1080x0 --rotate normal --output DP-2 --mode 1920x1080 --pos 0x0 --rotate left

nitrogen --restore

# conky -c ~/.config/conky/macchiato.conf
