#!/bin/bash

# Script para mudança automática de wallpapers
WALLPAPER_DIR="$HOME/Imagens/wallpapers"
INTERVAL=10  # Segundos entre mudanças

# Verifica se o diretório existe
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Diretório de wallpapers não encontrado: $WALLPAPER_DIR"
    exit 1
fi

echo "Iniciando mudança automática de wallpapers..."
echo "Intervalo: $INTERVAL segundos"
echo "Diretório: $WALLPAPER_DIR"
echo "Pressione Ctrl+C para parar"

while true; do
    # Encontra todos os arquivos de imagem
    mapfile -t wallpapers < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.bmp" \) 2>/dev/null)
    
    if [ ${#wallpapers[@]} -eq 0 ]; then
        echo "Nenhum wallpaper encontrado em $WALLPAPER_DIR"
        exit 1
    fi
    
    # Seleciona um wallpaper aleatório
    random_wallpaper="${wallpapers[$RANDOM % ${#wallpapers[@]}]}"
    
    echo "$(date '+%H:%M:%S') - Aplicando: $(basename "$random_wallpaper")"
    
    # Aplica o wallpaper usando swww
    swww img "$random_wallpaper" --transition-type fade --transition-duration 3
    
    # Espera o intervalo especificado
    sleep $INTERVAL
done