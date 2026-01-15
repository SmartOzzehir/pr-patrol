#!/usr/bin/env bash
#
# block-force-push.sh - PreToolUse hook to block git push --force
#
# Claude Code Hook Protocol:
#   - Input: JSON via stdin with tool_input.command
#   - Exit 0: Allow (optionally with JSON on stdout for advanced control)
#   - Exit 2: Block (stderr message fed back to Claude)
#
# This hook ALWAYS blocks force push to protect repository history.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

if echo "$COMMAND" | grep -qE 'git\s+push.*(-f\b|--force\b|--force-with-lease\b)'; then
  echo "BLOCKED: Force push is prohibited by pr-patrol safety hook." >&2
  echo "Use regular 'git push' instead. If you need to force push, do it manually outside Claude Code." >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  echo "BLOCKED: Hard reset is prohibited by pr-patrol safety hook." >&2
  echo "Use 'git checkout' or 'git restore' for specific files instead." >&2
  exit 2
fi

exit 0
