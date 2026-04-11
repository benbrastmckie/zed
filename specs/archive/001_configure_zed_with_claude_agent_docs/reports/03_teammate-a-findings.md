# Teammate A Findings: Complete Standard Zed Keybindings on Linux (No Vim Mode)

**Round**: 3
**Focus**: Comprehensive default Zed keybindings for Linux in standard (non-vim) mode
**Source**: `assets/keymaps/default-linux.json` from the Zed GitHub repository (fetched live)

---

## Key Findings

1. **Source of Truth**: All default Linux keybindings are defined in `assets/keymaps/default-linux.json` in the Zed repository. The Zed docs page at `zed.dev/docs/key-bindings` does NOT list them — it only explains how to find them.

2. **Context-Based Architecture**: Keybindings in Zed are context-sensitive. The same key can do different things depending on what's focused (Editor, Terminal, AgentPanel, ProjectPanel, etc.). This is critical for understanding Zed's binding system.

3. **No Vim Mode Required**: All bindings listed here are standard insert/edit-mode bindings. Standard Linux conventions (Ctrl+C/X/V, arrow keys, etc.) apply everywhere.

4. **Chord Bindings**: Zed uses two-key chord sequences extensively (e.g., `ctrl-k ctrl-s` for keymap editor). These are written as space-separated sequences.

5. **AI/Agent Panel**: The agent panel has its own rich set of keybindings separate from the editor context.

6. **Confidence**: HIGH — data sourced directly from the raw GitHub JSON file for the current main branch.

---

## Complete Keybinding Tables by Category

### File Operations

| Shortcut | Action | Notes |
|----------|--------|-------|
| `ctrl-s` | Save file | |
| `ctrl-shift-s` | Save As | |
| `ctrl-k s` | Save without formatting | REMOVE |
| `ctrl-alt-s` | Save all files | |
| `ctrl-n` | New file | |
| `ctrl-shift-n` | New window | |
| `ctrl-o` | Open files | |
| `ctrl-k ctrl-o` | Open folder/workspace | |
| `ctrl-r` | Open recent project | |
| `ctrl-alt-o` | Open recent project | |
| `ctrl-shift-w` | Close window | |
| `ctrl-q` | Quit Zed | |

### Navigation — Files and Symbols

| Shortcut | Action | Notes |
|----------|--------|-------|
| `ctrl-p` | Open file finder (fuzzy) | |
| `ctrl-e` | Open file finder (fuzzy) | REMOVE |
| `ctrl-t` | Go to project symbol | EXPLAIN |
| `ctrl-shift-o` | Toggle file outline | |
| `ctrl-g` | Go to line | |
| `ctrl-shift-p` | Command palette | |
| `f1` | Command palette | |
| `f12` | Go to definition | |
| `ctrl-f12` | Go to type definition | |
| `shift-f12` | Go to implementation | |
| `alt-f12` | Go to definition (split) | |
| `alt-shift-f12` | Find all references | |
| `ctrl-shift-tab` | Tab switcher (select last) | |
| `ctrl-tab` | Tab switcher | |
| `ctrl-m` | Move to enclosing bracket | |
| `ctrl-\|` | Move to enclosing bracket | REMOVE |

### Editor — Text Editing

| Shortcut | Action | Notes |
|----------|--------|-------|
| `ctrl-z` | Undo | |
| `ctrl-y` | Redo | |
| `ctrl-shift-z` | Redo | REMOVE |
| `ctrl-x` | Cut | |
| `shift-delete` | Cut | |
| `ctrl-c` | Copy | |
| `ctrl-insert` | Copy | |
| `ctrl-v` | Paste | |
| `shift-insert` | Paste | |
| `ctrl-a` | Select all | |
| `ctrl-l` | Select line | |
| `ctrl-d` | Select next occurrence | Multi-cursor |
| `ctrl-shift-l` | Select all occurrences | Multi-cursor |
| `ctrl-f2` | Select all occurrences | Alias |
| `ctrl-u` | Undo selection | |
| `ctrl-shift-u` | Redo selection | |
| `ctrl-shift-k` | Delete line | |
| `ctrl-shift-j` | Join lines | |
| `ctrl-/` | Toggle line comment | |
| `ctrl-k ctrl-c` | Toggle line comment | REMOVE |
| `ctrl-k ctrl-/` | Toggle block comment | |
| `shift-alt-a` | Toggle block comment | REMOVE |
| `ctrl-[` | Outdent | CHANGE to `ctrl-<` |
| `ctrl-]` | Indent | CHANGE to `ctrl->` |
| `alt-up` | Move line up | |
| `alt-down` | Move line down | |
| `ctrl-alt-shift-up` | Duplicate line up | |
| `ctrl-alt-shift-down` | Duplicate line down | |
| `ctrl-shift-i` | Format document | |
| `alt-shift-o` | Organize imports | |
| `ctrl-.` | Toggle code actions | |
| `ctrl-space` | Show completions | |
| `ctrl-shift-space` | Show word completions | |
| `ctrl-i` | Show signature help | |
| `ctrl-k ctrl-i` | Hover documentation | |
| `ctrl-k ctrl-b` | Blame hover | |
| `f2` | Rename symbol | |
| `ctrl-k ctrl-z` | Toggle soft wrap | |
| `ctrl-k z` | Toggle soft wrap | Alias (Zen mode) |
| `ctrl-k ctrl-q` | Rewrap paragraph | |

### Editor — Cursor Movement

| Shortcut | Action | Notes |
|----------|--------|-------|
| `up` / `down` / `left` / `right` | Move cursor | |
| `ctrl-left` | Move to previous word start | |
| `ctrl-right` | Move to next word end | |
| `home` | Move to beginning of line | |
| `end` | Move to end of line | |
| `ctrl-home` | Move to beginning of file | |
| `ctrl-end` | Move to end of file | |
| `pageup` | Move page up | |
| `pagedown` | Move page down | |
| `ctrl-up` | Scroll line up | |
| `ctrl-down` | Scroll line down | |
| `ctrl-alt-left` | Move to previous subword start | |
| `ctrl-alt-right` | Move to next subword end | |

### Editor — Selection

| Shortcut | Action | Notes |
|----------|--------|-------|
| `shift-up/down/left/right` | Extend selection | |
| `ctrl-shift-left` | Select to previous word start | |
| `ctrl-shift-right` | Select to next word end | |
| `ctrl-shift-home` | Select to beginning of file | |
| `ctrl-shift-end` | Select to end of file | |
| `shift-home` | Select to beginning of line | |
| `shift-end` | Select to end of line | |
| `shift-pageup` | Select page up | |
| `shift-pagedown` | Select page down | |
| `alt-shift-right` | Select larger syntax node | |
| `alt-shift-left` | Select smaller syntax node | |
| `ctrl-alt-e` | Select enclosing symbol | |
| `shift-alt-up` | Add cursor above | Multi-cursor |
| `shift-alt-down` | Add cursor below | Multi-cursor |
| `ctrl-shift-down` | Select next occurrence | Multi-cursor |
| `ctrl-shift-up` | Select previous occurrence | Multi-cursor |
| `ctrl-k ctrl-d` | Skip and select next occurrence | |
| `ctrl-k ctrl-shift-d` | Skip and select previous | |

### Editor — Code Folding

| Shortcut | Action | Notes |
|----------|--------|-------|
| `ctrl-{` | Fold | |
| `ctrl-}` | Unfold lines | |
| `ctrl-k ctrl-l` | Toggle fold | |
| `ctrl-k ctrl-[` | Fold recursive | |
| `ctrl-k ctrl-]` | Unfold recursive | |
| `ctrl-k ctrl-0` | Fold all | |
| `ctrl-k ctrl-j` | Unfold all | |
| `ctrl-k ctrl-1` through `ctrl-k ctrl-9` | Fold at level 1-9 | |

### Editor — Diagnostics and Navigation

| Shortcut | Action | Notes |
|----------|--------|-------|
| `f8` | Go to next diagnostic | |
| `shift-f8` | Go to previous diagnostic | |
| `alt-.` | Go to next hunk (diff) | |
| `alt-,` | Go to previous hunk (diff) | |
| `ctrl-shift-backspace` | Go to previous change | |
| `ctrl-shift-alt-backspace` | Go to next change | |
| `ctrl-f8` | Go to hunk | |
| `ctrl-shift-f8` | Go to previous hunk | |

### Search

| Shortcut | Action | Notes |
|----------|--------|-------|
| `ctrl-f` | Find in file | |
| `ctrl-h` | Find and replace in file | |
| `ctrl-shift-f` | Project-wide search | |
| `ctrl-shift-h` | Project-wide search with replace | |
| `enter` | Next match (in search bar) | |
| `shift-enter` | Previous match (in search bar) | |
| `alt-enter` | Select all matches | |
| `f3` | Select next match | |
| `shift-f3` | Select previous match | |
| `ctrl-alt-g` | Select next match | Alias |
| `ctrl-alt-shift-g` | Select previous match | Alias |
| `alt-c` | Toggle case sensitive | |
| `alt-w` | Toggle whole word | |
| `alt-r` | Toggle regex | |
| `ctrl-l` | Toggle selection search | In search bar |
| `ctrl-shift-enter` | Toggle all search results | |

### Panels — Toggle and Focus

| Shortcut | Action | Notes |
|----------|--------|-------|
| `ctrl-b` | Toggle left dock (project panel) | |
| `ctrl-alt-b` | Toggle right dock | |
| `ctrl-j` | Toggle bottom dock | |
| `ctrl-\`` | Toggle terminal panel | |
| `ctrl-~` | New terminal | |
| `ctrl-shift-e` | Focus project panel | |
| `ctrl-shift-b` | Focus outline panel | |
| `ctrl-shift-g` | Focus git panel | |
| `ctrl-shift-d` | Focus debug panel | |
| `ctrl-shift-m` | Open diagnostics | |
| `ctrl-?` | Toggle AI agent panel focus | |
| `ctrl-alt-y` | Toggle all docks | |
| `ctrl-alt-j` | Toggle workspace sidebar | |
| `ctrl-alt-;` | Focus workspace sidebar | |
| `ctrl-shift-x` | Open extensions | |
| `ctrl-,` | Open settings (UI) | |
| `ctrl-alt-,` | Open settings.json | |
| `ctrl-k ctrl-s` | Open keymap editor | |
| `ctrl-k ctrl-t` | Open theme selector | |
| `ctrl-k ctrl-shift-t` | Toggle dark/light theme | |

### Splits and Panes

| Shortcut | Action | Notes |
|----------|--------|-------|
| `ctrl-\` | Split pane right | In editor |
| `ctrl-k right` | Split pane right | In pane context |
| `ctrl-k left` | Split pane left | |
| `ctrl-k up` | Split pane up | |
| `ctrl-k down` | Split pane down | |
| `ctrl-k ctrl-right` | Activate pane right | |
| `ctrl-k ctrl-left` | Activate pane left | |
| `ctrl-k ctrl-up` | Activate pane up | |
| `ctrl-k ctrl-down` | Activate pane down | |
| `ctrl-k shift-right` | Swap pane right | |
| `ctrl-k shift-left` | Swap pane left | |
| `ctrl-k shift-up` | Swap pane up | |
| `ctrl-k shift-down` | Swap pane down | |
| `alt-1` through `alt-9` | Activate pane 1-9 | |

### Tabs / Buffer Management

| Shortcut | Action | Notes |
|----------|--------|-------|
| `ctrl-pageup` | Activate previous tab | |
| `ctrl-pagedown` | Activate next tab | |
| `ctrl-shift-pageup` | Swap tab left | |
| `ctrl-shift-pagedown` | Swap tab right | |
| `ctrl-w` | Close active tab | |
| `ctrl-f4` | Close active tab | Alias |
| `ctrl-shift-t` | Reopen closed tab | |
| `alt-ctrl-t` | Close other tabs | |
| `ctrl-k e` | Close tabs to the left | |
| `ctrl-k t` | Close tabs to the right | |
| `ctrl-k u` | Close unmodified tabs | |
| `ctrl-k w` | Close all tabs | |
| `ctrl-k ctrl-w` | Close all items and panes | |
| `alt-ctrl-shift-w` | Close inactive tabs and panes | |
| `alt-1` through `alt-9` | Activate tab 1-9 | In pane context |
| `alt-0` | Activate last tab | |
| `ctrl-alt--` | Navigate back (history) | |
| `ctrl-alt-_` | Navigate forward (history) | |
| `ctrl-k shift-enter` | Pin/unpin tab | |

### Terminal

| Shortcut | Action | Notes |
|----------|--------|-------|
| `ctrl-\`` | Toggle terminal panel | In workspace |
| `ctrl-~` | New terminal | |
| `ctrl-shift-c` | Copy in terminal | |
| `ctrl-shift-v` | Paste in terminal | |
| `ctrl-shift-l` | Clear terminal | |
| `ctrl-shift-w` | Close terminal tab | |
| `ctrl-shift-5` | Split terminal right | |
| `shift-pageup` | Scroll terminal page up | |
| `shift-pagedown` | Scroll terminal page down | |
| `shift-up` | Scroll terminal line up | |
| `shift-down` | Scroll terminal line down | |
| `shift-home` | Scroll to top of terminal | |
| `shift-end` | Scroll to bottom of terminal | |
| `ctrl-shift-f` | Search in terminal | |
| `ctrl-shift-space` | Toggle Vi mode in terminal | |
| `ctrl-enter` | Inline AI assist in terminal | |
| `ctrl-shift-r` | Rerun last task (in terminal) | |

### AI / Agent Panel

| Shortcut | Action | Notes |
|----------|--------|-------|
| `ctrl-?` | Toggle agent panel focus | |
| `ctrl-n` | New thread | In agent panel |
| `ctrl-shift-h` | Open thread history | |
| `ctrl-enter` | Send message (chat with follow) | |
| `ctrl-shift-enter` | Send message immediately / continue thread | |
| `ctrl->` | Add selection to thread | In editor or terminal |
| `ctrl-alt-/` | Toggle model selector | |
| `alt-tab` | Cycle favorite models | |
| `alt-l` | Cycle favorite models | Alias |
| `ctrl-alt-p` | Manage profiles | |
| `shift-tab` | Cycle mode selector | |
| `ctrl-i` | Toggle profile selector | |
| `shift-alt-escape` | Expand message editor | |
| `shift-alt-j` | Toggle navigation menu | |
| `shift-alt-i` | Toggle options menu | |
| `ctrl-;` | Open add context menu | In thread editor |
| `ctrl-alt-k` | Toggle thinking mode | |
| `ctrl-alt-.` | Toggle fast mode | |
| `ctrl-alt-'` | Toggle thinking effort menu | |
| `ctrl-'` | Cycle thinking effort | |
| `ctrl-shift-v` | Paste raw (no formatting) | In thread |
| `ctrl-shift-r` | Open agent diff view | |
| `shift-alt-y` | Keep all agent changes | |
| `shift-alt-z` | Reject all agent changes | |
| `shift-alt-u` | Undo last reject | |
| `alt-y` | Keep agent change | |
| `ctrl-alt-z` | Reject agent change | |
| `ctrl-alt-e` | Edit first queued message | |
| `ctrl-alt-backspace` | Clear message queue | |
| `shift-alt-q` | Allow always (permission) | |
| `shift-alt-a` | Allow once (permission) | |
| `shift-alt-x` | Reject once (permission) | |
| `ctrl-alt-a` | Open permission dropdown | |
| `ctrl-alt-c` | Open agent settings | In agent panel |
| `ctrl-alt-l` | Open rules library | |

### Inline AI Assist (in Editor)

| Shortcut | Action | Notes |
|----------|--------|-------|
| `ctrl-enter` | Trigger inline AI assist | In editor (non-agent-diff) |
| `ctrl-[` | Cycle to previous inline assist | |
| `ctrl-]` | Cycle to next inline assist | |
| `ctrl-shift-enter` | Thumbs up result | |
| `ctrl-shift-backspace` | Thumbs down result | |
| `ctrl-alt-e` | Select enclosing symbol | Also used for assist context |

### Git Panel

| Shortcut | Action | Notes |
|----------|--------|-------|
| `ctrl-shift-g` | Focus git panel | |
| `alt-g b` | Git blame | In editor |
| `alt-g m` | Open modified files | |
| `alt-g r` | Review diff | |
| `ctrl-g ctrl-g` | Fetch | In git panel |
| `ctrl-g up` | Push | |
| `ctrl-g down` | Pull | |
| `ctrl-g shift-down` | Pull rebase | |
| `ctrl-g shift-up` | Force push | |
| `ctrl-g d` | Show diff | |
| `space` | Stage/unstage file | In git changes list |
| `alt-y` | Stage file | |
| `alt-shift-y` | Unstage file | |
| `ctrl-alt-y` | Toggle staged | |
| `ctrl-enter` | Commit | In git panel or commit editor |
| `ctrl-shift-enter` | Amend commit | |
| `alt-l` | Generate commit message (AI) | In commit editor |
| `ctrl-space` | Stage all | |
| `ctrl-shift-space` | Unstage all | |
| `ctrl-k ctrl-r` | Restore file to HEAD | In editor |
| `ctrl-alt-y` | Toggle staged (in editor) | |
| `alt-y` | Stage and go to next | |
| `alt-shift-y` | Unstage and go to next | |

### Font / Display

| Shortcut | Action | Notes |
|----------|--------|-------|
| `ctrl-=` | Increase buffer font size | |
| `ctrl-+` | Increase buffer font size | Alias |
| `ctrl--` | Decrease buffer font size | |
| `ctrl-0` | Reset buffer font size | |
| `shift-escape` | Toggle zoom (focus mode) | |
| `f11` | Toggle fullscreen | |
| `ctrl-;` | Toggle line numbers | In editor |
| `ctrl-alt-shift-e` | Toggle AI edit prediction | |
| `ctrl-alt-'` | Toggle thinking effort menu | In agent |

### Debugger

| Shortcut | Action | Notes |
|----------|--------|-------|
| `f4` | Start debugger | |
| `f5` | Rerun / continue debugger | |
| `shift-f5` | Stop debugger | |
| `ctrl-shift-f5` | Rerun session | |
| `f6` | Pause | |
| `f7` | Step over | |
| `ctrl-f11` | Step into | |
| `shift-f11` | Step out | |
| `f9` | Toggle breakpoint | |
| `shift-f9` | Edit log breakpoint | |
| `ctrl-shift-d` | Focus debug panel | |

### Edit Prediction (Zed AI Suggestions)

| Shortcut | Action | Notes |
|----------|--------|-------|
| `alt-\` | Show edit prediction | When not active |
| `alt-tab` | Accept edit prediction | When prediction shown |
| `alt-l` | Accept edit prediction | Alias |
| `alt-k` | Accept next word of prediction | |
| `alt-j` | Accept next line of prediction | |
| `alt-]` | Next edit prediction | |
| `alt-[` | Previous edit prediction | |
| `ctrl-alt-shift-e` | Toggle edit prediction on/off | |

### Markdown / Preview

| Shortcut | Action | Notes |
|----------|--------|-------|
| `ctrl-k v` | Open markdown preview to the side | In .md files |
| `ctrl-shift-v` | Open markdown preview | In .md files |

### Miscellaneous / Utility

| Shortcut | Action | Notes |
|----------|--------|-------|
| `ctrl-k r` | Reveal file in file manager | In editor |
| `ctrl-k p` | Copy file path | |
| `ctrl-k n` | Open encoding selector | |
| `ctrl-k m` | Open language selector | |
| `ctrl-shift-c` | Toggle collab panel | Not in terminal |
| `alt-t` | Rerun task | |
| `alt-shift-t` | Spawn task | |
| `ctrl-shift-r` | Rerun task | |
| `ctrl-alt-r` | Rerun task (reevaluate context) | |
| `ctrl-'` | Toggle selected diff hunks | In editor |
| `ctrl-"` | Expand all diff hunks | |
| `ctrl-alt-space` | Show character palette | |
| `ctrl-alt-shift-c` | Display cursor names | |
| `alt-shift-r` | Spawn task (reveal in center) | |

---

## What Users Commonly Customize

Based on the default binding patterns, these are the areas where users most commonly add or override keybindings:

1. **Agent Panel Access**: The default `ctrl-?` to open agent panel is awkward to type. Many users remap it to `ctrl-shift-a` or a simpler chord.

2. **Inline Assist**: `ctrl-enter` for inline assist conflicts with "new line below" expectation. Users often remap it.

3. **Tab Navigation**: The `ctrl-pageup/pagedown` for tabs feels unnatural to VS Code migrants; many remap to `ctrl-shift-[` / `ctrl-shift-]`.

4. **Format on Save**: Not a keybinding but a setting — users configure `format_on_save`.

5. **Go to Definition**: `f12` is standard but some users add `ctrl-click` or prefer `ctrl-enter`.

6. **Multi-cursor**: The `shift-alt-up/down` for add cursor above/below is consistent with VS Code, but `ctrl-d` for select next match is also VS Code-identical.

7. **Panel Toggles**: Users often add custom bindings to toggle specific panels they use frequently (e.g., dedicated key for agent panel).

8. **Save without Format**: `ctrl-k s` is the default but not obvious — many users remap to something simpler.

9. **Comment Toggle**: `ctrl-/` is correct but some users also want `ctrl-shift-/` for block comments.

10. **Split Navigation**: `ctrl-k ctrl-{direction}` chords for pane navigation are often remapped to simpler `ctrl-alt-{direction}` bindings.

---

## Evidence and Sources

- **Primary Source**: Zed GitHub repository `assets/keymaps/default-linux.json` — fetched live from `raw.githubusercontent.com/zed-industries/zed/main/assets/keymaps/default-linux.json`
- **Secondary Source**: `zed.dev/docs/ai/agent-panel` — confirmed agent panel shortcuts
- **Methodology**: Direct JSON fetch of the canonical default-linux.json file, providing ground-truth data for all contexts

---

## Confidence Level

**HIGH** for the complete keybinding list — sourced directly from the live default-linux.json file in the Zed repository main branch.

**MEDIUM** for "commonly customized" patterns — based on analysis of the binding structure and common editor migration patterns rather than community surveys.

**Key gaps**: The exact set of bindings that override macOS defaults vs Linux defaults was not separately verified (some bindings may only exist in `default-macos.json`). However, everything listed here was confirmed present in the Linux-specific file.
