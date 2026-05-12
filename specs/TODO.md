---
next_project_number: 85
---

# Task List

## Tasks

### 84. Create web development guide with example artifacts
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: general
- **Research**: [084_create_web_dev_guide/reports/01_team-research.md]
- **Plan**: [084_create_web_dev_guide/plans/01_web-dev-guide-plan.md]
- **Summary**: [084_create_web_dev_guide/summaries/01_web-dev-guide-summary.md]

**Description**: Create a web development guide in docs/. Examine /home/benjamin/Projects/Logos/Website/src/data/advantages.ts to extract a basic website form. Copy essential artifacts to a web/ directory. Write a comprehensive guide explaining how to use Claude Code or OpenCode with the web development extension to design, research, plan, and implement a website using the built-in task system. Add a link to the guide in /home/benjamin/.config/zed/README.md

### 83. Revise documentation to reflect new extensions
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: markdown
- **Research**: [083_revise_docs_for_new_extensions/reports/01_team-research.md]
- **Plan**: [083_revise_docs_for_new_extensions/plans/01_docs-revision-plan.md]
- **Summary**: [083_revise_docs_for_new_extensions/summaries/01_docs-revision-summary.md]

**Description**: Review new extensions loaded via `<leader>al` and revise all documentation (docs/ and README.md) for accuracy, clarity, and completeness. Ensure clear, accessible, well-balanced and representative documentation with basic usage guides and overview of functionality without repetition or verbosity.

### 82. Improve documentation and installation script for dual agent systems
- **Effort**: large
- **Status**: [COMPLETED]
- **Task Type**: general
- **Research**: [082_improve_docs_and_install_script/reports/01_team-research.md]
- **Plan**: [082_improve_docs_and_install_script/plans/01_docs-install-plan.md]
- **Summary**: [082_improve_docs_and_install_script/summaries/01_docs-install-summary.md]

**Description**: Research all the extensions that have been included in .claude/ and .opencode/ in order to improve the documentation for this repo to more accurately present both agent systems and their common contents (what each extension provides). The aim of this task is to improve the documentation in /home/benjamin/.config/zed/docs/ and to update /home/benjamin/.config/zed/README.md with appropriate descriptions and links. Also improve the installation script to give users the option of installing Claude Code and its dependencies, or OpenCode and its dependencies, or both.

### 81. Set up .opencode/ directory with xlsx skill mirroring
- **Effort**: small
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Depends On**: 79
- **Research**: [081_setup_opencode_xlsx_system/reports/01_opencode-xlsx-setup.md]
- **Plan**: [081_setup_opencode_xlsx_system/plans/01_opencode-xlsx-plan.md]
- **Summary**: [081_setup_opencode_xlsx_system/summaries/01_opencode-xlsx-summary.md]

**Description**: Create .opencode/ directory structure with xlsx skill support. Mirror or symlink the skill-xlsx from .claude/skills/ into .opencode/skills/skill-xlsx/. If .opencode/ supports a different agent model (e.g., embedded agent logic vs separate agent files), adapt accordingly. Set up .opencode/skills/skill-xlsx/SKILL.md and any required agent configuration. Ensure .opencode/ discovery picks up the xlsx skill for tasks involving spreadsheet files.

### 80. Integrate xlsx skill into filetypes extension routing
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Depends On**: 79
- **Research**: [080_integrate_xlsx_filetypes_routing/reports/01_xlsx-routing-audit.md]
- **Plan**: [080_integrate_xlsx_filetypes_routing/plans/01_xlsx-routing-plan.md]
- **Summary**: [080_integrate_xlsx_filetypes_routing/summaries/01_xlsx-routing-summary.md]

**Description**: Update filetypes extension configuration to route .xlsx/.xls/.xlsm/.csv/.tsv files to the new skill-xlsx/xlsx-agent. Changes needed: (1) `.claude/extensions.json` -- add skill-xlsx as installed_dirs entry and add context paths; (2) `.claude/skills/skill-filetypes/SKILL.md` -- add xlsx as a routed format with `--xlsx` flag or delegate-to-skill-xlsx logic; (3) `.claude/commands/convert.md` -- add xlsx operation mode to supported conversions table; (4) `.claude/CLAUDE.md` -- add skill-xlsx to the filetypes extension section; (5) Create `/xlsx` command that delegates to skill-xlsx for full create/edit/analyze operations. Distinguish between existing `/convert .xlsx` (extract to markdown) and new `/xlsx file.xlsx "add column with..."` (full creation/editing/analysis/formulas/charting).

### 79. Create skill-xlsx and xlsx-agent for filetypes extension
- **Effort**: medium
- **Status**: [COMPLETED]
- **Task Type**: meta
- **Plan**: [079_create_skill_xlsx_and_agent/plans/01_xlsx-skill-agent.md]
- **Summary**: [079_create_skill_xlsx_and_agent/summaries/01_xlsx-skill-agent-summary.md]

**Description**: Create `skill-xlsx` and `xlsx-agent` following the thin-wrapper delegation pattern used by existing filetypes skills. (1) Create `.claude/skills/skill-xlsx/SKILL.md` -- adapt Anthropic xlsx skill content with thin-wrapper frontmatter (allowed-tools: Task), trigger conditions (direct: `/xlsx` command, implicit: plan steps mentioning "create spreadsheet", "edit xlsx", "add formulas", and .xlsx/.xlsm/.csv/.tsv extensions), context pointers to subagent-return.md, and Task-tool delegation to xlsx-agent. (2) Create `.claude/agents/xlsx-agent.md` -- the implementation agent with allowed-tools (Read, Write, Edit, Bash, Glob, Grep), context references to tool-detection.md and depedency-guide.md, and the full Anthropic xlsx creation/editing/analysis workflow (pandas for analysis, openpyxl for formulas/formatting, recalc.py for formula verification, color coding standards, formula error prevention, etc.).
- **Effort**: medium
- **Status**: [RESEARCHED]
- **Task Type**: meta
- **Research**:
  - [specs/078_generalize_extension_docs_remove_nvim/reports/01_nvim-loader-doc-audit.md]
  - [079_create_skill_xlsx_and_agent/reports/01_xlsx-skill-agent.md]

**Description**: Three documentation files contain references to the nvim Lua extension loader implementation that should be generalized to be implementation-agnostic. (1) `.claude/context/guides/loader-reference.md` is entirely a Lua API reference with function signatures, `vim.fn` calls, and Telescope picker details -- rewrite as a conceptual loader operations reference or delete. (2) `.claude/docs/architecture/extension-system.md` heavily references Lua source files (`init.lua`, `loader.lua`, `merge.lua`, etc.), `vim.fn.filereadable()`, and "Telescope picker" -- generalize to describe what each component does without naming Lua files or vim APIs. (3) `.claude/context/guides/extension-development.md` has a few Lua-specific leaks (`copy_context_dirs()` in `loader.lua`, `vim.fn.isdirectory()`) -- replace with conceptual descriptions.

### 76. Troubleshoot Zed keybindings on macOS and update cheat sheet
- **Effort**: medium
- **Status**: [COMPLETED]
- **Completed**: 2026-04-19
- **Task Type**: general
- **Summary**: Fixed two keybinding bugs (ctrl-shift-a in Editor, secondary-shift-c in Workspace), removed redundant indent/outdent blocks from keymap.json, and rewrote Typst cheat sheet and markdown guide for macOS-only notation (Cmd/Opt instead of Ctrl/Cmd/Alt).
- **Research**:
  - [specs/076_troubleshoot_zed_keybindings_macos/reports/01_team-research.md]
  - [specs/076_troubleshoot_zed_keybindings_macos/reports/02_macos-keybinding-spec.md]

**Description**: Many keybindings in `docs/general/keybindings-cheat-sheet.typ` do not work as expected on macOS. For instance, `ctrl+shift+a` only works when the PDF is open, not when the `.typ` file is open. `cmd+shift+c` is also inconsistent. Troubleshoot the issues, prefer `cmd` over `ctrl` where there are no conflicts with macOS system keybindings (open to changing macOS keybindings if it makes sense), fix the Zed configuration, and update `keybindings-cheat-sheet.typ` accordingly.

### 73. Port high-value Slidev resources from Vision repository into talk library
- **Effort**: medium
- **Status**: [RESEARCHED]
- **Task Type**: meta
- **Research**: [01_vision-slidev-port.md](specs/073_port_vision_slidev_resources/reports/01_vision-slidev-port.md)

**Description**: Port high and medium value Slidev resources from /home/benjamin/Projects/Logos/Vision/.context/deck/ into the talk library at .claude/context/project/present/talk/. High value: (1) Animation pattern library — 6 reusable v-click/v-motion patterns (fade-in, slide-in-below, metric-cascade, rough-marks, scale-in-pop, staggered-list), (2) Composable style architecture — separate color, typography, and texture CSS files instead of monolithic themes, (3) Texture overlays (grid-overlay.css, noise-grain.css). Medium value: (4) ComparisonCol.vue — side-by-side comparison columns, (5) TimelineItem.vue — milestone timeline with status indicators, (6) MetricCard.vue — animated KPI/metric display. Adapt business-oriented components for academic/research use where needed. Update talk library index.json to catalog new resources.

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
- **Research**:
  - [specs/065_strip_nvim_references_post_sync/reports/01_nvim-reference-audit.md]
  - [specs/065_strip_nvim_references_post_sync/reports/02_relevance-reaudit.md]
  - [specs/065_strip_nvim_references_post_sync/reports/03_post-reload-audit.md]
  - [specs/065_strip_nvim_references_post_sync/reports/04_post-reload-diff-review.md]
  - [specs/065_strip_nvim_references_post_sync/reports/05_post-reload-diff-review.md]

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
3. **78** -> plan (independent)

## Recommended Order


## Recommended Order

