#!/bin/bash

# Script FINAL - funciona baseado em detecção de processos de áudio

while true; do
    # Verificar se há streams de áudio PipeWire
    streams=$(pactl list short sink-inputs 2>/dev/null | wc -l)
    
    # Obter volume atual
    volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null | awk '{print $2}' | sed 's/0\.//' || echo "50")
    volume=${volume:0:2}
    
    # Verificar processos de áudio conhecidos
    audio_processes=$(pgrep -f "firefox|chrome|chromium|spotify|vlc|mpv|mplayer|rhythmbox|totem|audacious|clementine|amarok|banshee|deadbeef|smplayer|dragon|elisa|strawberry|qmmp|audacity|brasero|k3b|pavucontrol|pulseaudio|pipewire" 2>/dev/null | wc -l)
    
    if [ "$streams" -gt 0 ] || [ "$audio_processes" -gt 0 ]; then
        # Há áudio - gerar barras baseadas no volume com movimento
        level=$((volume * 7 / 100))
        [ $level -lt 2 ] && level=2
        [ $level -gt 7 ] && level=7
        
        # Gerar padrão animado
        case $(($(date +%s) % 6)) in
            0) echo "♪ ▂▃▄▅▆▅▄▃" ;;
            1) echo "♪ ▃▄▅▆▇▆▅▄" ;;
            2) echo "♪ ▄▅▆▇█▇▆▅" ;;
            3) echo "♪ ▅▆▇█▇▆▅▄" ;;
            4) echo "♪ ▆▇█▇▆▅▄▃" ;;
            5) echo "♪ ▇█▇▆▅▄▃▂" ;;
        esac
    else
        # Sem áudio - barras baixas
        case $(($(date +%s) % 3)) in
            0) echo "♪ ▁▁▂▁▁▂▁▁" ;;
            1) echo "♪ ▁▂▁▁▂▁▁▁" ;;
            2) echo "♪ ▂▁▁▂▁▁▁▂" ;;
        esac
    fi
    
    sleep 0.5
done
