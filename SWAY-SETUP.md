# Sway Setup

Sway on Ubuntu, next to GNOME. Pick the session on the GDM login screen
(gear icon: "Sway" or "Ubuntu").

## Status: working — Ubuntu 26.04, Sway 1.11 (2026-09-26)

---

## Install

```bash
sudo apt install sway swaybg swayidle swaylock waybar mako-notifier rofi wlogout \
    grim slurp swappy wl-clipboard cliphist libnotify-bin \
    blueman udiskie mate-polkit brightnessctl wireplumber pulseaudio-utils \
    imagemagick jq kitty stow
```

- WezTerm is not in Ubuntu's repo. Add its apt repo (`apt.fury.io/wez`, steps on
  wezterm.org), then `sudo apt install wezterm`.
- `wl-mirror` is left out. Only the projector "mirror" option in Alt+s needs it.

Then link the configs:

```bash
cd ~/dotfiles
stow sway swaylock waybar mako rofi kitty wlogout bin
```

Brightness keys need the `video` group (then log out and back in):

```bash
sudo usermod -aG video $USER
```

Wallpapers: put images in `~/Pictures/Wallpapers`, then pick one with Alt+o.
The images are not in this repo. The current ones are from
`github.com/zhichaoh/catppuccin-wallpapers` (MIT license, `landscapes/` folder).

---

## Differences from the Arch setup

- Wallpaper: `swaybg` instead of `awww` (no Ubuntu package). `wallpaper-menu`
  links the pick to `~/.local/state/wallpaper`, and the sway config loads that link.
- Polkit agent path: `/usr/libexec/polkit-mate-authentication-agent-1`.
- Screenshot (Print): plain `grim` + `slurp` + `swappy`, no `wayfreeze`.
- Dictation removed.

---

## Open items

- [ ] Log into GNOME and check it still works (dropdowns, Rofi, Flameshot).

---

## Notes

- **WezTerm runs under XWayland on Sway.** Version 20240203 crashes on native
  Wayland (`Attempted to dispatch unknown opcode 0 for wl_shm`). So
  `wezterm-dropdown` matches it with `[class=...]`, not `[app_id=...]`.
  Kitty runs native Wayland and uses `[app_id=...]`.
- **Rofi on GNOME needs XWayland.** GNOME has no layer-shell support, so the GNOME
  keybinding forces X11 (see `SETUP-GUIDE.md`). On Sway, plain `rofi -show drun` works.
- **Waybar ignores config changes?** Run `waybar -l info` and look at
  "Using configuration file". If it says `/etc/xdg/waybar/...`, the link in
  `~/.config/waybar` is broken. Fix: `stow -R waybar`.

---

## Rollback

If something breaks in GNOME:
1. Log into GNOME session
2. Check which script changed last: `git log --oneline`
3. Revert with `git revert <commit>`
4. Or restore one file: `git checkout <commit> -- path/to/file`
