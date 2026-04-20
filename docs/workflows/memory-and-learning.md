# Memory and Learning

Save knowledge across sessions and draw on prior learnings during research. The memory vault (`.memory/`) gives Claude persistent recall of facts, decisions, and discoveries that would otherwise be lost between conversations.

> **Requires the `memory` extension.** Ensure the extension is loaded before using these commands.

## Memory lifecycle

The memory system follows a four-stage lifecycle:

1. **Create** (`/learn`) — Save text, files, directories, or task artifacts as memories in the vault.
2. **Retrieve** (automatic) — Relevant memories are automatically injected into `/research`, `/plan`, and `/implement` contexts via `memory-retrieve.sh`. Pass `--clean` to skip retrieval.
3. **Harvest** (`/todo`) — When archiving completed tasks, `/todo` collects memory candidates emitted by agents and presents them for batch approval.
4. **Maintain** (`/distill`) — Score, purge, merge, compress, and garbage-collect vault entries to keep the vault healthy over time.

## Decision guide

| I want to... | Use |
|---|---|
| Save a piece of text as a memory | `/learn "text"` |
| Save the contents of a file | `/learn /path/to/file` |
| Scan a directory for learnable content | `/learn /path/to/dir/` |
| Harvest insights from a completed task | `/learn --task N` |
| Skip automatic memory retrieval | `/research N --clean` |
| Check vault health | `/distill` |
| Remove stale memories | `/distill --purge` |
| Merge duplicate memories | `/distill --merge` |
| Compress verbose memories | `/distill --compress` |
| Clean up metadata | `/distill --auto` |
| Hard-delete tombstoned memories | `/distill --gc` |

## Saving text as memory

```
/learn "The Cox model assumes we're using age as the time scale, not calendar time"
```

Stores the text in the `.memory/` vault with automatic content mapping and deduplication. If a similar memory already exists, it updates rather than duplicates.

## Learning from a file

```
/learn notes/meeting-2026-04-08.md
```

Reads the file and extracts key learnable content — decisions made, facts discovered, patterns identified. Useful for preserving meeting notes, design documents, or analysis results.

## Scanning a directory

```
/learn results/experiment-3/
```

Walks the directory and identifies files with learnable content. You can interactively select which items to save. Good for bulk knowledge capture after completing a research sprint.

## Harvesting task artifacts

```
/learn --task 42
```

Reviews the research reports, plans, and summaries for a completed task and creates memories from the key findings. This is the best way to preserve institutional knowledge after a task is archived by `/todo`.

## Automatic memory retrieval

Memory retrieval is automatic for all `/research`, `/plan`, and `/implement` operations via the `memory-retrieve.sh` script. The script scores `.memory/memory-index.json` entries by keyword overlap with the task description, selects the top matches (TOKEN_BUDGET=2000, MAX_ENTRIES=5), and injects them as a `<memory-context>` block into the agent context. Tombstoned memories are excluded from retrieval.

This helps Claude build on prior work rather than rediscovering things from scratch. Pass `--clean` to any of these commands to skip memory retrieval entirely.

## Memory harvest during archival

When `/todo` archives completed tasks, it collects memory candidates that agents emitted during research, planning, and implementation. Candidates are classified into three tiers:

- **Tier 1** (pre-selected) — High-confidence PATTERN and CONFIG candidates.
- **Tier 2** (presented) — Medium-confidence WORKFLOW and TECHNIQUE candidates.
- **Tier 3** (hidden) — Low-confidence or INSIGHT candidates.

You approve or reject candidates in a batch selection prompt. Approved memories are created with proper frontmatter and the JSON index is regenerated. Deduplication prevents creation of memories with >90% keyword overlap with existing entries.

## Vault maintenance (/distill)

The `/distill` command maintains vault health over time. Run it bare for a read-only health report, or with a flag to perform a specific operation.

| Mode | What it does |
|---|---|
| `/distill` | Print a health report: total memories, never-retrieved count, health score |
| `/distill --purge` | Tombstone stale or zero-retrieval memories (soft delete) |
| `/distill --merge` | Merge overlapping memories with keyword superset guarantee |
| `/distill --compress` | Reduce verbose memories to key points |
| `/distill --refine` | Improve memory metadata quality (keywords, tags, topics) |
| `/distill --auto` | Automatic safe metadata fixes (no interaction required) |
| `/distill --gc` | Hard-delete tombstoned memories past the 7-day grace period |

The `memory_health` field in `specs/state.json` tracks vault metrics: `last_distilled`, `distill_count`, `total_memories`, `never_retrieved`, `health_score`, and `status`.

See [`.claude/context/project/memory/distill-usage.md`](../../.claude/context/project/memory/distill-usage.md) for the full usage guide.

### Tombstone pattern

`/distill --purge` does not permanently delete memories. Instead, it marks them as tombstoned (soft delete). Tombstoned memories are excluded from retrieval but remain on disk for a 7-day grace period. After 7 days, `/distill --gc` permanently removes them. This two-step pattern prevents accidental data loss.

### Distill log

Every `/distill` operation is recorded in `.memory/distill-log.json` with timestamps, operation type, and affected memory IDs. This provides an audit trail for vault maintenance.

## See also

- [agent-lifecycle.md](agent-lifecycle.md) — The core task lifecycle
- [`../agent-system/commands.md`](../agent-system/commands.md) — Full command reference with flags
- [`../agent-system/context-and-memory.md`](../agent-system/context-and-memory.md) — How context and memory work in the agent system
- [`.claude/commands/distill.md`](../../.claude/commands/distill.md) — `/distill` command reference
- [`.claude/context/project/memory/distill-usage.md`](../../.claude/context/project/memory/distill-usage.md) — Full distill usage guide
