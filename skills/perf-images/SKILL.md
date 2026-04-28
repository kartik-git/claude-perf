---
name: perf-images
description: Image optimization audit — modern formats (WebP/AVIF), responsive srcset, lazy loading, explicit dimensions, decoding hints, and image CDN strategy.
type: skill
parent: perf
---

# `perf-images` — Image Optimization

## Scope

Inspect every image referenced by the page (HTML `<img>`, CSS `background-image`,
`<picture>` sources, SVG `<image>`, inline data URIs). Measure size, dimensions, format,
loading attributes, and produce concrete optimization recommendations.

## When to invoke

- `/perf images <url>` — explicit
- During `/perf audit` — covered by `perf-agent-render` (delegates to this skill)
- Mentions of: "image weight", "WebP", "AVIF", "lazy loading", "responsive images",
  "srcset", "image CDN", "Cloudinary", "Imgix"

## Analysis checklist

### Format
1. **Modern formats** — count images served as WebP, AVIF, JPEG, PNG, GIF.
2. **AVIF beats WebP** for photos (~20–30% smaller); WebP beats JPEG (~25%).
3. **`<picture>` with fallback** — recommend the pattern:
   ```html
   <picture>
     <source srcset="hero.avif" type="image/avif">
     <source srcset="hero.webp" type="image/webp">
     <img src="hero.jpg" alt="…" width="1200" height="800">
   </picture>
   ```
4. **PNGs that should be JPEG/WebP** — flag any photographic PNG (use heuristic: JPEG
   would compress > 50% smaller).
5. **GIFs that should be `<video autoplay loop muted playsinline>`** — animated GIFs
   are nearly always 5–10× larger than equivalent video.

### Sizing
1. **Decoded vs displayed** — flag any image whose decoded dimensions are >2× the
   displayed CSS size (over-sized).
2. **`srcset` with `sizes`** — every responsive image should have a width-descriptor
   srcset (`image-400.jpg 400w, image-800.jpg 800w, …`) and a `sizes` attribute
   matching the layout.
3. **DPR coverage** — at minimum `1x` and `2x` variants.
4. **Explicit `width` and `height`** — non-negotiable for CLS prevention. CSS
   `aspect-ratio` is acceptable as an alternative.

### Loading strategy
1. **Above-the-fold (LCP candidate):** `loading="eager"` (default) + `fetchpriority="high"`
   + preload hint.
2. **Below-the-fold:** `loading="lazy"` + `decoding="async"`.
3. **First image is the LCP candidate** — never set `loading="lazy"` on the LCP image.
   This is one of the most common mistakes.
4. **Background images** can't use `loading="lazy"` directly — use `<img>` if at all
   possible, or use `content-visibility: auto` on the container.

### Image CDN
- Cloudinary, Imgix, Cloudflare Images, Bunny, Vercel Image Optimization, Next/Image —
  all give:
  - Format negotiation (`Accept` header → WebP/AVIF)
  - On-the-fly resize via URL params
  - DPR-aware delivery
- If the site has no CDN-style transformations, recommend one.

## Output format

```markdown
# Image Audit — <url>

**Total image weight:** … KB  •  **Image count:** N  •  **LCP image:** <selector>

## Format mix
| Format | Count | Size  | Avg size |
|--------|-------|-------|----------|
| AVIF   |   2   | 80 KB | 40 KB    |
| WebP   |   8   |320 KB | 40 KB    |
| JPEG   |  12   |1.4 MB |117 KB    |
| PNG    |   3   |600 KB |200 KB    |
| GIF    |   1   |2.1 MB |2.1 MB    |

## Issues
| Image | Issue | Savings |
|-------|-------|---------|
| /hero.jpg | not WebP/AVIF, no preload, LCP | ~120 KB + ~300 ms LCP |
| /banner.png | photographic PNG | ~280 KB |
| /demo.gif | animated GIF, should be video | ~1.7 MB |
| /thumb-12.jpg | decoded 2400×1600, displayed 400×267 | ~85 KB |

## Loading strategy
- Above-the-fold images set to `loading="lazy"`: 1 (will hurt LCP) — `/hero.jpg`
- Below-the-fold images without `loading="lazy"`: 14
- Missing `width`/`height`: 6 (CLS risk)

## Recommendations (tiered)
### Critical
- Add `fetchpriority="high"` and remove `loading="lazy"` from `/hero.jpg`
- …
### High / Medium / Low
- …
```

## Tools to use

- **Playwright** with `page.evaluate(() => Array.from(document.images, …))` to
  enumerate every `<img>` plus computed display size.
- **WebFetch** to download originals and measure transfer + decoded sizes.
- **Bash** for `cwebp` / `avifenc` recommendations and savings estimates.

## References

- web.dev — Choose the right image format: https://web.dev/articles/choose-the-right-image-format
- MDN — `<picture>` element: https://developer.mozilla.org/en-US/docs/Web/HTML/Element/picture
- web.dev — `fetchpriority`: https://web.dev/articles/fetch-priority
