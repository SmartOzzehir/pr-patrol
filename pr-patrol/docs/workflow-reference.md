# PR Patrol Workflow Reference (Archive)

> **Note:** This is an archived reference document. The active workflow is controlled by:
> - `skills/pr-patrol/SKILL.md` — Phase routing
> - `skills/pr-patrol/phases/gate-*.md` — Detailed gate instructions
> - `hooks/hooks.json` — Workflow enforcement

---

## Original Inline Workflow

Process PR bot review comments through batch validation with state persistence.

---

## Phase 1: Collect

### Step 1.1 — Detect PR

```bash
# If PR number provided as argument, use it
# Otherwise detect from current branch:
gh pr view --json number,headRepository,headRefName --jq '{
  pr: .number,
  owner: .headRepository.owner.login,
  repo: .headRepository.name,
  branch: .headRefName
}'
```

### Step 1.2 — Load/Create State File

State file location: `.claude/bot-reviews/PR-{number}.md` (in current project)

- **Exists:** Read it, determine current cycle, identify PENDING/REJECTED from previous
- **New:** Create directory if needed, start with cycle 1

```bash
mkdir -p .claude/bot-reviews
```

### Step 1.3 — Fetch ALL Comments

**CRITICAL:** Fetch from BOTH endpoints with pagination!

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT}/skills/pr-patrol/scripts"

# Use the fetch script (handles both endpoints + normalization)
"$SCRIPTS/fetch_pr_comments.sh" "$OWNER" "$REPO" "$PR" > /tmp/pr_comments.json

# Or manually:
# 1. Review comments (line-level)
gh api repos/{owner}/{repo}/pulls/{pr}/comments --paginate --jq '
  .[] | {
    type: "review",
    id,
    bot: .user.login,
    in_reply_to_id,
    created_at,
    path,
    line,
    diff_hunk,
    body
  }'

# 2. Issue comments (walkthrough + summaries)
gh api repos/{owner}/{repo}/issues/{pr}/comments --paginate --jq '
  .[] | {
    type: "issue",
    id,
    bot: .user.login,
    created_at,
    body
  }'
```

### Step 1.4 — Extract Embedded CodeRabbit Comments

**CRITICAL:** CodeRabbit embeds additional comments inside the PR walkthrough due to GitHub API limitations. These MUST be extracted separately!

Embedded comment types:
- `♻️ Duplicate comments` — Issues from previous reviews that still apply
- `🔇 Additional comments` — Comments outside the diff range
- `🧹 Nitpick comments` — Minor style suggestions

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT}/skills/pr-patrol/scripts"

# Extract issue comments from already-fetched data (avoids redundant API call)
# Reshape to raw GitHub API format expected by parse_coderabbit_embedded.sh
jq '[.bot_comments[], .user_replies[], .bot_responses[] | select(.type == "issue") | {id, user: {login: .bot}, body}]' /tmp/pr_comments.json > /tmp/issue_comments.json

# Extract embedded comments from CodeRabbit walkthrough
"$SCRIPTS/parse_coderabbit_embedded.sh" /tmp/issue_comments.json > /tmp/embedded_comments.json

# Check what was found
jq '.total_embedded, .by_type' /tmp/embedded_comments.json
```

**WARNING:** Skipping this step means missing nitpicks and duplicate comments from CodeRabbit!

### Step 1.5 — Merge Threads

For each comment:
1. If `in_reply_to_id` is null → root comment (potential issue)
2. If `in_reply_to_id` exists → reply to existing thread
3. Group replies with their root comments

### Step 1.6 — Merge Embedded with Inline Comments

```bash
# Combine inline PR comments with embedded CodeRabbit comments
jq -s '
  .[0] as $inline |
  .[1].comments as $embedded |
  $inline + {
    embedded_count: ($embedded | length),
    comments: ($inline.comments + $embedded)
  }
' /tmp/pr_comments.json /tmp/embedded_comments.json > /tmp/all_comments.json
```

### Step 1.7 — Categorize States

For each bot root comment, determine state:

| Condition | State |
|-----------|-------|
| No user reply | `NEW` |
| User replied, no bot follow-up | `PENDING` |
| Bot follow-up contains approval markers | `RESOLVED` |
| Bot follow-up contains rejection markers | `REJECTED` |

**Approval markers:** "LGTM", "looks good", "thank you", "confirmed", "✅", "addressed"
**Rejection markers:** "but", "however", "still", "don't see", "not fixed", "?"

### Step 1.8 — Update State File

Write discovered comments to state file with categories.

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT}/skills/pr-patrol/scripts"
STATE_FILE=".claude/bot-reviews/PR-${PR}.md"

# Update billboard (status + next gate info)
"$SCRIPTS/update_billboard.sh" "$STATE_FILE" "collected" "2" "Validate comments"
```

### Step 1.9 — Present Summary

```
╔══════════════════════════════════════════════════════════════╗
║  🤖 Review Bots — PR #{number} — Cycle {n}                   ║
╠══════════════════════════════════════════════════════════════╣
║  Found {total} comments ({inline} inline + {embedded} embedded)
║  From {bot_count} bots                                       ║
║                                                              ║
║  | State | Count | Action |                                  ║
║  |-------|-------|--------|                                  ║
║  | NEW | {x} | Will validate |                               ║
║  | REJECTED | {y} | Need re-fix |                            ║
║  | PENDING | {z} | Awaiting bot |                            ║
║  | RESOLVED | {w} | Skip |                                   ║
║                                                              ║
║  To process: {x + y} comments                                ║
╚══════════════════════════════════════════════════════════════╝
```

**Note:** Embedded comments are from CodeRabbit's walkthrough (♻️ duplicates, 🔇 outside-diff, 🧹 nitpicks).

If PENDING exists, ask:

```
┌─────────────────────────────────────────────────────────────┐
│  {z} threads awaiting bot response.                         │
│                                                             │
│  [1] Re-fetch — Check if bots responded                    │
│  [2] Skip — Focus on NEW + REJECTED only                   │
│  [3] Review — Show list, mark resolved manually            │
└─────────────────────────────────────────────────────────────┘
```

---

## Phase 2: Validate (Batch, Parallel)

### Step 2.1 — Group Comments

Group NEW + REJECTED comments by file for efficient validation:

```
Comments to validate: {count}

Groups:
• src/api.ts: {n} comments
• src/auth.ts: {n} comments
• src/components/*: {n} comments
```

Max 8 groups. If more files, combine smaller ones.

### Step 2.2 — Spawn Validators (Parallel)

For each group, spawn `bot-comment-validator` agent:

```
Task tool (run ALL in parallel, single message):
  subagent_type: "bot-comment-validator"
  model: "opus"
  prompt: |
    Validate these PR bot comments.

    Project: {owner}/{repo}
    Check AGENTS.md for project-specific conventions.

    Comments:
    {JSON array of comments in this group}

    Return JSON array with verdicts.
```

### Step 2.3 — Collect Results

Wait for all validators to complete. Merge results.

### Step 2.4 — Update State

Write validation results to state file.

### Step 2.5 — CHECKPOINT: Batch Review

Present ALL results in one table:

```
╔══════════════════════════════════════════════════════════════╗
║  🤖 Review Bots — PR #{number} — Validation Complete         ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  | # | Bot | File | Issue | Verdict | Conf | Severity |      ║
║  |---|-----|------|-------|---------|------|----------|      ║
║  | 1 | CR  | api.ts:42 | null check | ✓ VALID | 95% | high | ║
║  | 2 | Grep| utils.ts | extract helper | ✓ VALID | 72% | low |║
║  | 3 | CR  | auth.ts | race cond | ✓ VALID | 91% | high |    ║
║  | 4 | Cop | db.ts | N+1 query | ✗ FP | 85% | - |            ║
║  | 5 | CR  | types.ts | unused import | ✓ VALID | 99% | low | ║
║                                                              ║
║  Summary: {valid_count} VALID, {fp_count} FALSE_POSITIVE     ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────┐
│  [1] Continue — Design fixes for VALID issues              │
│  [2] Modify — Change some verdicts                         │
│  [3] Details — Show reasoning for specific comment         │
└─────────────────────────────────────────────────────────────┘
```

---

## Phase 3: Fix (Batch)

### Step 3.1 — Design Fixes

Spawn `pr-fix-architect` agent for ALL valid issues:

```
Task tool:
  subagent_type: "pr-fix-architect"
  prompt: |
    Design fixes for these validated PR bot issues:

    {List of VALID issues with context}

    Check project's AGENTS.md for conventions.
    Return consolidated fix plan with all changes.
```

### Step 3.2 — CHECKPOINT: Approve Plan

```
╔══════════════════════════════════════════════════════════════╗
║  🤖 Review Bots — PR #{number} — Fix Plan                    ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  Files to modify:                                            ║
║  • src/api.ts (3 changes)                                    ║
║  • src/auth.ts (2 changes)                                   ║
║  • src/utils.ts (1 change)                                   ║
║                                                              ║
║  Changes:                                                    ║
║  1. api.ts:42 — Add null check                              ║
║  2. api.ts:67 — Add try-catch                               ║
║  3. auth.ts:15 — Fix race condition                         ║
║  ...                                                         ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────┐
│  [1] Implement — Apply all fixes                           │
│  [2] Details — Show specific fix in detail                 │
│  [3] Modify — Adjust the plan                              │
│  [4] Skip — Don't implement now                            │
└─────────────────────────────────────────────────────────────┘
```

### Step 3.3 — Implement Fixes

Spawn `pr-implementer` agent:

```
Task tool:
  subagent_type: "pr-implementer"
  prompt: |
    Implement these approved fixes:

    {Complete fix plan from architect}

    Apply exactly as designed. Report changes made.
```

### Step 3.4 — Update State

Mark implemented issues in state file.

### Step 3.5 — Run Mandatory Checks

**BLOCKING** - Must pass before proceeding!

```bash
# Typecheck - MUST PASS or exit
(pnpm typecheck || npm run typecheck) || {
  echo "Typecheck failed! Fix errors before proceeding."
  exit 1
}

# Lint with auto-fix - MUST PASS or exit
(pnpm biome check --write src/ || pnpm lint --fix) || {
  echo "Lint failed! Fix errors before proceeding."
  exit 1
}
```

If checks fail, the workflow will stop. Fix the issues and re-run.

### Step 3.6 — Gate 3.5: Quality Review (OPTIONAL)

```
┌─────────────────────────────────────────────────────────────┐
│  Checks passed. Run additional review?                       │
│                                                             │
│  [1] Quick checks only (done)              [Recommended]    │
│  [2] Run code-reviewer agent                                │
│  [3] Run silent-failure-hunter agent                        │
│  [4] Run both                                               │
└─────────────────────────────────────────────────────────────┘
```

If user wants additional review, spawn `pr-review-toolkit:code-reviewer` or `pr-review-toolkit:silent-failure-hunter` agents.

### Step 3.7 — Show Changes

```bash
git diff --stat
git diff
```

### Step 3.8 — CHECKPOINT: Commit Approval

```
╔══════════════════════════════════════════════════════════════╗
║  🤖 Review Bots — PR #{number} — Changes Ready               ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  {n} files changed, {insertions}+, {deletions}-             ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────┐
│  [1] Commit + Push — Create commit, push, send replies     │
│  [2] Commit only — Create local commit, don't push         │
│  [3] View diff — Show full diff                            │
│  [4] Discard — Revert all changes                          │
└─────────────────────────────────────────────────────────────┘
```

### Step 3.9 — Commit (if approved)

```bash
git add -A
git commit -m "$(cat <<'EOF'
fix: address PR bot review feedback

Fixes:
- {description 1}
- {description 2}

False positives explained:
- {explanation 1}

Reviewed by: {bot names}

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

If push approved:
```bash
git push
```

Record commit SHA for replies.

---

## Phase 4: Reply & Complete

### Step 4.1 — Determine Reply Content

Based on commit status:
- **Committed:** `Fixed in commit {sha}: {description}`
- **Not committed:** `Will be addressed in upcoming commit: {description}`

### Step 4.2 — CRITICAL: Issue Comments vs PR Review Comments

GitHub has TWO comment systems with DIFFERENT reply methods!

| Type | Endpoint | Has `path`? | Threading | Reply Method |
|------|----------|-------------|-----------|--------------|
| PR Review | `/pulls/{pr}/comments` | Yes | `in_reply_to` | Thread reply |
| Issue | `/issues/{pr}/comments` | No | None | **@mention in body** |

**For Issue Comments (no threading!):**
```bash
# MUST use @mention since no thread support!
gh api repos/$OWNER/$REPO/issues/$PR/comments \
  -X POST \
  -f body="@greptile-apps Fixed in commit $COMMIT_SHA. Thanks!"
```

**For PR Review Comments:**
```bash
gh api repos/$OWNER/$REPO/pulls/$PR/comments \
  -X POST \
  -f body="Fixed in commit $COMMIT_SHA" \
  -F in_reply_to=$COMMENT_ID
```

### Step 4.3 — Send Replies

For each processed comment, send appropriate reply:

**CodeRabbit:**
```bash
gh api repos/{owner}/{repo}/pulls/{pr}/comments \
  -f body="{reply}" -F in_reply_to={id}
```

**Greptile / Codex:**
```bash
# Reaction first
gh api repos/{owner}/{repo}/pulls/comments/{id}/reactions \
  -f content='{+1 or -1}'

# Then reply
gh api repos/{owner}/{repo}/pulls/{pr}/comments \
  -f body="{reply}" -F in_reply_to={id}
```

**Copilot:**
- NO REPLY (fix silently)

### Step 4.4 — Update State

Mark comments as REPLIED in state file.

### Step 4.5 — Post Greptile Consolidated Summary

If Greptile comments were processed, post ONE summary comment (helps Greptile ML learn):

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT}/skills/pr-patrol/scripts"
STATE_FILE=".claude/bot-reviews/PR-${PR}.md"
CYCLE=$(grep "^current_cycle:" "$STATE_FILE" | cut -d' ' -f2)

# Generate and post summary
"$SCRIPTS/build_greptile_summary.sh" "$STATE_FILE" "$CYCLE" > /tmp/greptile_summary.md
gh api repos/$OWNER/$REPO/issues/$PR/comments -X POST -f body="$(cat /tmp/greptile_summary.md)"
```

### Step 4.6 — Cycle Summary

```
╔══════════════════════════════════════════════════════════════╗
║  🤖 Review Bots — PR #{number} — Cycle {n} Complete ✓        ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  ✓ {fixed} issues fixed                                     ║
║  ✓ {fp} false positives explained                           ║
║  ✓ Replies sent to {replied} comments                       ║
║  ○ {pending} threads awaiting bot response                  ║
║                                                              ║
║  Commit: {sha or "not committed"}                           ║
║  Pushed: {yes/no}                                            ║
║                                                              ║
║  State saved: .claude/bot-reviews/PR-{number}.md            ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝

┌─────────────────────────────────────────────────────────────┐
│  [1] New cycle — Re-fetch and check bot responses          │
│  [2] Wait — Bots need 1-2 min to respond                   │
│  [3] Done — PR ready for merge                             │
└─────────────────────────────────────────────────────────────┘
```

If user chooses [1], restart from Phase 1 with incremented cycle.

---

## Critical Rules

1. **ALWAYS use --paginate** — Default returns only 30 comments
2. **Fetch BOTH endpoints** — Review comments AND issue comments
3. **Extract embedded CodeRabbit comments** — Use `parse_coderabbit_embedded.sh` (nitpicks, duplicates, outside-diff)
4. **Issue vs PR review comments** — Different reply methods! Issue comments need @mention (no threading)
5. **Batch validation** — One table, one approval, not per-comment
6. **Track state** — Persist to `.claude/bot-reviews/` in current project
7. **Read AGENTS.md** — Check for project-specific conventions
8. **Correct bot response** — CodeRabbit ≠ Greptile ≠ Copilot (Copilot = SILENT fix only!)
9. **NEVER commit without approval**
10. **NEVER push without asking**
11. **Update state file** — After every major action
12. **Use helper scripts** — `${CLAUDE_PLUGIN_ROOT}/skills/pr-patrol/scripts/` has utilities
13. **TRUST SCRIPT OUTPUT** — When `check_new_comments.sh` returns data, DO NOT make verification queries!

---

## State File Location

**Project-local:** `.claude/bot-reviews/PR-{number}.md`

State is kept with the project because PRs are project-specific. Create the directory if it doesn't exist.
