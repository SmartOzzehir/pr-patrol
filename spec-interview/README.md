# Spec Interview

Conducts structured requirements interviews to generate comprehensive PRD documents. Asks targeted questions until there's complete clarity, then validates against best practices.

## How It Works

```bash
/spec-interview "Add dark mode to the app"     # Start from an idea
/spec-interview docs/feature-spec.md           # Refine existing spec
```

**From an idea:** Interviews you through 8 stages (problem, users, features, UI, edge cases, etc.)

**From a file:** Analyzes what's already defined, skips clear sections, asks only about gaps.

## Key Features

- **Smart Analysis** — Reads existing files and skips sections that are already well-defined
- **Adaptive Questions** — Adjusts technical depth based on your background
- **Validation Checklist** — Checks 14 categories of best practices before writing
- **Complexity Detection** — Warns if scope is too large and suggests splitting into phases
- **Multi-Language** — Auto-detects from your input (supports 12+ languages)

## Interview Stages

0. **Calibration** — Your technical level, confirm understanding
1. **Problem & Vision** — What problem does this solve? How do we measure success?
2. **Users** — Who uses this? What are their needs?
3. **Functional** — What actions? What data? What logic?
4. **UI/UX** — Where does it live? What states does it have?
5. **Edge Cases** — What could go wrong? How do we handle it?
6. **Non-Functional** — Performance, security, accessibility
7. **Technical** — Architecture, APIs, storage
8. **Prioritization** — MVP scope, phasing

## Output

Generates a 14-section PRD covering problem statement, user personas, requirements, UI specs, edge cases, technical notes, and more.

## Installation

```bash
/plugin marketplace add SmartOzzehir/smart-plugins
/plugin install spec-interview
```

## License

MIT
