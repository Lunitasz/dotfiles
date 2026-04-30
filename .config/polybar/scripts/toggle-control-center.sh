#!/usr/bin/env bash

if eww active-windows | grep -q "controlcenter"; then
  eww close controlcenter
else
  eww open controlcenter
fi
