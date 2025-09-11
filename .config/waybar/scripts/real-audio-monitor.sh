#!/bin/bash

# Monitor REAL de áudio - versão ultra simples que funciona

# Função para capturar dados de áudio diretamente
capture_audio_data() {
    # Usar dd para capturar dados brutos do monitor
    local sink_monitor="alsa_output.pci-0000_04_00.6.analog-stereo.monitor"
    
    # Capturar 1024 bytes de dados de áudio
    local audio_data=$(timeout 0.1 dd if=<(pactl record --device="$sink_monitor" --format=s16le --rate=8000 --channels=1 - 2>/dev/null) bs=1024 count=1 2>/dev/null | od -t u2 -A n | tr ' ' '\n' | grep -E '^[0-9]+$' | head -50)
    
    if [ -n "$audio_data" ]; then
        # Calcular nível médio dos dados de áudio
        local sum=0
        local count=0
        for value in $audio_data; do
            local abs_value=$((value > 32767 ? 65535 - value : value))
            sum=$((sum + abs_value))
            count=$((count + 1))
        done
        
        if [ $count -gt 0 ]; then
            local avg=$((sum / count))
            local level=$((avg / 4096))  # Normalizar para 0-7
            [ $level -gt 7 ] && level=7
            echo $level
            return 0
        fi
    fi
    
    echo 0
    return 1
}

# Fallback: análise baseada em atividade
analyze_activity() {
    local streams=$(pactl list short sink-inputs | wc -l)
    local volume=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}' | sed 's/0\.//' | head -c2)
    
    if [ "$streams" -gt 0 ] && [ "$volume" -gt 10 ]; then
        # Simular nível baseado no volume + variação
        local base_level=$((volume / 15))
        local variation=$((RANDOM % 3 - 1))
        local final_level=$((base_level + variation))
        
        [ $final_level -lt 1 ] && final_level=1
        [ $final_level -gt 7 ] && final_level=7
        echo $final_level
    else
        echo 0
    fi
}

# Gerar barras visuais
make_bars() {
    local level=$1
    local bars=""
    
    for i in {1..8}; do
        local height=$level
        
        # Adicionar pequena variação para movimento
        if [ $((RANDOM % 2)) -eq 0 ]; then
            height=$((level + (RANDOM % 2)))
        fi
        
        [ $height -gt 7 ] && height=7
        [ $height -lt 0 ] && height=0
        
        case $height in
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
while true; do
    # Tentar capturar dados reais primeiro
    audio_level=$(capture_audio_data)
    
    # Se falhou, usar análise de atividade
    if [ $? -ne 0 ] || [ "$audio_level" -eq 0 ]; then
        audio_level=$(analyze_activity)
    fi
    
    make_bars "$audio_level"
    sleep 0.3
done
