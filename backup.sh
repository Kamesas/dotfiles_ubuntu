#!/bin/bash

#######################################
# Dotfiles Backup System
# Creates timestamped backups before making changes
#######################################

set -e

# Configuration
BACKUP_DIR="$HOME/.dotfiles-backups"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/backup_$TIMESTAMP"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Files and directories to backup
DOTFILES_TO_BACKUP=(
    # Home directory dotfiles
    ".bashrc"
    ".bash_logout"
    ".profile"
    ".gitconfig"
    ".gitmessage"
    ".wezterm.lua"
    ".dircolors"
    ".tmux.conf"
    
    # Config directories
    ".config/nvim"
    ".config/tmux"
    ".config/fish"
    ".config/btop"
    ".config/flameshot"
    ".config/guake"
    ".config/kanata"
    ".config/copyq"
    ".config/autostart"
)

#######################################
# Functions
#######################################

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

create_backup() {
    print_header "Creating Dotfiles Backup"
    
    # Create backup directory
    mkdir -p "$BACKUP_PATH"
    print_success "Created backup directory: $BACKUP_PATH"
    
    local backed_up=0
    local skipped=0
    
    # Backup each file/directory
    for item in "${DOTFILES_TO_BACKUP[@]}"; do
        local source="$HOME/$item"
        local dest="$BACKUP_PATH/$item"
        
        if [ -e "$source" ]; then
            # Create parent directory in backup
            mkdir -p "$(dirname "$dest")"
            
            # Copy file or directory
            if [ -L "$source" ]; then
                # If it's a symlink, store both the link and what it points to
                cp -P "$source" "$dest"
                echo "$(readlink "$source")" > "$dest.symlink-target"
                print_success "Backed up symlink: $item"
            else
                cp -r "$source" "$dest"
                print_success "Backed up: $item"
            fi
            ((backed_up++))
        else
            print_warning "Skipped (not found): $item"
            ((skipped++))
        fi
    done
    
    # Create backup metadata
    cat > "$BACKUP_PATH/backup-info.txt" << EOF
Backup Information
==================
Timestamp: $TIMESTAMP
Date: $(date)
Hostname: $(hostname)
User: $USER
Total items backed up: $backed_up
Items skipped: $skipped

Backed up items:
EOF
    
    for item in "${DOTFILES_TO_BACKUP[@]}"; do
        if [ -e "$HOME/$item" ]; then
            echo "  - $item" >> "$BACKUP_PATH/backup-info.txt"
        fi
    done
    
    echo ""
    print_success "Backup completed successfully!"
    print_success "Location: $BACKUP_PATH"
    echo ""
    echo -e "Files backed up: ${GREEN}$backed_up${NC}"
    echo -e "Files skipped: ${YELLOW}$skipped${NC}"
}

list_backups() {
    print_header "Available Backups"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        print_warning "No backups found. Backup directory doesn't exist."
        return
    fi
    
    local backups=($(ls -1t "$BACKUP_DIR" 2>/dev/null || true))
    
    if [ ${#backups[@]} -eq 0 ]; then
        print_warning "No backups found."
        return
    fi
    
    echo ""
    for backup in "${backups[@]}"; do
        local backup_path="$BACKUP_DIR/$backup"
        local size=$(du -sh "$backup_path" | cut -f1)
        local date=$(stat -c %y "$backup_path" | cut -d'.' -f1)
        
        echo -e "${GREEN}$backup${NC}"
        echo "  Path: $backup_path"
        echo "  Size: $size"
        echo "  Date: $date"
        echo ""
    done
}

restore_backup() {
    local backup_name=$1
    
    if [ -z "$backup_name" ]; then
        print_error "Please specify a backup to restore."
        echo "Usage: $0 restore <backup_name>"
        echo ""
        list_backups
        return 1
    fi
    
    local restore_path="$BACKUP_DIR/$backup_name"
    
    if [ ! -d "$restore_path" ]; then
        print_error "Backup not found: $backup_name"
        list_backups
        return 1
    fi
    
    print_header "Restoring Backup: $backup_name"
    print_warning "This will overwrite your current dotfiles!"
    echo ""
    
    read -p "Are you sure you want to continue? (yes/no): " -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_warning "Restore cancelled."
        return 0
    fi
    
    # Create a safety backup before restoring
    print_warning "Creating safety backup before restore..."
    create_backup
    
    # Restore files
    local restored=0
    cd "$restore_path"
    
    for item in "${DOTFILES_TO_BACKUP[@]}"; do
        if [ -e "$item" ]; then
            local dest="$HOME/$item"
            
            # Remove existing file/symlink
            if [ -e "$dest" ] || [ -L "$dest" ]; then
                rm -rf "$dest"
            fi
            
            # Create parent directory if needed
            mkdir -p "$(dirname "$dest")"
            
            # Restore
            cp -r "$item" "$dest"
            print_success "Restored: $item"
            ((restored++))
        fi
    done
    
    echo ""
    print_success "Restore completed! Restored $restored items."
}

clean_old_backups() {
    local keep=${1:-10}
    
    print_header "Cleaning Old Backups"
    echo "Keeping the $keep most recent backups..."
    echo ""
    
    if [ ! -d "$BACKUP_DIR" ]; then
        print_warning "No backup directory found."
        return
    fi
    
    local backups=($(ls -1t "$BACKUP_DIR" 2>/dev/null || true))
    local total=${#backups[@]}
    
    if [ $total -le $keep ]; then
        print_success "Only $total backups found. Nothing to clean."
        return
    fi
    
    local to_delete=$((total - keep))
    echo "Found $total backups. Will delete $to_delete old backups."
    echo ""
    
    read -p "Continue? (yes/no): " -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_warning "Cleanup cancelled."
        return 0
    fi
    
    local deleted=0
    for ((i=keep; i<total; i++)); do
        local backup="${backups[$i]}"
        rm -rf "$BACKUP_DIR/$backup"
        print_success "Deleted: $backup"
        ((deleted++))
    done
    
    echo ""
    print_success "Cleaned up $deleted old backups."
}

show_help() {
    cat << EOF
Dotfiles Backup System
======================

Usage: $0 [command] [options]

Commands:
  create              Create a new backup (default)
  list                List all available backups
  restore <name>      Restore a specific backup
  clean [keep]        Remove old backups (default: keep 10 most recent)
  help                Show this help message

Examples:
  $0                          # Create a new backup
  $0 create                   # Create a new backup
  $0 list                     # List all backups
  $0 restore backup_20240101_120000  # Restore specific backup
  $0 clean 5                  # Keep only 5 most recent backups

Backup location: $BACKUP_DIR

EOF
}

#######################################
# Main
#######################################

case "${1:-create}" in
    create)
        create_backup
        ;;
    list)
        list_backups
        ;;
    restore)
        restore_backup "$2"
        ;;
    clean)
        clean_old_backups "${2:-10}"
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
