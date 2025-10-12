#!/bin/bash

# Wrapper para executar o mini seletor de wallpapers
# Garante que as variáveis de ambiente estejam corretas

# Definir variáveis de ambiente necessárias
export DISPLAY=${DISPLAY:-:0}
export WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-0}

# Log para debug
echo "$(date): Executando mini_swww_selector.py" >> /tmp/wallpaper_selector.log
echo "DISPLAY=$DISPLAY" >> /tmp/wallpaper_selector.log
echo "WAYLAND_DISPLAY=$WAYLAND_DISPLAY" >> /tmp/wallpaper_selector.log

# Executar o script Python
cd ~/.config/waypaper
python3 ~/.config/waypaper/mini_swww_selector.py 2>&1 | tee -a /tmp/wallpaper_selector.log