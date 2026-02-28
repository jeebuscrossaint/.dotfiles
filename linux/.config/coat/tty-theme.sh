#!/bin/sh
# coat TTY theme: Firefox Dev
# FredHappyface (https://github.com/fredHappyface)
# variant: dark

# Apply Base16 colors to Linux TTY/console
# This script should be run with root privileges or from /etc/profile.d/

if [ "$TERM" = "linux" ]; then
    printf '\033]P00B0D0D'
    printf '\033]P1EE327D'
    printf '\033]P23FC32F'
    printf '\033]P30D69AB'
    printf '\033]P428A1ED'
    printf '\033]P5C170F3'
    printf '\033]P64173A9'
    printf '\033]P7A7AEAF'
    printf '\033]P834494F'
    printf '\033]P9EE327D'
    printf '\033]PA3FC32F'
    printf '\033]PB0D69AB'
    printf '\033]PC28A1ED'
    printf '\033]PDC170F3'
    printf '\033]PE4173A9'
    printf '\033]PFE6E6E6'
    clear
fi
