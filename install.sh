#!/bin/bash

#######################################
# Dotfiles Installation Script
# Uses GNU Stow to symlink dotfiles
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
CYAN='\033[0;36m'
NC='\033[0m'

# Available packages
CORE_PACKAGES=("bash" "git")
OPTIONAL_PACKAGES=("nvim" "tmux" "wezterm" "misc" "fish" "btop" "flameshot" "kanata")

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

print_info() {
    echo -e "${CYAN}ℹ${NC} $1"
}

check_stow() {
    if ! command -v stow &> /dev/null; then
        print_error "GNU Stow is not installed!"
        echo ""
        echo "Please install it with:"
        echo "  sudo apt install stow"
        exit 1
    fi
    print_success "GNU Stow is installed"
}

create_backup() {
    echo ""
    print_warning "Creating backup before installation..."
    if [ -x "$BACKUP_SCRIPT" ]; then
        "$BACKUP_SCRIPT" create
    else
        print_warning "Backup script not found, skipping backup"
    fi
}

list_packages() {
    echo ""
    print_header "Available Packages"
    echo ""
    echo -e "${GREEN}Core Packages (recommended):${NC}"
    for pkg in "${CORE_PACKAGES[@]}"; do
        if [ -d "$DOTFILES_DIR/$pkg" ]; then
            echo "  ✓ $pkg"
        else
            echo "  ✗ $pkg (not found)"
        fi
    done
    
    echo ""
    echo -e "${CYAN}Optional Packages:${NC}"
    for pkg in "${OPTIONAL_PACKAGES[@]}"; do
        if [ -d "$DOTFILES_DIR/$pkg" ]; then
            echo "  ✓ $pkg"
        else
            echo "  ✗ $pkg (not found)"
        fi
    done
    echo ""
}

install_package() {
    local package=$1
    local package_dir="$DOTFILES_DIR/$package"
    
    if [ ! -d "$package_dir" ]; then
        print_warning "Package not found: $package"
        return 1
    fi
    
    echo ""
    print_info "Installing package: $package"
    
    cd "$DOTFILES_DIR"
    
    # Stow the package
    if stow -v "$package" 2>&1 | grep -q "LINK"; then
        print_success "Installed: $package"
        return 0
    else
        # Try restowing if already linked
        if stow -R -v "$package" 2>&1; then
            print_success "Re-installed: $package"
            return 0
        else
            print_error "Failed to install: $package"
            return 1
        fi
    fi
}

uninstall_package() {
    local package=$1
    
    echo ""
    print_info "Uninstalling package: $package"
    
    cd "$DOTFILES_DIR"
    
    if stow -D -v "$package" 2>&1; then
        print_success "Uninstalled: $package"
        return 0
    else
        print_error "Failed to uninstall: $package"
        return 1
    fi
}

install_all() {
    local mode=${1:-"interactive"}
    
    print_header "Installing Dotfiles"
    
    if [ "$mode" = "interactive" ]; then
        echo ""
        print_warning "This will create symlinks from ~/dotfiles to your home directory"
        echo ""
        read -p "Create backup before installation? (recommended) (y/n): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            create_backup
        fi
    else
        create_backup
    fi
    
    echo ""
    print_header "Installing Packages"
    
    local installed=0
    local failed=0
    
    # Install core packages
    echo ""
    echo -e "${GREEN}Installing core packages...${NC}"
    for pkg in "${CORE_PACKAGES[@]}"; do
        if [ -d "$DOTFILES_DIR/$pkg" ]; then
            if install_package "$pkg"; then
                ((installed++))
            else
                ((failed++))
            fi
        fi
    done
    
    # Install optional packages
    echo ""
    echo -e "${CYAN}Installing optional packages...${NC}"
    for pkg in "${OPTIONAL_PACKAGES[@]}"; do
        if [ -d "$DOTFILES_DIR/$pkg" ]; then
            if install_package "$pkg"; then
                ((installed++))
            else
                ((failed++))
            fi
        fi
    done
    
    echo ""
    print_header "Installation Summary"
    echo ""
    echo -e "Successfully installed: ${GREEN}$installed${NC} packages"
    if [ $failed -gt 0 ]; then
        echo -e "Failed: ${RED}$failed${NC} packages"
    fi
    echo ""
    print_success "Installation complete!"
    echo ""
    print_info "Your dotfiles are now symlinked from $DOTFILES_DIR"
    print_info "Any changes to files in $DOTFILES_DIR will be reflected immediately"
}

install_specific() {
    local packages=("$@")
    
    print_header "Installing Specific Packages"
    
    create_backup
    
    local installed=0
    local failed=0
    
    for pkg in "${packages[@]}"; do
        if install_package "$pkg"; then
            ((installed++))
        else
            ((failed++))
        fi
    done
    
    echo ""
    print_header "Installation Summary"
    echo ""
    echo -e "Successfully installed: ${GREEN}$installed${NC} packages"
    if [ $failed -gt 0 ]; then
        echo -e "Failed: ${RED}$failed${NC} packages"
    fi
}

uninstall_all() {
    print_header "Uninstalling All Dotfiles"
    
    echo ""
    print_warning "This will remove all symlinks created by Stow"
    print_warning "Your original files in ~/dotfiles will remain untouched"
    echo ""
    read -p "Continue? (y/n): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Uninstall cancelled"
        return 0
    fi
    
    local uninstalled=0
    
    # Uninstall all packages
    for pkg in "${CORE_PACKAGES[@]}" "${OPTIONAL_PACKAGES[@]}"; do
        if [ -d "$DOTFILES_DIR/$pkg" ]; then
            if uninstall_package "$pkg"; then
                ((uninstalled++))
            fi
        fi
    done
    
    echo ""
    print_success "Uninstalled $uninstalled packages"
}

show_status() {
    print_header "Dotfiles Status"
    
    echo ""
    echo "Checking symlinks..."
    echo ""
    
    cd "$DOTFILES_DIR"
    
    for pkg in "${CORE_PACKAGES[@]}" "${OPTIONAL_PACKAGES[@]}"; do
        if [ -d "$pkg" ]; then
            echo -e "${CYAN}Package: $pkg${NC}"
            
            # Find all files in package and check if they're symlinked
            find "$pkg" -type f -o -type d | while read -r file; do
                # Remove package prefix to get home path
                local rel_path=${file#$pkg/}
                local home_path="$HOME/$rel_path"
                
                if [ -L "$home_path" ]; then
                    local target=$(readlink "$home_path")
                    if [[ "$target" == *"$DOTFILES_DIR/$pkg"* ]]; then
                        echo "  ✓ $rel_path (symlinked)"
                    fi
                elif [ -e "$home_path" ]; then
                    echo "  ⚠ $rel_path (exists but not symlinked)"
                fi
            done
            echo ""
        fi
    done
}

show_help() {
    cat << EOF
Dotfiles Installation Script (GNU Stow)
========================================

Usage: $0 [command] [options]

Commands:
  install             Install all dotfiles (interactive, default)
  install <packages>  Install specific packages
  uninstall [package] Uninstall all or specific package
  list                List available packages
  status              Show current symlink status
  help                Show this help message

Examples:
  $0                      # Install all (interactive)
  $0 install              # Install all (interactive)
  $0 install bash git     # Install only bash and git
  $0 uninstall            # Uninstall all
  $0 uninstall nvim       # Uninstall only nvim
  $0 list                 # List available packages
  $0 status               # Show symlink status

Package Management:
  After installation, you can manage packages individually:
  - Install:   stow <package>
  - Uninstall: stow -D <package>
  - Reinstall: stow -R <package>

Notes:
  - Backups are automatically created in ~/.dotfiles-backups
  - All changes are symlinks - edit files in ~/dotfiles
  - Changes are immediately reflected in your home directory
  - Safe to run multiple times (will re-stow existing packages)

EOF
}

#######################################
# Main
#######################################

# Check if we're in the right directory
if [ ! -d "$DOTFILES_DIR" ]; then
    print_error "Dotfiles directory not found: $DOTFILES_DIR"
    exit 1
fi

# Check for GNU Stow
check_stow

# Parse command
case "${1:-install}" in
    install)
        shift
        if [ $# -eq 0 ]; then
            install_all "interactive"
        else
            install_specific "$@"
        fi
        ;;
    uninstall)
        if [ -z "$2" ]; then
            uninstall_all
        else
            shift
            for pkg in "$@"; do
                uninstall_package "$pkg"
            done
        fi
        ;;
    list)
        list_packages
        ;;
    status)
        show_status
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        print_error "Unknown command: $1"
        echo ""
        show_help
        exit 1
        ;;
esac
