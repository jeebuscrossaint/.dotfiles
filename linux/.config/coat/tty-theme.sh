#!/bin/sh
# coat TTY theme: Wallpaper
# coat (extracted)
# variant: dark

# Apply Base16 colors to Linux TTY/console
# This script should be run with root privileges or from /etc/profile.d/

if [ "$TERM" = "linux" ]; then
    printf '\033]P00C0C0C'
    printf '\033]P1620E1B'
    printf '\033]P235070D'
    printf '\033]P3E54B5C'
    printf '\033]P4211C11'
    printf '\033]P5211711'
    printf '\033]P62C0608'
    printf '\033]P7736263'
    printf '\033]P8423939'
    printf '\033]P9620E1B'
    printf '\033]PA35070D'
    printf '\033]PBE54B5C'
    printf '\033]PC211C11'
    printf '\033]PD211711'
    printf '\033]PE2C0608'
    printf '\033]PF9F8E90'
    clear
fi
