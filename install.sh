#!/usr/bin/env bash

# GNU Stow dotfiles installer

set -e

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check if stow is installed
if ! command -v stow &> /dev/null; then
    echo "Error: GNU Stow is not installed"
    echo "Install with: sudo pacman -S stow (Arch) or sudo apt install stow (Debian/Ubuntu)"
    exit 1
fi

# Use stow to symlink the linux directory
cd "$DOTFILES_DIR"
stow -v -t "$HOME" linux

echo "Dotfiles installed with GNU Stow!"
