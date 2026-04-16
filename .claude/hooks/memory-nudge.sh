#!/usr/bin/env bash
# Memory nudge hook (Stop hook)
# Prints a one-line reminder about memory capture after lifecycle command completion.
# No file writes, no MCP calls, no state changes. Idempotent and non-blocking.

# Read the transcript/tool output to detect lifecycle command completion
TOOL_OUTPUT="${CLAUDE_TOOL_OUTPUT:-}"
RESPONSE="${CLAUDE_RESPONSE:-}"

# Check for lifecycle command completion markers in the response
# These patterns indicate a /research, /plan, or /implement just completed
if echo "$RESPONSE" | grep -qiE '(status updated to \[RESEARCHED\]|status updated to \[PLANNED\]|status updated to \[COMPLETED\]|Research completed for task|Plan created for task|Implementation completed for task)'; then
    # Extract task number if possible
    TASK_NUM=$(echo "$RESPONSE" | grep -oE 'task [0-9]+' | head -1 | grep -oE '[0-9]+')
    if [ -n "$TASK_NUM" ]; then
        echo "Memory: artifacts available for /learn --task $TASK_NUM"
    fi
fi

# Always exit 0 (non-blocking)
exit 0
