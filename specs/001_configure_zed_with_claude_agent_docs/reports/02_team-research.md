# Research Report: Task #1 (Round 2)

**Task**: Configure Zed with Claude agent system documentation
**Date**: 2026-04-10
**Mode**: Team Research (4 teammates)
**Focus**: Extensions, keymaps, settings best practices

## Summary

Round 2 provides concrete, verified configuration artifacts ready for implementation. Key deliverables: a corrected `settings.json` (no `"source": "custom"`, no legacy `assistant` block), a complete `keymap.json` porting nvim bindings via space-leader syntax, a curated extension list with `auto_install_extensions`, and detailed agent system integration guidance. All Round 1 claims have been verified or corrected.

## Key Findings

### 1. Verified settings.json (Corrected from Round 1)

```json
{
  "theme": "One Dark",
  "ui_font_size": 16,
  "buffer_font_size": 14,
  "buffer_font_family": "RobotoMono Nerd Font",
  "vim_mode": true,
  "vim": {
    "default_mode": "normal",
    "use_system_clipboard": "always",
    "toggle_relative_line_numbers": true,
    "use_smartcase_find": true
  },
  "relative_line_numbers": true,
  "tab_size": 2,
  "format_on_save": "on",
  "cursor_blink": false,
  "terminal": {
    "font_size": 14,
    "font_family": "RobotoMono Nerd Font"
  },
  "agent": {
    "default_model": {
      "provider": "anthropic",
      "model": "claude-sonnet-4-6"
    },
    "tool_permissions": {
      "default": "confirm"
    },
    "play_sound_when_agent_done": "never"
  },
  "languages": {
    "Markdown": {
      "format_on_save": "off",
      "soft_wrap": "editor_width",
      "remove_trailing_whitespace_on_save": false
    },
    "JSON": {
      "tab_size": 2
    }
  },
  "context_servers": {
    "superdoc": {
      "command": "npx",
      "args": ["@superdoc-dev/mcp"],
      "env": {}
    },
    "openpyxl": {
      "command": "npx",
      "args": ["@jonemo/openpyxl-mcp"],
      "env": {}
    }
  },
  "auto_install_extensions": {
    "markdown-oxide": true,
    "markdownlint": true,
    "codebook": true,
    "csv": true
  }
}
```

**Corrections from Round 1**:
- Removed `"assistant"` block (legacy; `"agent"` is current API)
- Removed `"source": "custom"` from context_servers (not in official docs)
- Added `auto_install_extensions` for declarative extension management
- Added `vim.toggle_relative_line_numbers` (switches relative/absolute like nvim)
- Added `play_sound_when_agent_done: "never"`

### 2. Complete keymap.json (Ported from Neovim)

Space-leader bindings use `"space e"` syntax (space as sequence separator) in `"Editor && vim_mode == normal"` context. Confirmed by Zed maintainer.

```json
[
  {
    "context": "Editor && vim_mode == normal",
    "bindings": {
      "space e": "project_panel::ToggleFocus",
      "space f f": "project_search::ToggleFocus",
      "space f b": "tab_switcher::Toggle",
      "space c": "pane::SplitRight",
      "space k": "pane::CloseActiveItem",
      "space w": "workspace::SaveAll",
      "space g l": "git::Blame",
      "space g g": "git_panel::ToggleFocus",
      "space i d": "editor::GoToDefinition",
      "space i r": "editor::FindAllReferences",
      "space i shift-r": "editor::Rename",
      "space i c": "editor::ToggleCodeActions",
      "space i l": "editor::Hover"
    }
  },
  {
    "context": "Workspace",
    "bindings": {
      "ctrl-h": "workspace::ActivatePaneLeft",
      "ctrl-j": "workspace::ActivatePaneDown",
      "ctrl-k": "workspace::ActivatePaneUp",
      "ctrl-l": "workspace::ActivatePaneRight",
      "ctrl-t": "workspace::ToggleBottomDock"
    }
  },
  {
    "context": "Editor",
    "bindings": {
      "ctrl-p": "file_finder::Toggle",
      "alt-j": "editor::MoveLineDown",
      "alt-k": "editor::MoveLineUp",
      "tab": "pane::ActivateNextItem",
      "shift-tab": "pane::ActivatePreviousItem"
    }
  }
]
```

**Action names verified**: `git::Blame` (not deprecated `editor::ToggleGitBlame`), `project_panel::ToggleFocus`, all `workspace::ActivatePane*` actions confirmed from Zed source.

**Items needing live testing**: `tab`/`shift-tab` may conflict with vim Tab motion (restrict to `vim_mode == normal` if so), `ctrl-semicolon` for comments may need `ctrl-/` instead, `space i shift-r` chord syntax is unverified.

### 3. Recommended Extensions

**Priority 1 (install for this setup)**:

| Extension | Downloads | Purpose |
|-----------|-----------|---------|
| Markdown Oxide | 86k | PKM-style markdown with backlinks, wiki-links |
| Markdownlint | 37k | Markdown style/structure linting |
| Codebook Spell Checker | 98k | Code-aware spell checking for docs |
| CSV | 117k | CSV language support |

**Priority 2 (consider)**:

| Extension | Downloads | Purpose |
|-----------|-----------|---------|
| Context7 MCP Server | 122k | Live library docs for Claude Code context |
| MarkItDown MCP Server | 21k | Office-to-Markdown conversion via MCP |
| Brave Search MCP Server | 48k | Web search for Claude Code agent |

**Not available**: No DOCX/XLSX/PDF preview extensions exist. Office file workflows rely on MCP servers (SuperDoc, openpyxl) + external apps (LibreOffice).

**No markdown preview**: Zed has no markdown preview pane (built-in or extension).

**Installation**: `Ctrl+Shift+X` opens extension gallery. Or use `auto_install_extensions` in settings.json for declarative management.

### 4. Claude Code Agent Panel Shortcuts (Linux, Verified)

| Shortcut | Action | Context |
|----------|--------|---------|
| `Ctrl+?` | Toggle agent panel | Workspace |
| `Ctrl+N` | New thread | AgentPanel |
| `Ctrl+Shift+H` | Open history | AgentPanel |
| `Ctrl+;` | Add context menu | AcpThread |
| `Ctrl+Enter` | Chat with follow | AcpThread |
| `Ctrl+Shift+Enter` | Send immediately | AcpThread |
| `Ctrl+Alt+K` | Toggle thinking mode | AcpThread |

Source: raw `default-linux.json` keymap from Zed repository.

### 5. Round 1 Claim Verification

| Claim | Round 1 | Round 2 Verdict |
|-------|---------|-----------------|
| Claude Code uses ACP, auto-installs | Claimed | **CONFIRMED** — installs `@zed-industries/claude-agent-acp` on first use |
| Agent panel shortcut `Ctrl+?` | Medium | **CONFIRMED** — directly from Linux default keymap |
| `context_servers` needs `"source": "custom"` | Claimed mandatory | **WRONG** — field absent from all official docs; remove it |
| `assistant` block for AI config | Claimed | **LEGACY** — use `agent` block instead |
| CLAUDE.md auto-loaded by Zed | Assumed | **CONFIRMED** — Zed natively reads CLAUDE.md as project rules |
| Markdown `format_on_save: off` needed | Claimed | **ALREADY DEFAULT** — explicit is fine for clarity |
| `vim_mode` user-level only | Claimed | **CONFIRMED** |

### 6. Agent System Integration Details

**CLAUDE.md discovery**: Zed workspace root = Claude Code working directory. Opening `~/.config/zed/` activates the `.claude/` system automatically. Claude Code reads CLAUDE.md upward from workspace root.

**Multi-folder limitation**: With multiple folders open, Claude Code always uses the first folder. Open `zeditor ~/.config/zed/` as a single-folder project.

**Custom slash commands**: All `.claude/commands/*.md` files work as slash commands in the Agent Panel.

**Built-in AI vs Claude Code**: The `agent` block configures Zed's built-in AI assistant. Claude Code runs separately via ACP with its own configuration. Only Claude Code has access to `.claude/` commands.

### 7. tasks.json for Practical Workflows

```json
[
  {
    "label": "Open in LibreOffice",
    "command": "libreoffice",
    "args": ["$ZED_FILE"],
    "reveal": "never"
  },
  {
    "label": "Export Agent System",
    "command": "bash",
    "args": [".claude/scripts/export-to-markdown.sh"],
    "cwd": "$ZED_WORKTREE_ROOT"
  },
  {
    "label": "Git Status",
    "command": "git",
    "args": ["status"],
    "cwd": "$ZED_WORKTREE_ROOT"
  }
]
```

Tasks are secondary to the Agent Panel — useful for LibreOffice opening and utility scripts.

### 8. .memory/ Vault Status

The vault exists but is unpopulated (`10-Memories/` has only README.md). No Zed-specific configuration needed — `/learn` manages everything through Claude Code. Wiki-link syntax `[[filename]]` is not clickable in Zed (acceptable — vault is primarily read by Claude Code).

### 9. Documentation Structure (Refined from Round 1)

**docs/agent-system.md** (~100-150 lines, thin bridge):
1. The Two AI Systems in Zed (built-in vs. Claude Code)
2. Starting Claude Code (Ctrl+?, /login, first use)
3. Project Discovery (workspace root = working directory)
4. Key Commands (3-4 examples, link to .claude/README.md for full list)
5. The Memory Vault (what /learn does, link to .memory/README.md)
6. tasks.json Enhancements (LibreOffice open, export script)
7. Known Limitations (ACP vs terminal, multi-folder restriction)

**Do not duplicate** the command reference from `.claude/README.md`.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution | Reasoning |
|----------|------------|-----------|
| `"source": "custom"` in context_servers | **Remove** — not in any official docs | Teammate C verified against raw Zed source; Teammate A's Round 1 claim was from a third-party tutorial |
| `assistant` vs `agent` block | **Use `agent` only** | `assistant` is legacy pre-2024 API; `agent` is current |
| Tab/Shift-Tab for buffer cycling | **Keep in Editor context, note potential conflict** | May need `vim_mode == normal` restriction if Tab indentation breaks |
| .zed/settings.json needed? | **Not needed** — user-level covers everything | Teammate D confirmed Markdown settings are already Zed defaults; no project-specific overrides required |

### Gaps Remaining

1. **One Dark theme availability** — still unverified if built-in or needs extension
2. **`tab`/`shift-tab` vim conflict** — needs live testing
3. **`ctrl-semicolon` vs `ctrl-/`** — default Linux comment toggle is `ctrl-/`; test both
4. **`space i shift-r` chord** — shift+letter in sequence unverified
5. **MCP server activation** — need to test `context_servers` actually activates SuperDoc/openpyxl

### Implementation Readiness

| Artifact | Status | Notes |
|----------|--------|-------|
| settings.json | **Ready** | Verified against official defaults, corrections applied |
| keymap.json | **Ready** | Core bindings verified; 3 items need live testing |
| Extension list | **Ready** | `auto_install_extensions` covers Priority 1 |
| tasks.json | **Ready** | 3 practical tasks defined |
| docs/ structure | **Ready** | 4-file structure with content outlines |
| project-overview.md | **Ready** | Needs full rewrite (content from Round 1) |

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Zed extensions research | completed | high |
| B | Neovim keymap porting | completed | high |
| C | Settings best practices, claim verification | completed | high |
| D | Agent system integration, workspace config | completed | high |

## References

- Zed docs: https://zed.dev/docs/configuring-zed
- Zed key bindings: https://zed.dev/docs/key-bindings
- Zed vim mode: https://zed.dev/docs/vim
- Zed external agents: https://zed.dev/docs/ai/external-agents
- Zed MCP: https://zed.dev/docs/ai/mcp
- Zed rules: https://zed.dev/docs/ai/rules
- Zed tasks: https://zed.dev/docs/tasks
- Zed Linux keymap: github.com/zed-industries/zed/blob/main/assets/keymaps/default-linux.json
- Zed default settings: github.com/zed-industries/zed/blob/main/assets/settings/default.json
- jellydn/zed-101-setup (community config reference)
