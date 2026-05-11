# Implementation Summary: Task #82

- **Task**: 82 - Improve documentation and installation script for dual agent systems
- **Status**: [COMPLETED]
- **Started**: 2026-05-11T12:00:00Z
- **Completed**: 2026-05-11T13:30:00Z
- **Effort**: 3 hours
- **Dependencies**: None
- **Artifacts**: [specs/082_improve_docs_and_install_script/reports/01_team-research.md], [specs/082_improve_docs_and_install_script/plans/01_docs-install-plan.md]
- **Standards**: status-markers.md, artifact-management.md, tasks.md

## Overview

The repository hosted two parallel AI agent systems (Claude Code and OpenCode) sharing 9 extensions, but all user-facing documentation and the installation wizard were entirely Claude Code-centric. This implementation rewrote documentation across README.md, docs/, and the install wizard to present both systems as equal peers, created new reference pages for extensions and OpenCode, and added agent system selection to the install wizard.

## What Changed

- Created `docs/agent-system/extensions.md` with a 9-extension feature matrix including per-system availability, naming differences, and exclusive capabilities
- Created `docs/agent-system/opencode.md` with setup guide, command comparison table, shared state model, and unique OpenCode capabilities
- Reframed `docs/agent-system/README.md` from "Two AI systems" (Zed Agent Panel + Claude Code) to "Three AI access methods" (Claude Code + OpenCode + Agent Panel)
- Added dual-system architecture diagram to `docs/agent-system/architecture.md` showing shared specs/ and .memory/ with separate config trees
- Added per-system availability markers (CC only, OC only) to `docs/agent-system/commands.md` and documented OpenCode-exclusive commands (/deck, /project-overview)
- Expanded shared state documentation in `docs/agent-system/context-and-memory.md`
- Created `scripts/install/install-agent-systems.sh` handling Claude Code CLI install and OpenCode binary verification
- Factored Claude CLI and MCP server functions out of `scripts/install/install-base.sh`
- Added `agent-systems` group to `scripts/install/install.sh` wizard (now 7 groups), updated title from "Zed + Claude Code" to "Zed toolchain"
- Updated `README.md`: dual-system title, Linux/NixOS platform support, .opencode/ in directory layout, fixed broken .claude/README.md link, renamed "Claude Code Commands" to "Agent Commands"
- Updated `docs/README.md` and `docs/general/installation.md` with dual-system framing and agent system selection section
- Cleaned ghost extension references (lean, nix, web, z3, formal, founder) from `.opencode/docs/` files

## Decisions

- Presented Claude Code and OpenCode as equal peers rather than primary/secondary
- Kept agent-system-specific content in dedicated pages (opencode.md, extensions.md) while shared content stays in shared pages
- Used "available from upstream" annotation for ghost extensions rather than removing references entirely (preserves documentation value)
- OpenCode install is verification-only (not Homebrew-based) since it's typically a NixOS system package

## Impacts

- Users can now discover and set up OpenCode from the documentation
- Install wizard supports choosing between Claude Code, OpenCode, or both
- All 30+ docs/ files now acknowledge both agent systems
- Extension feature matrix provides a single reference for understanding what each extension provides and where it differs between systems

## Follow-ups

- Pre-existing broken links in docs/ (general/R.md, general/python.md) should be fixed separately (these point to docs/toolchain/ paths)
- Task 66 (update docs post-refactoring) is largely subsumed by this work and could be marked [ABANDONED]

## References

- `specs/082_improve_docs_and_install_script/reports/01_team-research.md`
- `specs/082_improve_docs_and_install_script/plans/01_docs-install-plan.md`
