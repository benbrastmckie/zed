# Implementation Summary: Revise Documentation for New Extensions

- **Task**: 83 - revise_docs_for_new_extensions
- **Status**: [COMPLETED]
- **Started**: 2026-05-11T00:01:00Z
- **Completed**: 2026-05-11T00:30:00Z
- **Effort**: ~1 hour (estimated 4 hours)
- **Dependencies**: None
- **Artifacts**: [plans/01_docs-revision-plan.md], [reports/01_team-research.md]
- **Standards**: status-markers.md, artifact-management.md, tasks.md

## Overview

Revised documentation across `docs/` and `README.md` to reflect the current state of the agent system: 10 extensions (not 9), web extension documented, `/sheet` command added to catalogs, broken doc paths fixed, and a new comparison document created for the two AI agent systems (Claude Code and OpenCode). Also restored `docs/agent-system/opencode.md` which had been deleted from the working tree and corrected the false claim about `.claude/extensions/` not existing.

## What Changed

- Created `docs/ai_agent_systems.md` -- new comparison doc covering cost model, shared infrastructure, and differences between Claude Code and OpenCode
- Restored and updated `docs/agent-system/opencode.md` -- fixed extension count (9 -> 10), corrected `/project-overview` attribution (now both systems), added link to comparison doc
- Fixed "9 extensions" -> "10 extensions" in 4 files: `docs/agent-system/extensions.md`, `docs/agent-system/README.md`, `docs/README.md`, `README.md`
- Fixed broken Python/R doc paths in 3 files: `docs/README.md`, `docs/workflows/README.md`, `docs/agent-system/README.md` (`general/python.md` -> `toolchain/python.md`, `general/R.md` -> `toolchain/r.md`)
- Corrected false "No `.claude/extensions/` directory" claim in `docs/agent-system/README.md` -- replaced with accurate description of the 10-extension architecture
- Added `web` extension to feature matrix in `docs/agent-system/extensions.md` and extension list in `docs/agent-system/README.md`
- Added `web` and `python` sections to `docs/toolchain/extensions.md` with prerequisites and build commands
- Added `/sheet` command to `docs/agent-system/commands.md` (Documents section) and `README.md` (Document Tools table)
- Rewrote `docs/workflows/edit-spreadsheets.md` to feature `/sheet` as the primary interface, with direct MCP as fallback
- Fixed `/project-overview` in `docs/agent-system/commands.md` -- removed OC-only label, moved to shared section, updated source link
- Updated `README.md` Quick Start to mention system choice and link to comparison doc
- Added `ai_agent_systems.md` to navigation in `docs/README.md`, `docs/agent-system/README.md`, and `README.md` Documentation table

## Decisions

- Kept `/deck` as OC-only since OpenCode is still active and it is exclusive to that system
- Used hedged language for pricing claims in the comparison doc ("at time of writing")
- Added both `python` and `web` extension sections to `docs/toolchain/extensions.md` (python was also missing)
- Did not create a web development workflow guide -- noted as potential follow-up

## Impacts

- Users can now find accurate extension counts (10) throughout all documentation
- The new comparison doc provides a clear entry point for understanding the dual-system architecture
- `/sheet` is now discoverable through the command catalog and README
- Python/R setup links now resolve to the correct `docs/toolchain/` paths
- Web extension is documented alongside all other extensions

## Follow-ups

- Consider creating a `docs/workflows/web-development.md` workflow guide for the web extension
- The `docs/agent-system/README.md` General section still says "Covers Homebrew, Node.js" -- may want to update for non-macOS platforms

## References

- `specs/083_revise_docs_for_new_extensions/plans/01_docs-revision-plan.md`
- `specs/083_revise_docs_for_new_extensions/reports/01_team-research.md`
