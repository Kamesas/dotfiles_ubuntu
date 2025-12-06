#!/bin/bash

# First, focus the external monitor to avoid being stuck on laptop screen
hyprctl dispatch focusmonitor HDMI-A-1

# Move all workspaces from laptop to external monitor
for ws in $(hyprctl workspaces -j | jq -r '.[] | select(.monitor == "eDP-1") | .id'); do
    hyprctl dispatch moveworkspacetomonitor "$ws" HDMI-A-1
done

# Now disable the laptop monitor
hyprctl keyword monitor "eDP-1, disable"
