#!/usr/bin/env bash

if pgrep -x waybar > /dev/null; then
    pkill -x waybar
else
    waybar -c ~/.config/waybar/config.json -s ~/.config/waybar/style.css &
fi
