# Memory Vault Index

## Quick Navigation
- [Inbox](00-Inbox/) - Quick capture for new memories
- [Memories](10-Memories/) - All stored memory entries
- [Templates](30-Templates/) - Memory entry templates

## JSON Index

The machine-queryable index at `.memory/memory-index.json` enables two-phase retrieval:
1. **Score phase**: Read JSON index, score entries by keyword overlap, select top-K candidates
2. **Retrieve phase**: Read only selected memory files into context

The JSON index is regenerated alongside this file during `/learn` operations and validated before each retrieval via the validate-on-read pattern.

### Retrieval Tracking Fields

Each memory entry (both in JSON index and file frontmatter) tracks:
- `retrieval_count` - Number of times this memory has been injected into agent context
- `last_retrieved` - ISO date of most recent retrieval (null if never retrieved)
- `keywords` - Array of 5-8 significant terms for scoring
- `summary` - One-line description for quick scanning

## Recent Memories
- [MEM-zed-editor-settings](../10-Memories/MEM-zed-editor-settings.md) - Zed editor settings configuration (2026-04-15)
- [MEM-zed-keybindings-scheme](../10-Memories/MEM-zed-keybindings-scheme.md) - Zed keybindings Scheme A (2026-04-15)
- [MEM-agent-system-architecture](../10-Memories/MEM-agent-system-architecture.md) - Claude Code three-layer architecture (2026-04-15)
- [MEM-claude-code-command-catalog](../10-Memories/MEM-claude-code-command-catalog.md) - 25-command catalog (2026-04-15)
- [MEM-toolchain-dependencies](../10-Memories/MEM-toolchain-dependencies.md) - Toolchain dependencies and install groups (2026-04-15)
- [MEM-zed-agent-panel-modes](../10-Memories/MEM-zed-agent-panel-modes.md) - Terminal CLI vs agent panel (2026-04-15)
- [MEM-context-memory-layers](../10-Memories/MEM-context-memory-layers.md) - Five context + two memory layers (2026-04-15)
- [MEM-install-wizard-scripts](../10-Memories/MEM-install-wizard-scripts.md) - Install wizard and helper scripts (2026-04-15)

## By Category

### [PATTERN]
- [MEM-agent-system-architecture](../10-Memories/MEM-agent-system-architecture.md) - Three-layer pipeline, checkpoint execution, task lifecycle
- [MEM-context-memory-layers](../10-Memories/MEM-context-memory-layers.md) - Five context layers, two memory layers, content routing

### [TECHNIQUE]
- [MEM-zed-agent-panel-modes](../10-Memories/MEM-zed-agent-panel-modes.md) - Terminal CLI vs agent panel modes, ACP bridge

### [CONFIG]
- [MEM-zed-editor-settings](../10-Memories/MEM-zed-editor-settings.md) - Theme, fonts, LSP, extensions, agent_servers
- [MEM-zed-keybindings-scheme](../10-Memories/MEM-zed-keybindings-scheme.md) - Scheme A custom bindings, modifier categories
- [MEM-toolchain-dependencies](../10-Memories/MEM-toolchain-dependencies.md) - Python, R, LaTeX, Typst, MCP servers

### [WORKFLOW]
- [MEM-claude-code-command-catalog](../10-Memories/MEM-claude-code-command-catalog.md) - 25 slash commands: lifecycle, docs, grants, epi, memory
- [MEM-install-wizard-scripts](../10-Memories/MEM-install-wizard-scripts.md) - Install wizard, Zed tasks, helper scripts

### [INSIGHT]
<!-- Insight memories -->

## By Topic

Topics use slash-separated hierarchical paths (e.g., `zed/config`, `agent-system/architecture`).

### zed/
- [MEM-zed-editor-settings](../10-Memories/MEM-zed-editor-settings.md) - zed/config
- [MEM-zed-keybindings-scheme](../10-Memories/MEM-zed-keybindings-scheme.md) - zed/keybindings
- [MEM-toolchain-dependencies](../10-Memories/MEM-toolchain-dependencies.md) - zed/toolchain
- [MEM-zed-agent-panel-modes](../10-Memories/MEM-zed-agent-panel-modes.md) - zed/ai-modes
- [MEM-install-wizard-scripts](../10-Memories/MEM-install-wizard-scripts.md) - zed/install

### agent-system/
- [MEM-agent-system-architecture](../10-Memories/MEM-agent-system-architecture.md) - agent-system/architecture
- [MEM-claude-code-command-catalog](../10-Memories/MEM-claude-code-command-catalog.md) - agent-system/commands
- [MEM-context-memory-layers](../10-Memories/MEM-context-memory-layers.md) - agent-system/context

## Statistics
- Total memories: 8
- Topics: 2 (zed/, agent-system/)
- Last updated: 2026-04-15
