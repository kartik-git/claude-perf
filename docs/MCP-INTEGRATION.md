# MCP Integration

`claude-perf`'s extensions can be exposed as MCP servers if you want them callable from
contexts other than Claude Code (e.g., from your own agents).

> **Note:** MCP server scaffolding is optional. The core skill works without any MCP
> setup — extensions ship as plain CLIs that read API keys from environment variables.

## When to use MCP vs plain extension

| Use case | Recommendation |
|---|---|
| Just running `/perf` from Claude Code | Plain extension is enough |
| Sharing PSI / CrUX / WPT calls across multiple skills or agents | MCP server |
| Calling from a non-Claude harness (custom agent, CLI) | MCP server |
| You want to centralize rate-limit / caching | MCP server |

## Reference layout

If you decide to wrap an extension as an MCP server:

```
extensions/<name>/mcp/
├── server.py              ← stdio MCP server
├── tools.py               ← @tool-decorated functions
├── pyproject.toml
└── README.md
```

Wire it into `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "perf-pagespeed": {
      "command": "python",
      "args": ["-m", "claude_perf.pagespeed.mcp.server"],
      "env": {
        "PAGESPEED_API_KEY": "${PAGESPEED_API_KEY}"
      }
    }
  }
}
```

## Recommended MCP tools per extension

### `perf-pagespeed`
- `pagespeed_run(url, strategy, category)` → full PSI JSON
- `pagespeed_field(url)` → CrUX subset only
- `pagespeed_compare(url_a, url_b)` → diff dict

### `perf-crux`
- `crux_origin(origin, form_factor, country)` → percentile dict
- `crux_url(url, form_factor, country)` → percentile dict (404s if no data)
- `crux_history(url|origin, months=12)` → time series

### `perf-wpt`
- `wpt_run(url, location, browser, network)` → test_id
- `wpt_status(test_id)` → status enum
- `wpt_results(test_id)` → metrics dict

## Caching

For all three extensions, recommend a 24-hour cache keyed by `(method, url, options)`.
PSI and CrUX rate-limit aggressively; WPT bills per run.

## Security

- Never log API keys.
- `Vary` cached responses by API key prefix to prevent cross-tenant cache hits in shared
  environments.
- Sanitize URL input — no internal network probes (block RFC 1918 / loopback / link-local
  by default; opt-in via flag).
