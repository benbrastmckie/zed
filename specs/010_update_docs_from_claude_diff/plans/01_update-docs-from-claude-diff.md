# Implementation Plan: Task 10 - Update docs/ from .claude/ diff

- **Task**: 10 - Update docs/ based on .claude/ diff
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Dependencies**: None (task 9 plan edit is folded into Phase 6 atomically)
- **Research Inputs**: specs/010_update_docs_from_claude_diff/reports/01_team-research.md
- **Artifacts**: plans/01_update-docs-from-claude-diff.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/state-management.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/workflows.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Task 10 is a surgical documentation housekeeping pass: `/home/benjamin/.config/zed/docs/` has drifted in 13 specific places from the current `.claude/` configuration, chiefly because `/talk` was deleted and its role absorbed by `/slides`, while old PPTX-conversion semantics moved into `/convert --format`. The team research identified 4-5 `docs/` files needing touch-ups (8 of 16 files need zero changes), plus one cross-task collision in `specs/009_.../plans/01_workflow-docs-plan.md` that must be resolved atomically within this task. Tier 2 scope is adopted: mechanical drift fixes plus a "Zed adaptations" note in `docs/agent-system/README.md` plus non-numerical command-count phrasing.

### Research Integration

The synthesized team research at `specs/010_update_docs_from_claude_diff/reports/01_team-research.md` consolidated findings from four parallel teammates (A: diff cataloger, B: docs mapper, C: critic, D: horizons). All four independently surfaced the same 13-item drift catalog, giving high confidence of completeness. The plan's phase structure follows Teammate B's prior-art pattern from task 8: one phase per drifted file, with a final "repair inbound links" verification phase. Drift items from the catalog are cited by number (#1-#13) in each phase.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md context provided beyond path; this task is documentation housekeeping, not a roadmap-advancing feature.

## Goals & Non-Goals

**Goals**:
- Eliminate all 13 catalogued drift items in `/home/benjamin/.config/zed/docs/` so that user-facing docs match the current `.claude/` configuration.
- Replace numerical "24 commands" phrasings with non-counting language that will not drift the next time a command is added or removed.
- Repurpose the `/slides` and `/convert` entries to reflect the new semantics (research-talk task creation for `/slides`; `--format beamer|polylux|touying` for PPTX conversion on `/convert`).
- Add a small "Zed adaptations" note to `docs/agent-system/README.md` documenting the three intentional Zed-workspace deviations (no extension loader directory, no `Co-Authored-By` trailer, no `<leader>ac` keybinding).
- Atomically resolve the task 9 / task 10 collision by editing `specs/009_workflow_docs_for_commands/plans/01_workflow-docs-plan.md` in the same phase set.
- Verify zero stale tokens remain via manual grep, since `check-extension-docs.sh` cannot run here.

**Non-Goals**:
- No restructuring of the `docs/` three-way split (general/, agent-system/, workflows/). Task 8 established this and it is sound.
- No edits to `.claude/docs/` (system-builder audience, explicitly out of scope).
- No attempt to run `.claude/scripts/check-extension-docs.sh` as a validation gate (it cannot run without a `.claude/extensions/` directory in this workspace).
- No cleanup of `.claude/CLAUDE.md.backup`, `settings.local.json.backup`, or `index.json.backup` (orthogonal hygiene).
- No documentation of the new lean-mcp helper scripts (`setup-lean-mcp.sh`, `verify-lean-mcp.sh`) in user-facing `docs/` -- they are neovim/lean tooling and orthogonal.
- No Tier 3 drift-lint script (`check-docs-sync.sh`); deferred.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `.claude/CLAUDE.md` is mid-edit (backup file present), so docs edits propagate WIP | M | M | Assume finalized state per Open Questions section; if user indicates otherwise, re-run after CLAUDE.md stabilizes. Edits are small and easily re-applied. |
| Naive find-and-replace on `/slides` creates a duplicate section in `docs/agent-system/commands.md` | H | M | Phase 2 explicitly performs a section-merge: delete the `### /talk` section and rewrite the `### /slides` section in-place; do not append. |
| Stale anchor links elsewhere in `docs/` pointing to the removed `### /talk` heading | M | L | Phase 6 (verification) greps for `#talk`, `/talk`, `talk.md` across `docs/` and fixes any inbound links. |
| Task 9 re-implements before this lands, creating a `/talk` workflow doc for a deleted command | H | L | Phase 5 edits the task 9 plan atomically within task 10 scope, per team recommendation. |
| Grep false-positive matches on legitimate uses of the word "talk" in unrelated prose | L | M | Phase 6 uses word-boundary grep (`\btalk\b`, `/talk\b`) and reviews each hit manually. |

## Open Questions / Assumptions

The research report flagged four open questions. This plan adopts the following assumptions rather than blocking on user input mid-execution; if any assumption is wrong, the affected phase can be re-run in isolation.

1. **Is `.claude/CLAUDE.md` in its final state?** *Assumption*: Yes. The `.backup` file is presumed to be a prior snapshot, not an in-flight draft. If user indicates CLAUDE.md is still being edited, re-run Phase 1 and Phase 3 after it stabilizes.
2. **Tier choice**: *Assumption*: Tier 2 per team recommendation (mechanical fixes + "Zed adaptations" box + non-numerical phrasing + atomic task 9 collision resolution).
3. **Backup file cleanup** (`.claude/CLAUDE.md.backup`, `settings.local.json.backup`, `index.json.backup`): *Assumption*: Out of scope. Not touched.
4. **Lean-mcp scripts scope** (`setup-lean-mcp.sh`, `verify-lean-mcp.sh`): *Assumption*: Out of scope for user-facing `docs/`. They are neovim/lean tooling and will be documented (if at all) in the neovim extension docs, not `docs/`.
5. **`check-extension-docs.sh` as validation gate**: *Assumption*: Not used. It cannot run in this workspace (no `.claude/extensions/` directory). Manual grep is the validation path.
6. **Task 9 collision resolution mechanism**: *Assumption*: Edit the task 9 plan in-place within this task rather than spawning a separate `/revise 9`. This is atomic and faster.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4, 5 | -- |
| 2 | 6 | 1, 2, 3, 4, 5 |

Phases within the same wave can execute in parallel.

Note: Phases 1-5 each touch a distinct file with no cross-file coupling, so they are independent and can be executed in any order or in parallel. Phase 6 is a verification sweep that must run after all edits are complete.

---

### Phase 1: Update docs/agent-system/commands.md [COMPLETED]

**Goal**: Eliminate drift items #1, #2, #3, #10 from the main command catalog file. This is the highest-volume phase: it removes the `### /talk` section entirely, rewrites the `### /slides` section to cover its new research-talk role, and fixes two rename tokens.

**Tasks**:
- [ ] Drift #1: On line 3, change "All 24 slash commands in this workspace" -> "All slash commands in this workspace" (Edit old_string: `All 24 slash commands in this workspace`, new_string: `All slash commands in this workspace`).
- [ ] Drift #2: Delete the entire `### /talk` section (lines ~312-330). This includes the heading, the example `/talk "job talk..."` snippet, and the dead link to `.claude/commands/talk.md`. Use Edit with the full section as old_string and empty new_string (or replace with a blank line).
- [ ] Drift #3: Rewrite the `### /slides` section (lines ~217-227). The old content describes PPTX -> Beamer/Polylux/Touying conversion. Replace it with a description that (a) covers the research-talk task creation with forcing questions, matching `.claude/commands/slides.md`, and (b) contains a one-line pointer: "PPTX conversion moved to `/convert --format beamer|polylux|touying`; see the Convert Documents workflow." Remove the dead link to `.claude/commands/talk.md`.
- [ ] Drift #10: On line 82, change `update CHANGE_LOG and ROAD_MAP` -> `update CHANGE_LOG and ROADMAP` (Edit old_string: `update CHANGE_LOG and ROAD_MAP`, new_string: `update CHANGE_LOG and ROADMAP`).
- [ ] Verify file compiles as markdown (no orphaned list markers, no duplicate headings).

**Timing**: 40 minutes

**Depends on**: none

**Files to modify**:
- `docs/agent-system/commands.md` - drop `### /talk` section, rewrite `### /slides` section, fix two tokens on lines 3 and 82

**Verification**:
- `grep -n "24 slash commands\|24 commands\|/talk\|talk\.md\|ROAD_MAP" docs/agent-system/commands.md` returns no matches
- `grep -nc "^### /slides" docs/agent-system/commands.md` returns `1` (exactly one slides section, no duplicate)
- `grep -nc "^### /talk" docs/agent-system/commands.md` returns `0`

---

### Phase 2: Update docs/agent-system/README.md [NOT STARTED]

**Goal**: Eliminate drift item #4 and add the "Zed adaptations" callout box (Tier 2 addition).

**Tasks**:
- [ ] Drift #4: On line 20, change "all 24 Claude Code commands" -> "the Claude Code command catalog" (Edit old_string: `all 24 Claude Code commands`, new_string: `the Claude Code command catalog`).
- [ ] Add a new subsection titled "Zed adaptations" near the top of the README (after the introduction paragraph but before the main structural sections). The subsection should be 4-8 lines of prose/bullets explaining that this workspace adapts the upstream neovim-based `.claude/` configuration with three intentional deviations:
  - No `<leader>ac` extension loader keybinding (Zed does not support vim keybindings in shared collaboration mode; see `~/.claude/projects/.../feedback_no_vim_mode_zed.md`).
  - No `Co-Authored-By` trailer on commits (per user preference).
  - No `.claude/extensions/` directory; extensions are tracked via the flat `.claude/extensions.json` file instead.
- [ ] Verify the new subsection renders cleanly and is not nested inside an unintended parent.

**Timing**: 20 minutes

**Depends on**: none

**Files to modify**:
- `docs/agent-system/README.md` - fix line 20, insert "Zed adaptations" subsection

**Verification**:
- `grep -n "24 Claude Code commands\|24 commands" docs/agent-system/README.md` returns no matches
- `grep -n "Zed adaptations" docs/agent-system/README.md` returns exactly one match
- Manual review: the new subsection is at the correct nesting level

---

### Phase 3: Update docs/agent-system/architecture.md [NOT STARTED]

**Goal**: Eliminate drift items #5, #6, #7 -- the `Co-Authored-By` trailer leak and two "24 commands" references.

**Tasks**:
- [ ] Drift #5: On line 58, remove the example `Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>` trailer line from the example commit message block. Add a new sentence immediately after the example: `This workspace omits the `Co-Authored-By` trailer per user preference (see `.claude/CLAUDE.md`).`
- [ ] Drift #6: On line 84, change `# 24 slash command definitions` -> `# slash command definitions` (Edit old_string: `# 24 slash command definitions`, new_string: `# slash command definitions`).
- [ ] Drift #7: On line 95, change `All 24 commands are always available` -> `All commands are always available` (Edit old_string: `All 24 commands are always available`, new_string: `All commands are always available`).

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:
- `docs/agent-system/architecture.md` - drop Co-Authored-By example line and fix two "24 commands" phrasings

**Verification**:
- `grep -n "Co-Authored-By" docs/agent-system/architecture.md` returns no matches (or only the new explanatory sentence)
- `grep -n "24 slash command\|24 commands" docs/agent-system/architecture.md` returns no matches

---

### Phase 4: Update docs/workflows/agent-lifecycle.md and docs/workflows/convert-documents.md [NOT STARTED]

**Goal**: Eliminate drift items #8, #9, #11 -- the last numeric "24 commands" instance, the ROAD_MAP rename, and the `/slides` -> `/convert --format` semantic shift in the convert-documents workflow doc.

**Tasks**:
- [ ] Drift #8: In `docs/workflows/agent-lifecycle.md` line 87, change `annotates ROAD_MAP.md` -> `annotates ROADMAP.md` (Edit old_string: `annotates \`ROAD_MAP.md\``, new_string: `annotates \`ROADMAP.md\``).
- [ ] Drift #9: In `docs/workflows/agent-lifecycle.md` line 120, change `Full catalog of all 24 commands` -> `Full command catalog` (Edit old_string: `Full catalog of all 24 commands`, new_string: `Full command catalog`).
- [ ] Drift #11: In `docs/workflows/convert-documents.md`, rewrite the PPTX slide-conversion section (lines 12, 35, 38). Every example currently uses `/slides deck.pptx` -> Beamer/Polylux/Touying. Replace with `/convert deck.pptx --format beamer` (and polylux, touying variants). Add one sentence near the top of that section: "Note: `/slides` now creates research-talk tasks; PPTX-to-slide conversion is handled by `/convert --format`."
- [ ] Verify no other `/slides deck.pptx` examples remain in this file.

**Timing**: 25 minutes

**Depends on**: none

**Files to modify**:
- `docs/workflows/agent-lifecycle.md` - fix lines 87, 120
- `docs/workflows/convert-documents.md` - rewrite PPTX examples, add clarifying sentence

**Verification**:
- `grep -n "ROAD_MAP\|24 commands" docs/workflows/agent-lifecycle.md` returns no matches
- `grep -n "/slides [^\"]*\.pptx\|/slides deck" docs/workflows/convert-documents.md` returns no matches
- `grep -n "/convert.*--format" docs/workflows/convert-documents.md` returns at least three matches (beamer, polylux, touying)

---

### Phase 5: Resolve task 9 collision and update docs/agent-system/context-and-memory.md [NOT STARTED]

**Goal**: Eliminate drift items #12 and #13. Item #12 fixes the stale `.claude/extensions/*/context/` reference in the context-and-memory doc. Item #13 atomically revises the task 9 plan to remove `/talk` references before task 9 is re-implemented.

**Tasks**:
- [ ] Drift #12: In `docs/agent-system/context-and-memory.md` lines 78 and 87, the text currently references `.claude/extensions/*/context/` as if that directory existed. Replace with a clarification: `.claude/extensions/` does not exist as a directory in this workspace; extensions are managed via the flat `.claude/extensions.json` file. Cross-reference the new "Zed adaptations" subsection in `docs/agent-system/README.md` added in Phase 2.
- [ ] Drift #13: Edit `specs/009_workflow_docs_for_commands/plans/01_workflow-docs-plan.md`. Find any phase referencing `/talk` or `.claude/commands/talk.md` and rewrite to reference `/slides` (new research-talk role). Remove the dead `.claude/commands/talk.md` link. Add a one-line note at the top of the plan: `Updated {DATE}: task 10 removed /talk references after /talk was deleted and /slides absorbed its role.`
- [ ] If task 9 status is currently `[COMPLETED]` in TODO.md but the state.json says `implementing`, note this state drift in a comment at the bottom of the task 9 plan (do not try to fix it here; flag for `/task --sync`).

**Timing**: 20 minutes

**Depends on**: none

**Files to modify**:
- `docs/agent-system/context-and-memory.md` - fix lines 78, 87 extensions references
- `specs/009_workflow_docs_for_commands/plans/01_workflow-docs-plan.md` - remove `/talk` references, redirect to `/slides`

**Verification**:
- `grep -n "extensions/\*/context\|\.claude/extensions/[a-z]" docs/agent-system/context-and-memory.md` returns no matches (or only matches with explicit "does not exist" context)
- `grep -n "/talk\|talk\.md" specs/009_workflow_docs_for_commands/plans/01_workflow-docs-plan.md` returns no matches
- `grep -n "/slides" specs/009_workflow_docs_for_commands/plans/01_workflow-docs-plan.md` returns at least one match

---

### Phase 6: Repair inbound links and final verification [NOT STARTED]

**Goal**: Sweep the entire `docs/` tree for any remaining stale tokens or inbound links that point to removed sections/files. This phase catches anything the per-file phases missed and acts as the task's final validation gate.

**Tasks**:
- [ ] Run a workspace-wide grep over `docs/` for stale tokens and verify each returns zero (or only intentional) matches:
  - [ ] `grep -rn "/talk\b" docs/` (should be 0 hits)
  - [ ] `grep -rn "talk\.md" docs/` (should be 0 hits)
  - [ ] `grep -rn "ROAD_MAP" docs/` (should be 0 hits)
  - [ ] `grep -rn "24 commands\|24 slash\|all 24" docs/` (should be 0 hits)
  - [ ] `grep -rn "Co-Authored-By" docs/` (should be 0 hits, or only the new explanatory sentence in architecture.md)
  - [ ] `grep -rn "/slides [^\"]*\.pptx" docs/` (should be 0 hits -- no more PPTX examples under `/slides`)
- [ ] Scan for any inbound markdown links pointing to the removed `### /talk` anchor:
  - [ ] `grep -rn "#talk\b\|#/talk" docs/` and fix any hits by redirecting to `#slides` or the Convert Documents workflow.
- [ ] Verify the new "Zed adaptations" subsection in `docs/agent-system/README.md` is reachable from the docs TOC (if one exists) or at least cross-linked from `docs/agent-system/context-and-memory.md` per Phase 5.
- [ ] Read through each modified file once end-to-end to catch any structural issues (orphaned headings, broken numbered lists, duplicate sections, anchor drift).
- [ ] Confirm task 9 plan now reads coherently after the `/talk` -> `/slides` substitution.

**Timing**: 20 minutes

**Depends on**: 1, 2, 3, 4, 5

**Files to modify**:
- None expected. Any hits discovered here are fixed in-place and logged as addenda to the appropriate prior phase.

**Verification**:
- All six `grep -rn ... docs/` commands above return zero matches (or only documented intentional matches)
- Manual read-through of each modified file produces no further issues

---

## Testing & Validation

- [ ] All six verification grep commands in Phase 6 return zero matches
- [ ] `docs/agent-system/commands.md` has exactly one `### /slides` section and zero `### /talk` sections
- [ ] `docs/agent-system/README.md` contains a "Zed adaptations" subsection
- [ ] `docs/workflows/convert-documents.md` uses `/convert --format` for all PPTX examples
- [ ] `specs/009_workflow_docs_for_commands/plans/01_workflow-docs-plan.md` contains no `/talk` references
- [ ] Manual spot-check rendering of each modified markdown file (no broken lists, no orphaned headings)
- [ ] No new broken inbound anchor links introduced (`#talk`, `#/talk` not referenced anywhere in `docs/`)

## Artifacts & Outputs

- `specs/010_update_docs_from_claude_diff/plans/01_update-docs-from-claude-diff.md` (this plan)
- `specs/010_update_docs_from_claude_diff/summaries/01_update-docs-from-claude-diff-summary.md` (created by `/implement` postflight)
- Modified: `docs/agent-system/commands.md`
- Modified: `docs/agent-system/README.md`
- Modified: `docs/agent-system/architecture.md`
- Modified: `docs/agent-system/context-and-memory.md`
- Modified: `docs/workflows/agent-lifecycle.md`
- Modified: `docs/workflows/convert-documents.md`
- Modified: `specs/009_workflow_docs_for_commands/plans/01_workflow-docs-plan.md`

## Rollback/Contingency

All edits are small, surgical, and independent. If any phase produces a broken result:

1. **Per-file rollback**: `git checkout HEAD -- docs/agent-system/commands.md` (or the affected file). Because phases 1-5 touch distinct files, a failure in one does not cascade.
2. **Whole-task rollback**: `git checkout HEAD -- docs/ specs/009_workflow_docs_for_commands/plans/01_workflow-docs-plan.md`. Restores all seven modified files in one command.
3. **Partial completion**: If Phase 6 discovers issues that cannot be fixed in the current session, mark Phase 6 `[PARTIAL]` and leave the phase-specific fixes completed. Re-running `/implement 10` resumes at Phase 6.
4. **If task 9 state drift (`implementing` in state.json vs `[COMPLETED]` in TODO.md) is discovered in Phase 5**: Flag for `/task --sync` as a follow-up; do not attempt to reconcile within task 10 scope.
