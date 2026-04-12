# Implementation Plan: Disable system-wide auto-memories

- **Task**: 43 - Disable system-wide Claude Code auto-memories and use per-repo .memory/ exclusively
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/043_disable_system_wide_auto_memories/reports/01_auto-memory-research.md
- **Artifacts**: plans/01_disable-auto-memory.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Disable Claude Code's auto-memory system globally and migrate existing valuable memories to the per-repo `.memory/` vault. The dotfiles-managed `~/.claude/settings.json` will be updated at source (`~/.dotfiles/config/claude-settings.json`) to set `autoMemoryEnabled: false`, and the two existing auto-memory files for the zed project will be migrated to `.memory/10-Memories/` before disabling. After deployment via `home-manager switch`, verification confirms the change took effect.

### Research Integration

Key findings from `reports/01_auto-memory-research.md`:
- Two official disable mechanisms: `autoMemoryEnabled: false` in settings.json and `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` env var
- Settings file is Home Manager-managed; edits must target `~/.dotfiles/config/claude-settings.json`
- 2 auto-memory files exist for zed project (855B + 1913B); 2 additional index-only entries have no backing files
- Per-repo `.memory/` vault structure exists but `10-Memories/` is empty
- The `settings.json` approach is preferred over env var (cleaner, officially documented)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items found.

## Goals & Non-Goals

**Goals**:
- Migrate 2 existing auto-memory files and 2 index-only entries to `.memory/10-Memories/`
- Disable auto-memory globally via dotfiles settings
- Deploy the change so new Claude Code sessions do not read or write auto-memories
- Verify the disable is effective

**Non-Goals**:
- Deleting `~/.claude/projects/` conversation logs (only memory files are relevant)
- Setting up `.memory/` vaults in other repositories (out of scope)
- Using the environment variable kill switch (settings.json is sufficient)
- Modifying the memory extension or `/learn` command

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Home Manager rebuild overwrites runtime settings | H | H | Edit dotfiles source, not runtime file |
| Setting not respected by future Claude Code versions | M | L | Belt-and-suspenders: can add env var later if needed |
| Memory vault entries not loaded by agents | M | L | CLAUDE.md context architecture already lists .memory/ as a layer |
| home-manager switch fails or is unavailable | M | L | Phase 2 includes manual fallback instruction |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Migrate auto-memories to .memory/ vault [COMPLETED]

**Goal**: Transfer the 4 auto-memory entries (2 files + 2 index-only) into the per-repo `.memory/10-Memories/` directory using proper MEM-*.md format with frontmatter.

**Tasks**:
- [ ] Read `~/.claude/projects/-home-benjamin--config-zed/memory/feedback_no_vim_mode_zed.md` content
- [ ] Read `~/.claude/projects/-home-benjamin--config-zed/memory/project_zed_keymap_context_shadowing.md` content
- [ ] Read `~/.claude/projects/-home-benjamin--config-zed/memory/MEMORY.md` to capture the 2 index-only entries (`feedback_lazy_task_directories`, `feedback_no_researched_without_artifacts`)
- [ ] Create `.memory/10-Memories/MEM-001.md` -- "No vim mode in Zed" (from feedback_no_vim_mode_zed.md)
- [ ] Create `.memory/10-Memories/MEM-002.md` -- "Keymap context shadowing" (from project_zed_keymap_context_shadowing.md)
- [ ] Create `.memory/10-Memories/MEM-003.md` -- "Lazy task directories" (from index-only entry)
- [ ] Create `.memory/10-Memories/MEM-004.md` -- "No RESEARCHED without artifacts" (from index-only entry)
- [ ] Update `.memory/20-Indices/` if an index file exists, or verify entries are discoverable

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `.memory/10-Memories/MEM-001.md` - Create (no vim mode)
- `.memory/10-Memories/MEM-002.md` - Create (keymap shadowing)
- `.memory/10-Memories/MEM-003.md` - Create (lazy task dirs)
- `.memory/10-Memories/MEM-004.md` - Create (no RESEARCHED without artifacts)

**Verification**:
- All 4 MEM-*.md files exist in `.memory/10-Memories/`
- Each file has proper frontmatter (id, title, created, source, tags)
- Content matches original auto-memory entries

---

### Phase 2: Disable auto-memory in dotfiles settings [COMPLETED]

**Goal**: Add `autoMemoryEnabled: false` to the dotfiles source for Claude Code settings and deploy via Home Manager.

**Tasks**:
- [ ] Read `~/.dotfiles/config/claude-settings.json` to see current content
- [ ] Add `"autoMemoryEnabled": false` to the JSON object
- [ ] Run `home-manager switch` to deploy the updated settings (or document manual copy if home-manager unavailable)
- [ ] Verify `~/.claude/settings.json` contains `autoMemoryEnabled: false` after deployment

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `~/.dotfiles/config/claude-settings.json` - Add autoMemoryEnabled field

**Verification**:
- `jq '.autoMemoryEnabled' ~/.claude/settings.json` returns `false`
- `jq '.autoMemoryEnabled' ~/.dotfiles/config/claude-settings.json` returns `false`

---

### Phase 3: Verify and update context architecture documentation [NOT STARTED]

**Goal**: Confirm auto-memory is disabled in a new session context and update CLAUDE.md to reflect that auto-memory is no longer active.

**Tasks**:
- [ ] Verify `~/.claude/settings.json` has `autoMemoryEnabled: false` (post-deploy check)
- [ ] Update the Context Architecture table in `.claude/CLAUDE.md` to mark the auto-memory layer as disabled or remove it
- [ ] Add a note in `.memory/10-Memories/` documenting the decision to disable auto-memory (MEM-005.md)

**Timing**: 30 minutes

**Depends on**: 2

**Files to modify**:
- `.claude/CLAUDE.md` - Update Context Architecture table (auto-memory row)
- `.memory/10-Memories/MEM-005.md` - Create (decision record: auto-memory disabled)

**Verification**:
- CLAUDE.md no longer references auto-memory as an active context layer
- New Claude Code session does not load auto-memories (verify by checking session startup behavior)

## Testing & Validation

- [ ] All 4 migrated memory files exist in `.memory/10-Memories/` with correct frontmatter
- [ ] `~/.claude/settings.json` contains `"autoMemoryEnabled": false`
- [ ] `~/.dotfiles/config/claude-settings.json` contains `"autoMemoryEnabled": false`
- [ ] CLAUDE.md context architecture table updated
- [ ] New Claude Code session does not reference auto-memory content

## Artifacts & Outputs

- `specs/043_disable_system_wide_auto_memories/plans/01_disable-auto-memory.md` (this file)
- `specs/043_disable_system_wide_auto_memories/summaries/01_disable-auto-memory-summary.md` (after implementation)
- `.memory/10-Memories/MEM-001.md` through `MEM-005.md`
- `~/.dotfiles/config/claude-settings.json` (modified)
- `.claude/CLAUDE.md` (modified)

## Rollback/Contingency

To revert if auto-memory needs to be re-enabled:
1. Remove or set `"autoMemoryEnabled": true` in `~/.dotfiles/config/claude-settings.json`
2. Run `home-manager switch` to redeploy
3. The `.memory/` entries remain valid regardless (no conflict with auto-memory being active)
4. Original auto-memory files in `~/.claude/projects/` are untouched (not deleted by this plan)
