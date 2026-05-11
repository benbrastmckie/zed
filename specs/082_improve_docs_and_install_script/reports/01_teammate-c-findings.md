# Teammate C (Critic) Findings: Task 82

**Task**: Improve documentation and installation script for dual agent systems
**Date**: 2026-05-11
**Angle**: Gaps, blind spots, and shortcomings
**Confidence**: High

## Key Findings

### 1. OpenCode Is Completely Invisible to Users

The README.md, docs/README.md, docs/general/installation.md, docs/agent-system/README.md, and the install wizard (`scripts/install/install.sh`) contain **zero mentions** of OpenCode. The only OpenCode references in all of `docs/` are two passing mentions in `docs/agent-system/context-and-memory.md` about the shared `.memory/` vault.

A user cloning this repo would have no idea that `.opencode/` exists, what it does, or how it relates to `.claude/`. The directory layout in README.md lists `.claude/` but omits `.opencode/`.

### 2. Installation Script Has No OpenCode Support

The install wizard (`scripts/install/install.sh`) is entirely Claude Code-centric:
- `install-base.sh` installs `claude` CLI via `brew install --cask claude-code` and registers MCP servers via `claude mcp add`
- There is no `install-opencode.sh` group
- There is no mechanism to install the `opencode` CLI or configure its MCP servers
- The wizard has no concept of choosing between agent systems

OpenCode is installed via NixOS (`/run/current-system/sw/bin/opencode`) on this system, suggesting the install story for OpenCode may be completely different (Nix vs Homebrew) — this needs to be surfaced.

### 3. Platform Claims Are Misleading

README.md states "**Platform**: macOS 11+." and all installation docs are macOS-only. But this system is currently running on **Linux 7.0.3** (NixOS). The install wizard is Homebrew-only. If OpenCode users are expected to be on Linux/NixOS, the platform story needs significant expansion, or at minimum the README needs to clarify that macOS is only one supported platform.

### 4. Broken Link: .claude/README.md

README.md line 257 links to `[.claude/README.md](.claude/README.md)` — this file **does not exist**. The actual documentation hub is at `.claude/docs/README.md`. The docs/agent-system/README.md also references `.claude/README.md` at lines 74, 77. These are broken links.

## Critical Gaps Identified

### Gap 1: No Explanation of the Dual-System Relationship

Nowhere in the repo is the relationship between `.claude/` and `.opencode/` explained:
- Do they share `specs/`? (Yes — same TODO.md, state.json)
- Do they share `.memory/`? (Yes — mentioned in context-and-memory.md)
- Can they run simultaneously? 
- Are they interchangeable or complementary?
- Which system created which tasks? (specs/ uses prefix convention: no prefix = Claude Code, OC_ prefix = OpenCode)

### Gap 2: Extension Parity Is Not Documented

Both systems have the same 9 extensions (core, epidemiology, filetypes, latex, memory, present, python, slidev, typst) but with notable skill-level differences:
- Claude Code has `skill-docx-edit`, `skill-scrape`, `skill-filetypes-spreadsheet` — OpenCode does not
- OpenCode has `skill-deck`, `skill-project-overview`, `skill-spreadsheet` — Claude Code does not
- Naming differs: Claude Code uses `skill-epi-research` while OpenCode uses `skill-epidemiology-research`

These differences are nowhere documented. A user would not know which capabilities are available in which system.

### Gap 3: Agent Architecture Differences Are Undocumented

- Claude Code: agents in `.claude/agents/`, skills in `.claude/skills/`
- OpenCode: agents in `.opencode/agent/subagents/`, skills in `.opencode/skills/`
- Claude Code uses `CLAUDE.md` as the auto-loaded config; OpenCode uses `AGENTS.md`
- Different model defaults (Claude Code defaults to Opus; OpenCode mentions Sonnet as default)

### Gap 4: No Shared Documentation About What Extensions Provide

The `docs/agent-system/README.md` lists extensions with one-line descriptions but doesn't detail what each provides (skills, agents, commands, context files). There's no unified view of "extension X gives you these commands and capabilities."

## Documentation Blind Spots

1. **No user-facing extension catalog**: Which extensions are loaded? What do they provide? The only reference is `.claude/extensions.json` / `.opencode/extensions.json` — machine-readable files not designed for humans.

2. **No migration or switching guide**: If a user starts with Claude Code and wants to add OpenCode (or vice versa), there's no guidance.

3. **Team mode documentation**: Both systems support `--team` flag but this is only documented in `.claude/CLAUDE.md` and `.opencode/AGENTS.md` — not in the user-facing `docs/`.

4. **The `docs/agent-system/README.md` "Zed adaptations" section** says "No `.claude/extensions/` directory" but `.opencode/extensions/` does have a directory tree. This inconsistency between the two systems is not explained.

5. **`docs/` only links to `.claude/` commands**: The commands.md links all go to `.claude/commands/*.md`. If a user is using OpenCode, the equivalent files are at `.opencode/commands/*.md` — this isn't mentioned.

## Installation Concerns

1. **No OpenCode install path**: The wizard needs a new group or a routing mechanism to install OpenCode CLI and its dependencies.

2. **Different package managers**: Claude Code installs via Homebrew (`brew install --cask claude-code`); OpenCode may install via Nix, npm, or another method. The install script framework (`lib.sh`) is Homebrew-only.

3. **MCP server registration differs**: Claude Code uses `claude mcp add --scope user`; OpenCode likely has its own MCP registration mechanism. This needs investigation.

4. **Shared dependencies**: Both systems need `jq`, `gh`, Python, etc. The install wizard should allow installing shared toolchain without requiring either agent system.

5. **Linux support**: If OpenCode users are on Linux, the Homebrew-only install script is insufficient. Need to handle `apt`, `nix`, or at minimum document alternative install paths.

## Scope Assessment

The task scope is appropriate but potentially underestimates the install script work. Three sub-tasks should be considered:

1. **Documentation updates** (README.md, docs/): Primarily additive — can be done without breaking changes.

2. **Extension catalog creation** (new docs): Requires auditing both `.claude/extensions.json` and `.opencode/extensions.json` for accurate capability tables.

3. **Install script refactoring**: This is the riskiest part. The current script is well-structured but fundamentally assumes a single agent system (Claude Code) on macOS. Adding OpenCode support and potentially Linux support is a significant engineering effort.

### Questions That Should Be Asked

- Is this repo intended to support Linux users, or is macOS the only target?
- Should OpenCode be presented as equal to Claude Code, or as an optional alternative?
- Do users need both systems, or is it typically one or the other?
- Should the install wizard support Nix package manager for Linux?
- Who is the target audience for the documentation? (Researchers? Developers? Both?)
