# Gate 2: Validation Complete

**Previous status:** `collected`
**Status to set after completion:** `validated`

---

## What This Phase Does

1. Validate each bot comment to determine REAL vs FALSE POSITIVE
2. Use `bot-comment-validator` agent (NOT manual validation!)
3. Collect verdicts and update state file

---

## IMPORTANT: Include Embedded Comments

CodeRabbit embeds some comments in the walkthrough (issue comment) due to GitHub API limitations:

| Section | Emoji | What It Contains |
|---------|-------|------------------|
| Duplicate comments | `♻️` | Issues from previous reviews that still apply |
| Additional comments | `🔇` | Comments outside the diff range |
| Nitpick comments | `🧹` | Minor style suggestions (sometimes embedded) |

**These MUST be validated too!** Use the extracted embedded comments from Gate 1.

If embedded comments were extracted to `/tmp/embedded_comments.json`, include them:

```bash
# Merge inline + embedded for validation
jq -s '.[0].comments + .[1].comments' /tmp/all_comments.json /tmp/embedded_comments.json
```

---

## CRITICAL: Use Task Tool for Validation

**DO NOT manually read files and validate comments.**

Launch `bot-comment-validator` agents in parallel:

```xml
<Task>
  <subagent_type>bot-comment-validator</subagent_type>
  <description>Validate comment #123456</description>
  <prompt>
Validate this PR bot comment against the actual code:

Comment ID: 123456
Bot: coderabbitai[bot]
File: src/components/customers/customer-list.tsx
Line: 246
Comment: "getRegionLabel is called with customer.region but expects UUID..."

Read the file and determine:
- Is this a REAL issue or FALSE POSITIVE?
- Confidence level (high/medium/low)
- Reasoning for your verdict
- Suggested fix if real issue

Return JSON:
{
  "comment_id": 123456,
  "verdict": "VALID" | "FALSE_POSITIVE" | "NEEDS_CLARIFICATION",
  "confidence": 0.85,
  "reasoning": "...",
  "suggested_fix": "..." (if VALID)
}
  </prompt>
</Task>
```

### Batch Validation (Recommended)

For efficiency, group comments by file and validate in batches:

```
File A (3 comments) → Single agent call with all 3
File B (2 comments) → Single agent call with all 2
```

### Parallel Validation

Launch multiple Task calls in a single message for parallelism:

```xml
<!-- All in one message for parallel execution -->
<Task subagent_type="bot-comment-validator" description="Validate comment #111">...</Task>
<Task subagent_type="bot-comment-validator" description="Validate comment #222">...</Task>
<Task subagent_type="bot-comment-validator" description="Validate comment #333">...</Task>
```

---

## Validation Output Format

Each agent returns:

```json
{
  "comment_id": 123456,
  "verdict": "VALID",
  "confidence": 0.85,
  "reasoning": "The function indeed expects UUID but receives text code...",
  "suggested_fix": "Use customer.regionId ?? customer.region"
}
```

### Verdict Types

| Verdict | Meaning | Action |
|---------|---------|--------|
| `VALID` | Bot correctly identified a problem | Add to fix queue |
| `FALSE_POSITIVE` | Bot was wrong | Mark for dismissal reply |
| `NEEDS_CLARIFICATION` | Agent not confident | Escalate to user |

---

## MANDATORY AskUserQuestion

After all validations complete:

```
Header: "Validation"
Question: "Validation complete: {real} real issues, {false} false positives. How to proceed?"
Options:
├── "Fix all real issues ({real})" [Recommended]
├── "Fix critical + high only ({critical_high})"
├── "Select specific issues to fix"
├── "Review validation details"
├── "Skip fixes, proceed to replies"
├── "Stop here (save state)"
```

---

## Edge Cases

| Case | Detection | Action |
|------|-----------|--------|
| All false positives | No `VALID` verdicts | Skip to Gate 5 (replies) |
| Validator timeout | No response in 60s | Retry/Skip/Manual |
| Validator uncertain | `NEEDS_CLARIFICATION` returned | Escalate to user with AskUserQuestion |

---

## State File Update

Update the validation results:

```markdown
### VALID - Real Issues ({count})
| ID | Bot | File | Severity | Summary | Fix Applied |
|----|-----|------|----------|---------|-------------|
| 123 | coderabbitai[bot] | customer-list.tsx | HIGH | UUID vs text mismatch | Pending |

### FALSE_POSITIVE ({count})
| ID | Bot | File | Summary | Reason |
|----|-----|------|---------|--------|
| 456 | Copilot | config.ts | Type enum suggestion | Code is correct |
```

Add Validation Cache:

```markdown
## Validation Cache
```json
{
  "validated_at": "2026-01-13T10:30:00Z",
  "fixed_issues": [{"id": 123, "severity": "high", "file": "..."}],
  "false_positives": [456, 789]
}
```

Update status and billboard:

```bash
SCRIPTS="${CLAUDE_PLUGIN_ROOT}/skills/pr-patrol/scripts"
STATE_FILE=".claude/bot-reviews/PR-${PR}.md"

# If real issues found → Gate 3
# If all false positives → Gate 5
if [ "$REAL_ISSUES_COUNT" -gt 0 ]; then
  "$SCRIPTS/update_billboard.sh" "$STATE_FILE" "validated" "3" "Design and apply fixes for real issues"
else
  "$SCRIPTS/update_billboard.sh" "$STATE_FILE" "validated" "5" "Post replies to bot comments"
fi
```

---

## After This Phase

1. ✅ Billboard updated: `status: validated`
2. **IMMEDIATELY** read the next gate file:
   - Real issues found → `phases/gate-3-fix.md`
   - All false positives → `phases/gate-5-reply.md`
3. Do NOT stop or wait - continue to next gate!
