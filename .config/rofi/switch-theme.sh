#!/bin/bash

# Script para alternar temas do Rofi
# Uso: ./switch-theme.sh [dracula|minimal|transparente]

ROFI_CONFIG="$HOME/.config/rofi/config.rasi"

case "$1" in
    "dracula" | "")
        echo '@theme "~/.config/rofi/themes/dracula-modern.rasi"' > "$ROFI_CONFIG"
        echo "🎨 Tema Dracula Modern ativado!"
        ;;
    "minimal")
        echo '@theme "~/.config/rofi/themes/minimal-glass.rasi"' > "$ROFI_CONFIG"
        echo "✨ Tema Minimal Glass ativado!"
        ;;
    "transparente")
        echo '@theme "~/.config/rofi/themes/transparente.rasi"' > "$ROFI_CONFIG"
        echo "👻 Tema Transparente ativado!"
        ;;
    "help" | "-h" | "--help")
        echo "Uso: $0 [tema]"
        echo ""
        echo "Temas disponíveis:"
        echo "  dracula      - Tema Dracula moderno (padrão)"
        echo "  minimal      - Tema minimalista com vidro"
        echo "  transparente - Tema transparente simples"
        echo ""
        echo "Para testar: rofi -show drun"
        ;;
    *)
        echo "❌ Tema '$1' não encontrado!"
        echo "Use: $0 help para ver temas disponíveis"
        exit 1
        ;;
esac