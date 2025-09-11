#!/bin/bash

# Script Cava simples - apenas indicador visual baseado em atividade de áudio

cleanup() {
    exit 0
}

trap cleanup EXIT INT TERM

# Função para verificar se há áudio ativo
check_audio_activity() {
    pactl list short sink-inputs 2>/dev/null | grep -q . && return 0
    return 1
}

# Função para obter informações sobre o áudio atual
get_audio_info() {
    # Verificar se há algum sink-input ativo
    local sink_inputs=$(pactl list short sink-inputs 2>/dev/null | wc -l)
    # Obter volume atual
    local volume=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | head -n 1 | awk '{print $5}' | sed 's/%//' 2>/dev/null || echo "0")
    
    echo "$sink_inputs:$volume"
}

# Animações baseadas no estado do áudio
show_audio_visualization() {
    local has_audio=$1
    local volume=$2
    
    if [ "$has_audio" = "true" ]; then
        # Há áudio tocando - mostrar visualização baseada no volume
        local level=$(( volume * 7 / 100 ))
        [ $level -gt 7 ] && level=7
        [ $level -lt 1 ] && level=1
        
        # Patterns dinâmicos baseados no nível
        case $level in
            1|2) echo "♪ ▁▂▁▂▁▂▁▂" ;;
            3|4) echo "♪ ▂▃▄▃▂▃▄▃" ;;
            5|6) echo "♪ ▃▅▆▅▃▅▆▅" ;;
            7)   echo "♪ ▅▆▇█▇▆▅▄" ;;
            *)   echo "♪ ▂▃▂▃▂▃▂▃" ;;
        esac
    else
        # Sem áudio - animação suave
        local animations=(
            "♪ ▁▁▂▁▁▂▁▁"
            "♪ ▁▂▁▁▂▁▁▁"
            "♪ ▂▁▁▂▁▁▁▂"
            "♪ ▁▁▂▁▁▂▁▁"
        )
        local frame=$(( $(date +%s) % ${#animations[@]} ))
        echo "${animations[$frame]}"
    fi
}

# Loop principal
while true; do
    audio_info=$(get_audio_info)
    sink_count=$(echo "$audio_info" | cut -d: -f1)
    volume=$(echo "$audio_info" | cut -d: -f2)
    
    if [ "$sink_count" -gt 0 ]; then
        show_audio_visualization "true" "$volume"
    else
        show_audio_visualization "false" "$volume"
    fi
    
    sleep 0.5
done
