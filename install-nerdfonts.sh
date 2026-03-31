#!/bin/sh
# install-nerdfonts.sh — download and install all Nerd Fonts
# Works on Linux and OpenBSD (requires curl, tar with xz support, fc-cache)

set -e

FONTS_DIR="${HOME}/.local/share/fonts/NerdFonts"
mkdir -p "$FONTS_DIR"

if ! command -v curl > /dev/null 2>&1; then
    echo "error: curl is required (pkg_add curl on OpenBSD, pacman -S curl on Arch)"
    exit 1
fi

API="https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest"

echo "Fetching latest Nerd Fonts release..."
RELEASE=$(curl -fsSL "$API")
VERSION=$(printf '%s' "$RELEASE" | grep '"tag_name"' | sed 's/.*"tag_name": *"\(.*\)".*/\1/')
echo "Version: $VERSION"

BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${VERSION}"

FONTS=$(printf '%s' "$RELEASE" | grep '"name"' | grep '\.tar\.xz"' | sed 's/.*"name": *"\(.*\)".*/\1/')

TOTAL=$(printf '%s\n' "$FONTS" | wc -l | tr -d ' ')
COUNT=0

for font in $FONTS; do
    COUNT=$(( COUNT + 1 ))
    printf '[%d/%d] %s\n' "$COUNT" "$TOTAL" "$font"
    curl -fsSL "${BASE_URL}/${font}" | tar -xJf - -C "$FONTS_DIR" 2>/dev/null
done

echo "Updating font cache..."
fc-cache -f "$FONTS_DIR"
echo "Done — $COUNT font families installed to $FONTS_DIR"
