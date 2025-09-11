#!/bin/bash

# Script para atualizar cores do terminal baseado no wallpaper
# Executado quando o wallpaper muda

# Obter o wallpaper atual do swww
WALLPAPER=$(swww query | grep -oP '(?<=image: ).*')

if [ -n "$WALLPAPER" ]; then
    # Executar wallust com o wallpaper atual
    ~/.cargo/bin/wallust run "$WALLPAPER"
    
    # Recarregar configuração do kitty para todas as instâncias abertas
    killall -SIGUSR1 kitty 2>/dev/null || true
    
    echo "Cores do terminal atualizadas baseadas em: $WALLPAPER"
else
    echo "Nenhum wallpaper encontrado pelo swww"
fi
