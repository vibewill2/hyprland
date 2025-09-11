#!/bin/bash

# Script CAVA com múltiplas fontes de áudio para waybar

cleanup() {
    pkill -f "cava -p"
    rm -f /tmp/cava_waybar_multi_$$
    exit 0
}

trap cleanup EXIT INT TERM

if ! command -v cava &> /dev/null; then
    echo "♪ ▁▁▁▁▁▁▁▁"
    exit 0
fi

# Lista de possíveis fontes para tentar
get_audio_sources() {
    echo "auto"
    pactl list short sources | grep -E "monitor|input" | cut -f2
}

# Função para verificar se há áudio ativo
check_audio_activity() {
    pactl list short sink-inputs 2>/dev/null | grep -q . && return 0
    return 1
}

# Animação idle
show_idle_animation() {
    local animations=("♪ ▁▂▃▂▁▂▃▂" "♪ ▂▃▄▃▂▃▄▃" "♪ ▃▄▅▄▃▄▅▄" "♪ ▄▃▂▃▄▃▂▃")
    local frame=0
    while true; do
        echo "${animations[$frame]}"
        frame=$(( (frame + 1) % ${#animations[@]} ))
        sleep 0.4
        check_audio_activity && break
    done
}

# Tentar cada fonte de áudio
for source in $(get_audio_sources); do
    # Criar configuração temporária
    TEMP_CONFIG="/tmp/cava_waybar_multi_$$"
    cat > "$TEMP_CONFIG" << EOF
[general]
bars = 8
bar_width = 1
bar_spacing = 0
sleep_timer = 1
sensitivity = 200

[input]
method = pulse
source = $source

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
gravity = 60
integral = 40
ignore = 0
EOF

    if check_audio_activity; then
        # Tentar esta fonte por 60 segundos
        timeout 60 cava -p "$TEMP_CONFIG" 2>/dev/null | while IFS= read -r line; do
            clean_line=$(echo "$line" | tr -cd '0-7')
            
            if [ -z "$clean_line" ] || [ ${#clean_line} -lt 2 ]; then
                continue
            fi
            
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
            
            while [ ${#visual} -lt 8 ]; do
                visual+="▁"
            done
            visual=${visual:0:8}
            
            echo "♪ $visual"
            sleep 0.03
        done
        
        # Se chegou aqui e ainda há áudio, continuar com próxima fonte
        check_audio_activity && continue || break
    else
        show_idle_animation
        break
    fi
done

echo "♪ ▁▁▁▁▁▁▁▁"
