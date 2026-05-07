#!/bin/bash

if [ -f /etc/arch-release ]; then
    count=$(checkupdates 2>/dev/null | wc -l)
    list=$(checkupdates 2>/dev/null | head -n 3 | sed 's/^/• /')

elif [ -f /etc/debian_version ]; then
    # Parrot/Debian
    count=$(apt-get -s upgrade 2>/dev/null | grep -c "^Inst")

    list=$(apt-get -s upgrade 2>/dev/null \
        | grep "^Inst" \
        | head -n 3 \
        | awk '{print "• " $2}')

else
    count=0
    list="Sistema no soportado"
fi

case "$1" in
    --count) echo "$count" ;;
    --list) echo "$list" ;;
esac
