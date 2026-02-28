#!/bin/sh
# coat TTY theme: Kanagawa Dragon
# Stefan Weigl-Bosker (https://github.com/sweiglbosker), Tommaso Laurenzi (https://github.com/rebelot/kanagawa.nvim)
# variant: dark

# Apply Base16 colors to Linux TTY/console
# This script should be run with root privileges or from /etc/profile.d/

if [ "$TERM" = "linux" ]; then
    printf '\033]P0121111'
    printf '\033]P1CD697D'
    printf '\033]P2849E79'
    printf '\033]P3CCC989'
    printf '\033]P48AA8B6'
    printf '\033]P5A293A7'
    printf '\033]P68EA8A7'
    printf '\033]P7C8CCC8'
    printf '\033]P8605C58'
    printf '\033]P9CD697D'
    printf '\033]PA849E79'
    printf '\033]PBCCC989'
    printf '\033]PC8AA8B6'
    printf '\033]PDA293A7'
    printf '\033]PE8EA8A7'
    printf '\033]PFC8CCC8'
    clear
fi
