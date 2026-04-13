# Research Report: Task #56

**Task**: 56 - Refactor keymap.json to use Zed's `secondary-` modifier for platform-adaptive keybindings
**Started**: 2026-04-13T00:00:00Z
**Completed**: 2026-04-13T00:30:00Z
**Effort**: small-medium
**Dependencies**: None
**Sources/Inputs**:
- Codebase: `keymap.json`, `docs/general/keybindings.md`, `docs/general/keybindings-cheat-sheet.typ`
- Zed official documentation: https://zed.dev/docs/key-bindings
- Zed source: `default-macos.json`, `default-linux.json` (GitHub)
- Zed docs source: https://github.com/zed-industries/zed/blob/main/docs/src/key-bindings.md
**Artifacts**:
- `specs/056_refactor_keymap_platform_adaptive/reports/01_platform-adaptive-keybindings.md`
**Standards**: report-format.md, artifact-management.md, tasks.md

## Executive Summary

- Zed officially supports `secondary-` as a modifier prefix: it maps to `cmd` on macOS and `ctrl` on Linux/Windows, enabling single-definition cross-platform keybindings.
- Of the 17 custom bindings, **7 can safely adopt `secondary-`** with no collision risk, **5 have serious collisions** with macOS defaults that would break core functionality, and **5 use `alt-` modifiers that are unaffected** by this refactor.
- The critical collisions are: `secondary-q` (Quit), `secondary-h` (Hide app), `secondary-o` (Open files dialog), `secondary-l` (SelectLine), and `secondary-i` (ShowSignatureHelp) -- these must remain as `ctrl-` on all platforms.
- The documentation files (`keybindings.md`, `keybindings-cheat-sheet.typ`) currently use macOS-centric "Cmd" notation; they should be updated to use platform-neutral language (e.g., "Secondary" or "Ctrl/Cmd") to match the cross-platform keymap.
- The `ctrl->` / `ctrl-<` indent/outdent bindings and their null-out overrides collide with Zed's `agent::AddSelectionToThread` default and should remain as `ctrl-` with explicit overrides rather than using `secondary-`.

## Context & Scope

The current `keymap.json` contains 17 unique custom bindings (26 entries across contexts). All use explicit `ctrl-` or `alt-` modifiers. The task description asks to audit these bindings for migration to `secondary-` to achieve platform-adaptive behavior, with a particular focus on avoiding collisions with Zed's built-in macOS `cmd-` shortcuts.

### What is `secondary-`?

From Zed's official key-bindings documentation:

> `secondary-` Equivalent to `cmd` when Zed is running on macOS and `ctrl` when on Windows and Linux.

This means `"secondary-s"` in keymap.json would resolve to `Cmd+S` on macOS and `Ctrl+S` on Linux/Windows. It is a syntactic convenience -- no runtime overhead, resolved at keymap load time.

### Current Behavior

The existing keymap uses `ctrl-` for all non-Alt bindings. The header comment explicitly states: "All custom bindings intentionally use Ctrl+ (not Cmd+) on macOS so they do not collide with Zed's built-in Cmd+ shortcuts." This was a deliberate design choice to avoid the collision problem that `secondary-` would reintroduce on macOS.

## Findings

### Complete Binding Inventory

The 17 custom bindings, their current keys, and collision analysis:

| # | Key | Action | Contexts | Can use `secondary-`? | Collision on macOS |
|---|-----|--------|----------|----------------------|-------------------|
| 1 | `ctrl-h` | ActivatePaneLeft | Workspace, Editor | **NO** | `cmd-h` = `zed::Hide` (hides app) |
| 2 | `ctrl-l` | ActivatePaneRight | Workspace, Editor | **NO** | `cmd-l` = `editor::SelectLine` |
| 3 | `ctrl-?` | ToggleRightDock | Workspace | **YES** (already `cmd-?` = `agent::ToggleFocus`) | Acceptable override -- same panel area |
| 4 | `ctrl-shift-e` | ToggleLeftDock | Workspace, Editor | **YES** | `cmd-shift-e` = `project_panel::ToggleFocus` (same intent) |
| 5 | `ctrl-shift-a` | task::Spawn Claude Code | Workspace, Terminal | **RISKY** | `cmd-shift-a` = `file_finder::ToggleSplitMenu` / `editor::SelectAll` (Terminal) |
| 6 | `ctrl-q` | CloseActiveItem | Workspace, Editor | **NO** | `cmd-q` = `zed::Quit` (quits entire app) |
| 7 | `ctrl-o` | pane::GoBack | Workspace, Editor | **NO** | `cmd-o` = `workspace::Open` (file open dialog) |
| 8 | `ctrl-i` | pane::GoForward | Workspace, Editor | **NO** | `cmd-i` = `editor::ShowSignatureHelp` / `agent::ToggleProfileSelector` |
| 9 | `alt-v` | ToggleVimMode | Workspace | N/A | Alt bindings unaffected |
| 10 | `alt-j` | MoveLineDown | Editor | N/A | Alt bindings unaffected |
| 11 | `alt-k` | MoveLineUp | Editor | N/A | Alt bindings unaffected |
| 12 | `ctrl-shift-c` | CopyPath | Editor | **YES** | `cmd-shift-c` = `collab_panel::ToggleFocus` (minor -- collab panel rarely used) |
| 13 | `alt-shift-e` | Build PDF task | Editor | N/A | Alt bindings unaffected |
| 14 | `alt-shift-p` | Preview in Browser task | Editor | N/A | Alt bindings unaffected |
| 15 | `ctrl-enter` | editor::OpenFile | Editor | **YES** | `cmd-enter` = `editor::NewlineBelow` in Editor (acceptable -- custom override) |
| 16 | `alt-r` | editor::ReloadFile | Editor | N/A | Alt bindings unaffected |
| 17 | `ctrl->` / `ctrl-<` | Indent/Outdent | Editor, Workspace | **NO** | `cmd->` = `agent::AddSelectionToThread` (important AI feature) |

### Collision Severity Classification

**FATAL (must not use `secondary-`):**

1. **`ctrl-q` -> `secondary-q`**: Would map to `Cmd+Q` on macOS = quit the entire application. Absolutely cannot migrate.
2. **`ctrl-h` -> `secondary-h`**: Would map to `Cmd+H` on macOS = hide the application window. Breaks pane navigation.
3. **`ctrl-o` -> `secondary-o`**: Would map to `Cmd+O` on macOS = Open files dialog. Breaks jump-list back navigation.

**SERIOUS (should not use `secondary-`):**

4. **`ctrl-l` -> `secondary-l`**: Would map to `Cmd+L` on macOS = `editor::SelectLine`. Overriding this loses a useful default.
5. **`ctrl-i` -> `secondary-i`**: Would map to `Cmd+I` on macOS = `editor::ShowSignatureHelp`. Overriding loses LSP signature help.
6. **`ctrl->` -> `secondary->`**: Would map to `Cmd+>` on macOS = `agent::AddSelectionToThread`. The current override already handles this with null-out entries; `secondary-` would make it worse by needing platform-conditional null-outs.

**RISKY (migration possible but loses existing functionality):**

7. **`ctrl-shift-a` -> `secondary-shift-a`**: Loses `file_finder::ToggleSplitMenu` and Terminal `editor::SelectAll`. The Claude Code launcher is used frequently enough that this may be acceptable, but Select All in terminal is a meaningful loss.

**SAFE (can migrate to `secondary-`):**

8. **`ctrl-?` -> `secondary-?`**: macOS default `cmd-?` = `agent::ToggleFocus`. Our binding does `workspace::ToggleRightDock` which serves the same purpose (the agent panel lives in the right dock). This is an intentional override of the same UI area.
9. **`ctrl-shift-e` -> `secondary-shift-e`**: macOS default `cmd-shift-e` = `project_panel::ToggleFocus`. Our binding does `workspace::ToggleLeftDock` which is functionally similar (project panel is in the left dock). Acceptable override.
10. **`ctrl-shift-c` -> `secondary-shift-c`**: macOS default `cmd-shift-c` = `collab_panel::ToggleFocus`. The collab panel is rarely used; copy-path is more valuable. Acceptable override.
11. **`ctrl-enter` -> `secondary-enter`**: macOS default `cmd-enter` in Editor = `editor::NewlineBelow`. This is a minor loss; `OpenFile` under cursor is more useful in our workflow. Acceptable override.

### Bindings Unaffected by This Refactor

Five bindings use `alt-` modifier and are not candidates for `secondary-`:
- `alt-v` (ToggleVimMode)
- `alt-j` (MoveLineDown)
- `alt-k` (MoveLineUp)
- `alt-shift-e` (Build PDF)
- `alt-shift-p` (Preview in Browser)
- `alt-r` (ReloadFile)

One additional binding uses bare keys in ProjectPanel context (h/j/k/l) and is also unaffected.

### Documentation Impact

**`docs/general/keybindings.md`**:
- Currently written with macOS-first "Cmd" notation (line 1: "This guide assumes macOS")
- Custom bindings shown as `Ctrl+` (e.g., `Ctrl+O *`, `Ctrl+I *`)
- Zed defaults shown as `Cmd+` (e.g., `Cmd+P`, `Cmd+S`)
- After migration: bindings that use `secondary-` should be documented as `Ctrl/Cmd+` or with a platform note
- Bindings that remain `ctrl-` should be clearly marked as Ctrl on all platforms

**`docs/general/keybindings-cheat-sheet.typ`**:
- Footer says "Linux notation. On macOS, substitute Cmd for Ctrl."
- Uses `key-combo("Ctrl", ...)` for everything
- After migration: `secondary-` bindings should use a different label (e.g., `key-combo("Sec", ...)` or continue using `Ctrl` with an updated footer note)
- Alternatively, keep the Linux-first notation and update the footer to distinguish "Ctrl (all platforms)" from "Ctrl/Cmd (platform-adaptive)"

## Decisions

1. **Only 4 bindings should migrate to `secondary-`**: `ctrl-?`, `ctrl-shift-e`, `ctrl-shift-c`, and `ctrl-enter`. These have acceptable or beneficial collision profiles on macOS.
2. **10 `ctrl-` bindings must remain as `ctrl-`**: The 5 with fatal/serious collisions (`ctrl-h`, `ctrl-l`, `ctrl-o`, `ctrl-i`, `ctrl-q`) and the `ctrl->` / `ctrl-<` pair (plus their null-out overrides) must stay platform-explicit.
3. **5 `alt-` bindings are unchanged**: They use a different modifier and are not part of this refactor.
4. **`ctrl-shift-a` should remain as `ctrl-`**: The loss of Terminal Select All is not worth the cross-platform benefit, and the binding already works identically on both platforms with `ctrl-`.
5. **Documentation should adopt platform-neutral notation**: Rather than "macOS-first" or "Linux-first", use a notation that distinguishes platform-adaptive bindings from platform-fixed ones.

## Recommendations

### Priority 1: Migrate Safe Bindings to `secondary-`

Update `keymap.json` to change these 4 bindings:

| Current | New | Notes |
|---------|-----|-------|
| `ctrl-?` | `secondary-?` | Workspace context |
| `ctrl-shift-e` | `secondary-shift-e` | Workspace + Editor contexts |
| `ctrl-shift-c` | `secondary-shift-c` | Editor context |
| `ctrl-enter` | `secondary-enter` | Editor context |

### Priority 2: Update Header Comment

Revise the `keymap.json` header comment block (lines 1-27) to:
- Explain the `secondary-` modifier and its platform mapping
- Categorize bindings into `secondary-` (platform-adaptive) and `ctrl-` (fixed) groups
- Remove the blanket statement "All custom bindings intentionally use Ctrl+"
- Document why specific bindings cannot use `secondary-`

### Priority 3: Update `docs/general/keybindings.md`

- Change the opening line from "This guide assumes macOS" to a platform-neutral introduction
- For `secondary-` bindings, show as "Ctrl+/Cmd+" or use a platform-adaptive notation
- For `ctrl-` bindings, explicitly note they are Ctrl on all platforms (including macOS)
- Add a brief section explaining the two modifier categories

### Priority 4: Update `docs/general/keybindings-cheat-sheet.typ`

- Update the footer legend to explain both modifier types
- Consider adding a visual indicator (e.g., different fill color) for platform-adaptive vs fixed bindings
- Update the relevant `key-combo()` calls for migrated bindings

### Priority 5: Review and Simplify Null-Out Entries

The `ctrl->` / `ctrl-<` null-out entries in Workspace and `Editor && mode == full` contexts should remain unchanged since these bindings stay as `ctrl-`. No simplification is possible here.

## Risks & Mitigations

| Risk | Severity | Mitigation |
|------|----------|------------|
| `secondary-?` override loses `agent::ToggleFocus` on macOS | Low | `ToggleRightDock` exposes the same panel; functionally equivalent |
| `secondary-shift-e` override loses `project_panel::ToggleFocus` on macOS | Low | `ToggleLeftDock` serves same purpose (project panel is in left dock) |
| `secondary-shift-c` override loses `collab_panel::ToggleFocus` on macOS | Very Low | Collab panel seldom used; CopyPath is higher value |
| `secondary-enter` override loses `editor::NewlineBelow` on macOS | Low | Users can use `o` in vim mode or Enter at end of line |
| Documentation confusion between two modifier categories | Medium | Clear legend/footnote in all docs; consistent notation |
| Future Zed updates change default bindings | Medium | Pin review to Zed version; re-audit on major updates |

## Appendix

### Search Queries Used
- `Zed editor "secondary-" modifier keymap platform adaptive keybindings`
- `Zed editor keymap.json secondary modifier ctrl cmd cross-platform`
- `site:github.com zed-industries/zed "secondary-" keymap modifier`

### Documentation References
- [Zed Key Bindings Documentation](https://zed.dev/docs/key-bindings)
- [Zed default-macos.json](https://github.com/zed-industries/zed/blob/main/assets/keymaps/default-macos.json)
- [Zed default-linux.json](https://github.com/zed-industries/zed/blob/main/assets/keymaps/default-linux.json)
- [Zed docs source (key-bindings.md)](https://github.com/zed-industries/zed/blob/main/docs/src/key-bindings.md)

### macOS Default Collision Reference

| Key Combo (macOS) | Zed Default Action | Our Custom Action | Collision? |
|---|---|---|---|
| `cmd-h` | `zed::Hide` | ActivatePaneLeft | FATAL |
| `cmd-l` | `editor::SelectLine` | ActivatePaneRight | SERIOUS |
| `cmd-o` | `workspace::Open` | pane::GoBack | FATAL |
| `cmd-i` | `editor::ShowSignatureHelp` | pane::GoForward | SERIOUS |
| `cmd-q` | `zed::Quit` | pane::CloseActiveItem | FATAL |
| `cmd-?` | `agent::ToggleFocus` | ToggleRightDock | Acceptable |
| `cmd-shift-e` | `project_panel::ToggleFocus` | ToggleLeftDock | Acceptable |
| `cmd-shift-a` | Split menu / SelectAll | task::Spawn Claude Code | Risky |
| `cmd-shift-c` | `collab_panel::ToggleFocus` | CopyPath | Acceptable |
| `cmd-enter` | `editor::NewlineBelow` | editor::OpenFile | Acceptable |
| `cmd->` | `agent::AddSelectionToThread` | editor::Indent | SERIOUS |

### Linux Default Override Reference

| Key Combo | Zed Linux Default | Our Custom Action | Status |
|---|---|---|---|
| `ctrl-h` | `search::ToggleReplace` (BufferSearchBar) | ActivatePaneLeft | Already overriding |
| `ctrl-l` | `editor::SelectLine` | ActivatePaneRight | Already overriding |
| `ctrl-o` | `workspace::OpenFiles` | pane::GoBack | Already overriding |
| `ctrl-i` | `editor::ShowSignatureHelp` | pane::GoForward | Already overriding |
| `ctrl-q` | `zed::Quit` | pane::CloseActiveItem | Already overriding |
| `ctrl-shift-e` | `project_panel::ToggleFocus` | ToggleLeftDock | Already overriding (similar intent) |
| `ctrl-shift-c` | `terminal::Copy` (Terminal) | CopyPath | Already overriding |
| `ctrl-enter` | Various context-dependent | editor::OpenFile | Already overriding |
| `ctrl->` | `agent::AddSelectionToThread` | editor::Indent | Already overriding (with null-outs) |
