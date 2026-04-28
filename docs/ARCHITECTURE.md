# Architecture

`claude-perf` follows the same multi-skill / multi-agent pattern as `claude-seo`.

## Layout in `~/.claude/`

```
~/.claude/
├── skills/
│   ├── perf/                  ← master orchestrator (router)
│   ├── perf-cwv/              ← Core Web Vitals
│   ├── perf-bundle/           ← JS / CSS payload
│   ├── perf-render/           ← critical rendering path
│   ├── perf-images/           ← image audit
│   ├── perf-fonts/            ← web font loading
│   ├── perf-network/          ← protocol / TTFB / compression
│   ├── perf-caching/          ← Cache-Control / CDN / SW
│   ├── perf-third-party/      ← 3p cost inventory
│   ├── perf-ssr/              ← SSR / hydration
│   ├── perf-mobile/           ← mobile-throttled
│   ├── perf-accessibility/    ← perf-adjacent a11y
│   ├── perf-plan/             ← strategic roadmaps
│   └── perf-monitor/          ← RUM guidance
└── agents/
    ├── perf-agent-cwv.md
    ├── perf-agent-bundle.md
    ├── perf-agent-network.md
    ├── perf-agent-render.md
    ├── perf-agent-third-party.md
    ├── perf-agent-mobile.md
    └── perf-agent-reporter.md
```

## Two execution paths

### `/perf audit` — fan-out

```
user invokes /perf audit https://example.com
        │
        ▼
perf/SKILL.md (router) validates URL, then issues
ONE message containing 6 parallel Task tool calls:
        │
        ├─▶ perf-agent-cwv ─────────────┐
        ├─▶ perf-agent-bundle ──────────┤
        ├─▶ perf-agent-network ─────────┤
        ├─▶ perf-agent-render ──────────┼─▶ each returns Markdown
        ├─▶ perf-agent-third-party ─────┤
        └─▶ perf-agent-mobile ──────────┘
                                        │
                                        ▼
                              perf-agent-reporter
                                        │
                                        ▼
                          .perf-reports/<host>-<ts>.md
```

The orchestrator does **not** wait sequentially — all six agents run concurrently, then
the reporter is invoked once with their concatenated outputs.

### Single-focus commands — inline

For commands like `/perf cwv` or `/perf bundle`, the master skill loads the matching
sub-skill **inline** and executes its analysis directly. No subagent fan-out, no
reporter step.

## Sub-skill anatomy

Every sub-skill is a single Markdown file with this structure:

```
---
name: perf-<topic>
description: <one line>
type: skill
parent: perf
---

# perf-<topic> — <Title>

## Scope
## When to invoke
## Analysis checklist
## Output format
## Tools
## References
```

The `## Output format` section is a Markdown template. The agent (or the inline-invoked
skill) fills it in and returns it verbatim.

## Agent anatomy

Every agent is a single Markdown file with frontmatter:

```
---
name: perf-agent-<topic>
description: <one line>
tools: <tool list>
model: sonnet
---
```

The body is the agent's system prompt. It's self-contained — the agent has no prior
conversation context, so the prompt explicitly states the input shape, the job, the
output format, and the constraints.

## Cross-skill data flow

- `perf-agent-render` may flag image issues; full image audit lives in `perf-images`.
  The render agent stays brief and points the reporter at the deeper sub-skill if a
  user wants follow-up.
- `perf-agent-network` covers headers; `perf-caching` is the deeper drill-down.
- `perf-agent-cwv` and `perf-agent-render` will sometimes flag the same issue (LCP image
  not preloaded). The reporter's dedup step merges them.

## State on disk

| File | Purpose | Owner |
|---|---|---|
| `.perf-budget.json` | Project-level budget | User (created by `/perf budget create`) |
| `.perf-reports/<host>-<ts>.md` | Audit report archive | Reporter agent |
| `.perf-ignore` | Glob list of paths to skip | User |
| `.perf-cache/` | Cached PSI / CrUX responses | Extensions |

## Why this shape

- **One file per concern** keeps every skill and agent independently editable.
- **Subagent fan-out** parallelizes the slow parts (Lighthouse, Playwright, repeated
  curl) without flattening the conversation context.
- **Reporter as a single aggregator** means there's one source of truth for severity
  promotion (especially budget breaches).
- **Single-focus inline mode** means a user who knows exactly what they want
  (`/perf bundle ./dist`) doesn't pay the fan-out cost.
