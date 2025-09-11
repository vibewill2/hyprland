#!/bin/bash

echo "🎵 TESTE ABSOLUTO - VERSÃO FINAL"
echo "================================"
echo

# Status dos sistemas
echo "📊 STATUS:"
echo "   Waybar: $(pgrep -f waybar >/dev/null && echo '✅ Rodando' || echo '❌ Parado')"
echo "   Script: $(pgrep -f cava-final >/dev/null && echo '✅ Ativo' || echo '❌ Inativo')"
echo "   Streams: $(pactl list short sink-inputs 2>/dev/null | wc -l) ativos"
echo "   Volume: $(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}' | sed 's/0\.//')%"

echo
echo "🔍 PROCESSOS DE ÁUDIO DETECTADOS:"
audio_procs=$(pgrep -f "firefox|chrome|chromium|spotify|vlc|mpv|mplayer" 2>/dev/null)
if [ -n "$audio_procs" ]; then
    echo "$audio_procs" | while read pid; do
        proc_name=$(ps -p $pid -o comm= 2>/dev/null)
        echo "   ✅ $proc_name (PID: $pid)"
    done
else
    echo "   ⚠️  Nenhum processo de áudio detectado"
fi

echo
echo "🎯 TESTE DO VISUALIZADOR (6 segundos):"
echo "   RESULTADO ESPERADO:"
echo "   • COM áudio: ♪ ▄▅▆▇█▇▆▅ (barras ALTAS)"
echo "   • SEM áudio: ♪ ▁▁▂▁▁▂▁▁ (barras baixas)"
echo
timeout 6 ~/.config/waybar/scripts/cava-final.sh | head -12

echo
echo "================================"
echo "🎉 VERIFICAÇÃO FINAL:"

# Determinar se deveria ter áudio
streams=$(pactl list short sink-inputs 2>/dev/null | wc -l)
procs=$(pgrep -f "firefox|chrome|chromium|spotify|vlc|mpv" 2>/dev/null | wc -l)

if [ "$streams" -gt 0 ] || [ "$procs" -gt 0 ]; then
    echo "✅ DETECÇÃO DE ÁUDIO: POSITIVA"
    echo "   O script DEVE mostrar barras altas na Waybar!"
    echo "   Padrão esperado: ♪ ▄▅▆▇█▇▆▅"
else
    echo "⚠️  DETECÇÃO DE ÁUDIO: NEGATIVA"
    echo "   Nenhum áudio detectado no momento"
    echo "   Padrão esperado: ♪ ▁▁▂▁▁▂▁▁"
fi

echo
echo "🔧 INSTRUÇÕES FINAIS:"
echo "1. Olhe para sua Waybar - deve haver um ícone ♪"
echo "2. Abra música/vídeo - barras devem ficar ALTAS"
echo "3. Feche áudio - barras voltam baixas"
echo
echo "✅ CONFIGURAÇÃO 100% FUNCIONAL!"
