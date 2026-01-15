# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Git Safety Rules

**NEVER perform these actions without explicit user permission:**

- `git commit` — Always ask before committing
- `git push` — Always ask before pushing
- `git push --force` — NEVER do this
- `gh pr create` — Always ask before creating PRs
- `git reset --hard` — NEVER do this without permission
- `git rebase` — Always ask before rebasing

**Workflow:**
1. Make changes as requested
2. Show what changed (`git diff --stat`)
3. **ASK** before committing
4. **ASK** before pushing
5. **ASK** before creating PR

---

## Repository Overview

This is a monorepo containing Claude Code plugins. Each plugin is self-contained in its own directory with a `.claude-plugin/plugin.json` manifest.

**Plugins:**
- `pr-patrol/` (v1.4.1) — PR bot comment processor with 7-gate workflow
- `spec-interview/` (v2.0.0) — Requirements interview for PRD generation

## Plugin Structure

Each plugin follows this structure:
```text
plugin-name/
├── .claude-plugin/plugin.json   # Required manifest
├── commands/                    # Slash commands (*.md)
├── agents/                      # Custom agents (*.md)
├── skills/skill-name/           # Skills with SKILL.md + supporting files
│   ├── SKILL.md
│   ├── phases/                  # Phase-specific instructions
│   └── scripts/                 # Executable scripts (.sh, .jq)
└── README.md
```

## Development Notes

### pr-patrol

**Platform:** Linux, macOS (`brew install coreutils`), Windows (WSL)

**Prerequisites:** `gh` (GitHub CLI), `jq` 1.6+, Bash 4.0+

**Scripts location:** `pr-patrol/skills/pr-patrol/scripts/`
- Shell scripts (`.sh`) — fetching, state management
- jq filters (`.jq`) — JSON parsing, bot detection

**State files:** Created at `.claude/bot-reviews/PR-{number}.md` in the target project (not in this repo)

**Supported bots:** CodeRabbit, Greptile, Copilot, Codex, Sentry

### spec-interview

**No external dependencies.** Pure prompt-based skill.

**Supports 12 languages:** Auto-detected from user input.

**Output:** 13-section PRD document.

## Testing Plugins Locally

```bash
# Test a specific plugin
claude --plugin-dir ./pr-patrol

# Test from repo root (uses root plugin.json)
claude --plugin-dir .
```

## Validation

Run plugin validation before commits:
```bash
# Check plugin manifest
cat pr-patrol/.claude-plugin/plugin.json | jq .

# Verify all referenced files exist
ls -la pr-patrol/agents/
ls -la pr-patrol/commands/
ls -la pr-patrol/skills/pr-patrol/
```
