#!/bin/bash

# Script monitor para detectar mudanças na aplicação ativa
# Envia sinais para waybar atualizar o ícone

# Função para enviar sinal de atualização
update_waybar() {
    pkill -SIGRTMIN+1 waybar 2>/dev/null
}

# Monitor inicial
previous_class=""

while true; do
    # Obter janela ativa atual
    current_window=$(hyprctl activewindow -j 2>/dev/null)
    
    if [ "$current_window" != "null" ] && [ -n "$current_window" ]; then
        current_class=$(echo "$current_window" | jq -r '.class // empty')
    else
        current_class=""
    fi
    
    # Se mudou a aplicação, atualizar waybar
    if [ "$current_class" != "$previous_class" ]; then
        update_waybar
        previous_class="$current_class"
    fi
    
    sleep 0.5
done