#!/bin/bash

# Script alternativo que simula Cava baseado no volume e atividade do sistema

cleanup() {
    exit 0
}

trap cleanup EXIT INT TERM

# Função para verificar se há áudio ativo
check_audio_activity() {
    pactl list short sink-inputs 2>/dev/null | grep -q . && return 0
    return 1
}

# Função para obter o volume atual
get_current_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print $5}' | sed 's/%//' || echo "50"
}

# Função para gerar visualização baseada no volume
generate_volume_bars() {
    local volume=$1
    local activity=$2
    
    # Normalizar volume (0-100 para 0-7)
    local level=$(( volume * 7 / 100 ))
    [ $level -gt 7 ] && level=7
    [ $level -lt 0 ] && level=0
    
    # Se há atividade, gerar padrão baseado no volume
    if [ "$activity" = "true" ]; then
        local bars=""
        local variation=$((RANDOM % 3 - 1))  # -1, 0, ou 1
        
        for i in {1..8}; do
            local bar_height=$level
            
            # Adicionar variação para simular movimento
            if [ $((i % 2)) -eq 0 ]; then
                bar_height=$((bar_height + variation))
            else
                bar_height=$((bar_height - variation))
            fi
            
            # Limitar entre 0-7
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
    else
        # Animação quando não há áudio
        local animations=(
            "♪ ▁▂▁▂▁▂▁▂"
            "♪ ▂▃▂▃▂▃▂▃"
            "♪ ▁▂▁▂▁▂▁▂"
            "♪ ▁▁▁▁▁▁▁▁"
        )
        echo "${animations[$((RANDOM % ${#animations[@]}))]}"
    fi
}

# Tentar usar Cava real primeiro
try_real_cava() {
    # Criar configuração temporária otimizada
    local temp_config="/tmp/cava_real_$$"
    cat > "$temp_config" << EOF
[general]
bars = 8
bar_width = 1
bar_spacing = 0
sensitivity = 500

[input]
method = pulse
source = auto

[output]
method = raw
channels = mono
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
bar_delimiter = 0

[smoothing]
monstercat = 1
gravity = 50
integral = 30
ignore = 0
EOF

    # Tentar Cava por 30 segundos
    local cava_output
    cava_output=$(timeout 30 cava -p "$temp_config" 2>/dev/null)
    
    if [ -n "$cava_output" ] && [ "$cava_output" != "00000000" ]; then
        echo "$cava_output" | while IFS= read -r line; do
            clean_line=$(echo "$line" | tr -cd '0-7')
            
            if [ -n "$clean_line" ] && [ ${#clean_line} -ge 4 ]; then
                visual=""
                for (( i=0; i<${#clean_line} && i<8; i++ )); do
                    char="${clean_line:$i:1}"
                    case $char in
                        0) visual+="▁" ;;
                        1) visual+="▂" ;;
                        2) visual+="▃" ;;
                        3) visual+="▄" ;;
                        4) visual+="▅" ;;
                        5) visual+="▆" ;;
                        6) visual+="▇" ;;
                        7) visual+="█" ;;
                    esac
                done
                
                while [ ${#visual} -lt 8 ]; do
                    visual+="▁"
                done
                
                echo "♪ $visual"
                return 0  # Sucesso
            fi
        done
    fi
    
    rm -f "$temp_config"
    return 1  # Falha
}

# Loop principal
counter=0
while true; do
    # A cada 10 iterações, tentar Cava real
    if [ $((counter % 10)) -eq 0 ]; then
        if try_real_cava; then
            counter=$((counter + 1))
            continue
        fi
    fi
    
    # Fallback: visualização baseada em volume
    volume=$(get_current_volume)
    if check_audio_activity; then
        generate_volume_bars "$volume" "true"
    else
        generate_volume_bars "$volume" "false"
    fi
    
    sleep 0.2
    counter=$((counter + 1))
done
