#!/usr/bin/env sh

# Dotfiles installation script
# Pure POSIX shell - works on any Unix-like system

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory (where the dotfiles repo is)
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
LINUX_DIR="$DOTFILES_DIR/linux"
CONFIG_DIR="$HOME/.config"

# Print colored output
print_info() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

print_success() {
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

print_warning() {
    printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
}

print_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

# Create backup of existing file/directory
backup_existing() {
    target="$1"
    backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
    
    if [ -e "$target" ] || [ -L "$target" ]; then
        print_warning "Backing up existing $target to $backup"
        mv "$target" "$backup"
    fi
}

# Create symlink with backup
create_symlink() {
    source="$1"
    target="$2"
    
    # Create parent directory if it doesn't exist
    target_dir="$(dirname "$target")"
    if [ ! -d "$target_dir" ]; then
        print_info "Creating directory: $target_dir"
        mkdir -p "$target_dir"
    fi
    
    # Backup existing file/directory/symlink
    backup_existing "$target"
    
    # Create symlink
    print_info "Linking $source -> $target"
    ln -sf "$source" "$target"
    print_success "Created symlink: $target"
}

# Install .config directories
install_config() {
    if [ ! -d "$LINUX_DIR/.config" ]; then
        print_warning "No .config directory found in $LINUX_DIR"
        return
    fi
    
    print_info "Installing .config files..."
    
    # Iterate through each directory in linux/.config
    for config_item in "$LINUX_DIR/.config"/*; do
        if [ ! -e "$config_item" ]; then
            continue
        fi
        
        item_name="$(basename "$config_item")"
        target="$CONFIG_DIR/$item_name"
        
        create_symlink "$config_item" "$target"
    done
}

# Install standalone dotfiles (files in linux/ root, excluding .config/)
install_dotfiles() {
    if [ ! -d "$LINUX_DIR" ]; then
        print_error "Linux directory not found: $LINUX_DIR"
        return 1
    fi
    
    print_info "Installing standalone dotfiles..."
    
    # Find all files and directories in linux/ that start with a dot, excluding .config
    for dotfile in "$LINUX_DIR"/.*; do
        # Skip . and .. and .config directory
        case "$(basename "$dotfile")" in
            .|..|.config)
                continue
                ;;
        esac
        
        if [ ! -e "$dotfile" ]; then
            continue
        fi
        
        dotfile_name="$(basename "$dotfile")"
        target="$HOME/$dotfile_name"
        
        create_symlink "$dotfile" "$target"
    done
    
    # Also handle non-hidden files in linux/ root (like scripts)
    for file in "$LINUX_DIR"/*; do
        if [ ! -e "$file" ] || [ -d "$file" ]; then
            continue
        fi
        
        file_name="$(basename "$file")"
        
        # Skip if it's .config or starts with a dot
        case "$file_name" in
            .config|.*)
                continue
                ;;
        esac
        
        target="$HOME/$file_name"
        create_symlink "$file" "$target"
    done
}

# Uninstall (remove symlinks)
uninstall() {
    print_info "Uninstalling dotfiles..."
    
    # Remove .config symlinks
    if [ -d "$LINUX_DIR/.config" ]; then
        for config_item in "$LINUX_DIR/.config"/*; do
            if [ ! -e "$config_item" ]; then
                continue
            fi
            
            item_name="$(basename "$config_item")"
            target="$CONFIG_DIR/$item_name"
            
            if [ -L "$target" ] && [ "$(readlink "$target")" = "$config_item" ]; then
                print_info "Removing symlink: $target"
                rm "$target"
                print_success "Removed: $target"
            fi
        done
    fi
    
    # Remove standalone dotfile symlinks
    if [ -d "$LINUX_DIR" ]; then
        for dotfile in "$LINUX_DIR"/.*; do
            case "$(basename "$dotfile")" in
                .|..|.config)
                    continue
                    ;;
            esac
            
            if [ ! -e "$dotfile" ]; then
                continue
            fi
            
            dotfile_name="$(basename "$dotfile")"
            target="$HOME/$dotfile_name"
            
            if [ -L "$target" ] && [ "$(readlink "$target")" = "$dotfile" ]; then
                print_info "Removing symlink: $target"
                rm "$target"
                print_success "Removed: $target"
            fi
        done
        
        # Remove non-hidden files
        for file in "$LINUX_DIR"/*; do
            if [ ! -e "$file" ] || [ -d "$file" ]; then
                continue
            fi
            
            file_name="$(basename "$file")"
            
            case "$file_name" in
                .config|.*)
                    continue
                    ;;
            esac
            
            target="$HOME/$file_name"
            
            if [ -L "$target" ] && [ "$(readlink "$target")" = "$file" ]; then
                print_info "Removing symlink: $target"
                rm "$target"
                print_success "Removed: $target"
            fi
        done
    fi
    
    print_success "Uninstallation complete!"
}

# List all symlinks that would be created
list_links() {
    print_info "Dotfiles that would be symlinked:"
    echo ""
    
    if [ -d "$LINUX_DIR/.config" ]; then
        printf '%b\n' "${YELLOW}.config directories:${NC}"
        for config_item in "$LINUX_DIR/.config"/*; do
            if [ ! -e "$config_item" ]; then
                continue
            fi
            
            item_name="$(basename "$config_item")"
            printf "  %s -> %s\n" "$config_item" "$CONFIG_DIR/$item_name"
        done
        echo ""
    fi
    
    if [ -d "$LINUX_DIR" ]; then
        printf '%b\n' "${YELLOW}Standalone dotfiles:${NC}"
        for dotfile in "$LINUX_DIR"/.*; do
            case "$(basename "$dotfile")" in
                .|..|.config)
                    continue
                    ;;
            esac
            
            if [ ! -e "$dotfile" ]; then
                continue
            fi
            
            dotfile_name="$(basename "$dotfile")"
            printf "  %s -> %s\n" "$dotfile" "$HOME/$dotfile_name"
        done
        
        for file in "$LINUX_DIR"/*; do
            if [ ! -e "$file" ] || [ -d "$file" ]; then
                continue
            fi
            
            file_name="$(basename "$file")"
            
            case "$file_name" in
                .config|.*)
                    continue
                    ;;
            esac
            
            printf "  %s -> %s\n" "$file" "$HOME/$file_name"
        done
    fi
}

# Main installation
install() {
    print_info "Starting dotfiles installation from: $DOTFILES_DIR"
    echo ""
    
    # Create .config directory if it doesn't exist
    if [ ! -d "$CONFIG_DIR" ]; then
        print_info "Creating $CONFIG_DIR"
        mkdir -p "$CONFIG_DIR"
    fi
    
    # Install everything
    install_config
    install_dotfiles
    
    echo ""
    print_success "Dotfiles installation complete!"
}

# Show help
show_help() {
    cat << EOF
Dotfiles Manager - Simple GNU Stow-like dotfile manager

Usage: $0 [COMMAND]

Commands:
    install     Install/link all dotfiles (default)
    uninstall   Remove all dotfile symlinks
    list        List all dotfiles that would be symlinked
    help        Show this help message

Structure:
    linux/
        .config/          -> \$HOME/.config/
            i3/           -> \$HOME/.config/i3/
            rofi/         -> \$HOME/.config/rofi/
            ...
        .bashrc           -> \$HOME/.bashrc
        .zshrc            -> \$HOME/.zshrc
        script.sh         -> \$HOME/script.sh
        ...

Examples:
    $0                    # Install dotfiles
    $0 install            # Install dotfiles
    $0 uninstall          # Remove symlinks
    $0 list               # List what would be installed

EOF
}

# Main script logic
main() {
    case "${1:-install}" in
        install)
            install
            ;;
        uninstall)
            uninstall
            ;;
        list)
            list_links
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
}

main "$@"
