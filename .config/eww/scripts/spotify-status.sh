#!/bin/bash
# spotify-status.sh — info de playerctl para eww
# Uso: spotify-status.sh [progress|length|status|title|artist]
 
case "$1" in
  progress)
    # Posición actual en segundos
    playerctl position 2>/dev/null | awk '{printf "%.0f", $1}' || echo 0
    ;;
  length)
    # Duración total en segundos
    playerctl metadata mpris:length 2>/dev/null | awk '{printf "%.0f", $1/1000000}' || echo 0
    ;;
  status)
    playerctl status 2>/dev/null || echo "Stopped"
    ;;
  title)
    playerctl metadata title 2>/dev/null | head -c 30 || echo "Sin reproducción"
    ;;
  artist)
    playerctl metadata artist 2>/dev/null | head -c 25 || echo ""
    ;;
  cover)
    # URL de la portada (para mostrar con image en eww)
    playerctl metadata mpris:artUrl 2>/dev/null || echo ""
    ;;
  *)
    echo "Uso: spotify-status.sh [progress|length|status|title|artist|cover]"
    ;;
esac
