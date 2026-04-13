# Implementation Plan: Revise Keybindings Docs Post Task 56

- **Task**: 59 - Revise keybindings docs post task 56
- **Status**: [COMPLETED]
- **Effort**: 0.5 hours
- **Dependencies**: Task 56 (completed)
- **Research Inputs**: reports/01_keybindings-docs-review.md
- **Artifacts**: plans/01_keybindings-docs-review.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: true

## Overview

Fix the inline assist / open file documentation conflict caused by the task 56 `secondary-enter` migration. The custom `secondary-enter` binding maps to `editor::OpenFile`, which overrides the Zed default inline assist shortcut in Editor context. Both `keybindings.md` and the Typst cheat sheet need corrections to reflect this override and point users to working alternatives.

### Research Integration

The research report identified one significant issue (inline assist docs conflict) and two minor pre-existing gaps. This plan addresses the significant issue directly caused by task 56. The pre-existing gaps (missing `Alt+R` in keybindings.md, `Ctrl/Cmd+>` context ambiguity) are noted but out of scope.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No active roadmap items. The roadmap is empty.

## Goals & Non-Goals

**Goals**:
- Correct the inline assist entry in keybindings.md to reflect the `secondary-enter` override
- Add `Ctrl/Cmd+Enter` to the Quick Reference table as "Open file under cursor"
- Fix the cheat sheet inline assist entry notation and override note

**Non-Goals**:
- Fixing pre-existing documentation gaps unrelated to task 56 (Alt+R missing, Ctrl/Cmd+> ambiguity)
- Restructuring or reorganizing the docs beyond targeted corrections

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Incorrect alternative shortcut for inline assist | M | L | Verify `Ctrl/Cmd+;` is not overridden in keymap.json before recommending it |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |

Phases within the same wave can execute in parallel.

### Phase 1: Fix keybindings.md [COMPLETED]

**Goal**: Correct inline assist documentation and add Open File to Quick Reference table.

**Tasks**:
- [ ] Add `Ctrl/Cmd+Enter *` -> "Open file under cursor (overrides inline assist default)" to the Quick Reference table, positioned near other navigation entries
- [ ] Update the Inline Assist section (line 149): change entry to note that `Ctrl/Cmd+Enter` is overridden by the custom "Open file under cursor" binding in Editor context; recommend `Ctrl/Cmd+;` or command palette as alternatives
- [ ] Verify `Ctrl/Cmd+;` is not overridden in keymap.json

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:
- `docs/general/keybindings.md` -- Update Quick Reference table and Inline Assist section

**Verification**:
- Quick Reference table includes `Ctrl/Cmd+Enter *` entry
- Inline assist section clearly notes the override and provides working alternatives
- No contradictory information about `Ctrl/Cmd+Enter` remains

---

### Phase 2: Fix cheat sheet [COMPLETED]

**Goal**: Correct the inline assist entry in the Typst cheat sheet.

**Tasks**:
- [ ] Update line 217: change `Ctrl+Enter` to `Ctrl/Cmd+Enter` with dagger symbol and add note that it is overridden by custom "Open file" binding in Editor context
- [ ] Consider adding `Ctrl/Cmd+;` as the working alternative for inline assist, or annotate the existing entry to indicate the override

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:
- `docs/general/keybindings-cheat-sheet.typ` -- Fix inline assist entry notation and override note

**Verification**:
- Inline assist entry uses correct `Ctrl/Cmd+Enter` notation with dagger
- Override by custom binding is noted
- No misleading information about key availability

## Testing & Validation

- [ ] All `Ctrl/Cmd+Enter` references across both docs are consistent and accurate
- [ ] The cheat sheet dagger symbol usage is consistent (platform-adaptive bindings marked)
- [ ] No contradictions between keybindings.md, cheat sheet, and keymap.json for the affected entries

## Artifacts & Outputs

- `docs/general/keybindings.md` -- Updated with inline assist override note and Quick Reference entry
- `docs/general/keybindings-cheat-sheet.typ` -- Updated inline assist entry

## Rollback/Contingency

Both files are version-controlled. Revert with `git checkout HEAD -- docs/general/keybindings.md docs/general/keybindings-cheat-sheet.typ` if changes introduce errors.
