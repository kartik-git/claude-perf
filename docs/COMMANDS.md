# Commands

Full `/perf` command reference. All commands are dispatched by `perf/SKILL.md`.

## Audit

| Command | Description |
|---|---|
| `/perf audit <url>` | Full audit. Dispatches all 7 subagents in parallel; reporter aggregates. Saves to `.perf-reports/<host>-<ts>.md`. |

Flags: `--mobile`, `--desktop`, `--no-field`, `--region=<iso>`.

## Single-focus audits

| Command | Description |
|---|---|
| `/perf cwv <url>` | LCP / INP / CLS — lab + field |
| `/perf bundle [path\|url]` | JS / CSS payload analysis |
| `/perf render <url>` | Critical rendering path |
| `/perf images <url>` | Image audit |
| `/perf fonts <url>` | Web font loading |
| `/perf network <url>` | Protocol / TTFB / compression / headers |
| `/perf cache <url>` | Cache-Control / CDN / service worker |
| `/perf third-party <url>` | Third-party cost inventory |
| `/perf ssr <url>` | SSR / hydration / streaming |
| `/perf mobile <url>` | Mobile-throttled audit |

## Strategic / planning

| Command | Description |
|---|---|
| `/perf plan ecommerce` | 30/60/90 roadmap for an ecommerce site |
| `/perf plan saas` | Roadmap for a SaaS dashboard |
| `/perf plan media` | Roadmap for a publisher / media site |
| `/perf plan docs` | Roadmap for a documentation site |
| `/perf plan blog` | Roadmap for a blog |
| `/perf monitor <url>` | RUM setup recommendation |

## Budgets & CI

| Command | Description |
|---|---|
| `/perf budget create` | Scaffold a `.perf-budget.json` from `schema/perf-budgets.json` |
| `/perf budget check` | Validate measured metrics against `.perf-budget.json` |
| `/perf ci setup` | Generate Lighthouse CI workflow |
| `/perf ci check` | Validate the existing workflow enforces the budget |

## Comparison

| Command | Description |
|---|---|
| `/perf compare <url-a> <url-b>` | Side-by-side metrics |

## Extensions (require API keys)

| Command | Source |
|---|---|
| `/perf pagespeed <url>` | Google PageSpeed Insights |
| `/perf pagespeed field <url>` | CrUX (via PSI) |
| `/perf pagespeed compare <a> <b>` | PSI side-by-side |
| `/perf crux <url>` | Chrome UX Report — origin |
| `/perf crux url <url>` | Chrome UX Report — URL-level |
| `/perf crux trend <url>` | 12-month trend |
| `/perf wpt run <url>` | WebPageTest run |
| `/perf wpt filmstrip <url>` | WPT filmstrip |
| `/perf wpt waterfall <url>` | WPT waterfall |
| `/perf wpt compare <a> <b>` | WPT A/B |
