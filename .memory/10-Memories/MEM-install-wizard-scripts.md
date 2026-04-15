---
title: "Installation wizard and Zed helper scripts"
created: 2026-04-15
tags: [WORKFLOW, install, scripts, zed]
topic: "zed/install"
source: "scripts/install/, .zed/tasks.json, .zed/scripts/"
modified: 2026-04-15
---

# Installation Wizard and Zed Scripts

## Install Wizard (scripts/install/install.sh)
- **Platform**: macOS (Homebrew)
- **6 groups** in topological order: base -> shell-tools -> python -> r -> typesetting -> mcp-servers
- **Interactive prompts**: accept (a) / skip (s) / cancel (c) per group
- **Subprocess isolation**: each group runs in child bash; failure doesn't abort wizard
- **Flags**: `--dry-run` (preview), `--check` (health report), `--help`
- **Exit codes**: 0=success, 1=check found missing, 2=cancelled, 3=prereq failure, 4=group failure
- **Hard invariant**: never reads any markdown file at runtime

### Group Scripts
Each supports `--dry-run`, `--check`, `--help` independently:
- `install-base.sh` — Xcode CLT, Homebrew, Node.js, Zed, Claude Code CLI, SuperDoc+openpyxl MCP
- `install-shell-tools.sh` — jq, gh, fontconfig, optional make
- `install-python.sh` — python3, uv, ruff, optional uv tools + filetypes packages
- `install-r.sh` — R, languageserver/lintr/styler, optional renv/Quarto/epi bundle
- `install-typesetting.sh` — LaTeX, Typst, Pandoc, markitdown, fonts
- `install-mcp-servers.sh` — rmcp, markitdown-mcp, mcp-pandoc, obsidian-memory pointer

### Shared Library (lib.sh)
Common functions used by all group scripts.

## Zed Task Definitions

### .zed/tasks.json (project-level)
- **Claude Code** — `claude --dangerously-skip-permissions`, new terminal, concurrent runs, dock
- **Build PDF** — `.zed/scripts/build-pdf.sh "$ZED_FILE"`, dispatches by extension (.typ/.md)
- **Preview in Browser** — `.zed/scripts/preview.sh "$ZED_FILE"`, dispatches by extension

### tasks.json (root-level)
- **Open in LibreOffice** — `libreoffice $ZED_FILE`
- **Export Agent System** — `.claude/scripts/export-to-markdown.sh`
- **Git Status** — `git status --short`

## Helper Scripts (.zed/scripts/)

### build-pdf.sh
- `.typ` -> `typst compile` with desktop notification
- `.md` -> `npx @slidev/cli export` with notification
- On failure: notification + opens error log

### preview.sh
- `.typ` -> `tinymist preview --open`
- `.md` -> `cd dir && pnpm dev` (Slidev dev server)

### slidev-export.sh
- Silent Slidev PDF export with desktop notifications

## Connections
<!-- Add links to related memories using [[filename]] syntax -->
