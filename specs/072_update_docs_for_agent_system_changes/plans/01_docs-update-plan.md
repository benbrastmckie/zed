# Implementation Plan: Update docs/ for agent system changes

- **Task**: 72 - Update docs/ to reflect agent system changes
- **Status**: [IMPLEMENTING]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: reports/01_docs-update-audit.md
- **Artifacts**: plans/01_docs-update-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: true

## Overview

Four user-facing docs files contain stale references to removed flags (`--remember`), outdated two-phase memory retrieval descriptions, and missing new flags (`--fast|--hard`, `--haiku|--sonnet|--opus`, `--clean`, `--refine`). The research report identified 11 discrete edits across 4 files. All changes are find-and-replace operations with no structural rewrites. Done when all 4 files match the authoritative `.claude/CLAUDE.md`.

### Research Integration

Integrated findings from `reports/01_docs-update-audit.md`: 9 findings across 5 files (1 file confirmed no-change-needed), yielding 11 concrete edits organized by file.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No active roadmap items. ROADMAP.md is empty.

## Goals & Non-Goals

**Goals**:
- Update all command flag lists to include `--fast|--hard`, `--haiku|--sonnet|--opus`, and `--clean`
- Replace stale two-phase memory retrieval descriptions with `memory-retrieve.sh` references
- Add `--refine` to all `/distill` operation tables
- Remove stale `--remember` flag from agent-lifecycle.md and replace with `--clean`
- Add model/effort flags documentation to agent-lifecycle.md

**Non-Goals**:
- Rewriting prose or restructuring document layout
- Updating `docs/agent-system/architecture.md` (confirmed no changes needed)
- Changing any `.claude/` source files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Line numbers shifted since research | L | L | Use content matching (Edit tool) not line numbers |
| Inconsistent flag formatting across files | M | L | Use CLAUDE.md as the authoritative reference for format |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |

Phases within the same wave can execute in parallel.

### Phase 1: Update command flags and agent-lifecycle.md [COMPLETED]

**Goal**: Add missing flags to commands.md and fix stale --remember flag in agent-lifecycle.md.

**Tasks**:
- [ ] `docs/agent-system/commands.md`: Add `--fast|--hard`, `--haiku|--sonnet|--opus` to `/research` flags (line ~33)
- [ ] `docs/agent-system/commands.md`: Add `--clean`, `--fast|--hard`, `--haiku|--sonnet|--opus` to `/plan` flags (line ~46)
- [ ] `docs/agent-system/commands.md`: Add `--clean`, `--fast|--hard`, `--haiku|--sonnet|--opus` to `/implement` flags (line ~61)
- [ ] `docs/agent-system/commands.md`: Add `--refine`, `--dry-run`, `--verbose` to `/distill` flags (line ~206)
- [ ] `docs/workflows/agent-lifecycle.md`: Remove `--remember` example from /research examples (line ~54)
- [ ] `docs/workflows/agent-lifecycle.md`: Replace `### --remember` section with `### --clean` section (lines ~106-108)
- [ ] `docs/workflows/agent-lifecycle.md`: Add `### Model and effort flags` section with flag table

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `docs/agent-system/commands.md` -- 4 flag list updates
- `docs/workflows/agent-lifecycle.md` -- 3 changes (remove --remember, add --clean, add model/effort flags)

**Verification**:
- All `/research`, `/plan`, `/implement` flag lists include `--fast|--hard` and `--haiku|--sonnet|--opus`
- `/plan` and `/implement` include `--clean`
- `/distill` lists `--refine`, `--dry-run`, `--verbose`
- No mention of `--remember` in agent-lifecycle.md
- `--clean` section explains memory suppression
- Model/effort flags table present

---

### Phase 2: Update memory retrieval descriptions and distill tables [COMPLETED]

**Goal**: Replace stale two-phase retrieval descriptions with `memory-retrieve.sh` references and add `--refine` to distill tables.

**Tasks**:
- [ ] `docs/agent-system/context-and-memory.md`: Update brief retrieval mention (line ~38) to reference `memory-retrieve.sh`
- [ ] `docs/agent-system/context-and-memory.md`: Replace "Automatic memory retrieval" section (lines ~74-79) with script-based description
- [ ] `docs/agent-system/context-and-memory.md`: Add `--refine` row to `/distill` operations table (line ~102)
- [ ] `docs/workflows/memory-and-learning.md`: Replace "Automatic memory retrieval" section (lines ~66-71) with script-based description
- [ ] `docs/workflows/memory-and-learning.md`: Add `--refine` row to `/distill` operations table (line ~94)

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `docs/agent-system/context-and-memory.md` -- 3 changes (brief mention, full section, distill table)
- `docs/workflows/memory-and-learning.md` -- 2 changes (full section, distill table)

**Verification**:
- No mention of "two-phase retrieval" or "3000 tokens" in either file
- Both files reference `memory-retrieve.sh` with TOKEN_BUDGET=2000 and MAX_ENTRIES=5
- Both distill tables include `--refine` row
- `--clean` suppression still documented in both files

## Testing & Validation

- [ ] Grep all 4 files for "two-phase" -- should return zero matches
- [ ] Grep all 4 files for "--remember" -- should return zero matches
- [ ] Grep commands.md for "--fast" -- should appear in /research, /plan, /implement entries
- [ ] Grep commands.md for "--refine" -- should appear in /distill entry
- [ ] Grep agent-lifecycle.md for "--clean" -- should appear in new section
- [ ] Grep agent-lifecycle.md for "Model and effort flags" -- should appear as section heading
- [ ] Verify context-and-memory.md and memory-and-learning.md both mention `memory-retrieve.sh`

## Artifacts & Outputs

- `specs/072_update_docs_for_agent_system_changes/plans/01_docs-update-plan.md` (this plan)
- `specs/072_update_docs_for_agent_system_changes/summaries/01_docs-update-summary.md` (after implementation)
- Modified files: `docs/agent-system/commands.md`, `docs/agent-system/context-and-memory.md`, `docs/workflows/agent-lifecycle.md`, `docs/workflows/memory-and-learning.md`

## Rollback/Contingency

All changes are to tracked markdown files. Revert with `git checkout -- docs/agent-system/commands.md docs/agent-system/context-and-memory.md docs/workflows/agent-lifecycle.md docs/workflows/memory-and-learning.md`.
