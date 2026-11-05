# arch-dots

The settings behind the desktop in the pictures, for Arch Linux. Programs keep their settings in files
whose names start with a dot (hidden files), hence "dotfiles". Here they are for:

- **mango**: arranges the windows (tiling: side by side, no overlapping) and holds the keyboard shortcuts
- **waybar**: the bar at the top, **rofi**: the app menu, **mako**: notifications
- **foot**: the terminal, **bash** the shell inside it (or **zsh**, with suggestions from your history)
- **swaylock**: the lock screen, **Thunar**: files, all in the [Nord](https://www.nordtheme.com/) colours

New to Arch? [arch-install](https://github.com/archlinux-fan/arch-install) installs Arch step by step and puts these files in place
(`desktop/70-dotfiles.sh`); guide: [archlinux-fan.github.io/arch-install](https://archlinux-fan.github.io/arch-install/).
Screenshots and wallpapers as a website: [archlinux-fan.github.io/arch-dots](https://archlinux-fan.github.io/arch-dots/)

![Desktop with the Nord wallpaper and waybar](screenshots/desktop.png)

![waybar](screenshots/waybar.png)
waybar: keyboard layout, updates (official repos, AUR), webcam, firewall, sound, mic, Bluetooth, Wi-Fi, clock, battery, power.
Muted sound or mic turns grey, the update counters go green, orange, red; hover shows what each click does.

| | |
|---|---|
| ![fastfetch in foot](screenshots/fastfetch.png) | ![Thunar](screenshots/thunar.png) |
| fastfetch in foot, Nord palette | Thunar; mic muted, 42 updates listed on hover |
| ![rofi app launcher](screenshots/rofi.png) | ![Ristretto](screenshots/ristretto.png) |
| rofi app launcher; webcam driver unloaded | Ristretto image viewer |
| ![btop](screenshots/btop.png) | ![satty](screenshots/satty.png) |
| btop; an AUR update | satty screenshot editor; sound muted |
| ![swaylock lock screen](screenshots/swaylock.png) | ![hyprlock lock screen](screenshots/hyprlock.png) |
| swaylock lock screen | hyprlock lock screen, if you install it instead |
| ![Reboot confirmation](screenshots/confirm.png) | ![Brave](screenshots/brave.png) |
| Reboot / power off asks first (`power-confirm`); power icon on hover | Brave with the startpage, vertical tabs collapsed |

Screenshots are 4K (3840x2160); click one for full size.

Wallpapers in all 16 Nord colours, and the script that makes them: [pictures/wallpapers](pictures/wallpapers/).

## Keys

Super is the Windows key. All of them, with comments: [.config/mango/keybindings.toml](.config/mango/keybindings.toml).

| Keys | What it does |
|---|---|
| Super+Return | terminal |
| Super+Space | app menu: type a few letters, Enter starts it |
| Super+B / T / E | browser / files / text editor |
| Super+Q | close the window |
| Super+F | full screen |
| Super+V | let the window float, or tile it again |
| Super+mouse drag | left button moves a window, right button resizes it |
| Super+arrows | go to the window on the left, right, above, below |
| Super+1 … 0 | show tag (workspace) 1 … 10 |
| Super+Ctrl+1 … 0 | move the window to tag 1 … 10 |
| Super+L | lock the screen |
| Super+U | install updates |
| Print / Shift+Print | screenshot of a region / of the frozen screen, to draw on in satty |
| Super+P | pick a colour anywhere on the screen |
| Super+Ctrl+Shift+R / P | reboot / power off (asks first) |
| Alt+Shift | next keyboard layout, if you set two (example in `general.toml`) |

## Install by hand

arch-install does this for you. The repo mirrors your home folder (`~`): `.config/mango/config.toml` here
belongs in `~/.config/mango/config.toml`. Copy its files into `~`, without the repo's own README, docs and screenshots:

```bash
git clone --depth 1 https://github.com/archlinux-fan/arch-dots /tmp/dots
cp -r /tmp/dots/.config /tmp/dots/.local /tmp/dots/pictures /tmp/dots/.bash_profile /tmp/dots/.zshenv ~
```

Want your changes in git? Link the files instead of copying them: [stow](https://www.gnu.org/software/stow/)
puts a link in `~` for every file, so a change in `~` is a change in the repo
(arch-install: `dots_link=y` in its settings file):

```bash
git clone https://github.com/archlinux-fan/arch-dots ~/.dots
stow --no-folding -d ~/.dots -t ~ .      # link
stow -D -d ~/.dots -t ~ .                # unlink
```

If a file already exists in `~`, stow stops and names it; move it away and run stow again.
`--no-folding` links single files, not whole folders, so other repos can add files to the same folders.

Personal files (ssh, git name and e-mail, monitors, keyboard layout) belong in a private repo linked the same way.
`~/.config/mango/local.toml` from there is read by `config.toml` after the shared settings.

GTK apps on Wayland take the theme, icons, cursor and font from gsettings, not from `settings.ini`.
They are saved outside the repo; arch-install sets them, by hand it's once:

```bash
gsettings set org.gnome.desktop.interface gtk-theme 'Nordic-bluish-accent-standard-buttons'
gsettings set org.gnome.desktop.interface icon-theme 'Nordzy'
gsettings set org.gnome.desktop.interface cursor-theme 'Nordzy-cursors-white'
gsettings set org.gnome.desktop.interface cursor-size 24
gsettings set org.gnome.desktop.interface font-name 'Noto Sans 11'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
```
