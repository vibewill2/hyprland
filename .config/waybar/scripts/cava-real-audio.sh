#!/bin/bash

# Script DEFINITIVO - monitora volume real do sistema

cleanup() {
    jobs -p | xargs -r kill 2>/dev/null
    exit 0
}

trap cleanup EXIT INT TERM

# Função para obter nível de áudio atual em tempo real
get_audio_level() {
    # Usar pactl para monitorar o sink padrão
    local sink=$(pactl get-default-sink)
    
    # Capturar dados do monitor em tempo real
    timeout 0.1 pactl record --channels=1 --format=s16le --rate=44100 --device="${sink}.monitor" - 2>/dev/null | \
    od -t d2 -A n -N 128 2>/dev/null | \
    tr ' ' '\n' | \
    awk '
        BEGIN { max = 0 }
        /^[0-9-]/ { 
            val = $1 < 0 ? -$1 : $1
            if (val > max) max = val 
        }
        END { 
            if (max == 0) print 0
            else {
                level = int(max / 4096)
                if (level > 7) level = 7
                print level
            }
        }
    ' 2>/dev/null || echo 0
}

# Função para gerar barras baseadas no nível
generate_bars() {
    local level=$1
    local bars=""
    
    # Gerar 8 barras baseadas no nível
    for i in {1..8}; do
        local bar_level=$level
        
        # Adicionar variação para simular movimento
        if [ $((RANDOM % 3)) -eq 0 ]; then
            bar_level=$((level + (RANDOM % 2)))
        fi
        
        # Limitar entre 0-7
        [ $bar_level -gt 7 ] && bar_level=7
        [ $bar_level -lt 0 ] && bar_level=0
        
        case $bar_level in
            0) bars+="▁" ;;
            1) bars+="▂" ;;
            2) bars+="▃" ;;
            3) bars+="▄" ;;
            4) bars+="▅" ;;
            5) bars+="▆" ;;
            6) bars+="▇" ;;
            7) bars+="█" ;;
        esac
    done
    
    echo "♪ $bars"
}

# Função alternativa usando volume atual + atividade
get_volume_level() {
    local has_streams=$(pactl list short sink-inputs 2>/dev/null | wc -l)
    local volume=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | head -n 1 | awk '{print $5}' | sed 's/%//' || echo "0")
    
    if [ "$has_streams" -gt 0 ] && [ "$volume" -gt 0 ]; then
        # Há streams ativos, calcular nível baseado no volume
        local level=$((volume * 7 / 100))
        [ $level -gt 7 ] && level=7
        [ $level -lt 1 ] && level=1
        echo $level
    else
        echo 0
    fi
}

# Loop principal
while true; do
    # Tentar capturar áudio real primeiro
    audio_level=$(get_audio_level)
    
    # Se não conseguiu capturar, usar volume + atividade
    if [ "$audio_level" -eq 0 ]; then
        audio_level=$(get_volume_level)
    fi
    
    generate_bars "$audio_level"
    sleep 0.2
done
