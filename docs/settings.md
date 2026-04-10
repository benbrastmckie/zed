# Configuration Reference

This document explains each section of the Zed configuration files. For keyboard shortcuts, see [guides/keybindings.md](guides/keybindings.md).

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

The `themes/` directory can hold custom theme files. To switch themes, change the `"theme"` value or use the command palette (Ctrl+Shift+P, then "theme").

### Base Keymap

```jsonc
"base_keymap": "VSCode",
```

This sets the default keybinding scheme to VSCode-style (Ctrl-based). No vim mode is configured.

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

### Agent (AI) Configuration

```jsonc
"agent": {
  "default_model": {
    "provider": "anthropic",
    "model": "claude-sonnet-4-20250514"
  },
  "inline_alternatives": [
    {
      "provider": "anthropic",
      "model": "claude-opus-4-20250514"
    }
  ]
}
```

This configures Zed's built-in agent panel. The block is named `"agent"` (not `"assistant"` -- that was the old name).

- **default_model**: Used for the agent panel and inline assist
- **inline_alternatives**: Additional models available via the model picker

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

### Adding More Bindings

1. Open `keymap.json` (Ctrl+P, type "keymap")
2. Add a new object inside the array with `context` and `bindings`
3. Check the default reference comments at the bottom of the file to avoid conflicts
4. Save -- changes apply immediately

To find action names, open the command palette (Ctrl+Shift+P) and note the action name shown next to each command.

### Context Scoping

Bindings are scoped by context. For example, Ctrl+H means "focus pane left" in the Workspace context but "find and replace" in the Editor context (Zed default). This avoids conflicts.

Common contexts:
- `Workspace` -- applies everywhere in Zed
- `Editor` -- applies only when editing text
- `Terminal` -- applies only in the terminal panel
- `Agent` -- applies only in the agent panel

## tasks.json Structure

The tasks file defines commands available from the task runner (Ctrl+Shift+P, then "task: spawn").

```json
[
  {
    "label": "Open in LibreOffice",
    "command": "libreoffice",
    "args": ["$ZED_FILE"],
    "tags": ["office"]
  }
]
```

- **label**: Display name in the task picker
- **command**: The program to run
- **args**: Arguments; `$ZED_FILE` is replaced with the current file path
- **tags**: Categories for filtering

## Platform Notes

- **Binary name**: On NixOS, the Zed binary is `zeditor` (not `zed`)
- **Config location**: `~/.config/zed/`
- **Keyboard**: All shortcuts use Ctrl (not Cmd) on Linux

## Related Documentation

- [Keybindings guide](guides/keybindings.md) -- Everyday shortcuts
- [Agent system](agent-system.md) -- AI integration
- [Office workflows](office-workflows.md) -- Working with Office files
- [README](../README.md) -- Navigation hub
