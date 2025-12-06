#!/bin/bash

#######################################
# Migrate Dotfiles to Stow Structure
# Reorganizes dotfiles into Stow-compatible format
#######################################

set -e

# Configuration
DOTFILES_DIR="$HOME/dotfiles"
BACKUP_SCRIPT="$DOTFILES_DIR/backup.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header "Dotfiles Migration to Stow Structure"

# Step 1: Create backup
echo ""
print_warning "Creating backup before migration..."
if [ -x "$BACKUP_SCRIPT" ]; then
    "$BACKUP_SCRIPT" create
else
    print_error "Backup script not found or not executable!"
    exit 1
fi

echo ""
print_header "Starting Migration"

# Step 2: Restructure nvim (already in dotfiles)
echo ""
echo "Restructuring nvim..."
if [ -d "$DOTFILES_DIR/nvim" ]; then
    # nvim needs to be in .config/nvim structure for Stow
    mkdir -p "$DOTFILES_DIR/nvim/.config"
    if [ ! -e "$DOTFILES_DIR/nvim/.config/nvim" ]; then
        # Move contents to proper structure
        temp_dir=$(mktemp -d)
        mv "$DOTFILES_DIR/nvim/"* "$temp_dir/" 2>/dev/null || true
        mv "$DOTFILES_DIR/nvim/".* "$temp_dir/" 2>/dev/null || true
        mkdir -p "$DOTFILES_DIR/nvim/.config/nvim"
        mv "$temp_dir/"* "$DOTFILES_DIR/nvim/.config/nvim/" 2>/dev/null || true
        mv "$temp_dir/".* "$DOTFILES_DIR/nvim/.config/nvim/" 2>/dev/null || true
        rmdir "$temp_dir"
        print_success "Restructured nvim"
    else
        print_success "nvim already in correct structure"
    fi
fi

# Step 3: Restructure tmux
echo ""
echo "Restructuring tmux..."
if [ -d "$DOTFILES_DIR/tmux" ]; then
    mkdir -p "$DOTFILES_DIR/tmux/.config/tmux"
    
    # Move tmux.conf files
    if [ -f "$DOTFILES_DIR/tmux/tmux.conf" ]; then
        mv "$DOTFILES_DIR/tmux/tmux.conf" "$DOTFILES_DIR/tmux/.config/tmux/tmux.conf"
    fi
    if [ -f "$DOTFILES_DIR/tmux/tmux.reset.conf" ]; then
        mv "$DOTFILES_DIR/tmux/tmux.reset.conf" "$DOTFILES_DIR/tmux/.config/tmux/tmux.reset.conf"
    fi
    
    # Keep README if exists
    if [ -f "$DOTFILES_DIR/tmux/README.md" ]; then
        # READMEs can stay at package root
        :
    fi
    
    print_success "Restructured tmux"
fi

# Step 4: Create bash package
echo ""
echo "Creating bash package..."
mkdir -p "$DOTFILES_DIR/bash"

if [ -f "$HOME/.bashrc" ] && [ ! -L "$HOME/.bashrc" ]; then
    cp "$HOME/.bashrc" "$DOTFILES_DIR/bash/.bashrc"
    print_success "Copied .bashrc"
fi

if [ -f "$HOME/.bash_logout" ] && [ ! -L "$HOME/.bash_logout" ]; then
    cp "$HOME/.bash_logout" "$DOTFILES_DIR/bash/.bash_logout"
    print_success "Copied .bash_logout"
fi

if [ -f "$HOME/.profile" ] && [ ! -L "$HOME/.profile" ]; then
    cp "$HOME/.profile" "$DOTFILES_DIR/bash/.profile"
    print_success "Copied .profile"
fi

# Step 5: Create git package
echo ""
echo "Creating git package..."
mkdir -p "$DOTFILES_DIR/git"

if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
    cp "$HOME/.gitconfig" "$DOTFILES_DIR/git/.gitconfig"
    print_success "Copied .gitconfig"
fi

if [ -f "$HOME/.gitmessage" ] && [ ! -L "$HOME/.gitmessage" ]; then
    cp "$HOME/.gitmessage" "$DOTFILES_DIR/git/.gitmessage"
    print_success "Copied .gitmessage"
fi

# Step 6: Create wezterm package
echo ""
echo "Creating wezterm package..."
mkdir -p "$DOTFILES_DIR/wezterm"

if [ -f "$HOME/.wezterm.lua" ] && [ ! -L "$HOME/.wezterm.lua" ]; then
    cp "$HOME/.wezterm.lua" "$DOTFILES_DIR/wezterm/.wezterm.lua"
    print_success "Copied .wezterm.lua"
fi

# Step 7: Create misc package for other dotfiles
echo ""
echo "Creating misc package..."
mkdir -p "$DOTFILES_DIR/misc"

if [ -f "$HOME/.dircolors" ] && [ ! -L "$HOME/.dircolors" ]; then
    cp "$HOME/.dircolors" "$DOTFILES_DIR/misc/.dircolors"
    print_success "Copied .dircolors"
fi

# Step 8: Create optional packages for .config directories
echo ""
echo "Creating optional .config packages..."

# Fish
if [ -d "$HOME/.config/fish" ]; then
    mkdir -p "$DOTFILES_DIR/fish/.config"
    if [ ! -L "$HOME/.config/fish" ]; then
        cp -r "$HOME/.config/fish" "$DOTFILES_DIR/fish/.config/"
        print_success "Copied fish config"
    fi
fi

# Btop
if [ -d "$HOME/.config/btop" ]; then
    mkdir -p "$DOTFILES_DIR/btop/.config"
    if [ ! -L "$HOME/.config/btop" ]; then
        cp -r "$HOME/.config/btop" "$DOTFILES_DIR/btop/.config/"
        print_success "Copied btop config"
    fi
fi

# Flameshot
if [ -d "$HOME/.config/flameshot" ]; then
    mkdir -p "$DOTFILES_DIR/flameshot/.config"
    if [ ! -L "$HOME/.config/flameshot" ]; then
        cp -r "$HOME/.config/flameshot" "$DOTFILES_DIR/flameshot/.config/"
        print_success "Copied flameshot config"
    fi
fi

# Kanata
if [ -d "$HOME/.config/kanata" ]; then
    mkdir -p "$DOTFILES_DIR/kanata/.config"
    if [ ! -L "$HOME/.config/kanata" ]; then
        cp -r "$HOME/.config/kanata" "$DOTFILES_DIR/kanata/.config/"
        print_success "Copied kanata config"
    fi
fi

echo ""
print_header "Migration Complete!"
echo ""
echo "Your dotfiles structure is now:"
echo ""
tree -L 2 -a "$DOTFILES_DIR" 2>/dev/null || ls -la "$DOTFILES_DIR"
echo ""
print_success "Next steps:"
echo "  1. Review the structure: cd $DOTFILES_DIR"
echo "  2. Run: git add -A"
echo "  3. Run: git commit -m 'Restructure for GNU Stow'"
echo "  4. Run: ./install.sh to deploy with Stow"
echo ""
print_warning "Note: Your original files are still in place and backed up."
echo "The install.sh script will safely replace them with symlinks."
