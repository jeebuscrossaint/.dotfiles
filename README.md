# dotfiles

My personal dotfiles for Arch Linux and OpenBSD. Cross-platform where possible.

## Stack

| Role | App |
|------|-----|
| WM | Sway / Hyprland / labwc |
| Bar | Waybar |
| Launcher | Fuzzel |
| Terminal | Foot |
| Shell | Fish |
| Editor | Helix |
| Notifications | Dunst |
| Lock screen | swaylock + swayidle |
| Theming | [coat](https://github.com/jeebuscrossaint/coat) (Base16) |
| File manager | yazi |
| Font | VictorMono Nerd Font |

## Install

```sh
git clone https://github.com/jeebuscrossaint/.dotfiles ~/.dotfiles
cd ~/.dotfiles
stow linux
```

Then apply the color theme:

```sh
coat apply
```

Set your Canvas iCal URL for the waybar assignment module:

```sh
mkdir -p ~/.config/canvas
echo "YOUR_CANVAS_ICAL_URL" > ~/.config/canvas/ical-url
```

For Nerd Fonts on systems without packages (e.g. OpenBSD):

```sh
./install-nerdfonts.sh
```

## Structure

```
linux/           stowed to $HOME
  .config/       app configs
  .local/bin/    scripts (in PATH automatically)
windows/         PowerShell profile, AHK scripts
misc/            miscellaneous stuff
install-nerdfonts.sh   download and install all Nerd Fonts
```

## Scripts (in PATH via ~/.local/bin)

| Script | What it does |
|--------|--------------|
| `volumectl` | Cross-platform volume control (wpctl / sndioctl) |
| `waybar-volume` | Waybar volume widget |
| `waybar-mic` | Waybar mic widget |
| `waybar-temp` | Waybar CPU temp (Linux sysfs / OpenBSD sysctl) |
| `waybar-battery` | Waybar battery (Linux sysfs / OpenBSD apm) |
| `waybar-network` | Waybar network (ip/iw / OpenBSD ifconfig) |
| `waybar-bluetooth` | Waybar bluetooth (hides on OpenBSD) |
| `waybar-mpris` | Waybar media player via playerctl |
| `waybar-canvas` | Waybar Canvas assignment tracker |
| `canvas-ical-fetch` | Fetch/cache Canvas iCal feed |
| `canvas-ical-parse` | Parse iCal events to JSON |
| `canvas-notify` | Dunst notifications for upcoming assignments |
| `swayscreenshot` | Region screenshot → clipboard |
| `toggle-waybar` | Toggle waybar on/off |
| `start-polkit` | Start polkit agent (tries common paths) |
| `start-waybar` | Launch waybar with correct env |

## Keybinds (Sway / Hyprland / labwc)

| Bind | Action |
|------|--------|
| Super+Q | Terminal (footclient) |
| Super+D | Launcher (fuzzel) |
| Super+C | Close window |
| Super+F | Fullscreen |
| Super+L | Lock screen |
| Super+P | Toggle waybar |
| Super+Shift+S | Screenshot |
| Super+Delete | wlboard |

## Wallpaper repos

- https://github.com/rann01/IRIX-tiles
- https://github.com/dharmx/walls
- https://github.com/wallace-aph/tiles-and-such
- https://github.com/tile-anon/tiles
- https://github.com/peteroupc/classic-wallpaper
- https://github.com/makccr/wallpapers
- https://github.com/whoisYoges/lwalpapers
- https://github.com/Axenide/Wallpapers

## Browser Extensions

uBlock Origin, SponsorBlock, BetterCanvas, Return YouTube Dislike, DocsAfterDark, Proton Pass, Dark Reader
