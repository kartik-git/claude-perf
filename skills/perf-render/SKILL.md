---
name: perf-render
description: Critical rendering path analysis — render-blocking resources, parser-blocking scripts, resource hints, priority hints, and waterfall reconstruction.
type: skill
parent: perf
---

# `perf-render` — Critical Rendering Path

## Scope

Trace the path from "first byte received" to "first meaningful paint." Identify every
resource that blocks rendering, every chain of dependent requests, and every missed
opportunity for the browser to load assets earlier or in parallel.

## When to invoke

- `/perf render <url>` — explicit
- During `/perf audit` — fan-out via `perf-agent-render`
- Mentions of: "render blocking", "first paint", "FCP", "waterfall", "preload",
  "preconnect", "fetchpriority", "resource hints"

## Concepts to apply

### Render-blocking
A resource is **render-blocking** if the browser will not paint pixels until it has
finished downloading and processing it. This includes:
- `<script>` tags in `<head>` without `async` or `defer`
- `<link rel="stylesheet">` in `<head>` without `media` query
- `<style>` blocks (inline CSS — usually fine, but watch for huge ones)

### Parser-blocking
A subset of render-blocking. A `<script>` mid-document without `async` or `defer` halts
HTML parsing entirely until it executes.

### Critical request chain
The longest chain of dependent requests required to render. Example:
`HTML → CSS → font referenced in CSS → first paint`. Every link in that chain is a
sequential round-trip.

## Analysis checklist

1. **Fetch the HTML** and list every `<script>`, `<link rel="stylesheet">`, `<style>`,
   `@import`, and `<link rel="preload">` in `<head>` (and the first 10 lines of `<body>`).
2. **Categorize each `<script>`** as: blocking, `async`, `defer`, `module`, or
   `module nomodule`.
3. **Categorize each stylesheet** as: render-blocking (no media), conditional (`media="..."`),
   or preloaded.
4. **Reconstruct the waterfall** using either a captured HAR file, a Playwright trace,
   or live `Resource Timing API` data. Identify:
   - Critical chain length (number of sequential requests)
   - Total critical chain duration
   - The longest individual request
5. **Resource hints inventory:**
   - `<link rel="preconnect">` for every external origin used in the critical path
   - `<link rel="dns-prefetch">` as fallback for older browsers
   - `<link rel="preload">` for critical fonts and the LCP image
   - `<link rel="modulepreload">` for entry-point ES modules
6. **Priority hints:**
   - `fetchpriority="high"` on the LCP image
   - `fetchpriority="low"` on below-fold lazy assets
7. **Inline vs external CSS:** for above-the-fold styles, inline critical CSS and
   defer the full sheet via `media="print"` swap or `loadCSS` pattern.

## Common findings & fixes

| Finding | Fix |
|---|---|
| Render-blocking `<script>` in `<head>` | Add `defer` (preferred) or `async` |
| Synchronous third-party tag in `<head>` | Move to `</body>` or use facade |
| LCP image discovered late (in JS-rendered DOM) | Add `<link rel="preload" as="image" fetchpriority="high">` |
| Multiple preconnects (>4) | Trim — each preconnect costs a TCP+TLS handshake budget |
| `@import` inside CSS | Inline the import or move to `<link>` to avoid serial loading |
| Fonts loaded via JS | Convert to `<link rel="preload" as="font" crossorigin>` + `font-display: swap` |
| LCP image set via JS-injected `<img>` | Move image into HTML so the preloader sees it |

## Output format

```markdown
# Critical Rendering Path — <url>

**FCP (lab):** … s  •  **Critical chain length:** N requests  •  **Longest chain:** … s

## Render-blocking resources
| Resource | Type | Size | Blocking time |
|----------|------|------|---------------|
| /app.css | CSS  | 88 KB| 320 ms        |
| /vendor.js | JS | 142 KB| 540 ms       |

## Parser-blocking scripts
- `<script src="…analytics.js">` in <head>, no async/defer

## Critical request chain
1. document (`/`) — 120 ms
2. → app.css — 320 ms
3.   → /fonts/Inter-var.woff2 — 240 ms
   **Total:** 680 ms

## Resource hints — present
- preconnect: cdn.example.com, fonts.gstatic.com
- preload: /fonts/Inter-var.woff2

## Resource hints — missing
- preconnect: api.example.com (used in critical path)
- preload: LCP image /hero.webp
- fetchpriority="high" on `<img>` for LCP

## Recommendations (tiered)
### Critical
- …
### High
- …
### Medium / Low
- …

## Quick wins (copy-paste)
```html
<link rel="preconnect" href="https://api.example.com" crossorigin>
<link rel="preload" as="image" href="/hero.webp" fetchpriority="high">
```
```

## Tools to use

- **WebFetch** to grab the HTML and inspect `<head>`.
- **Playwright** to capture network and rendering traces (`page.tracing.start()`).
- **HAR analysis** if the user supplies a saved HAR file.
- **Bash** for `curl -I` to inspect headers feeding into rendering decisions.

## References

- web.dev — Critical rendering path: https://web.dev/articles/critical-rendering-path
- web.dev — Resource hints: https://web.dev/articles/preconnect-and-dns-prefetch
- HTML Living Standard — Priority Hints: https://html.spec.whatwg.org/multipage/urls-and-fetching.html#fetch-priority-attribute
