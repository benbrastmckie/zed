# Task 65: nvim/neovim Reference Audit (Post-Reload)

## Summary

After the latest `.claude/` sync reload, there are **368 nvim/neovim occurrences across 53 files** (356 nvim/neovim + 12 in previously uncounted `settings.local.json`). Additionally, **21 neotex references across 3 files** and **19 `<leader>ac` references across 10 files** represent related Neovim-specific contamination.

The sync overwrote 8 of 9 `.syncprotect`-listed files (only `context/repo/project-overview.md` survived, likely because it's excluded by `CONTEXT_EXCLUDE_PATTERNS` rather than `.syncprotect`). The root `CLAUDE.md` created by task 63 no longer exists.

## .syncprotect Status

The `.syncprotect` file at project root lists 9 files. Post-reload status:

| Protected File | Overwritten? | nvim refs |
|----------------|--------------|-----------|
| `context/repo/project-overview.md` | No (survived) | 0 |
| `CLAUDE.md` | Yes | 4 |
| `README.md` | Yes | 2 |
| `commands/fix-it.md` | Yes | 16 |
| `commands/learn.md` | Yes | 1 |
| `commands/review.md` | Yes | 7 |
| `commands/task.md` | Yes | 3 |
| `skills/skill-orchestrator/SKILL.md` | Yes | 2 |
| `rules/plan-format-enforcement.md` | Yes | 1 |

`project-overview.md` survived because `CONTEXT_EXCLUDE_PATTERNS` skips it during sync, not because `.syncprotect` works. The sync mechanism does not honor `.syncprotect`.

**Root CLAUDE.md**: Task 63 created `CLAUDE.md` at the repo root (`~/.config/zed/CLAUDE.md`). It no longer exists -- either the sync deleted it or it was never committed.

## Complete File Inventory

53 files, 368 nvim/neovim occurrences (sorted by count descending):

| File | Count | Category |
|------|-------|----------|
| `docs/examples/fix-it-flow-example.md` | 60 | D |
| `docs/guides/neovim-integration.md` | 29 | C: Delete |
| `docs/guides/user-installation.md` | 22 | C: Rewrite |
| `docs/guides/tts-stt-integration.md` | 19 | C: Delete |
| `docs/guides/copy-claude-directory.md` | 17 | C: Rewrite |
| `commands/fix-it.md` | 16 | A+ |
| `context/guides/extension-development.md` | 15 | D |
| `docs/guides/component-selection.md` | 13 | D |
| `docs/examples/research-flow-example.md` | 12 | D |
| `docs/guides/development/context-index-migration.md` | 12 | D |
| `docs/architecture/system-overview.md` | 12 | D |
| `context/project/memory/learn-usage.md` | 12 | E |
| `settings.local.json` | 12 | A: Broken paths |
| `docs/guides/creating-agents.md` | 8 | D |
| `docs/guides/user-guide.md` | 8 | C: Rewrite |
| `commands/review.md` | 7 | A+ |
| `extensions.json` | 7 | A: Broken paths |
| `docs/guides/adding-domains.md` | 7 | C: Rewrite |
| `docs/guides/permission-configuration.md` | 7 | D |
| `skills/skill-memory/SKILL.md` | 7 | E |
| `docs/reference/standards/agent-frontmatter-standard.md` | 6 | D |
| `scripts/validate-wiring.sh` | 5 | A |
| `CLAUDE.md` | 4 | A+ |
| `commands/todo.md` | 4 | A |
| `agents/meta-builder-agent.md` | 3 | B |
| `agents/code-reviewer-agent.md` | 3 | B |
| `commands/task.md` | 3 | A+ |
| `context/standards/ci-workflow.md` | 3 | E |
| `docs/architecture/extension-system.md` | 3 | E |
| `docs/guides/creating-skills.md` | 2 | D |
| `docs/guides/creating-extensions.md` | 2 | D |
| `context/architecture/system-overview.md` | 2 | B |
| `README.md` | 2 | A+ |
| `skills/skill-orchestrator/SKILL.md` | 2 | A+ |
| `skills/skill-fix-it/SKILL.md` | 2 | B |
| `context/formats/frontmatter.md` | 2 | E |
| `scripts/lint/lint-postflight-boundary.sh` | 2 | E |
| `rules/plan-format-enforcement.md` | 1 | A+ |
| `settings.json` | 1 | A |
| `systemd/claude-refresh.service` | 1 | A |
| `agents/spawn-agent.md` | 1 | B |
| `context/orchestration/orchestration-core.md` | 1 | B |
| `context/standards/postflight-tool-restrictions.md` | 1 | E |
| `context/standards/documentation-standards.md` | 1 | E |
| `context/index.schema.json` | 1 | E |
| `context/repo/update-project.md` | 1 | E |
| `context/project/memory/knowledge-capture-usage.md` | 1 | E |
| `context/project/memory/domain/memory-reference.md` | 1 | E |
| `context/project/memory/memory-setup.md` | 1 | E |
| `context/project/latex/tools/compilation-guide.md` | 1 | E |
| `context/project/typst/tools/compilation-guide.md` | 1 | E |
| `docs/reference/standards/multi-task-creation-standard.md` | 1 | D |
| `commands/learn.md` | 1 | A+ |

### Related Contamination

**neotex references** (21 across 3 files):
- `docs/guides/tts-stt-integration.md` (13) -- Category C: Delete
- `docs/guides/neovim-integration.md` (6) -- Category C: Delete
- `docs/guides/user-guide.md` (2) -- Category C: Rewrite

**`<leader>ac` references** (19 across 10 files):
- `CLAUDE.md` (2), `README.md` (1), `context/guides/extension-development.md` (2), `docs/guides/creating-extensions.md` (3), `docs/guides/adding-domains.md` (3), `docs/architecture/extension-system.md` (2), `docs/reference/standards/extension-slim-standard.md` (2), `context/reference/skill-agent-mapping.md` (2), `docs/guides/neovim-integration.md` (1), `context/project/epidemiology/README.md` (1)

## Categories

### Category A+: Re-contaminated by Sync (Critical, 8 files, 36 occurrences)

Files that task 63 had cleaned but the sync reload overwrote. Listed in `.syncprotect` but overwritten anyway.

| File | Count | What was lost |
|------|-------|---------------|
| `CLAUDE.md` | 4 | Extension list mentions neovim, neovim task_type example, `<leader>ac` |
| `README.md` | 2 | nvim extension row, neovim-integration guide link |
| `commands/fix-it.md` | 16 | All examples use nvim/lua/ paths, neovim task types |
| `commands/learn.md` | 1 | neovim directory example |
| `commands/review.md` | 7 | nvim --headless, nvim/lua/ paths in examples |
| `commands/task.md` | 3 | neovim keyword detection, nvim path examples |
| `skills/skill-orchestrator/SKILL.md` | 2 | neovim routing entry |
| `rules/plan-format-enforcement.md` | 1 | neovim task_type example |

### Category A: Broken Config (Critical, 6 files, 30 occurrences)

Files with paths pointing to nvim directories that don't exist in this repo.

| File | Count | Issue |
|------|-------|-------|
| `extensions.json` | 7 | All 7 `source_dir` entries point to `/home/benjamin/.config/nvim/.claude/extensions/*` |
| `settings.local.json` | 12 | Bash permissions reference nvim paths: mv commands for neovim context files, script paths, spec file paths |
| `settings.json` | 1 | SessionStart hook runs `~/.config/nvim/scripts/claude-ready-signal.sh` |
| `systemd/claude-refresh.service` | 1 | ExecStart points to `nvim/.claude/scripts/claude-refresh.sh` |
| `commands/todo.md` | 4 | Health metrics grep `nvim/lua/`, run `nvim --headless` |
| `scripts/validate-wiring.sh` | 5 | Validates nonexistent neovim-research/implementation agents |

### Category B: Incorrect Routing (High, 6 files, 12 occurrences)

Files routing tasks to neovim agents/skills that don't exist here.

| File | Count | Issue |
|------|-------|-------|
| `agents/meta-builder-agent.md` | 3 | Routes "nvim", "neovim", "plugin" keywords to `task_type = "neovim"` |
| `agents/code-reviewer-agent.md` | 3 | "Load For Neovim Code" section with nvim extension context paths |
| `agents/spawn-agent.md` | 1 | Lists "neovim" as valid task_type example |
| `skills/skill-fix-it/SKILL.md` | 2 | `.lua (nvim/)` -> "neovim" type detection; neovim keyword list |
| `context/architecture/system-overview.md` | 2 | "Neovim Configuration agent system" |
| `context/orchestration/orchestration-core.md` | 1 | "Neovim Configuration's architecture" |

### Category C: Neovim-Centric Guides (Medium, 6 files, ~106 occurrences)

Entire files written for Neovim workflows with no Zed relevance.

| File | Count | Action |
|------|-------|--------|
| `docs/guides/neovim-integration.md` | 29 (+6 neotex, +1 leader) | **Delete** -- SessionStart hooks, nvim --remote-expr, terminal state management |
| `docs/guides/tts-stt-integration.md` | 19 (+13 neotex) | **Delete** -- neotex STT plugin, PulseAudio recording, Neovim-specific |
| `docs/guides/user-installation.md` | 22 | **Rewrite** -- "Setting Up a Neovim Configuration Project", telescope.nvim examples |
| `docs/guides/copy-claude-directory.md` | 17 | **Rewrite** -- "Copying .claude/ for Neovim configuration maintenance" |
| `docs/guides/user-guide.md` | 8 (+2 neotex) | **Rewrite** -- neovim task type throughout, lazy.nvim examples |
| `docs/guides/adding-domains.md` | 7 (+3 leader) | **Rewrite** -- `<leader>ac` extension loading, neovim as core domain |

### Category D: Examples Using Neovim (Medium, 13 files, ~142 occurrences)

Files using neovim as the example domain in templates/walkthroughs.

| File | Count | Issue |
|------|-------|-------|
| `docs/examples/fix-it-flow-example.md` | 60 | All examples use nvim/lua/ paths, neovim task types |
| `context/guides/extension-development.md` | 15 (+2 leader) | Neovim extension as worked example |
| `docs/guides/component-selection.md` | 13 | "Neovim Configuration agent system", neovim skill/agent tables |
| `docs/examples/research-flow-example.md` | 12 | Scenario C: "Neovim Task Routing" |
| `docs/guides/development/context-index-migration.md` | 12 | Neovim context entry examples |
| `docs/architecture/system-overview.md` | 12 | "Neovim Configuration agent system" throughout |
| `docs/guides/creating-agents.md` | 8 | neovim agents listed |
| `docs/guides/permission-configuration.md` | 7 | "Neovim Implementation Agent" permission profile |
| `docs/reference/standards/agent-frontmatter-standard.md` | 6 | neovim-research-agent as example |
| `docs/guides/creating-skills.md` | 2 | "Neovim Configuration agent system" |
| `docs/guides/creating-extensions.md` | 2 (+3 leader) | Extension loading via `<leader>ac` in Neovim |
| `context/formats/frontmatter.md` | 2 | "non-Neovim tasks", "Neovim plugin tooling" |
| `docs/reference/standards/multi-task-creation-standard.md` | 1 | nvim/lua/ path in example |
| `context/standards/documentation-standards.md` | 1 | "Use `lua` for Neovim configuration" |

### Category E: Template/Generic Mentions (Low, 14 files, ~42 occurrences)

Neovim in editor lists, build patterns, or generic templates.

| File | Count | Issue |
|------|-------|-------|
| `context/project/memory/learn-usage.md` | 12 | Neovim as example memory topic throughout |
| `skills/skill-memory/SKILL.md` | 7 | Neovim as example topic, directory, file type |
| `context/standards/ci-workflow.md` | 3 | "Neovim Lua files" in CI table |
| `docs/architecture/extension-system.md` | 3 (+2 leader) | `<leader>ac`, nvim paths in examples |
| `scripts/lint/lint-postflight-boundary.sh` | 2 | nvim --headless in build pattern list |
| `context/index.schema.json` | 1 | `nvim.config` in schema $id URL |
| `context/repo/update-project.md` | 1 | Notes existing project-overview is Neovim example |
| `context/standards/postflight-tool-restrictions.md` | 1 | `nvim --headless` in restriction table |
| `context/project/memory/knowledge-capture-usage.md` | 1 | neovim memory example |
| `context/project/memory/domain/memory-reference.md` | 1 | neovim topic example |
| `context/project/memory/memory-setup.md` | 1 | neovim memory write example |
| `context/project/latex/tools/compilation-guide.md` | 1 | "Neovim with VimTeX" in editor list |
| `context/project/typst/tools/compilation-guide.md` | 1 | "Neovim Integration" section header |

## Additional Issues

### Missing Root CLAUDE.md

Task 63 created `~/.config/zed/CLAUDE.md` as a central config index. This file no longer exists. It needs to be recreated and should NOT be a synced file (it's repo-specific).

### `<leader>ac` References

19 references across 10 files use the Neovim keybinding `<leader>ac` for extension loading. These should describe extensions as loaded "via the extension loader" or similar generic phrasing, since Zed doesn't use Neovim keybindings.

## Impact Summary

| Category | Files | Occurrences | Severity | Effort |
|----------|-------|-------------|----------|--------|
| A+: Re-contaminated | 8 | 36 | Critical | Low (re-apply known fixes) |
| A: Broken Config | 6 | 30 | Critical | Medium |
| B: Incorrect Routing | 6 | 12 | High | Low-Medium |
| C: Neovim-Centric Guides | 6 | ~106 | Medium | High (delete 2, rewrite 4) |
| D: Examples Using Neovim | 14 | ~142 | Medium | High (many examples to rewrite) |
| E: Template/Generic | 14 | ~42 | Low | Low |
| **Total** | **53 (+1 missing)** | **368** | | |

Additional: 21 neotex refs (3 files), 19 `<leader>ac` refs (10 files).

## Recommendations

1. **Fix sync protection before cleanup.** `.syncprotect` is not honored. Options:
   - Fix the sync loader to read `.syncprotect`
   - Use a post-sync fixup script that re-applies known patches
   - Use git stash/restore workflow around syncs
2. **Recreate root CLAUDE.md** (`~/.config/zed/CLAUDE.md`) -- repo-specific, not synced
3. **Prioritize A+ and A** -- broken paths and regressions from task 63
4. **Delete** `neovim-integration.md` and `tts-stt-integration.md` (100% Neovim-specific)
5. **Replace `<leader>ac`** with generic "extension loader" language across 10 files
6. **Category E can be deferred** -- harmless mentions in generic templates
7. **Estimated total effort**: Large (53 files, ~368 occurrences, many substantive rewrites)
