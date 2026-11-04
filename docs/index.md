---
title: arch-dots
screenshots:
  - { file: desktop, text: "Desktop with a Nord wallpaper and waybar" }
  - { file: fastfetch, text: "fastfetch in foot, Nord palette" }
  - { file: thunar, text: "Thunar; mic muted, 42 updates listed on hover" }
  - { file: rofi, text: "rofi app launcher; webcam driver unloaded" }
  - { file: ristretto, text: "Ristretto image viewer" }
  - { file: btop, text: "btop; an AUR update" }
  - { file: satty, text: "satty screenshot editor; sound muted" }
  - { file: lock, text: "hyprlock lock screen" }
  - { file: confirm, text: "Reboot / power off asks first (power-confirm); power icon on hover" }
  - { file: brave, text: "Brave with the startpage, vertical tabs collapsed" }
---

# arch-dots

A shared mango desktop for Arch Linux: waybar, rofi, foot, mako, Thunar and Nord themes.
It is installed by [arch-install]({{ site.install_url }}). Click a picture to see it large;
‹ › or the arrow keys go to the next one.

![waybar: keyboard layout, updates, webcam, firewall, sound, mic, Bluetooth, Wi-Fi, clock, battery, power]({{ site.raw }}/screenshots/waybar.png)

Muted sound or mic turns grey, the update counters go green, orange, red; hover shows what each click does.

<ul class="photos">
{% for s in page.screenshots %}  <li><figure><a href="{{ site.raw }}/screenshots/{{ s.file }}.png"><img src="{{ '/assets/thumbs/' | append: s.file | append: '.webp' | relative_url }}" alt="{{ s.text }}" loading="lazy"></a><figcaption>{{ s.text }}</figcaption></figure></li>
{% endfor %}</ul>

Screenshots are 4K (3840x2160). Wallpapers in all 16 Nord colours: [Wallpapers]({{ '/wallpapers.html' | relative_url }}).
