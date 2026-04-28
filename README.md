# claude-perf

> **Speed is a feature. Make it yours.**

`claude-perf` is a comprehensive web performance engineering skill for
[Claude Code](https://docs.claude.com/claude-code). It gives Claude a world-class
performance brain — Core Web Vitals diagnosis, bundle analysis, rendering pipeline
audits, CDN strategy, real-user monitoring, and CI budget enforcement — all behind a
single `/perf` command namespace.

It's the natural companion to [`claude-seo`](https://github.com/your-org/claude-seo). Fast
pages rank better; well-ranked pages need to be fast.

---

## What's in the box

- **1 master skill** that routes every `/perf` command.
- **13 sub-skills** covering every layer of the modern performance stack.
- **7 parallel subagents** that fan out for full audits and assemble a unified report.
- **3 extension scaffolds** for PageSpeed Insights, Chrome UX Report, and WebPageTest.
- **5 budget templates** for ecommerce, SaaS, media, docs, and blog sites.
- **2 hooks** for post-build and post-deploy auto-checks.
- **CI integration** for Lighthouse CI on every PR.

---

## Install

### macOS / Linux / WSL

```bash
git clone --depth 1 https://github.com/your-org/claude-perf.git
bash claude-perf/install.sh
```

One-liner:

```bash
curl -fsSL https://raw.githubusercontent.com/your-org/claude-perf/main/install.sh | bash
```

### Windows

```powershell
git clone --depth 1 https://github.com/your-org/claude-perf.git
powershell -ExecutionPolicy Bypass -File claude-perf\install.ps1
```

The installer copies the master skill, sub-skills, and agents into `~/.claude/`. Run
with `--dev` to symlink instead (useful when contributing).

Uninstall with `bash uninstall.sh` / `powershell -File uninstall.ps1`.

---

## Quick start

```bash
claude

# Full audit — six parallel subagents fan out, reporter aggregates
/perf audit https://example.com

# Core Web Vitals deep dive
/perf cwv https://example.com/checkout

# Bundle bloat after a build
/perf bundle ./dist

# Mobile-throttled audit
/perf mobile https://example.com

# What's killing your INP?
/perf third-party https://example.com

# Strategic 30/60/90 plan for an ecommerce site
/perf plan ecommerce

# Set up CI enforcement
/perf budget create
/perf ci setup
```

---

## Commands

| Command | Description |
|---|---|
| `/perf audit <url>` | Full audit. Dispatches all 7 subagents in parallel, then unifies the report. |
| `/perf cwv <url>` | LCP, INP, CLS deep dive — lab + field. |
| `/perf bundle [path\|url]` | JS/CSS payload, duplicates, tree-shaking gaps, code splitting. |
| `/perf render <url>` | Critical rendering path: render-blocking, waterfall, resource hints. |
| `/perf images <url>` | Image audit: format, dimensions, lazy loading, LCP image. |
| `/perf fonts <url>` | Font loading: preload, font-display, subsetting. |
| `/perf network <url>` | TTFB, HTTP/2 vs HTTP/3, compression, Vary, CDN headers. |
| `/perf cache <url>` | Cache-Control coherence, CDN TTL, service worker. |
| `/perf third-party <url>` | Third-party script cost: blocking time, transfer, removal candidates. |
| `/perf mobile <url>` | Mobile-throttled audit (Slow 4G + 4× CPU). |
| `/perf ssr <url>` | SSR / hydration / streaming / islands / PPR. |
| `/perf plan <type>` | 30/60/90 strategic roadmap. Types: `ecommerce`, `saas`, `media`, `docs`, `blog`. |
| `/perf monitor <url>` | RUM setup with `web-vitals.js` + tool comparison. |
| `/perf budget [create\|check]` | Scaffold or enforce a `.perf-budget.json`. |
| `/perf compare <a> <b>` | Side-by-side metric comparison. |
| `/perf ci [setup\|check]` | Lighthouse CI workflow generator + budget gate. |

Extensions (require API keys):
- `/perf pagespeed <url>` — PageSpeed Insights
- `/perf crux <url>` — Chrome UX Report
- `/perf wpt run <url>` — WebPageTest

---

## How `/perf audit` works

```
/perf audit https://example.com
     │
     ├──▶ perf-agent-cwv          (Core Web Vitals — field + lab)
     ├──▶ perf-agent-bundle       (JS/CSS payload)
     ├──▶ perf-agent-network      (TTFB, headers, compression, CDN)
     ├──▶ perf-agent-render       (Render-blocking, waterfall)
     ├──▶ perf-agent-third-party  (Third-party cost inventory)
     ├──▶ perf-agent-mobile       (Mobile-throttled)
     │     │
     │     all six run in parallel
     │     │
     └──▶ perf-agent-reporter     (Aggregates, dedupes, prioritizes)
             │
             └─▶ .perf-reports/<host>-<timestamp>.md
```

The unified report contains:
1. Executive summary (top 3 wins)
2. Core Web Vitals dashboard
3. Tiered findings (Critical / High / Medium / Low)
4. Quick wins (copy-paste snippets)
5. 30 / 60 / 90 day roadmap

For single-focus commands, the master skill loads the matching sub-skill inline — no
fan-out.

---

## Sub-skills

| Skill | Domain |
|---|---|
| `perf-cwv` | LCP / INP / CLS — lab + field, per-phase decomposition |
| `perf-bundle` | JS/CSS payload, duplicates, tree-shaking, code splitting |
| `perf-render` | Critical rendering path, resource hints, priority hints |
| `perf-images` | WebP/AVIF, srcset, lazy loading, LCP image |
| `perf-fonts` | font-display, preload, subsetting, fallback metric override |
| `perf-network` | HTTP/2/3, Brotli, TTFB, Vary, CDN |
| `perf-caching` | Cache-Control, CDN TTL, service worker |
| `perf-third-party` | Tag managers, ads, chat, analytics — facade / defer / Partytown |
| `perf-ssr` | SSR / SSG / ISR / streaming / islands / PPR |
| `perf-mobile` | Slow 4G + 4× CPU, viewport, touch passiveness |
| `perf-accessibility` | Reflow on focus, ARIA live cost, reduced motion |
| `perf-plan` | Phased roadmaps per site type |
| `perf-monitor` | `web-vitals.js`, beacon, p75/p95, RUM tool comparison |

Every sub-skill is a single Markdown file. Open `skills/perf-*/SKILL.md` to read or edit.

---

## Performance budgets

Bootstrap a budget tailored to your site type:

```bash
/perf budget create
# → writes .perf-budget.json based on schema/perf-budgets.json templates
```

Then enforce it:

```bash
/perf budget check
```

The budget is read by every `/perf audit` run — any breach is automatically promoted to
**Critical** severity in the report, regardless of absolute metric value.

---

## CI integration

```bash
/perf ci setup
```

Generates a Lighthouse CI workflow for your CI provider (GitHub Actions, GitLab CI,
CircleCI, Bitbucket Pipelines). The workflow:

1. Runs Lighthouse on every PR.
2. Compares against `main`.
3. Posts a CWV summary as a PR comment.
4. Fails the build if any metric breaches the budget.

---

## Hooks

Two opt-in Claude Code hooks live under `hooks/`:

- **`on-build-complete.sh`** — fires after `npm run build` / `vite build`. Runs bundle
  analysis on the output and warns on budget breaches.
- **`on-deploy.sh`** — fires after a detected deployment. Runs a lightweight CWV check
  on the deployed URL.

Wire them in via `~/.claude/settings.json` — see `docs/INSTALLATION.md`.

---

## Extensions

| Extension | Data source | Install |
|---|---|---|
| `pagespeed` | Google PageSpeed Insights API | `extensions/pagespeed/install.sh` |
| `crux` | Chrome UX Report API (28-day field data) | `extensions/crux/install.sh` |
| `webpagetest` | WebPageTest API | `extensions/webpagetest/install.sh` |

Each requires its own API key; see the extension's README for setup.

---

## Pairs well with

| Skill | What it adds |
|---|---|
| [`claude-seo`](https://github.com/your-org/claude-seo) | SEO audits, schema, GEO. Run `/seo audit` after `/perf audit` for a full content+speed picture. |
| `claude-blog` | Blog writing pipeline; `claude-perf` enforces image and font budgets at publish time. |
| `claude-banana` | Generated images run through `perf-images` before commit. |

Cross-skill flow:

```
/seo audit https://example.com       # content + ranking issues
/perf audit https://example.com      # speed issues
/perf plan ecommerce                 # 90-day perf roadmap
/perf ci setup                       # lock budgets in CI
```

---

## Requirements

- Python 3.10+
- Claude Code CLI ([install](https://docs.claude.com/claude-code))
- Optional: Node.js 18+ for local Lighthouse runs
- Optional: Playwright for waterfall and CLS screenshot capture

---

## Documentation

- [`docs/INSTALLATION.md`](docs/INSTALLATION.md)
- [`docs/COMMANDS.md`](docs/COMMANDS.md)
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- [`docs/MCP-INTEGRATION.md`](docs/MCP-INTEGRATION.md)
- [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md)

---

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md). Pull requests welcome — especially new
sub-skills, agent improvements, and extension integrations.

---

## License

MIT. See [`LICENSE`](LICENSE).

---

*Built for Claude Code.*
