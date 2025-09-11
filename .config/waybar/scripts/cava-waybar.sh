#!/bin/bash

# Script otimizado do CAVA para waybar
# Versão melhorada com tratamento de erros

# Função de limpeza
cleanup() {
    pkill -f "cava -p"
    rm -f /tmp/cava_waybar_$$
    exit 0
}

trap cleanup EXIT INT TERM

# Verificar se cava está instalado
if ! command -v cava &> /dev/null; then
    echo "♪ ▁▁▁▁▁▁▁▁"
    exit 0
fi

# Verificar se PulseAudio/PipeWire está rodando
if ! pgrep -x "pulseaudio\|pipewire" > /dev/null 2>&1; then
    echo "♪ ▁▁▁▁▁▁▁▁"
    exit 0
fi

# Criar arquivo de configuração temporário
TEMP_CONFIG="/tmp/cava_waybar_$$"
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

# Executar cava com timeout e processar saída
timeout 300 cava -p "$TEMP_CONFIG" 2>/dev/null | while IFS= read -r line; do
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
    
    # Pequeno delay para evitar sobrecarga da CPU
    sleep 0.1
done

# Fallback se o loop terminar
echo "♪ ▁▁▁▁▁▁▁▁"
