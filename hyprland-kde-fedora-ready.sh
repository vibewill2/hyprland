#!/bin/bash
# --- Hyprland + KDE automático plug-and-play no Fedora ---

# 1⃣ Instala Hyprland + dependências
sudo dnf install -y \
    hyprland wayland-utils swaybg swaylock wl-clipboard \
    pamixer kitty rofi polkit-kde-agent-1 \
    xdg-desktop-portal xdg-desktop-portal-kde \
    mako grim slurp swayidle playerctl

# 2⃣ Instala pacotes KDE + Plasma Desktop
sudo dnf install -y \
    plasma-workspace plasma-desktop kde-cli-tools \
    dolphin konsole kate okular \
    breeze-gtk breeze-icon-theme kde-gtk-config

# 3⃣ Cria environment.conf
mkdir -p ~/.config/hypr
cat > ~/.config/hypr/environment.conf << 'EOF'
export QT_QPA_PLATFORM=wayland
export XDG_CURRENT_DESKTOP=KDE
export XDG_SESSION_DESKTOP=KDE
export GTK_USE_PORTAL=1
export XCURSOR_THEME=Breeze
export XCURSOR_SIZE=24
export QT_STYLE_OVERRIDE=Breeze
EOF

# 4⃣ Configura hyprland.conf
mkdir -p ~/.config/hypr
HYPRCONF=~/.config/hypr/hyprland.conf
cat > "$HYPRCONF" << 'EOF'
# --- Hyprland config com KDE ---

# Layout teclado BR
input {
    kb_layout = br
}

# Resolução fixa 1400x900
monitor=,1400x900,0x0,1

# Autostart KDE + notificações
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = /usr/libexec/xdg-desktop-portal-kde
exec-once = /usr/libexec/xdg-desktop-portal &
exec-once = gsettings set org.gnome.desktop.interface gtk-theme "Breeze"
exec-once = gsettings set org.gnome.desktop.interface icon-theme "breeze"
exec-once = hyprctl setcursor Breeze 24

exec-once = plasmashell &
exec-once = mako &

# Atalhos apps KDE
bind = SUPER, RETURN, exec, konsole
bind = SUPER, E, exec, dolphin
bind = SUPER, W, exec, kate

# Atalho fechar janela
bind = SUPER, Q, killactive

# 5 workspaces fixos
bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER, 3, workspace, 3
bind = SUPER, 4, workspace, 4
bind = SUPER, 5, workspace, 5

# Mover janelas entre workspaces
bind = SUPER SHIFT, 1, movetoworkspace, 1
bind = SUPER SHIFT, 2, movetoworkspace, 2
bind = SUPER SHIFT, 3, movetoworkspace, 3
bind = SUPER SHIFT, 4, movetoworkspace, 4
bind = SUPER SHIFT, 5, movetoworkspace, 5

# Multimídia
bind = XF86AudioRaiseVolume, exec, pamixer -i 5
bind = XF86AudioLowerVolume, exec, pamixer -d 5
bind = XF86AudioMute, exec, pamixer -t
bind = XF86AudioPlay, exec, playerctl play-pause
bind = XF86AudioNext, exec, playerctl next
bind = XF86AudioPrev, exec, playerctl previous

# Lockscreen
bind = SUPER, L, exec, swaylock -f -c 000000
EOF

# 5⃣ Configura painel KDE (topo + Pager 5 workspaces numéricos)
PLASMACONF=~/.config/plasma-org.kde.plasma.desktop-appletsrc
mkdir -p ~/.config
cat > "$PLASMACONF" << 'EOF'
[Containments][1]
activityId=
formfactor=2
immutability=1
lastScreen=0
location=3
plugin=org.kde.panel
wallpaperplugin=org.kde.image

[Containments][1][Applets][1]
plugin=org.kde.plasma.kickoff

[Containments][1][Applets][2]
plugin=org.kde.plasma.pager
[Containments][1][Applets][2][Configuration][General]
rows=1
showOnlyCurrentScreen=false
wrap=false
displayedText=number
previews=false
showWindowIcons=false
showOnlyCurrentActivity=false
virtualDesktopCount=5

# Mostra números em vez de miniaturas
displayedText=number

[Containments][1][Applets][3]
plugin=org.kde.plasma.systemtray

[Containments][1][Applets][4]
plugin=org.kde.plasma.digitalclock

[Containments][1][General]
alignment=0
EOF

# 6⃣ Cria sessão Hyprland + KDE no GDM
SESSIONFILE=/usr/share/wayland-sessions/hyprland-kde.desktop
sudo tee $SESSIONFILE > /dev/null << 'EOF'
[Desktop Entry]
Name=Hyprland + KDE
Comment=Hyprland with KDE Plasma panel
Exec=Hyprland
Type=Application
DesktopNames=Hyprland
EOF

# 7⃣ Configura Hyprland como sessão padrão para login automático
if [ -f /etc/gdm/custom.conf ]; then
    sudo sed -i '/^\[daemon\]/a AutomaticLoginEnable=True\nAutomaticLogin='$USER'' /etc/gdm/custom.conf
fi

# 8⃣ Configura wallpaper e tema Breeze automaticamente
gsettings set org.kde.desktop.background picture-uri "file:///usr/share/wallpapers/Breeze/default.jpg"
gsettings set org.gnome.desktop.interface gtk-theme "Breeze"

# 9⃣ Conclusão
echo "✅ Hyprland + KDE configurado!"
echo "→ Sessão: 'Hyprland + KDE' no GDM"
echo "→ Painel topo, teclado BR, resolução 1400x900"
echo "→ Workspaces numéricos no painel"
echo "→ Alternar: SUPER+1..5 | Mover apps: SUPER+SHIFT+1..5 | Fechar: SUPER+Q"
