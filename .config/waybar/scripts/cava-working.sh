#!/bin/bash

# Script CAVA funcional para waybar

# Verificar se cava está instalado
if ! command -v cava &> /dev/null; then
    echo "♪ ▁▁▁▁▁▁▁▁▁▁"
    exit 0
fi

# Configuração inline do CAVA para garantir funcionamento
cat > /tmp/cava_waybar_config << EOF
[general]
bars = 8
bar_width = 1
bar_spacing = 0

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
gravity = 100
integral = 77
EOF

# Executar CAVA e processar saída
cava -p /tmp/cava_waybar_config 2>/dev/null | while read -r line; do
    # Converter números em barras
    visual=""
    for (( i=0; i<${#line} && i<8; i++ )); do
        char="${line:$i:1}"
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
    
    # Preencher até 8 caracteres
    while [ ${#visual} -lt 8 ]; do
        visual+="▁"
    done
    
    echo "♪ $visual"
done
