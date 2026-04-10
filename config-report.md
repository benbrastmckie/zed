# Zed Configuration Setup Report

**Generated**: 2026-04-09
**Zed Version**: 0.230.1
**Platform**: macOS (installed via Homebrew: `brew install --cask zed`)

---

## Current State

| Item | Status |
|------|--------|
| Zed installed | Yes (`/run/current-system/sw/bin/zeditor`) |
| Config directory | `~/.config/zed/` (nearly empty) |
| settings.json | Missing -- needs creation |
| keymap.json | Missing -- needs creation |
| Extensions | Only `html` installed |
| Claude Code extension | Not installed |
| MCP servers (superdoc, openpyxl) | Not configured |
| Node.js/npx | Available (v24.14.0) |
| Documentation | No manpages; docs at https://zed.dev/docs |

## Setup Steps

### Step 1: Create settings.json

Create `~/.config/zed/settings.json`. This is the main config file (equivalent to nvim's init.lua).

Open Zed and use the command palette (`Ctrl+Shift+P`) then type "Open Settings" to get the
default scaffold, or create it manually:

```json
{
  "theme": "One Dark",
  "ui_font_size": 16,
  "buffer_font_size": 14,
  "buffer_font_family": "RobotoMono Nerd Font",
  "vim_mode": true,
  "tab_size": 2,
  "format_on_save": "on",
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
  }
}
```

Key settings reference: https://zed.dev/docs/configuring-zed

### Step 2: Create keymap.json

Create `~/.config/zed/keymap.json` for keybinding overrides.

```json
[
  {
    "context": "Workspace",
    "bindings": {
      "ctrl-shift-/": "assistant::ToggleFocus"
    }
  }
]
```

Keybindings reference: https://zed.dev/docs/key-bindings

### Step 3: Install Claude Code Extension

1. Open Zed: `zeditor`
2. Open Extensions: `Ctrl+Shift+X` (or command palette -> "Extensions: Install")
3. Search for "Claude Code"
4. Click Install

Once installed, the Agent Panel opens with `Ctrl+Shift+?` (or `Ctrl+Shift+/`).

### Step 4: Configure MCP Servers for Office Files

These give Claude the ability to edit .docx and .xlsx files properly.

```bash
# Word document editing with tracked changes
claude mcp add --scope user superdoc -- npx @superdoc-dev/mcp

# Excel spreadsheet editing
claude mcp add --scope user openpyxl -- npx @jonemo/openpyxl-mcp

# Verify
claude mcp list
```

Node.js is already available (v24.14.0), so npx will work.

### Step 5: Verify Setup

1. Open Zed: `zeditor`
2. Open Agent Panel: `Ctrl+Shift+?`
3. Type: "Hello, what can you help me with?"
4. Verify Claude responds

### Step 6 (Optional): Add to Dotfiles

If you want Zed config managed by your dotfiles repo:

**Option A -- Symlink via Home Manager** (like nvim):
Add to `home.nix`:
```nix
xdg.configFile."zed/settings.json".source = ./config/zed/settings.json;
xdg.configFile."zed/keymap.json".source = ./config/zed/keymap.json;
```

**Option B -- Track directly**:
Since `~/.config/zed/` is not currently managed by Home Manager, you can just
track the files in git separately or symlink manually.

---

## Documentation and Reference

### Where Zed Docs Live

Zed has no manpages or bundled documentation. All docs are online:

| Resource | URL |
|----------|-----|
| Main docs | https://zed.dev/docs |
| Configuration | https://zed.dev/docs/configuring-zed |
| Key bindings | https://zed.dev/docs/key-bindings |
| Vim mode | https://zed.dev/docs/vim |
| Extensions | https://zed.dev/docs/extensions |
| Assistant/AI | https://zed.dev/docs/assistant |
| Languages | https://zed.dev/docs/languages |
| Linux-specific | https://zed.dev/docs/linux |
| Release notes | https://zed.dev/releases |

### Config File Locations

| File | Purpose |
|------|---------|
| `~/.config/zed/settings.json` | Main settings (theme, font, editor behavior, AI) |
| `~/.config/zed/keymap.json` | Keybinding overrides |
| `~/.config/zed/themes/` | Custom themes |
| `~/.config/zed/tasks.json` | Custom task definitions (build/run commands) |
| `~/.config/zed/snippets/` | Code snippets |
| `~/.local/share/zed/extensions/` | Installed extensions (managed by Zed) |
| `~/.local/share/zed/logs/` | Log files |
| `~/.local/share/zed/db/` | Internal databases |

### Comparison with Neovim Config

| Aspect | Neovim (~/.config/nvim/) | Zed (~/.config/zed/) |
|--------|--------------------------|----------------------|
| Config format | Lua scripts | JSON files |
| Complexity | High (plugin ecosystem, LSP, treesitter) | Low (2-3 JSON files) |
| Plugin management | lazy.nvim (manual) | Built-in extension panel |
| LSP | Manual config per language | Automatic via extensions |
| Key files | init.lua + lua/**/*.lua | settings.json + keymap.json |
| AI integration | Via terminal (claude) | Built-in Agent Panel |

Zed is intentionally simpler to configure than Neovim. Most functionality
works out of the box; configuration is primarily about preferences, not setup.

---

## Included Files

- `README.md` -- This setup report
- `zed-claude-office-guide.md` -- Guide for Claude Code + Office file workflows (copied from nvim specs)
