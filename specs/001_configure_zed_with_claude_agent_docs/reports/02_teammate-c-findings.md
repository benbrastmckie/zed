# Round 2 Research Report: Teammate C (Critic) Findings

**Task**: 1 - Configure Zed with Claude agent system documentation
**Role**: Critic — best practices verification and Round 1 claim checking
**Round**: 2
**Date**: 2026-04-09
**Focus**: Settings.json best practices, verified/corrected Round 1 claims, exact formats

---

## Key Findings

### 1. Agent Panel Shortcut: `Ctrl+?` Is Confirmed

The Linux default keymap binds `ctrl-?` to `agent::ToggleFocus` in the Workspace context.

Verified from the raw default-linux.json keymap:
```
"ctrl-?" -> "agent::ToggleFocus"  (Workspace context)
```

**Round 1 claim**: "`Ctrl+?` on Linux (medium confidence)" — now HIGH confidence. The mapping
is `ctrl-?` (not `Ctrl+Shift+?`). The earlier confusion likely arose from macOS docs showing
`cmd-?` being read as `Ctrl+Shift+?` (the character `?` requires Shift on US keyboards, but
Zed treats `ctrl-?` as a direct binding, not `ctrl-shift-/`).

**Implication for keymap.json**: Any custom binding should use `ctrl-shift-a` or similar if
remapping the agent panel — or simply rely on the default `ctrl-?`.

---

### 2. Claude Code ACP: Auto-Install Confirmed, `agent_servers` Key for Customization

From the official Zed docs on external agents:

> "The first time you create a Claude Agent thread, Zed will install
> @zed-industries/claude-agent-acp. This installation is only available to Zed and is kept
> up to date as you use the agent."

**What this means**:
- No extension installation step required in setup docs
- No `claude mcp add` step needed for Zed's Claude Code integration
- Zed manages the ACP adapter independently, even if `claude` CLI is installed globally

**Registry name** for claude-acp is `claude-acp`. To customize:
```json
{
  "agent_servers": {
    "claude-acp": {
      "type": "registry",
      "env": {
        "CLAUDE_CODE_EXECUTABLE": "/path/to/alternate-claude-code-executable"
      }
    }
  }
}
```

**Round 1 claim**: "Claude Code uses ACP and auto-installs" — CONFIRMED.

---

### 3. `context_servers` Format: `"source"` Field Is NOT Documented

Round 1 (Teammate A) claimed: "The `'source': 'custom'` field is mandatory — without it Zed
ignores the entry."

**Research finding**: The official Zed MCP documentation shows context_servers WITHOUT a
`source` field:

```json
{
  "context_servers": {
    "local-mcp-server": {
      "command": "some-command",
      "args": ["arg-1", "arg-2"],
      "env": {}
    }
  }
}
```

The `source` field does NOT appear in any official Zed documentation or the default.json.
It may have existed in an older Zed version or been confused with a third-party tutorial.

**Corrected format** for MCP servers in settings.json:
```json
{
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
  }
}
```

For remote MCP servers:
```json
{
  "context_servers": {
    "remote-server": {
      "url": "https://mcp.example.com/mcp",
      "headers": { "Authorization": "Bearer <token>" }
    }
  }
}
```

**Risk**: If `"source": "custom"` is currently working in someone's config, it may be silently
ignored (Zed is likely tolerant of unknown fields). The correct format does not need it.

---

### 4. Agent Block: Confirmed Default Structure from Source

From Zed's actual default.json:

```json
{
  "agent": {
    "enabled": true,
    "button": true,
    "dock": "left",
    "default_model": {
      "provider": "zed.dev",
      "model": "claude-sonnet-4",
      "enable_thinking": false
    },
    "tool_permissions": {
      "default": "confirm"
    },
    "default_profile": "write",
    "profiles": {
      "write": { ... },
      "ask": { ... },
      "minimal": { ... }
    },
    "play_sound_when_agent_done": "never",
    "expand_edit_card": true,
    "expand_terminal_card": true,
    "use_modifier_to_send": false
  }
}
```

**Key insight**: The model name in defaults is `"claude-sonnet-4"` (not `"claude-sonnet-4-6"`).
The exact model ID depends on the Zed version. For the Anthropic provider directly (using your
own API key):

```json
{
  "agent": {
    "default_model": {
      "provider": "anthropic",
      "model": "claude-sonnet-4-6"
    }
  }
}
```

**Note**: Zed also supports `"provider": "zed.dev"` for hosted access (no API key required,
uses Zed's account). This is likely preferable for the beginner audience.

---

### 5. Markdown Language Block: Confirmed Defaults

From Zed's default.json, the Markdown block defaults are:
```json
{
  "languages": {
    "Markdown": {
      "format_on_save": "off",
      "use_on_type_format": false,
      "remove_trailing_whitespace_on_save": false,
      "allow_rewrap": "anywhere",
      "soft_wrap": "editor_width",
      "completions": {
        "words": "disabled"
      },
      "prettier": {
        "allowed": true
      }
    }
  }
}
```

`format_on_save: "off"` and `remove_trailing_whitespace_on_save: false` are already the Zed
defaults for Markdown. The settings.json only needs to override what differs from defaults.

**Recommendation**: Keep these explicit in the config for clarity (makes the intent visible),
but know they are not strictly necessary to set.

---

### 6. Vim Mode Block: Full Options Confirmed

```json
{
  "vim_mode": true,
  "vim": {
    "default_mode": "normal",
    "use_system_clipboard": "always",
    "use_smartcase_find": true,
    "toggle_relative_line_numbers": true,
    "gdefault": false,
    "highlight_on_yank_duration": 200
  }
}
```

`toggle_relative_line_numbers: true` is a high-value setting: shows relative numbers in Normal
mode and absolute numbers in Insert mode — exactly like Neovim's `relativenumber` + `number`
combination with autocmd.

**Important**: `vim_mode` is user-level only — cannot be set in `.zed/settings.json`.

---

### 7. Complete Agent Panel Keyboard Shortcuts (Linux Default)

From the raw Linux keymap — AI-related bindings:

| Shortcut | Action | Context |
|----------|--------|---------|
| `ctrl-?` | `agent::ToggleFocus` | Workspace |
| `ctrl-n` | `agent::NewThread` | AgentPanel |
| `ctrl-shift-h` | `agent::OpenHistory` | AgentPanel |
| `ctrl-alt-c` | `agent::OpenSettings` | AgentPanel |
| `ctrl-;` | `agent::OpenAddContextMenu` | AcpThread > Editor |
| `ctrl-enter` | `agent::ChatWithFollow` | AcpThread > Editor |
| `ctrl-shift-enter` | `agent::SendImmediately` | AcpThread > Editor |
| `ctrl-alt-k` | `agent::ToggleThinkingMode` | AcpThread > Editor |
| `ctrl-shift-r` | `agent::OpenAgentDiff` | AcpThread > Editor |
| `ctrl-[` | `agent::CyclePreviousInlineAssist` | InlineAssistant |
| `ctrl-]` | `agent::CycleNextInlineAssist` | InlineAssistant |
| `ctrl-enter` | `assistant::InlineAssist` | Editor (full mode) |

**Clarification**: `ctrl-alt-c` opens Agent Settings (not Claude Code). To start a new Claude
agent thread, use `ctrl-n` from within the agent panel after opening it with `ctrl-?`.

---

### 8. Rules Integration: CLAUDE.md Already Supported

Zed's agent system natively reads `CLAUDE.md` (confirmed in docs for rules discovery):

> "Zed supports... CLAUDE.md (and GEMINI.md)" as auto-included project rules.

This means the `.config/zed/.claude/CLAUDE.md` hierarchy is automatically loaded by Zed's
Claude agent — no configuration needed. The agent panel will pick up `.claude/CLAUDE.md`
when `~/.config/zed/` is the open workspace.

**Critical for docs**: This mechanism should be explicitly documented — the agent reads
CLAUDE.md up the directory tree from the open workspace root.

---

### 9. Project-Level Settings (.zed/settings.json) Scope

Project-level settings support all language-specific overrides and LSP settings, but NOT:
- `vim_mode` (user-level only)
- `theme` (user-level only)
- `ui_font_size`, `buffer_font_family` (user-level only)

Useful project-level settings for `.config/zed/`:
```json
{
  "tab_size": 2,
  "format_on_save": "off",
  "languages": {
    "Markdown": {
      "soft_wrap": "editor_width",
      "remove_trailing_whitespace_on_save": false
    },
    "JSON": {
      "tab_size": 2
    }
  }
}
```

---

### 10. `assistant` Block Is Redundant with `agent` Block

The Round 1 recommended settings.json includes both an `assistant` block and an `agent` block.
Investigation shows:

- The `assistant` block was the pre-2024 configuration for Zed's AI panel
- Zed renamed and restructured this to the `agent` block
- Setting `"assistant": { "enabled": true }` likely still works for backward compatibility
- But the current API is `"agent"` — prefer that

**Recommendation**: Use only the `agent` block. The `assistant` block in Round 1's config is
likely a legacy holdover from an older Zed version.

---

## Corrected settings.json

Based on verified findings, here is the corrected recommended `settings.json`:

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
  }
}
```

**Changes from Round 1**:
- Removed `"assistant"` block (redundant; `"agent"` is the current API)
- Removed `"source": "custom"` from `context_servers` entries (not in official docs)
- Model stays `claude-sonnet-4-6` (explicit version, using Anthropic provider directly)
- Added `"play_sound_when_agent_done": "never"` (practical for focus work)

---

## Gaps Remaining After Round 2

1. **Whether `"source": "custom"` breaks or is silently ignored**: The field may be harmless
   (Zed likely ignores unknown JSON keys), but it should not appear in documented configs.
   Needs live testing to confirm `context_servers` without `source` field activates MCP servers.

2. **`"provider": "anthropic"` vs `"provider": "zed.dev"`**: The zed.dev provider uses Zed's
   hosted access (account-based, no API key). The anthropic provider requires an API key via
   the UI or `ANTHROPIC_API_KEY` env var. For the beginner audience, `zed.dev` may be better
   (no API key management). The settings.json should document both options.

3. **One Dark theme availability**: Still unconfirmed whether it is a Zed built-in or requires
   extension install. Zed's extension registry includes One Dark, but whether it ships bundled
   with Zed varies by version.

4. **`agent_servers` for claude-acp customization**: The `CLAUDE_CODE_EXECUTABLE` env var in
   `agent_servers.claude-acp` would allow pointing to the NixOS-installed `claude` binary at
   `/home/benjamin/.npm/_npx/.../claude`. This may be worth documenting as optional.

---

## Confidence Summary

| Claim | Round 1 Status | Round 2 Verdict |
|-------|----------------|-----------------|
| Claude Code uses ACP | CLAIMED | CONFIRMED |
| ACP auto-installs on first use | CLAIMED | CONFIRMED |
| Agent panel shortcut `Ctrl+?` | MEDIUM confidence | HIGH confidence — direct from Linux keymap |
| `context_servers` with `"source": "custom"` | CLAIMED mandatory | UNCONFIRMED — field absent from all official docs |
| `context_servers` without `source` field | Not mentioned | LIKELY CORRECT per official docs |
| `assistant` block for built-in AI | CLAIMED separate | PARTIALLY CORRECT — but `agent` block is current API |
| Markdown `format_on_save: off` as override | CLAIMED needed | CONFIRMED as Zed default (explicit is still OK) |
| `vim_mode` user-level only | CLAIMED | CONFIRMED |
| CLAUDE.md auto-loaded by Zed | ASSUMED | CONFIRMED — Zed's rules system natively reads CLAUDE.md |

---

## Evidence Sources

- Official Zed docs: https://zed.dev/docs/ai/external-agents
- Official Zed docs: https://zed.dev/docs/ai/mcp
- Official Zed docs: https://zed.dev/docs/ai/rules
- Official Zed docs: https://zed.dev/docs/ai/agent-settings
- Official Zed docs: https://zed.dev/docs/vim
- Raw Linux keymap: https://raw.githubusercontent.com/zed-industries/zed/main/assets/keymaps/default-linux.json
- Raw default settings: https://raw.githubusercontent.com/zed-industries/zed/main/assets/settings/default.json
