# Context and Memory

Claude Code in this workspace pulls information from two distinct memory layers and five context layers. Keeping them straight matters: each has a different owner, lifetime, and sharing model.

## Summary

- **Project memory vault** (`.memory/`) — agent-managed Obsidian vault. Shared with OpenCode. Write via `/learn`.
- **Auto-memory** (`~/.claude/projects/...`) — harness-managed user preferences. Agents do not touch it.
- **Five context layers** — agent context, extensions, project context, project memory, auto-memory. Each has a different purpose.

## Two memory layers

### Project memory vault (.memory/)

**Location**: `/home/benjamin/.config/zed/.memory/`

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

**Read path** — grep-based discovery by default. Both AI systems fall back to grep when their respective MCP servers (Claude Code on WebSocket 22360, OpenCode on REST 27124) are unavailable. The `/research N --remember` flag searches the vault and injects matches into the research context.

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

## /research --remember

```
/research 5 --remember
```

Before running the normal research flow, the vault is searched for relevant prior memories and matches are injected into the research context. Useful when a task revisits territory you've already learned about.

## Five context layers

Claude Code agents pull context from five distinct layers. Each has a different owner and purpose.

| Layer | Location | Owner | Purpose |
|-------|----------|-------|---------|
| Agent context | `.claude/context/` | Extension loader | Core agent patterns, formats, workflows |
| Extensions | `.claude/extensions/*/context/` | Extension loader | Language-specific standards (not populated in this workspace) |
| Project context | `.context/` | User (via `index.json`) | Project conventions not covered by extensions |
| Project memory | `.memory/` | Agents (via `/learn`) | Learned facts, discoveries, decisions |
| Auto-memory | `~/.claude/projects/` | Claude Code harness | User preferences, behavioral corrections |

## Where should new content go?

```
Language-specific standard, pattern, or tool reference?
  yes -> extension context (.claude/extensions/*/context/)

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
- [agent-lifecycle.md](../workflows/agent-lifecycle.md) — Where `--remember` fits in the research flow
- [architecture.md](architecture.md) — How these layers are loaded and delivered to agents
