---
name: perf-cwv
description: Core Web Vitals deep dive — LCP, INP, CLS — combining lab (Lighthouse) and field (CrUX) data with root-cause breakdowns and tiered recommendations.
type: skill
parent: perf
---

# `perf-cwv` — Core Web Vitals

## Scope

This sub-skill investigates the three Core Web Vitals that Google uses for both ranking
and page experience scoring:

- **LCP** — Largest Contentful Paint
- **INP** — Interaction to Next Paint (replaced FID in 2024)
- **CLS** — Cumulative Layout Shift

It pulls **both** lab data (a controlled Lighthouse run) and field data (28-day rolling
CrUX p75) and analyzes the delta between them — a healthy lab score with a poor field
score points at user-environment factors (slow devices, slow networks, geographic gaps).

## When to invoke

- `/perf cwv <url>` — explicit
- During `/perf audit` — fan-out via `perf-agent-cwv`
- When the user mentions any of: "LCP", "INP", "CLS", "Web Vitals", "page experience"

## 2025 thresholds

| Metric | Good | Needs improvement | Poor |
|---|---|---|---|
| **LCP** | < 2.5 s | 2.5 – 4.0 s | > 4.0 s |
| **INP** | < 200 ms | 200 – 500 ms | > 500 ms |
| **CLS** | < 0.1 | 0.1 – 0.25 | > 0.25 |

A page passes Core Web Vitals only if **all three** are in the "good" band at p75.

## Analysis checklist

### LCP
1. **Identify the LCP element** (typically a hero image, headline, or above-the-fold
   block). Use Lighthouse's `largest-contentful-paint-element` audit or Playwright's
   `PerformanceObserver({ type: 'largest-contentful-paint' })`.
2. **Decompose LCP into four phases** (per [web.dev/optimize-lcp](https://web.dev/articles/optimize-lcp)):
   - **TTFB** — server response delay
   - **Resource load delay** — time from TTFB to LCP resource discovery
   - **Resource load duration** — time to actually fetch the LCP resource
   - **Element render delay** — time from resource fetched to painted
3. **Recommend per-phase fixes:**
   - High TTFB → cache, edge render, faster origin
   - High load delay → preload the LCP resource, drop render-blocking JS/CSS
   - High load duration → smaller image, modern format, better CDN
   - High render delay → reduce main-thread work, hydrate selectively
4. **Check for `fetchpriority="high"`** on the LCP image. Missing this on an image LCP
   is a quick win.
5. **Confirm explicit `width` / `height`** — missing dimensions cause CLS and can delay
   LCP rendering.

### INP
1. **Capture the worst interactions** — Lighthouse 12+ reports the slowest INP across the
   trace. For field data, CrUX gives the p75 INP across all interactions.
2. **Decompose INP into three phases:**
   - **Input delay** — main thread busy when interaction fires
   - **Processing time** — handlers running
   - **Presentation delay** — browser painting the next frame
3. **Long-task hunt** — list main-thread tasks > 50 ms, ordered by duration. Each is an
   INP candidate. Focus on tasks that occur near user input.
4. **Common culprits:**
   - Heavy event handlers (search-as-you-type, validation on every keystroke)
   - Synchronous third-party scripts (analytics, ad tags)
   - Large React re-renders triggered by input
   - `requestAnimationFrame` callbacks doing too much work
5. **Recommended mitigations:**
   - `yieldToMain()` / `scheduler.yield()` to break up long tasks
   - Debounce / throttle high-frequency handlers
   - Move work off the main thread (Web Workers, Partytown)
   - `content-visibility: auto` for off-screen content

### CLS
1. **Source the shifts** — Lighthouse provides `layout-shift-elements`. For field, CrUX
   reports CLS at p75.
2. **Common shift sources:**
   - Images / videos / iframes without explicit dimensions
   - Ads and embeds reserving space dynamically
   - Web fonts swapping in (FOUT) and reflowing text
   - Dynamic content injected above existing content (cookie banners, alerts)
   - Late-arriving viewport-relative animations
3. **Mitigations:**
   - Set `width` and `height` (or aspect-ratio) on every replaced element
   - `min-height` on ad slots
   - `font-display: optional` or matched fallback metrics (`size-adjust`,
     `ascent-override`, `descent-override`)
   - Animate only `transform` and `opacity` — never `top`, `left`, `width`, `height`

## Lab vs Field delta interpretation

| Lab | Field | Likely cause |
|---|---|---|
| Good | Good | Healthy. |
| Good | Poor | Real-user devices/networks worse than test rig. Investigate slow-3G + 4× CPU. |
| Poor | Good | Lab regression from a recent deploy not yet visible in 28-day field rolling window. |
| Poor | Poor | Real problem. Fix in the order of the per-phase analysis above. |

## Output format

```markdown
# Core Web Vitals — <url>

**Tested:** <ISO ts>  •  **Profile:** <mobile|desktop>  •  **Field source:** <CrUX url|origin|none>

## Verdict
<one-sentence verdict + emoji>

## Metrics
| Metric | Lab  | Field (p75) | Target | Status |
|--------|------|-------------|--------|--------|
| LCP    | …    | …           | <2.5s  | …      |
| INP    | …    | …           | <200ms | …      |
| CLS    | …    | …           | <0.1   | …      |

## LCP Breakdown
- **Element:** <selector>
- **TTFB:** … ms
- **Resource load delay:** … ms
- **Resource load duration:** … ms
- **Element render delay:** … ms
- **Recommendation:** …

## INP Breakdown
- **Worst interaction:** <event> on <selector>
- **Input delay:** … ms
- **Processing time:** … ms
- **Presentation delay:** … ms
- **Long tasks contributing:** N (longest <ms>)
- **Recommendation:** …

## CLS Sources
| Element | Shift score | Cause |
|---------|-------------|-------|
| …       | …           | …     |

## Recommendations (tiered)
### Critical
- …
### High
- …
### Medium
- …
### Low
- …
```

## Tools to use

- **Lighthouse** (local Node binary, or via PageSpeed Insights extension)
- **Playwright tracing** for INP long-task analysis
- **CrUX API** (via the `crux` extension, if installed) for field data
- **WebFetch** for HTML inspection (LCP element guess from `<head>` + first viewport)

## References

- web.dev — Optimize LCP: https://web.dev/articles/optimize-lcp
- web.dev — Optimize INP: https://web.dev/articles/optimize-inp
- web.dev — Optimize CLS: https://web.dev/articles/optimize-cls
- Chrome UX Report API: https://developer.chrome.com/docs/crux
