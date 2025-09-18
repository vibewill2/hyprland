#!/bin/bash
# --- Hyprland + KDE automático plug-and-play no openSUSE ---

# 1️⃣ Atualiza sistema e instala Hyprland + dependências
sudo zypper ref && sudo zypper dup -y
sudo zypper install -y \
    hyprland wayland-utils swaybg swaylock wl-clipboard \
    pamixer kitty rofi polkit-kde-agent-1 \
    xdg-desktop-portal xdg-desktop-portal-kde \
    mako grim slurp swayidle playerctl

# 2️⃣ Instala pacotes KDE + Plasma Desktop
sudo zypper install -y \
    plasma5-workspace plasma5-desktop kde-cli-tools5 \
    dolphin konsole kate okular \
    breeze breeze-gtk breeze5-style kde-gtk-config

# 3️⃣ Cria environment.conf
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

# 4️⃣ Configura hyprland.conf
HYPRCONF=~/.config/hypr/hyprland.conf
mkdir -p ~/.config/hypr
cat > "$HYPRCONF" << 'EOF'
# --- Hyprland + KDE ---

input {
    kb_layout = br
}

monitor=,1400x900,0x0,1

# Autostart KDE + notificações
exec-once = dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
exec-once = /usr/libexec/xdg-desktop-portal-kde
exec-once = /usr/libexec/xdg-desktop-portal &
exec-once = hyprctl setcursor Breeze 24

exec-once = plasmashell &
exec-once = mako &

# Atalhos apps KDE
bind = SUPER, RETURN, exec, konsole
bind = SUPER, E, exec, dolphin
bind = SUPER, W, exec, kate

# Workspaces fixos
bind = SUPER, 1, workspace, 1
bind = SUPER, 2, workspace, 2
bind = SUPER, 3, workspace, 3
bind = SUPER, 4, workspace, 4
bind = SUPER, 5, workspace, 5

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

# 5️⃣ Configura painel KDE (topo + Pager 5 desktops)
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
virtualDesktopCount=5
displayedText=number
showWindowIcons=false

[Containments][1][Applets][3]
plugin=org.kde.plasma.systemtray

[Containments][1][Applets][4]
plugin=org.kde.plasma.digitalclock

[Containments][1][General]
alignment=0
EOF

# 6️⃣ Cria sessão Hyprland + KDE no SDDM/GDM
SESSIONFILE=/usr/share/wayland-sessions/hyprland-kde.desktop
sudo tee $SESSIONFILE > /dev/null << 'EOF'
[Desktop Entry]
Name=Hyprland + KDE
Comment=Hyprland with KDE Plasma panel
Exec=Hyprland
Type=Application
DesktopNames=Hyprland
EOF

# 7️⃣ Configura login automático (SDDM ou GDM)
if [ -f /etc/sddm.conf ]; then
    sudo sed -i "/^\[Autologin\]/a User=$USER\nSession=hyprland-kde" /etc/sddm.conf
elif [ -f /etc/gdm/custom.conf ]; then
    sudo sed -i "/^\[daemon\]/a AutomaticLoginEnable=True\nAutomaticLogin=$USER" /etc/gdm/custom.conf
fi

# 8️⃣ Define tema Breeze (GTK + KDE)
gsettings set org.gnome.desktop.interface gtk-theme "Breeze" 2>/dev/null
gsettings set org.gnome.desktop.interface icon-theme "breeze" 2>/dev/null

# 9️⃣ Conclusão
echo "✅ Hyprland + KDE configurado no openSUSE!"
echo "→ Sessão 'Hyprland + KDE' disponível no SDDM/GDM"
echo "→ Painel no topo, teclado BR, resolução 1400x900"
echo "→ Workspaces 1-5 fixos no pager"
