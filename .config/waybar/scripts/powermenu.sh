#!/bin/bash

# Power Menu com Wofi
# Script para menu de power animado em tela cheia

# Ícones para as opções
poweroff=" Desligar"
reboot=" Reiniciar"
suspend=" Suspender"
hibernate=" Hibernar"
lock=" Bloquear"
logout=" Logout"
cancel=" Cancelar"

# Criar as opções do menu
options="$poweroff\n$reboot\n$suspend\n$hibernate\n$lock\n$logout\n$cancel"

# Mostrar o menu com wofi
chosen=$(echo -e "$options" | wofi \
    --dmenu \
    --location=center \
    --width=600 \
    --height=400 \
    --lines=7 \
    --columns=1 \
    --prompt="Escolha uma opção:" \
    --hide-scroll \
    --matching=contains \
    --insensitive \
    --no-actions \
    --style="/home/vibewill/.config/waybar/scripts/powermenu.css" \
    --gtk-dark)

# Executar a ação baseada na escolha
case $chosen in
    $poweroff)
        systemctl poweroff
        ;;
    $reboot)
        systemctl reboot
        ;;
    $suspend)
        systemctl suspend
        ;;
    $hibernate)
        systemctl hibernate
        ;;
    $lock)
        # Adapte para o seu lock screen (swaylock, waylock, etc.)
        if command -v swaylock &> /dev/null; then
            swaylock -f
        elif command -v waylock &> /dev/null; then
            waylock
        elif command -v hyprlock &> /dev/null; then
            hyprlock
        else
            notify-send "Nenhum screen locker encontrado"
        fi
        ;;
    $logout)
        # Logout do Hyprland
        hyprctl dispatch exit
        ;;
    $cancel)
        # Não fazer nada, apenas sair
        exit 0
        ;;
    *)
        # Se ESC ou cancelar
        exit 0
        ;;
esac
