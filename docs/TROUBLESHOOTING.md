# Troubleshooting

## `/perf audit` returns "[unavailable]" for several agents

Agents fall back to `[unavailable]` when an external tool is missing. Most common:

- **Lighthouse not installed** → `npm i -g lighthouse`
- **Playwright not installed** → `npm i -D playwright && npx playwright install`
- **`curl --http3` unsupported** → upgrade curl (`brew install curl --HEAD` on macOS)
- **No internet on the test host** → audits need outbound HTTPS

## CrUX returns "no data"

CrUX requires a URL to have enough traffic for anonymization (~thousands of weekly
visitors). For low-traffic URLs, fall back to origin-level data:

```
/perf crux <origin>
```

## PageSpeed Insights rate-limited

Default quota is ~25,000 queries/day per key. Symptoms: `429` responses.

- Cache aggressively (`.perf-cache/`)
- Apply for a higher quota in Google Cloud Console
- Or use the `crux` extension instead for field-only queries

## WebPageTest test stuck in "queued"

WPT public infrastructure shares a queue. Options:
- Pick a less-popular location (`--location=Frankfurt:Chrome` etc.)
- Use a private WPT instance for predictable runtime
- Switch to PSI for a faster (less detailed) lab measurement

## Lighthouse mobile profile gives unstable numbers

Lab mobile metrics have high run-to-run variance (~20%). For diagnostic work, run
Lighthouse 5–10 times and report the median. For ranking-relevant metrics, prefer CrUX
field data.

## "No `.perf-budget.json` found"

`/perf budget check` requires a budget file at the project root. Bootstrap with:

```
/perf budget create
```

It picks a template based on the project type it detects (e-commerce, SaaS, blog, etc.).

## Hooks not firing

1. Verify your `~/.claude/settings.json` has the hook registered under the right matcher.
2. Run the hook manually: `bash hooks/on-build-complete.sh` — it should print either a
   detection message or exit silently.
3. Check that the hook script is executable (`chmod +x` on Unix).

## Reporter agent times out

The reporter has a 30-second cap. If it times out, usually one of the other agents
returned an unusually large output. Re-run with fewer agents (`/perf cwv ...` instead of
`/perf audit ...`) to isolate.

## Reports saved to wrong location

`.perf-reports/` is created at the **project working directory** (whatever Claude Code
considers `cwd`), not your home directory. If you're in a subdirectory, the report
lands there.

## Where do logs live?

`claude-perf` itself doesn't write logs. Errors surface in Claude Code's output. For
verbose output during a Lighthouse run, set `LIGHTHOUSE_LOG=debug` before invoking
`/perf cwv`.
