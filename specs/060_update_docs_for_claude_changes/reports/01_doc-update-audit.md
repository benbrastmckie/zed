# Research Report: Task #60

**Task**: 60 - Update documentation to reflect .claude/ directory changes
**Started**: 2026-04-13T22:40:00Z
**Completed**: 2026-04-13T22:55:00Z
**Effort**: medium
**Dependencies**: None
**Sources/Inputs**:
- `git diff .claude/` output (10 changed files, 3087 insertions, 2925 deletions)
- Codebase grep for `slide-planner-agent`, `skill-slide-planning`, `PostToolUse`, `Co-Authored-By` references
- `docs/` directory content review
- `.claude/README.md` and `.claude/CLAUDE.md` review
**Artifacts**: specs/060_update_docs_for_claude_changes/reports/01_doc-update-audit.md
**Standards**: report-format.md, artifact-management.md

## Executive Summary

- The `.claude/CLAUDE.md` changes removed `slide-planner-agent` and `skill-slide-planning` from documentation tables, removed the PostToolUse Hooks section, and updated the Present Extension routing -- but the files themselves (`slide-planner-agent.md`, `skill-slide-planning/SKILL.md`) still exist on disk and are still tracked in git, `extensions.json`, and `index.json`.
- Three `docs/` files still reference `skill-slide-planning` and need updating: `docs/agent-system/commands.md`, `docs/agent-system/README.md`, and `docs/workflows/grant-development.md`.
- The `git-workflow.md` change re-added `Co-Authored-By` trailers to the commit format and examples, which conflicts with the documented user preference in `.claude/CLAUDE.md` (line 162) and the "Zed adaptations" section in `docs/agent-system/README.md` (line 70).
- Filetypes extension doc changes (conversion-tables, dependency-guide, tool-detection) and document-agent rewrite are self-contained within `.claude/` and do not create cross-reference issues in `docs/`.
- The `index.json` still contains 5 references to `slide-planner-agent` in `load_when.agents` arrays, and `skill-slides/SKILL.md` still references `skill-slide-planning` on line 22.

## Context & Scope

Task 60 audits documentation consistency after a batch of `.claude/` changes that were made directly (not through the task system). The changes span 10 files and cover four themes: (1) slide-planner de-documentation, (2) PostToolUse hooks removal from CLAUDE.md, (3) document-agent rewrite with pymupdf tooling, and (4) git-workflow Co-Authored-By re-addition.

This audit identifies every file outside the already-changed set that needs updating, plus internal inconsistencies within the changed files themselves.

## Findings

### Category 1: `slide-planner-agent` / `skill-slide-planning` References (still live)

The CLAUDE.md diff removed these from 3 tables (Skill-to-Agent, Agents, Present Extension Skill-Agent) and changed the Present Language Routing from `present:slides | slides | skill-slide-planning | skill-slides` to `present | slides | skill-slides | skill-slides`. However, multiple files still reference the removed items:

**Files needing updates (outside .claude/ already-changed set):**

| # | File | Line(s) | Issue | Action |
|---|------|---------|-------|--------|
| 1 | `docs/agent-system/commands.md` | 48 | References `skill-slide-planning` and `present:slides` routing for `/plan` | Remove or rewrite the Note paragraph to say `/plan` on slides tasks routes to `skill-slides` (matching new CLAUDE.md routing) |
| 2 | `docs/agent-system/README.md` | 59 | References `skill-slide-planning` in Extensions section | Remove "via `skill-slide-planning`" clause; simplify to just mention slides support |
| 3 | `docs/workflows/grant-development.md` | 80, 84 | References `skill-slide-planning` routing for `/plan` slides tasks | Remove or rewrite the Note and comment to match new routing |

**Files within .claude/ still referencing (potential inconsistencies):**

| # | File | Line(s) | Issue | Action |
|---|------|---------|-------|--------|
| 4 | `.claude/context/index.json` | 4067, 4104, 4139, 4201, 4379 | 5 entries still list `slide-planner-agent` in `load_when.agents` arrays | Remove `slide-planner-agent` from these agent arrays if the agent is no longer documented |
| 5 | `.claude/context/index.json.backup` | 4071, 4107, 4139, 4201, 4380 | Same 5 references as above | Update backup to match |
| 6 | `.claude/skills/skill-slides/SKILL.md` | 22 | Note says "Plan workflow (`/plan present:slides`) is handled by `skill-slide-planning`, not this skill" | Update to reflect that `skill-slides` now handles plan routing, or remove the note |
| 7 | `.claude/extensions.json` | ~181 | Still lists `slide-planner-agent.md` in present extension `installed_files` | This is accurate (file exists), but if the intent is to remove the agent, the file and reference should both be removed |

**Decision needed**: The agent file `.claude/agents/slide-planner-agent.md` and skill `.claude/skills/skill-slide-planning/SKILL.md` still exist on disk. The task description says "removed" but they were only removed from the CLAUDE.md documentation tables, not from the filesystem. The implementation plan should clarify whether to:
- (a) Delete the files entirely and remove all references, or
- (b) Keep the files but ensure documentation is consistent about them being undocumented/deprecated

### Category 2: PostToolUse Hooks Section Removal

The CLAUDE.md diff removed the "### Hooks" subsection under "Rules References" that documented `validate-plan-write.sh`. The hook itself still exists in `settings.json` (line 48-63) and the file `.claude/hooks/validate-plan-write.sh` still exists.

**Files referencing PostToolUse (outside the changed set):**

| # | File | Line(s) | Issue | Action |
|---|------|---------|-------|--------|
| 8 | `.claude/commands/research.md` | 43 | References "A PostToolUse hook monitors all Write/Edit operations" | Remove or soften the PostToolUse reference; the hook still exists in settings.json but is no longer documented in CLAUDE.md |
| 9 | `.claude/commands/plan.md` | 38 | Same reference as research.md | Same action |
| 10 | `.claude/commands/implement.md` | 37 | Same reference as research.md | Same action |

**Note**: The hook itself (`settings.json` + `validate-plan-write.sh`) was NOT removed -- only the CLAUDE.md documentation of it was removed. The commands still reference it as a reason for the "do not write artifacts directly" rule. These references may be fine to keep since they describe behavior that still exists, even if CLAUDE.md no longer documents it.

### Category 3: `git-workflow.md` Co-Authored-By Conflict

The diff re-added `Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>` to:
- The commit format template (line 95)
- Three example commit blocks (lines 124, 132, 140)

This directly conflicts with:

| # | File | Line | Content |
|---|------|------|---------|
| 11 | `.claude/CLAUDE.md` | 162 | `**Note**: Per user preference (see ~/.claude/projects/.../feedback_no_coauthored_by.md), omit Co-Authored-By trailers from all commits.` |
| 12 | `docs/agent-system/README.md` | 70 | `**No Co-Authored-By trailer** -- Git commits in this workspace omit the Co-Authored-By line per user preference.` |
| 13 | `docs/agent-system/architecture.md` | 83 | `This workspace omits the Co-Authored-By trailer per user preference` |

**Decision needed**: Either:
- (a) The git-workflow.md change was intentional and the preference note in CLAUDE.md and docs should be removed, or
- (b) The git-workflow.md change was a regression from upstream sync and should be reverted to match the workspace preference

The CLAUDE.md note was NOT changed in this diff (it still says "omit"), so the git-workflow.md change appears to be an upstream sync that introduced a conflict with the workspace-specific preference.

### Category 4: `agents/README.md` Changes

The diff removed:
- The `slide-planner-agent.md` row from the table
- The sentence "Extension-specific agents (epi, filetypes, latex, python, typst, present) are documented in their respective CLAUDE.md extension sections."

No other documentation files reference the README table structure, so this is self-contained.

### Category 5: document-agent.md Rewrite

The rewrite updates the conversion table to add pymupdf as primary PDF tool and adds EPUB support. This is consistent with the filetypes context file changes (conversion-tables.md, dependency-guide.md, tool-detection.md). No external docs reference the document-agent conversion table directly.

### Category 6: `extensions.json` Restructure

The change reorders JSON keys within each extension object (moving `installed_dirs`, `source_dir`, `status`, `loaded_at`, `data_skeleton_files` to different positions). This is a non-functional restructuring. The `version` key moved from top-level to bottom. No documentation references the internal structure of `extensions.json`.

### Category 7: `index.json` Restructure

The diff is large (2586+ lines changed) but appears to be primarily structural reorganization. The 5 `slide-planner-agent` references identified above are the only cross-reference concern.

## Decisions

- The research identifies 13 specific documentation items needing attention across 10 files.
- Items are grouped into 3 priority tiers: (1) docs/ files with stale skill references, (2) internal .claude/ consistency issues, (3) Co-Authored-By conflict resolution requiring user input.

## Recommendations

### Priority 1 -- docs/ Updates (3 files, no ambiguity)

1. **`docs/agent-system/commands.md` line 48**: Remove the `skill-slide-planning` routing note for `/plan` on slides tasks
2. **`docs/agent-system/README.md` line 59**: Remove `skill-slide-planning` reference from Present extension description
3. **`docs/workflows/grant-development.md` lines 80, 84**: Remove `skill-slide-planning` references

### Priority 2 -- .claude/ Internal Consistency (4 files, may require user decision)

4. **`.claude/context/index.json`**: Remove `slide-planner-agent` from 5 `load_when.agents` arrays (if agent is being de-documented)
5. **`.claude/skills/skill-slides/SKILL.md` line 22**: Update or remove the note about `skill-slide-planning` handling plan workflow
6. **`.claude/commands/{research,plan,implement}.md`**: Optionally soften PostToolUse references (low priority -- the hook still exists, just undocumented)

### Priority 3 -- Co-Authored-By Conflict (requires user decision)

7. **Resolve conflict between `git-workflow.md` (now has Co-Authored-By) and `CLAUDE.md` + `docs/` (says omit Co-Authored-By)**. User must decide which is correct.

## Risks & Mitigations

- **Risk**: Removing `slide-planner-agent` from `index.json` while the file still exists could cause routing confusion if someone tries to use `/plan` on a slides task.
  - **Mitigation**: The plan phase should verify whether `skill-slide-planning` is truly deprecated or just undocumented, and handle accordingly.

- **Risk**: The Co-Authored-By conflict could cause inconsistent commit behavior depending on which file an agent reads first.
  - **Mitigation**: Resolve in the plan phase with explicit user confirmation on the preferred behavior.

## Appendix

### Search Queries Used
- `git diff --stat .claude/` -- identify changed files
- `git diff .claude/{file}` -- examine each change in detail
- `grep -r "slide-planner-agent"` -- 60+ matches across codebase (most in archived specs)
- `grep -r "skill-slide-planning"` -- 15 files with matches
- `grep -r "PostToolUse\|validate-plan-write"` -- 18 files with matches
- `grep -r "Co-Authored-By"` in docs/ -- 2 files with omit preference
- `grep -r "present:slides"` -- extensive matches, CLAUDE.md already updated

### Files Already Changed (in the diff)
1. `.claude/CLAUDE.md` -- Removed slide-planner, hooks section, updated routing
2. `.claude/agents/README.md` -- Removed slide-planner row and extension note
3. `.claude/agents/document-agent.md` -- Rewritten with pymupdf tooling
4. `.claude/context/index.json` -- Restructured (still has slide-planner refs)
5. `.claude/context/index.json.backup` -- Restructured
6. `.claude/context/project/filetypes/domain/conversion-tables.md` -- pymupdf added
7. `.claude/context/project/filetypes/tools/dependency-guide.md` -- pymupdf added
8. `.claude/context/project/filetypes/tools/tool-detection.md` -- pymupdf added
9. `.claude/extensions.json` -- Key reordering
10. `.claude/rules/git-workflow.md` -- Co-Authored-By re-added
