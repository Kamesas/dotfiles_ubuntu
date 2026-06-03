# Setup Guide

This repo holds my config files (dotfiles). It uses **GNU Stow** to make links from this repo
into my home folder. So I edit a file here once, and it works everywhere.

You can set things up two ways: **all at once**, or **one piece at a time**.

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
