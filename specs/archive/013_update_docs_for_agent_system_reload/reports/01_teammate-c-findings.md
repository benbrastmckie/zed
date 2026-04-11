# Teammate C Findings: Gaps and Inconsistencies in docs/ After Agent System Reload

**Task**: Update docs/ documentation to reflect reloaded .claude/ agent system changes
**Role**: Critic — identify gaps, shortcomings, and blind spots
**Date**: 2026-04-10

---

## Key Findings

### 1. /epi Command is Entirely Missing from docs/

The `/epi` command is a newly added, untracked file (`.claude/commands/epi.md`). It is a substantial command — 10-question forcing flow, three input modes, routing to `epi:study` task type — comparable in scope to `/grant` or `/slides`. Yet:

- `docs/agent-system/commands.md` claims "all 24 slash commands" but `/epi` is not listed. With `/epi` added, there are now **25 commands** (24 command files + `/tag` which has no file).
- `docs/workflows/agent-lifecycle.md` says "Seven commands...the remaining **17** commands in commands.md layer on top." With `/epi`, the count becomes 18.
- `docs/workflows/README.md` has no epidemiology section and no row in its decision guide for `/epi`.
- No `docs/workflows/epidemiology-analysis.md` exists, unlike the analogous `grant-development.md` and `memory-and-learning.md` for other extension commands.

### 2. Old Epidemiology Skill and Agent Names are Stale in architecture.md

`docs/agent-system/architecture.md` line 121 says:

> Every extension entry in `.claude/CLAUDE.md` (epidemiology, filetypes, latex, memory, present, typst) is pre-merged into the active configuration in this workspace.

This sentence is still accurate (the extension names haven't changed), but the routing table it implicitly references is now different. Anyone following the cross-reference to `.claude/CLAUDE.md` will find the new skill/agent names (`skill-epi-research`, `epi-research-agent`, etc.) — which is fine — but the docs themselves never show those names, which leaves a gap for users who want to understand routing without reading CLAUDE.md.

The architecture.md routing table at line 127–132 only shows core task types (`general`, `meta`, `markdown`) and refers readers to CLAUDE.md for specialty routing. This is not wrong per se, but it means all documentation of the *changed* epi routing lives only in CLAUDE.md, not in the user-facing docs.

### 3. docs/ Never Documented Old Epidemiology Names Either — But Now Has a Forward Reference Gap

No doc in `docs/` directly named `skill-epidemiology-research`, `epidemiology-research-agent`, or `skill-epidemiology-implementation` (grep returns empty). So there are no stale hardcoded old names in docs/ to fix. **However**, this means docs/ was already under-documenting the epidemiology extension before the reload. The reload makes this more visible by adding a dedicated command (`/epi`) that is completely absent from docs/.

### 4. `<leader>ac` Notes Are Incorrect for Zed (Pre-Existing Inconsistency Exposed by This Change)

Two workflow docs carry a note that contradicts architecture.md:

- `docs/workflows/grant-development.md:5` — "**Requires the `present` extension.** Load it via `<leader>ac` before using these commands."
- `docs/workflows/memory-and-learning.md:5` — "**Requires the `memory` extension.** Load it via `<leader>ac` before using these commands."

`docs/agent-system/architecture.md:119` explicitly states: "That loader does not apply in this Zed workspace. All commands are always available; there is no `<leader>ac` or equivalent extension-loading keybinding."

This pre-existing inconsistency is not caused by the reload, but any new `/epi` workflow doc copied from these templates would perpetuate it. The same incorrect note could easily be added to an epidemiology workflow doc if authors follow the existing pattern.

### 5. Command Count Claim in commands.md is Now Wrong

`docs/agent-system/commands.md:3` — "Quick-reference catalog of all **24** slash commands."

Before the reload, there were 23 command files plus `/tag` (no file) = 24. Now there are 24 command files plus `/tag` = 25. The "24" is now incorrect and would mislead users who try to reconcile the catalog count with what they see in the command system.

### 6. agent-lifecycle.md "Remaining 17" Count is Now Wrong

`docs/workflows/agent-lifecycle.md:3` — "the remaining **17** commands in commands.md layer on top."

Seven core lifecycle commands + 17 = 24. Adding `/epi` makes the residual count 18. Both the number and the link to commands.md need updating.

### 7. No Validation of `.claude/docs/` Cross-References

Multiple docs/ files link deep into `.claude/docs/` (e.g., `../../.claude/docs/guides/user-guide.md`, `../../.claude/docs/examples/fix-it-flow-example.md`). These are not affected by the epidemiology reload, but the assumption that all such cross-references are valid has not been checked. If any `.claude/docs/` path was moved or removed during the reload, the links would silently break. The git diff shows no `.claude/docs/` changes, so these are likely intact — but no teammate has verified this.

---

## Recommended Approach

### What Is Likely Being Overlooked

The other teammates (A and B) are presumably cataloging changes to `.claude/` files and mapping them to docs/ updates. The natural focus is on renaming old references. But the **bigger gap** is not stale names (there are none in docs/) — it is the **total absence of /epi documentation**.

The implementation plan should include:

1. **Add `/epi` entry to `docs/agent-system/commands.md`** — under a new "Epidemiology" section or appended to "Research & Grants", with the same format as `/grant` and `/slides` (2-sentence explanation, examples, input modes, link to skill source).

2. **Update command count** in `docs/agent-system/commands.md:3` from "24" to "25".

3. **Update "remaining 17 commands"** in `docs/workflows/agent-lifecycle.md:3` to "remaining 18 commands".

4. **Create `docs/workflows/epidemiology-analysis.md`** — a workflow narrative parallel to `grant-development.md`, covering the `/epi` forcing-questions flow, the `epi:study` task type, the R-based research/plan/implement lifecycle, and the `--remember` flag for reusing prior analysis findings. This is the highest-value missing doc.

5. **Add epidemiology row to `docs/workflows/README.md`** — in both the Contents table and the Decision guide.

6. **Fix `<leader>ac` notes** in `grant-development.md` and `memory-and-learning.md` — replace with a note consistent with architecture.md ("All extensions are pre-loaded in this workspace; no activation step is needed"). Ensure any new `/epi` workflow doc does NOT include the same incorrect note.

7. **Do not add routing-table detail** for the new `epi`/`epi:study` task types to architecture.md — the existing design defers specialty routing to CLAUDE.md, which is appropriate. The fix is to make docs/ surface the command, not to duplicate the routing table.

---

## Evidence/Examples

| Issue | File | Line | Detail |
|-------|------|------|--------|
| `/epi` missing from catalog | `docs/agent-system/commands.md` | 3 | Claims "all 24 slash commands"; /epi absent entirely |
| Wrong command count | `docs/agent-system/commands.md` | 3 | "24" should be "25" after /epi addition |
| Wrong residual count | `docs/workflows/agent-lifecycle.md` | 3 | "remaining 17 commands" should be "remaining 18" |
| No epidemiology workflow doc | `docs/workflows/` | — | No `epidemiology-analysis.md`; grant-development.md and memory-and-learning.md exist as analogues |
| No epi entry in workflows README | `docs/workflows/README.md` | — | Contents table and Decision guide have no row for epidemiology or `/epi` |
| Incorrect `<leader>ac` note | `docs/workflows/grant-development.md` | 5 | Contradicts architecture.md:119 |
| Incorrect `<leader>ac` note | `docs/workflows/memory-and-learning.md` | 5 | Contradicts architecture.md:119 |
| Old epi skill names only in CLAUDE.md | `docs/agent-system/architecture.md` | 121–133 | Specialty routing not surfaced in user-facing docs |

---

## Confidence Level

**High** for findings 1–6 (verified by grep, git diff, and direct file reads).

**Medium** for finding 7 (`.claude/docs/` cross-reference validity) — git diff shows no `.claude/docs/` deletions during this reload, so the risk is low, but the assumption was not fully checked since it would require verifying each linked path exists on disk.
