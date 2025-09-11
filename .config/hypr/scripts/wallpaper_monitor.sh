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
    
    # Executar wallust
    ~/.cargo/bin/wallust run "$wallpaper" > /dev/null 2>&1
    
    # Recarregar kitty
    killall -SIGUSR1 kitty 2>/dev/null || true
    
    log_message "Cores atualizadas com sucesso"
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
