# PR Patrol

Handles PR review bot comments through a structured workflow. Collects comments from CodeRabbit, Greptile, Copilot, Codex, and Sentry — validates them, applies fixes, and posts appropriate replies.

## How It Works

```
/pr-patrol 123
```

1. **Collect** — Fetches all bot comments from the PR
2. **Validate** — Checks each comment against the actual code (parallel processing)
3. **Fix** — Designs and applies fixes for valid issues
4. **Commit** — Creates a commit with all changes
5. **Reply** — Posts replies to each bot in their expected format
6. **Push** — Pushes changes and checks for new comments

Each step requires your approval before proceeding.

## Supported Bots

| Bot | How It's Handled |
|-----|------------------|
| CodeRabbit | Reply to resolve |
| Greptile | React 👍 then reply |
| Copilot | Silent fix (no reply needed) |
| Codex | React then reply |
| Sentry | React then reply |

Deployment bots (Vercel, Dependabot, Renovate) are automatically ignored.

## Prerequisites

- GitHub CLI (`gh`) — authenticated with your account
- jq 1.6+
- GNU coreutils — built-in on Linux, `brew install coreutils` on macOS

## Installation

```bash
/plugin marketplace add SmartOzzehir/smart-plugins
/plugin install pr-patrol
```

## State Tracking

Progress is saved to `.claude/bot-reviews/PR-{number}.md` so you can resume interrupted sessions.

## License

MIT
