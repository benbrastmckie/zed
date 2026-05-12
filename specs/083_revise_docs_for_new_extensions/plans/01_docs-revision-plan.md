# Implementation Plan: Revise Documentation for New Extensions

- **Task**: 83 - revise_docs_for_new_extensions
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/083_revise_docs_for_new_extensions/reports/01_team-research.md
- **Artifacts**: plans/01_docs-revision-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown

## Overview

The documentation across `docs/` and `README.md` contains factual errors and incomplete coverage. Both Claude Code and OpenCode are active agent systems with the same 10 extensions, but documentation says "9 extensions" in multiple places, the `web` extension is undocumented, the `/sheet` command is missing from the command catalog, Python/R doc paths point to the wrong directory (`general/` instead of `toolchain/`), and a false claim states "No `.claude/extensions/` directory." Additionally, the existing `docs/agent-system/opencode.md` file was deleted from the working tree but should be restored and updated. A new `docs/ai_agent_systems.md` comparison doc is needed, and the README should briefly describe the install script's system choice and link to it. Done when all docs are accurate with correct extension count (10), web extension documented, `/sheet` in the command catalog, correct file paths, and a clear comparison doc for the two agent systems.

### Research Integration

The team research report (4 teammates, all high confidence) provided a prioritized list of issues with specific file locations and line references. Key findings that still apply:
- Web extension is completely undocumented -- needs feature matrix, README, and toolchain entries
- `/sheet` command is missing from `docs/agent-system/commands.md` and `README.md`
- Extension count reads "9" in at least 3 locations -- should be "10"
- Python/R doc paths use wrong directory (`general/` instead of `toolchain/`)
- False claim "No `.claude/extensions/` directory" in `docs/agent-system/README.md` -- the directory exists with 10 extensions
- `/project-overview` is misattributed as OC-only -- it exists in Claude Code too

### Prior Plan Reference

Original plan (v1) assumed OpenCode had been removed and focused on deleting all OpenCode references. That premise is now incorrect -- both agent systems are active. This revised plan preserves both systems and focuses on accuracy, the new comparison doc, and missing documentation.

### Roadmap Alignment

No ROADMAP.md items to advance (roadmap is empty).

## Goals & Non-Goals

**Goals**:
- Restore `docs/agent-system/opencode.md` (currently deleted from working tree) and update it for accuracy (10 extensions, add `/sheet` to command comparison)
- Create `docs/ai_agent_systems.md` -- comparison doc covering differences, subscription vs API pricing, and shared infrastructure
- Update `README.md` to briefly mention install script system choice (Claude Code, OpenCode, or both) and link to `docs/ai_agent_systems.md`
- Add web extension to the feature matrix in `docs/agent-system/extensions.md`, README, and toolchain docs
- Fix extension count from "9" to "10" everywhere
- Add `/sheet` command to `docs/agent-system/commands.md` and `README.md`
- Fix `/project-overview` attribution (available in both systems, not OC-only)
- Fix Python/R doc paths: `general/python.md` -> `toolchain/python.md`, `general/R.md` -> `toolchain/r.md`
- Fix false claim "No `.claude/extensions/` directory" in `docs/agent-system/README.md`
- Update `docs/workflows/edit-spreadsheets.md` to feature `/sheet` as the primary interface
- Improve documentation clarity and accuracy where relevant

**Non-Goals**:
- Creating new workflow guides (e.g., web-development.md) -- can be a follow-up task
- Restructuring the docs/ directory layout
- Rewriting content that is accurate but merely verbose
- Adding extension context files or modifying `.claude/` or `.opencode/` system internals
- Removing OpenCode references -- both systems are active and should be documented

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Incorrect extension count after edits | L | L | Verify count against `ls .claude/extensions/` and `ls .opencode/extensions/` output |
| Broken internal cross-references between docs | M | L | Check all `](` link targets in modified files during Phase 5 |
| Inaccurate pricing/subscription claims in comparison doc | M | M | Use hedged language ("at time of writing"), link to official pricing pages |
| Over-editing stable dual-system content | M | L | Limit changes to factual corrections and additions; preserve existing structure and voice |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 4 | 1 |
| 3 | 5 | 2, 3, 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Create AI Agent Systems Comparison Doc and Update README [COMPLETED]

**Goal**: Create the new `docs/ai_agent_systems.md` comparison document and update `README.md` to mention system choice and link to it. Also restore `docs/agent-system/opencode.md`.

**Tasks**:
- [x] Restore `docs/agent-system/opencode.md` from git (`git restore docs/agent-system/opencode.md`) and update it: change "9 extensions" to "10", add `/sheet` to the command comparison table, verify all links *(completed)*
- [x] Create `docs/ai_agent_systems.md` with the following sections *(completed)*
  - Overview of both systems (Claude Code and OpenCode) as parallel AI assistants
  - How to choose: the install script (`scripts/install/install.sh`) offers Claude Code, OpenCode, or both
  - Cost model comparison: Claude Code subscription (discounted if using Claude Code directly via Anthropic) vs OpenCode using API credits (pay-per-use)
  - Shared infrastructure: `specs/` task management, `.memory/` vault, 10 extensions, `docs/`
  - Differences: config directories (`.claude/` vs `.opencode/`), access methods (Ctrl+Shift+A vs terminal `opencode`), task prefix (`{NNN}_` vs `OC_{NNN}_`), exclusive commands
  - Link to detailed docs: `docs/agent-system/opencode.md`, `.claude/CLAUDE.md`, `.opencode/AGENTS.md`
- [x] Update `README.md` "Quick Start" section: add a sentence after the install script mention noting it lets you choose between Claude Code, OpenCode, or both, with a link to `docs/ai_agent_systems.md` *(completed)*
- [x] Update `README.md` "AI Integration" section: fix "9 extensions" to "10 extensions" in the OpenCode description, add link to `docs/ai_agent_systems.md` for detailed comparison *(completed)*
- [x] Update `README.md` "Documentation" table: add entry for `docs/ai_agent_systems.md` *(completed)*

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `docs/agent-system/opencode.md` - restore and update
- `docs/ai_agent_systems.md` - create new
- `README.md` - add system choice mention, link to comparison doc

**Verification**:
- `test -f docs/agent-system/opencode.md` succeeds (file restored)
- `test -f docs/ai_agent_systems.md` succeeds (new file created)
- `grep "ai_agent_systems" README.md` returns match
- `grep "10 extension" docs/agent-system/opencode.md` returns match
- `docs/ai_agent_systems.md` mentions subscription, API credits, and install script choice

---

### Phase 2: Fix Counts, Broken Paths, and Factual Errors [COMPLETED]

**Goal**: Correct the extension count, fix broken doc paths, and correct factual claims across all docs.

**Tasks**:
- [x] Change "9 extensions" to "10 extensions" in `docs/agent-system/extensions.md` (line 3) *(completed)*
- [x] Change "9 extensions" to "10 extensions" in `docs/agent-system/README.md` (line 13) *(completed)*
- [x] Fix Python/R doc paths in `docs/README.md`: `general/python.md` -> `toolchain/python.md`, `general/R.md` -> `toolchain/r.md` *(completed)*
- [x] Fix Python/R doc paths in `docs/workflows/README.md`: `../general/python.md` -> `../toolchain/python.md`, `../general/R.md` -> `../toolchain/r.md` *(completed)*
- [x] Fix R doc path in `docs/agent-system/README.md`: `../general/R.md` -> `../toolchain/r.md` *(completed)*
- [x] Fix factual error in `docs/agent-system/README.md` line ~73: correct "No `.claude/extensions/` directory" claim *(completed: rewritten to accurately describe the 10-extension architecture)*
- [x] Fix Python/R reference in `docs/README.md` line ~15: `general/python.md` -> `toolchain/python.md`, `general/R.md` -> `toolchain/r.md` *(completed)*

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `docs/agent-system/extensions.md` - fix extension count
- `docs/agent-system/README.md` - fix count, R path, extensions directory claim
- `docs/README.md` - fix count and Python/R paths
- `docs/workflows/README.md` - fix Python/R paths

**Verification**:
- `grep -r "9 extension" docs/` returns zero matches
- `grep -r "general/python\|general/R\|general/r\.md" docs/` returns zero matches
- `grep "No.*\.claude/extensions" docs/agent-system/README.md` returns zero matches

---

### Phase 3: Add Web Extension Documentation [COMPLETED]

**Goal**: Add the `web` extension to the feature matrix, README, and toolchain prerequisites so it has equivalent coverage to other extensions.

**Tasks**:
- [x] Add `web` row to the extension feature matrix in `docs/agent-system/extensions.md` *(completed)*
- [x] Add web development mention to `README.md` extension capabilities *(completed: already mentioned in opening paragraph)*
- [x] Add `web` section to `docs/toolchain/extensions.md` covering prerequisites (pnpm, Node.js 18+) and build commands *(completed: also added python section)*
- [x] Mention `web` extension alongside `python` in `docs/agent-system/README.md` extension list *(completed)*

**Timing**: 45 minutes

**Depends on**: 1 (so opencode.md is restored and extensions.md count is fixed first)

**Files to modify**:
- `docs/agent-system/extensions.md` - add web row to feature matrix
- `README.md` - ensure web is mentioned in capabilities
- `docs/toolchain/extensions.md` - add web prerequisites section
- `docs/agent-system/README.md` - add web to extension mentions

**Verification**:
- `grep -i "web" docs/agent-system/extensions.md` shows web extension entry with Astro/Tailwind
- `docs/toolchain/extensions.md` has a "Web" or "Astro" section with pnpm/Node.js prereqs
- `grep -i "web" docs/agent-system/README.md` shows web in extensions list

---

### Phase 4: Fix Commands and Spreadsheet Docs [COMPLETED]

**Goal**: Add missing `/sheet` command documentation, fix `/project-overview` attribution, and update the spreadsheet workflow guide.

**Tasks**:
- [x] Add `/sheet` to `docs/agent-system/commands.md` under the Documents section *(completed)*
- [x] Add `/sheet` to `README.md` Document Tools table *(completed)*
- [x] Update `docs/workflows/edit-spreadsheets.md` to feature `/sheet` as the primary interface *(completed)*
- [x] Fix `/project-overview` in `docs/agent-system/commands.md`: removed OC-only label, moved out of OC-only section, updated source link *(completed)*
- [x] Review `/deck` command entry: kept as OC-only *(completed)*

**Timing**: 30 minutes

**Depends on**: 1 (so the opencode.md context is restored before editing commands.md)

**Files to modify**:
- `docs/agent-system/commands.md` - add /sheet, fix /project-overview, review /deck
- `README.md` - add /sheet to Document Tools table
- `docs/workflows/edit-spreadsheets.md` - rewrite to feature /sheet

**Verification**:
- `grep "/sheet" docs/agent-system/commands.md` returns match
- `grep "/sheet" README.md` returns match
- `docs/workflows/edit-spreadsheets.md` mentions `/sheet` as primary interface
- No "(OC only)" label remains on `/project-overview`

---

### Phase 5: Final Validation and Polish [COMPLETED]

**Goal**: Comprehensive validation sweep across all modified files, verify link integrity, and polish for clarity and consistency.

**Tasks**:
- [x] Run grep sweep: `grep -r "9 extension" docs/ README.md` -- returns zero *(completed)*
- [x] Run grep sweep: `grep -r "general/python\|general/R\|general/r\.md" docs/` -- returns zero *(completed)*
- [x] Run grep sweep: `grep "No.*\.claude/extensions" docs/agent-system/README.md` -- returns zero *(completed)*
- [x] Spot-check web extension appears in all enumerated lists *(completed)*
- [x] Verify all internal markdown links in modified files resolve to existing targets *(completed)*
- [x] Read through `docs/ai_agent_systems.md` for tone, accuracy, and usefulness *(completed)*
- [x] Review `README.md` for coherence *(completed: no significant overlap requiring consolidation)*
- [x] Verify `docs/agent-system/opencode.md` links and command table are accurate *(completed)*
- [x] Add link to `ai_agent_systems.md` in `docs/agent-system/README.md` navigation and `docs/README.md` *(completed)*

**Timing**: 30 minutes

**Depends on**: 2, 3, 4

**Files to modify**:
- `README.md` - optional consolidation of redundant sections
- `docs/README.md` - add link to `ai_agent_systems.md` if not yet linked
- Any files with remaining issues found during sweep

**Verification**:
- All grep sweeps return zero stale references
- Manual review confirms docs read coherently with accurate dual-system descriptions
- No broken internal cross-references remain
- `docs/ai_agent_systems.md` is linked from at least README.md and one docs/ file

## Testing & Validation

- [x] `grep -r "9 extension" docs/ README.md` returns zero matches
- [x] `grep -r "general/python\|general/R\|general/r\.md" docs/` returns zero matches
- [x] `grep "No.*\.claude/extensions" docs/agent-system/README.md` returns zero matches
- [x] `test -f docs/agent-system/opencode.md` succeeds (file exists)
- [x] `test -f docs/ai_agent_systems.md` succeeds (new file exists)
- [x] `grep "ai_agent_systems" README.md` returns match
- [x] `docs/agent-system/extensions.md` contains a `web` row in the feature matrix
- [x] `docs/agent-system/commands.md` contains `/sheet` entry
- [x] `docs/toolchain/extensions.md` contains web prerequisites section
- [x] Extension count reads "10" in all locations
- [x] All internal markdown links resolve to existing files

## Artifacts & Outputs

- `specs/083_revise_docs_for_new_extensions/plans/01_docs-revision-plan.md` (this plan)
- New file: `docs/ai_agent_systems.md` -- comparison doc for Claude Code vs OpenCode
- Restored file: `docs/agent-system/opencode.md` -- updated for accuracy
- Modified documentation files (~10 files across docs/ and README.md)

## Rollback/Contingency

All changes are to tracked markdown files. If the revision introduces errors:
1. Use `git diff` to review all changes
2. Use `git checkout -- <file>` to revert individual files
3. Use `git stash` to save partial progress if needed
4. The research report remains available for re-planning if the approach needs adjustment
