#!/bin/bash

# Script melhorado do CAVA para waybar com detecção de áudio

# Função de limpeza
cleanup() {
    pkill -f "cava -p"
    pkill -f "timeout.*cava"
    rm -f /tmp/cava_waybar_enhanced_$$
    exit 0
}

trap cleanup EXIT INT TERM

# Verificar se cava está instalado
if ! command -v cava &> /dev/null; then
    echo "♪ ▁▁▁▁▁▁▁▁"
    exit 0
fi

# Função para verificar se há áudio ativo
check_audio_activity() {
    # Verificar se há streams de áudio ativos
    if pactl list short sink-inputs 2>/dev/null | grep -q RUNNING; then
        return 0  # Há áudio ativo
    fi
    
    # Verificar se há sources ativos
    if pactl list short source-outputs 2>/dev/null | grep -q RUNNING; then
        return 0  # Há áudio ativo
    fi
    
    return 1  # Sem áudio
}

# Função para mostrar animação quando não há áudio
show_idle_animation() {
    local animations=(
        "♪ ▁▁▁▂▃▂▁▁"
        "♪ ▁▁▂▃▄▃▂▁"
        "♪ ▁▂▃▄▅▄▃▂"
        "♪ ▂▃▄▅▆▅▄▃"
        "♪ ▃▄▅▆▅▄▃▂"
        "♪ ▄▅▆▅▄▃▂▁"
        "♪ ▅▆▅▄▃▂▁▁"
        "♪ ▆▅▄▃▂▁▁▁"
    )
    
    local frame=0
    while true; do
        echo "${animations[$frame]}"
        frame=$(( (frame + 1) % ${#animations[@]} ))
        sleep 0.5
        
        # Verificar se há áudio agora
        if check_audio_activity; then
            break
        fi
    done
}

# Criar arquivo de configuração temporário
TEMP_CONFIG="/tmp/cava_waybar_enhanced_$$"
cat > "$TEMP_CONFIG" << EOF
[general]
bars = 8
bar_width = 1
bar_spacing = 0
sleep_timer = 1

[input]
method = pulse
source = auto

[output]
method = raw
channels = mono
mono_option = average
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
bar_delimiter = 0

[smoothing]
monstercat = 1
waves = 0
gravity = 100
integral = 77
ignore = 0

[color]
gradient = 0
EOF

# Loop principal
while true; do
    if check_audio_activity; then
        # Há áudio ativo, executar cava
        timeout 30 cava -p "$TEMP_CONFIG" 2>/dev/null | while IFS= read -r line; do
            # Remover espaços e caracteres de controle
            clean_line=$(echo "$line" | tr -cd '0-7')
            
            # Se linha vazia, mostrar silêncio
            if [ -z "$clean_line" ]; then
                echo "♪ ▁▁▁▁▁▁▁▁"
                continue
            fi
            
            # Converter números (0-7) em barras visuais
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
                    *) visual+="▁" ;;
                esac
            done
            
            # Garantir exatamente 8 caracteres
            while [ ${#visual} -lt 8 ]; do
                visual+="▁"
            done
            visual=${visual:0:8}
            
            echo "♪ $visual"
            
            sleep 0.1
        done
    else
        # Sem áudio, mostrar animação
        show_idle_animation
    fi
    
    sleep 1
done
