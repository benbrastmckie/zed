# Implementation Plan: Add Claude ACP Keybindings Docs

- **Task**: 2 - Add Claude ACP keybindings docs
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/002_add_claude_acp_keybindings_docs/reports/01_claude-acp-keybindings.md
- **Artifacts**: plans/01_add-keybindings-docs.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: true

## Overview

The existing Zed documentation in `docs/keybindings.md` and `docs/agent-system.md` covers only 4 agent-related shortcuts, while research identified 20+ keybindings across 9 categories (panel management, thread management, message editing, thread navigation, model/profile management, inline assist, edit predictions, and external agents). This plan updates both documentation files with the complete keybinding reference, corrects potentially stale bindings (Ctrl+; and Ctrl+N), and adds coverage for edit predictions and Claude ACP external agent setup. Done when both files contain the full keybinding set organized by category.

### Research Integration

Research report `01_claude-acp-keybindings.md` identified 9 categories of agent keybindings with 20+ shortcuts. Key findings integrated:
- Two potentially stale bindings (Ctrl+; for inline assist, Ctrl+N for new thread) flagged for verification note
- Custom override of Ctrl+? from `agent::ToggleFocus` to `workspace::ToggleRightDock` documented
- Edit prediction shortcuts (Tab, Alt+L, Alt+], Alt+[) not currently documented anywhere
- Claude ACP external agent has no default binding; suggested custom binding Ctrl+Alt+C
- Context-dependent bindings (thread pane focused vs message editor focused) need clear labeling

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROAD_MAP.md found.

## Goals & Non-Goals

**Goals**:
- Expand `docs/keybindings.md` "How do I use the AI agent?" section with all 9 keybinding categories
- Update `docs/agent-system.md` with a keybindings quick reference for the Zed agent panel
- Correct or flag stale bindings (Ctrl+; and Ctrl+N) with verification notes
- Document edit prediction shortcuts
- Document Claude ACP external agent custom binding setup

**Non-Goals**:
- Modifying `keymap.json` (no new custom bindings added in this task)
- Documenting macOS keybindings (this is a Linux-only setup)
- Creating a separate keybindings reference file (integrate into existing docs)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Stale bindings (Ctrl+; and Ctrl+N) may be incorrect | M | M | Add verification note suggesting users check Ctrl+K Ctrl+S for current bindings |
| Zed updates change keybindings after documentation | L | M | Include date note and command palette verification guidance |
| Context-dependent bindings confuse users | M | L | Clearly label which panel/focus state each binding requires |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1    | 1      | --         |
| 2    | 2      | 1          |

Phases within the same wave can execute in parallel.

### Phase 1: Expand keybindings.md with full agent shortcuts [COMPLETED]

**Goal**: Replace the minimal 4-shortcut agent section with a comprehensive reference covering all 9 categories from research.

**Tasks**:
- [ ] Replace the "Agent panel (built-in)" subsection with expanded content covering: panel opening/focus, thread management, message editor shortcuts, and thread navigation (both contexts)
- [ ] Add new subsection "Model and profile management" with Ctrl+Alt+/, Alt+L, Ctrl+Alt+P, Shift+Tab
- [ ] Update "Inline assist" subsection: note Ctrl+Enter as current default, flag Ctrl+; status with verification note
- [ ] Add new subsection "Edit predictions" with Tab, Alt+L, Alt+], Alt+[ shortcuts
- [ ] Add new subsection "External agents (Claude ACP)" explaining custom binding setup via keymap.json
- [ ] Add verification guidance note (Ctrl+K Ctrl+S to check current bindings)
- [ ] Flag Ctrl+N with verification note about context-dependent behavior

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `docs/keybindings.md` - Expand "How do I use the AI agent?" section from ~20 lines to ~80 lines

**Verification**:
- All 9 research categories represented in the file
- Each shortcut includes context note where applicable (e.g., "when agent panel is focused")
- Custom bindings marked with * consistent with existing convention
- No broken markdown formatting

---

### Phase 2: Update agent-system.md with keybindings reference [COMPLETED]

**Goal**: Add a keybindings quick reference to the agent system documentation and update the existing shortcut mentions.

**Tasks**:
- [ ] Update the "How to use it" numbered list to correct Ctrl+; and Ctrl+N references (match Phase 1 changes)
- [ ] Add a "Keybindings Quick Reference" section after "How to use it" with a summary table of the most important agent panel shortcuts (10-15 most useful)
- [ ] Add note about edit predictions and external agent (Claude ACP) with cross-reference to keybindings.md for full details
- [ ] Fix the broken link `[Keybindings guide](guides/keybindings.md)` in Related Documentation to point to `keybindings.md` (correct relative path)

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `docs/agent-system.md` - Update existing shortcuts, add quick reference section (~30 lines added)

**Verification**:
- Shortcut references in agent-system.md consistent with keybindings.md
- Quick reference table renders correctly in markdown
- Cross-references between the two docs are correct
- Broken link to keybindings guide fixed

## Testing & Validation

- [ ] All shortcuts from research report Categories 1-9 are documented in at least one file
- [ ] Stale bindings (Ctrl+;, Ctrl+N) have verification notes
- [ ] Context-dependent bindings clearly labeled
- [ ] Markdown renders correctly (tables, headers, bold shortcuts)
- [ ] Cross-references between keybindings.md and agent-system.md are valid
- [ ] Custom binding convention (* marker) used consistently

## Artifacts & Outputs

- `docs/keybindings.md` - Updated with comprehensive agent keybinding reference
- `docs/agent-system.md` - Updated with keybindings quick reference and corrected shortcuts
- `specs/002_add_claude_acp_keybindings_docs/plans/01_add-keybindings-docs.md` - This plan
- `specs/002_add_claude_acp_keybindings_docs/summaries/01_add-keybindings-docs-summary.md` - Execution summary (after implementation)

## Rollback/Contingency

Both files are tracked in git. If changes cause issues, revert with `git checkout -- docs/keybindings.md docs/agent-system.md`. Since these are documentation-only changes, there is no risk to runtime behavior.
