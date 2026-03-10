#!/bin/bash

echo "Instalando Hyprland + KDE apps..."

sudo zypper install -y \
hyprland waybar rofi-wayland \
dolphin konsole kate ark okular \
kvantum-manager qt6ct qt5ct \
dunst grim slurp wl-clipboard \
network-manager-applet blueman

echo "Criando pastas de configuração..."

mkdir -p ~/.config/hypr
mkdir -p ~/.config/waybar
mkdir -p ~/.config/rofi

echo "Criando configuração do Hyprland..."

cat > ~/.config/hypr/hyprland.conf << 'EOF'
monitor=,preferred,auto,1

exec-once = waybar
exec-once = nm-applet
exec-once = blueman-applet
exec-once = dunst

env = QT_QPA_PLATFORMTHEME,qt6ct
env = QT_STYLE_OVERRIDE,kvantum

$mod = SUPER

bind = $mod, RETURN, exec, konsole
bind = $mod, Q, killactive
bind = $mod, D, exec, rofi -show drun
bind = $mod, E, exec, dolphin

bind = $mod, F, fullscreen
bind = $mod, SPACE, togglefloating

bind = $mod, 1, workspace, 1
bind = $mod, 2, workspace, 2
bind = $mod, 3, workspace, 3
bind = $mod, 4, workspace, 4
bind = $mod, 5, workspace, 5
bind = $mod, 6, workspace, 6
bind = $mod, 7, workspace, 7
bind = $mod, 8, workspace, 8
bind = $mod, 9, workspace, 9

general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
}

decoration {
    rounding = 10
    blur = yes
    blur_size = 6
}

animations {
    enabled = yes
}
EOF

echo "Criando configuração da Waybar..."

cat > ~/.config/waybar/config << 'EOF'
{
"layer": "top",
"position": "top",

"modules-left": ["hyprland/workspaces"],
"modules-center": ["clock"],
"modules-right": ["pulseaudio","network","cpu","memory","tray"],

"clock": {
"format": "{:%H:%M}"
}
}
EOF

echo "Criando estilo da Waybar..."

cat > ~/.config/waybar/style.css << 'EOF'
* {
font-family: JetBrainsMono Nerd Font;
font-size: 13px;
}

window#waybar {
background: rgba(30,30,30,0.8);
color: white;
}

#workspaces button {
padding: 5px;
color: white;
}

#clock {
padding: 0 10px;
}
EOF

echo "Criando configuração do Rofi..."

cat > ~/.config/rofi/config.rasi << 'EOF'
configuration {
    show-icons: true;
}

* {
    font: "JetBrainsMono Nerd Font 12";
}
EOF

echo "Instalação concluída!"
echo "Agora faça logout e selecione Hyprland na tela de login."
