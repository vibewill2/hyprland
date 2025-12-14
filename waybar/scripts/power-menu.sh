#!/usr/bin/env bash
set -euo pipefail

# Menu simples de energia para Waybar.
# Depende de: wofi (detectado no sistema).

menu() {
  # -dmenu: modo dmenu
  # -i: case-insensitive
  # -p: prompt
  printf "Desligar\nReiniciar\nSair (Hyprland)\nBloquear\n" \
    | wofi --dmenu -i -p "Energia"
}

choice="$(menu || true)"

case "$choice" in
  "Desligar")
    systemctl poweroff
    ;;
  "Reiniciar")
    systemctl reboot
    ;;
  "Sair (Hyprland)")
    hyprctl dispatch exit
    ;;
  "Bloquear")
    # Tenta travar a sessão via logind (funciona na maioria dos setups)
    loginctl lock-session || true
    ;;
  *)
    exit 0
    ;;
esac
