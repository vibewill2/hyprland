#!/bin/bash

# Script que monitora volume em tempo real usando eventos do sistema

cleanup() {
    jobs -p | xargs -r kill 2>/dev/null
    exit 0
}

trap cleanup EXIT INT TERM

# Função para capturar nível de áudio através do sistema
get_real_audio_level() {
    # Usar wpctl se disponível
    if command -v wpctl &> /dev/null; then
        # Pegar informações de volume do sink ativo
        local sink_info=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null)
        if echo "$sink_info" | grep -q "MUTED"; then
            echo 0
            return
        fi
        local volume=$(echo "$sink_info" | awk '{print $2}' | sed 's/0\.//' | cut -c1-2 2>/dev/null || echo "0")
    else
        # Fallback para pactl
        local volume=$(pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | head -n 1 | awk '{print $5}' | sed 's/%//' || echo "0")
    fi
    
    # Verificar se há streams ativos para modular o volume
    local active_streams=$(pactl list short sink-inputs 2>/dev/null | wc -l)
    
    if [ "$active_streams" -gt 0 ]; then
        # Calcular nível baseado no volume e adicionar variação
        local base_level=$((volume * 7 / 100))
        [ $base_level -lt 1 ] && base_level=1
        [ $base_level -gt 7 ] && base_level=7
        
        # Adicionar variação pseudo-aleatória baseada no tempo
        local time_var=$(($(date +%s) % 3))
        local final_level=$((base_level + time_var - 1))
        
        [ $final_level -lt 1 ] && final_level=1
        [ $final_level -gt 7 ] && final_level=7
        
        echo $final_level
    else
        echo 0
    fi
}

# Função para monitorar mudanças no sistema de áudio
monitor_audio_changes() {
    # Monitorar mudanças usando pactl subscribe
    pactl subscribe 2>/dev/null | grep --line-buffered "sink-input\|sink" | while read line; do
        echo "CHANGE"
    done &
    
    # Também enviar mudanças periódicas
    while true; do
        sleep 0.3
        echo "TICK"
    done &
}

# Função para gerar visualização
generate_audio_bars() {
    local level=$1
    local bars=""
    
    for i in {1..8}; do
        local bar_height=$level
        
        # Variação para simular movimento real
        if [ $((i % 2)) -eq 0 ]; then
            bar_height=$((level + ($(date +%N | cut -c8-9) % 2)))
        else
            bar_height=$((level - ($(date +%N | cut -c7-8) % 2)))
        fi
        
        # Garantir limites
        [ $bar_height -lt 0 ] && bar_height=0
        [ $bar_height -gt 7 ] && bar_height=7
        
        case $bar_height in
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

# Loop principal
current_level=0
last_change=0

while true; do
    # Obter nível atual
    new_level=$(get_real_audio_level)
    current_time=$(date +%s)
    
    # Se mudou ou passou tempo suficiente, atualizar
    if [ "$new_level" -ne "$current_level" ] || [ $((current_time - last_change)) -ge 1 ]; then
        current_level=$new_level
        last_change=$current_time
    fi
    
    # Gerar e exibir barras
    generate_audio_bars "$current_level"
    
    sleep 0.2
done
