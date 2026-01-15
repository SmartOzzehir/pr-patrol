# Smart Plugins

Claude Code plugins for common development workflows.

## Available Plugins

### pr-patrol

Handles PR review bot comments (CodeRabbit, Greptile, Copilot, Codex, Sentry) through a structured 7-gate workflow. Validates comments, applies fixes, and posts replies automatically.

```bash
/pr-patrol 123    # Process PR #123
```

### spec-interview

Conducts requirements interviews to generate PRD documents. Analyzes existing files, asks targeted questions, and validates against best practices.

```bash
/spec-interview "Add user export feature"
/spec-interview docs/feature-spec.md
```

## Installation

```bash
/plugin marketplace add SmartOzzehir/smart-plugins
/plugin install pr-patrol
/plugin install spec-interview
```

## License

MIT
