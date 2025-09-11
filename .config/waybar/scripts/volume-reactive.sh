#!/bin/bash

# Solução HONESTA - reage a mudanças REAIS de volume do sistema

# Armazenar volume anterior
PREV_VOLUME=0
ACTIVITY_COUNTER=0

while true; do
    # Obter volume atual
    CURRENT_VOLUME=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}' | sed 's/0\.//' | head -c2 || echo "50")
    
    # Verificar se há streams ativos
    STREAMS=$(pactl list short sink-inputs | wc -l)
    
    # Detectar mudança no volume (indica atividade de áudio)
    VOLUME_CHANGED=0
    if [ "$CURRENT_VOLUME" -ne "$PREV_VOLUME" ]; then
        VOLUME_CHANGED=1
        ACTIVITY_COUNTER=10  # Manter ativo por 10 ciclos
    fi
    
    # Decrementar contador de atividade
    if [ $ACTIVITY_COUNTER -gt 0 ]; then
        ACTIVITY_COUNTER=$((ACTIVITY_COUNTER - 1))
    fi
    
    # Determinar nível de visualização
    if [ "$STREAMS" -gt 0 ] || [ $ACTIVITY_COUNTER -gt 0 ]; then
        # Há atividade - calcular nível baseado no volume
        LEVEL=$((CURRENT_VOLUME / 14))
        [ $LEVEL -lt 1 ] && LEVEL=1
        [ $LEVEL -gt 7 ] && LEVEL=7
        
        # Se houve mudança de volume recentemente, aumentar o nível
        if [ $VOLUME_CHANGED -eq 1 ]; then
            LEVEL=$((LEVEL + 2))
            [ $LEVEL -gt 7 ] && LEVEL=7
        fi
        
        # Gerar barras com movimento
        BARS=""
        for i in {1..8}; do
            HEIGHT=$LEVEL
            
            # Variação baseada no tempo para movimento
            TIME_VAR=$((($(date +%s) + i) % 3 - 1))
            HEIGHT=$((HEIGHT + TIME_VAR))
            
            [ $HEIGHT -lt 0 ] && HEIGHT=0
            [ $HEIGHT -gt 7 ] && HEIGHT=7
            
            case $HEIGHT in
                0) BARS+="▁" ;;
                1) BARS+="▂" ;;
                2) BARS+="▃" ;;
                3) BARS+="▄" ;;
                4) BARS+="▅" ;;
                5) BARS+="▆" ;;
                6) BARS+="▇" ;;
                7) BARS+="█" ;;
            esac
        done
        
        echo "♪ $BARS"
    else
        # Sem atividade - barras baixas
        echo "♪ ▁▂▁▂▁▂▁▂"
    fi
    
    PREV_VOLUME=$CURRENT_VOLUME
    sleep 0.2
done
