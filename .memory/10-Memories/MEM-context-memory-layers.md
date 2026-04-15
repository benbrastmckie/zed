---
title: "Five context layers and two memory layers"
created: 2026-04-15
tags: [PATTERN, context, memory, architecture]
topic: "agent-system/context"
source: "docs/agent-system/context-and-memory.md"
modified: 2026-04-15
---

# Context and Memory Layers

## Five Context Layers

| Layer | Location | Owner | Purpose |
|-------|----------|-------|---------|
| Agent context | `.claude/context/` | Extension loader | Core agent patterns, formats, workflows |
| Extensions | `.claude/extensions.json` | Config file | Language-specific standards (flat file in this workspace) |
| Project context | `.context/` | User (index.json) | Project conventions |
| Project memory | `.memory/` | Agents (via /learn) | Learned facts, discoveries, decisions |
| Auto-memory | `~/.claude/projects/` | Claude Code harness | User preferences, behavioral corrections |

## Two Memory Layers

### Project Memory Vault (.memory/)
- Obsidian-compatible vault shared with OpenCode
- Structure: 00-Inbox/, 10-Memories/ (MEM-{slug}.md), 20-Indices/, 30-Templates/
- Write path: `/learn` command (text, file, directory, --task modes)
- Read path: grep-based discovery; `/research --remember` flag
- Content: learned facts, discoveries, decisions, reusable patterns

### Auto-Memory (~/.claude/projects/)
- Harness-managed, NOT agent-accessible
- Stores user preferences and behavioral corrections automatically
- Never write to it directly; use `/learn` for project-level knowledge

## Where New Content Goes
- Language-specific standard -> extension context
- Agent system pattern -> .claude/context/
- Project convention -> .context/
- Learned fact from development -> .memory/ (via /learn)
- User preference -> auto-memory (automatic)

## Context Discovery
```bash
jq -r --arg agent "..." --arg task_type "..." '
  .entries[] | select(
    (.load_when.always == true) or
    any(.load_when.agents[]?; . == $agent) or
    any(.load_when.task_types[]?; . == $task_type)
  ) | .path' .claude/context/index.json
```

## Connections
<!-- Add links to related memories using [[filename]] syntax -->
