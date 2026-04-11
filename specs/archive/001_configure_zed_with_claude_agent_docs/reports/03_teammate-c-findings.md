# Round 3 Research Report: Teammate C Findings

**Task**: 1 - Configure Zed with Claude agent system documentation
**Role**: Features and Keybindings Researcher
**Round**: 3
**Date**: 2026-04-09
**Focus**: All Zed utilities and features that a non-vim user might want keybindings for

---

## Key Findings

### 1. This User Does NOT Use Vim Mode

This is the critical framing for all keybinding recommendations. Without vim mode:
- No leader-key (Space) bindings
- No modal editing contexts (`vim_mode == normal`)
- Standard keybindings use Ctrl/Alt/Shift patterns, identical to VS Code muscle memory
- Zed's default `base_keymap` is "VSCode" — most features already have familiar bindings

**Implication**: The keymap.json for this setup should be short. Most VS Code defaults work. The only additions needed are Zed-specific features that have no default binding or have inconvenient defaults.

### 2. The Default Linux Keymap Is Very Complete

The `default-linux.json` keymap covers 500+ bindings across 50+ contexts. The VS Code base keymap adds recognizable mappings on top. A non-vim user will find most actions already bound.

**What does NOT have a default binding** (common gaps users fill):
- `workspace::ToggleCenteredLayout` — no default (zen/focus mode)
- `settings_profile_selector::Toggle` — no default (switch settings profiles)
- `task::Spawn` with a specific task — no default (requires custom binding per task)
- `editor::ToggleInlayHints` — no default (LSP type hint toggles)
- `editor::ToggleSoftWrap` — no default (wrap mode toggle)
- `workspace::CloseAllDocks` — no default (part of zen-mode sequences)
- `editor::DiffClipboardWithSelection` — no default (hidden gem feature)

### 3. Markdown Has Keybindings (Including Preview)

Contrary to prior round findings that "Zed has no markdown preview," the default Linux keymap includes:

```
Ctrl+K V  -> Open preview (side by side)
Ctrl+Shift+V -> Open preview (focused)
```

These ARE in the default-linux.json keymap. The preview may require a markdown extension or may be built-in — this needs verification. But the keybindings exist.

---

## Feature-Keybinding Table (Sorted by Relevance for This Setup)

### Tier 1: Essential — Daily Use Features

| Feature | What It Does | Default Linux Shortcut | Commonly Customized? | Relevant Here? |
|---------|-------------|----------------------|---------------------|----------------|
| **Command Palette** | Access any action by name — universal launcher | `Ctrl+Shift+P` or `F1` | Rarely (already great) | YES — primary interface |
| **File Finder** | Fuzzy search and open any file in project | `Ctrl+P` or `Ctrl+E` | Rarely | YES — open configs |
| **Buffer Search** | Search within current file | `Ctrl+F` | Rarely | YES |
| **Search & Replace** | Find/replace in current file | `Ctrl+H` | Rarely | YES |
| **Project Search** | Search across ALL files | `Ctrl+Shift+F` | Rarely | YES — search .claude/ |
| **Project Search+Replace** | Replace across ALL files | `Ctrl+Shift+H` | Sometimes | YES |
| **Save** | Save current file | `Ctrl+S` | Rarely | YES |
| **Save All** | Save all open files | `Ctrl+Alt+S` | Rarely | YES |
| **Agent Panel (Claude Code)** | Toggle Claude Code sidebar | `Ctrl+?` | Often — users rebind | YES — primary workflow |
| **New Agent Thread** | Start fresh Claude Code conversation | `Ctrl+N` (in AgentPanel) | Rarely | YES |
| **Terminal Panel** | Toggle integrated terminal | `` Ctrl+` `` | Rarely | YES |
| **New Terminal** | Open a new terminal tab | `Ctrl+~` | Rarely | YES |

### Tier 2: Important Navigation Features

| Feature | What It Does | Default Linux Shortcut | Commonly Customized? | Relevant Here? |
|---------|-------------|----------------------|---------------------|----------------|
| **Project Panel** | File explorer (left sidebar) | `Ctrl+Shift+E` or `Ctrl+B` | Sometimes | YES |
| **Tab Switcher** | MRU list of open tabs (hold Ctrl+Tab) | `Ctrl+Tab` | Sometimes | YES |
| **Go to Line** | Jump to specific line number | `Ctrl+G` | Rarely | YES |
| **Outline (buffer)** | Toggle in-file symbol list (fuzzy search) | `Ctrl+Shift+O` | Sometimes | YES — markdown headers |
| **Outline Panel** | Persistent sidebar for file symbols | `Ctrl+Shift+B` | Rarely | YES — markdown nav |
| **Split Pane Right** | Open editor side-by-side | `Ctrl+\` | Often | YES |
| **Split Pane Up/Down/Left** | Split in various directions | `Ctrl+K` + arrow | Sometimes | Sometimes |
| **Close Tab** | Close current file/tab | `Ctrl+W` or `Ctrl+F4` | Rarely | YES |
| **Reopen Closed Tab** | Reopen last closed tab | `Ctrl+Shift+T` | Rarely | YES |
| **Close All Tabs in Pane** | Close everything in pane | `Ctrl+K W` | Rarely | Sometimes |
| **Pin Tab** | Pin a tab to prevent accidental close | `Ctrl+K Shift+Enter` | Sometimes | YES |
| **Activate Pane Left/Right/Up/Down** | Move focus between split panes | `Ctrl+K Ctrl+Left/Right/Up/Down` | Often — users rebind to Ctrl+H/J/K/L | YES |
| **Toggle Left Dock** | Show/hide left panel (project/outline) | `Ctrl+B` | Rarely | YES |
| **Toggle Bottom Dock** | Show/hide bottom panel (terminal) | `Ctrl+J` | Rarely | YES |
| **Toggle Right Dock** | Show/hide right panel | `Ctrl+Alt+B` | Rarely | Sometimes |

### Tier 3: Code/Text Editing Operations

| Feature | What It Does | Default Linux Shortcut | Commonly Customized? | Relevant Here? |
|---------|-------------|----------------------|---------------------|----------------|
| **Multi-cursor: Add Above** | Add cursor on line above | `Shift+Alt+Up` | Rarely | YES — text editing |
| **Multi-cursor: Add Below** | Add cursor on line below | `Shift+Alt+Down` | Rarely | YES — text editing |
| **Multi-cursor: Select Next Match** | Select next occurrence of word | `Ctrl+D` | Rarely | YES |
| **Multi-cursor: Select All Occurrences** | Select ALL occurrences | `Ctrl+Shift+L` | Rarely | YES |
| **Move Line Up/Down** | Swap current line with above/below | `Alt+Up` / `Alt+Down` | Rarely | YES |
| **Duplicate Line Down** | Copy current line below | `Ctrl+Alt+Shift+Down` | Sometimes — users rebind to `Ctrl+Shift+D` | YES |
| **Delete Line** | Remove current line | `Ctrl+Shift+K` | Rarely | YES |
| **Toggle Line Comment** | Comment/uncomment selection | `Ctrl+/` | Rarely | YES |
| **Toggle Block Comment** | Block comment selection | `Shift+Alt+A` | Rarely | Sometimes |
| **Join Lines** | Merge current and next line | `Ctrl+Shift+J` | Rarely | YES — markdown editing |
| **Rewrap** | Reflow paragraph to wrap width | `Ctrl+K Ctrl+Q` | Rarely | YES — markdown prose |
| **Toggle Soft Wrap** | Toggle line wrap on/off | NO DEFAULT | Often added | YES — markdown/prose |
| **Expand/Shrink Selection** | Smart syntax-aware selection | `Alt+Shift+Right/Left` | Rarely | YES |
| **Go to Matching Bracket** | Jump to matching `{}`/`[]` etc. | `Ctrl+M` | Rarely | YES |
| **Undo/Redo** | Standard undo/redo | `Ctrl+Z` / `Ctrl+Y` | Rarely | YES |
| **Format Document** | Run formatter on whole file | `Ctrl+Shift+I` | Rarely | YES |
| **Insert Line Below** | Add new line below cursor | `Ctrl+Enter` | Sometimes | YES |
| **Insert Line Above** | Add new line above cursor | `Ctrl+Shift+Enter` | Sometimes | YES |

### Tier 4: Git Operations

| Feature | What It Does | Default Linux Shortcut | Commonly Customized? | Relevant Here? |
|---------|-------------|----------------------|---------------------|----------------|
| **Git Panel** | Full git UI (stage/commit/push/pull) | `Ctrl+Shift+G` | Sometimes | YES |
| **Toggle Blame** | Show/hide inline git blame | `Alt+G B` | Often — chord is awkward | YES |
| **Go to Next Hunk** | Jump to next changed section | `Alt+.` | Sometimes — users add `]h` | YES |
| **Go to Previous Hunk** | Jump to previous changed section | `Alt+,` | Sometimes | YES |
| **Toggle Diff Hunks** | Show/hide diff hunk highlights | `Ctrl+'` | Rarely | YES |
| **Expand Diff Hunks** | Expand context around changes | `Ctrl+"` | Rarely | Sometimes |
| **Stage File** | Stage current file | `Alt+Y` (in GitPanel) | Rarely | YES |
| **Unstage File** | Unstage current file | `Alt+Shift+Y` (in GitPanel) | Rarely | YES |
| **Commit** | Commit staged changes | `Ctrl+Enter` (in GitPanel) | Rarely | YES |
| **Push** | Push to remote | `Ctrl+G Up` (in GitPanel) | Rarely | YES |
| **Pull** | Pull from remote | `Ctrl+G Down` (in GitPanel) | Rarely | YES |
| **Fetch** | Fetch from remote | `Ctrl+G Ctrl+G` (in GitPanel) | Rarely | YES |
| **Restore File** | Discard changes to file | `Ctrl+K Ctrl+R` | Rarely | Sometimes |
| **Open Modified Files** | Multibuffer of all changed files | `Alt+G M` | Rarely | YES |

### Tier 5: AI/Agent Panel

| Feature | What It Does | Default Linux Shortcut | Commonly Customized? | Relevant Here? |
|---------|-------------|----------------------|---------------------|----------------|
| **Toggle Agent Panel** | Show/hide Claude Code sidebar | `Ctrl+?` | Often — chord is unusual | YES — primary feature |
| **New Thread** | Start a new conversation | `Ctrl+N` (AgentPanel context) | Rarely | YES |
| **Thread History** | View past conversations | `Ctrl+Shift+H` (AgentPanel) | Rarely | YES |
| **Add Context** | Add file/symbol context to thread | `Ctrl+;` (AcpThread) | Rarely | YES |
| **Send (with follow)** | Submit message, follow agent | `Ctrl+Enter` (AcpThread) | Rarely | YES |
| **Send Immediately** | Submit without waiting | `Ctrl+Shift+Enter` (AcpThread) | Rarely | YES |
| **Toggle Thinking Mode** | Enable extended thinking | `Ctrl+Alt+K` (AcpThread) | Rarely | YES |
| **Inline Assist** | Trigger AI for current selection | `Ctrl+Enter` (Editor) | Often — overlaps with other uses | YES |
| **Add Selection to Thread** | Send editor selection to agent | `Ctrl+>` | Sometimes | YES |
| **Agent Settings** | Open agent configuration | `Ctrl+Alt+C` (AgentPanel) | Rarely | YES |
| **Toggle Model Selector** | Switch between AI models | `Ctrl+Alt+/` (AgentPanel) | Rarely | YES |
| **Thread Switcher** | Switch between conversations | `Ctrl+Tab` (AgentPanel) | Rarely | YES |
| **Accept Edit Prediction** | Accept Zed's built-in AI autocomplete | `Alt+Tab` or `Alt+L` | Sometimes | YES |
| **Next Edit Prediction** | Cycle to next suggestion | `Alt+]` | Rarely | YES |

### Tier 6: Diagnostics and LSP

| Feature | What It Does | Default Linux Shortcut | Commonly Customized? | Relevant Here? |
|---------|-------------|----------------------|---------------------|----------------|
| **Deploy Diagnostics Panel** | Full list of errors/warnings | `Ctrl+Shift+M` | Rarely | YES |
| **Go to Next Diagnostic** | Jump to next error/warning | `F8` | Sometimes | YES |
| **Go to Previous Diagnostic** | Jump to previous error | `Shift+F8` | Sometimes | YES |
| **Go to Definition** | Jump to symbol definition | `F12` | Rarely | YES |
| **Go to References** | Find all uses of symbol | `Alt+Shift+F12` | Rarely | YES |
| **Toggle Code Actions** | Show quick-fix menu | `Ctrl+.` | Rarely | YES |
| **Show Completions** | Trigger autocomplete manually | `Ctrl+Space` | Rarely | YES |
| **Hover (documentation)** | Show symbol docs/type on hover | `Ctrl+K Ctrl+I` | Sometimes — chord awkward | YES |
| **Rename Symbol** | Rename across all files | `F2` | Rarely | YES |
| **Format Document** | Auto-format current file | `Ctrl+Shift+I` | Rarely | YES |
| **Toggle Inlay Hints** | Show/hide LSP type hints | NO DEFAULT | Often added | YES — JSON/code |

### Tier 7: Tasks, Panels, and Utilities

| Feature | What It Does | Default Linux Shortcut | Commonly Customized? | Relevant Here? |
|---------|-------------|----------------------|---------------------|----------------|
| **Spawn Task** | Open task picker to run a task | `Alt+Shift+T` | Often — users add per-task bindings | YES |
| **Rerun Task** | Rerun last task | `Ctrl+Shift+R` | Often | YES |
| **Debug Panel** | Toggle debugger panel | `Ctrl+Shift+D` | Rarely | Sometimes |
| **Centered Layout (Zen Mode)** | Center content, reduce distraction | NO DEFAULT | Often added | YES — prose writing |
| **Close All Docks** | Hide all panels at once | NO DEFAULT | Often — part of zen sequence | YES |
| **Settings Profiles** | Switch between settings profiles | NO DEFAULT | Sometimes | Sometimes |
| **Open Settings** | Edit settings.json | `Ctrl+,` | Rarely | YES |
| **Open Keymap** | Edit keymap.json | `Ctrl+K Ctrl+S` | Rarely | YES |
| **Theme Selector** | Interactively pick a theme | `Ctrl+K Ctrl+T` | Rarely | YES |
| **Increase/Decrease Font** | Adjust buffer font size | `Ctrl+=` / `Ctrl+-` | Rarely | YES |
| **Toggle Fullscreen** | Full-screen mode | `F11` | Rarely | YES |
| **Toggle Collab Panel** | Show/hide collaboration sidebar | `Ctrl+Shift+C` | Rarely | No (solo use) |
| **Extension Gallery** | Browse/install extensions | `Ctrl+Shift+X` | Rarely | YES — one-time setup |

### Tier 8: Markdown-Specific

| Feature | What It Does | Default Linux Shortcut | Commonly Customized? | Relevant Here? |
|---------|-------------|----------------------|---------------------|----------------|
| **Markdown Preview (side)** | Split view with live preview | `Ctrl+K V` | Rarely | YES — docs editing |
| **Markdown Preview (full)** | Full focused preview | `Ctrl+Shift+V` | Rarely | YES |
| **Toggle Soft Wrap** | Wrap long lines (essential for prose) | NO DEFAULT | Almost always added | YES — markdown |
| **Rewrap** | Reflow paragraph to column width | `Ctrl+K Ctrl+Q` | Sometimes | YES |
| **Outline Panel** | Navigate markdown headings as tree | `Ctrl+Shift+B` | Rarely | YES — document nav |
| **Outline (quick jump)** | Fuzzy search headings/symbols | `Ctrl+Shift+O` | Rarely | YES |

---

## Commonly Added Bindings (Features with No Default)

These are features that experienced Zed users regularly add to keymap.json because they have no default binding:

### 1. Centered Layout / Zen Mode

```json
{
  "context": "Workspace",
  "bindings": {
    "ctrl-alt-z": "workspace::ToggleCenteredLayout"
  }
}
```

Or combine into a full zen sequence:
```json
{
  "context": "Workspace",
  "bindings": {
    "ctrl-alt-z": [
      "action::Sequence",
      ["workspace::CloseAllDocks", "workspace::ToggleCenteredLayout"]
    ]
  }
}
```

**Why**: No default exists. Centered layout + no docks = distraction-free prose writing mode. Critical for markdown editing.

### 2. Toggle Soft Wrap

```json
{
  "context": "Editor",
  "bindings": {
    "alt-z": "editor::ToggleSoftWrap"
  }
}
```

**Why**: No default binding. Essential for markdown and prose editing. Commonly bound to `Alt+Z` (VS Code pattern).

### 3. Toggle Inlay Hints

```json
{
  "context": "Editor",
  "bindings": {
    "ctrl-alt-i": "editor::ToggleInlayHints"
  }
}
```

**Why**: No default. LSP type annotations appear inline — useful to toggle on/off for clarity.

### 4. Pane Navigation (Ctrl+H/J/K/L)

```json
{
  "context": "Workspace",
  "bindings": {
    "ctrl-h": "workspace::ActivatePaneLeft",
    "ctrl-j": "workspace::ActivatePaneDown",
    "ctrl-k": "workspace::ActivatePaneUp",
    "ctrl-l": "workspace::ActivatePaneRight"
  }
}
```

**Why**: Default is `Ctrl+K Ctrl+Arrow` which is a two-chord sequence. Single-chord is much faster, even for non-vim users. Note: `Ctrl+K` context may need care to avoid conflicting with `Ctrl+K` chords in Editor.

### 5. Settings Profiles Toggle

```json
{
  "context": "Workspace",
  "bindings": {
    "ctrl-alt-shift-p": "settings_profile_selector::Toggle"
  }
}
```

**Why**: No default. Lets users instantly switch between work profile, writing profile, presentation mode, etc.

### 6. Open Preview (Markdown) — Verify If Needed

Default `Ctrl+K V` and `Ctrl+Shift+V` may already be bound (present in default-linux.json). Add only if missing:

```json
{
  "context": "Editor",
  "bindings": {
    "ctrl-shift-v": "markdown::OpenPreviewToTheSide"
  }
}
```

### 7. Spawn a Specific Task

```json
{
  "context": "Workspace",
  "bindings": {
    "ctrl-alt-l": ["task::Spawn", { "task_name": "Open in LibreOffice" }]
  }
}
```

**Why**: No way to trigger a named task directly without this. Essential for the LibreOffice workflow with Office files.

### 8. Duplicate Line

```json
{
  "context": "Editor",
  "bindings": {
    "ctrl-shift-d": "editor::DuplicateLineDown"
  }
}
```

**Why**: Default `Ctrl+Alt+Shift+Down` is a 3-modifier chord. VS Code uses `Ctrl+Shift+D` — common muscle memory.

---

## Feature Details: Features Especially Relevant for This Setup

### Agent Panel (Claude Code)

The agent panel is the centerpiece of this setup. Key workflow details:

- `Ctrl+?` — Toggle panel focus (unusual binding — the `?` character requires Shift on US keyboards, but Zed treats this as a direct `ctrl-?` binding)
- Once inside the panel, `Ctrl+N` for new thread, `Ctrl+Tab` to switch threads
- `Ctrl+;` adds context (files, symbols) to the current thread
- `Ctrl+>` sends the current editor selection to the thread — extremely useful
- The panel reads `CLAUDE.md` from the workspace root automatically
- Slash commands from `.claude/commands/` work in the agent panel

**No-default gaps**: There is no binding to open a specific slash command directly. Users type `/command` manually in the thread input.

### Project Panel (File Explorer)

- `Ctrl+Shift+E` to toggle focus (or `Ctrl+B` to toggle left dock which includes it)
- Inside the panel: `F2` to rename, `Ctrl+N` for new file, `Delete` to trash
- `Ctrl+Alt+R` reveals the file in the OS file manager
- `Ctrl+Alt+Shift+F` opens a project search scoped to the selected directory — extremely useful for searching within `.claude/` subdirectories

### Outline Panel

- `Ctrl+Shift+B` to toggle
- Shows file structure as a persistent tree (great for markdown with many headings)
- Auto-scrolls to track cursor position
- Click to jump to any heading/symbol
- Also works in multi-buffer view (project search results, diagnostics)

### Git Panel

- `Ctrl+Shift+G` to toggle
- Full staging workflow: `Space` to toggle staged, `Alt+Y` stage+advance
- `Ctrl+Enter` to commit
- Push/pull/fetch all via `Ctrl+G` chords
- AI commit message generation: `Alt+L` (with cursor in commit message box)
- Stashing: available via command palette (`git: stash all`, `git: stash pop`)

### Tab Switcher

- `Ctrl+Tab` — hold Ctrl and keep pressing Tab to cycle through tabs by recency
- Works like Alt+Tab for windows — release to confirm
- `Ctrl+Backspace` while open closes the selected tab
- Different from File Finder: shows only OPEN tabs, sorted by recent use
- Useful for rapid back-and-forth between 2-3 frequently used files

### Search

- **Buffer search**: `Ctrl+F` (standard), `Enter`/`Shift+Enter` for next/previous match
- **Project search**: `Ctrl+Shift+F` — results appear in an EDITABLE multibuffer (unique Zed feature)
- **Search with replace**: `Ctrl+Shift+H` for project-wide search and replace
- **Select all matches**: `Alt+Enter` (selects all occurrences in buffer search)
- **Regex toggle**: `Alt+R` in search bar
- **Case sensitive**: `Alt+C` in search bar
- **Whole word**: `Alt+W` in search bar
- **New search in directory**: Right-click directory in project panel → "New search in directory" (or `Ctrl+Alt+Shift+F` with directory focused)

### Snippets

- Triggered by typing a prefix and pressing `Tab`
- Navigate between placeholders: `Tab` (next) / `Shift+Tab` (previous)
- No special keybinding — it's Tab-expansion only
- Configured in `~/.config/zed/snippets/{language}.json`
- VS Code snippet format (JSON with body, prefix, description)
- No dedicated binding to browse/insert snippets — must type prefix

### Diagnostics

- `Ctrl+Shift+M` — open full diagnostics panel
- `F8` / `Shift+F8` — next/previous diagnostic in file
- Errors shown inline in editor and in gutter
- Diagnostics panel is a multibuffer (editable, can navigate and click)

### Zen Mode / Centered Layout

- `workspace::ToggleCenteredLayout` — no default binding (must add custom)
- Configured in settings: `"centered_layout": {"left_padding": 0.2, "right_padding": 0.2}`
- Not exactly "zen mode" — just centers the editor with padding
- For true distraction-free: sequence of `CloseAllDocks` + `ToggleCenteredLayout`

### Edit Predictions (Built-in AI Autocomplete)

Note: separate from Claude Code in the agent panel. This is Zed's built-in ghost text completions:

- `Alt+Tab` or `Alt+L` — Accept entire suggestion
- `Alt+K` — Accept next word only
- `Alt+J` — Accept next line only
- `Alt+]` / `Alt+[` — Cycle through suggestions
- `Alt+\` — Force show suggestion
- Configured separately from Claude Code

### Tasks

- `Alt+Shift+T` — Open task picker (spawn any task from tasks.json)
- `Ctrl+Shift+R` — Rerun last task
- No binding per named task by default — add custom bindings per task
- Task variables available: `$ZED_FILE`, `$ZED_WORKTREE_ROOT`, `$ZED_SELECTED_TEXT`

### Collaboration

Not relevant for this solo setup. `Ctrl+Shift+C` toggles the collaboration panel — safe to ignore.

---

## What's Missing from Defaults (Summary)

| Feature | Gap | Recommended Binding |
|---------|-----|---------------------|
| Centered layout (zen mode) | No default | `ctrl-alt-z` |
| Toggle soft wrap | No default | `alt-z` |
| Toggle inlay hints | No default | `ctrl-alt-i` |
| Spawn specific named task | No default per task | `ctrl-alt-l` for LibreOffice task |
| Duplicate line | Default is 3-modifier chord | `ctrl-shift-d` |
| Pane navigation | Default is 2-chord sequence | `ctrl-h/j/k/l` |
| Settings profile switch | No default | `ctrl-alt-shift-p` |
| Toggle git blame | Default `alt-g b` exists but is a chord | Keep or rebind to `ctrl-shift-b` (conflicts with outline) |

---

## Non-Vim User: Recommended Minimal keymap.json

For a standard user (no vim mode), the keymap.json can be very lean:

```json
[
  {
    "context": "Workspace",
    "bindings": {
      "ctrl-alt-z": [
        "action::Sequence",
        ["workspace::CloseAllDocks", "workspace::ToggleCenteredLayout"]
      ],
      "ctrl-h": "workspace::ActivatePaneLeft",
      "ctrl-j": "workspace::ActivatePaneDown",
      "ctrl-k": "workspace::ActivatePaneUp",
      "ctrl-l": "workspace::ActivatePaneRight",
      "ctrl-alt-l": ["task::Spawn", {"task_name": "Open in LibreOffice"}]
    }
  },
  {
    "context": "Editor",
    "bindings": {
      "alt-z": "editor::ToggleSoftWrap",
      "ctrl-shift-d": "editor::DuplicateLineDown",
      "ctrl-alt-i": "editor::ToggleInlayHints"
    }
  }
]
```

**Rationale**:
- Everything else already has a sensible VS Code default
- Pane navigation single-chords are the most ergonomic change
- Zen mode + soft wrap are essential for markdown writing
- LibreOffice task launch fills the Office files gap

**Caution**: `ctrl-h` and `ctrl-k` in Workspace context may conflict with `ctrl-k` chord sequences in Editor (e.g., `ctrl-k ctrl-i` for hover). Test carefully. Use `"context": "Pane"` instead of `"Workspace"` if conflicts arise.

---

## Evidence Sources

- Raw Zed Linux keymap (authoritative): https://raw.githubusercontent.com/zed-industries/zed/main/assets/keymaps/default-linux.json
- Zed key bindings documentation: https://zed.dev/docs/key-bindings
- Zed features overview: https://zed.dev/features
- Zed git documentation: https://zed.dev/docs/git
- Zed tasks documentation: https://zed.dev/docs/tasks
- Zed outline panel: https://zed.dev/docs/outline-panel
- Zed tab switcher: https://zed.dev/docs/tab-switcher
- Zed command palette: https://zed.dev/docs/command-palette
- Zed snippets: https://zed.dev/docs/snippets
- Zed finding/navigating: https://zed.dev/docs/finding-navigating
- Zed hidden gems blog: https://zed.dev/blog/hidden-gems-part-3
- Community config reference: https://github.com/jellydn/zed-101-setup
- Zen mode discussion: https://github.com/zed-industries/zed/discussions/36882

---

## Confidence Summary

| Claim | Confidence | Source |
|-------|------------|--------|
| 500+ default bindings exist, VS Code base covers most needs | HIGH | Raw keymap file fetched |
| `ctrl-?` for agent panel | HIGH | Raw keymap verified in prior rounds |
| `ctrl-tab` for tab switcher | HIGH | Official docs + raw keymap |
| `ctrl-shift-g` for git panel | HIGH | Raw keymap + git docs |
| `ctrl-shift-b` for outline panel | HIGH | Outline panel docs |
| `ctrl-k v` / `ctrl-shift-v` for markdown preview | MEDIUM | Raw keymap (needs extension to verify) |
| `workspace::ToggleCenteredLayout` has no default | HIGH | Not in raw keymap |
| `editor::ToggleSoftWrap` has no default | HIGH | Not in raw keymap |
| Snippets use Tab for expansion | HIGH | Official snippets docs + community |
| `alt-z` is conventional for soft wrap | MEDIUM | VS Code convention, not Zed default |
| Pane navigation via `ctrl-h/j/k/l` needs conflict testing | MEDIUM | Known issue from community; needs live test |
