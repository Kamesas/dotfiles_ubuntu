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

### 3. Dropdown terminals (kitty + wezterm) — DONE 2026-06-19
- [x] Update `kitty-dropdown` — detect Sway via `$SWAYSOCK`, use `swaymsg [app_id=...]
      scratchpad show` there instead of `xdotool`. GNOME branch untouched.
- [x] Update `wezterm-dropdown` — same idea, but see note below: WezTerm still runs
      under XWayland on Sway too, matched via `[class=...]` instead of `[app_id=...]`.
- [x] Remove `linux_display_server x11` from `kitty/dropdown.conf` — safe because the
      GNOME script already force-unsets `WAYLAND_DISPLAY` before launching kitty, so
      it falls back to X11 there regardless; on Sway it now picks native Wayland.
- [x] `sway/config` — `for_window` rules float both dropdowns, size them
      `100 ppt x 100 ppt` (fills the workspace area, Waybar stays visible since ppt
      sizing excludes the bar), then `move scratchpad, scratchpad show` so they're
      shown/hidden by class/app_id instead of living on a workspace.
- [x] Test both dropdowns work in Sway AND still work in GNOME (kitty path verified
      live; wezterm GNOME path unchanged except window class, not yet re-tested live)

**Note:** the installed `wezterm` (20240203, latest in Arch's `extra` repo) crashes
on native Sway Wayland windows — `[wayland-client error] Attempted to dispatch
unknown opcode 0 for wl_shm, aborting.` Reproduces even with a bare
`wezterm start -- true`, no custom config involved. Worked around by keeping
WezTerm on XWayland on Sway too (same as GNOME), just toggled via
`swaymsg [class="wezterm-dropdown"] scratchpad show` instead of `xdotool`. If this
ever gets fixed upstream (or by moving to `wezterm-nightly` from AUR), the native
path would mirror kitty's: `--class` flag, `[app_id=...]` criteria, no forced X11.

### 4. Rofi
- [x] On GNOME, Mutter doesn't support the wlr-layer-shell protocol, so Rofi's native
      Wayland mode crashes there — the GNOME keybinding forces XWayland with
      `env WAYLAND_DISPLAY= DISPLAY=:0 XDG_SESSION_TYPE=x11 rofi -show drun -steal-focus`.
- [x] `-steal-focus` is needed too: under GNOME/XWayland, Mutter doesn't hand Rofi's
      window keyboard focus on its own, so typing/Escape did nothing without it.
- [x] Apps launched *from* Rofi inherit that forced environment too. Without
      `XDG_SESSION_TYPE=x11`, Chrome (and likely other apps that check session type to
      pick a display backend) tried Wayland anyway, found no socket, and exited instantly
      instead of falling back to X11 — looked like it briefly flashed open then vanished.
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
- [ ] Open the Claude tab in Chrome, check GPU% in btop — compare against the Sway
      number below to see if it's a Sway/wlroots throttling issue or just the site

---

## Notes / Issues

- **Waybar symlinks were broken since install, 2026-06-11 → fixed 2026-06-19:**
  `~/.config/waybar/config` and `style.css` had one extra `../` in their relative
  symlink target (pointing at `/home/dotfiles/...` instead of `/home/alex/dotfiles/...`),
  so they silently resolved to nothing and Waybar fell back to
  `/etc/xdg/waybar/config.jsonc` the whole time — no Waybar customization (colors,
  icons, layout) was ever actually visible. Not a stow bug (generic `stow -R waybar`
  produces the correct 2-level path); looks like a one-off manual `ln -s` mistake.
  Fixed by removing the broken links and running `stow -d ~/dotfiles -t ~ -R waybar`.
  If Waybar ever looks like it's ignoring config changes again, check
  `waybar -l info` output for "Using configuration file" — if it says
  `/etc/xdg/waybar/...` instead of `~/.config/waybar/...`, the symlink is broken again.

- **GPU usage on Sway, 2026-06-19:** with the Claude tab focused in Chrome, GPU freq
  spiked to 800-1100MHz (vs 300-550MHz with an empty tab focused) — confirmed live
  via `/sys/class/drm/card1/gt_cur_freq_mhz`. Likely a continuous animation in the
  site's UI keeping the renderer compositing non-stop. Not caused by the dropdown
  terminal changes (killed both kitty/wezterm dropdowns entirely and GPU still
  fluctuated the same way). Unconfirmed whether this is worse on Sway specifically
  (wlroots throttling background/animated tabs less aggressively than GNOME's
  Mutter) or just how the site behaves everywhere — see checklist item above.

---

## Rollback

If something breaks in GNOME:
1. Log into GNOME session
2. Check which script changed last in `git log --oneline dotfiles/`
3. Revert with `git revert <commit>`
4. Or restore single file: `git checkout <commit> -- path/to/file`
