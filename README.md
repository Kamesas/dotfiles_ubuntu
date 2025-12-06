# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [How It Works](#how-it-works)
- [Package Structure](#package-structure)
- [Usage](#usage)
- [Backup System](#backup-system)
- [Niri Compatibility](#niri-compatibility)
- [Troubleshooting](#troubleshooting)

## Overview

This repository contains configuration files (dotfiles) for various applications, managed using GNU Stow for easy deployment and synchronization across machines.

### What is GNU Stow?

GNU Stow is a symlink farm manager. It creates symbolic links from your dotfiles repository to your home directory, allowing you to:

- Keep all configs in one Git repository
- Easily sync configs across multiple machines
- Selectively enable/disable configurations
- Track changes with Git

### Repository Structure

```
~/dotfiles/
├── bash/           # Bash configuration (.bashrc, .profile)
├── git/            # Git configuration (.gitconfig)
├── nvim/           # Neovim configuration
├── tmux/           # Tmux configuration
├── wezterm/        # WezTerm terminal configuration
├── misc/           # Miscellaneous dotfiles (.dircolors, etc.)
├── fish/           # Fish shell (optional)
├── btop/           # System monitor (optional)
├── flameshot/      # Screenshot tool (optional)
├── kanata/         # Keyboard remapper (optional)
├── backup.sh       # Backup utility
├── install.sh      # Installation script
├── migrate-to-stow.sh  # Migration helper
└── README.md       # This file
```

## Quick Start

### First Time Setup

1. **Install GNU Stow:**
   ```bash
   sudo apt install stow
   ```

2. **Clone this repository** (if not already present):
   ```bash
   git clone <your-repo-url> ~/dotfiles
   cd ~/dotfiles
   ```

3. **Migrate existing dotfiles:**
   ```bash
   ./migrate-to-stow.sh
   ```

4. **Install all packages:**
   ```bash
   ./install.sh
   ```

### On a New Machine

1. **Install GNU Stow:**
   ```bash
   sudo apt install stow
   ```

2. **Clone your dotfiles:**
   ```bash
   git clone <your-repo-url> ~/dotfiles
   cd ~/dotfiles
   ```

3. **Install packages:**
   ```bash
   ./install.sh install
   ```

## How It Works

### The Magic of Stow

When you run `stow bash` from `~/dotfiles/`, Stow will:

1. Look inside the `bash/` directory
2. Find all files (e.g., `.bashrc`, `.profile`)
3. Create symbolic links in your home directory (`~/.bashrc` → `~/dotfiles/bash/.bashrc`)

**Example:**

```
Before Stow:
~/dotfiles/bash/.bashrc    (actual file)
~/.bashrc                  (old file)

After Stow:
~/dotfiles/bash/.bashrc    (actual file)
~/.bashrc                  → symlink to ~/dotfiles/bash/.bashrc
```

### Why Symlinks?

- **Instant updates:** Edit `~/dotfiles/bash/.bashrc` → changes immediately reflected in `~/.bashrc`
- **Git tracking:** All changes tracked in one repository
- **Easy sync:** Git push/pull to sync across machines

### Package Structure Rules

Each package follows this structure:

```
package-name/
├── .config/           # For XDG config files
│   └── app/
│       └── config.file
└── .dotfile           # For home directory dotfiles
```

**Example - nvim package:**
```
nvim/
└── .config/
    └── nvim/
        ├── init.lua
        └── lua/
```

When stowed, creates: `~/.config/nvim/` → `~/dotfiles/nvim/.config/nvim/`

## Usage

### Installation Script

The `install.sh` script provides easy management of your dotfiles.

#### Install All Packages

```bash
./install.sh
# or
./install.sh install
```

#### Install Specific Packages

```bash
./install.sh install bash git nvim
```

#### Uninstall All Packages

```bash
./install.sh uninstall
```

#### Uninstall Specific Package

```bash
./install.sh uninstall nvim
```

#### List Available Packages

```bash
./install.sh list
```

#### Check Symlink Status

```bash
./install.sh status
```

### Manual Stow Commands

You can also use Stow directly:

```bash
cd ~/dotfiles

# Install (stow) a package
stow bash

# Uninstall (unstow) a package
stow -D bash

# Reinstall (restow) a package
stow -R bash

# Simulate (don't actually create links)
stow -n bash

# Verbose output
stow -v bash
```

### Adding New Dotfiles

1. **Create a new package directory:**
   ```bash
   cd ~/dotfiles
   mkdir new-app
   ```

2. **Add your config files with proper structure:**
   ```bash
   # For ~/.config/app/config
   mkdir -p new-app/.config/app
   cp ~/.config/app/config new-app/.config/app/
   
   # For ~/.dotfile
   cp ~/.dotfile new-app/.dotfile
   ```

3. **Stow the package:**
   ```bash
   stow new-app
   ```

4. **Commit to Git:**
   ```bash
   git add new-app
   git commit -m "Add new-app configuration"
   git push
   ```

## Backup System

The `backup.sh` script provides comprehensive backup functionality.

### Creating Backups

```bash
# Create a backup
./backup.sh create
# or simply
./backup.sh
```

Backups are stored in `~/.dotfiles-backups/backup_YYYYMMDD_HHMMSS/`

### Listing Backups

```bash
./backup.sh list
```

### Restoring from Backup

```bash
./backup.sh restore backup_20240101_120000
```

### Cleaning Old Backups

```bash
# Keep only 10 most recent backups
./backup.sh clean

# Keep only 5 most recent backups
./backup.sh clean 5
```

### What Gets Backed Up?

- All dotfiles in home directory (`.bashrc`, `.gitconfig`, etc.)
- All config directories in `~/.config/`
- Symlink information (what they point to)

### Automatic Backups

The installation script automatically creates a backup before:
- Installing packages for the first time
- Restoring from a backup (safety backup)

## Niri Compatibility

This dotfiles setup is fully compatible with [Niri](https://github.com/YaLTeR/niri) window manager on Ubuntu.

### Setting Up for Niri

1. **Before installing Niri:**
   ```bash
   cd ~/dotfiles
   ./backup.sh create
   ```

2. **Create Niri package:**
   ```bash
   mkdir -p niri/.config/niri
   # Add your Niri config
   ```

3. **Install Niri package:**
   ```bash
   ./install.sh install niri
   ```

### Why It Works with Niri

- **Symlinks are transparent:** Niri reads configs from `~/.config/niri/` - doesn't matter if it's a symlink
- **XDG compliance:** Follows XDG Base Directory specification
- **No hardcoded paths:** Everything uses standard locations
- **Wayland compatible:** Stow works with any compositor/window manager

### After Installing Niri

Your dotfiles will continue working because:
- Terminal configs (wezterm, etc.) are already stowed
- Shell configs (bash, fish) remain in place
- All symlinks persist across different compositors

## Troubleshooting

### Conflicts During Installation

**Error:** `WARNING! stowing bash would cause conflicts`

**Solution:**
```bash
# Option 1: Backup and remove conflicting files
./backup.sh create
rm ~/.bashrc  # or conflicting file
./install.sh install bash

# Option 2: Force restow
cd ~/dotfiles
stow -R bash
```

### Broken Symlinks

**Check for broken links:**
```bash
find ~ -maxdepth 1 -xtype l
```

**Fix:**
```bash
cd ~/dotfiles
stow -R <package-name>
```

### Accidentally Deleted Dotfiles

**Restore from backup:**
```bash
./backup.sh list
./backup.sh restore backup_YYYYMMDD_HHMMSS
```

### Package Not Stowing Correctly

**Debug with verbose mode:**
```bash
cd ~/dotfiles
stow -v <package-name>
```

**Check structure:**
```bash
tree <package-name>
```

Ensure structure matches:
- Home dotfiles: `package/.dotfile`
- Config files: `package/.config/app/config`

### Git Status Shows Unwanted Files

**Add to `.gitignore`:**
```bash
cd ~/dotfiles
echo "*.log" >> .gitignore
echo ".DS_Store" >> .gitignore
git add .gitignore
git commit -m "Update gitignore"
```

## Advanced Usage

### Conditional Stowing (Different Machines)

Create machine-specific packages:

```
~/dotfiles/
├── bash/          # Common bash config
├── bash-work/     # Work-specific bash additions
└── bash-home/     # Home-specific bash additions
```

Install based on machine:
```bash
# On work machine
./install.sh install bash bash-work

# On home machine
./install.sh install bash bash-home
```

### Adopt Existing Files

If you have existing configs and want to move them to dotfiles:

```bash
cd ~/dotfiles
stow --adopt bash  # Moves existing files into dotfiles/bash/
git diff           # Check what changed
git checkout .     # Restore if needed
```

### Dry Run (Preview Changes)

```bash
cd ~/dotfiles
stow -n -v bash  # Show what would happen
```

## Maintenance

### Regular Tasks

1. **Update configs:**
   ```bash
   cd ~/dotfiles
   # Edit files as needed
   git add -A
   git commit -m "Update configs"
   git push
   ```

2. **Clean old backups:**
   ```bash
   ./backup.sh clean 10
   ```

3. **Verify symlinks:**
   ```bash
   ./install.sh status
   ```

### Syncing to Another Machine

```bash
# On new machine
git clone <your-repo> ~/dotfiles
cd ~/dotfiles
./install.sh
```

## Tips & Best Practices

1. **Commit often:** Small, focused commits are easier to track
2. **Use descriptive commit messages:** "Update nvim keybindings" not "Update stuff"
3. **Test before committing:** Make sure configs work before pushing
4. **Keep backups:** Run `./backup.sh` before major changes
5. **Document custom configs:** Add comments explaining non-obvious settings
6. **Use branches:** Test big changes in a separate branch first

## Resources

- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/)
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
- [Dotfiles Guide](https://dotfiles.github.io/)

## License

MIT - Do whatever you want with this setup!

---

**Happy configuring!**
