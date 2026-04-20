# Implementation Plan: Troubleshoot Zed Keybindings on macOS

- **Task**: 76 - Troubleshoot Zed keybindings on macOS and update cheat sheet
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/076_troubleshoot_zed_keybindings_macos/reports/02_macos-keybinding-spec.md
- **Artifacts**: plans/02_macos-keybinding-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

This plan implements the complete macOS keybinding overhaul specified in the Round 2 research report. The work spans four files: keymap.json (fix bindings and remove redundant indent/outdent blocks), settings.json (verify comment accuracy), keybindings-cheat-sheet.typ (full macOS rewrite replacing Ctrl with Cmd for Zed defaults, Alt with Opt, removing platform-adaptive notation), and keybindings.md (matching notation updates throughout). A final verification phase compiles the Typst cheat sheet and cross-checks consistency across all files.

### Research Integration

The Round 2 research report (02_macos-keybinding-spec.md) provides an exhaustive entry-by-entry mapping for every cheat sheet line, specifying exactly which entries change from Ctrl to Cmd, which retain Ctrl (custom bindings), and which Alt entries become Opt. It also specifies the exact keymap.json block additions and removals. This plan follows that specification directly.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items found. The roadmap is currently empty.

## Goals & Non-Goals

**Goals**:
- Fix keymap.json: add ctrl-shift-a to Editor context, add secondary-shift-c to Workspace context, remove ctrl->/ctrl-< indent/outdent and their null-out boilerplate
- Update header comment block in keymap.json to reflect binding count changes
- Rewrite the Typst cheat sheet for macOS-only notation (Cmd for Zed defaults, Opt for Alt, no dagger/platform-adaptive markers)
- Update keybindings.md to match the new macOS-only notation throughout
- Verify all four files are internally consistent and the Typst cheat sheet compiles

**Non-Goals**:
- Adding new keybindings beyond what the research report specifies
- Changing any Zed settings beyond comment accuracy in settings.json
- Cross-platform support in documentation (this is now macOS-only)
- Modifying the Typst helper functions or layout structure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Removing ctrl->/ctrl-< breaks user muscle memory | L | L | Cmd+]/[ are standard macOS alternatives, documented in cheat sheet |
| Incorrect Ctrl vs Cmd assignment for a Zed default | M | M | Research report provides per-entry verification; verify against keymap docs |
| Typst compilation fails after edits | L | L | Phase 5 includes compilation check; syntax is straightforward substitutions |
| Missed Alt->Opt replacement in keybindings.md | L | M | Systematic search-and-replace with verification grep |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 4 | 1 |
| 3 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Fix keymap.json [COMPLETED]

**Goal**: Add missing bindings, remove redundant indent/outdent blocks, update header comment

**Tasks**:
- [ ] Add `"ctrl-shift-a": ["task::Spawn", { "task_name": "Claude Code" }]` to the Editor context block (after ctrl-i line)
- [ ] Add `"secondary-shift-c": "workspace::CopyPath"` to the first Workspace context block (after secondary-shift-e line)
- [ ] Remove `"ctrl->": "editor::Indent"` and `"ctrl-<": "editor::Outdent"` from the Editor context block (lines 83-84)
- [ ] Remove the second Workspace block that null-outs ctrl-> and ctrl-< (lines 92-98)
- [ ] Remove the `Editor && mode == full` block for indent/outdent (lines 99-105)
- [ ] Update header comment: change binding count from 17 to 15 unique custom bindings, remove the two indent/outdent entries from the ctrl- category listing
- [ ] Remove the indent/outdent comment line from the ctrl- category

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `keymap.json` -- Add 2 bindings, remove 3 blocks, update header comment

**Verification**:
- keymap.json is valid JSONC (no parse errors in Zed)
- ctrl-shift-a appears in both Workspace and Editor contexts
- secondary-shift-c appears in both Workspace and Editor contexts
- No ctrl-> or ctrl-< bindings remain anywhere in the file
- Header comment shows 15 unique custom bindings

---

### Phase 2: Verify settings.json [COMPLETED]

**Goal**: Confirm settings.json vim_mode comment matches reality

**Tasks**:
- [ ] Verify `"vim_mode": false` with comment `// No vim mode -- standard keybindings for all users` is present and accurate
- [ ] Confirm no other settings changes are needed (per research report section C)

**Timing**: 5 minutes

**Depends on**: none

**Files to modify**:
- `settings.json` -- Read-only verification; no changes expected (already correct per research)

**Verification**:
- vim_mode is false and comment is accurate
- No contradictions between settings and keymap

---

### Phase 3: Rewrite cheat sheet (Typst) [COMPLETED]

**Goal**: Complete macOS rewrite of keybindings-cheat-sheet.typ following the entry-by-entry mapping in research report section B2

**Tasks**:
- [ ] Update footer: remove dagger line, change 4-column grid to 3-column, update Ctrl explanation to "Ctrl bindings use the Control key (not Cmd)"
- [ ] Essentials section: Change Ctrl to Cmd for entries 1-7 and 9-10 (Open file, Save, Undo, Redo, Copy, Cut, Paste, Command palette, Open settings). Keep Ctrl+Q as-is (custom).
- [ ] Navigation section: Change Alt to Opt for Go back/Go forward (entries 15-16). Change Ctrl+Shift+T to Cmd+Shift+T (entry 19). Change `Ctrl/Cmd` Enter to `Cmd` Enter and remove `#sym.dagger` (entry 22).
- [ ] Editing section: Change Ctrl to Cmd for Select all, Select next occurrence, Toggle comment, Delete line (entries 27-30). Change Alt to Opt for Move line up/down and Reload file (entries 31-32, 35). Remove Ctrl+> Indent and Ctrl+< Outdent entries (entries 33-34). Add Cmd+] Indent and Cmd+[ Outdent as non-custom entries.
- [ ] Search & Replace section: Change Ctrl to Cmd for all three entries (36-38).
- [ ] Panels & Layout section: Change Ctrl to Cmd for Toggle left sidebar (entry 39). Change `Ctrl/Cmd` to `Cmd` and remove `#sym.dagger` for File explorer, Toggle right dock, Copy file path (entries 40-41, 47). Change Ctrl to Cmd for Split pane right/down (entries 43-44). Remove duplicate Ctrl+H and Ctrl+L entries (entries 45-46, already in Navigation).
- [ ] Preview section: Change Ctrl to Cmd for Markdown chords (entries 48-49). Change Alt to Opt for Build PDF and Preview in browser (entries 50-51).
- [ ] AI & Agent Panel section: Change Ctrl to Cmd for New thread, Thread history, Review agent changes (entries 53, 55, 56). Change Shift+Alt to Shift+Opt for Recent threads and Expand message editor (entries 54, 58). Change Ctrl+> to Cmd+> for Add selection to thread (entry 59). Change Ctrl+Alt to Ctrl+Opt for Toggle model selector and Manage profiles (entries 60, 62). Change Alt+L to Opt+L (entry 61). Change `Ctrl/Cmd` to `Cmd` and remove `#sym.dagger` for Inline assist (entry 64).
- [ ] Optional/Advanced section: Change Alt to Opt for Toggle vim mode (entry 65).
- [ ] Update the synced-with date comment at line 2 to current date

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `docs/general/keybindings-cheat-sheet.typ` -- Comprehensive modifier key updates across all sections

**Verification**:
- No remaining `"Alt"` strings in the file (all converted to `"Opt"`)
- No remaining `"Ctrl/Cmd"` strings in the file
- No remaining `#sym.dagger` references
- `"Ctrl"` appears only for: Ctrl+Q, Ctrl+O, Ctrl+I, Ctrl+H, Ctrl+L, Ctrl+Shift+A, Ctrl+G, Ctrl+Tab, Ctrl+Shift+Tab, Ctrl+`
- Footer uses 3-column grid without dagger entry
- Indent/outdent entries use Cmd+] and Cmd+[ (not Ctrl+> and Ctrl+<)
- No duplicate Ctrl+H / Ctrl+L entries in Panels section

---

### Phase 4: Update keybindings.md [COMPLETED]

**Goal**: Update all references in the markdown guide to match macOS-only notation

**Tasks**:
- [ ] Rewrite header section (lines 1-12): Replace platform-neutral explanation with macOS-only guide. State Cmd = Command key, Ctrl = Control key for specific custom bindings, Opt = Option key. Simplify custom binding explanation.
- [ ] Quick Reference table (lines 16-41): Replace all `Ctrl/Cmd+X` with `Cmd+X`. Replace all `Alt+X` with `Opt+X`. Keep Ctrl for custom ctrl- bindings. Remove `Ctrl/Cmd+\`` and use `Ctrl+\``.
- [ ] Body sections: Apply same Ctrl/Cmd->Cmd and Alt->Opt substitutions throughout all section text
- [ ] Remove `Ctrl/Cmd+H` remapping note (line 92) -- rewrite to explain Ctrl+H is used for pane navigation, use command palette for find-and-replace
- [ ] Replace `xdg-open` reference (line 182) with `open` (macOS command)
- [ ] Remove indent/outdent references to ctrl->/ctrl-<, add Cmd+]/Cmd+[ to editing section
- [ ] Update "Adding more shortcuts" section (line 226-228): Remove cross-platform secondary- explanation, replace with macOS-specific guidance
- [ ] Remove `Ctrl+>` and `Ctrl+<` from the fixed-Ctrl list in the modifier key reference

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `docs/general/keybindings.md` -- Systematic notation updates throughout

**Verification**:
- No remaining `Ctrl/Cmd` notation anywhere in the file
- No remaining `Alt+` notation (all converted to `Opt+`)
- No references to `ctrl->` or `ctrl-<` indent/outdent
- `xdg-open` does not appear
- Header clearly states this is a macOS guide

---

### Phase 5: Verification and Compilation [COMPLETED]

**Goal**: Compile the Typst cheat sheet and verify cross-file consistency

**Tasks**:
- [ ] Run `typst compile docs/general/keybindings-cheat-sheet.typ` and verify no errors
- [ ] Grep keymap.json for any remaining `ctrl->` or `ctrl-<` entries (expect zero)
- [ ] Grep keybindings-cheat-sheet.typ for any remaining `"Alt"` strings (expect zero)
- [ ] Grep keybindings-cheat-sheet.typ for any remaining `"Ctrl/Cmd"` or `sym.dagger` (expect zero)
- [ ] Grep keybindings.md for any remaining `Ctrl/Cmd` or `Alt+` notation (expect zero)
- [ ] Verify ctrl-shift-a appears in Workspace, Editor, and Terminal contexts in keymap.json
- [ ] Verify secondary-shift-c appears in both Workspace and Editor contexts in keymap.json
- [ ] Spot-check 5 entries between cheat sheet and keybindings.md for consistency

**Timing**: 20 minutes

**Depends on**: 3, 4

**Files to modify**:
- None (read-only verification)

**Verification**:
- Typst compilation succeeds without errors
- All grep checks pass (no stale notation remaining)
- Cross-file consistency confirmed

## Testing & Validation

- [ ] keymap.json parses as valid JSONC (Zed loads without errors)
- [ ] Typst cheat sheet compiles successfully to PDF
- [ ] No `Ctrl/Cmd` dual notation remains in any documentation file
- [ ] No `Alt+` notation remains (all converted to `Opt+`)
- [ ] No `ctrl->` or `ctrl-<` bindings remain in keymap.json
- [ ] ctrl-shift-a is bound in Workspace, Editor, and Terminal contexts
- [ ] secondary-shift-c is bound in both Workspace and Editor contexts
- [ ] Cheat sheet and keybindings.md agree on all shortcut notation

## Artifacts & Outputs

- `keymap.json` -- Updated custom bindings (add 2, remove 3 blocks)
- `settings.json` -- No changes expected (already correct)
- `docs/general/keybindings-cheat-sheet.typ` -- Complete macOS rewrite
- `docs/general/keybindings.md` -- Notation updates throughout
- `plans/02_macos-keybinding-plan.md` -- This plan

## Rollback/Contingency

All four files are tracked in git. If any changes cause problems:
1. `git diff` to review what changed
2. `git checkout -- keymap.json settings.json docs/general/keybindings-cheat-sheet.typ docs/general/keybindings.md` to revert all changes
3. Individual file revert: `git checkout -- <file>` for targeted rollback
