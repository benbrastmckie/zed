# Research Report: Task #33 — Teammate D (Horizons)

**Task**: 33 - Improve documentation to present core agent system and extension architecture
**Role**: Teammate D — Long-term alignment and strategic direction
**Started**: 2026-04-11T00:00:00Z
**Completed**: 2026-04-11T00:30:00Z
**Effort**: 30 minutes
**Sources/Inputs**: README.md, docs/agent-system/README.md, docs/README.md, docs/workflows/README.md, .claude/README.md, .claude/CLAUDE.md, .claude/extensions.json, .claude/context/repo/project-overview.md, specs/ROADMAP.md
**Artifacts**: This report

---

## Key Findings

### 1. Fundamental Identity Confusion: The Documentation Tells the Wrong Story

The current README.md opens with: "A Zed editor configuration for macOS optimized for working in **R** and **Python** with **Claude Code** as the integrated AI assistant." This framing buries the lead. The most distinctive thing about this repository is not that it configures Zed — it is that it deploys a sophisticated, extensible AI agent system that transforms Claude Code into a domain-specific research and development platform.

The project-overview.md compounds this: it still describes a "Neovim configuration project using Lua and lazy.nvim." This file was written for the neovim repo and was never updated for the Zed deployment. It is actively misleading any agent that loads it.

**The real product is the `.claude/` agent system.** The Zed configuration is the delivery vehicle.

### 2. The Extension Ecosystem is a Platform Story — Not Currently Told

The `extensions.json` reveals six active, production-grade extensions:
- `epidemiology` (v2.0.0) — Full R-based study design pipeline
- `present` (v1.0.0) — Grant proposals, budgets, timelines, funding analysis, talks
- `filetypes` (v2.2.0) — Document format conversion and Office automation
- `latex` (v1.0.0) — LaTeX document development
- `typst` (v1.0.0) — Typst document development
- `memory` (v1.0.0) — Persistent knowledge vault

Each extension ships agents, skills, commands, and context files. This is a plugin ecosystem. The documentation currently describes these as "also available domain extensions" — an afterthought framing in the README — rather than presenting them as the distinguishing capability of the platform.

The correct mental model: **core system = task lifecycle + agent orchestration; extensions = domain-specific tools that run on top**. This "platform + plugins" story is already structurally true; it is just not named or presented as such anywhere in user-facing documentation.

### 3. The Task Lifecycle IS the Core Product, Not a Feature

The `/task` → `/research` → `/plan` → `/implement` → `/todo` pipeline is a structured software development methodology implemented as a state machine. It provides:
- Traceable decision history (specs/ artifact trail)
- Resumable, phase-aware execution
- Parallel multi-agent execution (--team flag)
- Error recovery and partial-state management
- Git integration with task-scoped commits

This is not described as a methodology anywhere in the current documentation. It is presented as a set of commands. The current `docs/agent-system/README.md` comes closest to explaining it, but even there the emphasis is on syntax rather than the underlying value proposition.

**The value proposition**: Claude Code is powerful but stateless. The agent system gives it persistent structure, traceability, and resumability. This deserves a dedicated "Why this exists" section in the README.

### 4. Documentation Scales Poorly as Extensions Are Added

The current architecture for documenting extensions is to append a new section to CLAUDE.md (which already has 7 extension sections), list them in a table in `.claude/README.md`, and add a workflow narrative in `docs/workflows/`. As extensions multiply, this becomes:
- CLAUDE.md becomes enormous (it already contains all extension documentation inline)
- No single "what extensions are available" page
- No discovery path from README.md to extension-specific docs
- The agent system's own README references an `extensions/` directory that does not exist in this deployment (it uses the flat `extensions.json` instead)

**A dedicated extensions hub document** — `docs/extensions.md` or `docs/agent-system/extensions.md` — would provide a single, scannable page of all extensions with their commands, use cases, and links to workflow guides.

### 5. Cross-Repository Portability: A Missed Opportunity

The README currently says this is "for macOS" and targets R/Python. But the `.claude/` agent system is entirely language-agnostic. The extension files source from `/home/benjamin/.config/nvim/.claude/extensions/` — the same system is deployed across two separate editor configurations (neovim + zed) from shared extension sources.

This suggests the `.claude/` system is already being treated as a portable platform, just without documentation that acknowledges this. A README that positions the system as "a Claude Code agent framework for structured development workflows, deployed here as a Zed workspace" would:
1. Accurately describe what the system actually is
2. Enable others to adopt the pattern
3. Create a template README for new deployments

### 6. The "Quick Start" Undersells the System

The current Quick Start focuses on editor installation (Homebrew, Zed extensions). For a user interested in the agent system, the most important Quick Start is:
1. Install Claude Code CLI
2. Open this workspace (Ctrl+Shift+A)
3. Run `/task "your first task"` and follow the lifecycle

That path is buried in `docs/agent-system/README.md` under "Quick start: your first task." It should be in the root README with equal prominence to the installation wizard.

---

## Recommended Approach

### Reframe: Platform-First Documentation

**Proposed README.md narrative structure**:

1. **Lede** (3-5 sentences): This is a Zed workspace with an AI agent system. The agent system provides structured research, planning, and implementation workflows via Claude Code. Extensions add domain-specific tools for epidemiology, grant development, presentations, and more.

2. **The Core Workflow** (before language sections): Introduce the task lifecycle as the primary mental model. Show the `/task` → `/research` → `/plan` → `/implement` pipeline with a single concrete example. This is what makes the system distinctive.

3. **Quick Start: First Task** (alongside the installation Quick Start): Show a user creating and executing their first task in 4 commands.

4. **Extensions Overview** (before Languages): A scannable table of all active extensions with their key commands, positioned as "what you can do beyond the core workflow."

5. **Languages section**: R and Python configuration, positioned as "the development environment this workspace is optimized for" — supportive of the agent system, not the main story.

6. **Command Reference**: Already present; keep it.

### Fix: Update project-overview.md

The file at `.claude/context/repo/project-overview.md` describes a Neovim project. It is loaded by agents for every task. Update it to accurately describe the Zed workspace: its structure, the active extensions, and the primary languages.

### Add: Extensions Hub Document

Create `docs/agent-system/extensions.md` as a single-page catalog of all installed extensions. Each entry: one paragraph description, list of commands, link to workflow doc. This page scales naturally as new extensions are installed.

### Add: "Why This Exists" Section

Add a short section to the README (or a `docs/agent-system/why.md`) that explains the value proposition of the agent system:
- Claude Code is powerful but has no memory of previous sessions
- The agent system provides structure: each task has a traceable history, resumable phases, and committed artifacts
- Extensions add domain knowledge, transforming the generic system into a specialized research platform

### Future-Proofing: Extension Registry Convention

The `extensions.json` file is machine-readable but not human-readable at a glance. Establish a convention: each extension must include a `description` field and a `commands` summary. This would make it possible to auto-generate the extensions hub document from `extensions.json` — the documentation would always be in sync with what is installed.

---

## Evidence and Examples

### Evidence: Wrong identity in project-overview.md

```
# Neovim Configuration Project
## Project Overview
This is a Neovim configuration project using Lua and lazy.nvim for plugin management.
```

This file is at `.claude/context/repo/project-overview.md` in the Zed repo. It is loaded by agents. Every research and implementation agent that runs in this workspace starts from a false premise.

### Evidence: Extension ecosystem depth

The `extensions.json` shows the present extension alone ships:
- 5 agents (grant-agent, budget-agent, timeline-agent, funds-agent, slides-agent)
- 5 commands (/grant, /budget, /timeline, /funds, /slides)
- 5 skills
- 26+ context files covering funder types, proposal components, budget frameworks, evaluation patterns, talk structures

This is a significant domain-specific capability, not a minor add-on.

### Evidence: Platform vs. editor framing gap

The `.claude/README.md` (version 3.0, 2026-03-28) lists 12 extension domains including `nvim`, `lean`, `z3`, `formal`, `founder`, `web`, `nix` — most of which are not installed in this Zed workspace but exist in the shared source system. This confirms the platform is genuinely portable and domain-agnostic; the Zed workspace is one deployment.

### Evidence: Structural narrative gap

The docs/workflows/README.md has an excellent "Decision guide" table and "Common scenarios" section. This is exactly the right pattern. But it is buried three levels deep (`docs/workflows/README.md`) and not surfaced in the root README at all. The root README has a documentation table but no decision guide, no scenarios, no "when would I use this" framing.

### Evidence: The Quick Start omission

The root README Quick Start covers: `git clone`, `bash install.sh`, editor setup, keybindings. It does not show a single Claude Code command being run. For a user who came here specifically for the AI agent system, the most important information is entirely absent from the first screen.

---

## Confidence Level

**High confidence**:
- project-overview.md is factually wrong for this deployment — must be updated
- The extension ecosystem is undertold — evidence is in extensions.json
- The task lifecycle is the core product and deserves lede positioning
- The Quick Start omits the primary workflow

**Medium confidence**:
- A "platform + plugins" narrative is the right strategic frame — this is a judgment about positioning, not a factual determination; it depends on what the intended audience values
- An extensions hub document would scale better than inline CLAUDE.md sections — reasonable to question whether a separate doc creates maintenance burden
- README-as-template for other deployments — viable if documentation is structured to separate "this workspace" from "the agent system"; would require deliberate authorial effort

**Low confidence (but worth considering)**:
- Auto-generating extension documentation from extensions.json — technically feasible, but requires establishing and maintaining the registry convention; high benefit if the system grows, lower benefit if extension count stabilizes
- Positioning this as a model README for other Claude Code deployments — depends on whether the owner intends external adoption; no signal in the current documentation either way

---

## Context Extension Recommendations

- **Topic**: Project identity for Zed workspace
- **Gap**: `project-overview.md` describes a Neovim project; no accurate project-overview exists for the Zed deployment
- **Recommendation**: Replace or rewrite `.claude/context/repo/project-overview.md` to describe the Zed workspace accurately, including active extensions and primary languages

- **Topic**: Extension ecosystem discovery
- **Gap**: No single document lists all installed extensions with commands and use cases
- **Recommendation**: Create `docs/agent-system/extensions.md` as an extension catalog; consider adding `description` and `commands` fields to `extensions.json` for machine-readable discovery
