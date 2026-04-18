# Implementation Plan: Update Claude Code Documentation (v2)

- **Task**: 75 - Review recent changes and update Claude Code documentation
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: specs/075_review_changes_update_claude_docs/reports/02_review-new-changes.md
- **Artifacts**: plans/02_update-docs-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The previous implementation committed the bulk of the 35-file changeset identified in round 1 research. Only 6 files remain modified (3 `.claude/` files with substantive or cosmetic changes, 3 operational files). Two broken cross-references to the deleted `.claude/README.md` persist in `meta-guide.md` and `creating-commands.md`, and four files still contain neovim/loader-specific content that should be generalized for the zed repository. This plan addresses these remaining items and stages everything for a final commit.

### Research Integration

Research report (02_review-new-changes.md) confirmed the unstaged diff is now only 6 files. The CLAUDE.md changes are correct (duplicate header fixed, README refs updated, root README added to imports). The `index.json` and `extensions.json` changes are purely cosmetic key reordering with zero semantic impact. Two broken `.claude/README.md` references remain. Four files contain neovim-specific content needing generalization.

### Prior Plan Reference

Plan v1 (01_update-docs-plan.md) had 3 phases totaling 1.5 hours. Phase 1 (broken references + duplicate header) is partially done -- CLAUDE.md and core-index-entries refs are fixed, but 2 README.md refs remain. Phase 2 (neovim cleanup) is entirely unaddressed. Phase 3 (index coverage + staging) is mostly done since the prior implementation committed the new files and index entries. This v2 plan focuses only on what remains.

### Roadmap Alignment

No ROADMAP.md items. The roadmap is empty.

## Goals & Non-Goals

**Goals**:
- Fix the 2 remaining broken cross-references to deleted `.claude/README.md`
- Generalize neovim/loader-specific content in 4 files for the zed repository context
- Commit the current `.claude/` file changes (CLAUDE.md fixes, index.json/extensions.json normalization)

**Non-Goals**:
- Rewriting extension architecture documentation (already updated)
- Modifying extension system code
- Changing neovim references within extension-specific context files (those are domain-appropriate)
- Reverting the cosmetic key reordering in index.json/extensions.json

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Generalizing neovim content too aggressively removes useful architectural context | M | L | Keep the two-layer concept but describe generically; only remove content explicitly about neovim Lua loader |
| Missing additional broken references beyond the 2 identified | L | L | Run a final grep sweep after edits to confirm zero remaining broken refs |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Fix Remaining Broken Cross-References [NOT STARTED]

**Goal**: Update the 2 remaining references to deleted `.claude/README.md` to point to `.claude/docs/README.md`.

**Tasks**:
- [ ] Update `.claude/docs/guides/creating-commands.md` line 143: change `.claude/README.md` to `.claude/docs/README.md`
- [ ] Update `.claude/context/meta/meta-guide.md` line 450: change `.claude/README.md` references to `.claude/docs/README.md`
- [ ] Verify with grep that no broken `.claude/README.md` references remain (excluding `docs/README.md` and extension READMEs)

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:
- `.claude/docs/guides/creating-commands.md` - Fix README.md cross-reference
- `.claude/context/meta/meta-guide.md` - Fix README.md cross-references

**Verification**:
- `grep -rn "\.claude/README\.md" .claude/` returns only references to `docs/README.md` or extension-specific READMEs
- No broken links in documentation

---

### Phase 2: Generalize Neovim-Specific Content [NOT STARTED]

**Goal**: Replace neovim/Lua loader-specific content with generic extension system descriptions appropriate for the zed repository.

**Tasks**:
- [ ] `.claude/context/repo/project-overview.md` lines 11-12: Replace "Neovim Lua loader" description with a generic description of the extension loading mechanism; remove `lua/neotex/plugins/ai/shared/extensions/` path and `<leader>ac` keybinding reference
- [ ] `.claude/context/guides/extension-development.md` line 11: Replace neovim-specific loader paragraph (about "Neovim Lua loader (Layer 1)", `generate_claudemd()`) with a generic description of how extensions are loaded into the `.claude/` runtime
- [ ] `.claude/context/architecture/system-overview.md` line 387: Replace "neovim" with more generic extension examples relevant to the zed context
- [ ] `.claude/templates/claudemd-header.md`: Change `<!-- Generated by: neotex extension loader -->` to `<!-- Generated by: extension loader -->`
- [ ] Verify with grep that no neovim-specific references remain in context/docs files (excluding extension-domain-appropriate references)

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `.claude/context/repo/project-overview.md` - Generalize Layer 1 description
- `.claude/context/guides/extension-development.md` - Remove neovim loader paragraph
- `.claude/context/architecture/system-overview.md` - Replace neovim example
- `.claude/templates/claudemd-header.md` - Generalize HTML comment

**Verification**:
- `grep -ri "neovim\|nvim\|lua loader\|neotex" .claude/context/ .claude/docs/ .claude/templates/` returns no results outside of extension-specific domain content
- Documentation reads coherently as a standalone Claude Code agent system reference

---

### Phase 3: Stage and Commit All Changes [NOT STARTED]

**Goal**: Stage the already-correct `.claude/` file changes plus the Phase 1 and 2 edits, and commit with a descriptive message.

**Tasks**:
- [ ] Review `git status` to confirm all changes are accounted for
- [ ] Stage `.claude/CLAUDE.md`, `.claude/context/index.json`, `.claude/extensions.json` (existing substantive + cosmetic changes)
- [ ] Stage all files modified in Phases 1 and 2
- [ ] Commit with message: `task 75: update documentation and fix cross-references`

**Timing**: 15 minutes

**Depends on**: 1, 2

**Files to modify**:
- Various `.claude/` files - Stage for commit

**Verification**:
- `git status` shows a clean working tree for `.claude/` files
- Commit message follows project conventions

## Testing & Validation

- [ ] `grep -rn "\.claude/README\.md" .claude/` returns no broken references (only `docs/README.md` or extension READMEs)
- [ ] `grep -ri "neovim\|nvim\|neotex" .claude/context/ .claude/docs/ .claude/templates/` returns no results outside extension-domain files
- [ ] `.claude/CLAUDE.md` contains exactly one level-1 heading
- [ ] All `.claude/` changes are committed

## Artifacts & Outputs

- `specs/075_review_changes_update_claude_docs/plans/02_update-docs-plan.md` (this plan)
- Updated `.claude/docs/guides/creating-commands.md` with fixed reference
- Updated `.claude/context/meta/meta-guide.md` with fixed references
- Generalized content in 4 context/template files
- Clean commit of all documentation changes

## Rollback/Contingency

All changes are documentation-only edits to `.claude/` files. If any change breaks agent behavior, revert with `git checkout -- .claude/` to restore the pre-implementation state. The research reports preserve a complete inventory of changes for reference.
