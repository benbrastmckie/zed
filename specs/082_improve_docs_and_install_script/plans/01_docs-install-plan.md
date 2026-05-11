# Implementation Plan: Improve Docs and Install Script

- **Task**: 82 - Improve documentation and installation script for dual agent systems
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_team-research.md
- **Artifacts**: plans/01_docs-install-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The repository hosts two parallel AI agent systems -- Claude Code (`.claude/`) and OpenCode (`.opencode/`) -- sharing the same 9 extensions, task management (`specs/`), and memory vault (`.memory/`). Yet every user-facing document and the installation wizard are entirely Claude Code-centric: OpenCode has zero mentions in README.md, near-zero coverage across 30 docs/ files, and no install path. This plan rewrites the documentation to present both systems as equal peers, creates new reference pages for extensions and OpenCode, and adds agent system selection to the install wizard. Definition of done: README.md, docs/, and install.sh all accurately describe and support both agent systems.

### Research Integration

Key findings from `reports/01_team-research.md`:
- 9 shared extensions identified (core, epidemiology, filetypes, latex, memory, present, python, slidev, typst) with documented naming differences between systems
- README.md has a broken link to `.claude/README.md` (actual path: `.claude/docs/README.md`)
- Platform claims say "macOS 11+" but the system runs Linux/NixOS
- docs/agent-system/README.md says "Two AI systems" but means Zed Agent Panel + Claude Code, not Claude Code + OpenCode
- `.opencode/docs/` references extensions not installed in this repo (lean, nix, web, z3, formal, founder)
- Install wizard is Homebrew-only with no OpenCode option; Claude Code CLI is bundled in the "base" group

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items found (roadmap is empty).

## Goals & Non-Goals

**Goals**:
- Present Claude Code and OpenCode as equal peers across all user-facing documentation
- Create a comprehensive extension feature matrix page (`docs/agent-system/extensions.md`)
- Create an OpenCode setup and configuration page (`docs/agent-system/opencode.md`)
- Fix broken links, platform claims, and stale references in existing docs
- Add agent system selection to the install wizard (Claude Code / OpenCode / Both / Neither)
- Clean up `.opencode/docs/` references to extensions not installed in this repo

**Non-Goals**:
- Rewriting `.claude/` or `.opencode/` internal docs (machine-facing, not user-facing)
- Adding Nix package manager support to the install script (document manual install for OpenCode instead)
- Implementing extension sync from upstream nvim config
- Resolving task 66 overlap (reference its research but do not merge the tasks)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| OpenCode install steps unknown | M | M | Research actual binary location (`/run/current-system/sw/bin/opencode`) and document what is known; flag unknowns for manual verification |
| Broken cross-references after restructuring | M | H | Run link validation after each phase; fix forward references in the same phase |
| Scope creep into .opencode/ internal docs | M | M | Strictly scope to user-facing docs/ and README.md; treat .opencode/docs/ cleanup as minimal (remove ghost references only) |
| Platform section rewrite confuses macOS users | L | L | Keep macOS as primary documented platform; add Linux/NixOS as secondary with clear section separation |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Create New Documentation Pages [COMPLETED]

**Goal**: Create the two new documentation pages that other phases will link to, establishing the foundation for dual-system coverage.

**Tasks**:
- [ ] Create `docs/agent-system/extensions.md` with feature matrix table covering all 9 extensions: what each provides (commands, skills, agents, task types), availability per system, and naming differences
- [ ] Create `docs/agent-system/opencode.md` covering: what OpenCode is, how to access it, how it relates to Claude Code, shared state (specs/, .memory/), unique capabilities (/deck, /project-overview), and setup instructions
- [ ] Add navigation links to both new pages in `docs/agent-system/README.md` navigation section (under "Files in this directory")

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `docs/agent-system/extensions.md` - NEW: extension feature matrix with per-system availability
- `docs/agent-system/opencode.md` - NEW: OpenCode setup and reference guide
- `docs/agent-system/README.md` - Add navigation entries for new pages

**Verification**:
- Both new files exist and contain complete content
- README.md navigation lists both new pages
- Extension matrix covers all 9 extensions with accurate naming differences

---

### Phase 2: Update Existing Agent System Documentation [COMPLETED]

**Goal**: Rewrite existing docs/agent-system/ pages to present Claude Code and OpenCode as equal peers, fix the "Two AI systems" framing, and add dual-system architecture.

**Tasks**:
- [ ] Rewrite `docs/agent-system/README.md`: change "Two AI systems" framing from "Zed Agent Panel + Claude Code" to "Claude Code + OpenCode" as the two agent systems, with Zed Agent Panel as a third access method; update the system comparison table to include OpenCode row
- [ ] Update `docs/agent-system/architecture.md`: add dual-system architecture diagram showing shared specs/ and .memory/ with separate .claude/ and .opencode/ trees; update the configuration tree to include .opencode/; note that both systems share the same three-layer pipeline pattern
- [ ] Update `docs/agent-system/commands.md`: add system availability indicators showing which commands exist in which system (e.g., /distill is Claude Code only; /deck is OpenCode only)
- [ ] Update `docs/agent-system/context-and-memory.md`: expand the existing OpenCode mention to explain the shared state model more fully, reference the new opencode.md page

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `docs/agent-system/README.md` - Reframe dual-system narrative and update comparison table
- `docs/agent-system/architecture.md` - Add dual-system architecture diagram and .opencode/ config tree
- `docs/agent-system/commands.md` - Add per-system availability indicators
- `docs/agent-system/context-and-memory.md` - Expand shared state documentation

**Verification**:
- "Two AI systems" section accurately describes Claude Code and OpenCode
- Architecture page shows both system trees
- Command catalog indicates per-system availability
- No remaining Claude-Code-only framing in agent-system/ docs

---

### Phase 3: Update Install Wizard for Agent System Selection [COMPLETED]

**Goal**: Add an agent system selection prompt to the install wizard and factor Claude Code CLI out of the base group into a selectable agent system step.

**Tasks**:
- [ ] Create `scripts/install/install-agent-systems.sh`: new group script that handles Claude Code CLI install (via Homebrew), OpenCode documentation/verification (check if opencode binary exists), and MCP server registration (moved from install-base.sh for Claude Code; document OpenCode's mechanism)
- [ ] Update `scripts/install/install-base.sh`: remove Claude Code CLI install (`install_claude_cli`), SuperDoc MCP (`install_mcp_superdoc`), and openpyxl MCP (`install_mcp_openpyxl`) functions -- these move to install-agent-systems.sh; update check mode to remove claude/mcp checks
- [ ] Update `scripts/install/install.sh`: add `agent-systems` to ALL_GROUPS after `base`; update describe_group for the new group; change wizard title from "Zed + Claude Code toolchain wizard" to "Zed toolchain wizard"
- [ ] Update `scripts/install/lib.sh`: if any shared helpers are needed for OpenCode detection (e.g., `check_opencode_binary`), add them; update platform detection comment to note Linux support is documentary only

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `scripts/install/install-agent-systems.sh` - NEW: agent system selection and install
- `scripts/install/install-base.sh` - Remove Claude CLI and MCP functions
- `scripts/install/install.sh` - Add agent-systems group, update title
- `scripts/install/lib.sh` - Add OpenCode detection helper if needed

**Verification**:
- `bash scripts/install/install.sh --dry-run` shows agent-systems group in the wizard
- `bash scripts/install/install-agent-systems.sh --check` runs without error
- Claude Code CLI no longer appears in install-base.sh --check output
- install.sh title no longer says "Claude Code"

---

### Phase 4: Rewrite README.md and docs/README.md [COMPLETED]

**Goal**: Update the top-level README.md and docs hub to present both agent systems, fix broken links, correct platform claims, and update the directory layout.

**Tasks**:
- [ ] Rewrite README.md title and opening paragraph: change from "Zed IDE Configuration with Claude Code Agent System" to a title that covers both systems; update description to mention both Claude Code and OpenCode
- [ ] Fix broken link: change `.claude/README.md` to `.claude/docs/README.md` in Documentation table
- [ ] Update platform section: add Linux/NixOS as a supported platform alongside macOS; note that macOS uses Homebrew and Linux/NixOS uses system packages
- [ ] Update directory layout: add `.opencode/` entry to the tree diagram
- [ ] Update "Claude Code Commands" section: rename to "Agent Commands" or "AI Commands"; add a note that OpenCode provides a parallel command set with some differences (link to extensions.md)
- [ ] Update "AI Integration" section: add OpenCode as a third entry alongside Claude Code and Zed Agent Panel
- [ ] Update `docs/README.md`: change Claude-Code-centric framing to dual-system; add OpenCode mention in audience paragraph; fix `.claude/README.md` broken link
- [ ] Update `docs/general/installation.md`: add a section on agent system selection in the wizard; note that OpenCode users on NixOS may already have the binary available; update prerequisites to mention Linux as supported

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `README.md` - Title, description, broken link, platform, directory layout, commands section, AI integration
- `docs/README.md` - Dual-system framing, broken link fix
- `docs/general/installation.md` - Agent system wizard section, Linux platform note

**Verification**:
- README.md mentions both Claude Code and OpenCode in the opening
- No broken links to `.claude/README.md` (should be `.claude/docs/README.md`)
- Platform section lists both macOS and Linux
- Directory layout includes `.opencode/`
- docs/README.md references both systems

---

### Phase 5: Clean Up .opencode/docs/ and Final Validation [NOT STARTED]

**Goal**: Remove ghost extension references from .opencode/docs/ and validate all cross-references across the documentation.

**Tasks**:
- [ ] Audit `.opencode/docs/` files for references to extensions not installed in this repo (lean, nix, web, z3, formal, founder) and either remove them or mark them as "available from upstream"
- [ ] Run a link validation pass across all modified files: check that all relative links resolve to existing files
- [ ] Verify consistency: ensure extension names match between docs/agent-system/extensions.md, README.md, and .opencode/docs/ pages
- [ ] Review all modified files for any remaining Claude-Code-only framing that should mention OpenCode

**Timing**: 0.5 hours

**Depends on**: 3, 4

**Files to modify**:
- `.opencode/docs/` - Multiple files: remove or annotate ghost extension references
- Various - Link fixes discovered during validation

**Verification**:
- No references to lean/nix/web/z3/formal/founder extensions remain in .opencode/docs/ without qualification
- All relative links in modified files resolve correctly
- Consistent extension naming across all documentation

## Testing & Validation

- [ ] `bash scripts/install/install.sh --dry-run` completes and shows agent-systems group
- [ ] `bash scripts/install/install-agent-systems.sh --check` reports Claude Code and/or OpenCode status
- [ ] `bash scripts/install/install-base.sh --check` no longer checks for Claude CLI or MCP servers
- [ ] All new pages (extensions.md, opencode.md) contain complete content with no placeholder text
- [ ] README.md broken `.claude/README.md` link is fixed to `.claude/docs/README.md`
- [ ] README.md platform section mentions Linux/NixOS
- [ ] No docs/ file contains exclusively Claude-Code-centric framing without OpenCode mention
- [ ] grep for "Two AI systems" in docs/agent-system/README.md confirms updated framing

## Artifacts & Outputs

- `docs/agent-system/extensions.md` - NEW: extension feature matrix
- `docs/agent-system/opencode.md` - NEW: OpenCode setup and reference
- `scripts/install/install-agent-systems.sh` - NEW: agent system install group
- `README.md` - Updated with dual-system content
- `docs/README.md` - Updated framing
- `docs/agent-system/README.md` - Reframed dual-system narrative
- `docs/agent-system/architecture.md` - Dual-system architecture diagram
- `docs/agent-system/commands.md` - Per-system availability
- `docs/agent-system/context-and-memory.md` - Expanded shared state docs
- `docs/general/installation.md` - Agent system wizard section
- `scripts/install/install.sh` - Updated groups and title
- `scripts/install/install-base.sh` - Reduced scope (no Claude CLI)
- `scripts/install/lib.sh` - Optional OpenCode helpers
- `.opencode/docs/` - Ghost reference cleanup

## Rollback/Contingency

All changes are to documentation and install scripts. Git revert of the implementation commits is sufficient to restore the previous state. No runtime code, build systems, or agent configurations are modified. If only some phases complete, the documentation will be partially improved but internally consistent within each phase's scope -- partial progress is safe.
