#!/bin/bash
# ~/.config/eww/scripts/clipboard.sh

case "$1" in
    --rofi)
        # Necesitás tener instalado 'cliphist' o un gestor similar
        # Si no tenés cliphist, este comando básico usa xclip:
        cliphist list | rofi -dmenu -p "Clipboard" -theme-str 'window {width: 30%;}' | cliphist decode | xclip -selection clipboard
        ;;
esac
