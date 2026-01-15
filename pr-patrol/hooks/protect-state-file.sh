#!/usr/bin/env bash
#
# protect-state-file.sh - PreToolUse hook to protect pr-patrol state files
#
# Prevents accidental deletion of .claude/bot-reviews/ state files
# which track pr-patrol workflow progress.
#
# Claude Code Hook Protocol:
#   - Input: JSON via stdin with tool_input
#   - Exit 0: Allow
#   - Exit 2: Block (stderr message fed back to Claude)

set -euo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || echo "")

case "$TOOL_NAME" in
  Bash)
    COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")
    
    if echo "$COMMAND" | grep -qE 'rm\s+(-rf?|--recursive)?\s*.*\.claude/bot-reviews'; then
      echo "BLOCKED: Cannot delete pr-patrol state files (.claude/bot-reviews/)." >&2
      echo "These files track workflow progress. Delete manually if absolutely necessary." >&2
      exit 2
    fi
    ;;
    
  Write)
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || echo "")
    CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty' 2>/dev/null || echo "")
    
    if [[ "$FILE_PATH" == *".claude/bot-reviews/"* ]] && [[ -z "$CONTENT" ]]; then
      echo "BLOCKED: Cannot write empty content to pr-patrol state file." >&2
      exit 2
    fi
    ;;
esac

exit 0
