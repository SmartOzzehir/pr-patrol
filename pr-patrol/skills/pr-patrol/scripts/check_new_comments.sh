#!/usr/bin/env bash
# check_new_comments.sh - Check for new bot comments since last push
# Usage: ./check_new_comments.sh <owner> <repo> <pr> [since_timestamp]
#
# If since_timestamp not provided, uses last push time from git
#
# Returns JSON with:
#   - new_comments: Bot comments created after timestamp
#   - summary: Count by bot
#   - needs_review: true if any new comments found

set -euo pipefail

# Platform detection - need GNU date for -d flag
if date --version &>/dev/null; then
  DATE_CMD="date"
elif command -v gdate &>/dev/null; then
  DATE_CMD="gdate"
else
  echo "ERROR: GNU date required. On macOS: brew install coreutils" >&2
  echo "Windows users: Use WSL" >&2
  exit 1
fi

OWNER="${1:?Usage: $0 <owner> <repo> <pr> [since_timestamp]}"
REPO="${2:?Usage: $0 <owner> <repo> <pr> [since_timestamp]}"
PR="${3:?Usage: $0 <owner> <repo> <pr> [since_timestamp]}"
SINCE="${4:-}"

# Get script directory for jq files
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If no timestamp provided, get from last push
if [[ -z "$SINCE" ]]; then
  SINCE=$(git log -1 --format=%cI "origin/$(git rev-parse --abbrev-ref HEAD)" 2>/dev/null) || {
    echo "Warning: Could not get last push time, using epoch" >&2
    SINCE="1970-01-01T00:00:00Z"
  }
fi

# CRITICAL: Normalize timestamp to UTC for consistent comparison
# GitHub API returns timestamps in UTC (Z suffix)
# But local timestamps may have timezone offset (+03:00)
# String comparison fails: "11:30Z" vs "14:22+03:00" → 11 < 14 (WRONG!)
DATE_STDERR=$(mktemp)
if SINCE_NORMALIZED=$($DATE_CMD -u -d "$SINCE" +"%Y-%m-%dT%H:%M:%SZ" 2>"$DATE_STDERR"); then
  SINCE="$SINCE_NORMALIZED"
else
  echo "Warning: Could not normalize timestamp '$SINCE' ($(cat "$DATE_STDERR")), using as-is" >&2
fi
rm -f "$DATE_STDERR"

# Temporary file for error capture
STDERR_FILE=$(mktemp)
trap 'rm -f "$STDERR_FILE"' EXIT

# Fetch PR review comments with error handling
if ! PR_COMMENTS=$(gh api "repos/$OWNER/$REPO/pulls/$PR/comments" --paginate 2>"$STDERR_FILE"); then
  echo "Error: Failed to fetch PR comments: $(cat "$STDERR_FILE")" >&2
  exit 1
fi

# Fetch issue comments with error handling
if ! ISSUE_COMMENTS=$(gh api "repos/$OWNER/$REPO/issues/$PR/comments" --paginate 2>"$STDERR_FILE"); then
  echo "Error: Failed to fetch issue comments: $(cat "$STDERR_FILE")" >&2
  exit 1
fi

# Combine and process
{
  echo "$PR_COMMENTS"
  echo "$ISSUE_COMMENTS"
} | jq -s -L "$SCRIPT_DIR" --arg since "$SINCE" '
include "bot-detection";

# Detection functions for categorization
def is_resolved_response:
  . and (
    test("<!-- <review_comment_addressed> -->") or
    test("LGTM|excellent|thank you|confirmed|addressed|working as designed|looks good"; "i") or
    test("thanks for (the )?(fix|update|change)|acknowledged|got it"; "i") or
    test("\\u2705")
  );

def is_rejected_response:
  . and (
    test("cannot locate|could you confirm|I do not see"; "i") or
    test("(still|however|but).*(present|exists|remains|see|find|issue)"; "i") or
    test("not (been )?(fixed|addressed|resolved)"; "i") or
    test("issue (still )?(remains|persists)"; "i") or
    (test("\\?$") and test("Could you|Can you|Would you|Have you|Did you"; "i"))
  );

def is_acknowledgment:
  . and (
    test("^(thanks|thank you|got it|acknowledged|understood|okay|ok)!?$"; "i") or
    test("^thanks for (the )?(fix|update|change|feedback)"; "i") or
    (length < 50 and test("thanks|good|great|perfect"; "i"))
  );

add |

# Get all comments with metadata
[.[] |
  select(.user.login | is_ignored_bot | not) |
  select(.user.type == "Bot" or (.user.login | is_review_bot)) |
  select(.created_at > $since) |
  {
    id,
    bot: .user.login,
    path: (.path // "issue-level"),
    line,
    created_at,
    in_reply_to_id,
    body: (.body | gsub("[\\u0000-\\u001f]"; "")),
    body_preview: (.body | gsub("[\\u0000-\\u001f]"; "") | .[0:150])
  }
] |

# Categorize comments
. as $all |
{
  since: $since,
  
  # New bot issues (not replies, need attention)
  new_issues: [$all[] | select(.in_reply_to_id == null) | select(.bot != "Copilot") | del(.body)],
  
  # Bot responses to our replies that RESOLVED the issue
  resolved: [$all[] | select(.in_reply_to_id) | select(.body | is_resolved_response) | del(.body)],
  
  # Bot responses that REJECTED our fix
  rejected: [$all[] | select(.in_reply_to_id) | select(.body | is_rejected_response) | del(.body)],
  
  # Simple acknowledgments (skip these)
  acknowledgments: [$all[] | select(.in_reply_to_id) | select(.body | is_acknowledgment) | del(.body)],
  
  # Copilot comments (silent fix, no action needed)
  copilot: [$all[] | select(.bot == "Copilot") | select(.in_reply_to_id == null) | del(.body)],
  
  # Summary counts
  summary: {
    total: ($all | length),
    new_issues: ([$all[] | select(.in_reply_to_id == null) | select(.bot != "Copilot")] | length),
    resolved: ([$all[] | select(.in_reply_to_id) | select(.body | is_resolved_response)] | length),
    rejected: ([$all[] | select(.in_reply_to_id) | select(.body | is_rejected_response)] | length),
    acknowledgments: ([$all[] | select(.in_reply_to_id) | select(.body | is_acknowledgment)] | length),
    copilot: ([$all[] | select(.bot == "Copilot") | select(.in_reply_to_id == null)] | length)
  },
  
  by_bot: ($all | group_by(.bot) | map({bot: .[0].bot, count: length})),
  
  # Decision flags
  needs_review: (([$all[] | select(.in_reply_to_id == null) | select(.bot != "Copilot")] | length) > 0),
  has_rejections: (([$all[] | select(.in_reply_to_id) | select(.body | is_rejected_response)] | length) > 0),
  
  # Actionable = new_issues + rejections (need work)
  actionable_count: (
    ([$all[] | select(.in_reply_to_id == null) | select(.bot != "Copilot")] | length) +
    ([$all[] | select(.in_reply_to_id) | select(.body | is_rejected_response)] | length)
  )
}
'
