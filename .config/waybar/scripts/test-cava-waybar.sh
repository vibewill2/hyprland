#!/bin/bash

# Teste do Cava na waybar
echo "🔍 Testando Cava na Waybar..."
echo

echo "1. Verificando se Waybar está rodando:"
if pgrep -f waybar > /dev/null; then
    echo "   ✅ Waybar está rodando (PID: $(pgrep -f waybar | head -1))"
else
    echo "   ❌ Waybar não está rodando"
    exit 1
fi

echo
echo "2. Verificando se script Cava está executando:"
if pgrep -f cava-enhanced.sh > /dev/null; then
    echo "   ✅ Script Cava está rodando (PID: $(pgrep -f cava-enhanced.sh))"
else
    echo "   ⚠️  Script Cava não está rodando"
fi

echo
echo "3. Testando saída do script Cava (5 segundos):"
timeout 5 ~/.config/waybar/scripts/cava-enhanced.sh | head -5

echo
echo "4. Verificando configuração da Waybar:"
if grep -q "cava-enhanced.sh" ~/.config/waybar/config.jsonc; then
    echo "   ✅ Configuração do Cava encontrada na Waybar"
else
    echo "   ❌ Configuração do Cava não encontrada"
fi

echo
echo "5. Status dos dispositivos de áudio:"
pactl list short sinks | head -3
pactl list short sources | head -3

echo
echo "✅ Teste concluído! O Cava deve estar funcionando na sua Waybar."
echo "   Se não estiver aparecendo, tente:"
echo "   - Reiniciar a Waybar: pkill waybar && waybar &"
echo "   - Verificar se há erros nos logs"
