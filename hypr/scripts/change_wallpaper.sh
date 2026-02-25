#!/bin/bash

wallpapers_dir="$HOME/Imagens/wallpapers"

pgrep swww-daemon >/dev/null || swww-daemon &

while true; do
    wallpaper="$(find "$wallpapers_dir" -type f | shuf -n 1)"
    swww img --transition-fps 30 "$wallpaper"
    sleep 1800
done
