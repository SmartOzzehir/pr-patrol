# Changelog

## [1.0.0] - 2026-01-15

Initial release.

### Features

- **7-Gate Workflow** — Structured process: Init → Collect → Validate → Fix → Commit → Reply → Push
- **Batch Validation** — Validate multiple bot comments in parallel using specialized agents
- **5 Bot Support** — CodeRabbit, Greptile, Copilot, Codex, Sentry with bot-specific protocols
- **State Persistence** — Track progress in `.claude/bot-reviews/PR-{number}.md`
- **False Positive Detection** — Identify and dismiss incorrect suggestions
- **Cross-Platform** — Linux, macOS (with coreutils), Windows (WSL)
