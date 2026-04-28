# Changelog

All notable changes to `claude-perf` are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial scaffold of `claude-perf`: master skill, 13 sub-skills, 7 subagents.
- `/perf audit` orchestrator with parallel subagent fan-out.
- `/perf cwv`, `/perf bundle`, `/perf render`, `/perf images`, `/perf fonts`,
  `/perf network`, `/perf cache`, `/perf third-party`, `/perf mobile`, `/perf ssr`,
  `/perf plan`, `/perf monitor`, `/perf budget`, `/perf compare`, `/perf ci`.
- Performance budget templates for ecommerce, SaaS, media, docs, and blog sites.
- PageSpeed Insights, CrUX, and WebPageTest extension scaffolds.
- Post-build and post-deploy hooks.
- Unix and Windows installers.

## [0.1.0] - 2026-04-28

- First public scaffold.
