#!/bin/bash

# Re-enable the laptop monitor
hyprctl keyword monitor "eDP-1, 1920x1080@60,0x0,1.0"

# Optional: Move workspace 1 back to laptop monitor
# hyprctl dispatch moveworkspacetomonitor "1" eDP-1
