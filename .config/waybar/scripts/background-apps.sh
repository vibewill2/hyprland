#!/bin/bash

# Script para mostrar aplicações rodando em segundo plano
# Mostra apenas aplicações específicas que não estão com janela ativa

# Lista de aplicações que queremos monitorar especificamente quando em segundo plano
BACKGROUND_APPS=("steam" "discord" "telegram" "whatsapp" "spotify" "thunderbird" "skype" "slack" "teams" "zoom")

# Aplicações que geralmente têm janelas e não devem aparecer quando ativas
EXCLUDE_WHEN_VISIBLE=("firefox" "chrome" "chromium" "code" "vscode" "obs" "gimp" "libreoffice")

# Função para verificar se uma aplicação está rodando
is_running() {
    local app="$1"
    pgrep -i "$app" >/dev/null 2>&1
}

# Função para verificar se uma aplicação tem janela ativa/visível
has_visible_window() {
    local app="$1"
    # Verifica se há janelas visíveis da aplicação no Hyprland
    # Só considera "em segundo plano" se não tem janela ativa OU se todas as janelas estão minimizadas
    local visible_windows=$(hyprctl clients -j 2>/dev/null | jq -r ".[] | select(.class | test(\"$app\"; \"i\")) | select(.mapped == true) | .class" 2>/dev/null)
    [ -n "$visible_windows" ]
}

# Função para obter ícone da aplicação
get_app_icon() {
    local app="$1"
    case "$app" in
        "steam") echo "🎮" ;;
        "discord") echo "💬" ;;
        "telegram") echo "✈" ;;
        "whatsapp") echo "💬" ;;
        "spotify") echo "🎵" ;;
        "thunderbird") echo "📧" ;;
        "skype") echo "📞" ;;
        "slack") echo "💼" ;;
        "teams") echo "👥" ;;
        "zoom") echo "📹" ;;
        "firefox") echo "🌍" ;;
        "chrome"|"chromium") echo "🌍" ;;
        "code"|"vscode") echo "⚙️" ;;
        "obs") echo "📹" ;;
        "gimp") echo "🎨" ;;
        "libreoffice") echo "📝" ;;
        *) echo "🔹" ;;
    esac
}

# Função para abrir/focar aplicação
open_app() {
    local app="$1"
    
    # Primeiro tenta focar numa janela existente
    local window_address=$(hyprctl clients -j 2>/dev/null | jq -r ".[] | select(.class | test(\"$app\"; \"i\")) | .address" | head -1)
    
    if [ -n "$window_address" ]; then
        hyprctl dispatch focuswindow address:$window_address 2>/dev/null
    else
        # Se não tem janela, tenta abrir a aplicação
        case "$app" in
            "steam") steam >/dev/null 2>&1 & ;;
            "discord") discord >/dev/null 2>&1 & ;;
            "telegram") telegram-desktop >/dev/null 2>&1 & ;;
            "spotify") spotify >/dev/null 2>&1 & ;;
            "thunderbird") thunderbird >/dev/null 2>&1 & ;;
            "firefox") firefox >/dev/null 2>&1 & ;;
            "chrome") google-chrome >/dev/null 2>&1 & ;;
            "chromium") chromium >/dev/null 2>&1 & ;;
            "code"|"vscode") code >/dev/null 2>&1 & ;;
            "obs") obs >/dev/null 2>&1 & ;;
            "gimp") gimp >/dev/null 2>&1 & ;;
            "libreoffice") libreoffice >/dev/null 2>&1 & ;;
            *) echo "Aplicação $app não configurada para abrir" ;;
        esac
    fi
}

# Função para mostrar menu de aplicações
show_app_menu() {
    local running_apps=()
    
    # Coleta aplicações rodando em segundo plano
    for app in "${BACKGROUND_APPS[@]}"; do
        if is_running "$app" && ! has_visible_window "$app"; then
            running_apps+=("$app")
        fi
    done
    
    if [ ${#running_apps[@]} -eq 0 ]; then
        notify-send "Aplicações" "Nenhuma aplicação em segundo plano" 2>/dev/null
        return
    fi
    
    # Se só tem uma app, abre ela diretamente
    if [ ${#running_apps[@]} -eq 1 ]; then
        open_app "${running_apps[0]}"
        return
    fi
    
    # Cria menu com wofi/rofi se disponível
    if command -v wofi >/dev/null 2>&1; then
        selected=$(printf '%s\n' "${running_apps[@]}" | wofi --dmenu --prompt="Abrir aplicação:")
        [ -n "$selected" ] && open_app "$selected"
    elif command -v rofi >/dev/null 2>&1; then
        selected=$(printf '%s\n' "${running_apps[@]}" | rofi -dmenu -p "Abrir aplicação:")
        [ -n "$selected" ] && open_app "$selected"
    else
        # Fallback: abre a primeira aplicação
        open_app "${running_apps[0]}"
    fi
}

# Se receber argumento "click", mostra menu ou abre app específica
if [ "$1" = "click" ]; then
    if [ -n "$2" ]; then
        open_app "$2"
    else
        show_app_menu
    fi
    exit 0
fi

# Coleta aplicações em segundo plano
background_icons=""
background_apps_list=""

# Verifica aplicações que sempre queremos mostrar quando em segundo plano
for app in "${BACKGROUND_APPS[@]}"; do
    if is_running "$app" && ! has_visible_window "$app"; then
        icon=$(get_app_icon "$app")
        if [ -n "$background_icons" ]; then
            background_icons="$background_icons $icon"
            background_apps_list="$background_apps_list, $app"
        else
            background_icons="$icon"
            background_apps_list="$app"
        fi
    fi
done

# Output em formato JSON
if [ -n "$background_icons" ]; then
    echo "{\"text\":\"$background_icons\",\"tooltip\":\"Apps em segundo plano: $background_apps_list\"}"
else
    echo "{\"text\":\"\",\"tooltip\":\"Nenhuma aplicação em segundo plano\"}"
fi
