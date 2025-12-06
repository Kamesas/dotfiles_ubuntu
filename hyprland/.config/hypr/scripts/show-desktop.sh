#!/bin/bash
# Toggle show desktop - minimizes all windows on current workspace or restores them

STATE_FILE="/tmp/hypr-desktop-toggle-state"

# Get current workspace ID
current_workspace=$(hyprctl activeworkspace -j | jq -r '.id')

# Check if we're in "desktop shown" state for this workspace
if [ -f "$STATE_FILE" ] && grep -q "^$current_workspace$" "$STATE_FILE"; then
    # Desktop is shown, restore windows
    # Move all windows from special:desktop back to current workspace
    while IFS= read -r addr; do
        hyprctl dispatch movetoworkspacesilent "$current_workspace,address:$addr"
    done < <(hyprctl clients -j | jq -r ".[] | select(.workspace.name == \"special:desktop\") | .address")
    
    # Remove workspace from state file
    sed -i "/^$current_workspace$/d" "$STATE_FILE"
else
    # Desktop is not shown, hide all windows
    # Move all windows from current workspace to special:desktop
    while IFS= read -r addr; do
        hyprctl dispatch movetoworkspacesilent "special:desktop,address:$addr"
    done < <(hyprctl clients -j | jq -r ".[] | select(.workspace.id == $current_workspace) | .address")
    
    # Mark this workspace as having desktop shown
    echo "$current_workspace" >> "$STATE_FILE"
fi
