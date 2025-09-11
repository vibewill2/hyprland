#!/usr/bin/env bash
# ~/.config/waybar/scripts/color_toggle.sh

STATE_FILE="$HOME/.config/waybar/.bar_color_state"
CSS_FILE="$HOME/.config/waybar/style.css"

COLORS=(
    "rgba(0, 0, 0, 0.2)"
    "rgba(255, 0, 0, 0.2)"
    "rgba(0, 255, 0, 0.2)"
    "rgba(0, 0, 255, 0.2)"
    "rgba(255, 255, 0, 0.2)"
)

if [[ -f "$STATE_FILE" ]]; then
    INDEX=$(cat "$STATE_FILE")
else
    INDEX=0
fi

INDEX=$(( (INDEX + 1) % ${#COLORS[@]} ))
NEW_COLOR=${COLORS[$INDEX]}

# Substitui apenas a linha do #waybar com background
sed -i "s|^\(\s*background: \).*;|\1$NEW_COLOR;|" "$CSS_FILE"

echo "$INDEX" > "$STATE_FILE"
