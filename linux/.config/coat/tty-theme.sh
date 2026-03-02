#!/bin/sh
# coat TTY theme: Material Dark
# FredHappyface (https://github.com/fredHappyface)
# variant: dark

# Apply Base16 colors to Linux TTY/console
# This script should be run with root privileges or from /etc/profile.d/

if [ "$TERM" = "linux" ]; then
    printf '\033]P01D1D1C'
    printf '\033]P1AC183E'
    printf '\033]P26B7C16'
    printf '\033]P36591E9'
    printf '\033]P41737A6'
    printf '\033]P5480F69'
    printf '\033]P60F4D6C'
    printf '\033]P7C6C6C6'
    printf '\033]P86C6C6C'
    printf '\033]P9AC183E'
    printf '\033]PA6B7C16'
    printf '\033]PB6591E9'
    printf '\033]PC1737A6'
    printf '\033]PD480F69'
    printf '\033]PE0F4D6C'
    printf '\033]PFDCDCDC'
    clear
fi
