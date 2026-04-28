---
name: perf-fonts
description: Web font loading audit — font-display, preload, subsetting, FOUT/FOIT mitigation, variable fonts, and system font fallback matching.
type: skill
parent: perf
---

# `perf-fonts` — Web Font Loading

## Scope

Audit every custom font on the page: how it's discovered, how it's downloaded, what the
browser does while waiting for it, and how it's swapped in. Goal: zero invisible text
("FOIT") and minimum layout shift on swap.

## When to invoke

- `/perf fonts <url>` — explicit
- During `/perf audit` — covered by `perf-agent-render`
- Mentions of: "FOIT", "FOUT", "FOFT", "font-display", "Google Fonts", "Adobe Fonts",
  "Typekit", "preload font", "variable font", "subsetting"

## Concepts

- **FOIT** — Flash of Invisible Text. Browser hides text until the font loads. Bad UX,
  bad LCP.
- **FOUT** — Flash of Unstyled Text. Browser shows fallback first, swaps when font
  arrives. Good UX, but CLS risk if metrics differ.
- **FOFT** — Flash of Faux Text. Browser synthesizes bold/italic from regular while
  waiting. Worse than FOUT visually.

## Analysis checklist

### Discovery
1. **List every `@font-face`** rule. From inline `<style>`, external CSS, and
   `<link href="…fonts.googleapis.com…">` includes.
2. **Confirm WOFF2** — anything older (WOFF, TTF, OTF, EOT) is a quick win to convert.
3. **Subsetting** — check `unicode-range`. Latin-only sites should not ship
   Cyrillic/Greek glyphs.

### Loading
1. **`<link rel="preload" as="font" type="font/woff2" crossorigin>`** for every
   above-the-fold font weight/style.
2. **`crossorigin`** is **required** on preload, even for same-origin fonts — without
   it, the preload won't be matched against the actual fetch.
3. **Self-host vs CDN** — Google Fonts CSS-then-font is two round trips. Self-hosting
   (or `<link rel="preconnect">` to fonts.gstatic.com + preload) cuts this.
4. **Variable fonts** — single file replaces 4–9 weight files. Recommend if the design
   uses ≥3 weights.

### Display strategy
1. **`font-display: swap`** — recommended default. Browser uses fallback immediately,
   swaps when font arrives.
2. **`font-display: optional`** — even better for body text: zero CLS risk; if the
   font misses a 100 ms cutoff, it's not used at all on this page load (cached for
   next).
3. **`font-display: block`** — only for critical icon fonts where wrong glyphs would
   confuse (and even then, prefer SVG).
4. **Never:** `font-display: auto` for custom fonts (browser default = FOIT).

### Fallback matching
- Use `size-adjust`, `ascent-override`, `descent-override`, `line-gap-override` on the
  `@font-face` for the fallback to make it visually match the custom font. This
  collapses CLS on swap to ~0.
- Generators: https://screenspan.net/fallback, https://meowni.ca/font-style-matcher

### Synthesis avoidance
- If the design uses bold and italic, **load all required weights/styles**. Don't let
  the browser fake them — synthesized faux-bold is uglier than fallback.

## Output format

```markdown
# Font Audit — <url>

**Custom fonts:** N  •  **Total font weight:** … KB  •  **Self-hosted:** yes/no

## Inventory
| Family | Weights/Styles | Format | Size | Display | Preload | Subset |
|--------|----------------|--------|------|---------|---------|--------|
| Inter (var) | 100–900     | woff2  | 92 KB| swap    | yes     | latin  |
| Source Code Pro | 400, 700 | woff2 | 38 KB| auto    | no      | latin-ext |

## Issues
- `Source Code Pro` uses `font-display: auto` → FOIT for monospace (typically code
  blocks below the fold). Switch to `swap` or `optional`.
- `Inter` 700 missing — italic is being synthesized.
- No fallback metric overrides; CLS risk on swap.

## Quick wins (copy-paste)
```html
<link rel="preload" as="font" type="font/woff2"
      href="/fonts/Inter-var.woff2" crossorigin>
```

```css
@font-face {
  font-family: "Inter Fallback";
  src: local("Arial");
  size-adjust: 107.4%;
  ascent-override: 90.2%;
  descent-override: 22.5%;
  line-gap-override: 0%;
}

body { font-family: "Inter", "Inter Fallback", sans-serif; }
```

## Recommendations (tiered)
### Critical
- …
### High / Medium / Low
- …
```

## Tools

- **WebFetch** for the page CSS to enumerate `@font-face` rules.
- **Playwright** to confirm `document.fonts` API state and what the browser actually
  loaded.
- **Bash** to download WOFF2 files and measure transfer size.

## References

- web.dev — Optimize WebFonts: https://web.dev/articles/optimize-webfont-loading
- MDN — `font-display`: https://developer.mozilla.org/en-US/docs/Web/CSS/@font-face/font-display
- CSS Working Group — `size-adjust` and metric overrides: https://www.w3.org/TR/css-fonts-4/
