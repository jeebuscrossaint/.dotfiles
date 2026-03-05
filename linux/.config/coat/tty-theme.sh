#!/bin/sh
# coat TTY theme: Bright
# Chris Kempson (http://chriskempson.com)
# variant: dark

# Apply Base16 colors to Linux TTY/console
# This script should be run with root privileges or from /etc/profile.d/

if [ "$TERM" = "linux" ]; then
    printf '\033]P0000000'
    printf '\033]P1FB0120'
    printf '\033]P2A1C659'
    printf '\033]P3FDA331'
    printf '\033]P46FB3D2'
    printf '\033]P5D381C3'
    printf '\033]P676C7B7'
    printf '\033]P7E0E0E0'
    printf '\033]P8B0B0B0'
    printf '\033]P9FB0120'
    printf '\033]PAA1C659'
    printf '\033]PBFDA331'
    printf '\033]PC6FB3D2'
    printf '\033]PDD381C3'
    printf '\033]PE76C7B7'
    printf '\033]PFFFFFFF'
    clear
fi
