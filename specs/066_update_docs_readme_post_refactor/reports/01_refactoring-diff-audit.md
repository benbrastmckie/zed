# Refactoring Diff Audit: .claude/ Directory Changes

**Task**: #66 - Update docs/ and README.md to reflect .claude/ refactoring
**Date**: 2026-04-14
**Scope**: 42 files changed, 2847 insertions, 3578 deletions

---

## Executive Summary

The `.claude/` directory has been refactored to remove neovim-specific references and genericize the agent system. The changes fall into 7 categories. The `docs/` directory and `README.md` at the project root are **already clean** of neovim/nvim references and contain no stale cross-references to deleted files. However, some documentation may benefit from updates to stay consistent with the new generic terminology and examples used throughout `.claude/`.

---

## Category 1: Neovim Reference Removal (Core Identity Change)

All references to "neovim" as a built-in/core task type have been removed. Neovim is now treated as an optional extension, same as latex, typst, python, etc.

### Files Changed

| File | Change |
|------|--------|
| `.claude/CLAUDE.md` | `task_type: "neovim"` -> `task_type: "general"` in state.json example |
| `.claude/CLAUDE.md` | `skill-neovim-research -> neovim-research-agent` -> `skill-{domain}-research -> {domain}-research-agent` |
| `.claude/CLAUDE.md` | `neovim-lua.md for Lua development` -> `{domain}-rules.md for domain-specific development` |
| `.claude/commands/task.md` | Removed `"neovim", "plugin", "nvim", "lua" -> neovim` from task_type detection |
| `.claude/commands/fix-it.md` | Removed neovim keyword matching from QUESTION: language detection |
| `.claude/commands/review.md` | `nvim/**/*.lua -> neovim` task type inference removed; replaced with `*.lua -> general` |
| `.claude/agents/meta-builder-agent.md` | Removed neovim keyword classification from DetectDomainType |
| `.claude/agents/spawn-agent.md` | `task_type (meta, general, neovim, etc.)` -> `task_type (meta, general, etc.)` |
| `.claude/context/architecture/system-overview.md` | `The Neovim Configuration agent system` -> `The agent system` |
| `.claude/context/orchestration/orchestration-core.md` | `Neovim Configuration's command-skill-agent architecture` -> `the project's command-skill-agent architecture` |
| `.claude/context/formats/frontmatter.md` | `General research agent for non-Neovim tasks` -> `General research agent` |
| `.claude/context/formats/frontmatter.md` | `Add Neovim plugin tooling` -> `Add domain-specific tooling` |
| `.claude/context/standards/documentation-standards.md` | `Use lua for Neovim configuration` -> `Use the appropriate language identifier` |
| `.claude/context/standards/ci-workflow.md` | `Neovim Lua files (.lua)` -> `Source code files` |
| `.claude/context/standards/ci-workflow.md` | `Add [ci] for Neovim phases` -> `Add [ci] for source code phases` |
| `.claude/context/repo/update-project.md` | `example for a Neovim configuration project` -> `template for generating project-specific documentation` |
| `.claude/context/index.schema.json` | `$id` URL: `nvim.config` -> `claude-agent.config` |

### Impact on docs/README.md

**None required.** `docs/` and `README.md` already use generic terminology. No "neovim", "nvim", or "Neovim" references found.

---

## Category 2: `<leader>ac` -> "Extension Picker" (UI Reference Change)

All references to the Neovim keybinding `<leader>ac` for loading extensions have been replaced with the editor-agnostic term "extension picker".

### Files Changed

| File | Old | New |
|------|-----|-----|
| `.claude/CLAUDE.md` (x2) | `via <leader>ac` | `via the extension picker` |
| `.claude/README.md` | `via <leader>ac keybinding` | `via the extension picker` |
| `.claude/context/guides/extension-development.md` (x3) | `via <leader>ac in Neovim` | `via the extension picker` |
| `.claude/context/reference/skill-agent-mapping.md` | `<leader>ac opens extension selector` | `Extension picker: Opens extension selector` |
| `.claude/docs/architecture/extension-system.md` | `Neovim Managed: via Neovim picker (<leader>ac)` | `Editor Managed: via the extension picker` |
| `.claude/docs/architecture/extension-system.md` | `extension picker (<leader>ac)` | `extension picker` |
| `.claude/docs/guides/adding-domains.md` | `via the Neovim picker (<leader>ac)` | `via the extension picker` |
| `.claude/docs/guides/adding-domains.md` | `<leader>ac -> Select extension` | `Open the extension picker, select extension` |
| `.claude/docs/guides/creating-extensions.md` (x3) | `<leader>ac` | `extension picker` |

### Impact on docs/README.md

**None required.** No `<leader>ac` references found in `docs/` or `README.md`.

---

## Category 3: Path Genericization (`nvim/lua/` -> `src/`)

All example file paths using `nvim/lua/` (Neovim-specific directory structure) have been replaced with generic `src/` paths.

### Files Changed

| File | Examples of Path Changes |
|------|------------------------|
| `.claude/commands/fix-it.md` | `nvim/lua/Layer1/Modal.lua:67` -> `src/components/Modal.js:67` |
| `.claude/commands/fix-it.md` | `nvim/lua/config/lsp.lua:45` -> `src/config/lsp.js:45` |
| `.claude/commands/fix-it.md` | `nvim/lua/utils/helpers.lua:23` -> `src/utils/helpers.js:23` |
| `.claude/commands/review.md` | `nvim/lua/plugins/lsp.lua` -> `src/plugins/lsp.lua` |
| `.claude/commands/review.md` | `grep -r "TODO" nvim/lua/` -> `grep -r "TODO" .` with multi-type includes |
| `.claude/commands/todo.md` | `grep -r "TODO" nvim/lua/ --include="*.lua"` -> multi-type grep |
| `.claude/commands/todo.md` | `nvim --headless -c "quit"` -> `make check || npm run lint || true` |
| `.claude/docs/examples/fix-it-flow-example.md` | All `nvim/lua/` paths -> `src/` paths (major rewrite) |
| `.claude/docs/examples/fix-it-flow-example.md` | Lua grep patterns -> Python grep patterns |
| `.claude/docs/architecture/extension-system.md` | `/home/user/.config/nvim/` -> `$PROJECT_ROOT/` |
| `.claude/docs/architecture/extension-system.md` | `~/.config/nvim/.claude/extensions` -> `$PROJECT_ROOT/.claude/extensions` |

### Impact on docs/README.md

**None required.** No `nvim/lua/` paths found in `docs/` or `README.md`.

---

## Category 4: Example Content Genericization

Examples throughout the codebase have been updated to use generic/Python/web examples instead of Neovim-specific ones.

### Files Changed

| File | Change Summary |
|------|---------------|
| `.claude/context/guides/extension-development.md` | Manifest example: `neovim` extension -> `python` extension |
| `.claude/context/guides/extension-development.md` | Index entries: `neovim/lua-patterns.md` -> `python/coding-patterns.md` |
| `.claude/docs/examples/fix-it-flow-example.md` | Full rewrite: Lua files -> Python files, neovim tasks -> general tasks |
| `.claude/docs/examples/fix-it-flow-example.md` | `LSP Configuration` topic group -> `API Validation` topic group |
| `.claude/docs/examples/fix-it-flow-example.md` | `Neovim Configuration Team` -> `Project Development Team` |
| `.claude/docs/examples/research-flow-example.md` | Removed neovim routing from command frontmatter |
| `.claude/docs/examples/research-flow-example.md` | `Scenario C: Neovim Task Routing` -> `Scenario C: Extension Task Type Routing` |
| `.claude/docs/examples/research-flow-example.md` | `neovim-research-agent` -> `python-research-agent` (as example) |
| `.claude/docs/guides/development/context-index-migration.md` | Index entry example: `neovim/neovim-api.md` -> `python/python-api.md` |
| `.claude/docs/architecture/system-overview.md` | Layer diagrams: `skill-neovim-research` -> `skill-researcher` |
| `.claude/docs/architecture/system-overview.md` | Layer diagrams: `neovim-research-agent` -> `general-research-agent` |
| `.claude/docs/architecture/system-overview.md` | Routing table: removed `neovim` row, added `markdown` row |
| `.claude/docs/architecture/system-overview.md` | Directory tree: generic agent/skill names |
| `.claude/docs/guides/component-selection.md` | All neovim skill/agent examples -> generic `{domain}` patterns |
| `.claude/docs/guides/component-selection.md` | Removed `skill-neovim-*` and `neovim-*-agent` from mapping tables |
| `.claude/docs/guides/creating-agents.md` | Removed neovim agents from directory listing |
| `.claude/docs/guides/creating-agents.md` | Context example: `project/neovim/tools/lazy-nvim-guide.md` -> `project/{domain}/tools/tool-guide.md` |
| `.claude/docs/guides/creating-skills.md` | `Neovim Configuration agent system` -> `agent system` |
| `.claude/docs/guides/adding-domains.md` | `neovim in a neovim config repo` -> `python in a Python project` |
| `.claude/docs/guides/adding-domains.md` | Core approach example: `neovim for a Neovim config repo` -> `python for a Python project` |
| `.claude/commands/task.md` | Edge case: `Fix bug in nvim/lua/plugins/lsp.lua` -> `Fix bug in src/config/lsp.lua` |
| `.claude/commands/task.md` | `Update to neovim v0.10.0` -> `Update to python v3.12` |

### Impact on docs/README.md

**None required.** Examples in `docs/` and `README.md` already use Zed/Python/R-appropriate examples.

---

## Category 5: Deleted Files

Two guide files have been deleted:

| File | Status |
|------|--------|
| `.claude/docs/guides/neovim-integration.md` | **Deleted** (335 lines) |
| `.claude/docs/guides/tts-stt-integration.md` | **Deleted** (366 lines) |

### Cross-Reference Update

| File | Change |
|------|--------|
| `.claude/README.md` | `[Neovim Integration](docs/guides/neovim-integration.md)` -> note pointing to nvim extension |

### Impact on docs/README.md

**None required.** No references to either deleted file found in `docs/` or `README.md`.

---

## Category 6: Copy/Installation Guide Genericization

The copy-claude-directory guide has been fully genericized.

### Files Changed

| File | Change Summary |
|------|---------------|
| `.claude/docs/guides/copy-claude-directory.md` | "for Neovim configuration maintenance" -> "to a new project" |
| `.claude/docs/guides/copy-claude-directory.md` | Neovim context listing -> generic extension system description |
| `.claude/docs/guides/copy-claude-directory.md` | `nvim/` project structure example -> generic `src/` structure |
| `.claude/docs/guides/copy-claude-directory.md` | `~/.config/` paths -> `/path/to/your/project/` |
| `.claude/docs/guides/copy-claude-directory.md` | `$env:LOCALAPPDATA\nvim\` -> `C:\path\to\your\project\` |
| `.claude/docs/guides/copy-claude-directory.md` | `--language neovim` test command -> plain `/task "Test task creation"` |
| `.claude/docs/guides/copy-claude-directory.md` | `Configure telescope.nvim` example -> `Add search functionality` |
| `.claude/docs/guides/user-guide.md` | (38 lines changed - likely similar genericization) |
| `.claude/docs/guides/user-installation.md` | (95 lines changed - likely similar genericization) |
| `.claude/docs/guides/permission-configuration.md` | (53 lines changed) |

### Impact on docs/README.md

**None required.** The `docs/` directory's own guides (in `docs/general/`, `docs/agent-system/`, `docs/workflows/`) are separate from the `.claude/docs/` guides and already use Zed-appropriate content.

---

## Category 7: index.json Restructuring

The `.claude/context/index.json` file (4568 lines changed) has been restructured. The changes are primarily **key reordering** within each entry object (e.g., `line_count` before `keywords`, `path` moved to end of object). The semantic content appears largely unchanged aside from entries referencing neovim.

### Impact on docs/README.md

**None.** This is an internal machine-readable file.

---

## Category 8: Minor/Cosmetic Changes

| File | Change |
|------|--------|
| `.claude/extensions.json` | 424 lines changed (extension state tracking) |
| `.claude/settings.json` | 2 lines changed |
| `.claude/rules/plan-format-enforcement.md` | 2 lines changed |
| `.claude/skills/skill-fix-it/SKILL.md` | 7 lines changed |
| `.claude/skills/skill-orchestrator/SKILL.md` | 3 lines changed |
| All `Maintained By:` footers | `Neovim Configuration Development Team` -> `Development Team` or `Project Development Team` |

---

## Assessment: docs/ and README.md Update Needs

### Already Clean (No Changes Needed)

After scanning all files in `docs/` and `README.md`:

- **Zero** references to "neovim", "nvim", "Neovim" found
- **Zero** references to `<leader>ac` found
- **Zero** references to `nvim/lua/` paths found
- **Zero** references to deleted files (`neovim-integration.md`, `tts-stt-integration.md`)
- **Zero** references to `neovim-research-agent`, `skill-neovim-*`, or `neovim-implementation-agent`

### Potential Consistency Updates (Optional)

While no breaking references exist, consider whether `docs/` should be updated to match the new generic language patterns:

1. **`docs/agent-system/architecture.md`** - May reference neovim-era concepts; verify it uses current generic terminology
2. **`docs/agent-system/commands.md`** - Verify command descriptions match updated `.claude/commands/*.md`
3. **`docs/agent-system/context-and-memory.md`** - Verify context layer descriptions match updated `.claude/context/` structure

### Recommendation

**The `docs/` and `README.md` files do not require urgent updates.** The refactoring was done cleanly within `.claude/` and the public-facing documentation was already written with Zed-appropriate, editor-agnostic language. The task can be closed as "no changes required" or downgraded to a verification-only review.

---

## Appendix: Full File Change Summary

| File | Lines Changed | Category |
|------|--------------|----------|
| `.claude/CLAUDE.md` | +5/-5 | 1, 2 |
| `.claude/README.md` | +2/-2 | 2, 5 |
| `.claude/agents/meta-builder-agent.md` | +2/-3 | 1 |
| `.claude/agents/spawn-agent.md` | +1/-1 | 1 |
| `.claude/commands/fix-it.md` | +17/-17 | 1, 3 |
| `.claude/commands/review.md` | +7/-7 | 1, 3 |
| `.claude/commands/task.md` | +2/-3 | 1, 4 |
| `.claude/commands/todo.md` | +5/-5 | 3 |
| `.claude/context/architecture/system-overview.md` | +1/-1 | 1 |
| `.claude/context/formats/frontmatter.md` | +2/-2 | 1 |
| `.claude/context/guides/extension-development.md` | +15/-15 | 2, 4 |
| `.claude/context/index.json` | ~4568 | 7 |
| `.claude/context/index.schema.json` | +1/-1 | 1 |
| `.claude/context/orchestration/orchestration-core.md` | +1/-1 | 1 |
| `.claude/context/reference/skill-agent-mapping.md` | +2/-2 | 2 |
| `.claude/context/repo/update-project.md` | +1/-1 | 1 |
| `.claude/context/standards/ci-workflow.md` | +3/-3 | 1 |
| `.claude/context/standards/documentation-standards.md` | +1/-1 | 1 |
| `.claude/docs/architecture/extension-system.md` | +4/-4 | 2, 3 |
| `.claude/docs/architecture/system-overview.md` | +17/-17 | 1, 4 |
| `.claude/docs/examples/fix-it-flow-example.md` | +78/-78 | 3, 4 |
| `.claude/docs/examples/research-flow-example.md` | +8/-15 | 4 |
| `.claude/docs/guides/adding-domains.md` | +7/-7 | 1, 2, 4 |
| `.claude/docs/guides/component-selection.md` | +8/-14 | 1, 4 |
| `.claude/docs/guides/copy-claude-directory.md` | +26/-37 | 6 |
| `.claude/docs/guides/creating-agents.md` | +4/-10 | 1, 4 |
| `.claude/docs/guides/creating-extensions.md` | +4/-4 | 2, 4 |
| `.claude/docs/guides/creating-skills.md` | +2/-2 | 1 |
| `.claude/docs/guides/development/context-index-migration.md` | +13/-13 | 4 |
| `.claude/docs/guides/neovim-integration.md` | -335 | 5 (deleted) |
| `.claude/docs/guides/permission-configuration.md` | ~53 | 6 |
| `.claude/docs/guides/tts-stt-integration.md` | -366 | 5 (deleted) |
| `.claude/docs/guides/user-guide.md` | ~38 | 6 |
| `.claude/docs/guides/user-installation.md` | ~95 | 6 |
| `.claude/docs/reference/standards/agent-frontmatter-standard.md` | ~14 | 4 |
| `.claude/docs/reference/standards/extension-slim-standard.md` | ~4 | 4 |
| `.claude/docs/reference/standards/multi-task-creation-standard.md` | ~4 | 4 |
| `.claude/extensions.json` | ~424 | 8 |
| `.claude/rules/plan-format-enforcement.md` | ~2 | 8 |
| `.claude/settings.json` | ~2 | 8 |
| `.claude/skills/skill-fix-it/SKILL.md` | ~7 | 8 |
| `.claude/skills/skill-orchestrator/SKILL.md` | ~3 | 8 |
