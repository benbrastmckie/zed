# Implementation Plan: Refactor Keymap Platform-Adaptive Keybindings

- **Task**: 56 - Refactor keymap.json to use Zed's `secondary-` modifier for platform-adaptive keybindings
- **Status**: [IMPLEMENTING]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_platform-adaptive-keybindings.md
- **Artifacts**: plans/01_platform-adaptive-keybindings.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: true

## Overview

Migrate 4 safe keybindings from `ctrl-` to `secondary-` in keymap.json, update the header comment to explain the two modifier categories, and revise both documentation files (keybindings.md and keybindings-cheat-sheet.typ) to use platform-neutral notation. The task is done when all 3 files are updated, internally consistent, and the remaining 10 `ctrl-` and 6 `alt-` bindings are preserved unchanged.

### Research Integration

Integrated report: `reports/01_platform-adaptive-keybindings.md` (2026-04-13). Key findings:
- Only 4 bindings can safely migrate: `ctrl-?`, `ctrl-shift-e`, `ctrl-shift-c`, `ctrl-enter`
- 5 have fatal/serious macOS collisions and must remain `ctrl-`
- `ctrl-shift-a` should remain `ctrl-` (Terminal SelectAll loss)
- `ctrl->` / `ctrl-<` must stay `ctrl-` with existing null-out overrides
- 6 `alt-` bindings are unaffected

### Roadmap Alignment

No ROADMAP.md items are directly advanced by this task.

## Goals & Non-Goals

**Goals**:
- Migrate `ctrl-?`, `ctrl-shift-e`, `ctrl-shift-c`, `ctrl-enter` to `secondary-` in keymap.json
- Update keymap.json header comment to explain `secondary-` vs `ctrl-` categories
- Update keybindings.md to use platform-neutral notation and explain the two modifier types
- Update keybindings-cheat-sheet.typ legend and binding labels for migrated bindings
- Preserve all 10 `ctrl-` bindings and 6 `alt-` bindings unchanged

**Non-Goals**:
- Migrating risky or collision-prone bindings (`ctrl-h`, `ctrl-l`, `ctrl-o`, `ctrl-i`, `ctrl-q`, `ctrl-shift-a`, `ctrl->`, `ctrl-<`)
- Changing the `alt-` bindings or ProjectPanel bare-key bindings
- Modifying Zed default reference comment block beyond updating notation for migrated bindings

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `secondary-enter` overrides `editor::NewlineBelow` on macOS | L | H (definite on macOS) | Acceptable: vim `o` or Enter at EOL as alternatives; document the override |
| `secondary-shift-c` overrides `collab_panel::ToggleFocus` on macOS | L | H (definite on macOS) | Acceptable: collab panel rarely used |
| Documentation notation inconsistency between files | M | M | Phase 3 cross-checks all three files for consistency |
| Future Zed update changes default bindings | M | L | Document Zed version context; re-audit on major updates |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Migrate Bindings in keymap.json [COMPLETED]

**Goal**: Change 4 bindings from `ctrl-` to `secondary-` and update the header comment block.

**Tasks**:
- [ ] Change `ctrl-?` to `secondary-?` in Workspace context (line 37)
- [ ] Change `ctrl-shift-e` to `secondary-shift-e` in Workspace context (line 38) and Editor context (line 73)
- [ ] Change `ctrl-shift-c` to `secondary-shift-c` in Editor context (line 72)
- [ ] Change `ctrl-enter` to `secondary-enter` in Editor context (line 76)
- [ ] Rewrite header comment (lines 2-27): explain `secondary-` modifier, categorize bindings into `secondary-` (platform-adaptive, 4 bindings) and `ctrl-` (fixed, 10 bindings) groups, remove the blanket "All custom bindings intentionally use Ctrl+" statement
- [ ] Update the Zed default reference comment block entries for migrated bindings (lines 121-220) to reflect `secondary-` notation where applicable

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `keymap.json` -- binding values and header/reference comments

**Verification**:
- All 4 migrated bindings use `secondary-` prefix
- All 10 non-migrated `ctrl-` bindings unchanged
- All 6 `alt-` bindings unchanged
- JSON is valid (no syntax errors)

---

### Phase 2: Update keybindings.md [COMPLETED]

**Goal**: Revise the keyboard shortcuts guide to use platform-neutral notation and explain the two modifier categories.

**Tasks**:
- [ ] Replace opening line "This guide assumes macOS" with a platform-neutral introduction that explains: (a) Zed defaults use Cmd on macOS / Ctrl on Linux, (b) custom bindings marked with `*` fall into two categories: platform-adaptive (`Ctrl/Cmd`) and fixed (`Ctrl` on all platforms)
- [ ] Add a brief "Modifier Key Reference" section near the top explaining `secondary-` = Ctrl on Linux, Cmd on macOS
- [ ] Update the 4 migrated bindings in Quick Reference table and throughout the document: show as `Ctrl/Cmd+?`, `Ctrl/Cmd+Shift+E`, `Ctrl/Cmd+Shift+C`, `Ctrl/Cmd+Enter`
- [ ] Update the pane navigation section (lines 54-55): change `Cmd+H` / `Cmd+L` notation to `Ctrl+H` / `Ctrl+L` (these are ctrl- on all platforms, not Cmd)
- [ ] Update the "Adding more shortcuts" section (line 220) to mention `secondary-` as the preferred modifier for new cross-platform bindings
- [ ] Verify all remaining `Ctrl+` custom bindings are explicitly labeled as Ctrl on all platforms

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `docs/general/keybindings.md` -- notation and explanatory text throughout

**Verification**:
- No stale "assumes macOS" framing
- Migrated bindings shown as `Ctrl/Cmd+`
- Fixed bindings clearly marked as Ctrl on all platforms
- Consistent notation throughout

---

### Phase 3: Update keybindings-cheat-sheet.typ [COMPLETED]

**Goal**: Update the Typst cheat sheet legend and binding labels for the 4 migrated bindings.

**Tasks**:
- [ ] Update footer legend (line 19): replace "Linux notation. On macOS, substitute Cmd for Ctrl." with a legend that distinguishes platform-adaptive bindings (marked with a visual indicator) from fixed Ctrl bindings
- [ ] Add a visual indicator (e.g., a dagger symbol or different label) for platform-adaptive bindings, or use `Sec` / `Ctrl/Cmd` label in `key-combo()` calls
- [ ] Update `key-combo("Ctrl", "?")` (line 186) to platform-adaptive label
- [ ] Update `key-combo("Ctrl", "Shift", "E")` (line 185) to platform-adaptive label
- [ ] Update `key-combo("Ctrl", "Shift", "C")` (line 192) to platform-adaptive label
- [ ] Update `key-combo("Ctrl", "Enter")` (lines 153, 217) to platform-adaptive label
- [ ] Verify all remaining custom `Ctrl+` bindings retain their current labels
- [ ] Compile the cheat sheet (`typst compile docs/general/keybindings-cheat-sheet.typ`) to verify no errors

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `docs/general/keybindings-cheat-sheet.typ` -- footer, key-combo labels for 4 migrated bindings

**Verification**:
- Typst compiles without errors
- Footer legend distinguishes the two modifier categories
- 4 migrated bindings have platform-adaptive labels
- Remaining bindings unchanged

---

### Phase 4: Cross-File Consistency Check [NOT STARTED]

**Goal**: Verify all three files are internally consistent and aligned with each other.

**Tasks**:
- [ ] Compare binding keys across keymap.json, keybindings.md, and keybindings-cheat-sheet.typ: all 17 bindings should match
- [ ] Verify the 4 migrated bindings are consistently documented as platform-adaptive in all files
- [ ] Verify the 10 fixed `ctrl-` bindings are consistently documented as Ctrl-on-all-platforms
- [ ] Fix any inconsistencies found
- [ ] Update the cheat sheet sync date comment (line 2) to current date

**Timing**: 15 minutes

**Depends on**: 2, 3

**Files to modify**:
- Any of the 3 files if inconsistencies are found
- `docs/general/keybindings-cheat-sheet.typ` -- sync date comment

**Verification**:
- All 17 bindings are consistent across all 3 files
- No stale notation or comments remain

## Testing & Validation

- [ ] keymap.json is valid JSON (no trailing commas, proper nesting)
- [ ] `typst compile docs/general/keybindings-cheat-sheet.typ` succeeds without errors
- [ ] 4 bindings use `secondary-` in keymap.json: `secondary-?`, `secondary-shift-e`, `secondary-shift-c`, `secondary-enter`
- [ ] 10 bindings remain `ctrl-` in keymap.json: `ctrl-h`, `ctrl-l`, `ctrl-q`, `ctrl-o`, `ctrl-i`, `ctrl-shift-a`, `ctrl->`, `ctrl-<` (x2 in null-out contexts), `ctrl->` (mode==full), `ctrl-<` (mode==full)
- [ ] 6 bindings remain `alt-` in keymap.json: `alt-v`, `alt-j`, `alt-k`, `alt-shift-e`, `alt-shift-p`, `alt-r`
- [ ] Cross-file binding count: all 17 unique bindings documented in keybindings.md and keybindings-cheat-sheet.typ

## Artifacts & Outputs

- `keymap.json` -- Updated bindings and comments
- `docs/general/keybindings.md` -- Platform-neutral notation
- `docs/general/keybindings-cheat-sheet.typ` -- Updated legend and labels
- `specs/056_refactor_keymap_platform_adaptive/plans/01_platform-adaptive-keybindings.md` -- This plan
- `specs/056_refactor_keymap_platform_adaptive/summaries/01_platform-adaptive-keybindings-summary.md` -- Post-implementation summary

## Rollback/Contingency

All changes are to tracked files in git. If the migration causes issues:
1. `git checkout keymap.json docs/general/keybindings.md docs/general/keybindings-cheat-sheet.typ` reverts all changes
2. Individual bindings can be reverted from `secondary-` back to `ctrl-` independently
3. No database, build system, or external service dependencies
