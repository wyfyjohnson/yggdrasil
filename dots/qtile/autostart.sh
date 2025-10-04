#!/usr/bin/env bash
if [ "$XDG_SESSION_TYPE" = "x11" ]; then
  
  picom -b &

  xrandr --output DP-1 --primary --mode 3840x2160 --pos 1080x0 --rotate normal --output DP-2 --mode 1920x1080 --pos 0x0 --rotate left

  nitrogen --restore

elif [ "$XDG_SESSION_TYPE" = "wayland" ]; then

  if ! pgrep -x "swww-daemon" > /dev/null; then
    swww-daemon &
    sleep 1
  fi

  swww img --outputs DP-1 ~/Pictures/Wallpapers/waifu/43.png &
  swww img --outputs DP-2 ~/Pictures/Wallpapers/Vertical/rem.jpg &
fi
# conky -c ~/.config/conky/macchiato.conf
