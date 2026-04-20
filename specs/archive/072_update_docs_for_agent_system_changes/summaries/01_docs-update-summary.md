# Implementation Summary: Task #72

- **Task**: 72 - Update docs/ to reflect agent system changes
- **Status**: [COMPLETED]
- **Started**: 2026-04-16T00:00:00Z
- **Completed**: 2026-04-16T00:00:00Z
- **Effort**: 30 minutes
- **Dependencies**: None
- **Artifacts**: reports/01_docs-update-audit.md, plans/01_docs-update-plan.md
- **Standards**: status-markers.md, artifact-management.md, tasks.md

## Overview

Four user-facing docs files contained stale references to removed flags, outdated memory retrieval descriptions, and missing new flags. This implementation applied 11 discrete edits across 4 files to align documentation with the authoritative `.claude/CLAUDE.md`.

## What Changed

- `docs/agent-system/commands.md`: Added `--fast|--hard`, `--haiku|--sonnet|--opus` flags to `/research`, `/plan`, `/implement` entries; added `--clean` to `/plan` and `/implement`; added `--refine`, `--dry-run`, `--verbose` to `/distill` flags
- `docs/workflows/agent-lifecycle.md`: Replaced `--remember` example with `--clean`; replaced `### --remember` section with `### --clean` and `### Model and effort flags` sections including flag table
- `docs/agent-system/context-and-memory.md`: Updated brief retrieval mention and full "Automatic memory retrieval" section to reference `memory-retrieve.sh` with TOKEN_BUDGET=2000 and MAX_ENTRIES=5; added `--refine` row to distill table
- `docs/workflows/memory-and-learning.md`: Updated lifecycle summary and "Automatic memory retrieval" section to reference `memory-retrieve.sh`; added `--refine` row to distill table

## Decisions

- Used content matching (Edit tool) rather than line numbers for all edits, as plan recommended
- Kept the `--remember` references in out-of-scope files (mcp-servers.md, extensions.md, READMEs) untouched per plan non-goals

## Impacts

- All 4 target docs files now match `.claude/CLAUDE.md` for flag names and memory retrieval behavior
- No stale "two-phase retrieval" or "3000 tokens" references remain in any docs file

## Follow-ups

- Residual `--remember` references exist in `docs/toolchain/mcp-servers.md`, `docs/toolchain/extensions.md`, `docs/workflows/README.md`, and `docs/agent-system/README.md` -- these may need a separate cleanup pass

## References

- `specs/072_update_docs_for_agent_system_changes/reports/01_docs-update-audit.md`
- `specs/072_update_docs_for_agent_system_changes/plans/01_docs-update-plan.md`
- `.claude/CLAUDE.md` (authoritative source)
