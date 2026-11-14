---
title: arch-dots
screenshots:
  - { file: desktop, text: "Desktop with a Nord wallpaper and waybar" }
  - { file: fastfetch, text: "fastfetch in foot, Nord palette" }
  - { file: thunar, text: "Thunar; mic muted, 42 updates listed on hover" }
  - { file: fuzzel, text: "fuzzel app launcher" }
  - { file: ristretto, text: "Ristretto image viewer" }
  - { file: btop, text: "btop" }
  - { file: swappy, text: "swappy screenshot editor (Shift+Print)" }
  - { file: swaylock, text: "swaylock lock screen" }
  - { file: hyprlock, text: "hyprlock lock screen, if you install it instead" }
  - { file: confirm, text: "Reboot / power off asks first in fuzzel (power-confirm)" }
  - { file: firefox, text: "Firefox with the startpage, vertical tabs collapsed" }
  - { file: fuzzel-sound, text: "Sound output menu (Super+Alt+S)" }
  - { file: fuzzel-bluetooth, text: "Bluetooth menu (Super+Alt+B)" }
  - { file: fuzzel-wifi, text: "Wi-Fi menu (Super+Alt+W), made-up network names" }
  - { file: fuzzel-ssh, text: "SSH menu with the hosts from ~/.ssh/config (Super+Alt+Return), made-up names" }
  - { file: homelab, text: "homelab-ssh in foot, on tag 5" }
---

# arch-dots

The settings behind this desktop for Arch Linux: mango arranges the windows side by side,
waybar is the bar at the top, fuzzel the app menu, foot the terminal, all in the Nord colours.
New to Arch? [arch-install]({{ site.install_url }}) installs it step by step, these settings included.
The keyboard shortcuts are listed in the [README]({{ site.repo_url }}#keys).

Click a picture to see it large; ‹ › or the arrow keys go to the next one.

![waybar: keyboard layout, updates, webcam, firewall, sound, mic, Bluetooth, Wi-Fi, clock, battery, power]({{ site.raw }}/screenshots/waybar.png)

Muted sound or mic turns grey, the update counters go green, orange, red; hover shows what each click does.

<ul class="photos">
{% for s in page.screenshots %}  <li><figure><a href="{{ site.raw }}/screenshots/{{ s.file }}.png"><img src="{{ '/assets/thumbs/' | append: s.file | append: '.webp' | relative_url }}" alt="{{ s.text }}" loading="lazy"></a><figcaption>{{ s.text }}</figcaption></figure></li>
{% endfor %}</ul>

Screenshots are 4K (3840x2160). Wallpapers in all 16 Nord colours: [Wallpapers]({{ '/wallpapers.html' | relative_url }}). Want another colour or size? [Make your own]({{ site.generator_url }}).
