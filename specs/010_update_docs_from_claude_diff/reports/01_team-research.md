# Team Research Synthesis: Task 10

**Task**: 10 - Update docs/ based on .claude/ diff
**Started**: 2026-04-10
**Completed**: 2026-04-10
**Team Size**: 2 teammates returned findings (C, D); A and B did not produce reports
**Sources/Inputs**: `git diff HEAD -- .claude/`, `git status`, docs/ tree, .claude/ tree, task 9 plan, CLAUDE.md, scripts/check-extension-docs.sh
**Artifacts**:
- `specs/010_update_docs_from_claude_diff/reports/01_teammate-c-findings.md` (Critic)
- `specs/010_update_docs_from_claude_diff/reports/01_teammate-d-findings.md` (Horizons)
- `specs/010_update_docs_from_claude_diff/reports/01_team-research.md` (this synthesis)
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Task 10 is housekeeping, not a structural change.** The `docs/` three-way split (`general/` + `agent-system/` + `workflows/`) established by tasks 6-8 is sound and must be preserved.
- **Single dominant semantic change**: `.claude/commands/talk.md` was deleted and `.claude/commands/slides.md` was repurposed to absorb its role. The old `/slides` semantics (PPTX -> Beamer/Polylux/Touying) moved into `/convert --format`. This requires narrative rewriting in `docs/agent-system/commands.md` and `docs/workflows/convert-documents.md`, not find-and-replace.
- **13 concrete drift items** identified and verified (see Drift Catalog below), concentrated in four `docs/` files plus one cross-task collision in `specs/009_.../plans/01_workflow-docs-plan.md`.
- **Task 9 collision**: task 9's plan still references `/talk` and `.claude/commands/talk.md`. The plan must be revised (or explicitly edited as part of task 10 scope) before task 9 re-implements, otherwise it will create docs for a deleted command.
- **Branch note**: default branch is `master`, not `main`. Diff scope is `HEAD` (all changes are uncommitted on master).
- **Validation**: `.claude/scripts/check-extension-docs.sh` cannot run in this repo (no `.claude/extensions/` directory). Manual verification via grep is the only validation path for this task.
- **Recommended tier**: Teammate D's **Tier 2** (minimal mechanical fixes + a "Zed adaptations" section in `docs/agent-system/README.md` + non-numerical command-count phrasing). ~2 hours.

## Context & Scope

**What was researched**: The working-tree diff of `.claude/` vs HEAD, identifying every change with user-visible documentation implications in `/home/benjamin/.config/zed/docs/`.

**Scope boundaries** (with explicit resolutions from Teammate C):

| Question | Resolution |
|---|---|
| master vs main | `master` is the default branch. Use `HEAD`, not `main..HEAD`. |
| Committed vs staged vs unstaged | All changes are uncommitted on master. Use `git diff HEAD` + `git ls-files --others --exclude-standard .claude/`. |
| `.claude/docs/` vs `docs/` | **Out of scope**: `.claude/docs/` (25 files, system-builder audience). **In scope**: `/home/benjamin/.config/zed/docs/` (14 files, user audience). Task prompt explicitly names `docs/`. |
| Backup files (`.backup`, `index.json.backup`) | **Ignore as noise**. They are WIP snapshots. |
| `specs/tmp/*` | **Ignore**. Runtime state. |
| Untracked scripts (`check-extension-docs.sh`, `setup-lean-mcp.sh`, `verify-lean-mcp.sh`) | Internal-only; do not document in user-facing `docs/`. CLAUDE.md already mentions `check-extension-docs.sh` in its Utility Scripts section. |
| `.claude/context/index.json` 4528-line diff | **Noise**: mostly jq key reordering, not semantic. Do not allocate effort here. |

**Scope uncertainty (flagged for user confirmation)**:

1. Is `.claude/CLAUDE.md` in its final state? The presence of `.claude/CLAUDE.md.backup` suggests ongoing edits. Regenerating `docs/` from WIP propagates incompleteness.
2. Is the `/talk` -> `/slides` transition final? Both teammates assume yes based on file-level evidence.

## Findings

### Codebase Patterns

**Diff size (cleaned of noise)**:
- ~50 modified files in `.claude/`
- 2 deletions: `.claude/commands/talk.md`, `.claude/context/standards/documentation.md`
- 5 new untracked files: `check-extension-docs.sh`, `setup-lean-mcp.sh`, `verify-lean-mcp.sh`, `CLAUDE.md.backup`, `settings.local.json.backup`
- Real semantic changes concentrated in: `.claude/CLAUDE.md`, `.claude/commands/slides.md`, `.claude/commands/convert.md`, `.claude/commands/todo.md`, `.claude/context/standards/documentation-standards.md`, `.claude/context/reference/skill-agent-mapping.md`

**High-impact changes relevant to docs/**:

1. **`/talk` deleted, `/slides` repurposed** (Teammate C verified):
   - Old `/slides`: PPTX -> Beamer/Polylux/Touying conversion
   - New `/slides`: research talk task creation with forcing questions (former `/talk` semantics)
   - PPTX-to-slides conversion now handled by `/convert --format beamer|polylux|touying`
   - `.claude/commands/convert.md` gained +202 lines documenting the new `--format` flag

2. **`ROAD_MAP.md` -> `ROADMAP.md`** global rename (Teammate C verified). Stale references remain in `docs/workflows/agent-lifecycle.md:87` and `docs/agent-system/commands.md:82`.

3. **`Co-Authored-By` trailer removed** from commit convention in `.claude/CLAUDE.md`. Stale example remains in `docs/agent-system/architecture.md:58`.

4. **CLAUDE.md additions**:
   - New Utility Script: `check-extension-docs.sh`
   - New rule: `plan-format-enforcement.md` (internal-only)
   - Skill-agent-mapping expanded: `skill-reviser`, `skill-spawn`, `skill-orchestrator`, `skill-git-workflow`, `skill-fix-it` added

5. **Command count change**: 24 -> 23 commands (via `/talk` absorption). Teammate D found "24" referenced in at least 4 places in `docs/` (see Drift Catalog).

### External Resources

Not applicable — this is purely an internal codebase research task.

### Recommendations

**Tiered scope (Teammate D's framework, team-endorsed)**:

**Tier 1 — Minimal Mechanical (baseline)**: Fix 13 drift items below. Parameterize "24 commands" as non-numerical phrase. Update `/slides` entry to cover both roles. Drop `Co-Authored-By` from architecture.md example and add a one-line explanation. Revise `specs/009_.../plans/01_workflow-docs-plan.md` to remove `/talk` references. **Cost**: ~1 hour. Four `docs/` files + one `specs/` plan file.

**Tier 2 — Minimal + Zed-adaptations box (recommended)**: Tier 1, plus add a "Zed adaptations" section to `docs/agent-system/README.md` listing three intentional overrides: (a) no extension loader, (b) no `Co-Authored-By` trailer, (c) no `<leader>ac` keybinding. Replace every numerical "N commands" phrase with a non-counting phrase project-wide. Explicitly resolve the task 9 collision in the same PR. **Cost**: ~2 hours. **This is the team-recommended tier.**

**Tier 3 — Strategic + drift-lint script (ambitious)**: Tier 2, plus write `.claude/scripts/check-docs-sync.sh` modeled on `check-extension-docs.sh`. **Cost**: ~3 hours. Teammate C noted `check-extension-docs.sh` itself does not run in this repo (no `.claude/extensions/` dir), which should be addressed or documented before proposing it as a template.

## Drift Catalog (Consolidated)

Verified by both teammates via direct grep/diff inspection:

| # | File | Location | Current (stale) | Should be | Driver |
|---|------|----------|-----------------|-----------|--------|
| 1 | `docs/agent-system/commands.md` | line 3 | "All 24 slash commands in this workspace" | "All slash commands in this workspace" | `/talk` deleted |
| 2 | `docs/agent-system/commands.md` | lines 312-330 | Full `### /talk` section with example `/talk "job talk..."` and link to `.claude/commands/talk.md` | Remove section; fold into `### /slides` section (lines 217-227) | `/talk` deleted |
| 3 | `docs/agent-system/commands.md` | line 217-227, 330 | `/slides` section describes only PPTX conversion; link to `.claude/commands/talk.md` is dead | Expand `/slides` to cover both (a) task-creation with forcing questions (current slides.md) and (b) note that PPTX conversion moved to `/convert --format`. Replace dead link. | `/slides` repurposed, `/convert` expanded |
| 4 | `docs/agent-system/README.md` | line 20 | "all 24 Claude Code commands" | "the Claude Code command catalog" | `/talk` deleted |
| 5 | `docs/agent-system/architecture.md` | line 58 | Example commit message shows `Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>` trailer | Remove trailer line; add sentence: "This workspace omits the `Co-Authored-By` trailer per user preference" | `.claude/CLAUDE.md` new preference note |
| 6 | `docs/agent-system/architecture.md` | line 84 | "# 24 slash command definitions" | "# slash command definitions" | `/talk` deleted |
| 7 | `docs/agent-system/architecture.md` | line 95 | "All 24 commands are always available" | "All commands are always available" | `/talk` deleted |
| 8 | `docs/workflows/agent-lifecycle.md` | line 87 | "annotates `ROAD_MAP.md`" | "annotates `ROADMAP.md`" | Rename |
| 9 | `docs/workflows/agent-lifecycle.md` | line 120 | "Full catalog of all 24 commands" | "Full command catalog" | `/talk` deleted |
| 10 | `docs/agent-system/commands.md` | line 82 | "update CHANGE_LOG and ROAD_MAP" | "update CHANGE_LOG and ROADMAP" | Rename |
| 11 | `docs/workflows/convert-documents.md` | lines 12, 35, 38 | `/slides deck.pptx` to Beamer/Polylux/Touying | Move PPTX conversion examples to `/convert --format`; note that `/slides` now creates research-talk tasks | `/slides` repurposed, `/convert --format` added |
| 12 | `docs/agent-system/context-and-memory.md` | lines 78, 87 | References `.claude/extensions/*/context/` | Clarify that `.claude/extensions/` does not exist in this workspace; extensions are managed via flat `.claude/extensions.json` | Pre-existing drift, surfaced by this audit |
| 13 | `specs/009_workflow_docs_for_commands/plans/01_workflow-docs-plan.md` | phases referencing `/talk` | References `/talk` and `.claude/commands/talk.md` | Revise to reference `/slides` (new talk-creation role) and remove dead file link | Task-9 / task-10 collision |

**Non-drift items verified safe**:
- Two-memory-layers story in `docs/agent-system/context-and-memory.md` (except extensions line above) unchanged and correct
- `docs/general/installation.md` claude-acp setup unchanged and correct
- `docs/agent-system/zed-agent-panel.md` ACP bridge explanation unchanged and correct
- `docs/agent-system/architecture.md` three-layer pipeline diagram unchanged and correct
- `/tag` entry in `docs/agent-system/commands.md` (user-only) unchanged and correct
- `plan-format-enforcement.md` rule and `check-extension-docs.sh` script additions are internal-only; no `docs/` action needed

## Decisions

1. **Scope**: Tier 2 is the recommended scope. Tier 1 is an acceptable fallback if time is constrained; Tier 3 requires separate verification that `check-extension-docs.sh` can be made to work in this repo.
2. **docs/ structure**: Do **not** restructure. Preserve the `general/` + `agent-system/` + `workflows/` three-way split.
3. **docs/docs split**: `.claude/docs/` is **out of scope** for task 10 unless the user explicitly widens scope. Task 10 targets `/home/benjamin/.config/zed/docs/` only.
4. **Task 9 collision**: Resolve by editing `specs/009_.../plans/01_workflow-docs-plan.md` as part of task 10 scope (atomic), rather than as a separate `/revise 9` pre-step.
5. **Command count**: Use non-numerical phrasing ("the Claude Code command catalog", "all slash commands in this workspace") rather than a new number. This removes a recurring drift vector.
6. **Diff scope**: Use `git diff HEAD -- .claude/` plus explicit enumeration of deletions (`.claude/commands/talk.md`, `.claude/context/standards/documentation.md`). Ignore `.backup` files and `specs/tmp/*`.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| `.claude/CLAUDE.md` may be mid-edit (backup file present) | Ask user to confirm before implementing; otherwise implementation may propagate WIP |
| Naive find-and-replace on `/slides` will create duplicate sections in `docs/agent-system/commands.md` | Plan must call out section-merge operations explicitly, not just text substitutions |
| `check-extension-docs.sh` cannot run here (no `.claude/extensions/`) | Do not use it as a validation gate for task 10; use manual grep instead |
| Untracked new files (`check-extension-docs.sh`, `setup-lean-mcp.sh`, etc.) invisible to `git diff` | Cataloger must explicitly run `git ls-files --others --exclude-standard .claude/` |
| Deleted files invisible to `git diff --numstat` with `--diff-filter=M` | Cataloger must enumerate deletions separately |
| Task 9 may re-implement before task 10 lands and create a `/talk` workflow doc for a nonexistent command | Edit task-9 plan atomically as part of task 10 |
| State.json shows task 9 as `implementing` but TODO.md shows `[COMPLETED]` | Pre-existing drift; not task 10's responsibility but should be noted for `/task --sync` |

## Context Extension Recommendations

- **Topic**: `docs/` vs `.claude/docs/` two-tree layout. **Gap**: No context file explains the distinction between user-facing and system-builder documentation trees. **Recommendation**: Add a brief entry to `.claude/context/repo/project-overview.md`.
- **Topic**: Branch naming. **Gap**: Delegation prompts assume `main` but this repo uses `master`. **Recommendation**: Document the default branch in `.claude/context/repo/project-overview.md`.

## Questions for the Planner / User

1. Is `.claude/CLAUDE.md` in its final state? (`.backup` file suggests maybe not.)
2. Should task 10 atomically edit `specs/009_.../plans/01_workflow-docs-plan.md`, or should that be a separate `/revise 9` pre-step?
3. Which tier (1, 2, or 3) is the intended scope?
4. Should backup files (`.claude/CLAUDE.md.backup`, `settings.local.json.backup`, `index.json.backup`) be cleaned up or added to `.gitignore` as part of this task?
5. Are the new lean-lsp scripts (`setup-lean-mcp.sh`, `verify-lean-mcp.sh`) in scope for docs, or orthogonal neovim/lean work?

## Appendix

### Commands Used

```bash
git status --short
git log --oneline -20
git diff HEAD --stat -- .claude/
git diff HEAD -- .claude/commands/talk.md
git diff HEAD -- .claude/commands/slides.md
git diff HEAD -- .claude/commands/convert.md
git diff HEAD -- .claude/CLAUDE.md
git diff HEAD -- .claude/commands/todo.md
git diff HEAD -- .claude/context/standards/documentation-standards.md
git diff HEAD -- .claude/context/reference/skill-agent-mapping.md
git diff HEAD -- .claude/extensions.json
git ls-files --others --exclude-standard .claude/
```

Plus grep searches over `docs/` for: `\.claude/`, `/talk`, `/slides`, `/convert`, `ROAD_MAP|ROADMAP`, `Co-Authored-By`, `extensions/`, `TODO|FIXME|NOTE:`, `--team`, `24 commands`.

### Teammate Participation

- **Teammate A (Cataloger)**: No report produced. Expected to enumerate raw diff.
- **Teammate B (Docs mapper)**: No report produced. Expected to map `docs/` tree to `.claude/` referents.
- **Teammate C (Critic)**: `01_teammate-c-findings.md` — scope ambiguities, hidden coupling, blind spots, stress-test of the primary approach.
- **Teammate D (Horizons)**: `01_teammate-d-findings.md` — long-term alignment, strategic opportunities, tiered scope recommendation, drift catalog.

The synthesis above is based on C and D findings. The drift catalog is consolidated from D with scope validation from C. If the planner believes a raw diff catalog from A and B is necessary before planning, run `/research 10` again; otherwise the consolidated view above is sufficient for `/plan 10`.
