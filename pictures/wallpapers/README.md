# Wallpapers

Arch Linux wallpapers, 3840x2160, one for each of the 16 [Nord](https://www.nordtheme.com/) colours
plus three light ones, made by `make-wallpaper.sh`: a smooth vertical gradient and the Arch logo.

- `png/` and `webp/` hold the same images, both lossless (about 90 KB and 30 KB).
- The logo is 1.5x the size of a 1440p wallpaper, so on a 4K screen at scale 2 it looks the same.
- The gradient is rounded to 8 bits with ordered dithering, so it has no visible bands.
  Lossy WebP would bring the bands back and is no smaller here, so there is none.

## Make one

```bash
./make-wallpaper.sh '#BF616A' arch_nord11     # colour, name
```

Writes `png/arch_nord11_2160p.png` and `webp/arch_nord11_2160p.webp`. Any colour works: the top is
darkened to a calm tone (brightest channel at most 120), the bottom is 46 % of the top.

## Make all 16

```bash
while read n c; do ./make-wallpaper.sh "$c" arch_$n; done <<'EOF'
nord0 #2E3440
nord1 #3B4252
nord2 #434C5E
nord3 #4C566A
nord4 #D8DEE9
nord5 #E5E9F0
nord6 #ECEFF4
nord7 #8FBCBB
nord8 #88C0D0
nord9 #81A1C1
nord10 #5E81AC
nord11 #BF616A
nord12 #D08770
nord13 #EBCB8B
nord14 #A3BE8C
nord15 #B48EAD
EOF
```

## Light ones

The Snow Storm colours (nord4-6) are near white, so they also come as light wallpapers with a
dark (nord1) logo. A logo colour as third argument keeps the colour as is (bottom 88 %):

```bash
./make-wallpaper.sh '#D8DEE9' arch_nord4_light '#3B4252'
./make-wallpaper.sh '#E5E9F0' arch_nord5_light '#3B4252'
./make-wallpaper.sh '#ECEFF4' arch_nord6_light '#3B4252'
```

## Lock screen pictures

`-l` makes a 512x512 picture with only the icon, for the round image on the hyprlock screen
(`image { path = ... }` in `~/.config/hypr/hyprlock.conf`). Same colours as the wallpaper of that name:

```bash
./make-wallpaper.sh -l '#ECEFF4' login_nord6_light '#3B4252'
./make-wallpaper.sh -l '#434C5E' login_nord2
./make-wallpaper.sh -l '#3B4252' login_nord1
```

## Use them

`~/.config/hypr/keybindings.lua` picks one wallpaper per workspace (the `wallpapers` list).
Try one right away:

```bash
hyprctl hyprpaper wallpaper ",$HOME/pictures/wallpapers/webp/arch_nord11_2160p.webp"
```

Needs `vips` and `rsvg-convert`: `sudo pacman -S libvips librsvg`. The logo comes with Arch itself
(`/usr/share/pixmaps/archlinux-logo-text.svg`).
