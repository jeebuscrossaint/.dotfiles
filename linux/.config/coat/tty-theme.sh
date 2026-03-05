#!/bin/sh
# coat TTY theme: Charcoal Dark
# Mubin Muhammad (https://github.com/mubin6th)
# variant: dark

# Apply Base16 colors to Linux TTY/console
# This script should be run with root privileges or from /etc/profile.d/

if [ "$TERM" = "linux" ]; then
    printf '\033]P00F0B05'
    printf '\033]P1A88C62'
    printf '\033]P2DEC8A7'
    printf '\033]P3DEC8A7'
    printf '\033]P4C3A983'
    printf '\033]P5A88C62'
    printf '\033]P6DEC8A7'
    printf '\033]P7C3A983'
    printf '\033]P857462C'
    printf '\033]P9A88C62'
    printf '\033]PADEC8A7'
    printf '\033]PBDEC8A7'
    printf '\033]PCC3A983'
    printf '\033]PDA88C62'
    printf '\033]PEDEC8A7'
    printf '\033]PF231B0E'
    clear
fi
