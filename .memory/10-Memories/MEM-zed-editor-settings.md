---
title: "Zed editor settings configuration"
created: 2026-04-15
tags: [CONFIG, zed, settings, editor]
topic: "zed/config"
source: "settings.json"
modified: 2026-04-15
retrieval_count: 0
last_retrieved: null
keywords: [settings, theme, fonts, lsp, extensions, editor, configuration, zed]
summary: "Zed editor settings configuration including theme, fonts, LSP, extensions, and agent_servers"
---

# Zed Editor Settings Configuration

## Core Appearance
- **Theme**: One Dark
- **Font**: Fira Code, size 14 (buffer), 15 (UI)
- **Base keymap**: VSCode
- **Vim mode**: enabled (`"vim_mode": true`)
- **Tab size**: 2 (global), 4 (Python)
- **Soft wrap**: editor_width
- **Relative line numbers**: disabled
- **Indent guides**: enabled, indent_aware coloring

## Terminal
- Dock position: right
- Shell: bash
- Font size: 13
- Copy on select: enabled

## Telemetry
- Diagnostics: disabled
- Metrics: disabled

## LSP Configuration
- **markdownlint**: MD013, MD022, MD032 disabled
- **pyright**: basic type checking, openFilesOnly diagnostic mode
- **r-language-server**: diagnostics enabled, rich documentation enabled

## Language-Specific Settings
- **Markdown**: soft_wrap editor_width, tab_size 2, format on save via prettier (prose-wrap never)
- **JSON/JSONC/TOML/Nix**: tab_size 2
- **Python**: tab_size 4, language_servers [pyright, ruff], format on save via ruff
- **R**: tab_size 2, language_servers [r-language-server], format on save via r-language-server

## Auto-Install Extensions
markdown-oxide, markdownlint, codebook, csv, nix, toml, git-firefly, r, python, ruff (claude-code-extension: false)

## Claude Code Agent Server (ACP)
```jsonc
"agent_servers": {
  "claude-acp": {
    "type": "custom",
    "command": "npx",
    "args": ["@agentclientprotocol/claude-agent-acp", "--serve"],
    "env": {
      "CLAUDE_CODE_EXECUTABLE": "claude",
      "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
    }
  }
}
```

## File Scan Exclusions
.git, .svn, node_modules, target, .cache, result

## Git Integration
- Inline blame: enabled, 500ms delay

## Connections
<!-- Add links to related memories using [[filename]] syntax -->
