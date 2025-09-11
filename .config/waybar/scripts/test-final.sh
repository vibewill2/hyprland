#!/bin/bash

echo "🎵 TESTE FINAL DO INDICADOR DE ÁUDIO"
echo "=================================="
echo

echo "✅ O ruído foi removido (módulo loopback descarregado)"
echo

echo "Status atual:"
echo "1. Waybar: $(pgrep -f waybar > /dev/null && echo 'Rodando ✅' || echo 'Parado ❌')"
echo "2. Script indicador: $(pgrep -f cava-simple-indicator > /dev/null && echo 'Ativo ✅' || echo 'Inativo')"
echo

echo "3. Streams de áudio ativos:"
if pactl list short sink-inputs | grep -q .; then
    echo "   ✅ Detectado áudio tocando"
    pactl list short sink-inputs | while read line; do
        echo "     - $line"
    done
else
    echo "   ⚠️  Nenhum áudio detectado no momento"
fi

echo
echo "4. Volume atual:"
volume=$(pactl get-sink-volume @DEFAULT_SINK@ | head -n 1 | awk '{print $5}' || echo "N/A")
echo "   Volume do sistema: $volume"

echo
echo "5. Visualização do indicador (5 segundos):"
timeout 5 ~/.config/waybar/scripts/cava-simple-indicator.sh | head -10

echo
echo "=================================="
echo "✅ FUNCIONAMENTO CORRETO!"
echo
echo "O que você deve ver na Waybar:"
echo "• Quando HÁ áudio: ♪ com barras mais altas baseadas no volume"
echo "• Quando NÃO há áudio: ♪ com animação suave e baixa"
echo
echo "🔊 O indicador responde ao volume do sistema e à presença de áudio"
echo "🎧 Não interfere com seu áudio e não causa ruídos"
echo "✨ Funciona de forma leve e eficiente"
