#!/bin/sh
# coat TTY theme: Grayscale Dark
# Alexandre Gavioli (https://github.com/Alexx2/)
# variant: dark

# Apply Base16 colors to Linux TTY/console
# This script should be run with root privileges or from /etc/profile.d/

if [ "$TERM" = "linux" ]; then
    printf '\033]P0101010'
    printf '\033]P17C7C7C'
    printf '\033]P28E8E8E'
    printf '\033]P3A0A0A0'
    printf '\033]P4686868'
    printf '\033]P5747474'
    printf '\033]P6868686'
    printf '\033]P7B9B9B9'
    printf '\033]P8525252'
    printf '\033]P97C7C7C'
    printf '\033]PA8E8E8E'
    printf '\033]PBA0A0A0'
    printf '\033]PC686868'
    printf '\033]PD747474'
    printf '\033]PE868686'
    printf '\033]PFF7F7F7'
    clear
fi
