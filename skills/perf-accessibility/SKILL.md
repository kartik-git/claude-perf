---
name: perf-accessibility
description: Performance-adjacent accessibility audit — reflow on focus, ARIA-driven re-renders, animation under prefers-reduced-motion, and focus-management cost.
type: skill
parent: perf
---

# `perf-accessibility` — Performance-Adjacent Accessibility

## Scope

This is **not** a full a11y audit (that's a separate domain — use axe-core, Lighthouse
a11y, or a dedicated tool). It's the slice of accessibility that intersects with
performance: things that, done badly, cause layout thrash, slow input response, or block
assistive tech.

For full a11y audits, recommend the user run `axe` or Lighthouse's accessibility category.

## When to invoke

- During `/perf audit` when a11y signals come up
- Mentions of: "screen reader perf", "focus thrash", "ARIA live region cost",
  "reduced motion", "skip link reflow", "tab traversal slow"

## Analysis checklist

### Reflow on focus
1. **`:focus-visible`** vs `:focus` — using `:focus-visible` is correct UX, but ensure
   the styling doesn't change layout (only outline/box-shadow).
2. **Skip-link reflow** — a skip link that becomes positioned-absolute on focus and
   pushes content is fine; one that animates `width: auto → 100%` triggers expensive
   layout.
3. **Modal focus trap** — measure the cost of focus traversal in a deeply nested DOM.
   Some focus-trap libraries walk the entire subtree on every keystroke.

### ARIA live regions
1. **`aria-live="polite"`** — fine for status updates.
2. **`aria-live="assertive"`** — interrupts. Use sparingly.
3. **High-frequency updates** — never push more than 1 update per ~500 ms to a live
   region; assistive tech queues them and falls behind. (Performance angle: if your
   app pushes 60 updates/sec to a live region, it's also doing 60 DOM mutations/sec.)
4. **Toast / notification stacks** — append-only, with `aria-atomic="true"` on the
   container.

### Animation
1. **`prefers-reduced-motion: reduce`** — every CSS animation, transition, and
   `<canvas>` loop should respect it. From a perf angle, honoring this disables
   animation cost entirely for users who set the preference (often older devices).
2. **Carousel auto-advance** — pause on `prefers-reduced-motion`. Pause on focus.
   Pause on `prefers-reduced-data`.
3. **Parallax** — disable on reduced motion.

### Focus management cost
1. **Programmatic `.focus()` after navigation** — confirm route transitions move
   focus. Cheap from a perf angle when done right; thrashy if combined with
   layout-changing animation.
2. **`tabindex="0"` proliferation** — large lists with `tabindex="0"` on every item
   slow down screen reader linear traversal and can cause noticeable Tab-key lag in
   the browser.

### Image alt text and `aria-hidden`
1. **Decorative images** without `alt=""` cause screen readers to announce filenames
   — slow and noisy. Adding `alt=""` is also a tiny perf win (skip lookup).
2. **`aria-hidden="true"`** on a focusable element creates inconsistent UX. From a
   perf angle, ensure not duplicated on already-hidden subtrees.

### Forced colors / high contrast
1. **`forced-colors: active`** (Windows High Contrast Mode) overrides backgrounds.
   Confirm critical UI is still legible. (Perf angle: incompatible custom rendering
   in Canvas/SVG can force a costly fallback path.)

## Output format

```markdown
# Performance-Adjacent Accessibility — <url>

## Reflow on focus
- 3 elements change layout on focus (skip-link, search-bar, top-nav). Should change
  outline only.

## ARIA live regions
- 2 regions detected: `#status` (polite), `#toasts` (assertive).
- Update rate on `#toasts`: ~10/s during stream — too high.

## Animation under reduced motion
- 12 CSS animations.
- 3 honor `prefers-reduced-motion`.
- 9 do not — recommend wrapping in `@media (prefers-reduced-motion: no-preference)`.

## Focus management
- Route transition: focus moves to `<h1>` — good.
- Search results list: 240 items each with `tabindex="0"` — recommend roving tabindex
  pattern.

## Recommendations
- …
```

## Tools

- **WebFetch** for the page HTML to enumerate `aria-live`, `tabindex`, `<dialog>`.
- **Playwright** to measure tab-traversal time over a list.
- Cross-link: full a11y audit → `axe-core`, Lighthouse a11y category, Pa11y.

## References

- web.dev — Accessibility & performance overlap: https://web.dev/articles/accessibility-fundamentals
- WCAG 2.2: https://www.w3.org/TR/WCAG22/
- MDN — `prefers-reduced-motion`: https://developer.mozilla.org/en-US/docs/Web/CSS/@media/prefers-reduced-motion
