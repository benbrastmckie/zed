# Implementation Plan: Zed CLI Parity Configuration

- **Task**: 11 - Fix Zed ACP subagent invocation to match Neovim Claude Code plugin behavior
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_team-research.md
- **Artifacts**: plans/01_zed-cli-parity.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Configure Zed for full Claude Code CLI parity using a dual approach: (1) a terminal task entry in `.zed/tasks.json` that launches the `claude` CLI binary directly for complete feature parity including --team mode, with the terminal opening as a right sidebar; and (2) update the existing `agent_servers` config in `settings.json` with `CLAUDE_CODE_EXECUTABLE` so the agent panel still works for simple tasks. This addresses the SDK isolation mode root cause identified in research while giving the user the full CLI experience they requested.

### Research Integration

Integrated findings from `reports/01_team-research.md` (team research, 4 teammates):
- The ACP adapter runs in SDK isolation mode with no Skill/Agent tools available (Finding 1)
- `CLAUDE_CODE_EXECUTABLE` env var redirects the adapter to the user's installed binary (Finding 3)
- Team mode is a hard SDK constraint -- terminal task is the only path to full parity (Finding 5)
- Option C (terminal task) was recommended as the full-parity approach (Recommendation)
- The `env: {}` block in current settings forwards no environment variables, compounding isolation (Summary)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Create `.zed/tasks.json` with a Claude Code terminal task entry
- Configure the terminal task to open as a right sidebar (not bottom panel)
- Update `settings.json` agent_servers with `CLAUDE_CODE_EXECUTABLE` env var for ACP panel fallback
- Verify the claude binary path exists and is functional
- Provide a working dual-mode setup: terminal for full parity, agent panel for simple inline tasks

**Non-Goals**:
- Fix Zed's subagent rendering bug (upstream issue, out of scope)
- Implement environment detection / graceful degradation in the agent system itself (future task)
- Switch to `type: "registry"` adapter (untested, research gap -- stay with known `type: "custom"`)
- Add a `/doctor` command for runtime diagnosis (future task per research recommendations)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Zed tasks.json `dock` setting may not support right sidebar positioning | M | M | Research Zed task dock options; fall back to default panel if unsupported |
| claude binary path changes after Nix profile update | L | L | Use `~/.nix-profile/bin/claude` which is a stable symlink |
| ACP adapter ignores CLAUDE_CODE_EXECUTABLE with custom type | M | L | Research confirmed this env var works with both custom and registry types |
| Terminal task lacks inline diff review UI | L | H | Accepted trade-off per user decision; agent panel remains available for simple tasks |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Verify Environment and Create Terminal Task [NOT STARTED]

**Goal**: Confirm the claude binary works and create `.zed/tasks.json` with a terminal task configured to open as a right sidebar.

**Tasks**:
- [ ] Verify `/home/benjamin/.nix-profile/bin/claude` exists and check version (`claude --version`)
- [ ] Create `.zed/` directory if it does not exist
- [ ] Create `.zed/tasks.json` with a Claude Code terminal task entry:
  - `label`: "Claude Code"
  - `command`: "/home/benjamin/.nix-profile/bin/claude"
  - `args`: ["--dangerously-skip-permissions"]
  - `reveal`: "always"
  - `use_new_terminal`: true
  - Configure `dock` or equivalent setting for right sidebar positioning
- [ ] Research Zed's task schema for terminal dock position options (check Zed docs for `reveal_target`, `dock`, or panel positioning fields)

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `.zed/tasks.json` - Create new file with Claude Code terminal task

**Verification**:
- `.zed/tasks.json` is valid JSON
- File contains the Claude Code task entry with correct binary path

---

### Phase 2: Update Agent Server Configuration [NOT STARTED]

**Goal**: Add `CLAUDE_CODE_EXECUTABLE` and related env vars to the existing `agent_servers` config so the ACP panel works better for simple tasks.

**Tasks**:
- [ ] Edit `settings.json` to update the `agent_servers.claude-acp.env` block:
  - Add `"CLAUDE_CODE_EXECUTABLE": "/home/benjamin/.nix-profile/bin/claude"`
  - Add `"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"`
  - Add `"HOME": "/home/benjamin"` (ensures settings sources are found)
- [ ] Preserve all other existing settings unchanged
- [ ] Validate the resulting settings.json is valid JSONC

**Timing**: 20 minutes

**Depends on**: 1

**Files to modify**:
- `settings.json` - Update `agent_servers.claude-acp.env` block (lines 152-153)

**Verification**:
- `settings.json` parses as valid JSONC
- `agent_servers.claude-acp.env` contains all three env vars
- No other settings were altered

---

### Phase 3: Test and Document Configuration [NOT STARTED]

**Goal**: Verify both configurations work and document usage for the user.

**Tasks**:
- [ ] Test terminal task: confirm `.zed/tasks.json` is recognized by Zed (check with `zed` task picker)
- [ ] Test agent panel: confirm `settings.json` changes are loaded (restart Zed if needed)
- [ ] Verify terminal opens in right sidebar position (or document fallback if dock setting unsupported)
- [ ] Add a brief comment block at top of `.zed/tasks.json` explaining the dual-mode approach

**Timing**: 20 minutes

**Depends on**: 2

**Files to modify**:
- `.zed/tasks.json` - Add explanatory comments if JSONC is supported, otherwise no change

**Verification**:
- Terminal task appears in Zed task picker
- Running the task launches claude CLI in a terminal panel
- Terminal opens on the right side (or documented workaround)
- Agent panel still functions for simple prompts

## Testing & Validation

- [ ] `.zed/tasks.json` exists and contains valid JSON with Claude Code task
- [ ] `settings.json` has populated `env` block in `agent_servers.claude-acp`
- [ ] Claude binary at `/home/benjamin/.nix-profile/bin/claude` is executable
- [ ] Terminal task launches from Zed task picker
- [ ] Terminal opens as right sidebar (or documented alternative)
- [ ] Agent panel still responds to simple prompts after env var changes

## Artifacts & Outputs

- `.zed/tasks.json` - New file with Claude Code terminal task
- `settings.json` - Updated with CLAUDE_CODE_EXECUTABLE env var
- `specs/011_fix_zed_acp_subagent_invocation/plans/01_zed-cli-parity.md` - This plan
- `specs/011_fix_zed_acp_subagent_invocation/summaries/01_zed-cli-parity-summary.md` - Implementation summary (after completion)

## Rollback/Contingency

- **Terminal task**: Delete `.zed/tasks.json` to remove the terminal task entry
- **Agent server config**: Revert `settings.json` env block to `"env": {}` to restore original behavior
- **Git**: All changes are committed per phase, so `git revert` can undo any phase independently
- **If right sidebar is unsupported**: Accept bottom panel (default Zed terminal behavior) and document the limitation
