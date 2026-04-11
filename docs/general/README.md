# General

Core reference documentation for this Zed configuration on macOS, focused on working in **R** and **Python** with **Claude Code**: how to install the editor, set up each language, what keys to press, and what every setting means. Start here if you are setting up the editor for the first time, or come back when you want to look up a shortcut or tweak a configuration value.

## Navigation

Files in this directory (`docs/general/`):

- **[installation.md](installation.md)** -- Step-by-step macOS setup: Xcode Command Line Tools, Homebrew, Node.js, Zed, the Claude Code CLI, the `claude-acp` bridge, and the MCP tools (SuperDoc, openpyxl). Every section begins with a "check if already installed" block so you can skip anything you already have.
- **[python.md](python.md)** -- Python development setup: installing Python, `uv`, `ruff`, and configuring Zed's pyright + ruff language servers for type checking, linting, and format-on-save.
- **[R.md](R.md)** -- R development setup: installing R via Homebrew, the `languageserver`, `lintr`, and `styler` packages, and configuring Zed's r-language-server for diagnostics, documentation, and format-on-save.
- **[keybindings.md](keybindings.md)** -- Everyday Cmd-based keyboard shortcuts organized by task: panes, tabs, files, search, terminal, and the AI agent panel. Use this as a cheat sheet while you are learning the editor.
- **[settings.md](settings.md)** -- Annotated walkthrough of `settings.json`, `keymap.json`, and `tasks.json`. Explains every configuration block including `agent_servers` (the `claude-acp` bridge) and the theme, font, and editor behavior choices used here.

## Quick start

New to this setup? Read them in this order:

1. **[installation.md](installation.md)** -- get everything installed and authenticated
2. **[python.md](python.md)** -- set up Python (pyright + ruff + uv)
3. **[R.md](R.md)** -- set up R (r-language-server + lintr + styler)
4. **[keybindings.md](keybindings.md)** -- learn the shortcuts you will use every day
5. **[settings.md](settings.md)** -- understand and customize the configuration

## See also

- [../README.md](../README.md) -- Top-level documentation index
- [../agent-system/README.md](../agent-system/README.md) -- Claude Code and Zed AI integration overview
- [../workflows/README.md](../workflows/README.md) -- Agent task lifecycle, epi, grants, and Office file workflows
- [../../README.md](../../README.md) -- Repository README with quick start and directory layout
- [../../.memory/README.md](../../.memory/README.md) -- Shared AI memory vault
- [../../.claude/README.md](../../.claude/README.md) -- Claude Code framework architecture
