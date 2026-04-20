# Implementation Plan: Update Docs from Claude Diff

- **Task**: 32 - update_docs_from_claude_diff
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: None
- **Research Inputs**: specs/032_update_docs_from_claude_diff/reports/01_team-research.md
- **Artifacts**: plans/01_update-docs-config.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Documentation across .claude/ and root docs/ contains stale references to the removed Python extension, the renamed talk-agent (now slides-agent), and an orphaned task_type in state.json that will break routing. This plan updates 15+ files to reflect current reality: removing Python references, replacing Python-based examples with Rust, migrating Task 29's task_type, and deleting a contradictory memory file. Definition of done: no file references deleted Python skills/agents/context, Task 29 routes correctly, and all guide examples use a non-active extension (Rust) that will not go stale.

### Research Integration

Team research (4 teammates) catalogued 15 files with stale references across 3 priority tiers. Critical findings include Task 29's orphaned `present:talk` task_type and python routing to deleted skills. The replacement strategy (Python examples -> Rust examples) and user-decision items (project identity breadcrumbs, `<leader>ac` references) were identified and confirmed.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items to advance (roadmap is placeholder only).

## Goals & Non-Goals

**Goals**:
- Fix Task 29 task_type so `/slides 29` routes correctly
- Remove all Python extension references from routing, README, and docs
- Replace Python-based examples in 6 guide files with Rust equivalents
- Delete stale memory file that contradicts current state
- Documentation describes current reality without mentioning what changed

**Non-Goals**:
- Rewriting project-overview.md (user already did this intentionally)
- Deciding the Neovim/Zed project identity question (flag for user, do not resolve)
- Adding new documentation for lean MCP scripts or extension agents
- Modifying CLAUDE.md.backup (separate cleanup concern)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task 29 migration breaks ongoing work | H | L | Check Task 29 status; migration is a single-field change in state.json |
| Rust examples become stale if Rust extension is added later | M | L | Rust is not planned; if added, examples still illustrate the pattern correctly |
| User disagrees with breadcrumb/keybinding decisions | M | M | Flag items explicitly for user decision rather than changing unilaterally |
| Missing a stale reference | L | M | Use grep to verify no python/talk-agent references remain after each phase |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Critical Functional Fixes [COMPLETED]

**Goal**: Fix routing breakage and remove references to deleted skills

**Tasks**:
- [ ] Migrate Task 29 `task_type` from `present:talk` to `slides` in `specs/state.json`
- [ ] Update Task 29 entry in `specs/TODO.md` if task_type is visible there
- [ ] Remove the `python` row from `.claude/context/routing.md`
- [ ] Remove the `python` row from `.claude/README.md` extensions table
- [ ] Delete stale memory file `~/.claude/projects/-home-benjamin--config-zed/memory/project_python_extension_loaded.md`
- [ ] Update `~/.claude/projects/-home-benjamin--config-zed/memory/MEMORY.md` to remove the python entry
- [ ] Verify: grep for `present:talk` in state.json returns zero matches
- [ ] Verify: grep for `skill-python` in routing.md returns zero matches

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `specs/state.json` - Change task 29 task_type field
- `specs/TODO.md` - Update task 29 if task_type is shown
- `.claude/context/routing.md` - Remove python row
- `.claude/README.md` - Remove python from extensions table
- `~/.claude/projects/-home-benjamin--config-zed/memory/project_python_extension_loaded.md` - Delete
- `~/.claude/projects/-home-benjamin--config-zed/memory/MEMORY.md` - Remove python entry

**Verification**:
- `grep -r "present:talk" specs/state.json` returns nothing
- `grep -r "skill-python" .claude/context/routing.md` returns nothing
- `grep -r "python" .claude/README.md` returns no extension-table hits

---

### Phase 2: High-Priority Documentation Accuracy [COMPLETED]

**Goal**: Remove Python references from root docs/ and fix active documentation that misleads users

**Tasks**:
- [ ] Remove the `## python` section from `docs/toolchain/extensions.md`
- [ ] Remove Python references from `docs/agent-system/architecture.md` (extension list and routing table)
- [ ] Flag `docs/README.md` breadcrumbs ("Neovim Configuration") for user decision -- add a brief comment or note in the plan summary rather than changing unilaterally
- [ ] Verify: grep for `python` in `docs/toolchain/extensions.md` returns zero matches
- [ ] Verify: grep for `python` in `docs/agent-system/architecture.md` returns zero matches

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `docs/toolchain/extensions.md` - Remove python section
- `docs/agent-system/architecture.md` - Remove python from routing/extension tables

**Verification**:
- `grep -ri "python" docs/toolchain/extensions.md` returns nothing
- `grep -ri "skill-python\|python-research-agent\|python-implementation-agent" docs/agent-system/architecture.md` returns nothing

---

### Phase 3: Guide Example Replacement [COMPLETED]

**Goal**: Replace Python-based examples in 6 guide/architecture files with Rust equivalents

**Tasks**:
- [ ] `.claude/docs/guides/creating-skills.md` - Replace 4 Python example spots with Rust equivalents (skill-python-research -> skill-rust-research pattern, python-research-agent -> rust-research-agent pattern, deleted context path -> hypothetical rust path)
- [ ] `.claude/docs/guides/component-selection.md` - Replace 3 Python spots: skill name example, flow diagram, "Adding Python Support" example
- [ ] `.claude/docs/architecture/system-overview.md` - Replace "Adding New Language Support" Python example with Rust
- [ ] `.claude/context/architecture/component-checklist.md` - Replace "Pattern 2: New Language Support" Python example with Rust
- [ ] `.claude/docs/guides/creating-agents.md` - Replace JSON example `"language": "python"` with `"language": "rust"` and remove/replace context table row for python
- [ ] `.claude/docs/guides/adding-domains.md` - Replace python in decision tree example with rust
- [ ] `.claude/docs/guides/creating-extensions.md` - Verify no stale python references remain; fix if found
- [ ] Verify: grep for `python` across all modified guide files returns zero matches (excluding any legitimate generic mentions of "python" as a language name in non-example context)

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `.claude/docs/guides/creating-skills.md` - Replace python examples (4 spots)
- `.claude/docs/guides/component-selection.md` - Replace python examples (3 spots)
- `.claude/docs/architecture/system-overview.md` - Replace python example
- `.claude/context/architecture/component-checklist.md` - Replace python example
- `.claude/docs/guides/creating-agents.md` - Replace python examples (2 spots)
- `.claude/docs/guides/adding-domains.md` - Replace python example

**Verification**:
- `grep -rn "skill-python\|python-research-agent\|python-implementation-agent" .claude/docs/ .claude/context/architecture/` returns nothing
- Each replaced example compiles logically (rust-research-agent, skill-rust-research, etc. follow naming conventions)

---

### Phase 4: Final Sweep and Verification [COMPLETED]

**Goal**: Confirm all stale references are eliminated and document user-decision items

**Tasks**:
- [ ] Run comprehensive grep for `skill-python`, `python-research-agent`, `python-implementation-agent`, `present:talk`, `talk-agent`, `skill-talk` across entire `.claude/` directory and `docs/` directory
- [ ] Fix any remaining hits found by the sweep
- [ ] Document user-decision items in the implementation summary: (a) Neovim/Zed breadcrumbs in docs/README.md, (b) `<leader>ac` references in guide files
- [ ] Verify `specs/state.json` is valid JSON after Task 29 migration

**Timing**: 30 minutes

**Depends on**: 2, 3

**Files to modify**:
- Any files with remaining stale references found during sweep

**Verification**:
- Zero hits for `skill-python`, `python-research-agent`, `python-implementation-agent` across .claude/ and docs/
- Zero hits for `present:talk` across specs/
- Zero hits for `talk-agent` or `skill-talk` in active config files (archived specs excluded)
- `jq '.' specs/state.json` succeeds (valid JSON)

## Testing & Validation

- [ ] `grep -rn "skill-python" .claude/ docs/` returns zero results
- [ ] `grep -rn "python-research-agent\|python-implementation-agent" .claude/ docs/` returns zero results
- [ ] `grep -rn "present:talk" specs/state.json` returns zero results
- [ ] `grep -rn "skill-talk" .claude/` returns zero results (excluding archive)
- [ ] `jq '.active_projects[] | select(.project_number == 29) | .task_type' specs/state.json` returns `"slides"`
- [ ] Memory file `~/.claude/projects/-home-benjamin--config-zed/memory/project_python_extension_loaded.md` does not exist
- [ ] All Rust replacement examples follow consistent naming: `skill-rust-research`, `rust-research-agent`, `project/rust/` paths

## Artifacts & Outputs

- `specs/032_update_docs_from_claude_diff/plans/01_update-docs-config.md` (this plan)
- `specs/032_update_docs_from_claude_diff/summaries/01_update-docs-config-summary.md` (after implementation)
- 15+ modified documentation files across `.claude/`, `docs/`, and `specs/`

## Rollback/Contingency

All changes are documentation-only edits (no code). Git revert of the implementation commit(s) fully restores prior state. The Task 29 task_type migration is the only functional change; if it causes issues, revert the single field in state.json from `slides` back to `present:talk`.
