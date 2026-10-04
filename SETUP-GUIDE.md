# Setup Guide

This repo holds my config files (dotfiles). It uses **GNU Stow** to make links from this repo
into my home folder. So I edit a file here once, and it works everywhere.

You can set things up two ways: **all at once**, or **one piece at a time**.

---

## Required system packages

These packages are not installed by `install.sh` — install them manually on a new machine.

```bash
sudo pacman -S xclip copyq wmctrl xdotool flameshot
```

| Package | Why |
|---------|-----|
| `xclip` | Claude Code needs it to read images from clipboard (Ctrl+V image paste) |
| `copyq` | Clipboard manager — keeps clipboard alive after Flameshot closes |
| `wmctrl` | Window management used by launcher scripts |
| `xdotool` | Window/keyboard automation used by dropdown terminal scripts |
| `flameshot` | Screenshot tool (Print Screen key) |

### App launcher (Alt+U): Ulauncher or Rofi

Pick one, depending on the machine:

- **Ulauncher** (`sudo pacman -S ulauncher`) — full launcher with extensions (translate,
  clipboard, etc). Used on Ubuntu/HP.
- **Rofi** (`sudo pacman -S rofi`) — no extensions, but starts fresh each time instead of
  staying resident in the background. Used on the Arch/T480 GNOME-on-Wayland setup:
  Ulauncher's clipboard-watching extension leaked thousands of X11 windows there, and
  Rofi avoids the whole problem by not running as a background process. Two more things
  the keybinding below works around: Rofi's native Wayland mode crashes under GNOME
  (Mutter doesn't support wlr-layer-shell), so it forces XWayland with
  `WAYLAND_DISPLAY= DISPLAY=:0`; and apps launched from Rofi inherit that same forced
  environment, which makes Chrome (and likely other apps that read `XDG_SESSION_TYPE` to
  pick their display backend) crash instead of falling back to X11 — also forcing
  `XDG_SESSION_TYPE=x11` keeps the whole environment consistent so they start normally.

### Brightness keys (Sway)

`brightnessctl` needs write access to the screen backlight. Add your user to the
`video` group, then log out and back in:

```bash
sudo usermod -aG video $USER
```

Without it, the brightness popup shows but the level does not change.

---

## GNOME settings (manual, stored in dconf)

These are not in dotfiles — run once after a fresh install.

```bash
# Let Flameshot own the Print Screen key (remove GNOME's built-in screenshot)
gsettings set org.gnome.shell.keybindings show-screenshot-ui "[]"

# Custom keybindings
base="org.gnome.settings-daemon.plugins.media-keys"
path="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings"

gsettings set $base.custom-keybinding:$path/custom0/ name    'WezTerm dropdown'
gsettings set $base.custom-keybinding:$path/custom0/ command '/home/alex/.local/bin/wezterm-dropdown'
gsettings set $base.custom-keybinding:$path/custom0/ binding '<Alt>w'

gsettings set $base.custom-keybinding:$path/custom1/ name    'Kitty dropdown'
gsettings set $base.custom-keybinding:$path/custom1/ command '/home/alex/.local/bin/kitty-dropdown'
gsettings set $base.custom-keybinding:$path/custom1/ binding '<Alt>t'

gsettings set $base.custom-keybinding:$path/custom2/ name    'Flameshot'
gsettings set $base.custom-keybinding:$path/custom2/ command 'flameshot gui'
gsettings set $base.custom-keybinding:$path/custom2/ binding 'Print'

# Pick the command matching the launcher you installed above:
gsettings set $base.custom-keybinding:$path/custom3/ name    'Ulauncher toggle'
gsettings set $base.custom-keybinding:$path/custom3/ command '/home/alex/.local/bin/ulauncher-toggle'
# or, for Rofi:
# gsettings set $base.custom-keybinding:$path/custom3/ name    'Rofi launcher'
# gsettings set $base.custom-keybinding:$path/custom3/ command 'env WAYLAND_DISPLAY= DISPLAY=:0 XDG_SESSION_TYPE=x11 rofi -show drun -steal-focus'
gsettings set $base.custom-keybinding:$path/custom3/ binding '<Alt>u'

gsettings set $base custom-keybindings "['$path/custom0/', '$path/custom1/', '$path/custom2/', '$path/custom3/']"
```

---

## First: install Stow and get the repo

```bash
sudo apt install stow
git clone git@github.com:Kamesas/dotfiles_ubuntu.git ~/dotfiles
cd ~/dotfiles
```

---

## Option A — set up everything at once

```bash
cd ~/dotfiles
./install.sh
```

This makes a backup, links all Stow packages (bash, git, tmux, and the rest) into your home
folder, and creates the manual links (nvim and Claude). One command does it all.

---

## Option B — set up one piece at a time

Install just one package:

```bash
cd ~/dotfiles
./install.sh install bash        # or git, tmux, ... any name from the list
./install.sh list                # show all packages
```

Or use Stow directly:

```bash
stow bash        # link it
stow -D bash     # unlink it
stow -R bash     # re-link it
```

---

## Manual links (nvim and Claude)

Two things are linked by hand, not by Stow:
- `~/.config/nvim` → `nvim/` (the whole Neovim folder)
- `~/.claude/CLAUDE.md` → `.claude/CLAUDE.md` (the Claude Code rules)

`./install.sh` already creates these. To make just these links on their own:

```bash
./install.sh links
```

If a real file is already in the way, remove it first, then run the command again.

**On a second laptop:**

```bash
cd ~/dotfiles && git pull
./install.sh            # or just the links: ./install.sh links
```

After that, Claude on that laptop uses the same rules. Your private Claude files (chat history,
tokens, saved memory) stay out of git on purpose.

---

## ESP32 / PlatformIO development

What to do on a new machine. Editor keys and troubleshooting are in
`nvim/Platformio.md`.

**1. Install the PlatformIO CLI:**

```bash
pipx install platformio     # puts `pio` in ~/.local/bin
```

**2. Link the clangd config:**

```bash
cd ~/dotfiles && stow clangd
```

This links `~/.config/clangd/config.yaml`. It removes GCC-only flags that clang
rejects. Without it, clangd shows "Unknown argument" and cannot find system headers.

**3. Start Neovim.** Mason installs clangd. `nvim/lua/plugins/clangd.lua`
already has the `--query-driver` option for the ESP32 compilers.

**4. In each project, build once and make the clangd database:**

```bash
cd <project>
pio run                # downloads toolchain, framework and libraries
pio run -t compiledb   # writes compile_commands.json for clangd
```

Or in Neovim: `<leader>pi` (`:PioLSP`).

Do this even if the project already has a `compile_commands.json`. A copy from
another machine has wrong paths.

Notes:

- `~/.platformio/` and `<project>/.pio/` are only download caches. Do not copy
  them to a new machine. `pio run` downloads them again.
- If upload fails with "permission denied", add yourself to the serial group,
  then log out and in: `sudo usermod -aG dialout $USER` on Ubuntu, `uucp` on Arch.

---

## Edit and save your changes

Edit any file inside `~/dotfiles/`. Because of the links, the change is live right away.

To save and sync to git:

```bash
cd ~/dotfiles
git add -A
git commit -m "Update configs"
git push
```

---

## If something breaks

- **Stow says "conflict":** a real file is in the way. Back it up, remove it, link again.
  ```bash
  ./backup.sh create
  rm ~/.bashrc
  stow bash
  ```
- **A change is not showing:** check the link, then re-link.
  ```bash
  ls -la ~/.bashrc      # should point into ~/dotfiles
  stow -R bash
  ```
- **Undo everything:** `./install.sh uninstall`

More detail is in [README.md](README.md).
