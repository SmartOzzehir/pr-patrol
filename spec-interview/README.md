# Spec Interview

A Claude Code plugin for conducting structured requirements interviews to create specification documents.

## Features

- **Two Modes** - Enhance existing spec files or create new ones from ideas
- **5-Stage Methodology** - Context, Functional, UI/UX, Edge Cases, Technical
- **Non-Technical Friendly** - Explains concepts in plain language before asking technical questions
- **Multi-Language** - English and Turkish support

## Installation

```bash
# Add the marketplace (if not already added)
/plugin marketplace add SmartOzzehir/smart-plugins

# Install the plugin
/plugin install spec-interview
```

## Usage

```bash
# Enhance existing spec document
/spec-interview docs/phases/phase-10.md

# Create new spec from an idea
/spec-interview "Add export button to dashboard"

# Use Turkish language for interview
/spec-interview docs/phases/phase-10.md TUR
```

## Interview Stages

| Stage | Focus | Example Questions |
|-------|-------|-------------------|
| 1. Context | Who & Why | Who are the users? What problem does this solve? |
| 2. Functional | What | Core actions, data requirements, success criteria |
| 3. UI/UX | How it looks | Layout, loading states, error feedback |
| 4. Edge Cases | What could go wrong | Permissions, missing data, concurrent edits |
| 5. Technical | Implementation | Caching, real-time updates, validation timing |

## Output Format

The skill generates structured spec documents with:

- Overview and user stories
- Functional requirements with checkboxes
- Data requirements with types and validation
- UI/UX specifications with state descriptions
- Edge case handling strategies
- Technical notes and open questions
- Subphase breakdown (for complex features)

## Best Practices

- **Be specific** - Concrete examples help clarify requirements
- **Think about edge cases** - The skill will prompt you, but volunteer scenarios
- **Reference existing features** - "Like the export button on the reports page"
- **Don't worry about technical terms** - The skill explains concepts before asking

## License

MIT
