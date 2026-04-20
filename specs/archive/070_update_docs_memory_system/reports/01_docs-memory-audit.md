# Research Report: Task #70

**Task**: 70 - Update documentation to reflect current memory system
**Started**: 2026-04-16T18:35:00Z
**Completed**: 2026-04-16T18:50:00Z
**Effort**: Small-medium (5 files, documentation-only)
**Dependencies**: Task 69 (create /distill command) -- completed
**Sources/Inputs**:
- `.claude/CLAUDE.md` -- Memory Extension section (authoritative)
- `.claude/commands/distill.md` -- /distill command definition
- `.claude/skills/skill-memory/SKILL.md` -- Distill mode, scoring engine, tombstone pattern
- `.claude/skills/skill-memory/README.md` -- Distill overview
- `.claude/context/project/memory/distill-usage.md` -- Usage guide
- `specs/state.json` -- memory_health field (live)
**Artifacts**:
- `specs/070_update_docs_memory_system/reports/01_docs-memory-audit.md` (this file)

## Executive Summary

- All 5 target documentation files are outdated: none mention `/distill`, the memory lifecycle, tombstone pattern, `memory_health`, or `distill-log.json`.
- The largest gaps are in `docs/workflows/memory-and-learning.md` (missing entire lifecycle and maintenance sections) and `docs/agent-system/context-and-memory.md` (missing retrieval, harvest, distill).
- `docs/agent-system/commands.md` is missing the `/distill` command entry entirely.
- `README.md` and `docs/README.md` need minor additions to surface `/distill` in command tables and section descriptions.
- The `/research --remember` flag documented in multiple files appears to be a legacy term; CLAUDE.md uses `--clean` (opt-out) and describes retrieval as automatic. This inconsistency should be resolved.

## Context & Scope

Task 69 created the `/distill` command and updated all source-of-truth files (CLAUDE.md, skill SKILL.md, skill README, context index, distill-usage.md). However, the user-facing documentation under `docs/` and the root `README.md` were not updated. This audit identifies every gap file-by-file with specific edit instructions.

## Findings

### File 1: `docs/agent-system/context-and-memory.md`

**Current state**: Covers `/learn` (4 modes), auto-memory, 5 context layers, content routing. No mention of `/distill`, memory lifecycle, retrieval mechanics, `/todo` harvest, tombstone pattern, or `memory_health`.

**Gap 1 -- Missing automatic retrieval section** (lines 38-39):
The file mentions `--remember` flag on `/research` as the read path. Per CLAUDE.md, memory retrieval is now **automatic** for all `/research`, `/plan`, and `/implement` operations. The `--remember` flag is not mentioned in CLAUDE.md; instead `--clean` is the opt-out. The current text at line 38 ("The `/research N --remember` flag searches the vault...") is outdated.

**Action**: Replace lines 38-39 with a section describing automatic two-phase retrieval (score phase + retrieve phase), the `--clean` opt-out flag, and remove/update the `--remember` references.

**Gap 2 -- Missing memory lifecycle** (after line 61):
No description of the full memory lifecycle: `/learn` (create) -> retrieval (use) -> `/todo` harvest (capture) -> `/distill` (maintain).

**Action**: Add a "Memory lifecycle" section after the `/learn` usage section (after ~line 61) showing the four-stage lifecycle.

**Gap 3 -- Missing `/distill` command** (after lifecycle section):
No mention of `/distill` or any maintenance operations.

**Action**: Add a "Vault maintenance (/distill)" section covering: bare health report, `--purge`, `--merge`, `--compress`, `--auto`, `--gc` flags; tombstone pattern (soft delete + 7-day grace period); `distill-log.json` auditability; `memory_health` state tracking.

**Gap 4 -- Missing `/todo` harvest** (after lifecycle section):
No mention of memory candidate emission by agents or the `/todo` harvest workflow.

**Action**: Add a "Memory harvest via /todo" subsection describing: agent emission of 0-3 candidates during research/plan/implement, three-tier classification (Tier 1 pre-selected, Tier 2 presented, Tier 3 hidden), batch approval during `/todo`.

**Gap 5 -- Outdated "See also" section** (lines 106-110):
Missing links to `/distill` command reference and distill-usage.md.

**Action**: Add links to `.claude/commands/distill.md` and `.claude/context/project/memory/distill-usage.md`.

**Gap 6 -- `/research --remember` section** (lines 63-69):
The dedicated "## /research --remember" section should be replaced or significantly rewritten. Per CLAUDE.md, retrieval is automatic; `--remember` is not mentioned in the authoritative source. The section should describe the automatic retrieval and the `--clean` opt-out instead.

**Action**: Replace the `## /research --remember` section with `## Automatic memory retrieval` section describing the two-phase retrieval that runs automatically on `/research`, `/plan`, `/implement`, with `--clean` opt-out.

---

### File 2: `docs/agent-system/commands.md`

**Current state**: 25-command catalog. Memory section (lines 184-195) only lists `/learn`. No `/distill` entry anywhere.

**Gap 1 -- Missing `/distill` command entry** (after line 195):
`/distill` is a full command with 5 flags and a bare mode. It should have its own entry in the Memory section.

**Action**: Add a `/distill` entry in the Memory section (after `/learn`) following the catalog template: 2-sentence explanation, 2 examples, flags, source link. Include all 6 invocation forms (bare, --purge, --merge, --compress, --auto, --gc).

**Gap 2 -- `/todo` description incomplete** (lines 78-85):
The `/todo` description does not mention memory harvest. Per CLAUDE.md, `/todo` now collects memory candidates from state.json and presents them for batch approval.

**Action**: Add a sentence to the `/todo` description: "Also harvests memory candidates emitted by agents during research, planning, and implementation, presenting them for batch approval."

**Gap 3 -- Command count** (line 1):
States "25 slash commands". Adding `/distill` makes it 26.

**Action**: Update count to 26.

**Gap 4 -- `/research` description mentions `--remember`** (lines 27-35):
Line 30 shows `--remember` flag. Per CLAUDE.md, retrieval is automatic; the opt-out flag is `--clean`.

**Action**: Replace `--remember` with `--clean` in the flags list and update the description to note automatic memory retrieval rather than opt-in.

---

### File 3: `docs/workflows/memory-and-learning.md`

**Current state**: Covers `/learn` (4 modes) and `/research --remember`. No mention of memory lifecycle, `/distill`, `/todo` harvest, automatic retrieval, tombstone pattern, or vault health.

**Gap 1 -- Missing memory lifecycle overview** (after line 4):
The file jumps straight to the decision guide. It needs a lifecycle overview section before the decision guide.

**Action**: Add a "## Memory lifecycle" section after the opening paragraph showing: `/learn` (create) -> retrieval (use) -> `/todo` harvest (capture) -> `/distill` (maintain). Brief 1-sentence description per stage.

**Gap 2 -- Outdated decision guide** (lines 9-16):
Missing rows for `/distill` operations and `/todo` harvest. The `--remember` row should be updated.

**Action**: Add rows:
- "Check vault health" -> `/distill`
- "Remove stale memories" -> `/distill --purge`
- "Merge duplicate memories" -> `/distill --merge`
- "Compress verbose memories" -> `/distill --compress`
- "Clean up metadata" -> `/distill --auto`
- "Hard-delete tombstoned memories" -> `/distill --gc`
- "Harvest memories from completed tasks" -> `/todo` (happens automatically)
- Update "Use prior knowledge during research" row: retrieval is now automatic, not via `--remember`

**Gap 3 -- Missing `/distill` sections** (after line 55):
No vault maintenance content at all.

**Action**: Add sections:
- `## Checking vault health` -- bare `/distill` usage, health score explanation
- `## Removing stale memories` -- `/distill --purge`, tombstone pattern explanation
- `## Merging duplicates` -- `/distill --merge`, keyword superset guarantee
- `## Compressing verbose memories` -- `/distill --compress`
- `## Automatic metadata cleanup` -- `/distill --auto`
- `## Garbage collection` -- `/distill --gc`, 7-day grace period
- `## Distill log` -- auditability via `.memory/distill-log.json`

**Gap 4 -- Missing `/todo` harvest section**:
No mention that `/todo` harvests memory candidates.

**Action**: Add `## Memory harvest during archival` section explaining that `/todo` collects memory candidates emitted by agents, presents them in three tiers, and creates approved memories.

**Gap 5 -- Outdated "Using memories in research" section** (lines 49-55):
Describes `--remember` as the retrieval mechanism. Per CLAUDE.md, retrieval is automatic.

**Action**: Rewrite as "## Automatic memory retrieval" explaining that `/research`, `/plan`, and `/implement` automatically inject relevant memories via two-phase retrieval. Mention `--clean` opt-out.

**Gap 6 -- Missing "See also" links** (lines 57-62):
No links to `/distill` usage guide or distill command.

**Action**: Add links to `distill-usage.md` and `.claude/commands/distill.md`.

---

### File 4: `docs/README.md`

**Current state**: Section index with descriptions. The Workflows description (line 23) mentions "memory management (`/learn`)" but not `/distill`.

**Gap 1 -- Workflows section description** (line 23):
Says "memory management (`/learn`)". Should include `/distill`.

**Action**: Change to "memory management (`/learn`, `/distill`)".

**Gap 2 -- Agent System section description** (line 19):
Mentions "memory" but doesn't list `/distill`. Minor, but for completeness.

**Action**: No change needed here; the Agent System section appropriately defers to its own pages. The Workflows section update is sufficient.

---

### File 5: `README.md`

**Current state**: Root README. Memory section (lines 157-162) only lists `/learn`. No `/distill`.

**Gap 1 -- Memory command table** (lines 157-162):
Only lists `/learn`. Missing `/distill`.

**Action**: Add `/distill` row: "Maintain memory vault health (scoring, purging, merging, compressing)".

**Gap 2 -- Common Scenarios table** (lines 179-187):
No entry for memory maintenance.

**Action**: No change strictly needed; the "Common Scenarios" table is about domain workflows, not individual commands. The Memory command table addition is sufficient.

**Gap 3 -- AI Integration paragraph** (line 242):
Lists "persistent memory (`/learn`)" but not `/distill`.

**Action**: Change to "persistent memory (`/learn`, `/distill`)".

---

### Cross-cutting Issue: `--remember` vs automatic retrieval

CLAUDE.md (authoritative) describes memory retrieval as **automatic** for `/research`, `/plan`, `/implement` with `--clean` as opt-out. Multiple docs files reference `--remember` as an opt-in flag. This inconsistency exists in:

1. `docs/agent-system/context-and-memory.md` (lines 38-39, 63-69)
2. `docs/agent-system/commands.md` (lines 30, 34)
3. `docs/workflows/memory-and-learning.md` (lines 15, 49-55)

**Decision**: Align all docs with CLAUDE.md. Replace `--remember` references with automatic retrieval + `--clean` opt-out.

## Decisions

1. Use CLAUDE.md as the authoritative source for all memory system behavior.
2. Replace `--remember` with automatic retrieval + `--clean` opt-out across all docs.
3. Add `/distill` as a standalone command entry in `commands.md` (not merged into `/learn`).
4. Add lifecycle overview to both `context-and-memory.md` and `memory-and-learning.md`.
5. Keep docs concise -- reference `distill-usage.md` for deep details rather than duplicating.

## Recommendations

1. **Priority 1 -- `docs/workflows/memory-and-learning.md`**: Largest gap. Needs lifecycle, `/distill` sections, harvest section, and retrieval update. Estimated: add ~80 lines.
2. **Priority 2 -- `docs/agent-system/context-and-memory.md`**: Second largest gap. Needs retrieval rewrite, lifecycle, `/distill`, harvest sections. Estimated: add ~50 lines, modify ~10 lines.
3. **Priority 3 -- `docs/agent-system/commands.md`**: Missing `/distill` entry and needs `--remember` -> `--clean` update. Estimated: add ~20 lines, modify ~5 lines.
4. **Priority 4 -- `README.md`**: Two minor additions (`/distill` row, AI integration mention). Estimated: 3 line changes.
5. **Priority 5 -- `docs/README.md`**: One word change. Estimated: 1 line change.

## Risks & Mitigations

- **Risk**: `--remember` flag may still be functional in command files. **Mitigation**: Check `.claude/commands/research.md` during implementation to confirm whether `--remember` still works or has been replaced by automatic retrieval.
- **Risk**: Over-documenting `/distill` in user-facing docs. **Mitigation**: Keep docs sections brief with "See distill-usage.md for details" links.

## Appendix

### Files Read (Source of Truth)

| File | Key Content |
|------|-------------|
| `.claude/CLAUDE.md` | Memory Extension section: /learn, /distill commands, lifecycle, retrieval, harvest, memory_health |
| `.claude/commands/distill.md` | Full /distill command spec: argument parsing, flag routing, scoring engine, operations, state updates |
| `.claude/skills/skill-memory/SKILL.md` | mode=distill: scoring components, purge/combine/compress/auto/gc, tombstone pattern, distill-log schema |
| `.claude/skills/skill-memory/README.md` | Distill overview with operation table and tombstone summary |
| `.claude/context/project/memory/distill-usage.md` | User-facing guide: quick start, lifecycle, health report, operations, tombstone, /todo integration |
| `specs/state.json` | Live memory_health: `{"last_distilled":null,"distill_count":0,"total_memories":8,"never_retrieved":8,"health_score":100,"status":"healthy"}` |

### Gap Summary Matrix

| Topic | context-and-memory.md | commands.md | memory-and-learning.md | docs/README.md | README.md |
|-------|:----:|:----:|:----:|:----:|:----:|
| `/distill` command | MISSING | MISSING | MISSING | MISSING | MISSING |
| Memory lifecycle | MISSING | n/a | MISSING | n/a | n/a |
| Automatic retrieval | WRONG (`--remember`) | WRONG (`--remember`) | WRONG (`--remember`) | n/a | n/a |
| `--clean` opt-out | MISSING | MISSING | MISSING | n/a | n/a |
| Tombstone pattern | MISSING | n/a | MISSING | n/a | n/a |
| `memory_health` | MISSING | n/a | n/a | n/a | n/a |
| `distill-log.json` | MISSING | n/a | MISSING | n/a | n/a |
| `/todo` harvest | MISSING | INCOMPLETE | MISSING | n/a | n/a |
| Scoring engine | MISSING | n/a | MISSING | n/a | n/a |
| Memory index `status` field | MISSING | n/a | n/a | n/a | n/a |
