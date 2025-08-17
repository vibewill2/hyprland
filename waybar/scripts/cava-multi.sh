#!/bin/bash

# Cria um arquivo de configuração temporário para o CAVA
CONFIG=$(mktemp)

cat > "$CONFIG" <<EOF
[general]
bars = 40
framerate = 30
autosens = 1

[input]
method = pulse
source = auto

[output]
method = raw
channels = stereo
data_format = ascii
ascii_max_range = 10
EOF

# Loop que lê os dados do CAVA e converte em JSON para o Waybar
cava -p "$CONFIG" | while read -r line; do
    bars=$(echo "$line" | sed 's/;/ /g' | awk '{
        out="";
        for(i=1;i<=NF;i++){
            level=$i;
            if(level<2) out=out"▁";
            else if(level<3) out=out"▂";
            else if(level<4) out=out"▃";
            else if(level<5) out=out"▄";
            else if(level<6) out=out"▅";
            else if(level<7) out=out"▆";
            else if(level<8) out=out"▇";
            else out=out"█";
        }
        print out;
    }')

    synth1=$(echo "$bars" | cut -c1-15)   # primeiras 15 barras
    synth2=$(echo "$bars" | cut -c16-30)  # barras do meio
    synth3=$(echo "$bars" | cut -c31-40)  # últimas barras
    synth3=$(echo "$synth3" | tr "▁▂▃▄▅▆▇█" "█▇▆▅▄▃▂▁") # invertido

    # Saída em JSON para Waybar
    echo "{\"class\": \"synth1\", \"text\": \"$synth1\"}"
    echo "{\"class\": \"synth2\", \"text\": \"$synth2\"}"
    echo "{\"class\": \"synth3\", \"text\": \"$synth3\"}"
done
