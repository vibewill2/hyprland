#!/bin/bash

# Script para testar se o waypaper executa automaticamente o update_colors

echo "Testando waypaper com post_command..."

# Listar wallpapers disponíveis
WALLPAPERS=(~/Imagens/wallpapers/*.{jpg,png,jpeg})
CURRENT_WALLPAPER=$(swww query | grep -oP '(?<=image: ).*')

echo "Wallpaper atual: $CURRENT_WALLPAPER"

# Encontrar um wallpaper diferente do atual
for wp in "${WALLPAPERS[@]}"; do
    if [[ "$wp" != "$CURRENT_WALLPAPER" ]]; then
        TEST_WALLPAPER="$wp"
        break
    fi
done

if [[ -n "$TEST_WALLPAPER" ]]; then
    echo "Mudando para: $TEST_WALLPAPER"
    waypaper --wallpaper "$TEST_WALLPAPER"
    echo "Wallpaper alterado! O post_command deve ter executado automaticamente."
    echo "Verifique se as cores do terminal mudaram."
else
    echo "Não foi possível encontrar um wallpaper diferente para testar."
fi
