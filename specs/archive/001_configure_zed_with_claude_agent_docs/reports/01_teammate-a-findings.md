# Teammate A Findings: Primary Implementation Approach

**Task**: Configure Zed with Claude agent system documentation
**Research Angle**: Primary implementation approach
**Date**: 2026-04-09

---

## Key Findings

### 1. Claude Code in Zed Uses ACP (Agent Client Protocol), Not an Extension

The current Claude Code integration in Zed (version 0.230.1) is NOT a traditional extension -- it is a built-in agent that communicates via the Agent Client Protocol (ACP). Key facts:

- Zed auto-installs the Claude Agent adapter on first use
- Authentication uses `/login` inside the agent panel, NOT the Anthropic API key in settings.json
- The `assistant` block in settings.json configures Zed's *built-in* AI panel (different from the Claude Code agent)
- The Claude Code agent panel opens with `Ctrl+?` on Linux (not `Ctrl+Shift+/` or `Ctrl+Shift+?`)
- To start a Claude Code thread: open agent panel (`Ctrl+?`) -> click `+` -> select "Claude Code"

**Implication**: The config-report.md recommended `"assistant"` block is for Zed's own AI features, but Claude Code (the full agent with slash commands) runs separately via ACP. Both can coexist.

### 2. settings.json Structure Is Well-Understood

Zed's `settings.json` at `~/.config/zed/settings.json` supports:

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
    "toggle_relative_line_numbers": false,
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
  "assistant": {
    "enabled": true,
    "default_model": {
      "provider": "anthropic",
      "model": "claude-sonnet-4-6"
    }
  },
  "agent": {
    "default_model": {
      "provider": "anthropic",
      "model": "claude-sonnet-4-6"
    },
    "tool_permissions": {
      "default": "confirm"
    }
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
  }
}
```

**Critical note**: `vim_mode` only works in user settings (not project-level `.zed/settings.json`). Format-on-save for Markdown should be OFF to avoid reordering content in .claude/ docs.

### 3. MCP Servers Use `context_servers` Key in settings.json

MCP servers are NOT configured via Claude Code CLI for Zed (that's for the terminal-based Claude Code). For Zed, MCP servers go in `settings.json` under `context_servers`:

```json
{
  "context_servers": {
    "superdoc": {
      "source": "custom",
      "command": "npx",
      "args": ["@superdoc-dev/mcp"],
      "env": {}
    },
    "openpyxl": {
      "source": "custom",
      "command": "npx",
      "args": ["@jonemo/openpyxl-mcp"],
      "env": {}
    }
  }
}
```

The `"source": "custom"` field is mandatory -- without it Zed ignores the entry.

### 4. keymap.json for Linux (Ctrl-Based)

Linux uses `ctrl-` not `cmd-`. Essential keybindings for Claude Code and navigation:

```json
[
  {
    "context": "Workspace",
    "bindings": {
      "ctrl-shift-a": "agent::ToggleFocus"
    }
  },
  {
    "context": "VimControl && !menu",
    "bindings": {
      "space space": "file_finder::Toggle",
      "space e": "pane::RevealInProjectPanel",
      "space /": "workspace::NewSearch"
    }
  },
  {
    "context": "vim_mode == insert",
    "bindings": {
      "j k": "vim::NormalBefore"
    }
  }
]
```

For the Claude Code ACP agent specifically, the keymap uses:
```json
{
  "bindings": {
    "ctrl-alt-c": [
      "agent::NewExternalAgentThread",
      { "agent": { "custom": { "name": "claude-acp" } } }
    ]
  }
}
```

### 5. Project-Level Settings (.zed/settings.json)

A `.zed/settings.json` at the repo root can set editor behavior for this project:

```json
{
  "tab_size": 2,
  "format_on_save": "off",
  "languages": {
    "Markdown": {
      "soft_wrap": "editor_width",
      "extend_list_on_newline": true,
      "remove_trailing_whitespace_on_save": false
    }
  }
}
```

Limitations: Cannot set `vim_mode`, `theme`, or UI settings at project level -- those are user-only.

### 6. Built-in Language Support (No Extensions Needed)

Zed natively supports: JSON, Markdown, Bash, YAML. These are built-in with tree-sitter and work well for navigating `.claude/` directories.

For NixOS, the `nix` extension is available from the Zed extension registry and provides nixd/nil LSP support.

### 7. File Type Associations for .claude/ System

The `.claude/` agent system uses `.md` files with YAML frontmatter and `.json` files extensively. Useful `file_types` setting:

```json
{
  "file_types": {
    "JSONC": ["*.json5", ".zed/**/*.json"]
  }
}
```

Note: `.zed/**/*.json` files are already interpreted as JSONC by default (comments allowed).

### 8. Extensions Worth Installing

For this setup, recommended extensions:
- **Nix** -- NixOS configuration file support (important for this NixOS system)
- **TOML** -- For any TOML config files
- Built-ins cover everything else (Markdown, JSON, Bash, YAML)

No need for heavy extensions -- the `.claude/` system runs in the terminal via Claude Code CLI, not inside Zed itself.

---

## Recommended Approach

### Implementation Order

**Phase 1: Core Configuration Files**
1. Create `~/.config/zed/settings.json` with vim mode, fonts, agent config, MCP servers
2. Create `~/.config/zed/keymap.json` with Linux keybindings and Claude Code shortcut
3. Create `.zed/settings.json` in the repo root for project-level markdown settings

**Phase 2: Documentation**
4. Create `docs/` directory with these files:
   - `docs/getting-started.md` -- First-time setup: opening Zed, installing Claude Code, authenticating
   - `docs/keybindings.md` -- Complete keybinding reference for Linux
   - `docs/agent-system.md` -- How the .claude/ agent system works in Zed context
   - `docs/mcp-servers.md` -- Office file editing via SuperDoc/openpyxl
   - `docs/memory-system.md` -- The .memory/ vault and /learn command
5. Create `README.md` at repo root -- One-page orientation linking to all docs

**Phase 3: Project Context Update**
6. Update `.claude/context/repo/project-overview.md` to reflect Zed (currently describes Neovim)

### Documentation Structure

```
~/.config/zed/
├── README.md                    # Orientation: what this is, quick start
├── settings.json                # Main Zed config
├── keymap.json                  # Keybinding overrides
├── .zed/
│   └── settings.json           # Project-level editor settings
├── docs/
│   ├── getting-started.md      # Install, open, authenticate Claude Code
│   ├── keybindings.md          # Linux keyboard reference
│   ├── agent-system.md         # .claude/ commands and workflow
│   ├── mcp-servers.md          # Office file editing
│   └── memory-system.md        # .memory/ vault usage
├── .claude/                    # Agent system (already exists)
├── .memory/                    # Memory vault (already exists)
└── specs/                      # Task management (already exists)
```

### Cross-Linking Strategy

- `README.md` links to all `docs/*.md` files
- Each `docs/*.md` links back to README and to related docs
- `docs/agent-system.md` links to `.claude/README.md` and `.claude/CLAUDE.md`
- `docs/memory-system.md` links to `.memory/README.md`
- Use relative paths for all internal links

### Beginner-Friendliness Principles

1. **README.md as orientation**: Two paragraphs explaining what this is, then a "quick start" that gets Claude Code running in 3 steps
2. **Separate "what" from "how"**: Conceptual explanation first, then step-by-step instructions
3. **Concrete examples**: Show actual commands, actual keyboard shortcuts (Linux-specific)
4. **"You don't need to understand this" sections**: Flag .claude/ internals as optional reading for curious users
5. **Cheat sheet in keymap doc**: Single table with most-used shortcuts

---

## Evidence/Examples

### Claude Code Authentication Correction

The config-report.md says to verify Claude responds after setup, but the current Zed ACP integration requires:
1. Open agent panel: `Ctrl+?`
2. Click `+` -> Select "Claude Code"
3. Type `/login` in the panel to authenticate

Source: https://zed.dev/docs/ai/external-agents

### MCP Server Format Clarification

The config-report.md shows `claude mcp add --scope user superdoc -- npx @superdoc-dev/mcp`. This works for the terminal-based Claude Code CLI but NOT for Zed. Zed needs `context_servers` in `settings.json`.

Source: https://markaicode.com/mcp-zed-editor-setup/

### Vim Settings Depth

The `vim_mode: true` setting alone is functional but adding the `vim` block enables:
- `toggle_relative_line_numbers` -- switches between relative (normal mode) and absolute (insert mode)
- `use_smartcase_find` -- case-insensitive search when all lowercase
- `use_system_clipboard` -- integrates with system clipboard automatically

Source: https://zed.dev/docs/vim

### Linux Agent Panel Shortcut

On Linux, the agent panel shortcut is `Ctrl+?` (equivalent to macOS `Cmd+?`). The `secondary-` modifier maps to `ctrl` on Linux.

Source: https://zed.dev/docs/ai/external-agents

---

## Confidence Level

**High confidence**:
- settings.json structure and key options
- MCP server configuration format (`context_servers` vs `claude mcp add`)
- Claude Code ACP authentication flow (`/login` required)
- Documentation structure and cross-linking approach
- Linux keybindings (Ctrl not Cmd)

**Medium confidence**:
- Exact agent panel shortcut (`Ctrl+?` vs `Ctrl+Shift+?`) -- both appear in documentation
- Whether `context_servers` MCP entries work with the Claude Code ACP agent or only with Zed's built-in AI

**Low confidence**:
- Whether extensions like Nix are needed or already present in Zed 0.230.1
- Exact behavior of `format_on_save` with Prettier for Markdown on NixOS (Prettier may not be installed)

---

## Summary

The primary implementation approach is:
1. Create `settings.json` with corrected MCP config (`context_servers` block, not CLI commands)
2. Create `keymap.json` with Linux-appropriate shortcuts and Claude Code ACP binding
3. Create a `.zed/settings.json` for markdown-friendly project settings
4. Create `docs/` with 5 focused guides covering distinct topics
5. Create `README.md` as a beginner-friendly orientation page
6. Update `project-overview.md` to accurately describe this Zed configuration project

The documentation should consistently use Linux terminology (Ctrl not Cmd, `zeditor` not `zed`) and clearly distinguish between terminal-based Claude Code CLI (what `.claude/` commands use) and the Zed Agent Panel Claude Code (what the UI uses).
