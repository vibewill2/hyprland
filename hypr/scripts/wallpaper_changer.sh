#!/bin/bash

# Diretório onde suas imagens estão
WALLPAPERS_DIR="$HOME/Imagens/wallpapers/"

# Verifique se o diretório existe
if [ ! -d "$WALLPAPERS_DIR" ]; then
    echo "Erro: O diretório de papéis de parede não foi encontrado."
    exit 1
fi

# Escolhe uma imagem aleatória
IMG=$(find "$WALLPAPERS_DIR" -type f | shuf -n 1)

# Mostra a imagem em uma caixinha de confirmação
if yad --title="Definir Papel de Parede?" \
       --image="$IMG" \
       --button=Sim:0 \
       --button=Não:1 \
       --center \
       --width=400 \
       --height=400 \
       --text="Deseja definir esta imagem como papel de parede?"; then
    # Se clicar em Sim, aplica a imagem
    swww img "$IMG"
fi
