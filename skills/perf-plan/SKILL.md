---
name: perf-plan
description: Strategic performance planning — phased roadmaps (Quick Wins / Medium-term / Strategic) tailored to ecommerce, SaaS, media, docs, or blog sites with effort and impact estimates.
type: skill
parent: perf
---

# `perf-plan` — Strategic Performance Planning

## Scope

Where the other sub-skills tell you *what's wrong*, `perf-plan` tells you *what to do
next, in what order, and why*. It produces a phased roadmap tailored to the site's
business model.

## When to invoke

- `/perf plan <type>` — explicit. Types: `ecommerce`, `saas`, `media`, `docs`, `blog`.
- After a `/perf audit` when the user asks "what should I do first?"
- Mentions of: "roadmap", "performance plan", "quarterly", "30/60/90", "what next"

## Plan types

### `ecommerce`
**Top metrics:** LCP on PDPs, INP on filter/sort, CLS on cart, TTFB on category pages.
**Conversion lever:** Every 100 ms of LCP improvement is roughly 1% conversion uplift
(Amazon, Walmart studies — quote conservatively as "studies suggest").

Quick wins:
- Preload PDP hero image with `fetchpriority="high"`
- Lazy-load below-fold gallery thumbnails
- Move analytics + chat behind facades / `defer`
- Add `<link rel="preconnect">` for payment/CDN origins in `<head>`

Medium-term (1–3 months):
- Image CDN with format negotiation (Cloudinary, Imgix, Cloudflare Images)
- Image dimensions in CSS to prevent CLS
- Code-split product variants / size pickers
- Edge-render category pages with ISR / PPR
- INP audit on add-to-cart and quantity steppers

Strategic (3–9 months):
- Move PDPs to streaming SSR with islands for the buy box
- Service worker for repeat-visit instant nav
- Performance budget enforcement in CI per route type (PDP / PLP / cart / checkout)

### `saas`
**Top metrics:** TTI on dashboard, INP on data tables, INP on form interactions, FCP
after auth redirect.

Quick wins:
- Defer analytics + session-replay on the marketing site; gate session-replay behind
  authenticated routes only
- Code-split heavy charting (Recharts, Plotly, AG Grid) per route
- Preload the post-login landing JS

Medium-term:
- Virtualize long lists / data tables (react-window, TanStack Virtual)
- Web Worker for CSV parse, heavy data transforms
- `content-visibility: auto` for off-screen panels

Strategic:
- Rendering split: marketing site = SSG/edge, app = SPA, with shared design system
- Real-user INP monitoring (web-vitals.js + custom dashboard)
- Performance regression alerts on critical workflows

### `media` (publishers, blogs with high traffic)
**Top metrics:** LCP on article hero, CLS from ads, INP from comment widgets,
TTFB on home/section pages.

Quick wins:
- Reserve ad-slot space with `min-height` to prevent CLS
- Static map / image facades for embeds (YouTube, Twitter, Instagram)
- Brotli on HTML and edge CDN cache

Medium-term:
- Native lazy-loading on every below-fold image
- Critical CSS extraction for article template
- Defer GTM and consent management (within legal constraints)
- Image CDN for editorial assets

Strategic:
- ESI / edge-side includes to compose article + sidebar
- INP monitoring on comment widgets
- Server-rendered ad rendering (server-side header bidding) to reduce client cost

### `docs`
**Top metrics:** TTFB everywhere, LCP on home/landing, INP on search, navigation
transitions.

Quick wins:
- SSG everything; serve from edge CDN
- Inline critical CSS for the docs template
- Preload search index if used during initial nav

Medium-term:
- Algolia / Pagefind / FlexSearch — pick one, lazy-load on focus of search input
- View Transitions API for instant nav between pages
- Service worker for offline docs

Strategic:
- Static site generator's incremental builds (so content edits don't rebuild
  everything)
- Custom-tuned search ranking + instant search
- Client-side i18n routing without re-fetching pages

### `blog`
**Top metrics:** LCP on article hero image, CLS from images and ads, TTFB on home.

Quick wins:
- Image CDN
- `fetchpriority="high"` on the article hero image
- Single `<link rel="preload">` for the article-template font (preload only the
  weight you use above the fold)

Medium-term:
- Move comments behind facades (Disqus replacement, Giscus, etc.)
- Static generation for archive pages
- Web font subsetting (drop unused glyph ranges)

Strategic:
- Move to a static-first architecture (Astro, 11ty) if currently SSR-only
- Pagefind / static search

## Output format

```markdown
# Performance Roadmap — <site type> — <url>

## Current state (snapshot)
| Metric | Today | Target |
|--------|-------|--------|
| LCP    | …     | <2.5s  |
| INP    | …     | <200ms |
| CLS    | …     | <0.1   |
| TTFB   | …     | <600ms |
| First-load JS | … | <170KB |

## Phase 1 — Quick wins (0–30 days)
| # | Task | Effort | Impact | Owner |
|---|------|--------|--------|-------|
| 1 | Add `fetchpriority="high"` on hero image | 1 hr | LCP -300ms | FE |
| 2 | Defer GTM | 2 hr | INP -150ms | FE |
| 3 | Preload primary font | 1 hr | LCP -120ms | FE |
| … | …    | …      | …      | …     |

## Phase 2 — Medium-term (30–90 days)
| # | Task | Effort | Impact | Owner |
|---|------|--------|--------|-------|
| … | …    | …      | …      | …     |

## Phase 3 — Strategic (90–270 days)
| # | Task | Effort | Impact | Owner |
|---|------|--------|--------|-------|
| … | …    | …      | …      | …     |

## Success criteria
- Phase 1 success: LCP p75 < 3.0s
- Phase 2 success: All three CWV pass at p75
- Phase 3 success: CWV pass + INP <100ms on top 3 routes

## Investments to consider
- Image CDN (~$X/month)
- Edge runtime migration (~Y dev-weeks)
- Performance monitoring tool (SpeedCurve / Calibre / Sentry RUM)
```

## Tools

- **Read** for current `/perf audit` report (if one exists in `.perf-reports/`).
- **Read** for `package.json` to identify framework + dependencies.
- **Bash** for `git log` to gauge team velocity (rough).

## References

- web.dev — Site planning playbooks: https://web.dev/explore
- Performance budgets — Tim Kadlec: https://timkadlec.com/remembers/2017-04-13-setting-a-performance-budget/
