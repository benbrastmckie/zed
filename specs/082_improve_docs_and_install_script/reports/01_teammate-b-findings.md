# Teammate B Findings: Documentation State and Restructuring Proposal

**Task**: 82 — Improve documentation and installation script for dual agent systems
**Teammate**: B (Alternative Approaches — Documentation Structure)
**Date**: 2026-05-11
**Confidence**: High

## Key Findings

### 1. README.md and docs/ are entirely Claude Code-centric; OpenCode is invisible

The root README.md (258 lines) makes zero mention of OpenCode. It titles itself "Zed IDE Configuration with Claude Code Agent System", references `.claude/` 6 times, and the directory layout section omits `.opencode/` entirely. Every command table, every link, every workflow guide is framed exclusively around Claude Code.

The docs/ directory (30 files across 4 subdirectories) has exactly **one sentence** mentioning OpenCode, buried in `docs/agent-system/context-and-memory.md`: "Shared with OpenCode: both AI systems read and write the same vault."

### 2. .opencode/ is a near-complete parallel system

Both systems share **identical extensions** (9 each): core, epidemiology, filetypes, latex, memory, present, python, slidev, typst. They share the same `specs/` directory for task management, the same `.memory/` vault, and the same `scripts/install/` wizard.

Structural parallels:
- `.claude/` uses `agents/` (plural) → `.opencode/` uses `agent/subagents/`
- Both have identical: hooks/, scripts/, rules/, context/, docs/ (internal), extensions/, skills/, commands/, templates/, systemd/
- Files in shared directories (hooks, scripts) are **byte-identical** — duplicated, not symlinked

### 3. The two systems have intentional naming divergences

| Component | Claude Code | OpenCode |
|-----------|------------|----------|
| Epi skills | `skill-epi-research`, `skill-epi-implement` | `skill-epidemiology-research`, `skill-epidemiology-implementation` |
| Epi agents | `epi-research-agent.md`, `epi-implement-agent.md` | `epidemiology-research-agent.md`, `epidemiology-implementation-agent.md` |
| Spreadsheet skill | `skill-filetypes-spreadsheet` | `skill-spreadsheet` |
| Spreadsheet agent | `filetypes-spreadsheet-agent.md` | `spreadsheet-agent.md` |
| DOCX skill/agent | `skill-docx-edit` / `docx-edit-agent.md` | *(absent)* |
| Scrape skill/agent | `skill-scrape` / `scrape-agent.md` | *(absent)* |
| Deck skill/agent | *(absent)* | `skill-deck` / `deck-agent.md` |
| Project overview | *(absent)* | `skill-project-overview` / `project-overview.md` cmd |
| Distill command | `distill.md` | *(absent — `/learn` only)* |
| Epi command | `epi.md` | *(absent)* |
| Edit command | `edit.md` | *(absent)* |
| Scrape command | `scrape.md` | *(absent)* |

### 4. Installation script doesn't distinguish between systems

The install wizard (`scripts/install/install.sh`) installs dependencies for both systems without offering a choice. Its description says "Zed + Claude Code toolchain wizard" — no OpenCode mention. The 6 groups (base, shell-tools, python, r, typesetting, mcp-servers) install everything needed by both, but a user who only wants OpenCode support shouldn't need Claude Code CLI and vice versa.

### 5. Internal docs are fully duplicated

Both `.claude/docs/` and `.opencode/docs/` contain identical file trees (24 files each). The files appear to be copies with minor path adjustments. This means internal agent-facing docs are synchronized but the user-facing docs/ directory knows nothing about the second system.

## Current Documentation Inventory

### docs/ (user-facing, 30 files)

| Directory | Files | Coverage | OpenCode refs |
|-----------|-------|----------|---------------|
| `general/` | 5 (installation.md, keybindings.md, settings.md, keybindings-cheat-sheet.typ/pdf, README.md) | Complete for Zed + Claude Code setup | None |
| `agent-system/` | 5 (README.md, architecture.md, commands.md, context-and-memory.md, zed-agent-panel.md) | Complete for Claude Code agent system | 1 sentence |
| `toolchain/` | 7 (README.md, python.md, r.md, typesetting.md, mcp-servers.md, extensions.md, slidev.md, shell-tools.md) | Complete for extension dependencies | None |
| `workflows/` | 10 (README.md, agent-lifecycle.md, maintenance-and-meta.md, epidemiology-analysis.md, grant-development.md, memory-and-learning.md, convert-documents.md, edit-word-documents.md, edit-spreadsheets.md, tips-and-troubleshooting.md) | Complete for Claude Code workflows | None |

### .claude/docs/ (agent-facing, 24 files)

Architecture docs, guides (creating agents/skills/commands/extensions), user guides, reference standards, templates. Not visible to casual users browsing docs/.

### .opencode/docs/ (agent-facing, 24 files)

Mirror of .claude/docs/ with path adjustments.

## Proposed Documentation Structure

### Option A: Unified docs/ with dual-system sections (Recommended)

Restructure docs/ to present both systems as equals while documenting shared infrastructure:

```
docs/
├── README.md                           # Updated: "Two AI Systems" framing
├── general/
│   ├── installation.md                 # Updated: system selection in wizard
│   ├── keybindings.md                  # Unchanged
│   ├── settings.md                     # Unchanged
│   └── keybindings-cheat-sheet.*       # Unchanged
├── agent-system/
│   ├── README.md                       # NEW: "Two AI Systems" overview (replace Claude-only)
│   ├── claude-code.md                  # NEW: Claude Code-specific setup, shortcuts, how to access
│   ├── opencode.md                     # NEW: OpenCode-specific setup, shortcuts, how to access
│   ├── shared-architecture.md          # RENAME from architecture.md — shared lifecycle, state, routing
│   ├── commands.md                     # Updated: mark which commands exist in which system
│   ├── context-and-memory.md           # Updated: shared vault already documented
│   ├── extensions.md                   # NEW: per-extension feature matrix (what each provides)
│   └── zed-agent-panel.md              # Unchanged
├── toolchain/                          # Unchanged (dependencies are system-agnostic)
└── workflows/                          # Mostly unchanged; add OpenCode command variants where different
```

Key changes:
1. **README.md**: Replace "Claude Code Agent System" title with "Zed Configuration with AI Agent Systems" or similar; document both systems upfront
2. **New extensions.md**: Structured per-extension page showing what each extension provides (skills, agents, commands, context) across both systems
3. **System-specific pages**: `claude-code.md` and `opencode.md` for system-specific setup and access
4. **Command matrix**: Update commands.md with columns showing availability in each system

### Option B: Separate agent-system sections

Split agent-system/ into `agent-system/claude-code/` and `agent-system/opencode/` subdirectories. Cleaner separation but more duplication since 90%+ is shared.

### Option C: Single page addition

Minimal change: add one `docs/agent-system/opencode.md` page and update references. Quick but doesn't address the structural gap.

**Recommendation**: Option A. The systems share enough that separate sections would be 90% duplicate text, but a single page doesn't give OpenCode adequate visibility. Unified docs with clear system-selection callouts is the sweet spot.

## Content Gap Analysis

### Critical gaps (README.md and docs/)

1. **No OpenCode mention in README.md** — users browsing the repo have no idea a second system exists
2. **No extension feature matrix** — users can't see what capabilities each extension adds at a glance
3. **Directory layout omits .opencode/** — the layout diagram in README.md shows .claude/ but not .opencode/
4. **Installation wizard doesn't offer system choice** — users should be able to install only Claude Code deps, only OpenCode deps, or both
5. **No comparison page** — no doc explains when to use Claude Code vs OpenCode, their trade-offs, or how they interoperate (shared specs/, shared .memory/)
6. **docs/agent-system/README.md says "Two AI systems"** but means Zed Agent Panel + Claude Code — not Claude Code + OpenCode

### Moderate gaps

7. **toolchain/extensions.md** references only `.claude/` extensions — should note `.opencode/` has the same set
8. **Command naming differences** not documented — users moving between systems won't know that `/epi` in Claude Code is accessed differently in OpenCode
9. **Skill/agent naming differences** not documented — e.g., `epi-research-agent` vs `epidemiology-research-agent`

### Minor gaps

10. **Internal docs path references** — .opencode/docs/ files may still reference .claude/ paths in a few places (needs audit)
11. **docs/agent-system/README.md "Zed adaptations" section** says "No `.claude/extensions/` directory" — this is true but should note that .opencode/ DOES have an extensions/ directory
