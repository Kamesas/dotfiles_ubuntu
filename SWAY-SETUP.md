# Sway Setup

Goal: install Sway alongside GNOME. Both sessions work independently.
Scripts detect `$WAYLAND_DISPLAY` and behave correctly in each environment.

## Status: in progress — stopped after session 2026-06-11

---

## Steps

### 1. Install Sway
- [x] `sudo pacman -S sway swaylock waybar wofi wl-clipboard grim slurp`
- [ ] Verify Sway session appears at GDM login screen

### 2. Basic Sway config
- [x] Create `dotfiles/sway/.config/sway/config`
- [x] Catppuccin Mocha colors, gaps, borders
- [x] Autostart: copyq, waybar
- [x] Symlinked to `~/.config/sway/config`
- [x] Keybindings: Super+h/l focus left/right, Super+j/k move window to next/prev workspace
- [x] Waybar: persistent workspaces 1–5
- [x] `for_window [app_id=".*"] border pixel 2` added to suppress title bars

## Pending before next session

- [ ] Confirm title bars are gone (Super+Shift+C reload, then open a fresh kitty window)
- [ ] Run `pkill waybar` to pick up the persistent workspaces config (waybar doesn't reload on sway reload)
- [ ] Check waybar shows workspaces 1–5 after pkill

### 3. Dropdown terminals (kitty + wezterm)
- [ ] Update `kitty-dropdown` — detect Wayland, use `swaymsg` instead of `xdotool`
- [ ] Update `wezterm-dropdown` — same
- [ ] Remove `linux_display_server x11` from `kitty/dropdown.conf` (auto-detect)
- [ ] Remove `WAYLAND_DISPLAY= DISPLAY=:0` from wezterm autostart
- [ ] Test both dropdowns work in Sway AND still work in GNOME

### 4. Rofi
- [x] On GNOME, Mutter doesn't support the wlr-layer-shell protocol, so Rofi's native
      Wayland mode crashes there — the GNOME keybinding forces XWayland with
      `env WAYLAND_DISPLAY= DISPLAY=:0 rofi -show drun -steal-focus`.
- [x] `-steal-focus` is needed too: under GNOME/XWayland, Mutter doesn't hand Rofi's
      window keyboard focus on its own, so typing/Escape did nothing without it.
- [ ] On Sway (wlroots, has layer-shell), check whether `-steal-focus` is still needed
      — Sway may focus new windows correctly on its own, making it redundant there.
      Keep the plain `rofi -show drun` already in `sway/config` unless testing shows
      otherwise; don't copy the GNOME env override, it would disable the native
      rendering Sway actually supports.
- [ ] Test Alt+u opens Rofi in Sway AND GNOME

### 5. Screenshots (Flameshot → grim+slurp on Wayland)
- [ ] Add Sway keybinding: `Print` → `grim -g "$(slurp)"` (region select)
- [ ] Keep Flameshot binding for GNOME sessions
- [ ] Verify clipboard works (wl-clipboard)

### 6. Verify GNOME still works
- [ ] Log into GNOME — all dropdowns work
- [ ] Rofi opens correctly
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
