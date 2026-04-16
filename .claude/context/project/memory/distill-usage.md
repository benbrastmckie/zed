# /distill Usage Guide

Memory vault maintenance command for scoring, reporting, and refining the `.memory/` vault.

## Quick Start

```bash
# Health report (read-only, safe)
/distill

# Remove stale memories (interactive)
/distill --purge

# Merge duplicates (interactive, keyword superset guaranteed)
/distill --merge

# Compress verbose memories (interactive)
/distill --compress

# Automatic metadata cleanup (non-interactive)
/distill --auto

# Hard-delete tombstoned memories past grace period
/distill --gc
```

## Memory Lifecycle

```
/learn (create) -> retrieval (use) -> /todo harvest (capture) -> /distill (maintain)
```

The `/distill` command is the maintenance phase of the memory lifecycle. It identifies memories that are stale, redundant, verbose, or have metadata quality issues, and provides operations to address each.

## Health Report

Running `/distill` with no flags produces a read-only health report:

- **Overview**: Total memories, total tokens, average size
- **Category distribution**: Breakdown by PATTERN/CONFIG/WORKFLOW/TECHNIQUE/INSIGHT
- **Topic clusters**: Memory count per topic prefix
- **Retrieval statistics**: Retrieved vs never-retrieved, most/least retrieved
- **Distillation candidates**: Purge, merge, and compress candidate counts
- **Health score**: 0-100 composite score

The health score formula: `100 - (purge_candidates * 3) - (merge_candidates * 5) - (compress_candidates * 2)`

Status thresholds:
- 70-100: healthy
- 40-69: needs_attention
- 0-39: unhealthy

## Scoring Engine

Each memory receives a composite distillation score (0.0-1.0):

| Component | Weight | Description |
|-----------|--------|-------------|
| Staleness | 0.30 | Days since last retrieval / 90 (FSRS-adjusted) |
| Zero-retrieval | 0.25 | 1.0 if never retrieved and >30 days old |
| Size | 0.20 | Linear penalty above 600 tokens |
| Duplicate | 0.25 | Highest keyword overlap with any other memory |

Higher scores indicate stronger distillation candidates.

## Operations

### Purge (--purge)

Identifies stale and zero-retrieval memories for soft deletion.

**Candidates**: `zero_retrieval == 1.0` OR `staleness > 0.8`

**Process**:
1. Score and rank candidates
2. Present interactive selection via AskUserQuestion
3. Tombstone selected memories (soft delete)
4. Scan for stale cross-references
5. Log operation

**Category TTL advisory** (for ranking, not automatic):
- CONFIG: 180 days
- TECHNIQUE: 270 days
- WORKFLOW: 365 days
- PATTERN: 540 days
- INSIGHT: no TTL

### Combine (--merge)

Merges overlapping memory pairs within topic clusters.

**Candidates**: Pairs with >60% keyword overlap

**Keyword superset guarantee**: The merged memory's keywords are always the union of both source memories' keywords. This prevents retrieval degradation.

**Process**:
1. Group by topic cluster, compute pairwise overlap
2. Present pairs for selection
3. Determine primary (higher retrieval_count)
4. Merge content, enforce keyword superset
5. Tombstone secondary memory
6. Update cross-references
7. Regenerate indices

### Compress (--compress)

Reduces verbose memories to key points while preserving history.

**Candidates**: Memories with >600 tokens

**Process**:
1. Present candidates for selection
2. Extract key points, preserve code blocks and examples
3. Move original to History section (same as UPDATE pattern)
4. Recalculate token_count
5. Verify all keywords preserved

### Auto/Refine (--auto)

Automatic metadata fixes that run without user interaction.

**Fixes applied**:
- Deduplicate keywords within each memory
- Add missing `summary` field (from first content line)
- Normalize topic paths (lowercase, consistent separators)
- Rebuild memory-index.json from filesystem state

### Garbage Collect (--gc)

Hard-deletes tombstoned memories past the 7-day grace period.

**Process**:
1. Scan for tombstoned memories older than 7 days
2. Present list for confirmation
3. Delete files, remove from index, regenerate index.md

## Tombstone Pattern

All destructive operations use soft-delete:
- `status: tombstoned` added to frontmatter
- `tombstoned_at: ISO8601` timestamp recorded
- `tombstone_reason` tracks why (purge, merged_into:{id})
- Memory excluded from retrieval but remains on disk
- Hard deletion only via `--gc` after 7-day grace period

## Integration with /todo

The `/todo` command conditionally suggests `/distill` based on vault state:
- Suppressed when vault has <5 memories
- Health report suggested at 10+ memories
- Full interactive suggested at 30+ memories or when >50% never retrieved
- Maintenance suggested when last distilled >30 days ago or never

## Distill Log

All operations are recorded in `.memory/distill-log.json` with:
- Timestamp and operation type
- Affected memories
- Before/after metrics
- Compression ratios (for compress operations)
- Keyword verification (for merge operations)

## State Tracking

The `memory_health` field in `specs/state.json` tracks:
- `last_distilled`: ISO8601 timestamp of last non-bare distillation
- `distill_count`: Total distillation operations performed
- `total_memories`: Current active memory count
- `never_retrieved`: Count of memories with zero retrievals
- `health_score`: 0-100 composite health score
- `status`: healthy/needs_attention/unhealthy
