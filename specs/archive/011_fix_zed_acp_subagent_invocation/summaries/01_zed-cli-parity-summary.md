# Implementation Summary: Zed CLI Parity Configuration

- **Task**: 11 - Fix Zed ACP subagent invocation
- **Status**: [COMPLETED]
- **Phases**: 3/3 completed

## Changes Made

### Phase 1: Terminal Task Creation
- Verified claude CLI at `/home/benjamin/.nix-profile/bin/claude` (v2.1.87)
- Created `.zed/tasks.json` with Claude Code terminal task
- Task uses `--dangerously-skip-permissions` flag, `use_new_terminal: true`, `reveal: "always"`
- JSONC comments explain the dual-mode approach
- Note: Zed has no terminal dock position control; terminal opens in default panel position

### Phase 2: Agent Server Environment Variables
- Updated `settings.json` `agent_servers.claude-acp.env` with three env vars:
  - `CLAUDE_CODE_EXECUTABLE`: Points ACP adapter to installed claude binary
  - `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS`: Enables team mode
  - `HOME`: Ensures settings discovery works in isolated adapter
- All other settings preserved unchanged
- Validated as valid JSONC

### Phase 3: Verification
- Both `.zed/tasks.json` and `settings.json` validated as valid JSONC
- All env vars confirmed present in agent_servers config
- Terminal dock position not supported by Zed task schema (documented limitation)

## Artifacts
- `.zed/tasks.json` - New file with Claude Code terminal task
- `settings.json` - Updated agent_servers env block

## Limitations
- Terminal opens in Zed's default panel position (no right-sidebar control available in task schema)
- ACP adapter still runs in SDK isolation mode for agent panel; terminal task is the full-parity path
