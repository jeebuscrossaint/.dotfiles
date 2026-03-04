#!/bin/sh
# coat TTY theme: Wallpaper
# coat (extracted)
# variant: dark

# Apply Base16 colors to Linux TTY/console
# This script should be run with root privileges or from /etc/profile.d/

if [ "$TERM" = "linux" ]; then
    printf '\033]P018181B'
    printf '\033]P1AAB3EE'
    printf '\033]P2AABCEE'
    printf '\033]P3AAB8EE'
    printf '\033]P4AABBEE'
    printf '\033]P5ADBDEB'
    printf '\033]P6AABAEE'
    printf '\033]P7BCBDC2'
    printf '\033]P855555E'
    printf '\033]P9AAB3EE'
    printf '\033]PAAABCEE'
    printf '\033]PBAAB8EE'
    printf '\033]PCAABBEE'
    printf '\033]PDADBDEB'
    printf '\033]PEAABAEE'
    printf '\033]PFE4E4E7'
    clear
fi
