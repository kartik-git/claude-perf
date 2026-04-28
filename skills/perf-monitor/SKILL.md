---
name: perf-monitor
description: RUM and synthetic monitoring guidance — web-vitals.js instrumentation, beacon endpoint design, p75/p95 strategy, alerting, and tool comparison.
type: skill
parent: perf
---

# `perf-monitor` — Real-User Monitoring & Alerting

## Scope

Lab data tells you what your test rig sees. Field data — Real-User Monitoring (RUM) —
tells you what your users actually experience. This sub-skill covers instrumentation,
data collection, percentile strategy, alerting thresholds, and tool selection.

## When to invoke

- `/perf monitor <url>` — explicit
- Mentions of: "RUM", "web-vitals.js", "Sentry performance", "Datadog RUM",
  "SpeedCurve", "Calibre", "synthetic monitoring", "beacon"

## What to instrument (must-have)

1. **LCP** — `web-vitals` library, official Google package: `npm install web-vitals`.
2. **INP** — same package; uses the Event Timing API.
3. **CLS** — same package; uses the Layout Instability API.
4. **TTFB** — same package; from Navigation Timing.
5. **FCP** — bonus, useful as a leading indicator for LCP regressions.
6. **Page identity** — URL, pathname, route template (not query strings — too high
   cardinality), screen size, network type (`navigator.connection.effectiveType`),
   device memory, deployment SHA, A/B variant.

## What to instrument (nice-to-have)

- Soft-navigation Web Vitals (post-SPA-route-change LCP/INP/CLS).
- Long Animation Frames (LoAF) for INP root-cause traces.
- Custom marks: `time-to-data-loaded`, `time-to-first-meaningful-paint-component`.
- Element-level LCP (which selector?). Helpful for triage.

## Beacon endpoint design

```js
import { onLCP, onINP, onCLS, onFCP, onTTFB } from 'web-vitals';

const send = (metric) => {
  const body = JSON.stringify({
    name: metric.name,
    value: metric.value,
    id: metric.id,
    rating: metric.rating,
    delta: metric.delta,
    nav: metric.navigationType,
    href: location.href,
    route: window.__APP_ROUTE__,           // populated by router
    sha: window.__BUILD_SHA__,
    eft: navigator.connection?.effectiveType,
    dm:  navigator.deviceMemory,
    dpr: devicePixelRatio,
    vp:  `${innerWidth}x${innerHeight}`,
    ts:  Date.now(),
  });
  // sendBeacon fires even on unload; falls back to fetch keepalive
  (navigator.sendBeacon && navigator.sendBeacon('/_rum', body)) ||
    fetch('/_rum', { method: 'POST', body, keepalive: true });
};

onLCP(send); onINP(send); onCLS(send); onFCP(send); onTTFB(send);
```

Server-side: validate, sample (or ingest 100% if you can afford), aggregate by
`(route, eft, dm)` for percentile-driven dashboards.

## Percentile strategy

| Percentile | What it tells you |
|---|---|
| p50 | Median. Gives a vibe. Don't optimize against this alone. |
| **p75** | Google's CWV definition. The metric for ranking. |
| p90 | Slow-but-not-extreme bucket. Good for triage. |
| p95 | Long tail begins. Often dominated by one specific device/network combo. |
| p99 | Worst 1%. Frequently extreme outliers (offline, mid-redirect). Filter cautiously. |

Always alert on **p75** for CWV. Alert on **p95** for diagnostic metrics like TTFB.

## Sampling

For high-traffic sites, 10% sampling is usually enough for stable p75 numbers — and
keeps beacon traffic affordable. For lower-traffic sites, sample 100%.

Sample at the **session** level, not the **page-view** level. Otherwise a single bad
session looks like 5 separate bad page views.

## Synthetic monitoring

RUM tells you what *did* happen. Synthetic monitoring tells you what *will* happen on
the next deploy. Run both.

Synthetic options:
- **Lighthouse CI** — free, GitHub Actions, runs Lighthouse on every PR.
- **SpeedCurve** — paid, beautiful dashboards, scheduled tests across regions.
- **Calibre** — paid, great budget enforcement.
- **WebPageTest** (private instance) — most flexible, OSS friendly.
- **Treo / DebugBear** — newer, well-priced.

Run synthetic on:
- Every PR (Lighthouse CI as a status check)
- Every deploy (post-deploy hook into staging + prod)
- Hourly schedule on top 5 critical routes from 3 regions

## Alerting thresholds

```yaml
alerts:
  - name: "CWV regression: LCP p75 > 2.5s"
    metric: lcp.p75
    threshold: 2500
    window: 5m
    notify: ["#perf-alerts", "perf-oncall@…"]

  - name: "CWV regression: INP p75 > 200ms"
    metric: inp.p75
    threshold: 200
    window: 5m
    notify: ["#perf-alerts"]

  - name: "TTFB anomaly: p95 > 1.5s"
    metric: ttfb.p95
    threshold: 1500
    window: 10m
    notify: ["#infra-alerts"]
```

## Tool comparison

| Tool | RUM | Synthetic | Free tier | Strengths | Weaknesses |
|---|---|---|---|---|---|
| **Sentry Performance** | yes | no | small | Already in many stacks; tied to errors | Limited CWV depth |
| **Datadog RUM** | yes | yes | trial | Enterprise observability | Pricey |
| **New Relic Browser** | yes | yes | small | Established | UX is dated |
| **SpeedCurve** | yes | yes | trial | Beautiful UI, perfomance-only focus | Pricey at scale |
| **Calibre** | yes | yes | trial | Strong budgets, alerts | Mid-tier price |
| **Cloudflare RUM** | yes | no | yes | Free if you use CF | CWV-only |
| **DebugBear** | yes | yes | trial | Modern, GA4 integration | Newer, smaller |
| **Self-hosted** (web-vitals → ClickHouse / Postgres) | yes | no | n/a | Full control, cheap at scale | Build it yourself |

## Output format

```markdown
# RUM Setup Recommendation — <url>

## Current state
- web-vitals.js: not installed
- Beacon endpoint: none detected
- Synthetic: Lighthouse CI not configured
- RUM tool: none detected

## Recommended stack
1. **web-vitals.js** for instrumentation (free, official)
2. **<recommended RUM tool>** (rationale: …)
3. **Lighthouse CI** as PR gate
4. **<synthetic tool>** for hourly cross-region checks

## Step-by-step
1. `npm install web-vitals`
2. Drop `src/perf-rum.ts` (snippet above) into your app entry.
3. Stand up `/_rum` ingestion endpoint (sample code below).
4. Configure dashboard: LCP/INP/CLS p75 by route + device class.
5. Configure alerts (sample YAML above).

## Budgets to enforce
| Route | LCP p75 | INP p75 | CLS p75 |
|-------|---------|---------|---------|
| /     | 2.5s    | 200ms   | 0.1     |
| /pdp/*| 2.5s    | 200ms   | 0.1     |
| …     | …       | …       | …       |
```

## Tools

- **Read** for `package.json` (detect existing RUM/observability deps).
- **Glob** for any existing `service-worker.js`, `_rum.*`, web-vitals references.
- **Bash** to scaffold the snippet into a project file if requested.

## References

- web-vitals.js: https://github.com/GoogleChrome/web-vitals
- Lighthouse CI: https://github.com/GoogleChrome/lighthouse-ci
- web.dev — Best practices for RUM: https://web.dev/articles/vitals-measurement-getting-started
- Long Animation Frames API: https://developer.chrome.com/docs/web-platform/long-animation-frames
