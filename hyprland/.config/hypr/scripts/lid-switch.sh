#!/bin/bash

# ============================================================================
# HYPRLAND LID SWITCH HANDLER
# ============================================================================
# Automatically enables/disables laptop monitor based on lid state
# - Lid closed + external monitor: Disable laptop screen
# - Lid open + external monitor: Enable laptop screen at proper position
# - No external monitor: Always keep laptop screen enabled (safety)
#
# Features:
# - Desktop notifications for user feedback
# - Logging to /tmp/hypr-lid-switch.log for debugging
# - Debounce logic to prevent rapid re-triggering
# - Smart positioning based on monitor setup
# ============================================================================

LOGFILE="/tmp/hypr-lid-switch.log"
LOCKFILE="/tmp/hypr-lid-switch.lock"
MAX_LOG_LINES=100

# Function to log with timestamp
log_event() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$LOGFILE"
    
    # Rotate log if it gets too large (keep last MAX_LOG_LINES)
    if [ -f "$LOGFILE" ]; then
        local line_count=$(wc -l < "$LOGFILE")
        if [ "$line_count" -gt "$MAX_LOG_LINES" ]; then
            tail -n "$MAX_LOG_LINES" "$LOGFILE" > "${LOGFILE}.tmp"
            mv "${LOGFILE}.tmp" "$LOGFILE"
        fi
    fi
}

# Debounce - prevent rapid re-triggering
if [ -f "$LOCKFILE" ]; then
    # Check if lockfile is older than 2 seconds
    if [ $(($(date +%s) - $(stat -c %Y "$LOCKFILE"))) -lt 2 ]; then
        log_event "DEBOUNCE: Skipping (lockfile less than 2s old)"
        exit 0
    fi
fi
touch "$LOCKFILE"

# Get current lid state
LID_STATE=$(cat /proc/acpi/button/lid/*/state 2>/dev/null | grep -o "open\|closed")

if [ -z "$LID_STATE" ]; then
    log_event "ERROR: Could not read lid state from /proc/acpi/button/lid/*/state"
    rm -f "$LOCKFILE"
    exit 1
fi

# Check if external monitor is connected
EXTERNAL_MONITOR_CONNECTED=false
if hyprctl monitors 2>/dev/null | grep -q "HDMI-A-1"; then
    EXTERNAL_MONITOR_CONNECTED=true
fi

log_event "LID_STATE=$LID_STATE | EXTERNAL_MONITOR=$EXTERNAL_MONITOR_CONNECTED | Starting lid switch handler"

# Handle lid state changes
if [ "$EXTERNAL_MONITOR_CONNECTED" = true ]; then
    # External monitor connected - disable laptop screen when lid closes
    if [ "$LID_STATE" = "closed" ]; then
        log_event "ACTION: Disabling eDP-1 (lid closed, external monitor present)"
        hyprctl keyword monitor "eDP-1,disable" 2>&1 | tee -a "$LOGFILE" >/dev/null
        notify-send -u normal -t 3000 "🖥️ Laptop Screen Disabled" "External monitor active"
        log_event "RESULT: eDP-1 disabled successfully"
    else
        log_event "ACTION: Enabling eDP-1 at position 0x1152 (lid open, external monitor present)"
        hyprctl keyword monitor "eDP-1,1920x1080@60,0x1152,1.0" 2>&1 | tee -a "$LOGFILE" >/dev/null
        notify-send -u normal -t 3000 "🖥️ Laptop Screen Enabled" "Dual monitor mode"
        log_event "RESULT: eDP-1 enabled at 0x1152 successfully"
    fi
else
    # No external monitor - keep laptop screen on even if lid is closed
    log_event "ACTION: Ensuring eDP-1 enabled at 0x0 (no external monitor)"
    hyprctl keyword monitor "eDP-1,1920x1080@60,0x0,1.0" 2>&1 | tee -a "$LOGFILE" >/dev/null
    log_event "RESULT: eDP-1 enabled at 0x0 (standalone mode)"
fi

# Clean up old lockfile after 3 seconds
(sleep 3 && rm -f "$LOCKFILE") &

log_event "COMPLETE: Lid switch handler finished"
