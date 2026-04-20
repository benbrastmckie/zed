# Research Report: Task #76 -- Zed Keybindings macOS Troubleshooting

**Task**: 76 - Troubleshoot Zed keybindings on macOS and update cheat sheet
**Date**: 2026-04-19
**Mode**: Team Research (4 teammates)
**Session**: sess_1745107958_team76

## Summary

Three root causes explain the reported keybinding failures, and the cheat sheet has a systematic accuracy problem affecting 20+ entries. The current `ctrl-` modifier strategy is largely correct and should be preserved, with targeted fixes for the specific bugs reported.

## Key Findings

### 1. Root Cause: `ctrl+shift+a` Only Works with PDF Open (CRITICAL)

**Diagnosis**: Vim mode context conflict.

`settings.json` has `"vim_mode": true`. Zed's vim keymap binds `ctrl-shift-a` to `assistant::InlineAssist` in the `vim_mode == insert` context. When editing a `.typ` file (Editor context with vim mode active), the vim binding fires at the Editor level, which takes precedence over the Workspace-level `task::Spawn` binding. When the PDF viewer is focused (not an Editor context), the Workspace binding fires correctly.

**Fix**: Add `"ctrl-shift-a": ["task::Spawn", { "task_name": "Claude Code" }]` to the existing Editor context block in keymap.json. This matches the existing pattern where `ctrl-h`, `ctrl-l`, etc. are already duplicated in the Editor block to shadow Zed defaults.

### 2. Root Cause: `cmd+shift+c` (CopyPath) Inconsistency (HIGH)

**Diagnosis**: The `secondary-shift-c` binding only exists in the `Editor` context (line 77 of keymap.json). It does not fire from Workspace, Terminal, ProjectPanel, or AgentPanel contexts. Additionally, Zed's default `cmd+shift+c` maps to `collab_panel::ToggleFocus`, which may intercept in some contexts.

**Fix**: Add `"secondary-shift-c": "workspace::CopyPath"` to the Workspace context block so it works regardless of focus.

### 3. Root Cause: vim_mode Contradiction (HIGH)

**Diagnosis**: `settings.json` line 4 says "No vim mode" but line 5 has `"vim_mode": true`. The keymap.json comments and cheat sheet both say "off by default." This is actively misleading and causes:
- `ctrl-o` and `ctrl-i` custom bindings to be **redundant** (vim mode already provides identical `pane::GoBack`/`pane::GoForward`)
- `ctrl-h` to conflict with `editor::Backspace` in vim insert mode
- `ctrl-q` to conflict with `vim::ToggleVisualBlock` in vim normal mode
- `ctrl-shift-a` to be shadowed by `assistant::InlineAssist` in vim insert mode (the reported bug)

**Fix**: Either update the comment to match reality, or set `"vim_mode": false` if it was unintentionally enabled.

### 4. Cheat Sheet Systematically Wrong for macOS (CRITICAL)

The cheat sheet shows `Ctrl` for 20+ Zed default shortcuts that are actually `Cmd` on macOS. Examples:

| Cheat Sheet Shows | Actual macOS Key | Action |
|-------------------|------------------|--------|
| `Ctrl+P` | `Cmd+P` | Open file by name |
| `Ctrl+S` | `Cmd+S` | Save file |
| `Ctrl+Z` | `Cmd+Z` | Undo |
| `Ctrl+C/X/V` | `Cmd+C/X/V` | Copy/Cut/Paste |
| `Ctrl+Shift+P` | `Cmd+Shift+P` | Command palette |
| `Ctrl+F` | `Cmd+F` | Find in file |
| `Ctrl+B` | `Cmd+B` | Toggle sidebar |
| ...and 12+ more | | |

The footer says "Ctrl = fixed on all platforms" which is only true for the 8 custom `ctrl-` bindings, not the Zed defaults.

**Fix**: Replace all Zed-default `Ctrl` with `Cmd` in the cheat sheet. Keep `Ctrl` only for the custom bindings that explicitly use `ctrl-` in keymap.json.

### 5. Per-Binding ctrl→cmd Migration Analysis

| Binding | Current | Can Use cmd? | Blocker | Recommendation |
|---------|---------|-------------|---------|----------------|
| Pane left | `ctrl-h` | **NO** | Cmd+H = macOS Hide App (system-level, intercepted before Zed) | **Keep ctrl-h** |
| Pane right | `ctrl-l` | Risky | Cmd+L = Zed `editor::SelectLine` | **Keep ctrl-l** (losing SelectLine is high cost) |
| Jump back | `ctrl-o` | **NO** | Cmd+O = Zed `workspace::Open` (file dialog) | **Keep ctrl-o** (also vim convention) |
| Jump forward | `ctrl-i` | Risky | Cmd+I = Zed `editor::ShowSignatureHelp` | **Keep ctrl-i** (also vim convention) |
| Close tab | `ctrl-q` | **NO** | Cmd+Q = macOS Quit App | **Keep ctrl-q** |
| Claude Code | `ctrl-shift-a` | Maybe | Cmd+Shift+A = macOS Tahoe "Show Apps" (new in macOS 26) | **Keep ctrl-shift-a**, fix via Editor context override |
| Copy path | `secondary-shift-c` | Already cmd | N/A | **Broaden to Workspace context** |
| Indent/Outdent | `ctrl->` / `ctrl-<` | Unnecessary | Zed already has `Cmd+]` / `Cmd+[` | **Consider removing** (redundant) |

**Conclusion**: None of the current `ctrl-` bindings can safely become `cmd-`/`secondary-`. The original rationale for using `ctrl-` is sound.

### 6. macOS System Shortcuts Reference

**Truly system-reserved (cannot override)**:
- `Cmd+H` — Hide application
- `Cmd+Q` — Quit application
- `Cmd+Tab` — Switch applications
- `Cmd+M` — Minimize window

**Safe to remap via System Settings > Keyboard > Shortcuts**:
- `Cmd+Space` (Spotlight)
- `Cmd+Shift+A` (Show Apps — macOS Tahoe only)
- `Shift+Cmd+3/4/5` (Screenshots)

**Cmd+H workaround** (if ever needed): System Settings > Keyboard > App Shortcuts > add "Zed" > Menu Title "Hide Zed" > reassign to obscure combo. Not recommended — breaks cross-app muscle memory.

### 7. Modifier Decision Framework

```
Need Cmd on macOS?
├── YES → Cmd+key collides with FATAL macOS default?
│   ├── YES → Use ctrl- (fixed). Document why.
│   └── NO → Cmd+key collides with USEFUL Zed default?
│       ├── YES → Your action more valuable? → secondary- (override)
│       │                                   → ctrl- or alt- (avoid)
│       └── NO → Use secondary- (platform-adaptive)
└── NO → Vim/terminal convention? → ctrl- (muscle memory)
                                  → alt- (non-conflicting)
```

## Synthesis

### Conflicts Resolved

1. **Teammate A vs C on ctrl-shift-a fix**: Both agree the Editor context override is the simplest fix. Teammate A additionally suggested switching to `secondary-shift-a`, but Teammate B identified that Cmd+Shift+A conflicts with macOS Tahoe's new "Show Apps" system shortcut. **Resolution**: Keep `ctrl-shift-a` with Editor context override.

2. **Teammate A vs D on cheat sheet approach**: Teammate A focused on correcting modifier labels; Teammate D proposed a platform-variable system in Typst. **Resolution**: Both are needed — correct the labels first (immediate fix), consider the Typst variable approach for maintainability (plan phase).

### Gaps Identified

1. **vim_mode intent unclear**: The user needs to decide whether vim_mode should be `true` or `false`. If true, several custom bindings are redundant. If false, the ctrl-shift-a bug may resolve differently.

2. **Typst extension keybindings**: Not investigated — the Typst language server (tinymist) may register its own keybindings that could conflict.

3. **`(verify)` entries**: The keymap.json reference section has ~10 entries marked `(verify)` that have not been confirmed against actual Zed macOS defaults.

4. **`secondary-?` semantics**: Maps to `workspace::ToggleRightDock` vs Zed's default `agent::ToggleFocus`. These are different actions — the user should verify the behavior matches their intent.

### Recommendations

**Immediate fixes (keymap.json)**:
1. Add `ctrl-shift-a` to Editor context block
2. Add `secondary-shift-c` to Workspace context block
3. Fix `settings.json` vim_mode comment (or disable vim_mode)

**Cheat sheet fixes**:
4. Replace all Zed-default `Ctrl` with `Cmd` for macOS
5. Keep `Ctrl` only for the 8 custom `ctrl-` bindings
6. Update footer legend to clarify the distinction
7. Fix "vim mode (off by default)" label

**Optional improvements**:
8. Remove `ctrl->` / `ctrl-<` indent/outdent (redundant with `Cmd+]`/`Cmd+[`)
9. Remove redundant `ctrl-o`/`ctrl-i` if vim_mode stays enabled
10. Add drift-detection script for keymap.json ↔ documentation sync

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary binding analysis | completed | high | Root cause diagnosis for both reported bugs; per-binding migration table |
| B | macOS defaults & Zed architecture | completed | high | Comprehensive macOS system shortcut reference; `secondary-` modifier analysis; Tahoe Cmd+Shift+A warning |
| C | Critic | completed | high | vim_mode contradiction discovery; cheat sheet systematic error identification; terminal passthrough risk |
| D | Strategic horizons | completed | high | Modifier decision framework; documentation single-sourcing strategy; binding budget analysis; chord scalability |

## References

- [Mac keyboard shortcuts - Apple Support](https://support.apple.com/en-us/102650)
- [Zed Key Bindings Documentation](https://zed.dev/docs/key-bindings)
- [Zed default-macos.json](https://github.com/zed-industries/zed/blob/main/assets/keymaps/default-macos.json)
- [Zed vim.json](https://github.com/zed-industries/zed/blob/main/assets/keymaps/vim.json)
- [PR #26390: secondary modifier](https://github.com/zed-industries/zed/pull/26390)
- [Zed Vim Mode docs](https://zed.dev/docs/vim)
- Teammate findings: `01_teammate-{a,b,c,d}-findings.md`
