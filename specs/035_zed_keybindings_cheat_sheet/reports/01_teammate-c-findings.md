# Critic Findings: Zed Keybindings Cheat Sheet

**Role**: Critic — gaps, risks, and blind spots

**Sources examined**:
- `/home/benjamin/.config/zed/docs/general/keybindings.md`
- `/home/benjamin/.config/zed/keymap.json`
- User memory: `feedback_no_vim_mode_zed.md`, `project_zed_keymap_context_shadowing.md`

---

## Key Findings

### 1. CRITICAL: Platform Key Notation Mismatch (Linux vs macOS)

The keybindings.md opens with: _"This guide assumes macOS. The Cmd key is used where other platforms use Ctrl."_

The user is on **Linux** (confirmed by env: `Platform: linux`). On Linux, `Cmd` does not exist — `Ctrl` is used instead. However, the doc mixes two kinds of bindings:

- **Zed defaults** listed as `Cmd+P`, `Cmd+S`, etc. — on Linux these become `Ctrl+P`, `Ctrl+S`, etc.
- **Custom bindings** deliberately use `Ctrl+` to avoid colliding with macOS `Cmd+` shortcuts.

On Linux the distinction between "Zed default Cmd+" and "custom Ctrl+" collapses — they both become `Ctrl+`. This creates **apparent conflicts** that don't actually exist on macOS:

| Doc says | macOS | Linux |
|----------|-------|-------|
| `Cmd+H` (pane left, custom*) | `Cmd+H` | Does not appear to exist — doc says Cmd+H |
| `Ctrl+H` (pane left, actual keymap) | `Ctrl+H` | `Ctrl+H` |

Checking keymap.json: the actual binding is `ctrl-h` and `ctrl-l` for pane navigation, but the documentation in the "How do I work with tabs?" section says `Cmd+H` and `Cmd+L`. This means **the docs are wrong for Linux users** for pane navigation — the shortcuts are `Ctrl+H` / `Ctrl+L`, not `Cmd+H` / `Cmd+L`.

Similarly, `Ctrl+Shift+E` in the docs is listed as a custom binding to toggle the left sidebar, but the keymap.json comment block also lists `Cmd+Shift+E` as the Zed default for "File explorer (project panel)." On Linux both resolve to Ctrl — the cheat sheet must not imply they are different.

**For the cheat sheet**: Use `Ctrl` for all bindings on Linux. Document the macOS equivalent in a footnote if desired, but the primary notation should be `Ctrl`.

### 2. Bindings in keymap.json NOT Documented in keybindings.md

Two binding groups in `keymap.json` have **no mention at all** in the documentation:

#### a. `ctrl-enter` → `editor::OpenFile`
```json
{ "context": "Editor", "bindings": { "ctrl-enter": "editor::OpenFile" } }
```
The markdown doc does not mention this binding anywhere. It opens the file under the cursor — useful for navigating to imports or file paths in code. The keymap.json comment block notes it as `Ctrl+Enter — Open file under cursor (custom; see Editor bindings)` but keybindings.md is silent on it.

#### b. ProjectPanel hjkl navigation
```json
{
  "context": "ProjectPanel && not_editing",
  "bindings": {
    "h": "project_panel::CollapseSelectedEntry",
    "j": "menu::SelectNext",
    "k": "menu::SelectPrevious",
    "l": "project_panel::Open"
  }
}
```
This is an entire vim-style navigation mode for the file explorer panel — completely absent from keybindings.md. Given that the user memory says "no vim mode in Zed" but these bindings give vim-style navigation in the project panel, this section is especially notable and needs a decision: include it in the cheat sheet or not?

### 3. CONTRADICTION: Alt+V Vim Toggle vs "No Vim Mode" Memory

User memory (`feedback_no_vim_mode_zed.md`) states: _"Zed shared with collaborator; use standard keybindings, not vim"_.

Yet keybindings.md has a full section "How do I toggle vim mode?" describing `Alt+V *` as a way to toggle vim mode on/off. The binding exists in keymap.json (`"alt-v": "workspace::ToggleVimMode"`).

**The resolution appears to be**: vim mode is *available* but kept off by default; the binding is there as an escape hatch for occasional use. The "no vim mode" note reflects the *default state*, not a prohibition.

**Risk for the cheat sheet**: Including `Alt+V` prominently may confuse a collaborator who doesn't know vim. Options:
- Include it in a "Power User" or "Optional" section with a note that vim mode is off by default
- Omit it from the main cheat sheet, mention it only in a footnote
- Keep it as-is (the existing doc includes it without special marking)

Similarly, the ProjectPanel hjkl bindings from finding #2 are de-facto vim-style navigation. The cheat sheet must decide whether to include them.

### 4. Chord Bindings Requiring Special Typst Treatment

Two bindings are **multi-key sequences** (chords), not simultaneous key presses:

- `Cmd+K V` — Markdown preview side-by-side: press `Cmd+K`, release, then press `V`
- `Alt+G B` — Git blame: press `Alt+G`, release, then press `B`

In Typst, these need to be typeset differently from single-chord shortcuts (e.g., with a "then" separator or different visual style). Using `→` or a thin space between key groups is conventional. Using a standard `+` would be incorrect and misleading.

The doc uses spaces to separate the chord components (`Cmd+K V`, `Alt+G B`) — this convention must be preserved clearly in the Typst layout.

### 5. Context-Dependent Bindings Need Clear Visual Indication

Many bindings only work in specific UI contexts. The cheat sheet must visually distinguish these:

| Binding | Context constraint |
|---------|-------------------|
| `Cmd+N` (new thread) | Agent panel must be focused |
| `Shift+Alt+J` (recent threads) | Agent panel context |
| `Cmd+Shift+H` (thread history) | Agent panel context |
| `Double-Enter` (send immediately) | Agent panel context |
| `Enter` / `Cmd+Enter` (send message) | Agent panel message editor |
| `Shift+Alt+Escape` (expand editor) | Agent panel message editor |
| `Tab` (accept prediction) | Editor, only when completions menu is absent |
| `Alt+L` (accept prediction or cycle models) | Dual meaning depending on context |
| `h/j/k/l` navigation | ProjectPanel only, not_editing guard |
| `Ctrl+Enter` (open file) | Editor context |
| `Alt+Shift+P/E` (Slidev) | Editor context (Slidev file open) |
| `Ctrl+Shift+A` (Claude Code) | Workspace and Terminal contexts |

**Notable ambiguity**: `Alt+L` has two different meanings:
- In the editor: "Accept edit prediction" (AI code completion)
- In the agent panel: "Cycle favorite models"

This dual assignment is likely safe since the contexts are mutually exclusive, but it will confuse a reader of a flat cheat sheet. The Typst layout must show context clearly, or note the dual use.

### 6. Many Defaults Marked "(verify)" — Uncertain Accuracy

The keymap.json reference section flags many shortcuts with `(verify)`:

- `Cmd+Shift+S` — Save all (verify)
- `Cmd+Shift+G` — Git panel (verify)
- `Ctrl+- ` / `Ctrl+Shift+-` — Go back/forward (verify)
- `Cmd+Shift+M` — Problems panel (verify)
- `Cmd+Alt+F` — Find and replace in file (verify)
- `Cmd+Shift+H` — Replace across files (verify)
- `Cmd+?` — Toggle agent panel (verify)
- `Cmd+N` — New conversation in agent panel (verify)
- `Cmd+Enter` — Send message in agent panel (verify)
- `Cmd+;` — Toggle inline assist (verify)
- `Ctrl+Shift+K` vs `Cmd+Shift+K` — Delete line (verify)
- `Cmd+Alt+Up/Down` — Add cursor above/below (verify)
- `Cmd+Shift+I` — Format document (verify)
- `Cmd+K V` / `Cmd+Shift+V` — Markdown preview (verify)
- `Cmd+\` / `Cmd+Shift+\` — Split pane (verify)

Including unverified shortcuts in a cheat sheet risks training users on wrong bindings. The cheat sheet should either:
- Omit all `(verify)` shortcuts entirely, OR
- Include them with a visual "unverified" indicator (e.g., `?` superscript or italic), OR
- Verify them against the live Zed keymap (`Cmd+K Cmd+S`) before publication

### 7. `Cmd+Y` Listed as Redo Alternative — Platform-Specific

The quick reference table shows `Cmd+Shift+Z or Cmd+Y` for Redo. On Linux (where Cmd becomes Ctrl), `Ctrl+Y` is the standard redo shortcut in many applications, but `Ctrl+Shift+Z` is also common. This dual listing is fine but should be confirmed as actually functional in Zed on Linux.

### 8. `Cmd+H` Listed as Pane Navigation But Conflicts With Find-and-Replace

The doc mentions "The default Cmd+H is remapped to pane navigation" in the find-and-replace section. On Linux, `Ctrl+H` is commonly the find-and-replace shortcut in many editors. The keymap comment confirms: `Ctrl+H and Ctrl+L are re-declared here so that Zed's default Editor-context Ctrl+H (Find and replace in file) does not shadow the Workspace-context pane-navigation binding above.`

The cheat sheet should note that `Ctrl+H` does pane navigation (not find-and-replace), and direct users to `Cmd+Shift+P → find and replace` for that operation. This is already handled in the prose docs but could be missed in a compact cheat sheet format.

---

## Recommended Approach

### For Platform Notation
Use `Ctrl` throughout for Linux. Either add a small footnote ("macOS: replace Ctrl with Cmd for Zed defaults") or produce two versions. Do NOT use `Cmd` in the primary cheat sheet for a Linux user.

### For Undocumented Bindings
- **Ctrl+Enter (open file)**: Include — it's useful and completely absent from docs.
- **ProjectPanel hjkl**: Include in a separate "File Explorer" section with a note that these are always active (no vim mode required), guarded by "not editing" state.

### For Vim Toggle Contradiction
Include `Alt+V` in an "Optional / Power User" section with a note: "Vim mode is off by default; this is an opt-in toggle." This respects the user's collaborator concern while preserving the documented behavior.

### For Chord Bindings
Use distinct visual typography in Typst, e.g.:
- Simultaneous: `Ctrl`+`K` `Ctrl`+`S` (or a dedicated `\key{}` macro with `+` separator)
- Chord (sequential): `Ctrl`+`K` → `V` (arrow or space separator)

### For Context-Dependent Bindings
Group the cheat sheet by context (Global / Editor / Agent Panel / File Explorer / Terminal) rather than by function. This naturally eliminates context confusion.

### For "(verify)" Shortcuts
Omit from the cheat sheet OR add a visual indicator. Recommend omitting for a clean, reliable reference.

---

## Evidence / Examples

**Undocumented `ctrl-enter` binding** (keymap.json line 68):
```json
"ctrl-enter": "editor::OpenFile"
```
No mention in keybindings.md.

**Undocumented ProjectPanel section** (keymap.json lines 82-89):
```json
{
  "context": "ProjectPanel && not_editing",
  "bindings": { "h": "...", "j": "...", "k": "...", "l": "..." }
}
```
No mention in keybindings.md.

**Actual pane navigation binding** (keymap.json lines 61-62):
```json
"ctrl-h": "workspace::ActivatePaneLeft",
"ctrl-l": "workspace::ActivatePaneRight",
```
But keybindings.md "How do I work with tabs?" section says `Cmd+H` and `Cmd+L` — incorrect for Linux.

**Dual meaning of Alt+L** (keybindings.md lines 149, 151):
- Line 149: `Alt+L — Accept edit prediction`
- Line 151 (model management section): `Alt+L — Cycle favorite models`

---

## Confidence Level

| Finding | Confidence |
|---------|-----------|
| Platform notation mismatch (Linux Ctrl vs macOS Cmd) | High — env confirms Linux, keymap confirms Ctrl |
| ctrl-enter undocumented | High — searched full keybindings.md, not present |
| ProjectPanel hjkl undocumented | High — searched full keybindings.md, not present |
| Vim toggle vs memory contradiction | High — both sources are clear; interpretation is medium confidence |
| Chord bindings need special treatment | High |
| Alt+L dual meaning | High |
| (verify) shortcuts unreliable | High — explicitly flagged in keymap.json |
| Cmd+H docs say Cmd but keymap uses Ctrl | High |
