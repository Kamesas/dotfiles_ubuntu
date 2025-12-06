# GNOME Settings

This directory contains your GNOME desktop settings, particularly keybindings.

## Files

- `wm-keybindings.dconf` - Window manager keybindings
- `media-keys.dconf` - Media keys and custom shortcuts
- `shell-keybindings.dconf` - GNOME Shell keybindings
- `restore-keybindings.sh` - Script to restore all keybindings

## Your Custom Keybindings

### Window Management
- `Super+h` - Switch to workspace left
- `Super+l` - Switch to workspace right
- `Super+j` - Move window to workspace left
- `Super+k` - Move window to workspace right
- `Super+1/2/3/4` - Switch to workspace 1/2/3/4
- `Super+c` - Close window
- `Alt+a` - Activate window menu

### Applications
- `Super+t` - Terminal
- `Super+b` - Browser
- `Super+q` - Lock screen
- `Print` - Flameshot (screenshot)
- `Alt+6` - Toggle Tilix

## Usage

### Export Current Keybindings

```bash
cd ~/dotfiles/gnome-settings
dconf dump /org/gnome/desktop/wm/keybindings/ > wm-keybindings.dconf
dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > media-keys.dconf
dconf dump /org/gnome/shell/keybindings/ > shell-keybindings.dconf
```

### Restore Keybindings

```bash
cd ~/dotfiles/gnome-settings
./restore-keybindings.sh
```

Or manually:

```bash
dconf load /org/gnome/desktop/wm/keybindings/ < wm-keybindings.dconf
dconf load /org/gnome/settings-daemon/plugins/media-keys/ < media-keys.dconf
dconf load /org/gnome/shell/keybindings/ < shell-keybindings.dconf
```

## Note

Unlike other dotfiles, GNOME settings are NOT managed by Stow (they're not files, but dconf database entries). Instead:

1. Export settings to `.dconf` files (already done)
2. Commit to git
3. On new machine, run `./restore-keybindings.sh`

## When Switching to Niri

When you switch to Niri, these GNOME keybindings won't apply (Niri has its own config). You'll configure keybindings in your Niri config file instead.
