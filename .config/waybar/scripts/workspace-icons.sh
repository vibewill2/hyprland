#!/bin/bash

# Script para mostrar ícones das aplicações por workspace
# Integrado com Hyprland

# Mapeamento de classes de aplicações para ícones
get_app_icon() {
    local class="$1"
    case "${class,,}" in
        "google-chrome"|"chromium"|"firefox") echo "🌐" ;;
        "dev.warp.warp"|"kitty"|"alacritty"|"terminal") echo "💻" ;;
        "com.tibia.client"|"tibia") echo "⚔️" ;;
        "steam") echo "🎮" ;;
        "discord") echo "💬" ;;
        "spotify") echo "🎵" ;;
        "code"|"vscode") echo "⚙️" ;;
        "obs") echo "📹" ;;
        "gimp") echo "🎨" ;;
        "libreoffice"*) echo "📝" ;;
        "dolphin"|"nautilus"|"files") echo "📁" ;;
        "vlc"|"mpv") echo "📺" ;;
        "telegram") echo "✈️" ;;
        "zoom") echo "📹" ;;
        "thunderbird") echo "📧" ;;
        "elisa") echo "🎵" ;;
        *) echo "🔷" ;;
    esac
}

# Função principal
main() {
    # Obter informações dos workspaces
    workspaces=$(hyprctl workspaces -j)
    clients=$(hyprctl clients -j)
    
    # Array para armazenar ícones por workspace
    declare -A workspace_icons
    
    # Processar cada cliente
    while IFS= read -r client; do
        workspace_id=$(echo "$client" | jq -r '.workspace.id')
        class=$(echo "$client" | jq -r '.class')
        
        if [ "$workspace_id" != "null" ] && [ "$class" != "null" ]; then
            icon=$(get_app_icon "$class")
            
            # Adicionar ícone ao workspace (evitar duplicatas)
            if [[ "${workspace_icons[$workspace_id]}" != *"$icon"* ]]; then
                if [ -n "${workspace_icons[$workspace_id]}" ]; then
                    workspace_icons[$workspace_id]+="$icon"
                else
                    workspace_icons[$workspace_id]="$icon"
                fi
            fi
        fi
    done < <(echo "$clients" | jq -c '.[]')
    
    # Gerar saída JSON para waybar
    echo "{"
    echo "  \"text\": \"\","
    echo "  \"tooltip\": \"Workspaces com aplicações:\","
    echo "  \"class\": \"workspaces\","
    echo "  \"workspaces\": {"
    
    first=true
    for ws in {1..5}; do
        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi
        
        icons="${workspace_icons[$ws]:-}"
        echo -n "    \"$ws\": \"$icons\""
    done
    
    echo ""
    echo "  }"
    echo "}"
}

main