# Research Report: Task #43

**Task**: 43 - Disable system-wide Claude Code auto-memories and use per-repo .memory/ exclusively
**Started**: 2026-04-12T21:10:00Z
**Completed**: 2026-04-12T21:15:00Z
**Effort**: Small (research only)
**Dependencies**: None
**Sources/Inputs**: Official Claude Code docs (code.claude.com/docs/en/memory), ~/.claude/settings.json, ~/.claude/projects/ filesystem, .memory/ vault, GitHub issues #23544 and #23750
**Artifacts**: specs/043_disable_system_wide_auto_memories/reports/01_auto-memory-research.md
**Standards**: report-format.md

## Executive Summary

- Claude Code provides two official mechanisms to disable auto-memory: `"autoMemoryEnabled": false` in settings.json, and `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` environment variable
- The environment variable takes precedence over all other settings, making it the definitive kill switch
- The per-repo `.memory/` system is already set up and functional in this repository, with the memory extension providing `/learn` command support
- Current auto-memory contains only 3 files (3.3KB) for the zed project; the valuable memories should be migrated to `.memory/` before disabling

## Context & Scope

The user runs multiple repositories (zed, nvim, dotfiles, ProofChecker, etc.) from the same machine. Claude Code's auto-memory system at `~/.claude/projects/` stores per-project memories that persist across sessions. The concern is that cross-repo memories in `~/.claude/` cause behavioral interference, since different repos require different conventions (e.g., vim mode in nvim but not in zed).

The goal is to disable auto-memory globally and rely exclusively on the per-repo `.memory/` vault system managed by the memory extension's `/learn` command.

## Findings

### Current Auto-Memory State

**Location**: `~/.claude/projects/-home-benjamin--config-zed/memory/`

**Files** (3 total, 3.3KB):
1. `MEMORY.md` -- Index file (5 lines, 601 bytes) referencing 4 memories (2 have files, 2 are index-only entries)
2. `feedback_no_vim_mode_zed.md` -- "Do not enable vim_mode in Zed" (855 bytes)
3. `project_zed_keymap_context_shadowing.md` -- "Editor-context bindings shadow Workspace-context" (1913 bytes)

**MEMORY.md index references 4 items** but only 2 have backing files:
- `feedback_no_vim_mode_zed.md` -- exists
- `project_zed_keymap_context_shadowing.md` -- exists
- `feedback_lazy_task_directories.md` -- referenced in index but file does not exist
- `feedback_no_researched_without_artifacts.md` -- referenced in index but file does not exist

**Other projects with auto-memory dirs** (11 total, 141MB disk):
- Only the zed project has a `memory/` subdirectory with MEMORY.md
- Other project directories contain only session `.jsonl` files and session subdirectories (conversation logs, not memories)
- The 141MB is dominated by conversation logs (`.jsonl` files), not memory files

### Available Configuration Options

#### Option 1: settings.json (Recommended)

Add `"autoMemoryEnabled": false` to `~/.claude/settings.json`:

```json
{
  "autoMemoryEnabled": false,
  ...existing settings...
}
```

**Behavior**: Claude will not read from or write to `~/.claude/projects/<project>/memory/`. Per official docs, the first 200 lines of MEMORY.md (or 25KB) are normally loaded at session start; setting this to false prevents that.

**Important**: Since `~/.claude/settings.json` is managed by Home Manager via `~/.dotfiles/config/claude-settings.json`, the edit must be made in the dotfiles source and deployed with `home-manager switch`.

#### Option 2: Environment Variable (Nuclear option)

Set `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` in the shell environment.

**Behavior**: Overrides both the `/memory` toggle and `settings.json`. This is the definitive kill switch per official documentation.

**Where to set**: Could be added to the `env` block in `settings.json`:
```json
{
  "env": {
    "CLAUDE_CODE_DISABLE_AUTO_MEMORY": "1",
    ...
  }
}
```

Or in shell profile (`~/.bashrc`, `~/.zshrc`, or Nix environment).

#### Option 3: Per-Project settings.json

Add `"autoMemoryEnabled": false` to `.claude/settings.json` within each repository.

**Note**: Per official docs, `autoMemoryEnabled` CAN be set at the project level. Only `autoMemoryDirectory` is restricted from project settings for security reasons.

### Per-Repo .memory/ System Status

**Location**: `/home/benjamin/.config/zed/.memory/`

**Structure** (already set up):
```
.memory/
  00-Inbox/          -- Quick capture
  10-Memories/       -- Stored entries (currently empty except README.md)
  20-Indices/        -- Navigation
  30-Templates/      -- Entry templates
  README.md          -- Vault documentation
```

**Skill**: `skill-memory` (SKILL.md at `.claude/skills/skill-memory/SKILL.md`) provides:
- `/learn "text"` -- Add text content
- `/learn /path/to/file` -- Add file content
- `/learn /path/to/dir/` -- Scan directory
- `/learn --task N` -- Review task artifacts

**Current state**: The vault structure exists but `10-Memories/` contains no MEM-*.md files yet. The auto-memory system has been storing memories in `~/.claude/projects/` instead.

**Integration**: The CLAUDE.md context architecture table already lists `.memory/` as a context layer loaded by agents. The `/research --remember` flag searches the memory vault for relevant prior knowledge.

### Conflict Analysis

The two memory systems coexist but serve overlapping purposes:

| Aspect | Auto-memory (~/.claude/projects/) | Per-repo (.memory/) |
|--------|-----------------------------------|---------------------|
| Who writes | Claude automatically | User via /learn (interactive) |
| Scope | Machine-local, per-project | Repository-local, git-tracked |
| Loaded | First 200 lines at session start | By agents via context discovery |
| Shareable | No (machine-local) | Yes (committed to git) |
| Structured | Loose markdown | Frontmatter + templates |
| Searchable | By Claude reading files | MCP server or grep fallback |

**Key conflicts**:
1. Auto-memory can accumulate stale or contradictory information without user review
2. Auto-memory is not version-controlled, so no audit trail
3. Auto-memory content may duplicate or contradict .memory/ entries
4. Auto-memory loads unconditionally at session start, consuming context tokens

## Recommendations

### Recommended Approach: Two-Phase Disable

**Phase 1: Migrate valuable memories**
1. Read the 2 existing auto-memory files for the zed project
2. Use `/learn` to create equivalent entries in `.memory/10-Memories/`
3. Migrate: `feedback_no_vim_mode_zed.md` and `project_zed_keymap_context_shadowing.md`
4. The 2 index-only entries (`feedback_lazy_task_directories`, `feedback_no_researched_without_artifacts`) should also be captured

**Phase 2: Disable auto-memory globally**
1. Edit `~/.dotfiles/config/claude-settings.json` to add `"autoMemoryEnabled": false`
2. Run `home-manager switch` to deploy
3. Optionally clean up `~/.claude/projects/*/memory/` directories

**Phase 3: Verify and document**
1. Start a new Claude Code session and verify auto-memory is disabled (run `/memory` to check)
2. Confirm `.memory/` entries are being loaded by agents
3. Document the decision in `.memory/` or `.claude/CLAUDE.md`

### Alternative: Environment Variable in settings.json env block

If the `autoMemoryEnabled` setting proves unreliable (some GitHub issues suggest edge cases), the env-var approach via settings.json `env` block is a belt-and-suspenders option:

```json
{
  "env": {
    "CLAUDE_CODE_DISABLE_AUTO_MEMORY": "1",
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  },
  "autoMemoryEnabled": false
}
```

### NOT Recommended: Per-project disable only

Setting `autoMemoryEnabled: false` only in `.claude/settings.json` per-repo would leave other repos with auto-memory active. Since the user wants to standardize on `.memory/` across all repos, the global disable is preferred.

## Decisions

- Global disable via `~/.claude/settings.json` is preferred over environment variable (cleaner, documented in official settings)
- Existing auto-memory content should be migrated before disabling (2 files with useful project-specific knowledge)
- The `.memory/` vault is the sole memory mechanism going forward
- The dotfiles source file must be edited (not the runtime settings.json) due to Home Manager management

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Losing useful auto-memories | Migrate before disabling; auto-memory files are not deleted, just not read |
| Setting not respected by future Claude Code versions | Use both `autoMemoryEnabled: false` AND env var as belt-and-suspenders |
| .memory/ vault is empty, losing accumulated knowledge | Phase 1 migration populates it; `/learn --task N` can harvest from past task artifacts |
| Home Manager rebuild overwrites runtime changes | Edit the dotfiles source, not `~/.claude/settings.json` directly |
| Other repos lose auto-memory without .memory/ set up | Acceptable: auto-memory was minimal for other repos (no memory/ dirs exist for most) |

## Appendix

### Search Queries Used
- "Claude Code disable auto memory ~/.claude/projects settings.json 2026"
- "Claude Code CLAUDE_CODE_DISABLE_AUTO_MEMORY settings.json environment variable"
- "Claude Code autoMemoryEnabled false settings.json disable memory 2026"

### References
- [Official Claude Code Memory Docs](https://code.claude.com/docs/en/memory)
- [GitHub Issue #23544: Need ability to disable auto-memory](https://github.com/anthropics/claude-code/issues/23544)
- [GitHub Issue #23750: Option to disable auto-memory](https://github.com/anthropics/claude-code/issues/23750)
- [Claude Code Auto Memory Guide](https://claudefa.st/blog/guide/mechanics/auto-memory)

### Files Examined
- `~/.claude/settings.json` -- Current global settings (managed by Home Manager)
- `~/.dotfiles/config/claude-settings.json` -- Dotfiles source for settings
- `~/.claude/projects/-home-benjamin--config-zed/memory/MEMORY.md` -- Auto-memory index
- `~/.claude/projects/-home-benjamin--config-zed/memory/feedback_no_vim_mode_zed.md`
- `~/.claude/projects/-home-benjamin--config-zed/memory/project_zed_keymap_context_shadowing.md`
- `.memory/README.md` -- Per-repo memory vault documentation
- `.claude/skills/skill-memory/SKILL.md` -- Memory skill definition
