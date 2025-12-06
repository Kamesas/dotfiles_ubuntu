# Quick Setup Guide

## Step-by-Step Instructions

### Step 1: Install GNU Stow

```bash
sudo apt install stow
```

### Step 2: Migrate Your Existing Dotfiles

This will copy your current dotfiles into the proper Stow structure:

```bash
cd ~/dotfiles
./migrate-to-stow.sh
```

**What this does:**
- Creates a backup of all current dotfiles
- Organizes your configs into Stow packages
- Preserves all your existing configurations

### Step 3: Review the Structure

```bash
cd ~/dotfiles
ls -la
```

You should see packages like:
- `bash/` - Your shell configs
- `git/` - Git configuration
- `nvim/` - Neovim setup
- `tmux/` - Tmux configuration
- etc.

### Step 4: Install with Stow

```bash
./install.sh
```

**What this does:**
- Creates a backup (stored in `~/.dotfiles-backups/`)
- Removes your old dotfiles
- Creates symlinks from `~/dotfiles/` to your home directory

### Step 5: Verify Installation

```bash
./install.sh status
```

Check that your dotfiles are now symlinks:

```bash
ls -la ~/.bashrc
# Should show: ~/.bashrc -> /home/alex/dotfiles/bash/.bashrc
```

### Step 6: Commit to Git

```bash
cd ~/dotfiles
git add -A
git commit -m "Restructure dotfiles for GNU Stow"
git push
```

## How to Use After Setup

### Edit Your Configs

Just edit files in `~/dotfiles/` as normal:

```bash
cd ~/dotfiles
nvim bash/.bashrc
# Changes are immediately active because of symlinks!
```

### Sync to Another Machine

```bash
# On the new machine
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
```

### Add New Configs

```bash
# Example: Add alacritty config
cd ~/dotfiles
mkdir -p alacritty/.config/alacritty
cp ~/.config/alacritty/alacritty.yml alacritty/.config/alacritty/
stow alacritty
git add alacritty
git commit -m "Add alacritty config"
```

## Daily Workflow

1. **Make changes:**
   ```bash
   nvim ~/dotfiles/nvim/.config/nvim/init.lua
   ```

2. **Test changes:**
   Changes are live immediately due to symlinks

3. **Commit:**
   ```bash
   cd ~/dotfiles
   git add -A
   git commit -m "Update nvim config"
   git push
   ```

## Backup System

### Create Backup Before Major Changes

```bash
./backup.sh create
```

### List All Backups

```bash
./backup.sh list
```

### Restore from Backup

```bash
./backup.sh restore backup_20240101_120000
```

## Troubleshooting

### Problem: Stow Shows Conflicts

**Solution:**
```bash
./backup.sh create
rm ~/.bashrc  # Remove conflicting file
stow bash     # Try again
```

### Problem: Changes Not Reflected

**Check if symlink exists:**
```bash
ls -la ~/.bashrc
```

If not a symlink:
```bash
cd ~/dotfiles
stow -R bash  # Restow
```

### Problem: Want to Undo Everything

**Restore original files:**
```bash
./backup.sh list
./backup.sh restore backup_YYYYMMDD_HHMMSS
```

Or uninstall all:
```bash
./install.sh uninstall
```

## For Niri Installation

When you install Niri later:

1. **Your dotfiles will keep working** - Stow symlinks work with any window manager

2. **Add Niri config to dotfiles:**
   ```bash
   mkdir -p ~/dotfiles/niri/.config/niri
   # Copy your Niri config when ready
   stow niri
   ```

3. **All your terminal/shell configs stay the same** - No changes needed!

## Tips

- Backup before major changes: `./backup.sh`
- Check symlink status: `./install.sh status`
- Commit often to track changes
- Test configs before pushing to Git

---

Need help? Check the main [README.md](README.md) for detailed documentation.
