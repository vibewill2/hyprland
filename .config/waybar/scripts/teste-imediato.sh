#!/bin/bash

echo "🔊 TESTE IMEDIATO - REATIVIDADE AO VOLUME"
echo "========================================"
echo

echo "📋 INSTRUÇÕES PARA TESTAR:"
echo "1. Deixe este teste rodando"  
echo "2. Mude o volume do sistema (use as teclas de volume)"
echo "3. Observe se as barras REAGEM às mudanças"
echo "4. Abra/feche vídeos no navegador"
echo

echo "🎯 TESTANDO (20 segundos):"
echo "   MUDE O VOLUME AGORA para ver a reação!"
echo

timeout 20 ~/.config/waybar/scripts/volume-reactive.sh

echo
echo "========================================"
echo "❓ RESULTADO:"
echo
echo "• Se as barras MUDARAM quando você mudou o volume = ✅ FUNCIONANDO"
echo "• Se as barras NÃO reagiram às mudanças = ❌ Ainda não funciona"
echo
echo "🔧 O que você deve ver na Waybar:"
echo "• Ao mudar volume: barras devem ficar ALTAS temporariamente" 
echo "• Com áudio tocando: barras proporcionais ao volume"
echo "• Sem áudio: barras baixas ♪ ▁▂▁▂▁▂▁▂"
echo
echo "Teste concluído!"
