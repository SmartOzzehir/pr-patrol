---
description: "Interview user to gather detailed requirements for a spec document or feature idea"
argument-hint: "[file-path-or-idea]"
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, TodoWrite
---

# Spec Interview Command

Conducts a structured requirements interview through 12 phases.

## Usage

```
/spec-interview "Add dark mode to the app"
/spec-interview docs/feature-request.md
/spec-interview "Nueva función de exportación"
```

## Execution Flow

1. **Phase 0**: Check for existing session, create state file
2. **Phase 0.5**: Calibrate tech level, confirm understanding
3. **Phases 1-8**: Interview stages (problem, users, functional, UI, edge cases, NFR, technical, priority)
4. **Phase 9**: Validate against checklist
5. **Phase 10**: Write spec document

## Key Features

- **Progress tracking** - TodoWrite shows current phase
- **State persistence** - Resume interrupted interviews from `.claude/spec-interviews/`
- **Adaptive questioning** - Adjusts depth based on user's tech level
- **File analysis** - If given a file, skips already-covered sections
- **Multi-language** - Auto-detects and conducts interview in user's language

## START

Read `phases/phase-0-init.md` and begin the interview.
