#!/bin/bash

# Script CAVA corrigido para waybar - monitora saída de áudio

# Função de limpeza
cleanup() {
    pkill -f "cava -p"
    pkill -f "timeout.*cava"
    rm -f /tmp/cava_waybar_fixed_$$
    exit 0
}

trap cleanup EXIT INT TERM

# Verificar se cava está instalado
if ! command -v cava &> /dev/null; then
    echo "♪ ▁▁▁▁▁▁▁▁"
    exit 0
fi

# Função para obter o dispositivo monitor correto
get_monitor_source() {
    # Pegar o sink padrão
    local default_sink=$(pactl get-default-sink 2>/dev/null)
    if [ -n "$default_sink" ]; then
        echo "${default_sink}.monitor"
    else
        # Fallback: pegar o primeiro monitor disponível
        pactl list short sources | grep -E '\.monitor\s' | head -1 | cut -f2 | tr -d '\t'
    fi
}

# Função para verificar se há áudio ativo
check_audio_activity() {
    # Verificar se há streams de áudio ativos
    pactl list short sink-inputs 2>/dev/null | grep -q "PipeWire\|ALSA\|firefox\|chrome\|spotify" && return 0
    return 1
}

# Função para mostrar animação quando não há áudio
show_idle_animation() {
    local animations=(
        "♪ ▁▂▁▂▁▂▁▂"
        "♪ ▂▃▂▃▂▃▂▃"
        "♪ ▃▄▃▄▃▄▃▄"
        "♪ ▄▅▄▅▄▅▄▅"
        "♪ ▅▄▅▄▅▄▅▄"
        "♪ ▄▃▄▃▄▃▄▃"
        "♪ ▃▂▃▂▃▂▃▂"
        "♪ ▂▁▂▁▂▁▂▁"
    )
    
    local frame=0
    while true; do
        echo "${animations[$frame]}"
        frame=$(( (frame + 1) % ${#animations[@]} ))
        sleep 0.3
        
        # Verificar se há áudio agora
        if check_audio_activity; then
            break
        fi
    done
}

# Obter o dispositivo monitor correto
MONITOR_SOURCE=$(get_monitor_source)

# Criar arquivo de configuração temporário
TEMP_CONFIG="/tmp/cava_waybar_fixed_$$"
cat > "$TEMP_CONFIG" << EOF
[general]
bars = 8
bar_width = 1
bar_spacing = 0
sleep_timer = 1
sensitivity = 100

[input]
method = pulse
source = $MONITOR_SOURCE

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
gravity = 80
integral = 60
ignore = 0
EOF

# Loop principal
attempt=0
while [ $attempt -lt 3 ]; do
    if check_audio_activity; then
        # Há áudio ativo, executar cava
        timeout 30 cava -p "$TEMP_CONFIG" 2>/dev/null | while IFS= read -r line; do
            # Remover espaços e caracteres de controle
            clean_line=$(echo "$line" | tr -cd '0-7')
            
            # Se linha vazia ou muito pequena, pular
            if [ -z "$clean_line" ] || [ ${#clean_line} -lt 3 ]; then
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
            
            sleep 0.05
        done
        
        # Se chegou aqui, cava terminou, incrementar tentativa
        attempt=$((attempt + 1))
        sleep 1
    else
        # Sem áudio, mostrar animação
        show_idle_animation
        attempt=0  # Reset tentativas quando não há áudio
    fi
    
    sleep 0.5
done

# Fallback final
echo "♪ ▁▁▁▁▁▁▁▁"
