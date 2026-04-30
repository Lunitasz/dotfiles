#!/usr/bin/env bash
#!/usr/bin/env bash

theme="$HOME/.config/polybar/scripts/powermenu/style.rasi"

# Colores (los tuyos)
blue="#89b4fa"
yellow="#f9e2af"
green="#94e2d5"
red="#f38ba8"
fg="#e5e7eb"
muted="#7f849c"

# Opciones (ordenadas para 2x2)
lock="<span foreground='$blue'>󰌾</span> <span foreground='$fg'>Bloquear</span>"
reboot="<span foreground='$green'></span> <span foreground='$fg'>Reiniciar</span>"
logout="<span foreground='$yellow'></span> <span foreground='$fg'>Salir</span>"
shutdown="<span foreground='$red'></span> <span foreground='$red'><b>Apagar</b></span>"

options="$lock\n$reboot\n$logout\n$shutdown"

chosen=$(echo -e "$options" | rofi \
    -dmenu \
    -i \
    -markup-rows \
    -no-show-icons \
    -p "☾ Moon" \
    -theme "$theme")

case "$chosen" in
    "$lock")
        if command -v betterlockscreen >/dev/null 2>&1; then
            betterlockscreen -l
        elif command -v i3lock >/dev/null 2>&1; then
            i3lock
        else
            notify-send "Powermenu" "No hay locker instalado"
        fi
        ;;
    "$logout")
        bspc quit
        ;;
    "$reboot")
        systemctl reboot
        ;;
    "$shutdown")
        systemctl poweroff
        ;;
esac
