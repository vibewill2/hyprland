#!/bin/bash

# Pega o volume atual do microfone (PulseAudio)
volume=$(pactl get-source-volume @DEFAULT_SOURCE@ | grep -oP '\d+%' | head -n1)

echo "$volume "

