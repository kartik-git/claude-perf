# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security issue in `claude-perf`, please report it privately by emailing
the maintainers at the address listed in `pyproject.toml`. Do **not** open a public GitHub
issue for security reports.

We aim to acknowledge reports within 72 hours and resolve confirmed issues within 30 days.

## Scope

`claude-perf` runs locally as a Claude Code skill. It can:

- Make outbound HTTP requests to URLs you supply (audit targets, PageSpeed, CrUX, WPT).
- Read files inside your repo (bundle stats, build output, configs).
- Write reports to disk under your project directory.

It does **not**:

- Send your source code to third parties.
- Phone home or collect telemetry.
- Modify files outside your project directory unless you explicitly request it.

## Sensitive Data

API keys for extensions (PageSpeed, CrUX, WebPageTest) live in environment variables and
are never written to disk by this skill. If you supply credentials in a `.env` file, that
file should be `.gitignore`d and is the user's responsibility to protect.
