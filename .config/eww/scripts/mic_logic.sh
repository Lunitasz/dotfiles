#!/bin/bash
case "$1" in
    --toggle) pactl set-source-mute @DEFAULT_SOURCE@ toggle ;;
    --status) 
        pactl get-source-mute @DEFAULT_SOURCE@ | grep -q "yes" && echo "muted" || echo "active" ;;
    --icon)
        if pactl get-source-mute @DEFAULT_SOURCE@ | grep -q "yes"; then
            echo "󰍭" # Icono mute
        else
            echo "󰍬" # Icono activo
        fi ;;
esac
