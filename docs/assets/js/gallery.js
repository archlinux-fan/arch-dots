// Pictures open large over the page, growing out of the small picture and shrinking
// back into it. A .photos list is a gallery (‹ › or the arrow keys go through it),
// any other picture in the text opens on its own. Escape, × or a click beside the
// picture close it. Without this script a click opens the file.
{
  const box = document.createElement('dialog');
  box.className = 'lightbox';
  box.innerHTML = '<figure><img alt=""><figcaption></figcaption></figure>'
    + '<button type="button" class="close" aria-label="Close">×</button>'
    + '<button type="button" class="prev" aria-label="Previous">‹</button>'
    + '<button type="button" class="next" aria-label="Next">›</button>';
  document.body.append(box);
  const big = box.querySelector('img'), caption = box.querySelector('figcaption');
  const still = matchMedia('(prefers-reduced-motion: reduce)');
  const timing = { duration: 260, easing: 'cubic-bezier(.2, .9, .3, 1)' };
  let items = [], index = 0, shade = '', closing = false;

  // Each item: the small picture, the large file and its caption
  const groups = [...document.querySelectorAll('.photos')].map((list) =>
    [...list.querySelectorAll('figure')].map((figure) => ({
      thumb: figure.querySelector('img'),
      src: figure.querySelector('a').href,
      text: figure.querySelector('figcaption')?.textContent || '',
    })));
  for (const img of document.querySelectorAll('main img')) {
    if (!img.closest('.photos')) groups.push([{ thumb: img, src: img.src, text: img.alt }]);
  }

  const show = (i) => {
    index = (i + items.length) % items.length;
    big.src = items[index].src;
    big.alt = caption.textContent = items[index].text;
  };

  // The large picture moved and scaled over its small one; just faded if that is off screen
  const small = () => {
    const t = items[index].thumb.getBoundingClientRect(), b = big.getBoundingClientRect();
    if (!b.width || t.bottom < 0 || t.top > innerHeight) return { opacity: 0, transform: 'scale(.96)' };
    const x = t.left + t.width / 2 - (b.left + b.width / 2), y = t.top + t.height / 2 - (b.top + b.height / 2);
    return { opacity: 1, transform: `translate(${x}px, ${y}px) scale(${t.width / b.width})` };
  };
  const large = { opacity: 1, transform: 'none' };

  // The dark background, caption and buttons fade with the picture
  const fade = (into, options) => {
    const dark = [{ backgroundColor: 'transparent' }, { backgroundColor: shade }];
    box.animate(into ? dark : dark.reverse(), options);
    for (const el of [caption, ...box.querySelectorAll('button')]) {
      el.animate([{ opacity: into ? 0 : 1 }, { opacity: into ? 1 : 0 }], options);
    }
  };

  const open = async (group, i) => {
    items = group;
    show(i);
    box.classList.toggle('single', items.length < 2);
    try { await big.decode(); } catch { /* opens without growing */ }
    closing = false;
    box.showModal();
    if (still.matches) return;
    shade = getComputedStyle(box).backgroundColor;
    big.animate([small(), large], timing);
    fade(true, timing);
  };

  const close = () => {
    if (!box.open || closing) return;
    if (still.matches) return box.close();
    closing = true;
    const options = { ...timing, fill: 'forwards' };
    fade(false, options);
    big.animate([large, small()], options).finished.then(() => box.close(), () => {});
  };

  const step = (by) => {
    show(index + by);
    if (!still.matches) big.animate([{ opacity: .3 }, { opacity: 1 }], { duration: 160 });
  };

  for (const group of groups) {
    group.forEach((item, i) => (item.thumb.closest('a') || item.thumb).addEventListener('click', (event) => {
      event.preventDefault();
      open(group, i);
    }));
  }
  box.querySelector('.close').addEventListener('click', close);
  box.querySelector('.prev').addEventListener('click', () => step(-1));
  box.querySelector('.next').addEventListener('click', () => step(1));
  box.addEventListener('click', (event) => { if (event.target === box) close(); });
  box.addEventListener('cancel', (event) => { event.preventDefault(); close(); });
  box.addEventListener('close', () => {
    closing = false;
    for (const animation of box.getAnimations({ subtree: true })) animation.cancel();
  });
  box.addEventListener('keydown', (event) => {
    if (event.key === 'ArrowLeft') step(-1);
    if (event.key === 'ArrowRight') step(1);
  });
}
