#!/bin/bash
# check_reply_status.sh - Check which bot comments have been replied to
# Usage: ./check_reply_status.sh <owner> <repo> <pr>
#
# Returns JSON with:
#   - replied: Comments that have user replies
#   - pending: Comments waiting for user reply (excluding Copilot)
#   - copilot_silent: Copilot comments (no reply needed)

set -e

OWNER="${1:?Usage: $0 <owner> <repo> <pr>}"
REPO="${2:?Usage: $0 <owner> <repo> <pr>}"
PR="${3:?Usage: $0 <owner> <repo> <pr>}"

# Get script directory for jq library path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Sequential fetch from both endpoints
# IMPORTANT: Do NOT use parallel { cmd & cmd & wait } pattern here!
# Background processes can interleave stdout bytes, corrupting JSON.
{
  gh api "repos/$OWNER/$REPO/pulls/$PR/comments" --paginate
  gh api "repos/$OWNER/$REPO/issues/$PR/comments" --paginate
} 2>/dev/null | jq -s -L "$SCRIPT_DIR" '
include "bot-detection";

add |

# Separate into categories
[.[] | select(.user.login | is_ignored_bot | not)] |
[.[] | select(.user.type == "Bot" or (.user.login | is_review_bot)) | select(.in_reply_to_id == null)] as $bot_comments |
[.[] | select(.user.type == "Bot" or (.user.login | is_review_bot) | not) | select(.in_reply_to_id)] as $user_replies |

# Build replied set as object for O(1) lookup
($user_replies | map({key: (.in_reply_to_id | tostring), value: true}) | add // {}) as $replied_set |

# Categorize bot comments using O(1) lookup
{
  replied: [$bot_comments[] | select($replied_set[.id | tostring]) | {id, bot: .user.login, path: (.path // "issue-level")}],
  pending: [$bot_comments[] | select(.user.login != "Copilot") | select($replied_set[.id | tostring] | not) | {id, bot: .user.login, path: (.path // "issue-level")}],
  copilot_silent: [$bot_comments[] | select(.user.login == "Copilot") | {id, path: (.path // "issue-level")}],
  summary: {
    total_bot_comments: ($bot_comments | length),
    replied_count: ([$bot_comments[] | select($replied_set[.id | tostring])] | length),
    pending_count: ([$bot_comments[] | select(.user.login != "Copilot") | select($replied_set[.id | tostring] | not)] | length),
    copilot_count: ([$bot_comments[] | select(.user.login == "Copilot")] | length)
  }
}
'
