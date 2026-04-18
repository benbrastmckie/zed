# Implementation Plan: Update Claude Code Documentation

- **Task**: 75 - Review recent changes and update Claude Code documentation
- **Status**: [NOT STARTED]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/075_review_changes_update_claude_docs/reports/01_review-changes-docs.md
- **Artifacts**: plans/01_update-docs-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The working tree contains 35 changed files and 8 new untracked files reflecting a major extension system architecture overhaul. The documentation already updated in the diff is largely self-consistent, but several cross-references point to deleted files (`.claude/README.md`, `core-index-entries.json`), the generated CLAUDE.md has a duplicate header, and new untracked files need to be properly indexed. This plan fixes broken references, deduplicates the CLAUDE.md header, verifies index coverage for new files, removes neovim/nixos-specific content from zed-scoped docs, and stages all changes for a coherent commit.

### Research Integration

Research report (01_review-changes-docs.md) identified 9 categories of changes. Categories 1-2 (extension architecture overhaul, systematic rename) are already applied. The actionable items are: broken cross-references to deleted files (Priority 3 items 1-2), duplicate CLAUDE.md header (Priority 3 item 4), new untracked files needing staging (Priority 3 item 3), and neovim/loader-specific content that should be removed or generalized for the zed repository context.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No actionable ROADMAP.md items. The roadmap is empty.

## Goals & Non-Goals

**Goals**:
- Fix all broken cross-references to deleted `.claude/README.md`
- Fix all broken cross-references to deleted `core-index-entries.json`
- Fix the duplicate "# Agent System" header in CLAUDE.md
- Remove or generalize neovim/nixos-specific content from zed-scoped documentation
- Verify new untracked files are properly indexed in `index.json`
- Stage all changes for a clean commit

**Non-Goals**:
- Documenting version differences or migration notes
- Adding neovim loader implementation details
- Rewriting extension architecture docs (already updated in diff)
- Modifying the extension system code itself

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Broken references missed during grep scan | M | L | Use comprehensive regex patterns covering @-references, markdown links, and plain-text mentions |
| Removing neovim content that is actually relevant to Claude Code | M | L | Only remove content explicitly about neovim/Lua loader; keep agent system concepts that apply universally |
| CLAUDE.md auto-generation header template produces duplicate on next regeneration | L | M | Fix the template source if it exists in the working tree, not just the generated output |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Fix Broken Cross-References and Duplicate Header [NOT STARTED]

**Goal**: Eliminate all broken references to deleted files and fix the duplicate CLAUDE.md header.

**Tasks**:
- [ ] Grep the entire `.claude/` tree for references to `.claude/README.md` (including `@.claude/README.md` patterns)
- [ ] Replace each broken README.md reference with the appropriate replacement (e.g., `docs/README.md`, `CLAUDE.md`, or remove the reference entirely)
- [ ] Grep for references to `core-index-entries.json` and update or remove them
- [ ] Fix the duplicate "# Agent System" header in `.claude/CLAUDE.md` -- the auto-generation notice line should replace, not precede, the original header
- [ ] Check the `claudemd-header.md` template to ensure it will not re-introduce the duplicate header on next generation

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `.claude/CLAUDE.md` - Remove duplicate header, fix README.md reference in Quick Reference section
- Any files referencing `.claude/README.md` - Update cross-references
- Any files referencing `core-index-entries.json` - Update or remove references

**Verification**:
- `grep -r "README.md" .claude/` returns no references to the deleted `.claude/README.md` (references to `docs/README.md` or extension READMEs are acceptable)
- `grep -r "core-index-entries" .claude/` returns zero results
- `.claude/CLAUDE.md` has exactly one `# Agent System` heading

---

### Phase 2: Remove Neovim/NixOS-Specific Content from Zed Documentation [NOT STARTED]

**Goal**: Ensure documentation within the zed repository describes the Claude agent system without referencing neovim, nixos, or the Lua-based loader.

**Tasks**:
- [ ] Review `.claude/context/repo/project-overview.md` for neovim/Lua loader references in the Two-Layer Architecture section; generalize or remove Layer 1 (neovim Lua loader) details, keeping only the Claude Code agent system description
- [ ] Review `.claude/docs/architecture/extension-system.md` for loader-specific implementation details (e.g., `generate_claudemd()`, `copy_context_dirs()`, Lua function signatures); generalize to describe behavior rather than implementation
- [ ] Review `.claude/context/guides/extension-development.md` for neovim-specific loader references; focus content on extension authoring for Claude Code
- [ ] Review `.claude/context/guides/loader-reference.md` -- determine if this file is relevant to the zed repo or should be excluded from the index
- [ ] Scan `.claude/docs/guides/creating-extensions.md` for any neovim-specific references

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `.claude/context/repo/project-overview.md` - Remove/generalize neovim Layer 1 references
- `.claude/docs/architecture/extension-system.md` - Generalize loader implementation details
- `.claude/context/guides/extension-development.md` - Remove neovim-specific loader references
- `.claude/context/guides/loader-reference.md` - Evaluate relevance; remove from index if neovim-specific
- `.claude/docs/guides/creating-extensions.md` - Fix any neovim-specific references

**Verification**:
- `grep -ri "neovim\|nvim\|lua loader\|Layer 1" .claude/` returns no results in context/docs files (exceptions: extension manifest fields that mention Lua as a language are acceptable)
- Documentation reads coherently as a standalone Claude Code agent system reference

---

### Phase 3: Verify Index Coverage and Stage All Changes [NOT STARTED]

**Goal**: Ensure new files are indexed and all changes are staged for commit.

**Tasks**:
- [ ] Check that `.claude/context/guides/loader-reference.md` has an entry in `index.json` (if retained after Phase 2)
- [ ] Check that `.claude/context/reference/team-wave-helpers.md` has an entry in `index.json`
- [ ] Check that `.claude/context/checkpoints/README.md` has an entry in `index.json` (or determine it does not need one)
- [ ] Check that `.claude/context/reference/README.md` has an entry in `index.json` (or determine it does not need one)
- [ ] Verify the 8 new untracked files are appropriate for the zed repo (remove any that are neovim-only artifacts)
- [ ] Review `git status` for any remaining unstaged changes
- [ ] Stage all relevant modified and new files

**Timing**: 30 minutes

**Depends on**: 1, 2

**Files to modify**:
- `.claude/context/index.json` - Add missing entries for new files if needed
- Various new untracked files - Stage for commit

**Verification**:
- `git status` shows all relevant changes staged
- No orphaned index entries pointing to non-existent files
- New context files that agents need are indexed with appropriate `load_when` conditions

## Testing & Validation

- [ ] `grep -r "\.claude/README\.md" .claude/` returns no broken references (only `docs/README.md` or extension READMEs)
- [ ] `grep -r "core-index-entries" .claude/` returns zero results
- [ ] `.claude/CLAUDE.md` contains exactly one level-1 heading
- [ ] `grep -ri "neovim\|nvim" .claude/context/ .claude/docs/` returns no results in documentation files
- [ ] `.claude/scripts/validate-context-index.sh` passes (if runnable)
- [ ] All 8 new untracked files are either staged or explicitly excluded

## Artifacts & Outputs

- `specs/075_review_changes_update_claude_docs/plans/01_update-docs-plan.md` (this plan)
- Updated `.claude/CLAUDE.md` with fixed header
- Updated cross-reference files (various)
- Cleaned documentation files (neovim references removed)
- Staged git changes ready for commit

## Rollback/Contingency

All changes are documentation-only edits to `.claude/` files. If any change breaks agent behavior, revert with `git checkout -- .claude/` to restore the pre-implementation state. The research report preserves a complete inventory of the original changes for reference.
