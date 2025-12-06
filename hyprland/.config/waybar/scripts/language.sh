#!/bin/bash
# Get current keyboard layout and display it in short format
# This script monitors layout changes continuously

get_layout() {
    layout=$(hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap')
    
    case "$layout" in
        "English (US)")
            echo "EN"
            ;;
        "Ukrainian")
            echo "UK"
            ;;
        *)
            echo "${layout:0:2}"
            ;;
    esac
}

# Print initial layout
current=$(get_layout)
echo "$current"

# Continuously monitor for changes
while true; do
    new=$(get_layout)
    if [[ "$new" != "$current" ]]; then
        echo "$new"
        current="$new"
    fi
    sleep 0.2
done
