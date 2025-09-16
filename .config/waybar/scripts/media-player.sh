#!/bin/bash

# Script para mostrar informações do player de música na waybar
# Funciona com qualquer player compatível com MPRIS (incluindo players do KDE)

# Função para encontrar e abrir um player de música
open_music_player() {
    # Primeiro verifica se há YouTube aberto e foca nele
    local youtube_window=$(hyprctl clients -j 2>/dev/null | jq -r '.[] | select(.class=="Google-chrome" or .class=="Firefox") | select(.title | contains("YouTube")) | .address' 2>/dev/null | head -1)
    
    if [ -n "$youtube_window" ]; then
        # Foca na janela do YouTube
        hyprctl dispatch focuswindow address:$youtube_window 2>/dev/null
        return 0
    fi
    
    # Se não há YouTube, verifica players MPRIS ativos
    local active_players=$(playerctl --list-all 2>/dev/null)
    if [ -n "$active_players" ]; then
        # Se há um player ativo, apenas dá play/pause
        playerctl play-pause 2>/dev/null
        return 0
    fi
    
    # Lista de players em ordem de preferência (KDE primeiro)
    local players=("elisa" "amarok" "juk" "clementine" "audacious" "rhythmbox" "vlc" "spotify")
    
    for player in "${players[@]}"; do
        if command -v "$player" >/dev/null 2>&1; then
            nohup "$player" >/dev/null 2>&1 &
            return 0
        fi
    done
    
    # Se nenhum player foi encontrado, tenta abrir o player padrão
    if command -v xdg-open >/dev/null 2>&1; then
        # Tenta abrir um arquivo de música para ativar o player padrão
        nohup xdg-open "https://music.youtube.com" >/dev/null 2>&1 &
    else
        # Como último recurso, sugere instalar o Elisa
        notify-send "Player de Música" "Nenhum player encontrado. Instale o Elisa: sudo dnf install elisa" 2>/dev/null || echo "Instale um player de música (ex: sudo dnf install elisa)"
    fi
}

# Se o primeiro argumento for "open", abre o player
if [ "$1" = "open" ]; then
    open_music_player
    exit 0
fi

# Função para truncar texto longo
truncate_text() {
    local text="$1"
    local max_length=30
    if [ ${#text} -gt $max_length ]; then
        echo "${text:0:$max_length}..."
    else
        echo "$text"
    fi
}

# Função para detectar YouTube no navegador
get_youtube_info() {
    # Tenta pegar informação do título da janela do Chrome/Firefox com YouTube
    local youtube_title=$(hyprctl clients -j 2>/dev/null | jq -r '.[] | select(.class=="Google-chrome" or .class=="Firefox") | select(.title | contains("YouTube")) | .title' 2>/dev/null | head -1)
    
    if [ -z "$youtube_title" ]; then
        # Fallback para xdotool se hyprctl não funcionar
        youtube_title=$(xdotool search --class "Google-chrome" 2>/dev/null | head -1 | xargs -I {} xdotool getwindowname {} 2>/dev/null | grep -E "(YouTube|♪)" | head -1)
    fi
    
    if [ -n "$youtube_title" ]; then
        # Remove "YouTube" e outros textos desnecessários, melhora a formatação
        clean_title=$(echo "$youtube_title" | 
            sed 's/ - YouTube.*$//g' | 
            sed 's/^.*YouTube - //g' | 
            sed 's/ (Official.*Video).*$//gi' | 
            sed 's/ (Official.*Music.*Video).*$//gi' | 
            sed 's/ (Official.*Audio).*$//gi' | 
            sed 's/ \[Official.*Video\].*$//gi' | 
            sed 's/.*VEVO - //g' | 
            sed 's/ - Topic.*$//g'
        )
        
        if [ -n "$clean_title" ] && [ "$clean_title" != "YouTube" ]; then
            # Trunca o título se for muito longo
            display_title=$(truncate_text "$clean_title")
            # Tenta detectar se o vídeo está pausado pelo título ou usa ícone padrão
            if echo "$youtube_title" | grep -q -i "paused\|pause"; then
                echo "⏸ $display_title"
            else
                echo "▶ $display_title"
            fi
            return 0
        fi
    fi
    return 1
}

# Função para detectar outros players web
get_web_media_info() {
    # Verifica títulos de janelas que podem conter informações de mídia
    local media_title=$(hyprctl clients -j 2>/dev/null | jq -r '.[] | select(.class=="Google-chrome" or .class=="Firefox") | .title' 2>/dev/null | grep -E "(♪|🎵|▶|⏸|♫|🎶)" | head -1)
    
    if [ -n "$media_title" ]; then
        clean_title=$(echo "$media_title" | sed 's/ - Google Chrome.*$//g' | sed 's/ - Mozilla Firefox.*$//g')
        echo "$clean_title"
        return 0
    fi
    return 1
}

# Verifica se há players MPRIS ativos
players=$(playerctl --list-all 2>/dev/null)
if [ -n "$players" ]; then
    # Pega o primeiro player ativo
    player=$(echo "$players" | head -n1)
    
    # Pega informações do player
    status=$(playerctl --player="$player" status 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$status" ]; then
        # Define o ícone baseado no status
        case "$status" in
            "Playing")
                icon="▶"
                ;;
            "Paused")
                icon="⏸"
                ;;
            *)
                icon="♪"
                ;;
        esac
        
        # Pega título e artista
        title=$(playerctl --player="$player" metadata title 2>/dev/null)
        artist=$(playerctl --player="$player" metadata artist 2>/dev/null)
        
        # Se conseguiu pegar título, usa as informações MPRIS
        if [ -n "$title" ]; then
            if [ -n "$artist" ]; then
                full_text="$artist - $title"
            else
                full_text="$title"
            fi
            
            display_text=$(truncate_text "$full_text")
            echo "$icon $display_text"
            exit 0
        fi
    fi
fi

# Se não encontrou players MPRIS, tenta detectar YouTube
if get_youtube_info; then
    exit 0
fi

# Se não encontrou YouTube, tenta outros media web
if get_web_media_info; then
    exit 0
fi

# Se não encontrou nada, mostra mensagem padrão
echo "♪ Nenhuma música"
