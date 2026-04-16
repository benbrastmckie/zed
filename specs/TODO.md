---
next_project_number: 71
---

# Task List

## Tasks

### 70. Update documentation to reflect current memory system
- **Effort**: medium
- **Status**: [RESEARCHED]
- **Task Type**: markdown
- **Research**: [01_docs-memory-audit.md](specs/070_update_docs_memory_system/reports/01_docs-memory-audit.md)

**Description**: Update docs/agent-system/context-and-memory.md, docs/agent-system/commands.md, docs/workflows/memory-and-learning.md, docs/README.md, and README.md to reflect the current memory system including /distill command, memory lifecycle (/learn -> retrieval -> /todo harvest -> /distill), tombstone pattern, memory_health state tracking, vault maintenance operations (purge/combine/compress/refine/auto/gc), and distill-log auditability.

### 69. Create /distill command for memory system refinement
- **Effort**: large
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Research**: [01_team-research.md](specs/069_create_distill_command_memory_refinement/reports/01_team-research.md)
- **Plan**: [01_distill-command-plan.md](specs/069_create_distill_command_memory_refinement/plans/01_distill-command-plan.md)
- **Summary**: [01_distill-command-summary.md](specs/069_create_distill_command_memory_refinement/summaries/01_distill-command-summary.md)

**Description**: Research best practices online to create a `/distill` command that complements `/learn` by processing the `.memory/` system to compress, combine, purge, and refine stored memories. Investigate how Claude Code's own dreaming/consolidation functionality works for inspiration. Additionally, update `/todo` to suggest running `/distill` and `/review` commands when it finishes as helpful reminders.

### 66. Update docs/ and README.md to reflect .claude/ refactoring
- **Effort**: medium
- **Status**: [RESEARCHED]
- **Task Type**: meta
- **Research**: [01_refactoring-diff-audit.md](specs/066_update_docs_readme_post_refactor/reports/01_refactoring-diff-audit.md)

**Description**: Update all relevant documentation in `docs/` and `README.md` to reflect the .claude/ directory refactoring: remove neovim-specific references, replace `<leader>ac` with "extension picker", genericize examples (nvim/lua/ paths to src/ paths, neovim task types to general), and fix any stale cross-references from deleted files (neovim-integration.md, tts-stt-integration.md).

### 65. Strip nvim/neovim references from 53 .claude/ files after sync reload
- **Effort**: large
- **Status**: [RESEARCHED]
- **Task Type**: meta
- **Research**: [01_nvim-reference-audit.md](specs/065_strip_nvim_references_post_sync/reports/01_nvim-reference-audit.md)

**Description**: 368 nvim/neovim occurrences across 53 `.claude/` files, plus 21 neotex and 19 `<leader>ac` references. The sync reload overwrote 8 of 9 `.syncprotect`-listed files (only `project-overview.md` survived via `CONTEXT_EXCLUDE_PATTERNS`, not `.syncprotect`). Root `CLAUDE.md` created by task 63 no longer exists. Full per-file audit in research report.

**Prerequisite -- Fix sync protection**: `.syncprotect` is not honored by the sync mechanism. Options: fix the loader, add a post-sync fixup script, or use git stash/restore around syncs. Without this, cleanup will be undone on next reload.

**Category A+ -- Re-contaminated (Critical, 8 files, 36 refs):** Syncprotected files the reload overwrote: `CLAUDE.md`, `README.md`, `commands/fix-it.md`, `commands/learn.md`, `commands/review.md`, `commands/task.md`, `skills/skill-orchestrator/SKILL.md`, `rules/plan-format-enforcement.md`.

**Category A -- Broken Config (Critical, 6 files, 30 refs):** Paths to nonexistent nvim directories. `extensions.json` (7 source_dir), `settings.local.json` (12 nvim path permissions), `settings.json` (SessionStart hook), `systemd/claude-refresh.service`, `commands/todo.md` (health metrics), `scripts/validate-wiring.sh`.

**Category B -- Incorrect Routing (High, 6 files, 12 refs):** Routes to nonexistent neovim agents/skills. `agents/meta-builder-agent.md`, `agents/code-reviewer-agent.md`, `agents/spawn-agent.md`, `skills/skill-fix-it/SKILL.md`, `context/architecture/system-overview.md`, `context/orchestration/orchestration-core.md`.

**Category C -- Neovim-Centric Guides (Medium, 6 files, ~106 refs):** Delete `neovim-integration.md` and `tts-stt-integration.md`. Rewrite `user-installation.md`, `copy-claude-directory.md`, `user-guide.md`, `adding-domains.md`.

**Category D -- Examples Using Neovim (Medium, 14 files, ~142 refs):** Replace `nvim/lua/` paths and neovim task types with Zed-appropriate examples across docs, standards, and context guides.

**Category E -- Template/Generic (Low, 14 files, ~42 refs):** Neovim in editor lists or generic templates. Replace where easy, defer rest.

**Also needed:** Recreate root `~/.config/zed/CLAUDE.md` (gone after reload). Replace 19 `<leader>ac` references with generic "extension loader" language across 10 files.

## Recommended Order

1. **65** [RESEARCHED] -> plan (independent)
