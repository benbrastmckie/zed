# Configuration Reference

This document explains each section of the Zed configuration files (macOS). For keyboard shortcuts, see [keybindings.md](keybindings.md).

## Configuration Files

Zed reads configuration from `~/.config/zed/`:

| File | Purpose |
|------|---------|
| `settings.json` | Editor behavior, theme, fonts, languages, extensions, AI |
| `keymap.json` | Custom keyboard shortcuts (JSONC with comments) |
| `tasks.json` | Task runner definitions |

All files support JSONC format (JSON with `//` comments). Changes take effect immediately on save.

## settings.json Sections

### Theme and Appearance

```jsonc
"theme": "One Dark",
"buffer_font_size": 14,
"buffer_font_family": "JetBrains Mono",
"ui_font_size": 15,
```

The `themes/` directory can hold custom theme files. To switch themes, change the `"theme"` value or use the command palette (Cmd+Shift+P, then "theme").

### Base Keymap

```jsonc
"base_keymap": "VSCode",
```

This sets the default keybinding scheme to VSCode-style. On macOS this means Cmd-based shortcuts. No vim mode is configured.

### Editor Behavior

```jsonc
"tab_size": 2,
"soft_wrap": "preferred_line_length",
"preferred_line_length": 100,
"show_whitespaces": "boundary",
"relative_line_numbers": false,
"cursor_blink": true,
```

- **soft_wrap**: Lines wrap at the preferred line length instead of running off-screen
- **show_whitespaces**: Shows dots at word boundaries to spot extra spaces
- **relative_line_numbers**: Set to `false` for standard line numbers

### Agent (AI) Configuration (intentionally unset)

This configuration does **not** set `agent.default_model` in `settings.json`. The `agent` block governs only Zed's built-in Agent Panel (Ctrl+?) and inline assist -- it has no effect on Claude Code (Ctrl+Shift+A), which is the primary AI workflow here. Leaving the block unset lets Zed use its shipped default, which updates automatically with new Zed releases, so no manual model-ID maintenance is required.

The block name is `"agent"` (not `"assistant"` -- that was the old name).

#### If you do use the Agent Panel

If you want to pin a specific model for the Agent Panel or inline assist, Zed supports `-latest` aliases internally (see `crates/anthropic/src/anthropic.rs` in the Zed source). The `-latest` suffix auto-advances within a named model family (for example within 4.6), but will **not** jump to 4.7 or 5.x without an explicit edit -- so it is much lower maintenance than pinning a dated snapshot ID like `claude-opus-4-6-20260101`.

```jsonc
"agent": {
  "default_model": {
    "provider": "anthropic",
    "model": "claude-opus-4-6-latest"
  },
  "inline_alternatives": [
    { "provider": "anthropic", "model": "claude-sonnet-4-6-latest" }
  ]
}
```

- **default_model**: Used for the agent panel and inline assist
- **inline_alternatives**: Additional models available via the model picker

### agent_servers

The `agent_servers` block configures external agent backends that Zed spawns through the Agent Client Protocol (ACP). This is where the Claude Code thread in the Agent Panel is wired up.

There are two ways to configure `claude-acp`: the **registry** type (recommended default) and the **custom** type (for non-standard setups where the registry version does not work).

#### Registry config (recommended)

```jsonc
"agent_servers": {
  "claude-acp": {
    "type": "registry",
    "env": {}
  }
}
```

With `"type": "registry"`, Zed downloads and manages the `@zed-industries/claude-agent-acp` bridge for you. This is the right choice on macOS after installing the Claude Code CLI via Homebrew.

#### Custom config (non-standard setups)

```jsonc
"agent_servers": {
  "claude-acp": {
    "type": "custom",
    "command": "/usr/local/bin/npx",
    "args": ["@zed-industries/claude-agent-acp", "--serve"],
    "env": {}
  }
}
```

Use `"type": "custom"` when Zed cannot find `npx` on its PATH or when you need to pin a specific bridge binary. Adjust `command` to match your environment (use `which npx` to find the absolute path).

#### Environment variables

The `env` object is forwarded to the bridge process. Leave empty (`{}`) unless you need to pass something like `ANTHROPIC_API_KEY` for testing.

For the full installation walkthrough, see [installation.md](installation.md#configure-claude-acp).

### Language-Specific Settings

```jsonc
"languages": {
  "Markdown": { "soft_wrap": "preferred_line_length", "preferred_line_length": 80 },
  "Python": { "tab_size": 4 },
  ...
}
```

Override editor defaults on a per-language basis. Common overrides are tab size and line length.

### Auto-Install Extensions

```jsonc
"auto_install_extensions": {
  "markdown-oxide": true,
  "markdownlint": true,
  "codebook": true,
  "csv": true,
  "claude-code-extension": true,
  "nix": true,
  "toml": true,
  "git-firefly": true
}
```

These extensions install automatically when Zed opens. Key extensions:

- **claude-code-extension**: Integrates Claude Code with Zed via ACP
- **markdown-oxide**: Enhanced Markdown editing (wiki-links, backlinks)
- **markdownlint**: Markdown style linting
- **codebook**: Notebook support
- **nix**: Nix language support (syntax, LSP)

### Terminal

```jsonc
"terminal": {
  "shell": { "program": "bash" },
  "font_size": 13,
  "copy_on_select": true
}
```

### Telemetry

```jsonc
"telemetry": {
  "diagnostics": false,
  "metrics": false
}
```

Both are disabled.

## keymap.json Structure

The keymap file is a JSON array of binding objects. Each object has a `context` (where the binding applies) and `bindings` (the actual shortcuts).

```jsonc
[
  {
    "context": "Workspace",
    "bindings": {
      "ctrl-h": "workspace::ActivatePaneLeft"
    }
  }
]
```

### Keybinding Scheme A (Current)

We use a minimal set of 6 custom bindings:

| Shortcut | Action | Context |
|----------|--------|---------|
| Ctrl+H | Focus pane left | Workspace |
| Ctrl+J | Focus pane down | Workspace |
| Ctrl+K | Focus pane up | Workspace |
| Ctrl+L | Focus pane right | Workspace |
| Alt+J | Move line down | Editor |
| Alt+K | Move line up | Editor |

The pane-navigation bindings intentionally use Ctrl (not Cmd) so they do not collide with macOS system-wide shortcuts. On macOS keyboards, Alt is labeled Option.

### Adding More Bindings

1. Open `keymap.json` (Cmd+P, type "keymap")
2. Add a new object inside the array with `context` and `bindings`
3. Check the default reference comments at the bottom of the file to avoid conflicts
4. Save -- changes apply immediately

To find action names, open the command palette (Cmd+Shift+P) and note the action name shown next to each command.

### Context Scoping

Bindings are scoped by context. For example, Ctrl+H means "focus pane left" in the Workspace context but has a different meaning in the Editor context (Zed default). This avoids conflicts.

Common contexts:
- `Workspace` -- applies everywhere in Zed
- `Editor` -- applies only when editing text
- `Terminal` -- applies only in the terminal panel
- `Agent` -- applies only in the agent panel

## tasks.json Structure

The tasks file defines commands available from the task runner (Cmd+Shift+P, then "task: spawn").

```json
[
  {
    "label": "Git Status",
    "command": "git",
    "args": ["status", "--short"],
    "tags": ["git"]
  }
]
```

- **label**: Display name in the task picker
- **command**: The program to run
- **args**: Arguments; `$ZED_FILE` is replaced with the current file path
- **tags**: Categories for filtering

## Platform Notes

- **Install**: `brew install --cask zed` (Homebrew)
- **Config location**: `~/.config/zed/`
- **Keyboard**: All shortcuts use Cmd by default on macOS; the custom pane-navigation bindings use Ctrl to avoid macOS system shortcut collisions

## Related Documentation

- [Keybindings guide](keybindings.md) -- Everyday shortcuts
- [Agent system](../agent-system/README.md) -- AI integration
- [Workflows](../workflows/README.md) -- Agent task lifecycle and Office file workflows
- [docs README](../README.md) -- Navigation hub
