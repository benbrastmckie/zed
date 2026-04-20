# Context and Memory

Claude Code in this workspace pulls information from two distinct memory layers and five context layers. Keeping them straight matters: each has a different owner, lifetime, and sharing model.

## Summary

- **Project memory vault** (`.memory/`) — agent-managed Obsidian vault. Shared with OpenCode. Write via `/learn`, maintain via `/distill`.
- **Auto-memory** (`~/.claude/projects/...`) — harness-managed user preferences. Agents do not touch it.
- **Five context layers** — agent context, extensions, project context, project memory, auto-memory. Each has a different purpose.

## Two memory layers

### Project memory vault (.memory/)

**Location**: `~/.config/zed/.memory/`

A real, populated [Obsidian](https://obsidian.md)-compatible vault managed by agents via the `skill-memory` skill and the `/learn` command. **Shared with OpenCode**: both AI systems read and write the same vault, using timestamped memory IDs for collision resistance. See [`.memory/README.md`](../../.memory/README.md) for the full structure and sharing protocol.

**Structure**:

```
.memory/
├── 00-Inbox/        # Quick capture before classification
├── 10-Memories/     # Permanent storage (MEM-{semantic-slug}.md)
├── 20-Indices/      # index.md and topic indices
└── 30-Templates/    # memory-template.md and README
```

**File format**: YAML frontmatter with `title`, `created`, `tags`, `topic`, `source`, `modified`. Filenames are unique IDs (e.g., `MEM-telescope-custom-pickers.md`).

**Write path** — the `/learn` command has four modes:

- `/learn "text"` — inline capture
- `/learn /path/to/file.md` — ingest a file as a memory source
- `/learn /path/to/dir/` — scan a directory for learnable content
- `/learn --task N` — review a completed task's artifacts and propose memories

**Read path** — memory retrieval is automatic for all `/research`, `/plan`, and `/implement` operations. The `memory-retrieve.sh` script scores `.memory/memory-index.json` entries by keyword overlap with the task description (TOKEN_BUDGET=2000, MAX_ENTRIES=5) and injects the top matches as a `<memory-context>` block into the agent context. Pass `--clean` to skip retrieval. Tombstoned memories are excluded from retrieval.

**What belongs here**: learned facts, discoveries, decisions, reusable patterns, project-specific lessons.

### Auto-memory (Claude Code harness)

**Location**: `~/.claude/projects/-home-benjamin--config-zed/memory/`

Managed by the Claude Code harness, **not by agents**. Stores user preferences and behavioral corrections captured automatically from conversation (for example, `feedback_no_vim_mode_zed.md`: "Zed shared with collaborator; use standard keybindings, not vim").

You never write to this directory directly, and agents never read from or modify it. It is harness-private. If you want Claude Code to remember something across sessions at the project level, use `/learn` (which writes to `.memory/`) — not the auto-memory layer.

## Using /learn

The `/learn` command is the only write path to the project memory vault. Common uses:

```
/learn "macOS permissions dialog appears the first time Claude edits Word while Word is open"
/learn ~/notes/debugging-session.md
/learn ~/papers/tb-surveillance/
/learn --task 12
```

Each mode runs content through classification (topic, tags) and deduplication against existing memories before writing. See [`.claude/commands/learn.md`](../../.claude/commands/learn.md) for command details.

## Memory lifecycle

The memory system follows a four-stage lifecycle:

1. **Create** (`/learn`) — Save knowledge to the vault.
2. **Retrieve** (automatic) — Relevant memories are injected into agent contexts.
3. **Harvest** (`/todo`) — Completed-task archival collects agent-emitted memory candidates.
4. **Maintain** (`/distill`) — Vault health scoring, purging, merging, compressing, and garbage collection.

## Automatic memory retrieval

Memory retrieval runs automatically for `/research`, `/plan`, and `/implement` operations via the `memory-retrieve.sh` script. The script scores `.memory/memory-index.json` entries by keyword overlap with the task description, selects the top matches (TOKEN_BUDGET=2000, MAX_ENTRIES=5), and injects them as a `<memory-context>` block into the agent context. Tombstoned memories are excluded from retrieval.

Pass `--clean` to any of these commands to skip memory retrieval entirely. This is useful when you want a fresh-start investigation without prior context.

## Memory harvest via /todo

When `/todo` archives completed tasks, it collects memory candidates that agents emitted during research, planning, and implementation. Candidates are classified into three tiers:

- **Tier 1** (pre-selected) — High-confidence PATTERN and CONFIG candidates.
- **Tier 2** (presented) — Medium-confidence WORKFLOW and TECHNIQUE candidates.
- **Tier 3** (hidden) — Low-confidence or INSIGHT candidates.

Approved memories are created with proper frontmatter and the JSON index is regenerated. Deduplication prevents creation of memories with >90% keyword overlap with existing entries.

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

**Tombstone pattern**: `/distill --purge` does not permanently delete memories. Instead, it marks them as tombstoned (soft delete). Tombstoned memories are excluded from retrieval but remain on disk for a 7-day grace period. After 7 days, `/distill --gc` permanently removes them.

**Distill log**: Every `/distill` operation is recorded in `.memory/distill-log.json` with timestamps, operation type, and affected memory IDs. This provides an audit trail for vault maintenance.

**State tracking**: The `memory_health` field in `specs/state.json` tracks vault metrics: `last_distilled`, `distill_count`, `total_memories`, `never_retrieved`, `health_score`, and `status`. The health score is updated after each `/distill` operation.

See [`.claude/context/project/memory/distill-usage.md`](../../.claude/context/project/memory/distill-usage.md) for the full usage guide.

## Five context layers

Claude Code agents pull context from five distinct layers. Each has a different owner and purpose.

| Layer | Location | Owner | Purpose |
|-------|----------|-------|---------|
| Agent context | `.claude/context/` | Extension loader | Core agent patterns, formats, workflows |
| Extensions | `.claude/extensions.json` | Configuration file | Language-specific standards (flat file; no `.claude/extensions/` directory in this workspace) |
| Project context | `.context/` | User (via `index.json`) | Project conventions not covered by extensions |
| Project memory | `.memory/` | Agents (via `/learn`) | Learned facts, discoveries, decisions |
| Auto-memory | `~/.claude/projects/` | Claude Code harness | User preferences, behavioral corrections |

## Where should new content go?

```
Language-specific standard, pattern, or tool reference?
  yes -> extension context (via .claude/extensions.json; see Zed adaptations)

Agent system pattern (orchestration, format, workflow)?
  yes -> .claude/context/

Project convention (coding style, naming, domain knowledge)?
  yes -> .context/

Learned fact from development (discovery, decision, pattern)?
  yes -> .memory/  (use /learn)

User preference or behavioral correction?
  yes -> auto-memory (automatic, no action needed)
```

Full architectural details: [`.claude/context/architecture/context-layers.md`](../../.claude/context/architecture/context-layers.md).

## See also

- [`.memory/README.md`](../../.memory/README.md) — Vault structure, sharing protocol, MCP server details
- [`.claude/context/architecture/context-layers.md`](../../.claude/context/architecture/context-layers.md) — Full five-layer architecture
- [`.claude/commands/learn.md`](../../.claude/commands/learn.md) — `/learn` command reference
- [`.claude/commands/distill.md`](../../.claude/commands/distill.md) — `/distill` command reference
- [`.claude/context/project/memory/distill-usage.md`](../../.claude/context/project/memory/distill-usage.md) — Full distill usage guide
- [../workflows/memory-and-learning.md](../workflows/memory-and-learning.md) — Memory workflows and decision guide
- [architecture.md](architecture.md) — How these layers are loaded and delivered to agents
