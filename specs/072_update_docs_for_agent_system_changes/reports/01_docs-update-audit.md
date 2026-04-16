# Research Report: Task #72

**Task**: Update docs/ to reflect agent system changes
**Date**: 2026-04-16
**Started**: 2026-04-16
**Completed**: 2026-04-16
**Standards**: report-format.md, artifact-formats.md

## Sources/Inputs

- `docs/agent-system/commands.md` (current state)
- `docs/agent-system/context-and-memory.md` (current state)
- `docs/agent-system/architecture.md` (current state)
- `docs/workflows/agent-lifecycle.md` (current state)
- `docs/workflows/memory-and-learning.md` (current state)
- `.claude/CLAUDE.md` (updated agent system, authoritative)
- `.claude/docs/reference/standards/agent-frontmatter-standard.md` (updated)

## Executive Summary

The agent system update introduced model/effort flags, replaced inline two-phase memory retrieval with `memory-retrieve.sh`, added `--refine` to `/distill`, and changed all agents to default to Opus. Five user-facing docs files need updates to match. Changes are mostly find-and-replace operations with no structural rewrites needed.

## Findings

### Finding 1: commands.md missing model/effort/clean flags

**File**: `docs/agent-system/commands.md`
**Lines**: 33, 46, 61

The `/research`, `/plan`, and `/implement` entries list flags but omit the new `--fast`, `--hard`, `--haiku`, `--sonnet`, `--opus`, and `--clean` flags.

**Current** (line 33):
```
**Flags**: `[focus]`, `--team`, `--clean`, multi-task syntax (`5, 7-9`)
```

Note: `/research` already has `--clean` but `/plan` and `/implement` do not mention it.

**Required changes**:

- `/research` flags (line 33): Add `--fast`, `--hard`, `--haiku`, `--sonnet`, `--opus` to existing flag list
- `/plan` flags (line 46): Add `--clean`, `--fast`, `--hard`, `--haiku`, `--sonnet`, `--opus`
- `/implement` flags (line 61): Add `--clean`, `--fast`, `--hard`, `--haiku`, `--sonnet`, `--opus`

Suggested format for each:
```
**Flags**: `--team`, `--clean`, `--fast|--hard`, `--haiku|--sonnet|--opus`, multi-task syntax
```

### Finding 2: commands.md /distill missing --refine sub-mode

**File**: `docs/agent-system/commands.md`
**Lines**: 206

The `/distill` entry lists `--purge`, `--merge`, `--compress`, `--auto`, `--gc` but omits the new `--refine` sub-mode. Also missing: `--dry-run` and `--verbose` flags.

**Required change**: Add `--refine` (improve memory metadata quality) to the flag list. Add `--dry-run`, `--verbose` as utility flags.

### Finding 3: context-and-memory.md describes stale two-phase retrieval

**File**: `docs/agent-system/context-and-memory.md`
**Lines**: 38, 74-79

Two locations describe the old two-phase retrieval algorithm with inline scoring logic. The system now uses `memory-retrieve.sh` which encapsulates the scoring.

**Current** (lines 74-79):
```
1. **Score phase** — Reads `.memory/memory-index.json`, scores entries by keyword overlap
   with the task description, and selects the top-5 entries above threshold.
2. **Retrieve phase** — Reads selected memory files (capped at 3000 tokens) and injects
   them as a `<memory-context>` block into the agent context.
```

**Required change**: Replace with description of `memory-retrieve.sh` script behavior. Keep the user-facing description simple:

```
Memory retrieval is automatic in `/research`, `/plan`, and `/implement` preflight stages
via the `memory-retrieve.sh` script. The script scores `memory-index.json` entries by
keyword overlap with the task description, selects top entries within a token budget
(TOKEN_BUDGET=2000, MAX_ENTRIES=5), and injects them as a `<memory-context>` block.
Tombstoned memories are excluded. Pass `--clean` to skip retrieval.
```

Also update the brief mention on line 38 to match.

### Finding 4: memory-and-learning.md describes stale two-phase retrieval

**File**: `docs/workflows/memory-and-learning.md`
**Lines**: 66-71

Same stale two-phase retrieval description as context-and-memory.md.

**Required change**: Same replacement as Finding 3. Update to reference `memory-retrieve.sh` with TOKEN_BUDGET=2000 and MAX_ENTRIES=5.

### Finding 5: memory-and-learning.md /distill table missing --refine

**File**: `docs/workflows/memory-and-learning.md`
**Lines**: 87-95

The `/distill` operations table has 6 rows but omits `--refine`.

**Required change**: Add row:
```
| `/distill --refine` | Improve memory metadata quality (keywords, tags, topics) |
```

### Finding 6: agent-lifecycle.md has stale --remember flag

**File**: `docs/workflows/agent-lifecycle.md`
**Lines**: 54, 107-108

Line 54 shows `--remember` as a `/research` flag:
```
/research 1 --remember   # search the .memory/ vault first
```

Line 107-108:
```
### --remember

Only on `/research`. Searches the [`.memory/`](../agent-system/context-and-memory.md)
vault for relevant prior knowledge and injects matches into the research context.
```

The `--remember` flag does not exist in the current system. Memory retrieval is now automatic (via `memory-retrieve.sh` in preflight) and is suppressed with `--clean`. The `--remember` flag was apparently a documentation artifact that was never removed.

**Required change**:
- Remove `--remember` example from line 54
- Replace the `### --remember` section (lines 107-108) with a `### --clean` section explaining that memory retrieval is automatic and `--clean` suppresses it
- Add the new model/effort flags to the examples and flags sections

### Finding 7: agent-lifecycle.md missing model/effort flags

**File**: `docs/workflows/agent-lifecycle.md`
**Lines**: 89-103

The "Advanced flags" section covers multi-task syntax and team mode but doesn't mention the new model or effort flags.

**Required change**: Add a subsection:

```markdown
### Model and effort flags

Override the agent's default model or reasoning depth:

| Flag | Effect |
|---|---|
| `--fast` | Lighter reasoning, faster responses |
| `--hard` | Deeper reasoning, more thorough analysis |
| `--haiku` | Use Haiku (fastest, lowest cost) |
| `--sonnet` | Use Sonnet (balanced) |
| `--opus` | Use Opus (highest quality, default) |

Effort and model flags are independent and combinable: `--fast --sonnet`.
```

### Finding 8: architecture.md model description is stale

**File**: `docs/agent-system/architecture.md`
**Lines**: Not explicitly stated but implicit in the general architecture description.

The architecture page doesn't explicitly mention model selection, but links to the agent frontmatter standard. No direct text change needed here -- the link to the standard is sufficient, and the standard itself has already been updated.

**Status**: No change required.

### Finding 9: context-and-memory.md /distill table missing --refine

**File**: `docs/agent-system/context-and-memory.md`
**Lines**: 95-103

Same as Finding 5 -- the distill operations table omits `--refine`.

**Required change**: Add `--refine` row to the table.

## Recommendations

### File-by-file change list

**`docs/agent-system/commands.md`** (3 changes):
1. Add `--fast|--hard`, `--haiku|--sonnet|--opus` to `/research`, `/plan`, `/implement` flag lists
2. Add `--clean` to `/plan` and `/implement` flag lists
3. Add `--refine`, `--dry-run`, `--verbose` to `/distill` flag list

**`docs/agent-system/context-and-memory.md`** (3 changes):
1. Replace two-phase retrieval description (line 38) with `memory-retrieve.sh` reference
2. Replace "Automatic memory retrieval" section (lines 74-79) with script-based description
3. Add `--refine` row to `/distill` operations table

**`docs/workflows/memory-and-learning.md`** (2 changes):
1. Replace "Automatic memory retrieval" section (lines 66-71) with script-based description
2. Add `--refine` row to `/distill` operations table

**`docs/workflows/agent-lifecycle.md`** (3 changes):
1. Remove `--remember` flag example and section
2. Add `### --clean` section (memory retrieval suppression)
3. Add `### Model and effort flags` section with table

**`docs/agent-system/architecture.md`**: No changes required.

## Summary

| File | Changes | Severity |
|------|---------|----------|
| `docs/agent-system/commands.md` | 3 edits | Medium (missing flags) |
| `docs/agent-system/context-and-memory.md` | 3 edits | Medium (stale retrieval description) |
| `docs/workflows/memory-and-learning.md` | 2 edits | Medium (stale retrieval description) |
| `docs/workflows/agent-lifecycle.md` | 3 edits | High (stale --remember flag, missing new flags) |
| **Total** | **11 edits across 4 files** | |
