# skill-memory

Memory vault management skill for the /learn command.

## Purpose

Handles memory creation, similarity search, classification, and index maintenance for the Obsidian-compatible memory vault.

## Modes

### Standard Mode

Add text or file content as memory:
- Parse input (text vs file)
- Generate unique memory ID
- Search for similar existing memories
- Present preview with options
- Create memory file with YAML frontmatter
- Update index

### Task Mode

Review task artifacts and create classified memories:
- Locate task directory
- Scan artifact files
- Present interactive selection
- Classify each artifact (TECHNIQUE, PATTERN, CONFIG, WORKFLOW, INSIGHT, SKIP)
- Create categorized memories
- Update index with category grouping

### Distill Mode

Maintain memory vault health through scoring, reporting, and four distillation operations. Invoked via the `/distill` command.

**Operations**:

| Flag | Operation | Interactive? | Description |
|------|-----------|-------------|-------------|
| (bare) | Health Report | No | Read-only vault metrics and health score |
| `--purge` | Purge | Yes | Tombstone stale/zero-retrieval memories |
| `--merge` | Combine | Yes | Merge overlapping memories (keyword superset guarantee) |
| `--compress` | Compress | Yes | Reduce verbose memories to key points |
| `--auto` | Refine | No | Automatic metadata fixes (keyword dedup, summary, topic normalization) |
| `--gc` | Garbage Collect | Yes | Hard-delete tombstoned memories past 7-day grace period |

**Scoring Engine**:

Each memory receives a composite distillation score (0-1) based on:
- **Staleness** (30%): Days since last retrieval / 90, with FSRS-inspired adjustment for old-but-retrieved memories
- **Zero-retrieval** (25%): Penalty for memories never retrieved after 30 days
- **Size** (20%): Linear penalty above 600 tokens
- **Duplicate** (25%): Highest keyword overlap with any other memory

**Tombstone Pattern**:

Destructive operations use soft-delete (tombstone) rather than hard-delete:
- Adds `status: tombstoned` and `tombstoned_at` to frontmatter
- Tombstoned memories excluded from retrieval but remain on disk
- `--gc` performs hard deletion after 7-day grace period

**Distill Log** (`.memory/distill-log.json`):

All operations are logged with before/after metrics for auditability and rollback support.

**State Tracking** (`memory_health` in state.json):

Tracks total memories, never-retrieved count, health score (0-100), and distill history. Updated after every `/distill` invocation.

## Files

- `SKILL.md` - Skill definition and execution flow

## Navigation

- [Parent Directory](../README.md)
