#!/bin/sh
# coat TTY theme: Elementary
# FredHappyface (https://github.com/fredHappyface)
# variant: dark

# Apply Base16 colors to Linux TTY/console
# This script should be run with root privileges or from /etc/profile.d/

if [ "$TERM" = "linux" ]; then
    printf '\033]P0181818'
    printf '\033]P1D61B15'
    printf '\033]P259A413'
    printf '\033]P30855FE'
    printf '\033]P4053A8C'
    printf '\033]P5E40038'
    printf '\033]P62594E0'
    printf '\033]P7C5C5C5'
    printf '\033]P8737373'
    printf '\033]P9D61B15'
    printf '\033]PA59A413'
    printf '\033]PB0855FE'
    printf '\033]PC053A8C'
    printf '\033]PDE40038'
    printf '\033]PE2594E0'
    printf '\033]PF8C00EB'
    clear
fi
