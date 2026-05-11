#!/usr/bin/env bash

if eww active-windows | grep -q "now_playing_window"; then
    eww close now_playing_window
else
    eww open now_playing_window
fi
