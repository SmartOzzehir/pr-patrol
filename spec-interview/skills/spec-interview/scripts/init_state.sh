#!/usr/bin/env bash
# init_state.sh - Initialize spec interview state file
# Usage: ./init_state.sh <spec_id> [language]
#
# Examples:
#   ./init_state.sh "dashboard-export"
#   ./init_state.sh "user-auth" "tr"

set -euo pipefail

# Platform detection - need GNU date for -Iseconds flag
if date --version &>/dev/null; then
  DATE_CMD="date"
elif command -v gdate &>/dev/null; then
  DATE_CMD="gdate"
else
  echo "ERROR: GNU date required. On macOS: brew install coreutils" >&2
  echo "Windows users: Use WSL" >&2
  exit 1
fi

SPEC_ID="${1:?Usage: $0 <spec_id> [language]}"
LANGUAGE="${2:-en}"

# Sanitize spec_id for filename (remove spaces, special chars)
SAFE_ID=$(echo "$SPEC_ID" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')

# Create directory if needed
STATE_DIR=".claude/spec-interviews"
mkdir -p "$STATE_DIR"

STATE_FILE="${STATE_DIR}/${SAFE_ID}.md"

# Check if file already exists
if [[ -f "$STATE_FILE" ]]; then
  echo "State file already exists: $STATE_FILE"
  echo "Use --force to overwrite or choose a different spec_id"
  exit 1
fi

TIMESTAMP=$($DATE_CMD -Iseconds)

# Create state file
cat > "$STATE_FILE" << EOF
---
spec_id: "${SPEC_ID}"
current_stage: 0
status: calibration
tech_level: ""
language: "${LANGUAGE}"
created: "${TIMESTAMP}"
last_updated: "${TIMESTAMP}"
---

# Spec Interview: ${SPEC_ID}

## Progress

| Stage | Status | Summary |
|-------|--------|---------|
| 0. Calibration | ⏳ | Pending |
| 1. Problem & Vision | ⬜ | - |
| 2. Stakeholders | ⬜ | - |
| 3. Functional | ⬜ | - |
| 4. UI/UX | ⬜ | - |
| 5. Edge Cases | ⬜ | - |
| 6. Non-Functional | ⬜ | - |
| 7. Technical | ⬜ | - |
| 8. Prioritization | ⬜ | - |

---

## Stage 0: Calibration

(Pending tech level assessment)

---

## Stage 1: Problem & Vision

(Not started)

---

## Stage 2: Stakeholders & Users

(Not started)

---

## Stage 3: Functional Requirements

(Not started)

---

## Stage 4: UI/UX Design

(Not started)

---

## Stage 5: Edge Cases & Error Handling

(Not started)

---

## Stage 6: Non-Functional Requirements

(Not started)

---

## Stage 7: Technical Architecture

(Not started)

---

## Stage 8: Prioritization & Phasing

(Not started)

---

## Validation

(Pending - runs after all stages complete)

---

## Output

- **Spec file:** (not yet generated)
- **Complexity:** (not yet calculated)
EOF

echo "Created: $STATE_FILE"
echo "Spec ID: $SPEC_ID"
echo "Language: $LANGUAGE"
