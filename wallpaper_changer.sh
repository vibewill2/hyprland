#!/bin/bash

# Diretório onde suas imagens estão. Mude para o caminho correto.
WALLPAPERS_DIR="$HOME/Imagens/wallpapers/"

# Verifique se o diretório existe
if [ ! -d "$WALLPAPERS_DIR" ]; then
    echo "Erro: O diretório de papéis de parede não foi encontrado."
    exit 1
fi

# Use o swww para pegar uma imagem aleatória e definir como papel de parede
# O comando 'find' procura por arquivos, o '-type f' garante que são arquivos (não diretórios).
# O 'shuf -n 1' pega uma linha aleatória (ou seja, um arquivo aleatório).
# O 'xargs' passa essa linha como argumento para o swww.
find "$WALLPAPERS_DIR" -type f | shuf -n 1 | xargs swww img
# colocar dentro ~/.config/hypr/scripts/wallpaper_changer.sh
