 Hyprland Configuration

Omarchy-inspired Hyprland setup for Ubuntu 24.04 with Waybar.

## What's Included

- **Hyprland** - Tiling Wayland compositor configuration
- **Waybar** - Status bar with Omarchy-style minimal design
- **Scripts** - Custom scripts for show desktop, monitor management, and language indicator

## Features

### Hyprland Config
- Dual monitor support (laptop + external 2K display)
- Omarchy-style cyan/green gradient borders
- Natural touchpad scrolling
- Keyboard layouts: English (US) and Ukrainian (switch with Super+Space)
- Custom show desktop functionality (Super+D)
- 5 persistent workspaces

### Waybar
- Minimal, icon-based design matching Omarchy style
- Modules: workspaces, clock, language indicator, network, volume, CPU, memory, battery, tray
- Real-time language indicator (EN/UK)
- Clock format: `HH:MM  Day DD Mon` (e.g., "22:30  Saturday 06 Dec")

### Custom Scripts
- `show-desktop.sh` - Toggle hide/show all windows (Super+D)
- `language.sh` - Real-time keyboard layout indicator for Waybar
- `disable-laptop.sh` - Disable laptop screen (Super+F7)
- `enable-laptop.sh` - Enable laptop screen (Super+F8)

## Key Bindings

| Keys | Action |
|------|--------|
| Super+Q | Open terminal (WezTerm) |
| Super+W | Close window |
| Super+E | File manager (Yazi) |
| Super+D | Show desktop (toggle) |
| Super+F | Fullscreen |
| Super+Space | Switch keyboard layout (EN/UK) |
| Super+Arrow | Move focus |
| Super+Shift+Arrow | Swap windows |
| Super+1-9,0 | Switch to workspace |
| Super+Shift+1-9,0 | Move window to workspace |
| Super+Tab | Next workspace |
| Super+Shift+Tab | Previous workspace |
| Alt+R | Rofi launcher |
| Alt+U | Ulauncher |
| Alt+Tab | Cycle windows |
| Print | Screenshot selection to clipboard |
| Shift+Print | Screenshot selection to file |
| Super+F7 | Disable laptop screen |
| Super+F8 | Enable laptop screen |

## Installation

From your dotfiles directory:

```bash
# Backup existing configs
mv ~/.config/hypr ~/.config/hypr.backup
mv ~/.config/waybar ~/.config/waybar.backup

# Copy configs
cp -r hyprland/.config/hypr ~/.config/
cp -r hyprland/.config/waybar ~/.config/

# Make scripts executable
chmod +x ~/.config/hypr/scripts/*.sh
chmod +x ~/.config/waybar/scripts/*.sh

# Reload Hyprland
hyprctl reload
```

## Dependencies

Required packages:
- hyprland
- waybar
- wezterm (terminal)
- rofi (launcher)
- ulauncher (application launcher)
- mako (notifications)
- swww or swaybg (wallpaper)
- grim, slurp, wl-clipboard (screenshots)
- brightnessctl (brightness control)
- playerctl (media controls)
- pavucontrol (audio control)
- jq (for language script)

## Customization

### Change Wallpaper
Edit `~/.config/hypr/hyprland.conf` line 35:
```conf
$wallpaper = ~/Pictures/Wallpapers/your-wallpaper.jpg
```

### Adjust Monitor Scaling
Edit monitor settings in `hyprland.conf` lines 17-21

### Modify Waybar Modules
Edit `~/.config/waybar/config` to add/remove/reorder modules

### Change Colors
Edit `~/.config/waybar/style.css` for Waybar colors
Edit `hyprland.conf` lines 92-93 for border colors

## Notes

- Touchpad uses natural scrolling (swipe down = scroll down)
- Super+D creates a special workspace to hide/show windows per workspace
- Language indicator updates in real-time (checks every 0.2s)
- Persistent workspaces 1-5 always visible in Waybar
- Window opacity: active=1.0, inactive=0.9
