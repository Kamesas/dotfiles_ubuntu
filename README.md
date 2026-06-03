# Dotfiles

My personal config files, managed with [GNU Stow](https://www.gnu.org/software/stow/).
Stow makes symlinks from this repo into my home folder, so I edit a file here once and it
works everywhere.

**New here? Start with [SETUP-GUIDE.md](SETUP-GUIDE.md)** — the short, step-by-step setup.

## What's inside

**Stow packages** (linked into home by `./install.sh`):

| Package | What it is |
|---------|------------|
| `bash` | shell config (`.bashrc`, `.profile`) |
| `git` | git config (`.gitconfig`, `.gitmessage`) |
| `tmux` | tmux config |
| `wezterm` | WezTerm terminal |
| `misc` | small dotfiles (`.dircolors`) |
| `fish`, `btop`, `flameshot`, `kanata` | optional tools |

**Manual links** (Stow can't manage these — see below):

| Link | What it is |
|------|------------|
| `~/.config/nvim` → `nvim/` | Neovim config (whole folder) |
| `~/.claude/CLAUDE.md` → `.claude/CLAUDE.md` | Claude Code rules |

## Install

Everything at once:

```bash
sudo apt install stow
git clone git@github.com:Kamesas/dotfiles_ubuntu.git ~/dotfiles
cd ~/dotfiles
./install.sh          # backs up, stows packages, and creates the manual links
```

One piece at a time:

```bash
./install.sh install bash    # one Stow package (same as: stow bash)
./install.sh links           # just the manual links (nvim, Claude)
./install.sh list            # show all packages
./install.sh status          # show what's linked
```

Full steps and the second-laptop flow are in [SETUP-GUIDE.md](SETUP-GUIDE.md).

## Stow packages vs manual links

- **Stow package** — a folder laid out like home, e.g. `bash/.bashrc` → `~/.bashrc`, or
  `tmux/.config/tmux/...` → `~/.config/tmux/...`. `stow bash` makes the links.
- **Manual link** — something Stow can't manage cleanly:
  - `nvim/` is a flat folder, so it's linked as one whole dir to `~/.config/nvim`.
  - `CLAUDE.md` must sit inside `~/.claude/` next to private files, so we link just that file.

  `./install.sh links` (also part of `./install.sh`) creates these.

## Edit and save

Edit any file in `~/dotfiles/`. The change is live right away (symlinks).

```bash
cd ~/dotfiles
git add -A
git commit -m "Update configs"
git push
```

## Backup

`install.sh` makes a backup before it runs. You can also do it by hand:

```bash
./backup.sh create            # make a backup
./backup.sh list              # list backups
./backup.sh restore <name>    # restore one
```

Backups live in `~/.dotfiles-backups/`.

## If something breaks

- **Stow says "conflict"** — a real file is in the way:
  ```bash
  ./backup.sh create && rm ~/.bashrc && stow bash
  ```
- **A change is not showing** — check and re-link:
  ```bash
  ls -la ~/.bashrc      # should point into ~/dotfiles
  stow -R bash
  ```
- **A manual link is missing** — `./install.sh links`
- **Undo all Stow links** — `./install.sh uninstall`

## Add a new config

```bash
cd ~/dotfiles
mkdir -p newapp/.config/newapp
cp ~/.config/newapp/config newapp/.config/newapp/
stow newapp
git add newapp && git commit -m "Add newapp config" && git push
```
