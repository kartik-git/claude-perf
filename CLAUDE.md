# claude-perf — Web Performance Engineering Skill for Claude Code

> **"Speed is a feature. Make it yours."**

A comprehensive web performance engineering skill for Claude Code. Modeled after
`claude-seo`, `claude-perf` brings the same multi-skill / multi-agent architecture to
Core Web Vitals optimization, bundle analysis, rendering pipeline audits, CDN strategy,
and real-user monitoring — covering every layer of the modern performance stack.

---

## Name

**`claude-perf`**
Repo: `github.com/kartik-git/claude-perf`
Command namespace: `/perf`

Rationale: short, unambiguous, mirrors `claude-seo` naming convention, and maps directly
to the `/perf` slash-command prefix used in Claude Code.

---

## Vision & Positioning

`claude-seo` gives Claude Code a world-class SEO brain. `claude-perf` gives it a
world-class performance brain. The two skills are natural companions — fast pages rank
better, and well-ranked pages need to be fast.

Where `claude-seo` audits content signals, schema, and crawlability, `claude-perf` audits
load time, rendering, JavaScript execution, caching, and real-user experience. The same
developer who runs `/seo audit https://example.com` should be able to immediately run
`/perf audit https://example.com` and get an equally deep, actionable report.

---

## Repository Structure

```
claude-perf/
├── CLAUDE.md                  # Claude Code entrypoint — skill registration
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE                    # MIT
├── SECURITY.md
├── install.sh                 # Unix installer
├── install.ps1                # Windows installer
├── uninstall.sh
├── uninstall.ps1
├── pyproject.toml
├── requirements.txt           # Playwright, httpx, rich, etc.
│
├── perf/                      # Main skill (maps to ~/.claude/skills/perf/)
│   └── SKILL.md               # Master orchestrator skill
│
├── skills/                    # 13 sub-skills
│   ├── perf-cwv/              # Core Web Vitals (LCP, INP, CLS)
│   ├── perf-bundle/           # JS/CSS bundle analysis
│   ├── perf-render/           # Critical rendering path
│   ├── perf-images/           # Image optimization (format, size, lazy load)
│   ├── perf-fonts/            # Web font loading & FOUT/FOIT
│   ├── perf-network/          # HTTP/2, HTTP/3, compression, CDN headers
│   ├── perf-caching/          # Cache strategy (browser, CDN, service worker)
│   ├── perf-third-party/      # Third-party script impact analysis
│   ├── perf-ssr/              # SSR / hydration / TTFB
│   ├── perf-mobile/           # Mobile-specific: throttling, touch, viewport
│   ├── perf-accessibility/    # Performance-adjacent a11y (ARIA, focus, reflow)
│   ├── perf-plan/             # Strategic performance planning & roadmaps
│   └── perf-monitor/         # RUM setup guidance & alerting strategy
│
├── agents/                    # 7 parallel subagents
│   ├── perf-agent-cwv.md
│   ├── perf-agent-bundle.md
│   ├── perf-agent-network.md
│   ├── perf-agent-render.md
│   ├── perf-agent-third-party.md
│   ├── perf-agent-mobile.md
│   └── perf-agent-reporter.md
│
├── extensions/
│   ├── pagespeed/             # Google PageSpeed Insights MCP integration
│   │   ├── install.sh
│   │   └── README.md
│   ├── crux/                  # Chrome UX Report (CrUX) field data
│   │   ├── install.sh
│   │   └── README.md
│   └── webpagetest/           # WebPageTest MCP integration
│       ├── install.sh
│       └── README.md
│
├── hooks/                     # Claude Code hooks for auto-triggering
│   ├── on-build-complete.sh   # Run bundle analysis after builds
│   └── on-deploy.sh           # Trigger CWV checks post-deploy
│
├── schema/
│   └── perf-budgets.json      # Performance budget templates
│
├── docs/
│   ├── INSTALLATION.md
│   ├── COMMANDS.md
│   ├── ARCHITECTURE.md
│   ├── MCP-INTEGRATION.md
│   └── TROUBLESHOOTING.md
│
└── screenshots/
    ├── cover-image.jpeg
    └── perf-audit-demo.gif
```

---

## Commands

| Command | Description |
|---|---|
| `/perf audit <url>` | Full performance audit — dispatches all 7 subagents in parallel |
| `/perf cwv <url>` | Core Web Vitals deep dive (LCP, INP, CLS with root-cause analysis) |
| `/perf bundle [path\|url]` | JS/CSS bundle size analysis, tree-shaking gaps, code splitting |
| `/perf render <url>` | Critical rendering path: render-blocking resources, waterfall |
| `/perf images <url>` | Image audit: format, dimensions, lazy loading, LCP hero image |
| `/perf fonts <url>` | Font loading strategy: preload, `font-display`, subsetting |
| `/perf network <url>` | HTTP/2 push, compression (Brotli/gzip), TTFB, CDN headers |
| `/perf cache <url>` | Cache-Control audit, CDN TTL strategy, service worker |
| `/perf third-party <url>` | Third-party script cost: blocking time, size, removal candidates |
| `/perf mobile <url>` | Mobile performance: throttled CPU/network, viewport, touch events |
| `/perf ssr <url>` | SSR / hydration audit: TTFB, streaming, selective hydration |
| `/perf plan <type>` | Strategic performance roadmap (ecommerce, saas, media, docs, blog) |
| `/perf monitor <url>` | RUM setup guidance: Sentry, Datadog, SpeedCurve, web-vitals.js |
| `/perf budget [create\|check]` | Create or check against performance budgets |
| `/perf compare <url-a> <url-b>` | Waterfall / metric comparison between two pages or competitors |
| `/perf ci [setup\|check]` | Lighthouse CI / Playwright perf test setup and budget enforcement |

---

## Sub-Skill Design

Each sub-skill under `skills/` is a Markdown file that Claude Code loads as a skill
context. Skills are composable — the master orchestrator (`perf/SKILL.md`) delegates to
sub-skills and assembles a unified report.

### `perf-cwv` — Core Web Vitals

**Scope:** LCP, INP, CLS — both lab (Lighthouse) and field (CrUX) data.

Key analysis areas:
- LCP element identification and render delay breakdown (TTFB + resource load + render)
- INP interaction tracing: long tasks, input delay, processing time, presentation delay
- CLS shift sources: images without dimensions, dynamic content injection, font swap
- Delta between lab scores and real-user p75 field data
- Recommendations tiered by impact: critical / high / medium / low

Thresholds enforced (2025 targets):
- LCP < 2.5s (good), < 4.0s (needs improvement)
- INP < 200ms (good), < 500ms (needs improvement)
- CLS < 0.1 (good), < 0.25 (needs improvement)

### `perf-bundle` — Bundle Analysis

**Scope:** JavaScript and CSS delivered to the browser.

Key analysis areas:
- Total JS payload (parsed, executed), per-route breakdown
- Duplicate dependencies across chunks
- Tree-shaking effectiveness: unused exports in top packages
- Code splitting opportunities: async imports, dynamic routes
- CSS specificity bloat, unused rules, critical CSS extraction
- Build tool configuration review (Webpack, Vite, Rollup, esbuild)
- Compression ratio: raw vs gzip vs Brotli

Output: ASCII/Markdown bundle treemap summary + actionable package-level recommendations.

### `perf-render` — Critical Rendering Path

**Scope:** From first byte to first paint.

Key analysis areas:
- Render-blocking resources (synchronous CSS/JS in `<head>`)
- Parser-blocking scripts
- Resource waterfall reconstruction from HAR or Playwright trace
- `<link rel="preload">` / `<link rel="prefetch">` opportunities
- Resource hints: `dns-prefetch`, `preconnect`
- Priority Hints (`fetchpriority=high` on LCP image)
- Minimize: render-blocking chain depth

### `perf-images` — Image Optimization

**Scope:** Every image on the page.

Key analysis areas:
- Modern formats: WebP, AVIF adoption (with fallback strategy)
- Responsive images: `srcset`, `sizes`, `<picture>` element
- Lazy loading: `loading="lazy"` below fold, `loading="eager"` on LCP hero
- Correct dimensions: explicit `width` / `height` to prevent CLS
- Over-sized images: decoded size vs display size ratio
- Image CDN opportunities (Cloudinary, Imgix, Cloudflare Images)
- Decoding hint: `decoding="async"` for off-screen images

### `perf-fonts` — Web Font Loading

**Scope:** Custom fonts and their impact on rendering.

Key analysis areas:
- `font-display` strategy per font weight/style
- `<link rel="preload">` for critical fonts
- Self-hosted vs CDN fonts (Google Fonts, Adobe Fonts) tradeoffs
- Subsetting: unicode-range, WOFF2 compression
- FOUT / FOIT / FOFT analysis and mitigation
- Variable fonts: single file, weight/width axis usage
- System font stack fallback matching (ascent/descent/line-gap override)

### `perf-network` — Network & Protocol

**Scope:** Transport layer from server to browser.

Key analysis areas:
- HTTP/2 multiplexing vs HTTP/1.1 head-of-line blocking
- HTTP/3 / QUIC readiness
- TTFB: server response time, early hints (103)
- Compression: Brotli (preferred) vs gzip, compression ratio per resource type
- CDN configuration: cache-hit rate, origin shield, edge locations
- `Vary` header correctness, `Cache-Control` directives
- `<link rel="preconnect">` to critical origins
- TLS handshake optimization: OCSP stapling, session resumption

### `perf-caching` — Caching Strategy

**Scope:** Browser cache, CDN cache, service worker.

Key analysis areas:
- Cache-Control headers per resource type (HTML, JS, CSS, images, fonts)
- Immutable assets: content-hash filenames with long `max-age`
- CDN TTL alignment: CDN cache vs browser cache coherence
- Stale-while-revalidate opportunities
- Service Worker: precaching strategy, runtime caching, offline support
- Cache invalidation patterns: versioning, purge APIs
- ETag / Last-Modified validation

### `perf-third-party` — Third-Party Scripts

**Scope:** All non-first-party resources.

Key analysis areas:
- Inventory: analytics, ads, chat, social, A/B testing, tag managers
- Blocking time contribution per third party (TBT impact)
- Transfer size per third party
- Facade patterns: replace heavy embeds (video, maps, chat) with facades
- `async` / `defer` opportunities
- Partytown: offloading analytics to web worker
- Tag manager audit: remove redundant or stale tags
- Self-hosting candidates: fonts, analytics snippets

### `perf-ssr` — Server-Side Rendering & Hydration

**Scope:** Rendering strategies and hydration overhead.

Key analysis areas:
- TTFB by rendering mode: SSR, SSG, ISR, CSR
- Streaming SSR: `renderToPipeableStream` / Suspense boundaries
- Hydration cost: JS payload needed before interactive
- Selective hydration / Islands architecture
- Partial prerendering (PPR) opportunities
- Edge rendering: latency benefit vs cold start tradeoff
- Defer non-critical hydration: `next/dynamic`, `React.lazy`

### `perf-mobile` — Mobile Performance

**Scope:** Performance on constrained devices and networks.

Key analysis areas:
- Throttled CPU simulation: 4x slowdown (Lighthouse default)
- Network throttling: Slow 4G, Fast 3G profiles
- Touch event handler passiveness (scroll jank)
- Viewport meta tag correctness
- Input latency on main-thread-heavy pages
- Battery-aware performance: `prefers-reduced-motion`
- Mobile-specific resource hints and priority

### `perf-plan` — Strategic Planning

**Scope:** Roadmaps for teams, not just one-off fixes.

Plan types:
- `ecommerce` — checkout funnel LCP, INP on product pages, conversion impact
- `saas` — dashboard load, data table rendering, real-time websocket perf
- `media` — video/image CDN, article LCP, infinite scroll CLS
- `docs` — static site generation, search performance, navigation transitions
- `blog` — CMS image pipeline, font loading, comment widget facades

Output: Phased roadmap (Quick Wins / Medium-term / Strategic), estimated effort, expected
metric delta, and success criteria.

### `perf-monitor` — RUM & Alerting

**Scope:** Observability for real-user performance.

Key analysis areas:
- `web-vitals.js` instrumentation (Google's official library)
- Beacon endpoint setup: sendBeacon, batching
- P75 vs P95 vs P99 monitoring strategy
- Synthetic monitoring: Lighthouse CI, SpeedCurve, Calibre schedules
- Budget enforcement: GitHub Actions integration
- Alerting thresholds: pages crossing "needs improvement" → Slack/PagerDuty
- RUM tool comparison: SpeedCurve, Datadog RUM, Sentry, New Relic, Cloudflare

---

## Subagent Architecture

Like `claude-seo`, `/perf audit` fans out to 7 parallel subagents. Each agent runs its
analysis independently; the Reporter agent then aggregates results.

```
/perf audit https://example.com
     │
     ├──▶ perf-agent-cwv          (Core Web Vitals — field + lab)
     ├──▶ perf-agent-bundle       (JS/CSS payload)
     ├──▶ perf-agent-network      (TTFB, headers, compression, CDN)
     ├──▶ perf-agent-render       (Render-blocking resources, waterfall)
     ├──▶ perf-agent-third-party  (Third-party cost inventory)
     ├──▶ perf-agent-mobile       (Mobile throttled audit)
     └──▶ perf-agent-reporter     (Aggregates, deduplicates, prioritizes)
```

The Reporter agent produces a unified Markdown report with:
1. Executive summary (Overall score, top 3 wins)
2. Metric dashboard (CWV table with lab vs field delta)
3. Prioritized issue list (Critical / High / Medium / Low)
4. Per-category deep-dives (linked to sub-skill outputs)
5. Quick wins checklist (copy-paste ready code snippets)
6. 30/60/90 day roadmap

---

## Extensions

### PageSpeed Insights MCP

Pulls live Lighthouse scores and CrUX field data from the Google PageSpeed Insights API.

```bash
./extensions/pagespeed/install.sh   # requires PAGESPEED_API_KEY env var
```

```
/perf pagespeed <url>                  # Full PSI report
/perf pagespeed field <url>            # CrUX field data only (p75 LCP/INP/CLS)
/perf pagespeed compare <url-a> <url-b> # Side-by-side PSI scores
```

### CrUX MCP

Pulls Chrome UX Report data — 28-day rolling real-user percentiles by URL, origin,
country, and form factor (desktop / phone / tablet).

```bash
./extensions/crux/install.sh   # requires CRUX_API_KEY env var
```

```
/perf crux <url>               # Origin-level CrUX data
/perf crux url <url>           # URL-level CrUX data
/perf crux trend <url>         # 12-month metric trend
```

### WebPageTest MCP

Triggers WebPageTest runs and pulls filmstrip, waterfall, and metric data.

```bash
./extensions/webpagetest/install.sh   # requires WPT_API_KEY env var
```

```
/perf wpt run <url>            # Run test (Dulles, Chrome, Cable)
/perf wpt filmstrip <url>      # Visual filmstrip comparison
/perf wpt waterfall <url>      # Full request waterfall
/perf wpt compare <url-a> <url-b>  # A/B waterfall comparison
```

---

## Hooks

Two Claude Code hooks enable automatic performance checks:

**`on-build-complete.sh`** — Fires after a detected build command (`npm run build`,
`vite build`, etc.). Runs bundle analysis on the output directory and warns if total JS
exceeds the configured budget.

**`on-deploy.sh`** — Fires after a deployment step is detected. Triggers a lightweight
CWV lab check against the deployed URL and posts results to the console.

Both hooks respect a `.perf-ignore` file to skip specific routes.

---

## Performance Budgets

`schema/perf-budgets.json` ships with opinionated budget templates:

```json
{
  "ecommerce": {
    "lcp_ms": 2500,
    "inp_ms": 200,
    "cls": 0.1,
    "total_js_kb": 300,
    "total_css_kb": 50,
    "total_image_kb": 500,
    "total_transfer_kb": 1000,
    "ttfb_ms": 600
  },
  "saas_dashboard": { ... },
  "media_article": { ... },
  "docs_site": { ... },
  "blog": { ... }
}
```

`/perf budget create` scaffolds a project-specific `.perf-budget.json`.
`/perf budget check` compares current metrics against it and exits non-zero on failure
(for CI integration).

---

## CI Integration

`/perf ci setup` generates a GitHub Actions workflow that:
1. Runs Lighthouse CI on every PR
2. Compares metrics against the base branch
3. Posts a CWV summary table as a PR comment
4. Fails the build if any metric crosses a budget threshold

Supports: GitHub Actions, GitLab CI, CircleCI, Bitbucket Pipelines.

---

## Ecosystem

`claude-perf` is designed to pair with `claude-seo` and the broader skill ecosystem:

| Skill | What it does | Connection |
|---|---|---|
| `claude-seo` | SEO audits, schema, GEO | Shares CWV data — `/seo audit` can invoke `/perf cwv` |
| `claude-perf` | Performance engineering | Core skill |
| `claude-blog` | Blog writing | Performance checklist for publish pipeline |
| `claude-banana` | AI image generation | Images it generates are format/size optimized by perf guidance |

**Cross-skill workflow example:**
```
/seo audit https://example.com       # Identify content + ranking issues
/perf audit https://example.com      # Identify speed issues
/perf plan ecommerce                 # Generate 90-day performance roadmap
/perf ci setup                       # Lock in budgets with CI enforcement
```

---

## Architecture Notes

```
~/.claude/skills/perf/         # Master skill — orchestrator
~/.claude/skills/perf-*/       # 13 sub-skills
~/.claude/agents/perf-*.md     # 7 subagents
```

The master skill (`perf/SKILL.md`) acts as a router. When `/perf audit` is called, it:
1. Spins up all 7 subagents with Task tool calls
2. Each agent reads its corresponding sub-skill for domain expertise
3. Agents run in parallel (no inter-agent dependencies during analysis)
4. The Reporter agent receives all outputs and synthesizes the final report

For single-focus commands (`/perf cwv`, `/perf bundle`, etc.), the master skill invokes
only the relevant sub-skill directly — no subagent fan-out needed.

---

## Requirements

- Python 3.10+
- Claude Code CLI
- Optional: Playwright (for screenshot-based CLS analysis and waterfall capture)
- Optional: Node.js 18+ (for local Lighthouse runs)

---

## Installation

### Unix / macOS / Linux
```bash
git clone --depth 1 https://github.com/kartik-git/claude-perf.git
bash claude-perf/install.sh
```

One-liner:
```bash
curl -fsSL https://raw.githubusercontent.com/kartik-git/claude-perf/main/install.sh | bash
```

### Windows (PowerShell)
```powershell
git clone --depth 1 https://github.com/kartik-git/claude-perf.git
powershell -ExecutionPolicy Bypass -File claude-perf\install.ps1
```

---

## Quick Start

```bash
claude

# Full audit — parallel subagents
/perf audit https://example.com

# Core Web Vitals deep dive
/perf cwv https://example.com/product/shoes

# Bundle bloat analysis
/perf bundle ./dist

# What's killing your INP?
/perf third-party https://example.com

# Set up CI enforcement
/perf ci setup

# Strategic roadmap for an ecommerce site
/perf plan ecommerce
```

---

## Differentiators vs claude-seo

| Dimension | claude-seo | claude-perf |
|---|---|---|
| Domain | Search ranking signals | Load speed + UX metrics |
| Primary metric | Organic traffic | Core Web Vitals (LCP/INP/CLS) |
| Data sources | DataForSEO, GSC, Ahrefs | CrUX, PSI, WebPageTest |
| Analysis depth | Content + crawlability | Rendering pipeline + payload |
| CI integration | No (planned) | Yes — budget enforcement |
| Hook support | No | Yes — post-build + post-deploy |
| Budget system | No | Yes — per site-type templates |

---

## Roadmap (v2+)

- `perf-animation` sub-skill: Compositor-safe animations, `will-change`, GPU layers
- `perf-wasm` sub-skill: WebAssembly loading, streaming compilation
- Vercel / Netlify deploy hook integrations
- Lighthouse CI budget reporter as a GitHub App
- `claude-perf` × `claude-seo` shared CWV module (avoid duplicate analysis)
- DataDog RUM MCP extension
- SpeedCurve MCP extension

---

*Built for Claude Code. MIT License.*