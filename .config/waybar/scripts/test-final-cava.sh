#!/bin/bash

echo "🎵 TESTE FINAL - CAVA MONITORANDO ÁUDIO REAL"
echo "=============================================="
echo

echo "1. Status da Waybar:"
if pgrep -f waybar > /dev/null; then
    echo "   ✅ Waybar rodando (PIDs: $(pgrep -f waybar | tr '\n' ' '))"
else
    echo "   ❌ Waybar não está rodando"
fi

echo
echo "2. Script Cava ativo:"
if pgrep -f cava-fixed.sh > /dev/null; then
    echo "   ✅ Script cava-fixed.sh rodando (PID: $(pgrep -f cava-fixed.sh))"
else
    echo "   ⚠️  Script não está rodando ativamente"
fi

echo
echo "3. Dispositivos de áudio:"
echo "   Sink padrão: $(pactl get-default-sink)"
echo "   Monitor: $(pactl get-default-sink).monitor"

echo
echo "4. Streams de áudio ativos:"
if pactl list short sink-inputs | grep -q .; then
    echo "   ✅ Há áudio tocando:"
    pactl list short sink-inputs | while read line; do
        echo "     - $line"
    done
else
    echo "   ⚠️  Nenhum stream de áudio detectado"
fi

echo
echo "5. Teste do visualizador (10 segundos):"
echo "   Se há áudio tocando, você deve ver barras se movendo!"
echo
timeout 10 ~/.config/waybar/scripts/cava-fixed.sh 2>/dev/null | head -20

echo
echo "=============================================="
echo "✅ TESTE CONCLUÍDO!"
echo
echo "O que você deve ver na Waybar:"
echo "- ♪ com barras animadas quando NÃO há áudio"
echo "- ♪ com barras reativas quando HÁ áudio tocando"
echo
echo "Se o Cava não estiver reagindo ao áudio:"
echo "1. Certifique-se que há áudio tocando"
echo "2. Clique no ícone do Cava na Waybar para reiniciar"
echo "3. Ou execute: pkill -f cava-fixed && waybar &"
