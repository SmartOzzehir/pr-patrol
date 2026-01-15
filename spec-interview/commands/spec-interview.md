---
description: "Interview user to gather detailed requirements for a spec document or feature idea"
argument-hint: "[file-path-or-idea]"
allowed-tools: Read, Write, Edit, AskUserQuestion, Glob, Grep, Bash, TodoWrite
---

# Spec Interview Command

Load and execute the spec-interview skill with the provided arguments.

## Usage

```
/spec-interview docs/phases/phase-10.md
/spec-interview "Add export button to dashboard"
/spec-interview "Nueva función de exportación"
```

## Execution

Invoke the spec-interview skill to conduct a structured requirements interview.

**Arguments passed to skill:**
- `$1` = File path to existing spec OR idea description in quotes

**Language:** Auto-detected from input text. Supports 12+ languages.

## Workflow

1. **Check for existing session** at `.claude/spec-interviews/`
2. **Calibrate tech level** (MANDATORY first question)
3. **Setup progress tracking** via TodoWrite (8 stages visible)
4. **Interview 8 stages** - saving answers to state file after each
5. **Validate** against 14-category checklist
6. **Write spec** document

## State Management

Interview progress is saved to `.claude/spec-interviews/{spec_id}.md`:
- Survives session interruptions
- Can be resumed later
- Tracks all collected answers

## Scripts

- `scripts/init_state.sh` - Create new interview state file
- `scripts/update_state.sh` - Update state fields
