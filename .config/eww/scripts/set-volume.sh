#!/bin/bash

# Función para obtener el porcentaje de volumen
get_vol() {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -Po '[0-9]+(?=%)' | head -n 1
}

# Función para ver si está muteado (devuelve true/false)
is_muted() {
    pactl get-sink-mute @DEFAULT_SINK@ | grep -q "yes" && echo "true" || echo "false"
}

# Función para devolver el icono según el estado
get_icon() {
    if [ "$(is_muted)" = "true" ]; then
        echo "󰝟" # Icono de volumen tachado
    else
        echo "󰕾" # Icono de volumen activo
    fi
}

case "$1" in
    --get)
        get_vol
        ;;
    --set)
        # Limpiamos el valor para asegurar que sea un entero
        val=$(echo "$2" | cut -d. -f1)
        pactl set-sink-volume @DEFAULT_SINK@ "${val}%"
        ;;
    --toggle)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        ;;
    --status)
        is_muted
        ;;
    --icon)
        get_icon
        ;;
esac
