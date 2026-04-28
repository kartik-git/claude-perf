---
name: perf
description: Master web performance engineering skill. Routes /perf commands, dispatches subagents for full audits, and produces unified Core Web Vitals + payload + rendering reports.
type: skill
version: 0.1.0
---

# `/perf` — Web Performance Engineering Master Skill

> **"Speed is a feature. Make it yours."**

This is the master orchestrator for `claude-perf`. It receives every `/perf <command>`
invocation, routes to the appropriate sub-skill (or fans out to multiple subagents for
full audits), and produces a single unified report.

---

## Activation

Activate this skill when the user types any command beginning with `/perf`, or when they
ask about web performance, Core Web Vitals (LCP / INP / CLS), bundle size, rendering
waterfall, image/font/cache strategy, third-party script cost, RUM, or performance budgets.

Do **not** activate this skill for:
- General SEO questions (route to `/seo` if `claude-seo` is installed).
- Server-side performance unrelated to web rendering (DB tuning, backend profiling).
- Build tool errors that aren't perf-related.

---

## Command Router

When the user invokes `/perf <subcommand> [args]`, dispatch as follows:

| Subcommand | Behavior |
|---|---|
| `audit <url>` | **Fan-out audit.** Dispatch all 7 subagents in parallel, then run `perf-agent-reporter` to aggregate. |
| `cwv <url>` | Load `skills/perf-cwv` and run a Core Web Vitals deep dive. |
| `bundle [path\|url]` | Load `skills/perf-bundle`. If a path is given, analyze build output; if a URL, analyze delivered JS/CSS. |
| `render <url>` | Load `skills/perf-render`. Reconstruct the critical rendering path. |
| `images <url>` | Load `skills/perf-images`. Audit every image on the page. |
| `fonts <url>` | Load `skills/perf-fonts`. Audit web font loading strategy. |
| `network <url>` | Load `skills/perf-network`. Audit transport layer + headers. |
| `cache <url>` | Load `skills/perf-caching`. Audit Cache-Control + CDN TTL coherence. |
| `third-party <url>` | Load `skills/perf-third-party`. Inventory third-party cost. |
| `mobile <url>` | Load `skills/perf-mobile`. Run audit under mobile throttling. |
| `ssr <url>` | Load `skills/perf-ssr`. Audit rendering mode and hydration. |
| `plan <type>` | Load `skills/perf-plan`. Generate a strategic roadmap. Types: `ecommerce`, `saas`, `media`, `docs`, `blog`. |
| `monitor <url>` | Load `skills/perf-monitor`. Recommend RUM instrumentation. |
| `budget create` | Scaffold `.perf-budget.json` from `schema/perf-budgets.json`. |
| `budget check` | Compare current metrics against `.perf-budget.json`; exit non-zero on fail. |
| `compare <url-a> <url-b>` | Fetch metrics for both, output a side-by-side delta table. |
| `ci setup` | Generate a Lighthouse CI workflow file for the detected CI provider. |
| `ci check` | Validate that the existing CI workflow enforces the budget. |
| `pagespeed <url>` | (Extension) PageSpeed Insights API. Requires `PAGESPEED_API_KEY`. |
| `crux <url>` | (Extension) Chrome UX Report. Requires `CRUX_API_KEY`. |
| `wpt run <url>` | (Extension) WebPageTest. Requires `WPT_API_KEY`. |

If the subcommand is missing or unknown, print the table above and stop.

---

## `/perf audit` — Fan-Out Orchestration

`/perf audit <url>` is the flagship command. It dispatches the following subagents **in
parallel** using the Task tool, one per concern:

| Agent | File | Focus |
|---|---|---|
| `perf-agent-cwv` | `agents/perf-agent-cwv.md` | LCP / INP / CLS lab + field |
| `perf-agent-bundle` | `agents/perf-agent-bundle.md` | JS/CSS payload, code splitting |
| `perf-agent-network` | `agents/perf-agent-network.md` | TTFB, headers, compression, CDN |
| `perf-agent-render` | `agents/perf-agent-render.md` | Critical rendering path, waterfall |
| `perf-agent-third-party` | `agents/perf-agent-third-party.md` | Third-party script cost |
| `perf-agent-mobile` | `agents/perf-agent-mobile.md` | Mobile-throttled audit |
| `perf-agent-reporter` | `agents/perf-agent-reporter.md` | Aggregates all six and produces final report |

### Orchestration steps

1. Validate the URL: it must be reachable, return 2xx, and have a content-type of HTML.
2. Issue a single message containing six parallel `Task` tool calls (one per analysis
   agent). Each agent receives the URL plus any user-supplied flags (`--mobile`,
   `--region=eu`, etc.).
3. When all six agents return, invoke `perf-agent-reporter` with the concatenated raw
   outputs as input. The reporter deduplicates findings, prioritizes them by impact,
   and emits the final unified report.
4. Save the final report to `.perf-reports/<host>-<timestamp>.md` in the user's project
   directory (creating the directory if needed). Print the path at the end.

### Failure modes

- If any subagent fails (timeout, network error), the reporter must still run, marking
  that section as `[unavailable]` and proceeding.
- If the URL itself is unreachable, abort before fan-out and print a clear error.
- If no extensions are installed, `cwv` will rely on local Lighthouse / Playwright;
  surface a one-line note encouraging the user to install the PageSpeed extension for
  field data.

---

## Single-Focus Commands

For everything other than `audit`, the master skill loads the matching sub-skill **inline**
(no subagent fan-out). The sub-skill's own SKILL.md defines:

- The exact analysis checklist
- The Markdown output format
- The thresholds that determine severity

The master skill's only jobs in single-focus mode are:

1. Validate the URL or path argument.
2. Confirm any required environment variables exist (e.g., `PAGESPEED_API_KEY` for
   `/perf pagespeed`).
3. Hand off to the sub-skill and stream its output back to the user.

---

## Report Format (Unified)

Every `/perf` command — whether single-focus or full audit — produces output that follows
this top-level shape:

```markdown
# Performance Report — <url>

**Score:** <0-100>  •  **Tested:** <ISO timestamp>  •  **Profile:** <mobile|desktop>

## Executive Summary
- Top finding 1 (one sentence)
- Top finding 2
- Top finding 3

## Core Web Vitals
| Metric | Lab  | Field (p75) | Target | Status |
|--------|------|-------------|--------|--------|
| LCP    | …    | …           | <2.5s  | …      |
| INP    | …    | …           | <200ms | …      |
| CLS    | …    | …           | <0.1   | …      |

## Findings
### 🔴 Critical
- …

### 🟠 High
- …

### 🟡 Medium
- …

### 🟢 Low / Info
- …

## Quick Wins (copy-paste ready)
```html
<!-- e.g., add this to <head> -->
<link rel="preconnect" href="https://cdn.example.com">
```

## 30 / 60 / 90 Day Roadmap
- **30 days:** …
- **60 days:** …
- **90 days:** …
```

Severity emojis are **only** used in the report headings, never inside body text.

---

## Tools the master skill uses

- **Bash / PowerShell** — invoke local Lighthouse, curl HEAD requests, run Playwright.
- **Read / Write / Edit** — read build output, write the final report file.
- **Glob / Grep** — find `package.json`, build manifests, `next.config.*`, etc.
- **Task** — fan-out subagents during `/perf audit`.
- **WebFetch** — fetch the target URL's HTML, headers, and key resources.

---

## Performance Budget Awareness

Before producing a final report, check for `.perf-budget.json` in the project root. If
present, compare measured metrics against the budget and **promote any breach to Critical
severity**, regardless of the absolute value. A green score with a budget breach is still
a regression.

---

## Cross-Skill Hooks

If `claude-seo` is installed in the user's environment, surface a one-line note when CWV
issues are found:

> *Tip: Core Web Vitals affect search ranking. Run `/seo audit <url>` for a content-side
> companion analysis.*

Do **not** auto-invoke other skills. Only suggest.

---

## Examples

**Full audit:**
```
/perf audit https://example.com
```

**Targeted INP investigation:**
```
/perf cwv https://example.com/checkout
```

**Bundle bloat after a build:**
```
/perf bundle ./dist
```

**A/B comparison vs a competitor:**
```
/perf compare https://example.com https://competitor.com
```

**CI enforcement:**
```
/perf budget create
/perf ci setup
```
