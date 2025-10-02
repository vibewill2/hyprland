#!/bin/bash

# Daemon para monitorar mudanças de wallpaper e atualizar cores do terminal
# Executado em background

LAST_WALLPAPER=""
CHECK_INTERVAL=2  # segundos entre verificações

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> ~/.config/hypr/logs/wallpaper_monitor.log
}

update_colors() {
    local wallpaper="$1"
    log_message "Wallpaper mudou para: $wallpaper"
    
    # Garantir que o PATH inclui o cargo
    export PATH="$HOME/.cargo/bin:$PATH"
    
    # Executar wallust
    if wallust run "$wallpaper" > /dev/null 2>&1; then
        log_message "Wallust executado com sucesso"
        
        # Aguardar para os arquivos serem escritos
        sleep 0.5
        
        # Reiniciar waybar se estiver rodando (apenas no Hyprland)
        if [ "$XDG_CURRENT_DESKTOP" = "Hyprland" ] || [ "$HYPRLAND_INSTANCE_SIGNATURE" != "" ] || pgrep -x "Hyprland" >/dev/null; then
            if pgrep waybar >/dev/null; then
                log_message "Reiniciando waybar..."
                pkill waybar 2>/dev/null || true
                sleep 1
                WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc" WAYBAR_STYLE="$HOME/.config/waybar/style.css" waybar & 2>/dev/null
            fi
        else
            log_message "Não está no Hyprland - pulando waybar"
        fi
        
        # Recarregar kitty
        if pgrep kitty >/dev/null; then
            killall -SIGUSR1 kitty 2>/dev/null || true
            log_message "Kitty recarregado"
        fi
        
        log_message "Todas as cores atualizadas com sucesso"
    else
        log_message "Erro ao executar wallust"
    fi
}

# Criar diretório de logs se não existir
mkdir -p ~/.config/hypr/logs

log_message "Iniciando monitor de wallpaper..."

# Loop principal
while true; do
    # Obter wallpaper atual do swww
    CURRENT_WALLPAPER=$(swww query 2>/dev/null | grep -oP '(?<=image: ).*' | head -1)
    
    # Verificar se o wallpaper mudou
    if [ -n "$CURRENT_WALLPAPER" ] && [ "$CURRENT_WALLPAPER" != "$LAST_WALLPAPER" ]; then
        if [ -n "$LAST_WALLPAPER" ]; then
            # Só atualiza se não for a primeira execução
            update_colors "$CURRENT_WALLPAPER"
        else
            log_message "Wallpaper inicial detectado: $CURRENT_WALLPAPER"
        fi
        LAST_WALLPAPER="$CURRENT_WALLPAPER"
    fi
    
    sleep $CHECK_INTERVAL
done
