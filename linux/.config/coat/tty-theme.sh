#!/bin/sh
# coat TTY theme: Default Dark
# Chris Kempson (http://chriskempson.com)
# variant: dark

# Apply Base16 colors to Linux TTY/console
# This script should be run with root privileges or from /etc/profile.d/

if [ "$TERM" = "linux" ]; then
    printf '\033]P0181818'
    printf '\033]P1AB4642'
    printf '\033]P2A1B56C'
    printf '\033]P3F7CA88'
    printf '\033]P47CAFC2'
    printf '\033]P5BA8BAF'
    printf '\033]P686C1B9'
    printf '\033]P7D8D8D8'
    printf '\033]P8585858'
    printf '\033]P9AB4642'
    printf '\033]PAA1B56C'
    printf '\033]PBF7CA88'
    printf '\033]PC7CAFC2'
    printf '\033]PDBA8BAF'
    printf '\033]PE86C1B9'
    printf '\033]PFF8F8F8'
    clear
fi
