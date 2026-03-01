#!/bin/sh
# coat TTY theme: Wallpaper
# coat (extracted)
# variant: dark

# Apply Base16 colors to Linux TTY/console
# This script should be run with root privileges or from /etc/profile.d/

if [ "$TERM" = "linux" ]; then
    printf '\033]P0333230'
    printf '\033]P1F3CFAF'
    printf '\033]P2C7AE9F'
    printf '\033]P38E4226'
    printf '\033]P4F3CFAF'
    printf '\033]P5F3CFAF'
    printf '\033]P6F3CFAF'
    printf '\033]P7AEA9A9'
    printf '\033]P87F7A77'
    printf '\033]P9F3CFAF'
    printf '\033]PAC7AE9F'
    printf '\033]PB8E4226'
    printf '\033]PCF3CFAF'
    printf '\033]PDF3CFAF'
    printf '\033]PEF3CFAF'
    printf '\033]PFDDDBDD'
    clear
fi
