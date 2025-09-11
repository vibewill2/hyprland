#!/bin/bash

echo "🔍 VERIFICAÇÃO FINAL DO CAVA NA WAYBAR"
echo "======================================"
echo

# 1. Verificar Waybar
if pgrep -f waybar > /dev/null; then
    echo "✅ Waybar está rodando (PID: $(pgrep -f waybar | tr '\n' ' '))"
else
    echo "❌ Waybar NÃO está rodando"
    echo "   Executando: waybar &"
    waybar &
    sleep 2
fi

echo

# 2. Verificar script Cava
if pgrep -f cava-always-works > /dev/null; then
    echo "✅ Script Cava está rodando (PID: $(pgrep -f cava-always-works))"
else
    echo "⚠️  Script Cava não está ativo"
fi

echo

# 3. Teste do script
echo "🎵 TESTE DO SCRIPT (5 segundos):"
echo "   SEM áudio deve mostrar: ♪ ▁▂▁▂▁▂▁▂"
echo "   COM áudio deve mostrar barras maiores"
echo
timeout 5 ~/.config/waybar/scripts/cava-always-works.sh | head -8

echo
echo "======================================"
echo "📋 INSTRUÇÕES:"
echo
echo "1. VERIFICAR NA WAYBAR:"
echo "   - Olhe para sua barra superior"
echo "   - Procure por um ícone ♪ com barras"
echo
echo "2. TESTAR FUNCIONAMENTO:"
echo "   - Toque uma música ou vídeo"
echo "   - As barras devem ficar maiores: ♪ ▄▅▇█▇▅▄▃"
echo "   - Pare o áudio, devem ficar pequenas: ♪ ▁▂▁▂▁▂▁▂"
echo
echo "3. SE NÃO ESTIVER APARECENDO:"
echo "   - Clique no botão de reiniciar Waybar na barra"
echo "   - Ou execute: pkill waybar && waybar &"
echo
echo "✅ CONFIGURAÇÃO CONCLUÍDA!"
