# Installation

## Standard install

### Unix / macOS / Linux / WSL
```bash
git clone --depth 1 https://github.com/kartik-git/claude-perf.git
bash claude-perf/install.sh
```

### Windows
```powershell
git clone --depth 1 https://github.com/kartik-git/claude-perf.git
powershell -ExecutionPolicy Bypass -File claude-perf\install.ps1
```

## What gets installed

The installer copies into `~/.claude/`:

```
~/.claude/
├── skills/
│   ├── perf/                  # master skill
│   ├── perf-cwv/
│   ├── perf-bundle/
│   ├── … (13 sub-skills total)
└── agents/
    ├── perf-agent-cwv.md
    ├── perf-agent-bundle.md
    └── … (7 agents total)
```

Use `--dev` (or PowerShell `-Dev`) to symlink instead of copy — recommended when
contributing.

## Wiring up hooks (optional)

Hooks are off by default. To enable them, edit `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "/absolute/path/to/claude-perf/hooks/on-build-complete.sh"
          }
        ]
      }
    ]
  }
}
```

The hook runs after every Bash invocation; the script itself short-circuits unless a
build directory is detected.

## Optional dependencies

| Tool | Used by | How to install |
|---|---|---|
| Lighthouse | `/perf cwv`, `/perf audit`, `/perf mobile` | `npm i -g lighthouse` |
| Playwright | `/perf cwv` (INP traces), `/perf images`, `/perf third-party` | `npm i -D playwright && npx playwright install` |
| `cwebp` / `avifenc` | `/perf images` savings estimates | `brew install webp libavif` (macOS) |
| `curl --http3` | `/perf network` HTTP/3 detection | `brew install curl --HEAD` (macOS) |

The skill works without any of these — it'll fall back to static analysis and note
what was unavailable in the report.

## Extension setup

Each extension lives under `extensions/<name>/` and ships its own installer:

```bash
export PAGESPEED_API_KEY=...
bash extensions/pagespeed/install.sh

export CRUX_API_KEY=...
bash extensions/crux/install.sh

export WPT_API_KEY=...
bash extensions/webpagetest/install.sh
```

## Uninstall

```bash
bash uninstall.sh
# or
powershell -ExecutionPolicy Bypass -File uninstall.ps1
```

This removes only the skill / agent files copied by the installer. Your
`settings.json`, hooks config, and any `.perf-budget.json` / `.perf-reports/` in your
projects are left untouched.
