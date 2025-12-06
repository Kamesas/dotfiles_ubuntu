#!/bin/bash

# Debounce - prevent rapid re-triggering
LOCKFILE="/tmp/hypr-lid-switch.lock"
if [ -f "$LOCKFILE" ]; then
    # Check if lockfile is older than 2 seconds
    if [ $(($(date +%s) - $(stat -c %Y "$LOCKFILE"))) -lt 2 ]; then
        exit 0
    fi
fi
touch "$LOCKFILE"

# Get current lid state
LID_STATE=$(cat /proc/acpi/button/lid/*/state 2>/dev/null | grep -o "open\|closed")

# Check if external monitor is connected
if hyprctl monitors | grep -q "HDMI-A-1"; then
    # External monitor connected - disable laptop screen when lid closes
    if [ "$LID_STATE" = "closed" ]; then
        hyprctl keyword monitor "eDP-1,disable"
    else
        hyprctl keyword monitor "eDP-1,1920x1080@60,0x0,1.5"
    fi
else
    # No external monitor - keep laptop screen on even if lid is closed
    hyprctl keyword monitor "eDP-1,1920x1080@60,0x0,1.5"
fi

# Clean up old lockfile after 3 seconds
(sleep 3 && rm -f "$LOCKFILE") &
