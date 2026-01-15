# Gate 6: Push & Complete

**Previous status:** `replies_sent`
**Status to set after completion:** `pushed`

---

## ⚠️ CRITICAL RULES FOR THIS PHASE

1. **TRUST SCRIPT OUTPUT** - When `check_new_comments.sh` returns data, DO NOT make verification queries!
2. **ASK, DON'T ASSUME** - Always use AskUserQuestion before push and before starting new cycle
3. **READ GATE 1 NEXT** - After starting a new cycle, read `gate-1-collect.md`, NOT this file again

---

## What This Phase Does

1. Push to remote (on user approval)
2. Update state file with push info
3. Show cycle summary
4. Check for new bot comments (Cycle 2 trigger)

---

## MANDATORY AskUserQuestion (Push)

```
Header: "Push"
Question: "Local changes ready. Push to remote?"
Options:
├── "Yes, push now"
├── "Not yet (push later)"
├── "Keep local only"
```

---

## Step 1: Push to Remote

**Only after explicit user approval!**

```bash
# Check remote status first
git fetch origin
git status -sb

# Push
git push origin HEAD

# Verify
git log origin/HEAD -1 --oneline
```

---

## Edge Cases (Pre-Push)

| Case | Detection | Action |
|------|-----------|--------|
| Remote ahead | `git fetch` shows behind | Offer pull/rebase |
| Force push needed | Non-fast-forward | **BLOCK**: Never force push |
| Protected branch | Push rejected | Info only |

---

## Step 2: Update State File

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT}/skills/pr-patrol/scripts"
STATE_FILE=".claude/bot-reviews/PR-${PR}.md"

# Update push timestamp (use "now" keyword for cross-platform compatibility)
"$SCRIPTS/update_state.sh" "$STATE_FILE" last_push_at "now"

# Update push commit SHA
"$SCRIPTS/update_state.sh" "$STATE_FILE" last_push_commit "$(git rev-parse HEAD)"

# Update billboard - workflow complete (no next gate)
"$SCRIPTS/update_billboard.sh" "$STATE_FILE" "pushed" "✓" "Cycle complete - check for new comments or done"
```

---

## Step 3: Show Cycle Summary

Present summary to user:

```
## Cycle {N} Complete!

### Summary
- **Fixed:** {fixed_count} real issues
- **False Positives:** {false_count} marked
- **Replies Sent:** {reply_count}
- **Commit:** {commit_sha}
- **Pushed:** {push_time}

### Issues Fixed
1. {file1}: {summary1}
2. {file2}: {summary2}

### False Positives Dismissed
1. {file3}: {summary3} (reason)
```

---

## MANDATORY AskUserQuestion (Complete)

```
Header: "Complete"
Question: "Cycle complete! {fixed} issues fixed, {false} false positives marked. What's next?"
Options:
├── "Check for new bot responses (start Cycle 2)"
├── "Done for now"
├── "View full cycle report"
```

---

## Step 4: Check for New Comments

If user selects "Check for new bot responses":

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT}/skills/pr-patrol/scripts"
STATE=".claude/bot-reviews/PR-${PR}.md"

# Get timestamp from state file
LAST_PUSH=$(grep "^last_push_at:" "$STATE" | cut -d' ' -f2)

# Run the script ONCE
"$SCRIPTS/check_new_comments.sh" "$OWNER" "$REPO" "$PR" "$LAST_PUSH"
```

---

## ⚠️ CRITICAL: Trust The Script Output!

**DO:**
- ✅ Run `check_new_comments.sh` ONCE
- ✅ Read the JSON output (count, by_bot, new_comments)
- ✅ Immediately present results to user via AskUserQuestion
- ✅ Proceed based on user's choice

**DO NOT:**
- ❌ Make additional API calls to "verify" the comments
- ❌ Query GitHub again to "double-check" comment IDs
- ❌ Try to fetch individual comments to "confirm" they exist
- ❌ Run any validation queries after seeing the script output

**The script already:**
1. Fetches ALL comments from both PR and issue endpoints
2. Filters by bot type
3. Filters by timestamp (UTC normalized)
4. Returns accurate count and details

**If script says `"count": 3` → There ARE 3 new comments. Period. Move on!**

---

## Script Output Format (Enhanced)

The `check_new_comments.sh` script now categorizes bot responses:

```json
{
  "since": "2026-01-13T10:18:56Z",
  "summary": {
    "total": 5,
    "new_issues": 2,       // New bot comments requiring action
    "resolved": 2,         // Bot accepted our fix (good!)
    "rejected": 1,         // Bot rejected our fix (re-fix needed!)
    "acknowledgments": 0,  // Bot said "thanks" (skip)
    "copilot": 0           // Copilot comments (silent fix)
  },
  "new_issues": [...],     // Need validation + fix
  "resolved": [...],       // Just log, no action
  "rejected": [...],       // Need re-fix!
  "acknowledgments": [...], // Skip these
  "copilot": [...],        // Silent fix only
  "by_bot": [...],
  "needs_review": true,
  "has_rejections": true,  // Important flag!
  "actionable_count": 3    // new_issues + rejected
}
```

### Category Meanings

| Category | What It Means | Action |
|----------|---------------|--------|
| `new_issues` | New bot comment (not a reply) | Validate → Fix |
| `resolved` | Bot says "thanks", "LGTM", has `<!-- review_comment_addressed -->` | Log only |
| `rejected` | Bot says "still see issue", "not fixed" | Re-fix! |
| `acknowledgments` | Short "thanks" reply from bot | Skip |
| `copilot` | Copilot comment | Silent fix |

---

## MANDATORY AskUserQuestion (New Comments)

**If `count > 0`:**
```
Header: "New Comments"
Question: "Found {count} new bot comments since push ({by_bot summary}). Start Cycle {N+1}?"
Options:
├── "Yes, start Cycle {N+1}"
├── "Show comment details first"
├── "Done for now"
```

**If `count == 0`:**
```
Header: "Complete"
Question: "No new bot comments found. Workflow complete!"
Options:
├── "Done"
├── "Check again later"
```

---

## Starting Next Cycle (EXACT STEPS)

**When user selects "Yes, start Cycle N+1":**

### Step A: Update State File
```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT}/skills/pr-patrol/scripts"
STATE_FILE=".claude/bot-reviews/PR-${PR}.md"

# Increment cycle number
CURRENT=$(grep "^current_cycle:" "$STATE_FILE" | cut -d' ' -f2)
NEXT=$((CURRENT + 1))
"$SCRIPTS/update_state.sh" "$STATE_FILE" current_cycle "$NEXT"

# Reset billboard for new cycle - back to Gate 1
"$SCRIPTS/update_billboard.sh" "$STATE_FILE" "initialized" "1" "Collect new bot comments for Cycle $NEXT"
```

### Step B: Read Gate 1 Instructions
```
READ: phases/gate-1-collect.md
```

### Step C: Continue Workflow
Follow Gate 1 instructions to collect the new comments. **DO NOT re-read gate-6-push.md!**

---

## Flow Diagram (After Finding New Comments)

```
check_new_comments.sh returns count: 3
            │
            ▼
   ┌─ TRUST THE OUTPUT ─┐
   │  DO NOT verify!    │
   └────────────────────┘
            │
            ▼
   AskUserQuestion: "Start Cycle N+1?"
            │
     ┌──────┴──────┐
     ▼             ▼
   "Yes"        "Done"
     │             │
     ▼             ▼
  Update        END
  state file
     │
     ▼
  READ: gate-1-collect.md
     │
     ▼
  Continue from Gate 1
```

---

## Bot Response Patterns

After push, bots may respond to your replies:

### Resolved (Good)
- **CodeRabbit:** `<!-- <review_comment_addressed> -->`, "excellent!", "✅"
- **Greptile:** 👍 reaction on your reply, "looks good"
- **Sentry:** "fixed", "resolved"
- **Copilot:** Comment disappears in next review

### Rejected (Needs Re-fix)
- **CodeRabbit:** "cannot locate", "could you confirm", question marks
- **Greptile:** 👎 reaction, "issue remains"
- **Sentry:** "not fixed", "issue persists"
- **Copilot:** Same comment appears again

**If rejection detected:** Mark for re-fix in Cycle 2.

---

## Final State File Structure

After cycle completion:

```yaml
---
pr_number: 32
branch: feature/my-feature
owner: your-org
repo: my-project
created: 2026-01-13T09:00:00Z
last_updated: 2026-01-13T14:30:00Z
current_cycle: 1
status: pushed
last_push_at: 2026-01-13T14:25:00Z
last_push_commit: ff83040abc123
replied_comment_ids: [2685349486, 2685349490, 2685771202]
---
```

---

## Workflow Complete!

If no new comments or user selects "Done":

1. State file preserved for future reference
2. Cycle summary displayed
3. User can run `/pr-patrol` again to check later

---

## Error Recovery

| Scenario | Recovery |
|----------|----------|
| Push failed | Show error, retry options |
| Network error | Retry with backoff |
| Auth error | Re-authenticate via `gh auth` |
| Protected branch | Inform user, suggest PR |
