# Shared Memory Vault

This directory contains an Obsidian-compatible vault shared between Claude Code and OpenCode AI systems. Memories created by either system are accessible to both.

## Multi-System Usage

This vault is intentionally shared across AI systems:
- Both Claude Code and OpenCode can read all memories
- Both systems can create and update memories
- Memory IDs include timestamps for collision resistance
- Index files are regenerated from filesystem state

### MCP Server Considerations

Only one AI system should use MCP-based search at a time:
- Claude Code: Uses WebSocket port 22360
- OpenCode: Uses REST API port 27124

Both systems fall back to grep-based search when MCP is unavailable, which works safely in concurrent scenarios.

## Directory Structure

```
.memory/
+-- .obsidian/           # Obsidian configuration
+-- 00-Inbox/            # Quick capture for new memories
+-- 10-Memories/         # Stored memory entries
+-- 20-Indices/          # Navigation and organization
+-- 30-Templates/        # Memory entry templates
+-- memory-index.json    # Machine-queryable JSON index for two-phase retrieval
```

## Adding Memories

### Manual Capture

Use the `/learn` command:
- `/learn "text to remember"` - Add text content
- `/learn /path/to/file.md` - Add file content
- `/learn /path/to/dir/` - Scan directory for learnable content
- `/learn --task N` - Review task artifacts and create memories

The command will:
1. Parse the input
2. Generate a unique memory ID (collision-resistant format)
3. Present a preview with checkbox options
4. Allow you to add new, update existing, edit, or skip
5. Regenerate `memory-index.json` alongside `index.md`

### Automatic Capture via /todo

When `/todo` archives completed tasks, it collects memory candidates emitted by agents during `/research`, `/plan`, and `/implement` operations. Candidates are presented for batch approval using three-tier pre-classification:
- **Tier 1** (pre-selected): High-confidence PATTERN/CONFIG candidates
- **Tier 2** (presented): Medium-confidence WORKFLOW/TECHNIQUE candidates
- **Tier 3** (hidden): Low-confidence or INSIGHT candidates

Approved memories are created with proper frontmatter and the JSON index is regenerated. Deduplication prevents creation of memories with >90% keyword overlap with existing entries.

## Automatic Retrieval

Memory retrieval is automatic for all `/research`, `/plan`, and `/implement` operations using two-phase retrieval:

1. **Score phase**: Read `memory-index.json`, score entries by keyword overlap with task description, select top-5 above threshold
2. **Retrieve phase**: Read selected memory files (capped at 3000 tokens), inject as `<memory-context>` block

Retrieval statistics (`retrieval_count`, `last_retrieved`) are tracked in both the JSON index and memory file frontmatter for natural decay scoring.

Pass `--no-remember` to any lifecycle command to skip memory retrieval.

## Memory Index

The `memory-index.json` file is a machine-queryable index storing per-entry metadata for scoring. Per-entry fields: `id`, `path`, `title`, `summary`, `topic`, `category`, `keywords`, `token_count`, `created`, `modified`, `last_retrieved`, `retrieval_count`.

The index is regenerated during `/learn` operations. The validate-on-read pattern detects stale indices (missing files or unlisted MEM-*.md files) and triggers regeneration before scoring.

If the index becomes corrupted, delete `memory-index.json` and run `/learn` to regenerate from filesystem state.

## Git Workflow

**What to commit**:
- All `.md` files in the vault
- `memory-index.json`
- Templates and indices
- This README

**What to ignore** (in `.gitignore`):
- `.obsidian/` directory (user-specific Obsidian settings)
- `*.sqlite` files (search indexes)
- Plugin directories

## MCP Server Setup

For advanced features (search, retrieval), configure the MCP server:

1. Open Obsidian app
2. Open this `.memory/` as a vault
3. Install the appropriate MCP plugin for your system
4. Configure MCP server in your project settings

See the memory-setup.md in your system's context directory for detailed instructions.

## Naming Conventions

Memory files follow the pattern:
```
MEM-{semantic-slug}.md
```

Example: `MEM-epi-cohort-study-design.md`, `MEM-grant-nih-r01-tips.md`

The MEM- prefix is preserved for grep discoverability (`grep -r "MEM-" .memory/`).

## Template Format

Memory entries use YAML frontmatter:
```yaml
---
title: "Epidemiology Cohort Study Design"
created: 2026-03-06
tags: epidemiology, study-design, cohort
topic: "epidemiology/study-design"
source: "user input"
modified: 2026-03-06
retrieval_count: 0
last_retrieved: null
keywords: []
summary: ""
---
```

Filenames serve as unique identifiers. The `retrieval_count` and `last_retrieved` fields are updated automatically when a memory is injected into agent context. The `keywords` array and `summary` string are used by the JSON index for two-phase retrieval scoring.

## Best Practices

- Use descriptive first lines for better titles
- Review index.md regularly for navigation
- Commit memories to git for version history
- Use tags for better organization
- Link related memories using `[[filename]]` syntax
