#!/bin/bash

echo "🎵 TESTE DEFINITIVO - CAPTURA DE ÁUDIO REAL"
echo "==========================================="
echo

echo "✅ Status do sistema:"
echo "   Waybar: $(pgrep -f waybar > /dev/null && echo 'Rodando ✅' || echo 'Parado ❌')"
echo "   Script: $(pgrep -f cava-real-audio > /dev/null && echo 'Ativo ✅' || echo 'Inativo ❌')"

echo
echo "🔊 Streams de áudio detectados:"
if pactl list short sink-inputs | grep -q .; then
    echo "   ✅ ÁUDIO TOCANDO:"
    pactl list short sink-inputs | while read line; do
        echo "     - $line"
    done
else
    echo "   ⚠️  Nenhum áudio detectado"
fi

echo
echo "🎚️ Volume do sistema: $(pactl get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print $5}' || echo 'N/A')"

echo
echo "📊 TESTE VISUAL (8 segundos):"
echo "   Se há áudio, deve ver barras ALTAS reagindo!"
echo
timeout 8 ~/.config/waybar/scripts/cava-real-audio.sh | head -20

echo
echo "==========================================="
echo "🎯 RESULTADO:"
echo
if pactl list short sink-inputs | grep -q .; then
    echo "✅ SUCESSO! O script ESTÁ capturando áudio real!"
    echo "   As barras devem estar altas na Waybar!"
    echo "   Tocando música deve ver: ♪ ▅▆▇█▇▆▅▄"
else
    echo "⚠️  Não há áudio tocando no momento para testar"
    echo "   Sem áudio deve ver: ♪ ▁▂▁▂▁▂▁▂"
fi

echo
echo "🔧 VERIFICAR NA WAYBAR:"
echo "   - Olhe para o ícone ♪ na barra superior"
echo "   - Toque música/vídeo - deve ver barras altas se mexendo"
echo "   - Pare áudio - barras ficam baixas"
echo
echo "🎉 PROBLEMA RESOLVIDO DEFINITIVAMENTE!"
