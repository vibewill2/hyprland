#!/bin/bash

# FORÇA O CAVA REAL A FUNCIONAR - última tentativa definitiva

cleanup() {
    pkill -f "cava.*force"
    rm -f /tmp/force_cava_*
    exit 0
}

trap cleanup EXIT INT TERM

# Configuração que FORÇA captura de áudio
create_force_config() {
    local config_file="/tmp/force_cava_$$"
    cat > "$config_file" << 'EOF'
[general]
bars = 8
bar_width = 1
bar_spacing = 0
sleep_timer = 1
sensitivity = 100

[input]
method = pulse
source = auto

[output]
method = raw
channels = mono
mono_option = average
raw_target = /dev/stdout
data_format = ascii
ascii_max_range = 7
bar_delimiter = 0
bit_format = 8bit

[smoothing]
monstercat = 1
waves = 0
gravity = 200
integral = 100
ignore = 0

[color]
gradient = 0
EOF
    echo "$config_file"
}

# Tentar múltiplas fontes até uma funcionar
try_all_sources() {
    local config_file=$(create_force_config)
    
    # Lista de todas as fontes possíveis
    local sources=(
        "auto"
        "default"
        "@DEFAULT_SOURCE@"
        "alsa_output.pci-0000_04_00.6.analog-stereo.monitor"
        "$(pactl get-default-sink).monitor"
    )
    
    # Adicionar todas as sources disponíveis
    pactl list short sources | cut -f2 | while read source; do
        sources+=("$source")
    done
    
    for source in "${sources[@]}"; do
        if [ -z "$source" ]; then continue; fi
        
        # Atualizar config com esta source
        sed -i "s/source = .*/source = $source/" "$config_file"
        
        # Tentar esta source por 3 segundos
        local output=$(timeout 3 cava -p "$config_file" 2>/dev/null)
        
        if [ -n "$output" ] && echo "$output" | grep -q -v "^0*$"; then
            # Esta source funciona! Usar ela
            while true; do
                timeout 60 cava -p "$config_file" 2>/dev/null | while IFS= read -r line; do
                    if [ ${#line} -ge 4 ] && echo "$line" | grep -q -v "^0*$"; then
                        # Converter para barras
                        visual=""
                        for (( i=0; i<${#line} && i<8; i++ )); do
                            char="${line:$i:1}"
                            case $char in
                                0) visual+="▁" ;;
                                1) visual+="▂" ;;
                                2) visual+="▃" ;;
                                3) visual+="▄" ;;
                                4) visual+="▅" ;;
                                5) visual+="▆" ;;
                                6) visual+="▇" ;;
                                7) visual+="█" ;;
                                *) visual+="▁" ;;
                            esac
                        done
                        
                        while [ ${#visual} -lt 8 ]; do
                            visual+="▁"
                        done
                        
                        echo "♪ $visual"
                    else
                        echo "♪ ▁▁▁▁▁▁▁▁"
                    fi
                done || break
            done &
            wait
            break
        fi
    done
    
    rm -f "$config_file"
}

# Se CAVA não funcionar, usar método de análise direta do PipeWire
analyze_pipewire_direct() {
    # Usar pw-dump para analisar dados de áudio
    if command -v pw-dump &> /dev/null; then
        pw-dump | jq -r '.[] | select(.info.props."media.class" == "Audio/Sink") | .info.props."node.name"' 2>/dev/null | head -1
    fi
}

# Método de último recurso - análise de sistema
system_audio_analysis() {
    while true; do
        # Analisar CPU de processos de áudio
        local audio_cpu=0
        for proc in $(pgrep -f "firefox|chrome|spotify|vlc|mpv"); do
            local cpu=$(ps -p $proc -o %cpu= 2>/dev/null | tr -d ' ' | cut -d. -f1)
            [ -n "$cpu" ] && audio_cpu=$((audio_cpu + cpu))
        done
        
        # Analisar mudanças no volume
        local current_vol=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2}' | sed 's/0\.//')
        
        # Gerar nível baseado na atividade do sistema
        local level=0
        [ "$audio_cpu" -gt 5 ] && level=3
        [ "$audio_cpu" -gt 15 ] && level=5
        [ "$audio_cpu" -gt 25 ] && level=7
        
        # Adicionar variação temporal
        local time_mod=$(($(date +%s) % 4))
        level=$((level + time_mod - 2))
        [ $level -lt 0 ] && level=0
        [ $level -gt 7 ] && level=7
        
        # Gerar barras
        local bars=""
        for i in {1..8}; do
            local bar_level=$((level + (RANDOM % 3 - 1)))
            [ $bar_level -lt 0 ] && bar_level=0
            [ $bar_level -gt 7 ] && bar_level=7
            
            case $bar_level in
                0) bars+="▁" ;;
                1) bars+="▂" ;;
                2) bars+="▃" ;;
                3) bars+="▄" ;;
                4) bars+="▅" ;;
                5) bars+="▆" ;;
                6) bars+="▇" ;;
                7) bars+="█" ;;
            esac
        done
        
        echo "♪ $bars"
        sleep 0.2
    done
}

# Tentar métodos em ordem de preferência
echo "Tentando CAVA real..." >&2
try_all_sources &
cava_pid=$!

# Se CAVA não funcionar em 10 segundos, usar análise de sistema
sleep 10
if kill -0 $cava_pid 2>/dev/null; then
    wait $cava_pid
else
    echo "CAVA falhou, usando análise de sistema..." >&2
    system_audio_analysis
fi
