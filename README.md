# dotfiles

Personal dotfiles for Arch Linux and OpenBSD.

## Stack

| Role | App |
|------|-----|
| WM | Sway (primary) / labwc |
| Bar | Waybar |
| Launcher | Fuzzel |
| Terminal | Foot |
| Shell | Fish |
| Editor | Helix |
| Notifications | Dunst |
| Lock screen | swaylock + swayidle |
| Theming | [coat](https://github.com/jeebuscrossaint/coat) (Base16) |
| File manager | Ranger |
| Browser | Firefox |
| Font | VictorMono Nerd Font |

## Install

```sh
git clone https://github.com/jeebuscrossaint/.dotfiles ~/.dotfiles
cd ~/.dotfiles
stow linux
```

Apply the color theme:

```sh
coat apply
```

Set your Canvas iCal URL for the waybar assignment module:

```sh
mkdir -p ~/.config/canvas
echo "YOUR_CANVAS_ICAL_URL" > ~/.config/canvas/ical-url
```

Install Nerd Fonts on systems without packages (e.g. OpenBSD):

```sh
./install-nerdfonts.sh
```

## Structure

```
linux/                  stowed to $HOME
  .config/              app configs
  .local/bin/           scripts (in PATH automatically)
windows/                PowerShell profile, AHK scripts
misc/                   miscellaneous stuff
install-nerdfonts.sh    download all Nerd Fonts
```

## Scripts

| Script | What it does |
|--------|--------------|
| `volumectl` | Volume control (wpctl on Linux, sndioctl on OpenBSD) |
| `waybar-volume` | Waybar volume widget |
| `waybar-mic` | Waybar mic widget |
| `waybar-temp` | CPU temp (Linux sysfs / OpenBSD sysctl) |
| `waybar-battery` | Battery (Linux sysfs / OpenBSD apm) |
| `waybar-network` | Network status (ip/iw / OpenBSD ifconfig) |
| `waybar-bluetooth` | Bluetooth status (hides on OpenBSD) |
| `waybar-mpris` | Media player via playerctl |
| `waybar-canvas` | Canvas assignment tracker |
| `canvas-ical-fetch` | Fetch and cache Canvas iCal feed |
| `canvas-ical-parse` | Parse iCal events to JSON |
| `canvas-notify` | Dunst alerts for upcoming assignments |
| `swayscreenshot` | Region screenshot to clipboard |
| `toggle-waybar` | Toggle waybar |
| `start-polkit` | Start polkit agent |
| `start-waybar` | Launch waybar |

## Keybinds

| Bind | Action |
|------|--------|
| Super+Q | Terminal (footclient) |
| Super+D | Launcher (fuzzel) |
| Super+C | Close window |
| Super+F | Fullscreen |
| Super+L | Lock screen |
| Super+P | Toggle waybar |
| Super+Shift+S | Screenshot |

## Wallpapers

- https://github.com/rann01/IRIX-tiles
- https://github.com/dharmx/walls
- https://github.com/wallace-aph/tiles-and-such
- https://github.com/tile-anon/tiles
- https://github.com/peteroupc/classic-wallpaper
- https://github.com/makccr/wallpapers
- https://github.com/whoisYoges/lwalpapers
- https://github.com/Axenide/Wallpapers

## Firefox Extensions

uBlock Origin, SponsorBlock, BetterCanvas, Return YouTube Dislike, DocsAfterDark, Proton Pass, Dark Reader
