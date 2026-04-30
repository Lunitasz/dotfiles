#!/bin/bash

if [ -f /etc/arch-release ]; then
    count=$(checkupdates 2>/dev/null | wc -l)
    list=$(checkupdates 2>/dev/null | head -n 3 | sed 's/^/• /')
elif [ -f /etc/debian_version ]; then
    # En Parrot/Debian usamos apt
    count=$(apt list --upgradable 2>/dev/null | grep -c upgradable)
    list=$(apt list --upgradable 2>/dev/null | grep upgradable | head -n 3 | cut -d/ -f1 | sed 's/^/• /')
else
    count=0
    list="Sistema no soportado"
fi

case "$1" in
    --count) echo "$count" ;;
    --list)  echo "$list" ;;
esac
