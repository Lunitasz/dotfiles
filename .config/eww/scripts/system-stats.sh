#!/bin/bash

case "$1" in
    --cpu)
        top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}'
        ;;
    --ram)
        free | grep Mem | awk '{print $3/$2 * 100.0}'
        ;;
    --disk-root)
        df -h / | awk 'NR==2 {print $5}' | sed 's/%//'
        ;;
    --disk-home)
        df -h /home | awk 'NR==2 {print $5}' | sed 's/%//'
        ;;
    --uptime)
        uptime -p | sed 's/up //' | sed 's/hours/hours,/' | sed 's/minutes/minutes/'
        ;;
esac
