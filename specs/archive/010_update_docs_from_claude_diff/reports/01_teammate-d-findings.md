# Teammate D (Horizons) Findings: Strategic Direction for docs/

- **Task**: 10 - Update docs/ based on .claude/ diff
- **Teammate**: D (Horizons) -- long-term alignment and strategic direction
- **Started**: 2026-04-10
- **Completed**: 2026-04-10
- **Sources**: `.claude/` working-tree diff, `docs/` tree, `specs/TODO.md`, task summaries 001-008, task 9 plan, `.claude/CLAUDE.md`, `.claude/README.md`, `.claude/docs/README.md`
- **Artifacts**: this file

## Key Findings

1. **Task 10 arrives mid-stride, not at rest.** Task 9 is `[PLANNED]` but not yet implemented. Its plan (`specs/009_workflow_docs_for_commands/plans/01_workflow-docs-plan.md`, phases 3 and elsewhere) still references `/talk` and `.claude/commands/talk.md` -- both of which were deleted in this diff. Task 10's mechanical update will silently collide with task 9 unless the two are sequenced or the task-9 plan is revised first. This is the single most important finding.

2. **The docs/ contract is already clear and defensible.** Read together, `docs/README.md`, `docs/agent-system/README.md`, and `docs/workflows/README.md` establish a three-layer split that works:
   - `docs/general/` -- install/settings/keybindings (macOS target, dependency-first)
   - `docs/agent-system/` -- reference (architecture, commands, context/memory, Zed panel)
   - `docs/workflows/` -- narrative "I want to..." guides
   - `docs/` does *not* try to replace `.claude/docs/` (power-user reference) or `.claude/CLAUDE.md` (always-loaded quick reference). It consistently links down to them. This boundary was hard-won over tasks 1, 3, 5, 6, 7, 8 and should be preserved. No structural restructure is warranted.

3. **Drift is concentrated and small, but systemic.** Four specific drift vectors (detailed below), each traceable to a single line in `.claude/CLAUDE.md` or a deleted file. They are small *individually* but add up to a trust problem: a reader who notices one stale fact will distrust the whole tree.

4. **`.claude/` is evolving toward explicit command shrinkage, not growth.** This is the first task-9-era diff in which the command count *decreases* (24 -> 23 via `/talk` absorption into `/slides`). Combined with the new doc-lint script (`.claude/scripts/check-extension-docs.sh`, untracked), the direction is consolidation and automated sync validation, not feature expansion.

5. **docs/ has no automated drift detection.** Every previous task (1-8) has manually repaired inbound links after a move. There is no CI-style check that `docs/` stays in sync with `.claude/commands/`, `.claude/CLAUDE.md` command table, or `.claude/rules/git-workflow.md`. The new `check-extension-docs.sh` script is a tell: `.claude/` is starting to self-police its docs. `docs/` has no equivalent and will keep accumulating the same class of drift every time `.claude/CLAUDE.md` is touched.

## Project Trajectory: What is .claude/ Evolving Toward?

Reading the last 8 completed tasks and the pending task 9 plan as a series, the direction is legible:

- **Consolidation of user-facing surface.** `/talk` was folded into `/slides`; `docs/office-workflows.md` was split into four files, two of which were then consolidated in task 9's plan. The pattern: multiple commands/docs are being merged under fewer, better-named umbrellas.
- **Lifecycle-completeness as an explicit goal.** Task 9 exists to guarantee every `.claude/commands/*.md` has a narrative home in `docs/workflows/`. The new `plan-format-enforcement.md` rule and the `check-extension-docs.sh` script apply the same lifecycle-completeness standard to the internal `.claude/` tree. These are both "close the coverage gap" moves.
- **macOS-only, Zed-only, non-NixOS.** Tasks 6 and 7 stripped NixOS from `docs/installation.md` and made Zed+macOS+Homebrew the single assumed baseline. The `.claude/CLAUDE.md` file still carries neovim/nix extension scaffolding, but `docs/` has correctly treated that as *not applicable here* (see `docs/agent-system/architecture.md:95`).
- **"Thin wrapper" discipline.** The `commands.md` file and each workflow file are intentionally terse and defer to `.claude/docs/guides/user-guide.md`. Task 8 summary: "docs/agent-system/ is now purely reference documentation... docs/workflows/ holds the user-facing narratives." That separation is holding.
- **Auto-memory vs vault is stabilized.** Tasks 3-6 settled the `.memory/` vs `~/.claude/projects/.../memory/` story; that text has not been touched in this diff and does not need re-litigation.

**Implication for task 10**: The diff is fundamentally *housekeeping*, not *direction change*. The strategic move is therefore to (a) fix the drift cleanly, (b) resolve the task 9 collision explicitly, and (c) install a lightweight drift check so task 11 isn't forced to do the same cleanup. A structural restructure would betray the direction the project is actually going.

## Strategic Opportunities in This Task (Beyond Mechanical Sync)

Non-obvious wins the orchestrator should consider on top of the diff catalog work from other teammates:

### Opportunity A: Install a docs-sync lint (20-30 lines of bash)

`.claude/scripts/check-extension-docs.sh` already exists and validates extension docs. An equivalent `docs/` lint could verify:
- Every file in `.claude/commands/` is mentioned in `docs/agent-system/commands.md`.
- The command-count claim in `docs/agent-system/commands.md`, `docs/agent-system/README.md`, `docs/workflows/agent-lifecycle.md`, and `docs/agent-system/architecture.md` matches `ls .claude/commands/ | wc -l`.
- No doc mentions a command file that does not exist.
- No doc shows a `Co-Authored-By` trailer (per `.claude/CLAUDE.md` new preference note).
- Optional: `docs/agent-system/commands.md` command list is alphabetically in sync with `.claude/commands/*.md`.

Cost: one script, ~30 lines. Payoff: every future `.claude/CLAUDE.md` edit gets an immediate signal.

### Opportunity B: Parameterize the command count (remove a moving number)

The number "24" appears in four places in `docs/`, and is already wrong (should be 23). Instead of replacing "24" with "23" by hand, **replace it with a non-numerical phrase**: "all slash commands in this workspace" or "the full command catalog". This removes a recurring drift vector permanently. The same applies to any other "N commands" counters.

### Opportunity C: Make the task 9 plan revision a prerequisite, not an afterthought

Task 9's plan still names `/talk` and `.claude/commands/talk.md` in phases 3 and elsewhere. If task 10 lands first and fixes the drift, task 9's next `/implement` invocation will create a workflow doc for a command that does not exist. The strategic move is:

- **Recommended**: Before task 10 implements, run `/revise 9` to update the task 9 plan to say `/slides` (grant extension) or fold talk content into `/slides`'s new workflow.
- **Alternative**: Make task 10 explicitly edit `specs/009_.../plans/01_workflow-docs-plan.md` as part of its scope. That keeps it atomic.
- **Do not** let task 10 complete and task 9 implement in that order without a revision step. The two tasks are entangled.

### Opportunity D: Introduce a "canonical facts" block at the top of CLAUDE.md consumers

`docs/agent-system/architecture.md:95` already documents one drift point ("That loader does not apply in this Zed workspace"). This is a good pattern: a short note that explicitly says "this fact in `.claude/CLAUDE.md` is neovim-only and not true here". Task 10 could generalize this: a small "Zed adaptations" box in `docs/agent-system/README.md` that lists the specific `.claude/CLAUDE.md` facts that are *deliberately* overridden in `docs/` (commit trailer policy, extension loader n/a, neovim keybindings n/a, etc.). This turns drift detection from "track every word" into "check this one list".

### Opportunity E: Stop mentioning specific numbered extensions in `docs/`

`docs/` currently inherits `.claude/CLAUDE.md`'s extension catalog (epidemiology, filetypes, latex, memory, present, typst) indirectly. But in the Zed workspace, the extension-loading `<leader>ac` keybinding does not exist and extensions are *always on*. The strategic move: `docs/` should talk about commands as a flat set, with a "requires the X extension" callout on individual commands only where it affects user behavior. Task 9's plan already does this correctly for memory/present. Task 10 could remove any remaining "extension-gated" framing from `docs/agent-system/` reference files, since the concept does not meaningfully apply in this workspace.

## Structural Recommendations for docs/

**Do not restructure.** The current four-way split (`general/` + `agent-system/` + `workflows/` + root README) is correct and was validated by tasks 6-8. Preserve it.

**Do these small moves:**

1. **Add `docs/workflows/README.md#see-also`** entries for each new task 9 file once task 9 lands. This is already on task 9's checklist; task 10 should verify it.
2. **Collapse the "24 commands" number** to a non-numerical phrase in all four locations (see Drift Detection below).
3. **Add a small "Zed adaptations" section** to `docs/agent-system/README.md` that lists the three `.claude/CLAUDE.md` facts explicitly not applicable in this workspace: (a) no extension loader, (b) no `Co-Authored-By` trailer, (c) no `<leader>ac` keybinding. This turns "drift" into "intentional override" and gives future tasks a single place to update.
4. **Do not** create `docs/reference/` or `docs/guides/` as new top-level directories. The three-way split is sufficient and was recently stabilized.
5. **Do not** duplicate `.claude/CLAUDE.md` content into `docs/`. Keep the link-down-into-.claude/ discipline.

## Drift Detection: Docs Content That Is Already Stale or Contradictory

Verified by direct inspection of `.claude/` diff vs `docs/` tree:

| # | File | Line/Pattern | Current (stale) | Should be | Driver |
|---|------|-------------|-----------------|-----------|--------|
| 1 | `docs/agent-system/commands.md` | line 3 | "All 24 slash commands in this workspace" | "All slash commands in this workspace" (or "23") | `.claude/commands/talk.md` deleted |
| 2 | `docs/agent-system/commands.md` | lines 312-330 | Full `### /talk` section with example `/talk "job talk..."` and link to `.claude/commands/talk.md` | Remove section; fold into `### /slides` section (which already exists at line 217) | Same |
| 3 | `docs/agent-system/commands.md` | line 227, 317-319, 330 | Examples `/talk ...`, link to `.claude/commands/talk.md` | Replace with `/slides` equivalents | Same |
| 4 | `docs/agent-system/README.md` | line 20 | "all 24 Claude Code commands" | "the Claude Code command catalog" | Same |
| 5 | `docs/agent-system/architecture.md` | line 84 | "# 24 slash command definitions" | "# slash command definitions" | Same |
| 6 | `docs/agent-system/architecture.md` | line 95 | "All 24 commands are always available" | "All commands are always available" | Same |
| 7 | `docs/workflows/agent-lifecycle.md` | line 120 | "Full catalog of all 24 commands" | "Full command catalog" | Same |
| 8 | `docs/agent-system/architecture.md` | lines 56-58 | Example commit message shows `Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>` trailer | Remove the trailer line from the example; add a sentence saying "This workspace omits the `Co-Authored-By` trailer per user preference" | New `.claude/CLAUDE.md` note: "omit `Co-Authored-By` trailers from all commits" |
| 9 | `docs/agent-system/commands.md` | `/slides` entry at line 217 | Description does not mention research-talk forcing questions; example `/slides deck.pptx --format beamer` only covers the conversion flavor | Expand to cover both (a) conversion (`/slides deck.pptx`) and (b) task creation with forcing questions (`/slides "Description"`, `/slides N`, `/slides /path/to/file`) | `.claude/commands/slides.md` was modified; `/slides` now does both the old `/slides` conversion job *and* the old `/talk` task-creation job |
| 10 | `docs/general/settings.md` | any mention of `/spawn` or `spawn-agent` | Not yet present in docs/ | Add brief reference in `docs/agent-system/commands.md` (spawn is already there at line 232-ish -- verify) and ensure the command table in `docs/agent-system/README.md` is not claiming a wrong count | `/spawn` present and `.claude/CLAUDE.md` still lists it |
| 11 | `docs/workflows/agent-lifecycle.md` (task 9 pending file) | N/A yet | Task 9 plan phases 3 reference `/talk` | Revise before task 9 implements | `.claude/commands/talk.md` deleted |
| 12 | `docs/` anywhere | `ROAD_MAP.md` | Not present in docs/ | N/A -- internal `.claude/` only, correct | `.claude/CLAUDE.md` diff fixed `ROAD_MAP.md` -> `ROADMAP.md`; verify no doc ever references the wrong spelling |
| 13 | `docs/agent-system/commands.md` | `/tag` entry | Description says "(user-only)" | Keep; verify the note that `.claude/commands/tag.md` does not exist is preserved (per task 6 summary) | No change needed; flagging for verification |

**Non-drift items verified safe:**
- Two-memory-layers story in `docs/agent-system/context-and-memory.md` is unchanged and still correct.
- `docs/general/installation.md` claude-acp setup is unchanged and still correct.
- `docs/agent-system/zed-agent-panel.md` ACP bridge explanation is unchanged and still correct.
- `docs/agent-system/architecture.md` three-layer pipeline diagram is unchanged and still correct.
- `.claude/CLAUDE.md` added a reference to `.claude/rules/plan-format-enforcement.md`; this is internal-only and does not need to be reflected in `docs/`.
- `.claude/CLAUDE.md` added `.claude/scripts/check-extension-docs.sh` to Utility Scripts; this is internal-only.

## Scope Recommendation

Three tiers of ambition. The orchestrator and planner should pick one, not mix.

### Tier 1: Minimal Mechanical (recommended baseline)

**What**: Fix the 13 drift items above, nothing else. Parameterize the "24 commands" number to a non-numerical phrase. Update `/slides` to cover both roles. Drop the `Co-Authored-By` line from the architecture.md example and add a one-line explanation. Revise `specs/009_.../plans/01_workflow-docs-plan.md` in the same PR to unblock task 9.

**Cost**: ~1 hour. Four files touched in `docs/` + one plan file touched in `specs/`.

**Trade-off**: Fast, safe, preserves the task-8 structure. Does *not* prevent the next `.claude/CLAUDE.md` edit from creating the same problem. Does *not* add the Zed-adaptations section.

**When to pick**: Default. Pick this unless you have a specific reason to go further.

### Tier 2: Minimal + Zed-adaptations box + parameterization (recommended strategic)

**What**: Tier 1, plus:
- Add a short "Zed adaptations" section to `docs/agent-system/README.md` listing the three intentional overrides (no extension loader, no co-author trailer, no `<leader>ac`).
- Replace every numerical "N commands" phrase with a non-counting phrase, project-wide.
- Explicitly resolve the task 9 collision by editing task 9's plan as part of the same PR.

**Cost**: ~2 hours. Adds one new section (~20 lines) and a small find/replace pass.

**Trade-off**: Slightly more surface area but delivers a single place to manage future CLAUDE.md drift. Task 9 can then implement cleanly.

**When to pick**: If the user has time for one small structural improvement and wants to reduce future maintenance. This is my recommended tier.

### Tier 3: Strategic + drift-lint script (ambitious)

**What**: Tier 2, plus:
- Write `.claude/scripts/check-docs-sync.sh` modeled on the existing `check-extension-docs.sh`. Verifies command-file presence, count-phrase absence, and trailer absence.
- Add a line to `docs/agent-system/README.md` pointing at the script.

**Cost**: ~3 hours. One new script file (~40 lines), one extra doc line, plus Tier 2.

**Trade-off**: Highest up-front cost; durable payoff. This closes the drift problem, not just this instance. The script belongs in `.claude/scripts/` (source of truth) rather than `docs/`.

**When to pick**: Only if the user explicitly wants a sustainable fix and is willing to treat "docs/ matches .claude/" as an invariant going forward. Otherwise Tier 2.

## Confidence Level

**High** on drift items 1-9 and the task-9 collision -- all verified by direct grep/diff inspection.

**Medium** on the Tier 2 Zed-adaptations box being the right pattern -- it is a plausible extension of the existing `architecture.md:95` note but has not been discussed elsewhere. A planner may reasonably disagree on placement.

**Medium-low** on Tier 3 script specification -- I did not read `check-extension-docs.sh` contents, only its mention in the diff. The script's design should be verified before scoping.

**High** on the overall recommendation that task 10 is housekeeping and should not restructure `docs/`. Tasks 6 and 8 established the current structure within the last week; restructuring now would thrash recently stabilized work.

## References

- `.claude/CLAUDE.md` diff (working tree) -- drivers for drift items 1-9, 12
- `docs/agent-system/commands.md` -- 9 direct drift hits verified
- `docs/agent-system/README.md` -- structure contract for `docs/`
- `docs/workflows/README.md` -- task-8 structure that should be preserved
- `specs/TODO.md` -- task 9 pending status
- `specs/009_workflow_docs_for_commands/plans/01_workflow-docs-plan.md` -- task 9 collision source
- `specs/008_split_workflows_into_directory/summaries/01_split-workflows-directory-summary.md` -- validation of current `docs/` structure
- `specs/006_expand_agent_system_docs/summaries/01_expand-docs-directory-summary.md` -- origin of the three-way split and `/tag` caveat
