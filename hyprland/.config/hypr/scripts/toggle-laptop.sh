#!/bin/bash

# ============================================================================
# HYPRLAND LAPTOP MONITOR TOGGLE
# ============================================================================
# Smart toggle for laptop monitor (eDP-1):
# - If laptop monitor is enabled: disable it (move workspaces to external)
# - If laptop monitor is disabled: enable it
# - If no external monitor: always keep laptop enabled (safety)
# ============================================================================

LOGFILE="/tmp/hypr-toggle-laptop.log"

# Function to log with timestamp
log_event() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$LOGFILE"
}

# Check if external monitor is connected
EXTERNAL_MONITOR_CONNECTED=false
if hyprctl monitors 2>/dev/null | grep -q "HDMI-A-1"; then
    EXTERNAL_MONITOR_CONNECTED=true
fi

# Check current state of laptop monitor
# Check if eDP-1 exists in active monitors list - if not, it's disabled
LAPTOP_ENABLED=$(hyprctl monitors -j 2>/dev/null | jq -r 'any(.name == "eDP-1")')

log_event "TOGGLE: External monitor=$EXTERNAL_MONITOR_CONNECTED | Laptop enabled=$LAPTOP_ENABLED"

# If no external monitor, always keep laptop enabled
if [ "$EXTERNAL_MONITOR_CONNECTED" = false ]; then
    log_event "ACTION: No external monitor - ensuring laptop enabled at 0x0"
    hyprctl keyword monitor "eDP-1,1920x1080@60,0x0,1.0" 2>&1 | tee -a "$LOGFILE" >/dev/null
    notify-send -u normal -t 3000 "🖥️ Laptop Monitor" "No external monitor detected"
    exit 0
fi

# Toggle based on current state
if [ "$LAPTOP_ENABLED" = "true" ]; then
    # Laptop is enabled - disable it
    log_event "ACTION: Disabling laptop monitor"

    # First, focus the external monitor to avoid being stuck on laptop screen
    hyprctl dispatch focusmonitor HDMI-A-1 2>&1 | tee -a "$LOGFILE" >/dev/null

    # Move all workspaces from laptop to external monitor
    for ws in $(hyprctl workspaces -j | jq -r '.[] | select(.monitor == "eDP-1") | .id' 2>/dev/null); do
        hyprctl dispatch moveworkspacetomonitor "$ws" HDMI-A-1 2>&1 | tee -a "$LOGFILE" >/dev/null
    done

    # Now disable the laptop monitor
    hyprctl keyword monitor "eDP-1,disable" 2>&1 | tee -a "$LOGFILE" >/dev/null
    notify-send -u normal -t 3000 "🖥️ Laptop Monitor Disabled" "Using external monitor only"
    log_event "RESULT: Laptop monitor disabled"
else
    # Laptop is disabled - enable it
    log_event "ACTION: Enabling laptop monitor at position 0x1152"
    hyprctl keyword monitor "eDP-1,1920x1080@60,0x1152,1.0" 2>&1 | tee -a "$LOGFILE" >/dev/null
    notify-send -u normal -t 3000 "🖥️ Laptop Monitor Enabled" "Dual monitor mode"
    log_event "RESULT: Laptop monitor enabled at 0x1152"
fi

log_event "COMPLETE: Toggle finished"
