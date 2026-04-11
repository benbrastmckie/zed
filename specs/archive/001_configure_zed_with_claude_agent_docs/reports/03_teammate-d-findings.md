# Teammate D Findings: Keybinding Design for No-Vim-Mode Zed

**Task**: 1 - Configure Zed with Claude agent system documentation
**Role**: Horizons — Combined keybinding design, vim-mode tradeoffs, scheme presentation
**Round**: 3
**Date**: 2026-04-09

---

## Key Findings

### 1. What Neovim Bindings Should NOT Be Ported

Without vim mode, several nvim concepts become meaningless or harmful:

| Nvim Concept | Why It Doesn't Port |
|---|---|
| Space as leader key | Space leader only works in `vim_mode == normal` context. Without vim mode, space is a regular character — binding it would intercept all text input. |
| Normal/insert mode switching (`<Esc>`, `i`, `a`) | Mode switching is the entire vim model. Without vim_mode enabled, no modes exist. |
| Text objects (`ci"`, `da(`, `viw`) | Text objects require vim's modal parser. Not available in standard editor mode. |
| Vim motions (`w`, `b`, `gg`, `G`, `f`, `t`) | All vim motion keys are just characters in standard mode. |
| `<leader>iR` (rename via shift-letter sequence) | The `"space i shift-r"` chord syntax only works inside vim normal mode context. |
| `g d`, `g A`, `c d` (vim-style LSP shortcuts) | These are vim.json built-ins. Without vim mode, they're regular text characters. |
| `] b`, `[ b` (bracket buffer navigation) | Built into vim.json, not available in standard editor mode. |
| `ctrl-w h/j/k/l` (vim split nav prefix) | Vim's window command prefix. Not applicable without vim mode. |

**Summary**: The entire space-leader keymap.json block from Round 2 is designed exclusively for `vim_mode == normal`. It is **incompatible** with a no-vim-mode setup and must be replaced entirely.

### 2. What Zed Defaults Already Cover

Many nvim bindings exist because nvim lacks built-in features that Zed provides natively. These are redundant in Zed regardless of vim mode:

| Nvim Need | Zed Default Coverage |
|---|---|
| Fuzzy file finder (`<leader>ff`, `Ctrl-p`) | `Ctrl+P` → `file_finder::Toggle` (already the Linux default) |
| Project grep (`<leader>fg`) | `Ctrl+Shift+F` → `project_search::ToggleFocus` |
| File explorer (`NvimTree`, `<leader>e`) | `Ctrl+Shift+E` → `project_panel::ToggleFocus` |
| Buffer cycling (`:bn`, `:bp`) | `Alt+,` / `Alt+.` → prev/next item in Zed defaults |
| Git blame (`<leader>gl`) | `Alt+G B` → `git::Blame` |
| Save all (`<leader>w`) | `Ctrl+Alt+S` → `workspace::SaveAll` |
| Toggle terminal | `Ctrl+\`` → `terminal_panel::Toggle` (via `ctrl-grave`) |
| Go to definition (`gd`) | `F12` → `editor::GoToDefinition` |
| Hover docs (`K` in nvim) | `Ctrl+K` → contextual help / hover in Zed |

**Implication**: In a no-vim-mode setup, the user can discover many of these through Ctrl+Shift+P (command palette) or the default keymap. The custom keymap only needs to add what's genuinely missing or improve ergonomics for frequently-used features.

### 3. Agent Panel Shortcuts Are Non-Negotiable

The Claude Code agent panel shortcuts (from Round 2 research) are set by Zed and should be treated as fixed anchors around which the custom keymap is designed:

| Shortcut | Action |
|---|---|
| `Ctrl+?` | Toggle agent panel |
| `Ctrl+N` | New thread (in AgentPanel context) |
| `Ctrl+Shift+H` | Open history (in AgentPanel context) |
| `Ctrl+;` | Add context menu (in AcpThread context) |
| `Ctrl+Enter` | Chat with follow (in AcpThread context) |
| `Ctrl+Shift+Enter` | Send immediately (in AcpThread context) |
| `Ctrl+Alt+K` | Toggle thinking mode (in AcpThread context) |

These exist in specific contexts (AgentPanel, AcpThread) and will not collide with editor bindings. However, `Ctrl+Alt+K` conflicts with any `Ctrl+Alt+K` we might want for the editor if context isn't carefully specified.

### 4. Design Principles for the Combined Set

Without vim mode, the design space shifts from "modal shortcuts" to "modifier patterns":

- **Ctrl+Shift**: Panel/dock toggles (Zed's established pattern: `Ctrl+Shift+E`, `Ctrl+Shift+F`, `Ctrl+Shift+X`)
- **Ctrl+Alt**: Navigation and workspace actions (less commonly used by Zed defaults)
- **Alt**: Line-level editing operations (`Alt+J/K` for move line, `Alt+Up/Down` for defaults)
- **Ctrl**: Standard editor actions (copy, paste, find — don't override these)
- **F-keys**: LSP actions (F12 = go to definition, F2 = rename — these are standard across editors)

**Muscle memory strategy for ex-nvim user**:
- Port conceptual intent, not exact keys. `Ctrl+Shift+E` for file tree is discoverable and close enough to `<leader>e`.
- Use `Alt+J/K` for line movement (already confirmed working from Round 2).
- Accept that pane navigation requires different ergonomics — `Ctrl+H/J/K/L` can still work in `Workspace` context without vim mode.

**Collaborator compatibility**:
- Standard shortcuts (`Ctrl+S`, `Ctrl+Z`, `Ctrl+C/V/X`, `Ctrl+F`, `Ctrl+P`) must not be overridden.
- F-key LSP bindings (`F12`, `F2`) are universally known — keep them.
- Avoid exotic key combinations that would surprise a VS Code or Sublime Text user.

---

## Keybinding Scheme Options

### Scheme A: Minimal — Only Fill the Gaps

**Philosophy**: Trust Zed defaults. Only add bindings for features Zed doesn't cover well by default. Collaborator-safe — nothing surprising.

**When to choose**: Collaborator comfort is top priority; willing to learn Zed's defaults rather than port nvim habits.

```json
[
  {
    "context": "Workspace",
    "bindings": {
      "ctrl-h": "workspace::ActivatePaneLeft",
      "ctrl-j": "workspace::ActivatePaneDown",
      "ctrl-k": "workspace::ActivatePaneUp",
      "ctrl-l": "workspace::ActivatePaneRight"
    }
  },
  {
    "context": "Editor",
    "bindings": {
      "alt-j": "editor::MoveLineDown",
      "alt-k": "editor::MoveLineUp",
      "ctrl-d": "editor::SelectNextOccurrence",
      "ctrl-shift-k": "editor::DeleteLine"
    }
  }
]
```

**What's covered by Zed defaults** (no custom binding needed):
- `Ctrl+P` → file finder
- `Ctrl+Shift+F` → project search
- `Ctrl+Shift+E` → file tree
- `F12` → go to definition
- `F2` → rename
- `Ctrl+.` → code actions
- `Alt+G B` → git blame
- `Ctrl+Shift+G` → git panel
- `Ctrl+W` → close tab
- `Ctrl+Shift+\`` → new terminal

**Tradeoffs**:
- (+) Zero conflict risk with Zed defaults
- (+) Collaborator can use this setup with no retraining
- (+) Survives Zed updates — fewer custom bindings to maintain
- (-) Pane navigation still requires `Ctrl+H/J/K/L` (added above — one non-default set)
- (-) Ex-nvim user must unlearn space-leader; no conceptual mapping to prior habits
- (-) `Alt+G B` for git blame is awkward (multi-key sequence with modifiers)

**Verdict**: Safe but low ergonomic payoff for the primary user.

---

### Scheme B: Power User — Port All Useful Nvim Concepts

**Philosophy**: Use `Ctrl+K` as a prefix (Zed's built-in chord prefix for commands) to create a leader-key-like experience without vim mode. This mirrors VS Code's `Ctrl+K` prefix pattern, which is familiar to many developers.

**When to choose**: Primary user productivity is top priority; collaborator has moderate experience with code editors.

**Note on `Ctrl+K` prefix**: Zed already uses `Ctrl+K` for some built-ins (e.g., `Ctrl+K Ctrl+C` for comment in some configs). Test for conflicts. Alternatively, `Ctrl+Alt` prefix is safer.

```json
[
  {
    "context": "Workspace",
    "bindings": {
      "ctrl-h": "workspace::ActivatePaneLeft",
      "ctrl-j": "workspace::ActivatePaneDown",
      "ctrl-k": "workspace::ActivatePaneUp",
      "ctrl-l": "workspace::ActivatePaneRight",
      "ctrl-shift-t": "workspace::ToggleBottomDock"
    }
  },
  {
    "context": "Editor",
    "bindings": {
      "alt-j": "editor::MoveLineDown",
      "alt-k": "editor::MoveLineUp",
      "ctrl-d": "editor::SelectNextOccurrence",
      "ctrl-shift-k": "editor::DeleteLine",
      "ctrl-shift-b": "tab_switcher::Toggle",
      "ctrl-alt-b": "git::Blame",
      "ctrl-alt-g": "git_panel::ToggleFocus",
      "ctrl-alt-e": "project_panel::ToggleFocus",
      "ctrl-alt-f": "project_search::ToggleFocus",
      "ctrl-alt-c": "pane::SplitRight",
      "ctrl-alt-w": "pane::CloseActiveItem",
      "ctrl-alt-d": "editor::GoToDefinition",
      "ctrl-alt-r": "editor::FindAllReferences",
      "ctrl-alt-n": "editor::Rename",
      "ctrl-alt-a": "editor::ToggleCodeActions",
      "ctrl-alt-i": "editor::Hover"
    }
  }
]
```

**Conceptual mapping from nvim**:
| Nvim | Scheme B | Same action |
|---|---|---|
| `<leader>e` | `Ctrl+Alt+E` | Toggle file tree |
| `<leader>ff` | `Ctrl+Alt+F` | Project search |
| `<leader>fb` | `Ctrl+Shift+B` | Buffer/tab switcher |
| `<leader>gl` | `Ctrl+Alt+B` | Git blame |
| `<leader>gg` | `Ctrl+Alt+G` | Git panel |
| `<leader>c` | `Ctrl+Alt+C` | Split right |
| `<leader>k` | `Ctrl+Alt+W` | Close active tab |
| `<leader>id` | `Ctrl+Alt+D` | Go to definition |
| `<leader>ir` | `Ctrl+Alt+R` | Find all references |
| `<leader>iR` | `Ctrl+Alt+N` | Rename (N for "name") |
| `<leader>ic` | `Ctrl+Alt+A` | Code actions |
| `<leader>il` | `Ctrl+Alt+I` | Hover/info |

**Tradeoffs**:
- (+) Near-complete port of nvim workflow concepts
- (+) All shortcuts are explicit and muscle-memory-buildable
- (+) `Ctrl+Alt+*` is unlikely to conflict with Zed defaults (Zed uses this prefix sparingly)
- (-) Collaborator must learn a new system — `Ctrl+Alt+D` for definition is non-standard (F12 is the norm)
- (-) Two concurrent mental models: Zed defaults AND these custom bindings
- (-) `ctrl-k` in Workspace context conflicts with Zed's potential `Ctrl+K` command prefix usage — needs testing
- (-) The `ctrl-k` upward navigation binding is risky in `Workspace` context; `Ctrl+K` may be intercepted as chord prefix

**Verdict**: High ergonomic payoff for primary user, moderate retraining cost for collaborator.

---

### Scheme C: Balanced — Best of Both

**Philosophy**: Keep all Zed defaults (collaborator-friendly). Add only the bindings where the default is genuinely ergonomically poor or missing. Use `Alt` and `Ctrl+Alt` sparingly for the highest-value additions. Preserve pane navigation (`Ctrl+H/J/K/L`) as the one major override.

**When to choose**: Both users matter; primary user accepts partial nvim habit adjustment.

```json
[
  {
    "context": "Workspace",
    "bindings": {
      "ctrl-h": "workspace::ActivatePaneLeft",
      "ctrl-j": "workspace::ActivatePaneDown",
      "ctrl-k": "workspace::ActivatePaneUp",
      "ctrl-l": "workspace::ActivatePaneRight",
      "ctrl-shift-t": "workspace::ToggleBottomDock"
    }
  },
  {
    "context": "Editor",
    "bindings": {
      "alt-j": "editor::MoveLineDown",
      "alt-k": "editor::MoveLineUp",
      "ctrl-d": "editor::SelectNextOccurrence",
      "ctrl-shift-k": "editor::DeleteLine",
      "ctrl-shift-b": "tab_switcher::Toggle",
      "ctrl-alt-b": "git::Blame",
      "ctrl-alt-g": "git_panel::ToggleFocus"
    }
  }
]
```

**Reasoning for each binding**:
| Binding | Why Include | Alternative Default |
|---|---|---|
| `Ctrl+H/J/K/L` | Pane navigation is daily-driver; `Ctrl+W W` cycling is poor | None in Zed by default |
| `Ctrl+Shift+T` | Toggle terminal; `Ctrl+\`` is hard to type | `Ctrl+\`` |
| `Alt+J/K` | Line movement is frequent; no default | None in Zed by default |
| `Ctrl+D` | Multi-cursor next occurrence; maps to Ctrl+D muscle memory | `Ctrl+D` may already do this |
| `Ctrl+Shift+K` | Delete line; universal across editors (VS Code uses this) | No default |
| `Ctrl+Shift+B` | Tab/buffer switcher; faster than mouse click on tabs | None |
| `Ctrl+Alt+B` | Git blame; `Alt+G B` default is awkward, daily use | `Alt+G B` |
| `Ctrl+Alt+G` | Git panel; `Ctrl+Shift+G` default conflicts with selection | `Ctrl+Shift+G` |

**What stays at Zed defaults** (not overridden):
- `Ctrl+P` → file finder (already great)
- `Ctrl+Shift+F` → project search (already great)
- `Ctrl+Shift+E` → file tree (already great)
- `F12` → go to definition (universal standard)
- `F2` → rename (universal standard)
- `Ctrl+.` → code actions (universal standard)
- `Ctrl+W` → close tab (standard)

**Tradeoffs**:
- (+) Collaborator can use ~90% of standard editor muscle memory
- (+) Highest-value nvim habits preserved (pane nav, line move, git blame)
- (+) No exotic modifier combos — all additions are discoverable patterns
- (-) LSP actions (definition, rename, code actions) stay at F-key defaults — primary user must adapt
- (-) No single-key leader pattern for quick workflows

**Verdict**: Best balance for the stated goal — collaborator-safe, primary-user-ergonomic for the most frequent actions.

---

## Plan Impact Assessment

The current plan (Phase 1) assumes `vim_mode: true` in settings.json and a space-leader keymap.json. Switching to no-vim-mode requires the following changes:

### settings.json Changes

**Remove entirely**:
```json
"vim_mode": true,
"vim": {
  "default_mode": "normal",
  "use_system_clipboard": "always",
  "toggle_relative_line_numbers": true,
  "use_smartcase_find": true
},
"relative_line_numbers": true,
```

**Net result**: Smaller settings.json. No vim block needed.

### keymap.json Changes

**Replace entirely**. The Round 2 keymap.json is 100% vim-mode-dependent:
- The `"Editor && vim_mode == normal"` context block is inert without vim mode — bindings never activate
- The `"space e"`, `"space f f"`, etc. patterns are meaningless without the vim parser

The replacement is one of Scheme A, B, or C above. All three are shorter than the Round 2 keymap.

**No context blocks needed for**: `Editor && vim_mode == normal`, `VimControl`, or any vim-specific context.

### docs/settings.md Changes

The settings documentation needs a different explanation:
- **Remove**: vim_mode section, vim options section, explanation of normal mode context
- **Add**: "Why no vim mode" rationale (collaborator-friendly choice)
- **Add**: Modifier pattern guide (Ctrl+Shift for panels, Ctrl+Alt for custom actions, Alt for editing)
- **Change**: Keybinding section from "space-leader porting" to "Zed-native ergonomics"
- **Smaller scope**: Settings.md loses ~40 lines of vim explanation; gains ~20 lines of modifier pattern explanation

### README.md Changes

- **Remove**: "Vim mode note for collaborators" caveat
- **Remove**: Quick start step about vim mode
- **Simpler**: Onboarding story is just "open Zed, use standard shortcuts"

### .claude/context/repo/project-overview.md Changes

- No mention of vim mode needed
- Description of keybinding philosophy becomes "standard editor shortcuts with ergonomic additions"

### Risks Introduced by Removing Vim Mode

| Risk | Severity | Mitigation |
|---|---|---|
| Primary user must relearn 5-10 frequent shortcuts | Medium | Scheme C minimizes this by preserving most-used bindings |
| `Ctrl+H` in Workspace context may still intercept backspace-style behavior in some panels | Low | Context specificity prevents this — `Workspace` context won't fire in text inputs |
| `Ctrl+K` for pane-up conflicts with Zed chord prefix | Medium | Test at launch; fallback to `Ctrl+Alt+Up` if needed |
| Tab/Shift-Tab vim conflict (noted in Round 2) | Gone | Removing vim mode eliminates this risk entirely |
| `space i shift-r` chord (noted as unverified) | Gone | Not ported to no-vim-mode schemes |

**Net risk**: Removing vim mode reduces implementation risk (fewer conflict scenarios). The Tab/Shift-Tab and `space i shift-r` issues from Round 2 disappear.

---

## Recommended Approach

**Adopt Scheme C (Balanced)** with one modification: keep `Ctrl+K` for upward pane navigation but add a fallback comment noting it may need replacement if Zed's chord prefix intercepts it.

**Rationale**:
1. The stated requirement "collaborator will also use this setup" makes vim mode off the correct choice. The plan should reflect this from the start, not add a caveat.
2. Scheme C preserves the most ergonomically valuable nvim habits (pane navigation, line movement, git blame) without requiring collaborator retraining on unfamiliar patterns.
3. The F-key LSP bindings (F12, F2, Ctrl+.) are universal — no muscle memory cost for either user.
4. Implementation is simpler and lower risk than the Round 2 vim-mode approach: fewer bindings, no vim context blocks, no unverified chord syntax.

**Implementation for Phase 1 (revised)**:

settings.json: remove vim_mode and vim block, keep everything else from Round 2 as-is.

keymap.json: use Scheme C (8 bindings total across 2 context blocks).

tasks.json: unchanged from Round 2 — no vim mode dependency.

**What the implementer should verify at first launch**:
1. `Ctrl+K` upward pane navigation — does Zed intercept it as a chord prefix?
2. `Ctrl+Alt+B` for git blame — does it activate?
3. `Ctrl+D` — does it do SelectNextOccurrence or something else by default?
4. `Alt+J/K` for line movement — confirms from Round 2 but worth verifying without vim mode

---

## Confidence Level

| Finding | Confidence |
|---|---|
| Space-leader bindings incompatible without vim mode | High — documented by Zed and confirmed in Round 2 |
| Zed default coverage of nvim needs | High — verified action names from Round 2 |
| `Ctrl+Alt+*` safe from conflicts | Medium — not all Zed defaults checked; low-use prefix by convention |
| `Ctrl+K` pane-up risk | Medium — Zed may reserve this as chord prefix; needs live test |
| Scheme C balance judgment | Medium — based on stated requirements; actual preference may differ after hands-on use |
| F12/F2 muscle memory acceptable | Medium — primary user has nvim habits; may prefer alternative mappings |
