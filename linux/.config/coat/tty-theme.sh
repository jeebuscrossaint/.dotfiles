#!/bin/sh
# coat TTY theme: Wallpaper
# coat (extracted)
# variant: dark

# Apply Base16 colors to Linux TTY/console
# This script should be run with root privileges or from /etc/profile.d/

if [ "$TERM" = "linux" ]; then
    printf '\033]P0222428'
    printf '\033]P1101A2D'
    printf '\033]P2101A2D'
    printf '\033]P3101A2D'
    printf '\033]P4101A2D'
    printf '\033]P5101A2D'
    printf '\033]P6101A2D'
    printf '\033]P796999C'
    printf '\033]P8676A6D'
    printf '\033]P9101A2D'
    printf '\033]PA101A2D'
    printf '\033]PB101A2D'
    printf '\033]PC101A2D'
    printf '\033]PD101A2D'
    printf '\033]PE101A2D'
    printf '\033]PFC6C8C9'
    clear
fi
