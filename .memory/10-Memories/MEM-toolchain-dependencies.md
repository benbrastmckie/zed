---
title: "Zed toolchain dependencies and install groups"
created: 2026-04-15
tags: [CONFIG, toolchain, dependencies, install]
topic: "zed/toolchain"
source: "docs/toolchain/"
modified: 2026-04-15
retrieval_count: 0
last_retrieved: null
keywords: [toolchain, dependencies, python, latex, typst, mcp, install, groups]
summary: "Toolchain dependencies and install groups in topological order for Python, R, LaTeX, Typst, and MCP servers"
---

# Zed Toolchain Dependencies

## Install Groups (topological order)
`base -> shell-tools -> python -> r -> typesetting -> mcp-servers`

## Base
- Xcode CLT (git, C++ compiler)
- Homebrew (package manager)
- Node.js (for MCP servers and ACP bridge)
- Zed (`brew install --cask zed`)
- Claude Code CLI (`brew install --cask claude-code`)

## Shell Tools
- **jq** — JSON processor for hooks, state queries, context discovery
- **gh** — GitHub CLI for /merge, PR/issue work
- **fontconfig** — fc-list for font verification
- **make** — optional, for Makefile-based pipelines

## Python
- **python3** — `brew install python`
- **uv/uvx** — fast package manager + ephemeral tool runner (`brew install uv`)
- **ruff** — linter + formatter, replaces black/isort/flake8 (`brew install ruff`)
- **Optional uv tools**: pytest, mypy, ipython
- **Filetypes packages**: pandas, openpyxl, python-pptx, python-docx, markitdown, xlsx2csv, pymupdf, pdfannots

## R
- **R** — `brew install r`
- **languageserver** — LSP bridge for Zed (autocomplete, go-to-definition)
- **lintr** — code checking, used by language server for diagnostics
- **styler** — code formatting, used by language server for format-on-save
- **Optional**: renv (project-local packages), Quarto (analysis reports), epidemiology R bundle (survival, brms, MatchIt, mice, etc.)

## Typesetting
- **LaTeX**: BasicTeX (100MB, recommended) or MacTeX (5GB full). Need pdflatex, latexmk, bibtex, biber
- **Typst**: `brew install typst` — single-pass, modern alternative. Auto-fetches packages from packages.typst.app
- **Pandoc**: `brew install pandoc` — universal document converter
- **markitdown**: `uv tool install markitdown` — "anything to Markdown" converter
- **Fonts**: Latin Modern Math, Computer Modern Unicode, Noto family

## MCP Servers
| Server | Install | Purpose |
|--------|---------|---------|
| superdoc | `claude mcp add --scope user superdoc -- npx @superdoc-dev/mcp` | Word doc editing |
| openpyxl | `claude mcp add --scope user openpyxl -- npx @jonemo/openpyxl-mcp` | Spreadsheet editing |
| rmcp | uvx rmcp (in .mcp.json) | R statistical modeling |
| markitdown-mcp | uvx markitdown-mcp | Document extraction |
| mcp-pandoc | uvx mcp-pandoc | Universal conversion |
| obsidian-memory | Manual setup | Memory vault search |

## Health Check
```bash
command -v R python3 uv ruff typst pandoc jq gh
```

## Connections
<!-- Add links to related memories using [[filename]] syntax -->
