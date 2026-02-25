#!/bin/sh
# coat TTY theme: Chinoiserie Midnight
# Di Wang (https://cs.cmu.edu/~diw3)
# variant: dark

# Apply Base16 colors to Linux TTY/console
# This script should be run with root privileges or from /etc/profile.d/

if [ "$TERM" = "linux" ]; then
    printf '\033]P01D1D1D'
    printf '\033]P1ED5A56'
    printf '\033]P2AEB831'
    printf '\033]P3FBB957'
    printf '\033]P481A2A2'
    printf '\033]P5CF8997'
    printf '\033]P688B68D'
    printf '\033]P7C4CBCF'
    printf '\033]P8918072'
    printf '\033]P9ED5A56'
    printf '\033]PAAEB831'
    printf '\033]PBFBB957'
    printf '\033]PC81A2A2'
    printf '\033]PDCF8997'
    printf '\033]PE88B68D'
    printf '\033]PFFFFEF9'
    clear
fi
