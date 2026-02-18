#!/bin/sh
# coat TTY theme: Jellybeans
# FredHappyface (https://github.com/fredHappyface)
# variant: dark

# Apply Base16 colors to Linux TTY/console
# This script should be run with root privileges or from /etc/profile.d/

if [ "$TERM" = "linux" ]; then
    printf '\033]P0121212'
    printf '\033]P1E27373'
    printf '\033]P293B979'
    printf '\033]P3B1D8F6'
    printf '\033]P497BEDC'
    printf '\033]P5E1C0FA'
    printf '\033]P600988E'
    printf '\033]P7D5D5D5'
    printf '\033]P8C5C5C5'
    printf '\033]P9E27373'
    printf '\033]PA93B979'
    printf '\033]PBB1D8F6'
    printf '\033]PC97BEDC'
    printf '\033]PDE1C0FA'
    printf '\033]PE00988E'
    printf '\033]PFFFFFFF'
    clear
fi
