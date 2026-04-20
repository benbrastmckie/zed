# Implementation Plan: Update docs for current memory system

- **Task**: 70 - Update documentation to reflect current memory system
- **Status**: [IMPLEMENTING]
- **Effort**: 2 hours
- **Dependencies**: Task 69 (completed)
- **Research Inputs**: reports/01_docs-memory-audit.md
- **Artifacts**: plans/01_docs-memory-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: true

## Overview

Update 5 documentation files to reflect the current memory system, which now includes `/distill` for vault maintenance, automatic memory retrieval (replacing the legacy `--remember` flag), `/todo` harvest of memory candidates, tombstone-based soft deletion, and `memory_health` state tracking. The research report identifies every gap file-by-file with specific edit instructions; this plan organizes those edits into 3 phases by file grouping and dependency.

### Research Integration

The research report (01_docs-memory-audit.md) audited all 5 target files against the authoritative CLAUDE.md Memory Extension section and found: (1) no file mentions `/distill`, the memory lifecycle, tombstone pattern, `memory_health`, or `distill-log.json`; (2) three files incorrectly document `--remember` as an opt-in flag when retrieval is now automatic with `--clean` as opt-out; (3) the largest gaps are in `memory-and-learning.md` and `context-and-memory.md`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items apply to this documentation task.

## Goals & Non-Goals

**Goals**:
- Document the full memory lifecycle: `/learn` (create) -> retrieval (use) -> `/todo` harvest (capture) -> `/distill` (maintain)
- Add `/distill` command to all relevant command tables and reference pages
- Replace outdated `--remember` references with automatic retrieval + `--clean` opt-out
- Document tombstone pattern, `memory_health` state tracking, and `distill-log.json` auditability
- Keep docs concise with "see distill-usage.md" links for deep details

**Non-Goals**:
- Rewriting unrelated sections of these documentation files
- Documenting internal skill/agent implementation details (those belong in `.claude/` source files)
- Updating `.claude/` source-of-truth files (already done in task 69)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `--remember` flag may still be functional in command files | M | L | Check `.claude/commands/research.md` during implementation to confirm current behavior before removing references |
| Over-documenting `/distill` in user-facing docs | L | M | Keep sections brief, link to `distill-usage.md` for details |
| Inconsistency between the 5 files after partial edits | M | L | Phase 1 handles the two largest files together; Phase 2 handles commands.md; Phase 3 handles the two small files. Cross-check terminology after each phase. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases are sequenced to establish canonical terminology in the deep-content files first (Phase 1), then align the command catalog (Phase 2), then update surface-level references (Phase 3).

---

### Phase 1: Update deep-content files (context-and-memory.md + memory-and-learning.md) [COMPLETED]

**Goal**: Bring the two files with the largest gaps up to date with the full memory system.

**Tasks**:

For `docs/workflows/memory-and-learning.md`:
- [ ] Add `## Memory lifecycle` section after line 4 (opening paragraph) with 4-stage diagram: `/learn` (create) -> retrieval (use) -> `/todo` harvest (capture) -> `/distill` (maintain), one sentence per stage
- [ ] Update decision guide table (lines 9-16): add rows for `/distill` (bare), `--purge`, `--merge`, `--compress`, `--auto`, `--gc`, and `/todo` harvest; change `--remember` row to describe automatic retrieval with `--clean` opt-out
- [ ] Replace "Using memories in research" section (lines 49-55) with `## Automatic memory retrieval` explaining two-phase retrieval (score phase + retrieve phase) for `/research`, `/plan`, `/implement`, with `--clean` opt-out
- [ ] Add `## Memory harvest during archival` section explaining `/todo` collects agent-emitted memory candidates, three-tier classification, batch approval
- [ ] Add `## Vault maintenance (/distill)` section covering: bare health report, `--purge` (tombstone stale memories), `--merge` (combine overlapping), `--compress` (reduce verbose), `--auto` (safe metadata fixes), `--gc` (hard-delete past 7-day grace period)
- [ ] Add `## Tombstone pattern` subsection: soft delete, 7-day grace period, `--gc` for permanent removal
- [ ] Add `## Distill log` subsection: `.memory/distill-log.json` auditability
- [ ] Update "See also" section: add links to `.claude/commands/distill.md` and `.claude/context/project/memory/distill-usage.md`

For `docs/agent-system/context-and-memory.md`:
- [ ] Replace lines 38-39 (read path describing `--remember`) with description of automatic two-phase retrieval and `--clean` opt-out
- [ ] Replace `## /research --remember` section (lines 63-69) with `## Automatic memory retrieval` describing automatic injection for `/research`, `/plan`, `/implement` with `--clean` opt-out
- [ ] Add `## Memory lifecycle` section (after the `/learn` usage section, ~line 61) showing the four-stage lifecycle
- [ ] Add `## Vault maintenance (/distill)` section covering: bare health report, flags, tombstone pattern, `distill-log.json`, `memory_health` state tracking
- [ ] Add `## Memory harvest via /todo` subsection describing agent emission, three-tier classification, batch approval
- [ ] Update "See also" section (lines 104-110): add links to `.claude/commands/distill.md` and `.claude/context/project/memory/distill-usage.md`; update `--remember` link text to reflect automatic retrieval

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `docs/workflows/memory-and-learning.md` - Add lifecycle, distill sections, rewrite retrieval section (~80 lines added)
- `docs/agent-system/context-and-memory.md` - Add lifecycle, distill, harvest sections, rewrite retrieval (~50 lines added, ~10 lines modified)

**Verification**:
- Both files mention `/distill` with all 6 invocation forms
- No remaining references to `--remember`
- Both files describe automatic retrieval with `--clean` opt-out
- Memory lifecycle appears in both files
- Tombstone pattern and `distill-log.json` documented

---

### Phase 2: Update command catalog (commands.md) [COMPLETED]

**Goal**: Add `/distill` as a full command entry and fix `--remember` references in the command catalog.

**Tasks**:
- [ ] Update command count on line 1 from "25" to "26"
- [ ] Add `/distill` entry in the Memory section (after `/learn`, after line 195) following catalog template: 2-sentence explanation, 2 examples, all 6 invocation forms (bare, --purge, --merge, --compress, --auto, --gc), source link to `.claude/commands/distill.md`
- [ ] Update `/research` entry (lines 26-35): replace `--remember` with `--clean` in flags list; update description to note automatic memory retrieval rather than opt-in; update example from `--remember` to `--clean`
- [ ] Update `/todo` description (lines 78-85): add sentence about memory harvest ("Also harvests memory candidates emitted by agents during research, planning, and implementation, presenting them for batch approval.")

**Timing**: 30 minutes

**Depends on**: 1 (terminology established in Phase 1)

**Files to modify**:
- `docs/agent-system/commands.md` - Add `/distill` entry (~20 lines), modify `/research` and `/todo` entries (~5 lines each)

**Verification**:
- `/distill` appears as a standalone entry in the Memory section
- Command count says "26"
- No remaining `--remember` references
- `/todo` entry mentions memory harvest

---

### Phase 3: Update surface-level references (README.md + docs/README.md) [COMPLETED]

**Goal**: Surface `/distill` in the root README command table and docs index.

**Tasks**:

For `README.md`:
- [ ] Add `/distill` row to Memory command table (after `/learn` row, ~line 161): "Maintain memory vault health (scoring, purging, merging, compressing)"
- [ ] Update AI Integration paragraph (line 242): change "persistent memory (`/learn`)" to "persistent memory (`/learn`, `/distill`)"

For `docs/README.md`:
- [ ] Update Workflows section description (line 23): change "memory management (`/learn`)" to "memory management (`/learn`, `/distill`)"

**Timing**: 15 minutes

**Depends on**: 2 (ensures command catalog is consistent before updating surface references)

**Files to modify**:
- `README.md` - Add `/distill` to command table (1 line), update AI Integration text (1 line)
- `docs/README.md` - Update Workflows description (1 line)

**Verification**:
- `/distill` appears in README.md Memory table
- AI Integration paragraph mentions `/distill`
- docs/README.md Workflows description mentions `/distill`

## Testing & Validation

- [ ] All 5 files updated with no remaining `--remember` references (grep for `--remember` returns zero hits in `docs/` and `README.md`)
- [ ] `/distill` mentioned in all 5 files
- [ ] Memory lifecycle documented in `context-and-memory.md` and `memory-and-learning.md`
- [ ] Tombstone pattern documented in at least `memory-and-learning.md`
- [ ] `distill-log.json` documented in at least `memory-and-learning.md`
- [ ] `memory_health` state tracking documented in `context-and-memory.md`
- [ ] All internal links are valid relative paths
- [ ] No duplication of deep technical details that belong in `distill-usage.md`

## Artifacts & Outputs

- `docs/workflows/memory-and-learning.md` - Updated with lifecycle, distill, harvest, and retrieval sections
- `docs/agent-system/context-and-memory.md` - Updated with lifecycle, distill, harvest, retrieval, and memory_health sections
- `docs/agent-system/commands.md` - Updated with `/distill` entry, `--remember` -> `--clean`, `/todo` harvest mention
- `README.md` - Updated with `/distill` in command table and AI Integration
- `docs/README.md` - Updated with `/distill` in Workflows description

## Rollback/Contingency

All changes are to tracked markdown files. Revert with `git checkout HEAD -- docs/ README.md` if any update introduces inconsistencies. Each phase modifies a distinct set of files, so partial rollback is straightforward.
