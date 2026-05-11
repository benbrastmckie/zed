# Teammate A Findings: Extension Audit & Documentation Assessment

**Task**: 82 — Improve documentation and installation script for dual agent systems
**Date**: 2026-05-11
**Angle**: Primary — comprehensive inventory of extensions, docs state, and install scripts
**Confidence**: High

---

## Key Findings

1. **Both systems share the same 9 extensions** (core, epidemiology, filetypes, latex, memory, present, python, slidev, typst), sourced from a common nvim config upstream but installed into their respective directory trees (`.claude/` vs `.opencode/`).

2. **The README.md and docs/ make zero mention of OpenCode** — the entire documentation treats the repo as Claude-Code-only, despite `.opencode/` being a fully functional parallel system with 213+ installed core files.

3. **The install script only installs Claude Code CLI** (`brew install --cask claude-code`) — there is no option to install OpenCode or its dependencies. OpenCode is not even mentioned in the install wizard.

4. **Naming inconsistencies exist between systems** — e.g., `skill-epi-research` vs `skill-epidemiology-research`, `skill-filetypes-spreadsheet` vs `skill-spreadsheet`, `docx-edit-agent` (Claude-only), `deck-agent` (OpenCode-only).

5. **The `.opencode/` system has its own rich internal docs** (README.md at 200+ lines, AGENTS.md, docs/ tree) that are completely invisible from the user-facing docs/.

---

## Extension Inventory

### 1. Core Extension

| Aspect | .claude/ | .opencode/ |
|--------|----------|------------|
| **Version** | 2.0.0 | 1.0.0 |
| **Installed files** | 210 files, 46 dirs | 213 files, 48 dirs |
| **Source** | nvim/.claude/extensions/core | nvim/.opencode/extensions/core |
| **Description** | Core agent system | Core agent system foundation |

**Provides**: All base commands (27 in .claude, 25 in .opencode), agents (7 core), skills (21 core), rules, scripts, hooks, context, docs, templates, systemd timers.

**Differences**:
- .claude has `distill.md`, `edit.md`, `epi.md`, `scrape.md` commands — .opencode does not
- .opencode has `deck.md`, `project-overview.md` commands — .claude does not
- .opencode has `skill-project-overview` — .claude does not

### 2. Epidemiology Extension

| Aspect | .claude/ | .opencode/ |
|--------|----------|------------|
| **Version** | 2.0.0 | 1.0.0 |
| **Installed files** | 20 files, 3 dirs | 9 files, 4 dirs |
| **Dependencies** | core | core |

**Provides**: Study design, causal inference, missing data analysis, statistical modeling, STROBE reporting. Routes task types `epi`, `epi:study`, `epidemiology`.

**Skill/Agent naming differences**:
- .claude: `skill-epi-research`, `skill-epi-implement`, `epi-research-agent`, `epi-implement-agent`
- .opencode: `skill-epidemiology-research`, `skill-epidemiology-implementation`, `epidemiology-research-agent`, `epidemiology-implementation-agent`

**Context**: Both share epidemiology domain context (study-designs, causal-inference, missing-data, data-management, reporting-standards, r-workflow, statistical-modeling, observational-methods, analysis-phases, strobe-checklist, R packages/tools, templates).

### 3. Filetypes Extension

| Aspect | .claude/ | .opencode/ |
|--------|----------|------------|
| **Version** | 2.2.0 | 2.2.0 |
| **Installed files** | 29 files, 7 dirs | 25 files, 7 dirs |
| **Dependencies** | core | core |

**Provides**: Document conversion (PDF/DOCX/Markdown), spreadsheet handling, presentation extraction, PDF annotation scraping, DOCX editing, XLSX creation/analysis.

**Skill/Agent differences**:
- .claude has: `skill-docx-edit` + `docx-edit-agent`, `skill-scrape` + `scrape-agent`, `skill-filetypes-spreadsheet` + `filetypes-spreadsheet-agent`
- .opencode has: `skill-spreadsheet` + `spreadsheet-agent`, `skill-deck` + `deck-agent` (not in .claude)
- Both have: `skill-filetypes`, `skill-presentation`, `skill-sheet`, `filetypes-router-agent`, `sheet-agent`, `document-agent`, `presentation-agent`

### 4. LaTeX Extension

| Aspect | .claude/ | .opencode/ |
|--------|----------|------------|
| **Version** | 1.0.0 | 1.0.0 |
| **Installed files** | 15 files, 3 dirs | 16 files, 4 dirs |
| **Dependencies** | core | core |

**Provides**: LaTeX document research and implementation. Routes task type `latex`.

**Skills**: `skill-latex-research`, `skill-latex-implementation` (identical naming)
**Agents**: `latex-research-agent`, `latex-implementation-agent` (identical naming)
**Context**: LaTeX domain knowledge, standards, patterns.

### 5. Memory Extension

| Aspect | .claude/ | .opencode/ |
|--------|----------|------------|
| **Version** | 1.0.0 | 1.0.0 |
| **Installed files** | 11 files, 2 dirs | 9 files, 3 dirs |
| **Dependencies** | core | core |

**Provides**: Knowledge capture/retrieval, vault management, distillation, MCP integration with Obsidian-compatible format.

**Skills**: `skill-memory` (identical naming, both)
**Commands**: .claude has `/learn` and `/distill`; .opencode has `/learn` only (no `/distill`)

### 6. Present Extension

| Aspect | .claude/ | .opencode/ |
|--------|----------|------------|
| **Version** | 1.0.0 | 1.0.0 |
| **Installed files** | 89 files, 8 dirs | 90 files, 9 dirs |
| **Dependencies** | core, slidev | core, slidev |

**Provides**: Grant proposals, budgets, timelines, funding analysis, academic talks/presentations, slide planning, slide critique. Routes task types `present`, `present:grant`, `present:budget`, `present:timeline`, `present:funds`, `present:slides`.

**Skills** (both systems): `skill-grant`, `skill-budget`, `skill-timeline`, `skill-funds`, `skill-slides`, `skill-slide-planning`, `skill-slide-critic`
**Agents** (both): `grant-agent`, `budget-agent`, `timeline-agent`, `funds-agent`, `slides-research-agent`, `pptx-assembly-agent`, `slidev-assembly-agent`, `slide-planner-agent`, `slide-critic-agent`

**Context**: Funder types, grant writing patterns, budget justification, talk library (patterns, templates, components, themes), Slidev configuration.

### 7. Python Extension

| Aspect | .claude/ | .opencode/ |
|--------|----------|------------|
| **Version** | 1.0.0 | 1.0.0 |
| **Installed files** | 10 files, 3 dirs | 11 files, 4 dirs |
| **Dependencies** | core | core |

**Provides**: Python development support with pytest, type checking (mypy), linting (ruff). Routes task type `python`.

**Skills**: `skill-python-research`, `skill-python-implementation` (identical naming)
**Agents**: `python-research-agent`, `python-implementation-agent` (identical naming)
**Context**: Code style standards, testing patterns, application/library patterns, semantic evaluation patterns.

### 8. Slidev Extension

| Aspect | .claude/ | .opencode/ |
|--------|----------|------------|
| **Version** | 1.0.0 | 1.0.0 |
| **Installed files** | 15 files, 1 dir | 16 files, 2 dirs |
| **Dependencies** | core | core |

**Provides**: Shared Slidev animation patterns and CSS style presets for deck/slide agents. No routing (dependency of present extension). No skills or agents of its own.

**Context**: Animation patterns, CSS presets, Slidev configuration templates.

### 9. Typst Extension

| Aspect | .claude/ | .opencode/ |
|--------|----------|------------|
| **Version** | 1.0.0 | 1.0.0 |
| **Installed files** | 30 files, 3 dirs | 31 files, 4 dirs |
| **Dependencies** | core | core |

**Provides**: Typst document research and implementation with single-pass compilation. Routes task type `typst`.

**Skills**: `skill-typst-research`, `skill-typst-implementation` (identical naming)
**Agents**: `typst-research-agent`, `typst-implementation-agent` (identical naming)
**Context**: Typst standards, fletcher diagrams, document patterns.

---

## Summary: What's Common vs Unique

### Commands unique to .claude/ (4)
- `/distill` — Memory vault maintenance
- `/edit` — DOCX editing with tracked changes
- `/epi` — Epidemiology study design routing
- `/scrape` — PDF annotation extraction

### Commands unique to .opencode/ (2)
- `/deck` — Deck/presentation creation
- `/project-overview` — Generate project overview

### Skills unique to .claude/ (5)
- `skill-docx-edit`, `skill-epi-implement`, `skill-epi-research`, `skill-filetypes-spreadsheet`, `skill-scrape`

### Skills unique to .opencode/ (5)
- `skill-deck`, `skill-epidemiology-implementation`, `skill-epidemiology-research`, `skill-project-overview`, `skill-spreadsheet`

### Agents unique to .claude/ (5)
- `docx-edit-agent`, `epi-implement-agent`, `epi-research-agent`, `filetypes-spreadsheet-agent`, `scrape-agent`

### Agents unique to .opencode/ (4)
- `deck-agent`, `epidemiology-implementation-agent`, `epidemiology-research-agent`, `spreadsheet-agent`

---

## Current Documentation Assessment

### README.md (258 lines)
- **Comprehensive for Claude Code** — good Quick Start, walkthrough, command catalog, directory layout
- **Zero mention of OpenCode** — `.opencode/` is completely absent from README
- **Directory Layout section** omits `.opencode/` entirely
- **Install section** only covers Claude Code CLI
- **"Claude Code Commands" section** needs renaming or splitting if covering both systems
- References `docs/agent-system/` which also only covers Claude Code

### docs/ Directory (28 markdown files across 4 sections)
- `docs/general/` — Installation, keybindings, settings (no OpenCode)
- `docs/agent-system/` — Architecture, commands, context/memory, Zed agent panel (mentions Claude Code only; agent-system/README.md briefly mentions "Two AI systems" but only Zed Agent Panel and Claude Code)
- `docs/toolchain/` — Python, R, shell tools, typesetting, MCP, extensions, Slidev
- `docs/workflows/` — Agent lifecycle, epi, grants, Word/spreadsheet editing, memory, tips

### .claude/ Internal Docs
- `.claude/CLAUDE.md` (always-loaded quick reference) — well-maintained
- `.claude/docs/` — architecture, examples, guides, reference, templates (agent-facing)

### .opencode/ Internal Docs
- `.opencode/AGENTS.md` (equivalent to .claude/CLAUDE.md) — well-maintained
- `.opencode/docs/README.md` — comprehensive navigation hub
- `.opencode/docs/` — architecture, examples, guides, reference, templates (agent-facing)
- References extensions that exist in upstream nvim but NOT in this repo (lean, nix, web, z3, formal, founder)

---

## Installation Script Assessment

### Current State
- **Main installer**: `scripts/install/install.sh` — 6-group wizard (base, shell-tools, python, r, typesetting, mcp-servers)
- **Helper lib**: `scripts/install/lib.sh` — shared utilities, macOS/bash-3.2 compatible
- **Group scripts**: `install-base.sh`, `install-shell-tools.sh`, `install-python.sh`, `install-r.sh`, `install-typesetting.sh`, `install-mcp-servers.sh`

### What it installs
- Zed editor, Claude Code CLI (via `brew install --cask claude-code`)
- Node.js, build tools (Homebrew, Xcode CLT)
- Python + uv + ruff + optional packages
- R + languageserver + lintr + styler + optional packages
- LaTeX + Typst + Pandoc + markitdown + fonts
- MCP servers (superdoc, openpyxl, rmcp, markitdown-mcp, mcp-pandoc)

### What's Missing
- **No OpenCode CLI installation** — no `brew install opencode` or equivalent
- **No choice between agent systems** — users can't pick Claude Code, OpenCode, or both
- **No `.opencode/`-specific dependencies** — e.g., OpenCode may have different MCP server or CLI requirements
- Shell-tools group description says ".claude/ hooks and commands" — should be generalized

### Agent System Scripts
- `.claude/scripts/` — 10 scripts including `install-extension.sh`, `uninstall-extension.sh`, `validate-wiring.sh`, etc.
- `.opencode/scripts/` — 10 scripts, same names as .claude/ scripts (parallel structure)
- Both have `install-aliases.sh`, `setup-lean-mcp.sh` (lean not loaded here)

---

## Extension Source Architecture

All extensions are sourced from the nvim config repository:
- .claude extensions: sourced from `~/.config/nvim/.claude/extensions/`
- .opencode extensions: sourced from `~/.config/nvim/.opencode/extensions/`

The extensions are "installed" (copied/linked) into this zed repo and tracked in `extensions.json`. The `.claude/` system does NOT have on-disk extension directories (no `.claude/extensions/` folder) — only the flat `extensions.json` tracks what's installed. The `.opencode/` system DOES have on-disk extension directories at `.opencode/extensions/{name}/` containing manifest.json files.

---

## Recommendations for Documentation Improvement

1. **README.md needs dual-system awareness**: Add OpenCode as a parallel system, update directory layout, explain the relationship
2. **docs/ needs an OpenCode section or dual-system coverage**: Either add docs/agent-system/opencode.md or refactor existing docs to cover both
3. **Install script needs agent-system choice**: Add a group or prompt asking "Install Claude Code, OpenCode, or both?"
4. **Extension inventory table**: The README should have a table showing all 9 extensions with what each provides
5. **Naming inconsistencies should be documented**: The epi/epidemiology and filetypes-spreadsheet/spreadsheet naming differences between systems should be called out
6. **.opencode/docs/README.md references extensions not in this repo** (lean, nix, web, z3, formal, founder) — should be cleaned up or noted as "available in upstream"
