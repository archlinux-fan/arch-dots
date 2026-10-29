#!/bin/bash
# Arch wallpaper, 3840x2160: vertical gradient in one colour and the Arch logo (white or own colour).
# Writes png/ and webp/ (both lossless) next to this script.
# Usage: make-wallpaper.sh [-l] <#rrggbb> <name> [#logo]
#   dark:  make-wallpaper.sh '#BF616A' arch_nord11              white logo, colour darkened
#   light: make-wallpaper.sh '#ECEFF4' arch_nord6_light '#3B4252'   logo in that colour, colour as is
#   -l:    lock screen picture instead: 512x512, icon only, saved as <name>.png next to this script
# Needs vips (libvips) and rsvg-convert (librsvg); the logo comes with the filesystem package.
set -euo pipefail
export VIPS_WARNING=0
login=; [ "$1" = -l ] && { login=1; shift; }
color=$1 name=$2 logo=${3:-}
W=3840 H=2160; [ $login ] && W=512 H=512
dir=$(dirname "$(readlink -f "$0")")
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"

# Logo: the icon (path starting at x=45.148) and the word "archlinux", without the ™ marks.
src=/usr/share/pixmaps/archlinux-logo-text.svg
paths=$(grep -o '<path[^>]*>' $src | sed -E "s/fill=\"[^\"]*\"/fill=\"${logo:-#ffffff}\"/")
icon=$(grep 'm45.148 ' <<<"$paths")
text=$(grep -E 'd="m(8[5-9]|9[0-9]|1[0-9]{2}|2[0-2][0-9])\.' <<<"$paths")

# Bounding box of a path group in SVG units: render at 32 px per unit and trim.
bbox() {
    printf '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 256 85.085" width="8192" height="2723">%s</svg>' "$1" > b.svg
    rsvg-convert b.svg -o b.png
    vips extract_band b.png a.png 3
    vips find_trim a.png --threshold 1 --background 0 | tr '\n' ' ' | awk '{print $1/32, $2/32, $3/32}'
}
read ix iy iw < <(bbox "$icon")
read tx ty tw < <(bbox "$text")

# Icon 159 px wide at (1840.5, 925.5), text 376.5 px wide at (1731, 1114.5): 1.5x the old
# 1440p wallpapers, so the logo looks the same size on a 4K screen at scale 2.
place() { awk -v w=$1 -v x=$2 -v y=$3 -v tw=$4 -v px=$5 -v py=$6 'BEGIN{s=tw/w; printf "translate(%f %f) scale(%f)", px-s*x, py-s*y, s}'; }
printf '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d"><g transform="%s">%s</g><g transform="%s">%s</g></svg>' \
    $W $H "$(place $iw $ix $iy 159 1840.5 925.5)" "$icon" "$(place $tw $tx $ty 376.5 1731 1114.5)" "$text" > logo.svg
# Lock screen: icon only, 60 % of the width, a bit above the middle.
[ $login ] && printf '<svg xmlns="http://www.w3.org/2000/svg" width="%d" height="%d"><g transform="%s">%s</g></svg>' \
    $W $H "$(place $iw $ix $iy 307.2 102.4 81)" "$icon" > logo.svg
rsvg-convert logo.svg -o logo.png

# Colours. White logo: top = the colour darkened until its brightest channel is at most 120
# (calm, the logo stays readable), bottom = 46 % of the top.
# Own logo colour (light wallpapers): top = the colour as is, bottom = 88 % of it.
read r1 g1 b1 r2 g2 b2 < <(printf '%d %d %d\n' 0x${color:1:2} 0x${color:3:2} 0x${color:5:2} |
    awk -v light=${logo:+1} '{m=$1; if($2>m)m=$2; if($3>m)m=$3; t=(!light && m>120)?120/m:1; f=light?0.88:0.46
          for(i=1;i<=3;i++) top[i]=$i*t; print top[1], top[2], top[3], top[1]*f, top[2]*f, top[3]*f}')
slope() { awk -v a=$1 -v b=$2 -v h=$H 'BEGIN{print (b-a)/(h-1)}'; }

# Gradient in floating point, row by row from top to bottom.
vips xyz xy.v $W $H
vips extract_band xy.v y.v 1
vips linear -- y.v grad.v "$(slope $r1 $r2) $(slope $g1 $g2) $(slope $b1 $b2)" "$r1 $g1 $b1"

# Ordered (8x8 Bayer) dithering when rounding to 8 bits: no bands, and it compresses well.
printf '8 8\n0 32 8 40 2 34 10 42\n48 16 56 24 50 18 58 26\n12 44 4 36 14 46 6 38\n60 28 52 20 62 30 54 22\n3 35 11 43 1 33 9 41\n51 19 59 27 49 17 57 25\n15 47 7 39 13 45 5 37\n63 31 55 23 61 29 53 21\n' > bayer.mat
vips matrixload bayer.mat bayer.v
vips replicate bayer.v tile.v $((W / 8)) $((H / 8))
vips linear tile.v dither.v 0.015625 0.0078125
vips add grad.v dither.v sum.v
vips cast sum.v bg.v uchar

# Logo over the background, saved as PNG and lossless WebP. Lossy WebP is not smaller
# here and brings the bands back, so there is none.
vips composite2 bg.v logo.png comp.v over
vips extract_band comp.v out.v 0 --n 3
if [ $login ]; then vips pngsave out.v "$dir/$name.png" --compression 9; ls -l "$dir/$name.png" | awk '{print $5, $9}'; exit; fi
mkdir -p "$dir/png" "$dir/webp"
vips pngsave out.v "$dir/png/${name}_2160p.png" --compression 9
vips webpsave out.v "$dir/webp/${name}_2160p.webp" --lossless --effort 6
ls -l "$dir"/{png/${name}_2160p.png,webp/${name}_2160p.webp} | awk '{print $5, $9}'
