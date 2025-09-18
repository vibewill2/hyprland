#!/bin/bash

# Script para mostrar o ícone da aplicação ativa
# Funciona com Hyprland

# Função para obter ícone da aplicação
get_app_icon() {
    local class="$1"
    case "${class,,}" in
        "google-chrome"|"chromium") echo "🌐" ;;
        "firefox") echo "🦊" ;;
        "dev.warp.warp") echo "💻" ;;
        "kitty"|"alacritty"|"terminal") echo "💻" ;;
        "com.tibia.client"|"tibia") echo "⚔️" ;;
        "org.kde.dolphin"|"dolphin"|"nautilus") echo "📁" ;;
        "steam") echo "🎮" ;;
        "discord") echo "💬" ;;
        "spotify") echo "🎵" ;;
        "code"|"code - oss"|"vscode") echo "⚙️" ;;
        "obs") echo "📹" ;;
        "gimp") echo "🎨" ;;
        "libreoffice"*) echo "📝" ;;
        "vlc"|"mpv") echo "📺" ;;
        "telegram") echo "✈️" ;;
        "zoom") echo "📹" ;;
        "thunderbird") echo "📧" ;;
        "elisa"|"amarok") echo "🎵" ;;
        "inkscape") echo "🖌️" ;;
        "blender") echo "🎭" ;;
        "krita") echo "🎨" ;;
        "steam"*) echo "🎮" ;;
        "game"*) echo "🎮" ;;
        "minecraft"*) echo "⛏️" ;;
        "") echo "🏠" ;;
        *) echo "📱" ;;
    esac
}

# Função para obter nome limpo da aplicação
get_app_name() {
    local class="$1"
    local title="$2"
    
    case "${class,,}" in
        "google-chrome"|"chromium") echo "Chrome" ;;
        "firefox") echo "Firefox" ;;
        "dev.warp.warp") echo "Warp" ;;
        "kitty") echo "Kitty" ;;
        "com.tibia.client") echo "Tibia" ;;
        "org.kde.dolphin") echo "Dolphin" ;;
        "steam") echo "Steam" ;;
        "discord") echo "Discord" ;;
        "spotify") echo "Spotify" ;;
        "code"|"vscode") echo "VS Code" ;;
        "obs") echo "OBS" ;;
        "gimp") echo "GIMP" ;;
        "") echo "Desktop" ;;
        *) echo "${class}" | sed 's/.*\.//' | sed 's/-/ /g' | sed 's/\b\w/\U&/g' ;;
    esac
}

# Obter janela ativa
active_window=$(hyprctl activewindow -j 2>/dev/null)

if [ "$active_window" = "null" ] || [ -z "$active_window" ]; then
    # Nenhuma janela ativa - mostrar desktop
    echo "{\"text\":\"🏠\",\"tooltip\":\"Desktop\",\"class\":\"desktop\"}"
    exit 0
fi

# Extrair informações da janela ativa
class=$(echo "$active_window" | jq -r '.class // empty')
title=$(echo "$active_window" | jq -r '.title // empty')

# Obter ícone e nome
icon=$(get_app_icon "$class")
name=$(get_app_name "$class" "$title")

# Truncar título se for muito longo
if [ -n "$title" ] && [ ${#title} -gt 30 ]; then
    title="${title:0:30}..."
fi

# Gerar saída JSON
echo "{\"text\":\"$icon\",\"tooltip\":\"$name: $title\",\"class\":\"active-app\"}"