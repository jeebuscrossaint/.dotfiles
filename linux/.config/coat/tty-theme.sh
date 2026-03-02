#!/bin/sh
# coat TTY theme: Wallpaper
# coat (extracted)
# variant: dark

# Apply Base16 colors to Linux TTY/console
# This script should be run with root privileges or from /etc/profile.d/

if [ "$TERM" = "linux" ]; then
    printf '\033]P02A2624'
    printf '\033]P12A1F18'
    printf '\033]P22A1F18'
    printf '\033]P32A1F18'
    printf '\033]P42A1F18'
    printf '\033]P52A1F18'
    printf '\033]P62A1F18'
    printf '\033]P7ACA9A7'
    printf '\033]P8797472'
    printf '\033]P92A1F18'
    printf '\033]PA2A1F18'
    printf '\033]PB2A1F18'
    printf '\033]PC2A1F18'
    printf '\033]PD2A1F18'
    printf '\033]PE2A1F18'
    printf '\033]PFDEDFE0'
    clear
fi
