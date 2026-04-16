---
description: Maintain memory vault health through scoring, purging, merging, compressing, and refining memories
allowed-tools: Read, Write, Edit, Bash(jq:*), Bash(wc:*), Bash(ls:*), Bash(grep:*), Bash(date:*), Bash(sort:*), Bash(head:*), Glob, Grep, AskUserQuestion
argument-hint: [--purge] [--merge] [--compress] [--auto] [--gc]
---

# Command: /distill

**Purpose**: Maintain memory vault health at scale through scoring, reporting, and four distillation operations (purge, combine, compress, refine). Default (bare) invocation produces a read-only health report.
**Layer**: 2 (Command File - Argument Parsing Agent)
**Delegates To**: skill-memory (mode=distill, direct execution)

**Input**: $ARGUMENTS

---

## Argument Parsing

```
args = $ARGUMENTS

# Flag detection
purge   = "--purge" in args
merge   = "--merge" in args
compress = "--compress" in args
auto    = "--auto" in args
gc      = "--gc" in args
bare    = not (purge or merge or compress or auto or gc)
```

## Flag Routing

| Flag | Operation | Interactive? | Description |
|------|-----------|-------------|-------------|
| (bare) | Health Report | No | Read-only vault health report |
| `--purge` | Purge | Yes | Tombstone stale/zero-retrieval memories |
| `--merge` | Combine | Yes | Merge overlapping memories with keyword superset guarantee |
| `--compress` | Compress | Yes | Reduce verbose memories to key points |
| `--auto` | Refine (safe) | No | Automatic metadata fixes (keyword dedup, summary generation, topic normalization) |
| `--gc` | Garbage Collect | Yes | Hard-delete tombstoned memories past 7-day grace period |

## Execution Flow

### 1. Load Memory Index

```bash
# Validate memory-index.json freshness (validate-on-read pattern)
disk_files=$(ls .memory/10-Memories/MEM-*.md 2>/dev/null | xargs -n1 basename | sed 's/.md$//' | sort)
index_ids=$(jq -r '.entries[].id' .memory/memory-index.json 2>/dev/null | sort)

if [ "$disk_files" != "$index_ids" ]; then
  echo "Memory index stale - regenerating..."
  # Trigger full index regeneration from skill-memory
fi
```

### 2. Compute Scores

For each memory entry in memory-index.json, compute composite distillation score.

**Scoring Engine** (see skill-memory SKILL.md mode=distill for full algorithm):

| Component | Weight | Formula |
|-----------|--------|---------|
| Staleness | 0.30 | `days_since_last_retrieval / 90` (capped at 1.0), FSRS adjustment: reduce by 0.3 if retrieval_count > 0 AND days_since_created > 60 |
| Zero-retrieval | 0.25 | `1.0 if retrieval_count == 0 AND days_since_created > 30, else 0.0` |
| Size penalty | 0.20 | `max(0, (token_count - 600) / 600)` (linear above 600 tokens) |
| Duplicate | 0.25 | Highest keyword overlap with any other memory |

Composite: `(staleness * 0.3) + (zero_retrieval * 0.25) + (size * 0.2) + (duplicate * 0.25)`

### 3. Route by Flag

```
if bare:
  -> Generate Health Report (Step 4)
  -> Update memory_health in state.json
elif purge:
  -> Purge Operation (skill-memory mode=distill, op=purge)
elif merge:
  -> Combine Operation (skill-memory mode=distill, op=combine)
elif compress:
  -> Compress Operation (skill-memory mode=distill, op=compress)
elif auto:
  -> Refine/Auto Operation (skill-memory mode=distill, op=auto)
elif gc:
  -> Garbage Collect (skill-memory mode=distill, op=gc)
```

### 4. Health Report (bare invocation)

Generate and display vault health report:

```
Memory Vault Health Report
==========================

Overview:
  Total memories: {N}
  Total tokens: {N}
  Average tokens/memory: {N}

Category Distribution:
  PATTERN:   {N}
  CONFIG:    {N}
  WORKFLOW:  {N}
  TECHNIQUE: {N}
  INSIGHT:   {N}

Topic Clusters:
  {topic}: {N} memories
  {topic}: {N} memories

Retrieval Statistics:
  Retrieved at least once: {N}
  Never retrieved: {N}
  Most retrieved: {memory_id} ({N} times)
  Least retrieved: {memory_id} ({N} times)

Distillation Candidates:
  Purge candidates (zero-retrieval >30d): {N}
  Merge candidates (>60% overlap): {N}
  Compress candidates (>600 tokens): {N}

Health Score: {N}/100
  Deductions: -{purge*3} purge, -{merge*5} merge, -{compress*2} compress
```

### 5. Update State

After any operation (including bare report):

```bash
# Update memory_health in state.json
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --argjson total "$total_memories" \
   --argjson never "$never_retrieved" \
   --argjson score "$health_score" \
   --argjson count "$distill_count" \
   '.memory_health = {
     "last_distilled": (if $count > 0 then $ts else .memory_health.last_distilled end),
     "distill_count": $count,
     "total_memories": $total,
     "never_retrieved": $never,
     "health_score": $score,
     "status": (if $score >= 70 then "healthy" elif $score >= 40 then "needs_attention" else "unhealthy" end)
   }' specs/state.json > specs/state.json.tmp && mv specs/state.json.tmp specs/state.json
```

### 6. Log Operation

For non-bare invocations, append to `.memory/distill-log.json`:

```json
{
  "timestamp": "ISO8601",
  "operation": "{purge|combine|compress|refine|gc}",
  "memories_affected": ["MEM-slug-1"],
  "pre_metrics": {"total_memories": 8, "total_tokens": 3751},
  "post_metrics": {"total_memories": 8, "total_tokens": 3751}
}
```

### 7. Git Commit

```bash
git add .memory/ specs/state.json
git commit -m "distill: {operation} {N} memories

Session: ${session_id}"
```

## Error Handling

| Error | Response |
|-------|----------|
| No memories found | Display "Memory vault is empty. Use /learn to add memories." |
| memory-index.json missing | Regenerate from filesystem state |
| state.json write failure | Log error, continue (non-blocking) |
| distill-log.json missing | Create with initial schema |

## Notes

- Bare invocation is always safe (read-only report + state.json update)
- All destructive operations require interactive confirmation via AskUserQuestion
- `--auto` is the only flag that skips user interaction (limited to safe metadata fixes)
- Tombstone pattern ensures no data loss; `--gc` is the only hard-delete path
- The scoring engine uses the same keyword overlap algorithm as skill-memory retrieval
