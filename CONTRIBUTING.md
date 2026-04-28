# Contributing to claude-perf

Thanks for your interest in improving `claude-perf`. This document describes how to add
sub-skills, agents, and extensions.

## Development setup

```bash
git clone https://github.com/kartik-git/claude-perf.git
cd claude-perf
python -m venv .venv && source .venv/bin/activate    # or .venv\Scripts\activate on Windows
pip install -r requirements.txt
```

To install the in-development copy as your active Claude Code skill:

```bash
bash install.sh --dev    # symlinks instead of copying
```

## Adding a sub-skill

1. Create `skills/perf-<topic>/SKILL.md`.
2. Follow the structure of existing sub-skills:
   - `## Scope` — what this skill audits
   - `## When to invoke` — triggers and routing rules
   - `## Analysis checklist` — concrete steps the skill performs
   - `## Output format` — Markdown report shape
   - `## Thresholds & references` — citations to web.dev / RFCs
3. Register the skill in `perf/SKILL.md`'s router table.
4. Add a command alias in `docs/COMMANDS.md`.

## Adding an agent

1. Create `agents/perf-agent-<topic>.md`.
2. Front-matter must declare: `name`, `description`, `tools`, `model` (optional).
3. The agent prompt should be self-contained — assume no prior conversation context.
4. Wire the agent into `perf/SKILL.md`'s fan-out map for `/perf audit`.

## Adding an extension

Extensions live under `extensions/<name>/` and provide MCP integrations or external API
glue. Each extension ships its own `install.sh`, `README.md`, and any required helper
scripts. The extension's slash commands should be namespaced under `/perf <name> ...`.

## Style

- Markdown: prefer 100-char soft wrap, ATX headings, fenced code blocks with language tags.
- Python: ruff-formatted, type-hinted where practical.
- Shell: `set -euo pipefail` at the top of every script; prefer POSIX over bashisms when
  possible.

## Testing

Run the offline test suite:

```bash
pytest tests/
```

Live integration tests (PSI / CrUX / WPT) require API keys and are gated behind
`PERF_LIVE=1`.

## Pull requests

- One concept per PR.
- Update `CHANGELOG.md` under `## [Unreleased]`.
- Update `docs/` if you change command syntax.
- Sub-skills must include at least one example invocation in the SKILL.md.
