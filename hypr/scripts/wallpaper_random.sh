#!/bin/bash

DIR="$HOME/Imagens/wallpapers"

IMG=$(find "$DIR" -type f | shuf -n 1)

pkill swaybg
swaybg -i "$IMG" -m fill &
