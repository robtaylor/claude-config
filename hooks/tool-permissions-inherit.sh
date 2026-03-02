#!/bin/bash
# tool-permissions-inherit.sh — PreToolUse hook for Claude Code
#
# Problem: Subagents (Task tool) don't inherit the parent session's
# permission allow list from settings.json. This means agents get
# prompted for Read, Edit, Glob, etc. even when the user has
# Read(/**), Edit(/**), etc. in their allow list.
#
# Solution: This hook reads the allow patterns for the current tool
# from settings.json and auto-approves if the tool input matches.
#
# Supported tools and their match fields:
#   Read    → file_path matched against Read(pattern)
#   Edit    → file_path matched against Edit(pattern)
#   Write   → file_path matched against Write(pattern)
#   Glob    → pattern matched against Glob(pattern)
#   Grep    → pattern matched against Grep(pattern)
#   LS      → path matched against LS(pattern)

set -eo pipefail

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [ -z "$TOOL_NAME" ]; then
  exit 0
fi

SETTINGS="$HOME/.claude/settings.json"
if [ ! -f "$SETTINGS" ]; then
  exit 0
fi

# Determine which input field to match based on tool type
case "$TOOL_NAME" in
  Read|Edit|Write)
    MATCH_VALUE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
    ;;
  Glob)
    MATCH_VALUE=$(echo "$INPUT" | jq -r '.tool_input.pattern // empty')
    ;;
  Grep)
    MATCH_VALUE=$(echo "$INPUT" | jq -r '.tool_input.pattern // empty')
    ;;
  LS)
    MATCH_VALUE=$(echo "$INPUT" | jq -r '.tool_input.path // empty')
    ;;
  NotebookRead|NotebookEdit)
    MATCH_VALUE=$(echo "$INPUT" | jq -r '.tool_input.notebook_path // empty')
    ;;
  *)
    exit 0  # unknown tool, pass through
    ;;
esac

if [ -z "$MATCH_VALUE" ]; then
  exit 0
fi

# Extract patterns for this tool from settings.json
# e.g. Read(/**) → /**
PATTERNS=()
while IFS= read -r line; do
  [ -n "$line" ] && PATTERNS+=("$line")
done < <(
  jq -r '.permissions.allow[]? // empty' "$SETTINGS" |
  grep "^${TOOL_NAME}(" |
  sed -n "s/^${TOOL_NAME}(\\(.*\\))$/\\1/p"
)

if [ ${#PATTERNS[@]} -eq 0 ]; then
  exit 0  # no patterns for this tool
fi

# Check if MATCH_VALUE matches any pattern (glob matching)
for pattern in "${PATTERNS[@]}"; do
  # shellcheck disable=SC2254
  if [[ "$MATCH_VALUE" == $pattern ]]; then
    jq -n --arg tool "$TOOL_NAME" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "allow",
        permissionDecisionReason: ("\($tool) auto-approved: matches settings.json allow pattern")
      }
    }'
    exit 0
  fi
done

# No match — fall through to normal permission system
exit 0
