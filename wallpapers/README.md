# Wallpapers

Arch Linux wallpapers, 3840x2160, three for each of the 16 [Nord](https://www.nordtheme.com/) colours:
white logo, dark logo (`_darklogo`) and a logo in the background's tone (`_tonelogo`).

- `png/` and `webp/` hold the same images, both lossless (about 90 KB and 30 KB).
- `login_nord*.png` are 512x512 icons for the lock screen.

Want another colour or size? [Make your own](https://archlinux-fan.github.io/arch-wallpaper/) in the browser.

## Use them

`~/.config/mango/wallpaper.sh` picks one wallpaper per tag (the `walls` list).
Try one right away (Ctrl+C brings the old one back):

```bash
swaybg -m fill -i ~/.dots/wallpapers/webp/arch_nord11_2160p.webp
```
