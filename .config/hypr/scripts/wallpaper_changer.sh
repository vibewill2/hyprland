#!/bin/bash

# Diretório onde suas imagens estão
WALLPAPERS_DIR="$HOME/Imagens/wallpapers/"

# Verifique se o diretório existe
if [ ! -d "$WALLPAPERS_DIR" ]; then
    echo "Erro: O diretório de papéis de parede não foi encontrado."
    exit 1
fi

# Abre uma janela gráfica para escolher imagem
IMG=$(zenity --file-selection \
    --title="Escolha um Papel de Parede" \
    --filename="$WALLPAPERS_DIR/" \
    --file-filter="Imagens | *.png *.jpg *.jpeg *.bmp *.webp")

# Se o usuário escolheu, aplica no swww
if [ -n "$IMG" ]; then
    swww img "$IMG"
fi
