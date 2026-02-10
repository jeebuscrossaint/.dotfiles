# dotfiles

My personal dotfiles repository for Linux and Windows.

## Quick Start

### Linux

**Requirements:** GNU Stow
```sh
# Install stow first
sudo pacman -S stow        # Arch/Manjaro
sudo apt install stow      # Debian/Ubuntu

# Install dotfiles
./install.sh               # Symlinks linux/ to $HOME using stow

# Uninstall dotfiles
stow -D linux              # Remove symlinks
```

### Structure
```
linux/.config/      # All XDG config files
  bat/
  btop/
  dunst/
  fish/
  helix/
  i3/
  kitty/
  labwc/
  mango/
  rofi/
  sway/
  swaylock/
  starship.toml

windows/
  starship.toml
  Microsoft.PowerShell_profile.ps1
  windowspkgs.txt
```

---

## Browser Extensions
LibreWolf extensions: ublock, sponsorblock, bettercanvas, return-dislike-youtube, docsafterdark, proton-pass, dark-reader

### Windows Setup
put starship.toml in .config
put the freaky powershell config in Documents/Powershell
install scoop
install packages listed in the txt

---

## Minecraft Mods
Prism Launcher modlist:
3d-Skin-Layers 
AppleSkin 
Armor Hud 
BetterHurtCam 
Client Commands 
Cloth Config v20 
Dynamic FPS 
EntityCulling 
Fabric API 
Fabric Language Kotlin 
FerriteCore 
Forge Config API Port 
Gamma Utils 
HUD Lib 
ImmediatelyFast 
Iris 
Jade 
Lithium 
Mod Menu 
More Culling 
Mouse Tweaks 
No Report Button 
Placeholder API 
Remove Reloading Screen 
Shulker Box Tooltip 
Sodium 
Sodium Extra 
WaveyCapes 
YetAnotherConfigLib 
Zoomify 
essential-container 
ukulib

wallpaper repos for additional epic:
https://github.com/rann01/IRIX-tiles
https://github.com/dharmx/walls
https://github.com/wallace-aph/tiles-and-such
https://github.com/tile-anon/tiles
https://github.com/whoisYoges/lwalpapers
https://github.com/D3Ext/aesthetic-wallpapers
https://github.com/peteroupc/classic-wallpaper
https://github.com/dixiedream/wallpapers
https://github.com/mylinuxforwork/wallpaper
https://github.com/makccr/wallpapers
https://github.com/Axenide/Wallpapers
https://github.com/l3ct3r/wallpapers
https://github.com/dmighty007/WallPapers
https://github.com/DenverCoder1/minimalistic-wallpaper-collection
https://github.com/BitterSweetcandyshop/wallpapers
https://github.com/linuxdotexe/nordic-wallpapers
