#!/bin/bash

# Script simples para cava na waybar

# Verifica se PulseAudio está funcionando
if ! pactl info >/dev/null 2>&1; then
    echo "♪ ▁▁▁▁▁▁▁▁▁▁"
    sleep 1
    exit 1
fi

# Testa cava rapidamente
if ! cava -p ~/.config/waybar/cava_config </dev/null >/dev/null 2>&1; then
    echo "♪ ▁▁▁▁▁▁▁▁▁▁"
    sleep 1
    exit 1
fi

# Executa cava e processa a saída
cava -p ~/.config/waybar/cava_config 2>/dev/null | awk '
{
    # Remove espaços e limita a 10 caracteres
    gsub(/[[:space:]]/, "", $0);
    line = substr($0, 1, 10);
    
    # Se a linha for muito pequena, preenche com ▁
    while (length(line) < 10) {
        line = line "▁";
    }
    
    # Imprime com ícone musical
    print "♪ " line;
    fflush();
}'
