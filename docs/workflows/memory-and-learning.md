# Memory and Learning

Save knowledge across sessions and draw on prior learnings during research. The memory vault (`.memory/`) gives Claude persistent recall of facts, decisions, and discoveries that would otherwise be lost between conversations.

> **Requires the `memory` extension.** Load it via `<leader>ac` before using these commands.

## Decision guide

| I want to... | Use |
|---|---|
| Save a piece of text as a memory | `/learn "text"` |
| Save the contents of a file | `/learn /path/to/file` |
| Scan a directory for learnable content | `/learn /path/to/dir/` |
| Harvest insights from a completed task | `/learn --task N` |
| Use prior knowledge during research | `/research N --remember` |

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

## Using memories in research

```
/research 42 --remember
```

The `--remember` flag searches the `.memory/` vault for knowledge relevant to the task and injects matching memories into the research context. This helps Claude build on prior work rather than rediscovering things from scratch. The flag is only available on `/research` and is ignored gracefully if the memory extension is not loaded.

## See also

- [agent-lifecycle.md](agent-lifecycle.md) — The core task lifecycle
- [`../agent-system/commands.md`](../agent-system/commands.md) — Full command reference with flags
- [`../agent-system/context-and-memory.md`](../agent-system/context-and-memory.md) — How context and memory work in the agent system
