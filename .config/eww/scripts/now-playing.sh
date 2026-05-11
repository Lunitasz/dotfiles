#!/usr/bin/env bash

PLAYER="$(playerctl -l 2>/dev/null | head -n 1)"

if [ -z "$PLAYER" ]; then
    case "$1" in
        title) echo "Nada reproduciéndose" ;;
        artist) echo "Abrir música" ;;
        status) echo "Stopped" ;;
        icon) echo "" ;;
        open) firefox & ;;
    esac
    exit 0
fi

case "$1" in
    title)
        playerctl -p "$PLAYER" metadata title 2>/dev/null || echo "Sin título"
        ;;
    artist)
        playerctl -p "$PLAYER" metadata artist 2>/dev/null || echo "$PLAYER"
        ;;
    status)
        playerctl -p "$PLAYER" status 2>/dev/null || echo "Stopped"
        ;;
    icon)
        status="$(playerctl -p "$PLAYER" status 2>/dev/null)"
        [ "$status" = "Playing" ] && echo "" || echo ""
        ;;
    play-pause)
        playerctl -p "$PLAYER" play-pause 2>/dev/null
        ;;
    next)
        playerctl -p "$PLAYER" next 2>/dev/null
        ;;
    previous)
        playerctl -p "$PLAYER" previous 2>/dev/null
        ;;
    open)
        firefox &
        ;;
    progress)
    pos="$(playerctl -p "$PLAYER" position 2>/dev/null | cut -d. -f1)"
    len="$(playerctl -p "$PLAYER" metadata mpris:length 2>/dev/null)"
    len="$((len / 1000000))"

    if [ -z "$pos" ] || [ -z "$len" ] || [ "$len" -eq 0 ]; then
        echo 0
    else
        echo $((pos * 100 / len))
    fi
    ;;
    current)
    pos="$(playerctl -p "$PLAYER" position 2>/dev/null)"

    if [ -z "$pos" ]; then
        echo "0:00"
    else
        minutes=$(printf "%.0f" "$(echo "$pos / 60" | bc -l)")
        seconds=$(printf "%02d" "$(echo "$pos % 60" | bc)")
        echo "${minutes}:${seconds}"
    fi
    ;;
    duration)
    len="$(playerctl -p "$PLAYER" metadata mpris:length 2>/dev/null)"
    len="$((len / 1000000))"

    if [ -z "$len" ] || [ "$len" -eq 0 ]; then
        echo "0:00"
    else
        minutes=$((len / 60))
        seconds=$(printf "%02d" $((len % 60)))
        echo "${minutes}:${seconds}"
    fi
    ;;

esac
