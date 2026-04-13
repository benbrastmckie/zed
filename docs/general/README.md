# General

Core reference documentation for this Zed configuration, focused on working in **R** and **Python** with **Claude Code**: how to install the editor, set up each language, what keys to press, and what every setting means. Start here if you are setting up the editor for the first time, or come back when you want to look up a shortcut or tweak a configuration value.

## Navigation

Files in this directory (`docs/general/`):

- **[installation.md](installation.md)** -- Step-by-step macOS setup: Xcode Command Line Tools, Homebrew, Node.js, Zed, the Claude Code CLI, the `claude-acp` bridge, and the MCP tools (SuperDoc, openpyxl). Every section begins with a "check if already installed" block so you can skip anything you already have.
- **[keybindings.md](keybindings.md)** -- Everyday Cmd-based keyboard shortcuts organized by task: panes, tabs, files, search, terminal, and the AI agent panel. Use this as a cheat sheet while you are learning the editor.
- **[settings.md](settings.md)** -- Annotated walkthrough of `settings.json`, `keymap.json`, and `tasks.json`. Explains every configuration block including `agent_servers` (the `claude-acp` bridge) and the theme, font, and editor behavior choices used here.

Language and extension toolchain docs live in [`docs/toolchain/`](../toolchain/README.md):

- **[../toolchain/python.md](../toolchain/python.md)** -- Python development setup: `uv`, `ruff`, pytest, mypy, filetypes Python packages.
- **[../toolchain/r.md](../toolchain/r.md)** -- R development setup: `languageserver`, `lintr`, `styler`, `renv`, Quarto, epidemiology R prereqs.
- **[../toolchain/README.md](../toolchain/README.md)** -- Index of every external dependency assumed by the `.claude/` extensions.

## Quick start

New to this setup? Read them in this order:

1. **[installation.md](installation.md)** -- get everything installed and authenticated
2. **[../toolchain/python.md](../toolchain/python.md)** -- set up Python (pyright + ruff + uv)
3. **[../toolchain/r.md](../toolchain/r.md)** -- set up R (r-language-server + lintr + styler)
4. **[keybindings.md](keybindings.md)** -- learn the shortcuts you will use every day
5. **[settings.md](settings.md)** -- understand and customize the configuration

## See also

- [../README.md](../README.md) -- Top-level documentation index
- [../agent-system/README.md](../agent-system/README.md) -- Claude Code and Zed AI integration overview
- [../workflows/README.md](../workflows/README.md) -- Agent task lifecycle, epi, grants, and Office file workflows
- [../../README.md](../../README.md) -- Repository README with quick start and directory layout
- [../../.memory/README.md](../../.memory/README.md) -- Shared AI memory vault
- [../../.claude/README.md](../../.claude/README.md) -- Claude Code framework architecture
