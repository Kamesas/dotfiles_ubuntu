# Sway Setup

Goal: install Sway alongside GNOME. Both sessions work independently.
Scripts detect `$WAYLAND_DISPLAY` and behave correctly in each environment.

## Status: in progress

---

## Steps

### 1. Install Sway
- [ ] `sudo pacman -S sway swaybar swaybg swaylock swaynag waybar`
- [ ] `sudo pacman -S wofi` (app launcher, replaces Ulauncher hotkey in Sway)
- [ ] `sudo pacman -S wl-clipboard` (replaces xclip on Wayland)
- [ ] `sudo pacman -S grim slurp` (screenshot tools, replaces Flameshot on Wayland)
- [ ] Verify Sway session appears at GDM login screen

### 2. Basic Sway config
- [ ] Create `dotfiles/sway/.config/sway/config`
- [ ] Set mod key, terminal, basic keybindings
- [ ] Autostart: copyq, ulauncher, waybar

### 3. Dropdown terminals (kitty + wezterm)
- [ ] Update `kitty-dropdown` — detect Wayland, use `swaymsg` instead of `xdotool`
- [ ] Update `wezterm-dropdown` — same
- [ ] Remove `linux_display_server x11` from `kitty/dropdown.conf` (auto-detect)
- [ ] Remove `WAYLAND_DISPLAY= DISPLAY=:0` from wezterm autostart
- [ ] Test both dropdowns work in Sway AND still work in GNOME

### 4. Ulauncher
- [ ] Update `ulauncher-toggle` — detect Wayland, use `swaymsg` for workspace move
- [ ] Update `ulauncher-start` — remove X11-specific flags if not needed
- [ ] Test Ulauncher appears on correct workspace in Sway AND GNOME

### 5. Screenshots (Flameshot → grim+slurp on Wayland)
- [ ] Add Sway keybinding: `Print` → `grim -g "$(slurp)"` (region select)
- [ ] Keep Flameshot binding for GNOME sessions
- [ ] Verify clipboard works (wl-clipboard)

### 6. Verify GNOME still works
- [ ] Log into GNOME — all dropdowns work
- [ ] Ulauncher opens on correct workspace
- [ ] Flameshot works with Print Screen
- [ ] Ctrl+; works correctly in ToggleTerm

---

## Notes / Issues

<!-- Add problems and solutions here as we go -->

---

## Rollback

If something breaks in GNOME:
1. Log into GNOME session
2. Check which script changed last in `git log --oneline dotfiles/`
3. Revert with `git revert <commit>`
4. Or restore single file: `git checkout <commit> -- path/to/file`
