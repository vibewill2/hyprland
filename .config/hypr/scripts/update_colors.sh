#!/bin/bash

# Script para atualizar cores do sistema baseado no wallpaper
# Sincroniza waybar e kitty com as cores extraídas do papel de parede

set -e  # Sair em caso de erro

# Obter o wallpaper atual do swww
WALLPAPER=$(swww query | grep -oP '(?<=image: ).*' | head -n1)

if [ -n "$WALLPAPER" ] && [ -f "$WALLPAPER" ]; then
    echo "🎨 Extraindo cores de: $(basename "$WALLPAPER")"
    
    # Garantir que o PATH inclui o cargo
    export PATH="$HOME/.cargo/bin:$PATH"
    
    # Executar wallust com o wallpaper atual
    if wallust run "$WALLPAPER" 2>/dev/null; then
        echo "✅ Paleta de cores gerada com sucesso"
        
        # Aguardar um momento para os arquivos serem escritos
        sleep 0.5
        
        # Detectar ambiente atual
        if pgrep -x "qtile" >/dev/null; then
            echo "⚠️  Qtile detectado - não atualizando waybar"
        elif [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ] || [ "$HYPRLAND_INSTANCE_SIGNATURE" != "" ] || pgrep -x "Hyprland" >/dev/null; then
            if pgrep waybar >/dev/null; then
                echo "🔄 Hyprland detectado - reiniciando waybar com novas cores..."
                pkill waybar 2>/dev/null || true
                sleep 1
                WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc" WAYBAR_STYLE="$HOME/.config/waybar/style.css" waybar &
            fi
        else
            echo "⚠️  Ambiente desconhecido - pulando atualização da waybar"
        fi
        
        # Recarregar configuração do kitty para todas as instâncias abertas
        if pgrep kitty >/dev/null; then
            echo "🔄 Recarregando configuração do kitty..."
            killall -SIGUSR1 kitty 2>/dev/null || true
        fi
        
        echo "🌈 Cores do sistema sincronizadas com: $(basename "$WALLPAPER")"
        
        # Mostrar notificação se tiver notify-send
        if command -v notify-send >/dev/null 2>&1; then
            notify-send "🎨 Cores Atualizadas" "Sistema sincronizado com $(basename "$WALLPAPER")" -t 3000
        fi
    else
        echo "❌ Erro ao processar wallpaper com wallust"
        exit 1
    fi
else
    echo "❌ Nenhum wallpaper válido encontrado pelo swww"
    exit 1
fi
