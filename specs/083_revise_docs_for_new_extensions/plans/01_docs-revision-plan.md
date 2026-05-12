# Implementation Plan: Revise Documentation for New Extensions

- **Task**: 83 - revise_docs_for_new_extensions
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/083_revise_docs_for_new_extensions/reports/01_team-research.md
- **Artifacts**: plans/01_docs-revision-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

The documentation across `docs/` and `README.md` is factually stale following the removal of the `.opencode/` directory (423 files deleted) and the addition of the `web` extension. Four-teammate research identified five priority tiers of issues: pervasive OpenCode references in a system that no longer exists, the completely undocumented `web` extension, missing `/sheet` command documentation, 30+ broken links, and incorrect counts. This plan revises all documentation to reflect the single-system (Claude Code + Zed Agent Panel) reality and adds coverage for the `web` extension. Done when all docs accurately describe the current system with no broken links, no OpenCode references, correct extension count (10), and balanced coverage of all extensions.

### Research Integration

The team research report (4 teammates, all high confidence) provided a prioritized list of issues with specific file locations and line references. All five priority tiers are addressed in this plan. Key findings integrated:
- OpenCode removal requires changes in 8+ files across docs/ and README.md
- Web extension needs additions to the feature matrix, README, and toolchain docs
- `/sheet` command and `/project-overview` command documentation needs corrections
- Extension count must change from "9" to "10" in at least 8 locations
- Python/R doc path references use wrong directory (`general/` instead of `toolchain/`)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items to advance (roadmap is empty).

## Goals & Non-Goals

**Goals**:
- Remove all OpenCode references and rewrite dual-system language to single-system
- Delete `docs/agent-system/opencode.md`
- Add web extension to the feature matrix, README, and toolchain docs
- Fix extension count from "9" to "10" everywhere
- Add `/sheet` command to commands.md and README.md
- Fix `/project-overview` attribution (remove OC-only label)
- Remove `/deck` command (OC-only, no longer available)
- Fix all broken `.opencode/` links and wrong doc paths
- Fix factual errors (e.g., "No `.claude/extensions/` directory" claim)
- Update `edit-spreadsheets.md` to feature `/sheet` as primary interface

**Non-Goals**:
- Creating new workflow guides (e.g., web-development.md) -- can be a follow-up task
- Restructuring docs/ directory layout
- Rewriting content that is accurate but merely verbose
- Adding extension context files or modifying `.claude/` system internals

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Missed OpenCode reference in a file not identified by research | M | M | Grep for "opencode", "OpenCode", ".opencode", "OC_", "OC only" across all docs after edits |
| Incorrect extension count after edits | L | L | Verify count against `ls .claude/extensions/` output |
| Broken internal cross-references between docs | M | L | Check all `](` link targets in modified files after Phase 4 |
| Over-editing stable content | M | L | Limit changes to factual corrections; preserve structure and voice |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Remove OpenCode References and Delete opencode.md [NOT STARTED]

**Goal**: Eliminate all OpenCode/dual-system language from documentation, establishing the single-system baseline that subsequent phases build on.

**Tasks**:
- [ ] Delete `docs/agent-system/opencode.md`
- [ ] Edit `README.md`: remove OpenCode as "parallel AI assistant", remove `.opencode/` from directory tree, remove dual-system language, remove "OC_" prefix documentation
- [ ] Edit `docs/README.md`: remove OpenCode cross-references, remove broken `.opencode/docs/README.md` link
- [ ] Edit `docs/agent-system/README.md`: rewrite from "two AI agent systems" to single-system, remove OpenCode as "second AI agent system", remove `.opencode/AGENTS.md` link, remove "OC_" prefix references
- [ ] Edit `docs/agent-system/architecture.md`: remove dual-system architecture sections, simplify to Claude Code + Zed Agent Panel
- [ ] Edit `docs/agent-system/commands.md`: remove all "OC only" labels, remove all "CC only" labels, remove broken `.opencode/` links, remove `/deck` command entry, fix `/project-overview` to remove OC-only attribution
- [ ] Edit `docs/agent-system/extensions.md`: remove CC/OC version split columns, simplify to single version column
- [ ] Edit `docs/agent-system/context-and-memory.md`: remove OpenCode shared-state descriptions, remove `.opencode/` path references
- [ ] Edit `docs/agent-system/zed-agent-panel.md`: remove any OpenCode comparison language

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `docs/agent-system/opencode.md` - delete entirely
- `README.md` - remove OpenCode references
- `docs/README.md` - remove OpenCode links
- `docs/agent-system/README.md` - rewrite to single-system
- `docs/agent-system/architecture.md` - remove dual-system sections
- `docs/agent-system/commands.md` - remove OC labels and links
- `docs/agent-system/extensions.md` - simplify version table
- `docs/agent-system/context-and-memory.md` - remove OpenCode state refs
- `docs/agent-system/zed-agent-panel.md` - clean up comparisons

**Verification**:
- `grep -ri "opencode\|\.opencode\|OC only\|OC_\|CC only" docs/ README.md` returns zero matches
- `docs/agent-system/opencode.md` no longer exists
- No remaining references to `/deck` command

---

### Phase 2: Add Web Extension Documentation [NOT STARTED]

**Goal**: Add the `web` extension to the feature matrix, README, and toolchain prerequisites so it has equivalent coverage to other extensions.

**Tasks**:
- [ ] Add `web` row to the extension feature matrix in `docs/agent-system/extensions.md` with: Astro/Tailwind/TypeScript, 2 agents, 2 skills, 1 rule, rich context
- [ ] Add web development mention to `README.md` extension list and capabilities
- [ ] Add `web` section to `docs/toolchain/extensions.md` covering prerequisites (pnpm, Node.js) and build commands
- [ ] Mention `web` extension alongside `python` in any lists where extensions with agent routing are enumerated

**Timing**: 45 minutes

**Depends on**: 1

**Files to modify**:
- `docs/agent-system/extensions.md` - add web row to feature matrix
- `README.md` - add web to extension mentions
- `docs/toolchain/extensions.md` - add web prerequisites section

**Verification**:
- `grep -i "web" docs/agent-system/extensions.md` shows web extension entry
- `docs/toolchain/extensions.md` has a "Web" or "Astro" section with pnpm/Node.js prereqs
- README mentions web alongside other extensions

---

### Phase 3: Fix Commands and Spreadsheet Docs [NOT STARTED]

**Goal**: Add missing `/sheet` command documentation, fix `/project-overview` attribution, and update the spreadsheet workflow guide.

**Tasks**:
- [ ] Add `/sheet` to `docs/agent-system/commands.md` under the Documents section with usage and description
- [ ] Add `/sheet` to `README.md` Document Tools table
- [ ] Update `docs/workflows/edit-spreadsheets.md` to feature `/sheet` as the primary structured interface, with raw MCP as fallback
- [ ] Fix `/project-overview` in `docs/agent-system/commands.md`: remove "(OC only)" label, update link from `.opencode/` to `.claude/` path

**Timing**: 30 minutes

**Depends on**: 1

**Files to modify**:
- `docs/agent-system/commands.md` - add /sheet, fix /project-overview
- `README.md` - add /sheet to table
- `docs/workflows/edit-spreadsheets.md` - rewrite to feature /sheet

**Verification**:
- `grep "/sheet" docs/agent-system/commands.md` returns match
- `grep "/sheet" README.md` returns match
- `docs/workflows/edit-spreadsheets.md` mentions `/sheet` as primary interface
- No "(OC only)" label remains on `/project-overview`

---

### Phase 4: Fix Counts, Broken Links, and Factual Errors [NOT STARTED]

**Goal**: Correct the extension count everywhere, fix all broken cross-reference links, and correct factual claims.

**Tasks**:
- [ ] Change "9 extensions" to "10 extensions" in all files (README.md, docs/README.md, docs/agent-system/README.md, docs/agent-system/extensions.md, and any others found via grep)
- [ ] Fix Python/R doc paths in `docs/README.md`: `general/python.md` -> `toolchain/python.md`, `general/R.md` -> `toolchain/r.md`
- [ ] Fix Python/R doc paths in `docs/workflows/README.md`: `../general/python.md` -> `../toolchain/python.md`, `../general/R.md` -> `../toolchain/r.md`
- [ ] Fix R doc path in `docs/agent-system/README.md`: `../general/R.md` -> `../toolchain/r.md`
- [ ] Fix factual error in `docs/agent-system/README.md` line ~73: remove or correct "No `.claude/extensions/` directory" claim
- [ ] Verify no remaining broken links to `.opencode/` paths (should be covered by Phase 1, but double-check)

**Timing**: 30 minutes

**Depends on**: 2, 3

**Files to modify**:
- `README.md` - fix extension count
- `docs/README.md` - fix count and Python/R paths
- `docs/agent-system/README.md` - fix count, R path, extensions directory claim
- `docs/agent-system/extensions.md` - fix count
- `docs/workflows/README.md` - fix Python/R paths

**Verification**:
- `grep -r "9 extensions" docs/ README.md` returns zero matches
- `grep -r "general/python\|general/R\|general/r" docs/` returns zero matches
- `grep -r "\.opencode/" docs/ README.md` returns zero matches
- `grep "No.*\.claude/extensions" docs/agent-system/README.md` returns zero matches

---

### Phase 5: Final Validation and Polish [NOT STARTED]

**Goal**: Comprehensive validation sweep and minor polish for balance and clarity.

**Tasks**:
- [ ] Run full grep sweep: `grep -ri "opencode\|\.opencode\|OC only\|OC_\|CC only\|9 extension\|general/python\|general/R" docs/ README.md` -- should return zero
- [ ] Spot-check that `python` extension is mentioned in docs alongside other extensions with agent routing
- [ ] Review README.md for redundancy between "AI Integration" and "Agent Commands" sections; consolidate if overlap is significant
- [ ] Verify all internal markdown links in modified files resolve to existing targets
- [ ] Read through the modified sections for tone consistency, clarity, and balanced representation of extensions

**Timing**: 15 minutes

**Depends on**: 4

**Files to modify**:
- `README.md` - optional consolidation of redundant sections
- Any files with remaining issues found during sweep

**Verification**:
- Full grep sweep returns zero stale references
- Manual review confirms docs read coherently as a single-system description
- No broken internal cross-references remain

## Testing & Validation

- [ ] `grep -ri "opencode\|\.opencode\|OC only\|OC_\|CC only" docs/ README.md` returns zero matches
- [ ] `grep -r "9 extension" docs/ README.md` returns zero matches
- [ ] `grep -r "general/python\|general/R\|general/r\.md" docs/` returns zero matches
- [ ] `grep -r "\.opencode/" docs/ README.md` returns zero matches
- [ ] `docs/agent-system/opencode.md` does not exist
- [ ] `docs/agent-system/extensions.md` contains a `web` row in the feature matrix
- [ ] `docs/agent-system/commands.md` contains `/sheet` entry
- [ ] `docs/toolchain/extensions.md` contains web prerequisites section
- [ ] Extension count reads "10" in all locations
- [ ] All internal markdown links resolve to existing files

## Artifacts & Outputs

- `specs/083_revise_docs_for_new_extensions/plans/01_docs-revision-plan.md` (this plan)
- Modified documentation files (~12 files across docs/ and README.md)
- Deleted file: `docs/agent-system/opencode.md`

## Rollback/Contingency

All changes are to tracked markdown files. If the revision introduces errors:
1. Use `git diff` to review all changes
2. Use `git checkout -- <file>` to revert individual files
3. Use `git stash` to save partial progress if needed
4. The research report remains available for re-planning if the approach needs adjustment
