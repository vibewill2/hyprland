#!/bin/bash

# Script melhorado para CAVA no waybar

# Função para limpar processos ao sair
cleanup() {
    pkill -f "cava -p"
    exit 0
}

trap cleanup EXIT

# Verificar se CAVA está disponível
if ! command -v cava &> /dev/null; then
    echo "♪ ▁▁▁▁▁▁▁▁▁▁"
    exit 0
fi

# Timeout para evitar travamento
timeout 10 cava -p ~/.config/waybar/cava_config 2>/dev/null | while read -r line; do
    # Remove espaços da linha
    clean_line=$(echo "$line" | tr -d ' ')
    
    # Se linha vazia, mostrar silêncio
    if [ -z "$clean_line" ]; then
        echo "♪ ▁▁▁▁▁▁▁▁▁▁"
        continue
    fi
    
    # Converte números (0-7) em caracteres de barra
    visual_line=""
    for (( i=0; i<${#clean_line} && i<10; i++ )); do
        char="${clean_line:$i:1}"
        case $char in
            0) visual_line+="▁" ;;
            1) visual_line+="▂" ;;
            2) visual_line+="▃" ;;
            3) visual_line+="▄" ;;
            4) visual_line+="▅" ;;
            5) visual_line+="▆" ;;
            6) visual_line+="▇" ;;
            7) visual_line+="█" ;;
            *) visual_line+="▁" ;;
        esac
    done
    
    # Garante pelo menos 10 caracteres
    while [ ${#visual_line} -lt 10 ]; do
        visual_line+="▁"
    done
    
    echo "♪ $visual_line"
done

# Se chegou aqui, mostrar estado padrão
echo "♪ ▁▁▁▁▁▁▁▁▁▁"
