# Research Report: Task #82

**Task**: Improve documentation and installation script for dual agent systems
**Date**: 2026-05-11
**Mode**: Team Research (4 teammates)
**Session**: sess_1778521337_51df09

## Summary

This repository contains two parallel AI agent systems — Claude Code (`.claude/`) and OpenCode (`.opencode/`) — that share the same 9 extensions, task management (`specs/`), and memory vault (`.memory/`). Yet the README.md, all 30 docs/ files, and the installation wizard are entirely Claude Code-centric. OpenCode is invisible to users: zero mentions in README.md, one sentence total across all of docs/. The installation script has no path for installing OpenCode or choosing between agent systems. This report synthesizes findings from 4 research teammates to guide documentation and installer improvements.

## Key Findings

### 1. Extension Inventory: 9 Shared Extensions

Both systems share the same 9 extensions, all sourced from a common upstream (`~/.config/nvim/`):

| Extension | Version | What It Provides | Task Types Routed |
|-----------|---------|-----------------|-------------------|
| **core** | 2.0.0/.1.0.0 | Base commands (25-27), 7 agents, 21 skills, rules, hooks, scripts, context, templates, systemd timers | general, meta, markdown |
| **epidemiology** | 2.0.0/1.0.0 | Study design, causal inference, missing data, statistical modeling, STROBE reporting | epi, epi:study, epidemiology |
| **filetypes** | 2.2.0 | Document conversion (PDF/DOCX/MD), spreadsheet handling, presentation extraction, PDF scraping, DOCX editing, XLSX analysis | (routing by format) |
| **latex** | 1.0.0 | LaTeX document research and implementation, pdflatex/latexmk build | latex |
| **memory** | 1.0.0 | Knowledge capture/retrieval, vault management, distillation, MCP integration | (utility) |
| **present** | 1.0.0 | Grant proposals, budgets, timelines, funding analysis, academic talks, slide planning/critique | present, present:grant, present:budget, present:timeline, present:funds, present:slides |
| **python** | 1.0.0 | Python dev with pytest, mypy, ruff. Code style, testing patterns, library patterns | python |
| **slidev** | 1.0.0 | Shared Slidev animation patterns, CSS presets, config templates (dependency of present) | (no routing — utility) |
| **typst** | 1.0.0 | Typst document research and implementation, fletcher diagrams, single-pass compilation | typst |

### 2. Naming and Capability Differences Between Systems

While extensions are structurally identical, there are intentional skill/agent naming divergences and capability differences:

| Capability | Claude Code | OpenCode |
|-----------|-------------|----------|
| Epi skills | `skill-epi-research`, `skill-epi-implement` | `skill-epidemiology-research`, `skill-epidemiology-implementation` |
| Spreadsheet skill | `skill-filetypes-spreadsheet` | `skill-spreadsheet` |
| DOCX editing | `skill-docx-edit` + `docx-edit-agent` | *absent* |
| PDF scraping | `skill-scrape` + `scrape-agent` | *absent* |
| Deck creation | *absent* | `skill-deck` + `deck-agent` |
| Project overview | *absent* | `skill-project-overview` |
| `/distill` command | Available | *absent* |
| `/epi` command | Available | *absent* |
| `/edit` command | Available | *absent* |
| `/scrape` command | Available | *absent* |
| `/deck` command | *absent* | Available |
| `/project-overview` command | *absent* | Available |

### 3. Shared State Architecture

Both systems share:
- **specs/** — TODO.md, state.json, task directories (Claude Code: `{NNN}_slug`, OpenCode: `OC_{NNN}_slug`)
- **.memory/** — Memory vault with validate-on-read index
- **scripts/install/** — Installation wizard
- **docs/** — User-facing documentation (currently Claude Code only)

Both systems have independently maintained:
- Internal docs (`.claude/docs/` and `.opencode/docs/` — mirror trees, 24 files each)
- Hooks (byte-identical copies, not symlinked)
- Scripts (parallel structure, same filenames)

### 4. Documentation Is Entirely Claude Code-Centric

| Documentation Area | OpenCode Coverage |
|--------------------|-------------------|
| README.md (258 lines) | Zero mentions |
| docs/general/ (5 files) | Zero mentions |
| docs/agent-system/ (5 files) | 1 sentence (shared memory) |
| docs/toolchain/ (7 files) | Zero mentions |
| docs/workflows/ (10 files) | Zero mentions |

**Broken link**: README.md links to `.claude/README.md` which does not exist. The actual hub is `.claude/docs/README.md`.

### 5. Installation Script Has No OpenCode Support

Current installer (`scripts/install/install.sh`): 6-group wizard (base, shell-tools, python, r, typesetting, mcp-servers).

Problems:
- Claude Code CLI is buried in the "base" group alongside Homebrew and Node.js
- No `install-opencode.sh` group exists
- No mechanism to choose between agent systems
- Wizard description says "Zed + Claude Code toolchain wizard" — no OpenCode awareness
- Homebrew-only approach — but OpenCode is installed via NixOS on this system
- MCP server registration uses `claude mcp add` — OpenCode likely has a different mechanism

### 6. Platform Claims Are Misleading

README.md claims "macOS 11+", but the system is currently running Linux 7.0.3 (NixOS). The installer is Homebrew-only. If the repo supports Linux/NixOS users (which it does, given OpenCode is running here), the platform documentation needs updating.

### 7. Ghost Extension References in OpenCode Docs

`.opencode/docs/` references extensions not installed in this repo: lean, nix, web, z3, formal, founder. These exist in the upstream nvim config (17 total) but only 9 are installed here. Documentation should either remove these references or note them as "available from upstream."

## Synthesis

### Conflicts Resolved

1. **Documentation approach** — Teammates B and D both recommended unified docs with dual-system sections (Option A) over separate documentation trees. Teammate C raised concerns about maintenance burden. **Resolution**: Unified approach is correct since 90%+ of content is shared. Maintenance risk is mitigated by keeping system-specific content in dedicated pages (`claude-code.md`, `opencode.md`) while shared content stays in shared pages.

2. **Extension documentation granularity** — Teammate A produced a detailed per-extension breakdown; Teammate D recommended a single `extensions.md` page with a summary table. **Resolution**: Single `extensions.md` page is the right approach for user docs. The detailed per-extension data from Teammate A becomes the source material for creating that page.

3. **Install script scope** — Teammate C flagged this as the riskiest part, noting potential Linux/Nix requirements. Teammate D recommended staying within the existing wizard flow. **Resolution**: Add agent system selection as a new group in the existing wizard. For now, handle Claude Code (Homebrew) and OpenCode (document manual install) separately — the install script does not need to support Nix package manager in this iteration.

### Gaps Identified

1. **OpenCode installation requirements**: What are the actual dependencies for OpenCode CLI? Is it available via Homebrew, npm, or only Nix? This needs investigation during planning.

2. **MCP server registration for OpenCode**: How does OpenCode register MCP servers? The `claude mcp add` pattern won't work. This needs research.

3. **Extension sync mechanism**: Extensions are sourced from nvim upstream. The install script doesn't handle extension loading. Should it? (Probably out of scope for this task.)

4. **Task 66 overlap**: Task 66 ("Update docs/ and README.md to reflect .claude/ refactoring") is [RESEARCHED] and covers similar ground. This task should subsume task 66's scope or explicitly reference its research.

### Recommendations

#### Documentation Changes

1. **README.md**: Rewrite to present both agent systems as equal peers. Update title, add dual-system overview, update directory layout diagram to include `.opencode/`, fix broken `.claude/README.md` link.

2. **New `docs/agent-system/extensions.md`**: Feature matrix page showing all 9 extensions with what each provides (commands, skills, agents, context) per system.

3. **New `docs/agent-system/opencode.md`**: OpenCode-specific setup, access, and configuration guide.

4. **Update `docs/agent-system/README.md`**: Reframe "Two AI Systems" to mean Claude Code + OpenCode (not Claude Code + Zed Agent Panel).

5. **Update `docs/agent-system/architecture.md`**: Add dual-system architecture diagram showing shared specs/ and .memory/ with separate .claude/ and .opencode/ trees.

6. **Update `docs/agent-system/commands.md`**: Add availability columns showing which commands exist in which system.

7. **Update `docs/general/installation.md`**: Document agent system selection in wizard.

8. **Clean up `.opencode/docs/`**: Remove references to extensions not installed in this repo (lean, nix, web, z3, formal, founder).

#### Installation Script Changes

1. **Add agent system selection prompt**: Before existing groups, ask: Claude Code / OpenCode / Both / Neither.
2. **Factor Claude Code CLI out of base**: Move `brew install --cask claude-code` to a new `install-agent-systems.sh` group.
3. **Add OpenCode install option**: Even if manual, document the path and verify the binary is available.
4. **Update MCP server registration**: Handle per-system MCP configuration.
5. **Update wizard description**: Change from "Zed + Claude Code toolchain wizard" to "Zed toolchain wizard" or similar.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Contribution |
|----------|-------|--------|------------|------------------|
| A | Primary (Extension Audit) | completed | high | Comprehensive per-extension inventory with file counts, skill/agent differences, and naming inconsistencies |
| B | Alternatives (Docs Structure) | completed | high | Proposed unified docs structure (Option A) with content gap analysis (11 gaps, 6 critical) |
| C | Critic | completed | high | Identified broken link, platform claims mismatch, 5 critical unanswered questions, risk assessment of install script scope |
| D | Horizons (Strategic) | completed | high | Strategic assessment: equal-peer treatment, task 66 overlap, layered install script, extension portability insight |

## References

- `.claude/extensions.json` — Claude Code extension registry
- `.opencode/extensions.json` — OpenCode extension registry
- `scripts/install/install.sh` — Current installation wizard
- `specs/066_update_docs_readme_post_refactor/reports/01_refactoring-diff-audit.md` — Related task 66 research
