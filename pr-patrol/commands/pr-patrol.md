---
description: Process PR bot comments (CodeRabbit, Greptile, Codex, Copilot, Sentry) with batch validation and state tracking
argument-hint: "[pr-number]"
allowed-tools: Bash, Read, Edit, Write, Grep, Glob, Task, AskUserQuestion
---

# /pr-patrol

## STOP - Phase-Based Routing Required

This command uses **7-gate workflow** with mandatory checkpoints. Do NOT continue reading inline - follow the routing below.

---

## Step 1: Detect PR Number

```bash
PR_NUMBER="${1:-$(gh pr view --json number -q '.number' 2>/dev/null)}"
echo "PR: $PR_NUMBER"
```

## Step 2: Check State File

```bash
STATE_FILE=".claude/bot-reviews/PR-${PR_NUMBER}.md"
if [ -f "$STATE_FILE" ]; then
  echo "State file exists - resuming workflow"
  grep -E "^(status|next_gate|next_action):" "$STATE_FILE"
else
  echo "No state file - starting fresh"
fi
```

## Step 3: Read SKILL.md

**MANDATORY:** Read the skill file for phase routing:

```
${CLAUDE_PLUGIN_ROOT}/skills/pr-patrol/SKILL.md
```

## Step 4: Read Current Gate File

Based on state file `status` field, read the correct gate:

| Status | Gate File to Read |
|--------|-------------------|
| (no file) | `phases/gate-0-init.md` |
| `initialized` | `phases/gate-1-collect.md` |
| `collected` | `phases/gate-2-validate.md` |
| `validated` / `fixes_planned` / `fixes_applied` | `phases/gate-3-fix.md` |
| `checks_passed` | `phases/gate-4-commit.md` |
| `committed` | `phases/gate-5-reply.md` |
| `replies_sent` | `phases/gate-6-push.md` |

---

## MANDATORY Rules

1. **EVERY gate requires AskUserQuestion** - NEVER skip user approval
2. **Use scripts** from `${CLAUDE_PLUGIN_ROOT}/skills/pr-patrol/scripts/`
3. **Copilot = SILENT FIX** - No replies, no reactions, ever
4. **Read bot-formats.md** before Gate 5 (replies)
5. **Issue comments need @mention** - No threading support
6. **Reaction BEFORE reply** for Greptile/Codex/Sentry
7. **Short reply format** - "Fixed in commit {sha}: {description}" not essays
8. **Update state file** after every gate completion

---

## Quick Reference

| Bot | Reaction | Reply |
|-----|----------|-------|
| CodeRabbit | No | Yes |
| Greptile | Yes (first!) | Yes |
| Codex | Yes (first!) | Yes |
| Sentry | Yes (first!) | Yes |
| **Copilot** | **NEVER** | **NEVER** |

---

**START NOW:** Read SKILL.md, then the appropriate gate file based on status.
