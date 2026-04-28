---
name: perf-third-party
description: Third-party script impact audit — inventory, blocking-time cost, transfer size, facade patterns, async/defer opportunities, Partytown, and tag-manager hygiene.
type: skill
parent: perf
---

# `perf-third-party` — Third-Party Script Cost

## Scope

Every byte the page loads from a domain other than its own first-party origin: analytics,
ads, A/B testing, chat widgets, embed scripts, tag managers, fonts (covered separately
under `perf-fonts`), maps, video players, social-media widgets.

Third parties are usually the #1 source of INP regressions and the #1 source of "we
don't control the code that's slowing us down."

## When to invoke

- `/perf third-party <url>` — explicit
- During `/perf audit` — fan-out via `perf-agent-third-party`
- Mentions of: "GTM", "tag manager", "analytics", "ads", "Optimizely", "Hotjar",
  "Intercom", "Drift", "Segment", "blocking time", "Partytown"

## Analysis checklist

### Inventory
1. **Enumerate every third-party request** — group by registered domain (Public Suffix
   List). For each group: count, transfer size, total blocking time, longest task.
2. **Categorize:**
   - Analytics (GA4, Plausible, Fathom, Heap, Mixpanel)
   - Tag manager (GTM, Tealium, Segment)
   - Ads (Google Ad Manager, Prebid)
   - Chat / support (Intercom, Drift, Zendesk, Hubspot chat)
   - A/B testing (Optimizely, VWO, AB Tasty)
   - Session replay (Hotjar, FullStory, LogRocket)
   - Social embeds (Twitter, LinkedIn, YouTube, Vimeo)
   - Maps (Google Maps, Mapbox)
   - Other (CAPTCHA, payments, etc.)

### Cost
1. **Total blocking time (TBT)** contributed by each third party.
2. **Transfer size** per third party (with compression).
3. **Number of subrequests** each script triggers — chat widgets often fan out to 6+
   additional origins.
4. **Long tasks** caused by their JS execution.

### Mitigation patterns

#### `async` / `defer`
- Default for any non-critical third-party `<script>`. Most analytics/tag-manager
  scripts can be `defer`. Most ads cannot.

#### Facade pattern
Replace the heavy third-party widget with a static placeholder that loads the real
thing on user interaction.
- **YouTube embed** → poster image + play button → load iframe on click.
  Use `lite-youtube-embed`.
- **Live chat** → static "Chat" button → load Intercom on click.
- **Google Maps** → static map image (Maps Static API) → load interactive on click.
- **Twitter/LinkedIn embeds** → server-rendered card → load widget on click.

#### Web Worker (Partytown)
Partytown moves third-party scripts off the main thread into a web worker, mediating
DOM access via `postMessage`. Suitable for: analytics, tag managers, A/B testing.
Not suitable for: scripts that need synchronous DOM access during render.

#### Tag manager audit
- List every tag firing on the page.
- Flag duplicates (same vendor twice — usually a leftover migration).
- Flag tags with `firingTrigger=All Pages` that should be route-scoped.
- Flag tags last edited >12 months ago + no events in 30 days (stale).

#### Self-hosting
Self-host the Google Analytics / Plausible / Fathom snippet from your own origin to
get HTTP/2 multiplexing and avoid an extra DNS+TCP+TLS handshake.

## Output format

```markdown
# Third-Party Audit — <url>

**Third-party origins:** N  •  **Transfer size:** … KB  •  **Total blocking time:** … ms

## Top contributors
| Origin | Category | Requests | Transfer | TBT  | Notes |
|--------|----------|----------|----------|------|-------|
| googletagmanager.com | tag mgr | 14 | 220 KB | 380 ms | sync, no defer |
| youtube.com / ytimg.com | embed | 9 | 540 KB | 220 ms | facade candidate |
| intercom.io | chat   | 6 | 180 KB | 140 ms | facade candidate |
| connect.facebook.net | analytics | 3 | 90 KB | 80 ms | unused — pixel firing without active campaigns |

## Mitigation candidates
- **Facade YouTube embed** → save ~540 KB, ~220 ms TBT
- **Defer GTM** → save ~380 ms TBT (move to `</body>`)
- **Replace Intercom inline load with `loadOnInteraction()`** → save ~180 KB on first paint
- **Remove Facebook pixel** → confirm with marketing first

## GTM tag audit (if GTM detected)
- 24 tags total, 3 firing on All Pages without need
- 4 tags last edited > 18 months ago, recommend review

## Recommendations (tiered)
### Critical
- …
### High / Medium / Low
- …
```

## Tools

- **WebFetch** to fetch HTML and enumerate `<script src=...>`.
- **Playwright** with `page.on('request', ...)` to capture every request, then
  group by registered domain (use `tldextract`).
- Reference: https://github.com/patrickhulce/third-party-web — categorized list of
  third-party domains with average TBT cost.

## References

- web.dev — Third-party JavaScript: https://web.dev/articles/third-party-javascript
- Partytown: https://partytown.builder.io/
- third-party-web: https://www.thirdpartyweb.today/
- lite-youtube-embed: https://github.com/paulirish/lite-youtube-embed
