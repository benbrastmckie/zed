# Research Report: Task #59

**Task**: 59 - Revise keybindings docs post task 56
**Started**: 2026-04-13T12:00:00Z
**Completed**: 2026-04-13T12:30:00Z
**Effort**: 30 minutes
**Dependencies**: Task 56 (completed)
**Sources/Inputs**:
- `docs/general/keybindings.md` -- Current keyboard shortcuts guide
- `docs/general/keybindings-cheat-sheet.typ` -- Current Typst cheat sheet
- `keymap.json` -- Current keymap configuration
- `specs/056_refactor_keymap_platform_adaptive/summaries/01_platform-adaptive-keybindings-summary.md` -- Task 56 summary
**Artifacts**:
- `specs/059_revise_keybindings_docs_post_task_56/reports/01_keybindings-docs-review.md`
**Standards**: report-format.md, artifact-management.md

## Executive Summary

- Task 56 successfully migrated 4 keybindings to `secondary-` and updated both doc files with platform-neutral notation, dagger legend, and modifier key reference section.
- The core migration documentation is correct and consistent across all three files (keymap.json, keybindings.md, cheat sheet).
- One significant issue found: `Ctrl/Cmd+Enter` is documented as "inline assist" in keybindings.md but `secondary-enter` is bound to `editor::OpenFile` in keymap.json, creating an undocumented override conflict.
- The cheat sheet line 217 lists inline assist as plain `Ctrl+Enter` (no dagger, no `/Cmd`), which is inconsistent with the Zed default being `Cmd+Enter` on macOS and now overridden by the custom `secondary-enter` -> `editor::OpenFile` binding.
- Two minor pre-existing gaps unrelated to task 56 were also discovered (documented below for completeness).

## Context & Scope

Task 56 migrated `ctrl-?`, `ctrl-shift-e`, `ctrl-shift-c`, and `ctrl-enter` to use Zed's `secondary-` modifier prefix. This research evaluates whether the documentation accurately reflects the current keymap state after that migration.

**Scope**: Compare keymap.json bindings against keybindings.md and keybindings-cheat-sheet.typ for accuracy, consistency, and completeness.

## Findings

### 1. Correctly Updated (No Action Needed)

The following were properly updated by task 56 and are consistent across all three files:

- **`secondary-?`** -> `Ctrl/Cmd+?` (toggle right dock): Correct in keybindings.md (line 34, 109), cheat sheet (line 186 with dagger), keymap.json.
- **`secondary-shift-e`** -> `Ctrl/Cmd+Shift+E` (file explorer): Correct in keybindings.md (line 47), cheat sheet (line 185 with dagger), keymap.json.
- **`secondary-shift-c`** -> `Ctrl/Cmd+Shift+C` (copy path): Correct in keybindings.md (line 36, 48), cheat sheet (line 192 with dagger), keymap.json.
- **`secondary-enter`** -> `Ctrl/Cmd+Enter` (open file under cursor): Correct in cheat sheet (line 153 with dagger), keymap.json.
- **Modifier Key Reference section** in keybindings.md (lines 5-12): Correctly lists the 4 `Ctrl/Cmd` platform-adaptive bindings and the fixed-Ctrl bindings.
- **Dagger legend** in cheat sheet footer (line 18): Correctly explains the platform-adaptive symbol.
- **Sync date** in cheat sheet (line 2): Updated to 2026-04-13.

### 2. Inline Assist / Open File Conflict (Needs Fix)

**keybindings.md line 149**: Lists `Ctrl/Cmd+Enter` as "Open inline assistant" under the Inline Assist section. However, in keymap.json, `secondary-enter` is bound to `editor::OpenFile` in Editor context. This means:
- On Linux: `Ctrl+Enter` in an editor opens the file under the cursor, NOT inline assist.
- On macOS: `Cmd+Enter` in an editor opens the file under the cursor, NOT inline assist.

The inline assist default (`Ctrl+Enter` on Linux / `Cmd+Enter` on macOS) is overridden by the custom binding. The docs should note this override and clarify how to access inline assist (likely via `Ctrl/Cmd+;` or the command palette).

**cheat sheet line 217**: Lists `Ctrl+Enter` (plain, no `/Cmd`, no dagger) for "Inline assist" in the AI section. This has two problems:
  1. The notation should be `Ctrl/Cmd+Enter` since the Zed default uses Cmd on macOS.
  2. This default is overridden by the custom `secondary-enter` -> `editor::OpenFile` binding in Editor context, so inline assist via this key combo may not work.

### 3. Pre-Existing Gaps (Not Task 56 Related)

These were discovered during research but are not regressions from task 56:

- **`Alt+R` (Reload file from disk)**: Present in keymap.json (line 82) and cheat sheet (line 174) but missing from keybindings.md entirely.
- **`Ctrl/Cmd+>` ambiguity**: keybindings.md line 123 lists `Ctrl/Cmd+>` as "Add selection to thread" (Zed default), but keymap.json overrides `ctrl->` to `editor::Indent` in Editor context and nulls it in Workspace context. On Linux, `Ctrl+>` does indent, not add-to-thread. On macOS, `Cmd+>` may still work for add-to-thread since only `ctrl->` is overridden. The docs don't explain this context-dependent behavior.

## Decisions

- Focus the task 59 implementation on fixing the inline assist / open file conflict (Finding #2), as this is directly caused by the task 56 migration.
- Pre-existing gaps (Finding #3) should be noted but can be addressed separately to keep task 59 scoped to post-task-56 revisions.

## Recommendations

### Priority 1: Fix Inline Assist Documentation (Task 56 Related)

1. **keybindings.md line 149**: Change the inline assist entry to note that `Ctrl/Cmd+Enter` is overridden by the custom "Open file under cursor" binding in Editor context. Suggest `Ctrl/Cmd+;` or the command palette as alternatives for inline assist.

2. **keybindings.md Quick Reference table**: Add `Ctrl/Cmd+Enter *` for "Open file under cursor" since it is a custom binding using `secondary-enter`. Currently this binding only appears in the "Adding more shortcuts" guidance section and is not listed in any shortcut table in the guide.

3. **cheat sheet line 217**: Either:
   - (a) Change `Ctrl+Enter` to `Ctrl/Cmd+Enter` and add a note that it is overridden by the custom "Open file" binding in Editor context, OR
   - (b) Remove the inline assist `Ctrl+Enter` entry and replace with `Ctrl/Cmd+;` for inline assist (since that is not overridden).

### Priority 2: Minor Corrections (Optional, Pre-Existing)

4. **keybindings.md**: Add `Alt+R *` (Reload file from disk) to the Editing section to match the cheat sheet.

5. **keybindings.md line 123**: Clarify that `Ctrl/Cmd+>` for "Add selection to thread" is overridden by the custom `Ctrl+>` indent binding in Editor context on Linux. On macOS, `Cmd+>` may still work for this purpose.

## Appendix

### Files Examined
- `/home/benjamin/.config/zed/keymap.json` (lines 1-210)
- `/home/benjamin/.config/zed/docs/general/keybindings.md` (228 lines)
- `/home/benjamin/.config/zed/docs/general/keybindings-cheat-sheet.typ` (222 lines)
- `/home/benjamin/.config/zed/specs/056_refactor_keymap_platform_adaptive/summaries/01_platform-adaptive-keybindings-summary.md`

### Key Line References
| File | Line | Content | Issue |
|------|------|---------|-------|
| keybindings.md | 149 | `Ctrl/Cmd+Enter -- Open inline assistant` | Overridden by custom binding |
| cheat-sheet.typ | 217 | `Ctrl+Enter, Inline assist` | Wrong notation, overridden |
| cheat-sheet.typ | 153 | `Ctrl/Cmd+Enter, Open file under cursor` | Correct (with dagger) |
| keymap.json | 81 | `secondary-enter: editor::OpenFile` | Source of override |
