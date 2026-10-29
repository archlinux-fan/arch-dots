---
title: Wallpapers
wallpapers: [nord0, nord1, nord2, nord3, nord4, nord5, nord6, nord7, nord8, nord9, nord10, nord11, nord12, nord13, nord14, nord15, nord4_light, nord5_light, nord6_light]
---

# Wallpapers

The Arch logo on a smooth gradient, one for each of the 16 [Nord](https://www.nordtheme.com/) colours,
plus three light ones with a dark logo. 3840x2160, lossless PNG and WebP, made by
[make-wallpaper.sh]({{ site.repo_url }}/tree/main/pictures/wallpapers). Click one to see it large.

<ul class="photos">
{% for w in page.wallpapers %}{% capture src %}{{ site.raw }}/pictures/wallpapers/webp/arch_{{ w }}_2160p.webp{% endcapture %}  <li><figure><a href="{{ src }}"><img src="{{ src }}" alt="{{ w | replace: '_', ' ' }}" loading="lazy"></a><figcaption>{{ w | replace: '_', ' ' }}</figcaption></figure></li>
{% endfor %}</ul>

The PNG files are in [pictures/wallpapers/png]({{ site.repo_url }}/tree/main/pictures/wallpapers/png).
