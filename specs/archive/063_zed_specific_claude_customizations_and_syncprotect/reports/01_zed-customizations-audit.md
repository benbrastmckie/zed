# Research Report: Task #63

**Task**: 63 - Create zed-specific .claude/ customizations and .syncprotect file
**Started**: 2026-04-14T00:00:00Z
**Completed**: 2026-04-14T00:30:00Z
**Effort**: medium
**Dependencies**: None
**Sources/Inputs**:
- Codebase audit of zed repo root structure
- Diff comparison of nvim vs zed .claude/CLAUDE.md
- Diff comparison of nvim vs zed .claude/rules/git-workflow.md
- Audit of .claude/agents/ directory
- Audit of .claude/hooks/ directory
- Review of extensions.json for loaded extensions
- Review of settings.json, keymap.json, tasks.json
**Artifacts**:
- specs/063_zed_specific_claude_customizations_and_syncprotect/reports/01_zed-customizations-audit.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The `project-overview.md` is entirely wrong -- it describes Neovim/Lua/lazy.nvim instead of the Zed editor configuration repo.
- The core CLAUDE.md (first 345 lines) is identical to the nvim canonical version; only the extension sections (lines 346-621) differ. No Co-Authored-By references exist. The `<leader>ac` references are nvim-specific and should be updated for zed context.
- `git-workflow.md` is byte-identical between nvim and zed -- no changes needed; accept upstream.
- `slide-planner-agent.md` and `validate-plan-write.sh` both exist in this repo. The CLAUDE.md already includes slide-planner table rows (line 503). No additions needed.
- The `agents/README.md` was deleted (visible in git status) and needs recreation.
- Only `project-overview.md` and `CLAUDE.md` need zed-specific customization. The `.syncprotect` should protect CLAUDE.md only.

## Context & Scope

This research audits the zed config repo's `.claude/` files to identify what needs zed-specific customization versus accepting the nvim canonical version. The zed repo is at `/home/benjamin/.config/zed` and is synced from the nvim source at `/home/benjamin/.config/nvim`.

## Findings

### 1. project-overview.md Audit

**Current state**: Entirely describes Neovim configuration (Lua, lazy.nvim, treesitter, nvim-lspconfig, mason.nvim). Every section is wrong for this repo.

**Actual zed repo structure**:
```
.                           # /home/benjamin/.config/zed
├── settings.json           # Zed editor settings (vim_mode, theme, LSP, languages, agent_servers)
├── keymap.json             # Custom keybindings (26 entries across contexts)
├── tasks.json              # Zed task runner definitions (3 tasks)
├── .gitignore              # Excludes specs/tmp/
├── README.md               # Comprehensive project documentation
├── docs/                   # User-facing documentation
│   ├── agent-system/       # Agent architecture, commands, Zed agent panel
│   ├── general/            # Installation, keybindings, settings
│   ├── toolchain/          # Extensions, MCP servers, Python, R, shell tools, Slidev, typesetting
│   └── workflows/          # Agent lifecycle, document conversion, epidemiology, grants, memory
├── examples/               # Example projects
│   ├── epi-slides/         # Slidev epidemiology presentation
│   ├── epi-study/          # R epidemiology study
│   └── test-files/         # Test documents
├── scripts/
│   └── install/            # Installation wizard (install.sh)
├── talks/                  # Research talk artifacts (task-linked)
│   ├── 49_hiv_grand_rounds_la_art_prep/
│   ├── 50_hiv_grand_rounds_slidev/
│   └── 53_hiv_grand_rounds_slidev/
├── themes/                 # (empty -- One Dark is set in settings.json)
├── prompts/                # Zed prompts library database
├── .zed/                   # Zed-specific task scripts
│   ├── scripts/            # build-pdf.sh, preview.sh, slidev-export.sh
│   └── tasks.json          # Zed tasks: Claude Code CLI, Build PDF, Preview in Browser
├── .memory/                # Memory vault for learned facts
├── specs/                  # Task management artifacts (TODO.md, state.json, task dirs)
└── .claude/                # Claude Code agent system configuration
```

**Technology stack**:
- **Editor**: Zed
- **Theme**: One Dark, Fira Code font
- **Languages**: R (r-language-server), Python (pyright + ruff), Markdown (prettier), Nix, TOML, JSON
- **AI Integration**: Claude Code via ACP agent server (npx @agentclientprotocol/claude-agent-acp)
- **Extensions auto-installed**: markdown-oxide, markdownlint, codebook, csv, nix, toml, git-firefly, r, python, ruff
- **Platforms**: macOS 11+, Debian/Ubuntu, Arch/Manjaro

### 2. CLAUDE.md Audit

**Core section (lines 1-345)**: Byte-identical to nvim canonical. This is the agent system documentation that is shared across repos.

**Extension sections (lines 346-621)**: Appended by the extension loader via `<!-- SECTION: extension_* -->` comment markers. These are dynamically managed and should not be manually edited.

**Zed-specific issues found in core section**:

1. **`<leader>ac` references (lines 73, 198, 291)**: These refer to the Neovim extension picker keybinding. In zed, extensions are loaded via the nvim extension loader remotely (source_dir paths all point to `/home/benjamin/.config/nvim/.claude/extensions/`). The zed repo does not have its own `<leader>ac` keybinding.

2. **VimTeX Integration subsection (lines 441-446)**: This section in the LaTeX extension describes `:VimtexCompile`, `:VimtexView`, etc. These are Neovim-specific. In zed, the equivalent is `Alt+Shift+E` (Build PDF via `.zed/scripts/build-pdf.sh`) and `Alt+Shift+P` (Preview in Browser via `.zed/scripts/preview.sh`). However, this section is inside a `<!-- SECTION: extension_latex -->` block that is dynamically managed by the extension loader -- editing it would be overwritten on next sync.

3. **No Co-Authored-By references found**: Clean.

4. **slide-planner-agent already present**: Line 503 has `| skill-slide-planning | slide-planner-agent | opus | Slide plan with design questions |` in the Present Extension section.

5. **slide-critic-agent already present**: Line 504 has `| skill-slide-critic | slide-critic-agent | opus | Interactive slide critique with rubric evaluation |`.

**Recommendation for CLAUDE.md**: The `<leader>ac` references at lines 73 and 291 should be updated to describe zed's extension loading mechanism (which uses the nvim loader remotely). This is the only substantive zed-specific customization needed in the core section.

### 3. rules/git-workflow.md Audit

**Status**: Byte-identical between nvim and zed (confirmed via `diff`). No Co-Authored-By references, no nvim-specific content.

**Recommendation**: Accept upstream as-is. No protection needed.

### 4. agents/ Directory Audit

**30 agent files present**:

| Agent | Source |
|-------|--------|
| budget-agent.md | present extension |
| code-reviewer-agent.md | core |
| document-agent.md | filetypes extension |
| docx-edit-agent.md | filetypes extension |
| epi-implement-agent.md | epidemiology extension |
| epi-research-agent.md | epidemiology extension |
| filetypes-router-agent.md | filetypes extension |
| funds-agent.md | present extension |
| general-implementation-agent.md | core |
| general-research-agent.md | core |
| grant-agent.md | present extension |
| latex-implementation-agent.md | latex extension |
| latex-research-agent.md | latex extension |
| meta-builder-agent.md | core |
| planner-agent.md | core |
| pptx-assembly-agent.md | present extension |
| presentation-agent.md | filetypes extension |
| python-implementation-agent.md | python extension |
| python-research-agent.md | python extension |
| reviser-agent.md | core |
| scrape-agent.md | filetypes extension |
| slide-critic-agent.md | present extension |
| slide-planner-agent.md | present extension |
| slides-research-agent.md | present extension |
| slidev-assembly-agent.md | present extension |
| spawn-agent.md | core |
| spreadsheet-agent.md | filetypes extension |
| timeline-agent.md | present extension |
| typst-implementation-agent.md | typst extension |
| typst-research-agent.md | typst extension |

**README.md status**: Deleted (shown in `git status` as ` D .claude/agents/README.md`). Needs recreation with accurate agent listing.

### 5. Hooks Directory Audit

**10 hook scripts present**:
- log-session.sh
- post-command.sh
- subagent-postflight.sh
- tts-notify.sh
- validate-plan-write.sh (exists -- task description asked about this)
- validate-state-sync.sh
- wezterm-clear-status.sh
- wezterm-clear-task-number.sh
- wezterm-notify.sh
- wezterm-task-number.sh

**Note**: `validate-plan-write.sh` exists, so if CLAUDE.md had a Hooks section, it should document it. Currently CLAUDE.md does not have a Hooks section (the nvim canonical doesn't either).

**Additional finding**: `.claude/settings.json` line 87 references `~/.config/nvim/scripts/claude-ready-signal.sh` -- an nvim-specific path in the zed settings. This is a separate issue but worth noting.

### 6. .syncprotect Analysis

Based on all findings, these files need sync protection:

| File | Needs Protection | Rationale |
|------|-----------------|-----------|
| `context/repo/project-overview.md` | No | Already excluded by CONTEXT_EXCLUDE_PATTERNS per task description |
| `CLAUDE.md` | **Yes** | The `<leader>ac` references will be customized for zed context |
| `rules/git-workflow.md` | No | Byte-identical; accept upstream |
| `agents/README.md` | No | README.md files already skipped by sync |
| Extension sections in CLAUDE.md | No | Managed by extension loader comment markers |

**Recommended .syncprotect contents**:
```
# Files with zed-specific customizations that should not be overwritten by sync
CLAUDE.md
```

Only CLAUDE.md needs protection because it will contain zed-specific replacement text for `<leader>ac` references. All other files either accept upstream, are excluded by other mechanisms, or are dynamically managed.

## Decisions

1. **project-overview.md**: Must be completely rewritten to describe the Zed editor configuration repo.
2. **CLAUDE.md**: Only the `<leader>ac` references (3 occurrences) need updating. The extension-managed sections should not be touched.
3. **git-workflow.md**: Accept upstream as-is. No zed-specific changes.
4. **agents/README.md**: Recreate with the 30 agents currently in the directory.
5. **.syncprotect**: Protect only CLAUDE.md.

## Recommendations

1. **Phase 1 (project-overview.md)**: Replace entirely with zed-specific content documenting settings.json, keymap.json, docs/, examples/, talks/, scripts/, .zed/, .memory/, and the Zed-specific technology stack.

2. **Phase 2 (CLAUDE.md)**: Replace the 3 `<leader>ac` references with zed-appropriate text. Suggested replacement: "loaded via the extension loader" or "loaded from the nvim extension source". Do NOT edit inside `<!-- SECTION: extension_* -->` blocks.

3. **Phase 3 (git-workflow.md)**: No action needed. Accept upstream.

4. **Phase 4 (agents/README.md)**: Generate a listing of all 30 agents organized by source (core vs extension). Include agent name, purpose, and model preference.

5. **Phase 5 (.syncprotect)**: Create `.claude/.syncprotect` with a single entry: `CLAUDE.md`.

6. **Bonus finding**: Consider fixing `.claude/settings.json` line 87 which references `~/.config/nvim/scripts/claude-ready-signal.sh` (an nvim path in zed config). This is out of scope for this task but should be tracked.

## Risks & Mitigations

- **Risk**: Editing CLAUDE.md inside extension comment markers could be overwritten on next extension load.
  - **Mitigation**: Only edit the core section (lines 1-345). The `<leader>ac` references are all in the core section.

- **Risk**: .syncprotect may not be recognized by the sync mechanism if the format is wrong.
  - **Mitigation**: Verify the sync script reads `.syncprotect` and confirm the expected format.

- **Risk**: The VimTeX subsection in the LaTeX extension section (lines 441-446) is nvim-specific but cannot be safely edited here.
  - **Mitigation**: This is an extension loader concern. The nvim extension source should have a mechanism for repo-specific overrides, or the VimTeX section should be removed from the extension's EXTENSION.md template. Out of scope for this task.

## Appendix

### Search Queries Used
- `diff` between nvim and zed CLAUDE.md
- `diff` between nvim and zed git-workflow.md
- `grep` for Co-Authored-By, nvim, neovim, `<leader>ac`, VimTeX, syncprotect
- `ls` of repo root, agents/, hooks/, .zed/, docs/, talks/, themes/, scripts/
- Review of settings.json, keymap.json, tasks.json, extensions.json, .gitignore

### Key File Paths
- `/home/benjamin/.config/zed/.claude/CLAUDE.md` (621 lines, core 1-345, extensions 346-621)
- `/home/benjamin/.config/zed/.claude/context/repo/project-overview.md` (145 lines, all wrong)
- `/home/benjamin/.config/zed/.claude/rules/git-workflow.md` (160 lines, identical to nvim)
- `/home/benjamin/.config/zed/.claude/agents/` (30 agent files, no README.md)
- `/home/benjamin/.config/zed/.claude/extensions.json` (7 extensions loaded from nvim source)
- `/home/benjamin/.config/zed/.claude/settings.json` (contains nvim path at line 87)
