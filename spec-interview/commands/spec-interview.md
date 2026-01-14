---
description: "Interview user to gather detailed requirements for a spec document or feature idea"
argument-hint: "[file-path-or-idea] [ENG|TUR]"
allowed-tools: Read, Write, Edit, AskUserQuestion, Glob, Grep, Skill
---

# Spec Interview Command

Load and execute the spec-interview skill with the provided arguments.

## Usage

```
/spec-interview docs/phases/phase-10.md
/spec-interview "Add export button to dashboard"
/spec-interview docs/phases/phase-10.md TUR
```

## Execution

Invoke the spec-interview skill to conduct a structured requirements interview.

**Arguments passed to skill:**
- `$1` = File path to existing spec OR idea description in quotes
- `$2` = Language: `ENG` (default) or `TUR` for Turkish

The skill will automatically:
1. Detect input mode (FILE or IDEA based on argument format)
2. Analyze existing document or parse the idea
3. Conduct 5-stage structured interview using AskUserQuestion
4. Write/update the spec document with gathered requirements
