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
    
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        print_warning "Backing up existing $target to $backup"
        mv "$target" "$backup"
    elif [ -L "$target" ]; then
        # If it's already a symlink, just remove it
        rm "$target"
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

# Recursively symlink files in .config
install_config() {
    if [ ! -d "$LINUX_DIR/.config" ]; then
        print_warning "No .config directory found in $LINUX_DIR"
        return
    fi
    
    print_info "Installing .config files..."
    
    # Use find to recursively get all files (not directories)
    find "$LINUX_DIR/.config" -type f -o -type l | while read -r source_file; do
        # Get the relative path from linux/.config/
        rel_path="${source_file#"$LINUX_DIR"/.config/}"
        target="$CONFIG_DIR/$rel_path"
        
        create_symlink "$source_file" "$target"
    done
}

# Install standalone dotfiles (files in linux/ root, excluding .config/)
install_dotfiles() {
    if [ ! -d "$LINUX_DIR" ]; then
        print_error "Linux directory not found: $LINUX_DIR"
        return 1
    fi
    
    print_info "Installing standalone dotfiles..."
    
    # Find all files in linux/ that start with a dot, excluding .config
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
        
        # Skip if it's a directory (we only want files at the root level)
        if [ -d "$dotfile" ]; then
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
        
        # Skip README and other special files
        case "$file_name" in
            README.md|.*)
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
    
    # Remove .config symlinks (recursively find all symlinks pointing to our repo)
    if [ -d "$LINUX_DIR/.config" ]; then
        find "$LINUX_DIR/.config" -type f -o -type l | while read -r source_file; do
            rel_path="${source_file#"$LINUX_DIR"/.config/}"
            target="$CONFIG_DIR/$rel_path"
            
            if [ -L "$target" ]; then
                link_target="$(readlink "$target")"
                if [ "$link_target" = "$source_file" ]; then
                    print_info "Removing symlink: $target"
                    rm "$target"
                    print_success "Removed: $target"
                fi
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
            
            if [ ! -e "$dotfile" ] || [ -d "$dotfile" ]; then
                continue
            fi
            
            dotfile_name="$(basename "$dotfile")"
            target="$HOME/$dotfile_name"
            
            if [ -L "$target" ]; then
                link_target="$(readlink "$target")"
                if [ "$link_target" = "$dotfile" ]; then
                    print_info "Removing symlink: $target"
                    rm "$target"
                    print_success "Removed: $target"
                fi
            fi
        done
        
        # Remove non-hidden files
        for file in "$LINUX_DIR"/*; do
            if [ ! -e "$file" ] || [ -d "$file" ]; then
                continue
            fi
            
            file_name="$(basename "$file")"
            
            case "$file_name" in
                README.md|.*)
                    continue
                    ;;
            esac
            
            target="$HOME/$file_name"
            
            if [ -L "$target" ]; then
                link_target="$(readlink "$target")"
                if [ "$link_target" = "$file" ]; then
                    print_info "Removing symlink: $target"
                    rm "$target"
                    print_success "Removed: $target"
                fi
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
        printf '%b\n' "${YELLOW}.config files:${NC}"
        find "$LINUX_DIR/.config" -type f -o -type l | while read -r source_file; do
            rel_path="${source_file#"$LINUX_DIR"/.config/}"
            printf "  %s -> %s\n" "$source_file" "$CONFIG_DIR/$rel_path"
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
            
            if [ ! -e "$dotfile" ] || [ -d "$dotfile" ]; then
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
                README.md|.*)
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
        .config/
            kitty/kitty.conf     -> \$HOME/.config/kitty/kitty.conf
            fish/config.fish     -> \$HOME/.config/fish/config.fish
            starship.toml        -> \$HOME/.config/starship.toml
            ...
        .bashrc                  -> \$HOME/.bashrc
        script.sh                -> \$HOME/script.sh

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
