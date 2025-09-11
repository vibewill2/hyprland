#!/bin/bash

# Script Cava super simples - sempre funciona

while true; do
    # Verificar se há áudio
    if pactl list short sink-inputs 2>/dev/null | grep -q .; then
        # Há áudio - mostrar barras animadas
        bars=("♪ ▂▃▅▆▅▃▂▁" "♪ ▃▄▆▇▆▄▃▂" "♪ ▄▅▇█▇▅▄▃" "♪ ▅▆█▇▆▅▃▂" "♪ ▆▇▆▅▄▃▂▁")
        echo "${bars[$((RANDOM % ${#bars[@]}))]}"
    else
        # Sem áudio - barras baixas
        echo "♪ ▁▂▁▂▁▂▁▂"
    fi
    sleep 0.5
done
