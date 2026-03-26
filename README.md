# dotfiles

My personal dotfiles for Arch Linux (Hyprland) and Windows.

## Stack

| Role | App |
|------|-----|
| WM | Hyprland |
| Bar | Waybar |
| Launcher | Anyrun |
| Terminal | Kitty |
| Shell | Fish + Starship |
| Editor | Helix |
| Notifications | Dunst |
| Lock screen | gtklock + swayidle |
| Theming | [coat](https://github.com/jeebuscrossaint/coat) (Base16) |
| File manager | yazi |

## Install

```bash
git clone https://github.com/jeebuscrossaint/.dotfiles ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

Requires [GNU Stow](https://www.gnu.org/software/stow/) — symlinks everything from `linux/` into `$HOME`. After installing, apply the color theme:

```bash
coat apply
```

## Structure

```
linux/           stowed to $HOME
  .config/       app configs
  .local/bin/    scripts (in PATH automatically)
windows/         PowerShell profile, package list, AHK scripts
misc/            miscellaneous stuff
```

## Scripts (in PATH via ~/.local/bin)

| Script | Keybind | What it does |
|--------|---------|--------------|
| `swayscreenshot` | Super+Shift+S | Region screenshot → swappy |
| `toggle-waybar` | Super+P | Toggle waybar on/off |
| `wlboard` | Super+Delete | Clipboard picker via cliphist + bemenu |

## Wallpaper repos

- https://github.com/rann01/IRIX-tiles
- https://github.com/dharmx/walls
- https://github.com/wallace-aph/tiles-and-such
- https://github.com/tile-anon/tiles
- https://github.com/peteroupc/classic-wallpaper
- https://github.com/makccr/wallpapers
- https://github.com/whoisYoges/lwalpapers
- https://github.com/Axenide/Wallpapers

## Browser Extensions (LibreWolf)

uBlock Origin, SponsorBlock, BetterCanvas, Return YouTube Dislike, DocsAfterDark, Proton Pass, Dark Reader
