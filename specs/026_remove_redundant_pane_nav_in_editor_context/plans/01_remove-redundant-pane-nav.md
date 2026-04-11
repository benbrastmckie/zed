# Implementation Plan: Task #26

- **Task**: 26 - Remove redundant ctrl-h/ctrl-l in Editor context of keymap.json
- **Status**: [NOT STARTED]
- **Effort**: 0.1 hours
- **Dependencies**: None
- **Research Inputs**: None (review-generated task)
- **Artifacts**: plans/01_remove-redundant-pane-nav.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: true

## Overview

Remove two redundant pane navigation bindings (`ctrl-h`, `ctrl-l`) from the Editor context block in `keymap.json` at lines 35-36. These bindings are already defined in the Workspace context block at lines 14-15, and since Editor is a descendant of Workspace in Zed's context hierarchy, the Workspace bindings apply within editors. The duplication serves no semantic purpose and removing it reduces configuration noise.

### Research Integration

No research report was produced for this task. Verification was performed by inspecting `keymap.json` directly:
- L14-15 (Workspace context): `ctrl-h` -> `workspace::ActivatePaneLeft`, `ctrl-l` -> `workspace::ActivatePaneRight`
- L35-36 (Editor context): identical bindings to the identical actions
- The actions are `workspace::*` (not `editor::*`), confirming they are intended for pane-level navigation, which the Workspace context already covers.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted for this minimal cleanup task.

## Goals & Non-Goals

**Goals**:
- Eliminate duplicated `ctrl-h`/`ctrl-l` bindings from the Editor context block
- Preserve the remaining Editor-context bindings (`alt-j`, `alt-k`, `ctrl-shift-c`) unchanged
- Keep Workspace-context bindings (L14-15) untouched so pane navigation continues to work everywhere

**Non-Goals**:
- Restructuring the rest of `keymap.json`
- Adding new keybindings
- Changing pane-navigation behavior

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Editor context intentionally overrode a different default | L | L | Verified actions are identical (`workspace::ActivatePaneLeft/Right`); Workspace bindings cascade into Editor. Test Ctrl+H/Ctrl+L in a split editor after edit. |
| JSON syntax error (trailing comma) after line removal | L | L | Remove the two lines cleanly; ensure the preceding line (`alt-k`) retains its trailing comma and the following line (`ctrl-shift-c`) is the last entry without a trailing comma, or vice versa depending on final position. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |

### Phase 1: Remove redundant bindings [NOT STARTED]

**Goal**: Delete the two redundant lines from the Editor context block in `keymap.json`.

**Tasks**:
- [ ] Open `/home/benjamin/.config/zed/keymap.json`
- [ ] Remove line 35: `"ctrl-h": "workspace::ActivatePaneLeft",`
- [ ] Remove line 36: `"ctrl-l": "workspace::ActivatePaneRight",`
- [ ] Verify the Editor `bindings` object remains valid JSON (commas correct)
- [ ] Save file

**Timing**: 0.1 hours

**Depends on**: none

**Files to modify**:
- `keymap.json` - remove 2 redundant lines in the Editor context block

**Verification**:
- File parses as valid JSON (Zed does not report a keymap error)
- Ctrl+H still moves focus to the left pane from an editor
- Ctrl+L still moves focus to the right pane from an editor
- `alt-j`, `alt-k`, `ctrl-shift-c` Editor bindings continue to work

---

## Testing & Validation

- [ ] `keymap.json` is valid JSON after the edit
- [ ] Zed reloads the keymap without errors
- [ ] Ctrl+H / Ctrl+L pane navigation still works inside editor buffers
- [ ] Remaining Editor-context bindings (alt-j, alt-k, ctrl-shift-c) still function

## Artifacts & Outputs

- Modified file: `keymap.json` (2 lines removed)
- Execution summary: `specs/026_remove_redundant_pane_nav_in_editor_context/summaries/01_remove-redundant-pane-nav-summary.md`

## Rollback/Contingency

If pane navigation stops working from editor buffers after the edit (unexpected, since Workspace context should cascade), restore the two lines to the Editor context block. The change is isolated to two lines and trivially revertible via `git checkout -- keymap.json`.
