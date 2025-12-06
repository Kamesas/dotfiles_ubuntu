#!/bin/bash

#######################################
# Restore GNOME Keybindings
# Loads keybindings from dconf files
#######################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Restoring GNOME keybindings..."

if [ -f "$SCRIPT_DIR/wm-keybindings.dconf" ]; then
    dconf load /org/gnome/desktop/wm/keybindings/ < "$SCRIPT_DIR/wm-keybindings.dconf"
    echo "✓ Window manager keybindings restored"
fi

if [ -f "$SCRIPT_DIR/media-keys.dconf" ]; then
    dconf load /org/gnome/settings-daemon/plugins/media-keys/ < "$SCRIPT_DIR/media-keys.dconf"
    echo "✓ Media keys restored"
fi

if [ -f "$SCRIPT_DIR/shell-keybindings.dconf" ]; then
    dconf load /org/gnome/shell/keybindings/ < "$SCRIPT_DIR/shell-keybindings.dconf"
    echo "✓ Shell keybindings restored"
fi

echo ""
echo "Keybindings restored successfully!"
echo "You may need to log out and back in for all changes to take effect."
