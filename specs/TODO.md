---
next_project_number: 75
---

# Task List

## Tasks

### 74. Update documentation for extension dependency system and slidev resource-only extension
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Research**: [01_ext-deps-doc-audit.md](specs/074_update_docs_extension_deps_slidev/reports/01_ext-deps-doc-audit.md)
- **Plan**: [01_ext-deps-doc-plan.md](specs/074_update_docs_extension_deps_slidev/plans/01_ext-deps-doc-plan.md)
- **Summary**: [01_ext-deps-doc-summary.md](specs/074_update_docs_extension_deps_slidev/summaries/01_ext-deps-doc-summary.md)

**Description**: Update documentation throughout .claude/ to reflect the new extension dependency system and slidev resource-only extension. Changes include: (1) CLAUDE.md addition of extension dependency paragraph, (2) extension-development.md new Dependencies section covering declaring dependencies, auto-loading behavior, circular detection, unload safety, resource-only extensions, and picker preview, (3) project-overview.md updated extension description mentioning dependencies and resource-only extensions, (4) extension-system.md updated load/unload flows with dependency resolution steps, (5) adding-domains.md updated extension description mentioning optional dependencies, (6) creating-extensions.md new Resource-Only Extensions section and updated dependency field description, (7) index.json key reordering and line_count updates, (8) extensions.json restructured with new slidev extension entry, (9) talk/index.json updated animations/styles paths to reference shared slidev extension context, (10) new .claude/context/project/slidev/ directory with animation and style subdirectories

### 73. Port high-value Slidev resources from Vision repository into talk library
- **Effort**: medium
- **Status**: [RESEARCHED]
- **Task Type**: meta
- **Research**: [01_vision-slidev-port.md](specs/073_port_vision_slidev_resources/reports/01_vision-slidev-port.md)

**Description**: Port high and medium value Slidev resources from /home/benjamin/Projects/Logos/Vision/.context/deck/ into the talk library at .claude/context/project/present/talk/. High value: (1) Animation pattern library — 6 reusable v-click/v-motion patterns (fade-in, slide-in-below, metric-cascade, rough-marks, scale-in-pop, staggered-list), (2) Composable style architecture — separate color, typography, and texture CSS files instead of monolithic themes, (3) Texture overlays (grid-overlay.css, noise-grain.css). Medium value: (4) ComparisonCol.vue — side-by-side comparison columns, (5) TimelineItem.vue — milestone timeline with status indicators, (6) MetricCard.vue — animated KPI/metric display. Adapt business-oriented components for academic/research use where needed. Update talk library index.json to catalog new resources.

### 72. Update docs/ to reflect agent system changes (model flags, memory retrieval, distill refine)
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: markdown
- **Research**: [01_docs-update-audit.md](specs/072_update_docs_for_agent_system_changes/reports/01_docs-update-audit.md)
- **Plan**: [072_update_docs_for_agent_system_changes/plans/01_docs-update-plan.md]
- **Summary**: [072_update_docs_for_agent_system_changes/summaries/01_docs-update-summary.md]

**Description**: Update user-facing docs/ to reflect agent system changes: add --fast/--hard/--haiku/--sonnet/--opus flags to commands.md and agent-lifecycle.md, replace two-phase retrieval description with memory-retrieve.sh script in context-and-memory.md and memory-and-learning.md, add --refine sub-mode to /distill tables, remove stale --remember flag from agent-lifecycle.md, and update architecture.md model description from split opus/sonnet to all-opus-default

### 71. Fix documentation regressions from agent system update
- **Effort**: small
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Research**: [01_doc-regression-review.md](specs/071_fix_doc_regressions_agent_update/reports/01_doc-regression-review.md)

**Description**: Fix documentation regressions from agent system update: restore return-metadata examples, plan-metadata JSON shape, and retrieval tracking field consistency

### 70. Update documentation to reflect current memory system
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: markdown
- **Research**: [01_docs-memory-audit.md](specs/070_update_docs_memory_system/reports/01_docs-memory-audit.md)
- **Plan**: [01_docs-memory-plan.md](specs/070_update_docs_memory_system/plans/01_docs-memory-plan.md)
- **Summary**: [01_docs-memory-summary.md](specs/070_update_docs_memory_system/summaries/01_docs-memory-summary.md)

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
2. **73** -> research (independent)
3. **74** -> research (independent)
