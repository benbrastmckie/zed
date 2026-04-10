# Teammate C: Critic

**Task**: 9 - Populate docs/workflows/ with command workflow guides
**Role**: Critic — identify gaps, assumptions, blind spots, and risks
**Started**: 2026-04-10T00:00:00Z
**Completed**: 2026-04-10T00:30:00Z

---

## Unvalidated Assumptions

### 1. The audience is a human user unfamiliar with the system

The task description says "populate docs/workflows/ with workflows covering all commands." Reading `docs/workflows/README.md` reveals that the existing docs are explicitly written for humans: narrative prose, "Common scenarios" sections, step-by-step guidance, and macOS keybindings like `Cmd+\``. However:

- There is no explicit statement of audience in `README.md` or any existing workflow doc.
- The `docs/agent-system/` directory also says "For the authoritative power-user reference, see `.claude/CLAUDE.md`" — implying `docs/` is not the power-user reference.
- The description in `README.md` ("End-to-end usage narratives") suggests workflow docs are narrative, not reference. But this is only stated for workflows/, not proven by policy.
- **Risk**: If implementers assume docs/workflows/ serves Claude Code agents (i.e., injected as context), they will write differently than if the audience is a returning human user. There is no evidence either way beyond stylistic hints.

### 2. "All 24 commands" means all 24 commands require individual workflow treatment

The task says "covering all commands" and lists 24. But the existing `docs/agent-system/commands.md` already has brief coverage of all 24, and `docs/workflows/agent-lifecycle.md` covers the 7 lifecycle commands in depth. An assumption is being made that:

- "Covering" means distinct narrative workflow docs, not acknowledgment within a shared reference
- 24 individual commands -> some nonzero number of new workflow files

Neither is stated explicitly. "Covering" could mean adding a one-liner to `README.md`'s decision guide. This assumption is load-bearing for the entire scope of work.

### 3. Existing workflow docs should remain unchanged

No guidance is given on whether `agent-lifecycle.md`, `convert-documents.md`, `edit-word-documents.md`, `edit-spreadsheets.md`, or `tips-and-troubleshooting.md` should be modified. The implementer will likely leave them alone, but:

- Some existing docs already partially cover maintenance commands (e.g., `agent-lifecycle.md` mentions `/spawn`, `/revise`, `/errors` by reference).
- New docs that overlap with existing ones will create inconsistency without updating the old docs.
- The `README.md` decision guide and "See also" sections will need to be updated regardless — but to what extent is unspecified.

### 4. The grouping in `commands.md` is the correct grouping for workflow docs

`docs/agent-system/commands.md` uses groups: Lifecycle, Maintenance, Memory, Documents, Research & Grants. The implementer will likely mirror this grouping. But workflow groupings may differ from reference groupings: `/merge` and `/tag` are "Maintenance" in the command catalog but have fundamentally different audiences (user-only vs. everyday). A workflow perspective might group differently.

---

## Gaps in Task Definition

### Gap 1: Depth not specified

The task says "workflows covering all commands." The existing workflow docs (`agent-lifecycle.md`, `convert-documents.md`) are 80-120 lines each with concrete examples, decision guides, and troubleshooting notes. A one-paragraph treatment per command would technically "cover" the command but provide negligible value over the existing `commands.md` reference.

There is no definition of minimum coverage depth. Implementers will guess.

### Gap 2: File count and grouping not specified

"Grouping related commands together" is vague. Options range from:
- One new file per command group (5 groups = 5 files, some very small)
- One file per command (24 files, mostly stubs)
- One or two additional files for the uncovered groups, leaving existing files intact

Without a specification, implementers will make a judgment call. Different teammates may make different calls and produce incompatible proposals.

### Gap 3: Treatment of extension-only commands is unspecified

12 of 24 commands (`/grant`, `/budget`, `/timeline`, `/funds`, `/talk`, `/convert`, `/table`, `/slides`, `/scrape`, `/edit`, `/learn`, and possibly `/tag`) require extensions to be loaded. The caveats needed are non-trivial:

- `/grant`, `/budget`, `/timeline`, `/funds`, `/talk` require the `present` extension
- `/convert`, `/table`, `/slides`, `/scrape`, `/edit` require the `filetypes` extension
- `/learn` requires the `memory` extension
- `/tag` is "user-only" and has no extension requirement but behavioral restrictions

No guidance is given on whether to:
- Include a standard "requires extension X" callout
- Group extension-gated commands separately from core commands
- Simply not document extension commands in workflows/ (they have dedicated docs elsewhere)
- Document the pattern of loading extensions first as a prerequisite step

### Gap 4: Staleness/maintenance strategy not specified

The task asks to create docs but does not ask about how they will be kept current. This is a structural gap:

- `.claude/commands/*.md` files are the authoritative source; workflow docs are derived.
- If a command gains a flag or changes behavior, workflow docs are likely to drift.
- There is no sync mechanism, no "last-verified" metadata, and no cross-reference policy stated.
- The task description does not ask about this, which means the implementation will almost certainly ignore it.

### Gap 5: Relation to `commands.md` not resolved

`docs/agent-system/commands.md` already covers all 24 commands with a one-line summary + example + flag list + link per command. The file explicitly says: "Each entry is intentionally terse: one-sentence summary, minimal example, flag list, and link into `.claude/`. For examples and edge cases, follow the links."

So "follow the links" is where the depth should live. The task may be asking to populate the target of those links. But this relationship is not stated in the task description, and `commands.md` currently links to `.claude/` docs and `.claude/commands/` source files — not to `docs/workflows/`. Any new workflow docs would need those links updated too, which is not in scope as stated.

---

## Duplication / Staleness Risks

### Risk 1: Four-layer redundancy already exists

Command documentation currently exists in:
1. `.claude/commands/*.md` — authoritative source, machine-readable frontmatter, used by Claude Code
2. `.claude/CLAUDE.md` — command reference table, always-loaded context
3. `docs/agent-system/commands.md` — human-readable terse catalog
4. `docs/workflows/agent-lifecycle.md` — narrative workflow for 7 lifecycle commands

Adding a 5th layer (`docs/workflows/*.md` for remaining commands) increases the surface area for staleness. Every change to a command may need to be reflected in up to 5 locations. There is no cross-reference enforcement.

### Risk 2: `agent-lifecycle.md` already covers 7 of 24 commands in depth

The lifecycle commands (`/task`, `/research`, `/plan`, `/implement`, `/revise`, `/review`, `/todo`) are already covered with state machine diagrams, resumability notes, exception state handling, and multi-task syntax. Any new "workflow" docs for these commands would either:
- Duplicate content that already exists (staleness risk)
- Defer to `agent-lifecycle.md` (adding no value)
- Restructure and partially replace it (scope creep, breaking existing links)

### Risk 3: `convert-documents.md` already covers 4 of 24 commands

`/convert`, `/table`, `/slides`, `/scrape` are documented in `convert-documents.md` with examples and a decision guide. `edit-word-documents.md` covers `/edit`. These 5 commands have existing workflow documentation. The task does not distinguish "commands already covered" from "commands needing coverage."

### Risk 4: The uncovered commands are the hardest to write workflows for

After removing the 12 commands already covered (7 lifecycle + 5 document commands), the truly uncovered commands are the maintenance cluster and the research/grants cluster. These are either:
- Narrow operational commands (`/errors`, `/refresh`, `/fix-it`, `/spawn`, `/tag`, `/merge`) — where a "workflow" is a 5-step procedure unlikely to need a full doc
- Domain-specific commands (`/grant`, `/budget`, `/timeline`, `/funds`, `/talk`) — where the workflow is highly variable by project type and hard to document generically

The "hard" commands are the ones without existing docs, creating an imbalance.

---

## Questions That Should Be Asked

1. **Is `docs/workflows/` read by humans, by Claude Code agents, or both?** The answer determines prose style, link format, depth, and whether frontmatter metadata is needed.

2. **What does "covered" mean for a command?** Is a one-sentence mention in `README.md`'s decision guide sufficient? Does each command need its own section? Its own file?

3. **Should the 5 commands already covered by existing workflow docs be left out of scope?** Or should those docs be updated to signal completeness?

4. **How should extension-gated commands be flagged?** Should there be a standard callout, a separate section, or a prerequisite note at the top of each file?

5. **Who will maintain these docs after task completion?** If the answer is "nobody until they break," then the depth of new docs should be proportional to how long they will remain accurate.

6. **Is there any user feedback about what was confusing?** The most valuable workflow docs address real confusion. Writing generic ones from the command source risks producing docs that answer questions nobody has.

7. **Should new workflow docs link into `.claude/commands/` source, or into `docs/agent-system/commands.md`?** These serve different audiences and the choice signals the intended reader.

8. **Should `/tag` be documented in workflows?** It is user-only (agents cannot invoke it), which makes it unusual. Its workflow is: check branch, decide version bump, run `/tag --patch`. This is 3 lines, not a workflow doc.

9. **Does `/merge` belong in a "workflows" doc at all?** It is a thin wrapper around `gh pr create`. The workflow is the same as any GitHub PR workflow, just invoked via slash command.

---

## What Success Looks Like (proposed explicit criteria)

Given the ambiguities above, here is a proposed definition of success that the task description does not provide:

**Minimum viable success**:
- Every command not already covered by an existing workflow doc (agent-lifecycle, convert-documents, edit-word-documents, edit-spreadsheets) has at least one sentence in `docs/workflows/README.md`'s decision guide explaining when to use it.
- `README.md` is updated to reference any new files.

**Moderate success** (likely what the task intends):
- 2-3 new workflow files covering the currently uncovered command groups: maintenance commands (`/errors`, `/refresh`, `/fix-it`, `/spawn`, `/tag`, `/merge`, `/meta`) and research/grant commands (`/grant`, `/budget`, `/timeline`, `/funds`, `/talk`), and the memory command (`/learn`).
- Each file follows the same structure as existing ones: decision guide, per-command section with examples, cross-links.
- Extension-gated commands have a standard "requires X extension" callout.
- `README.md` is updated with new table rows and decision guide entries.

**Strong success** (probably over-scoped):
- All 24 commands have dedicated workflow prose.
- Docs are de-duplicated (agent-lifecycle and convert-documents updated to cross-reference new files rather than stand alone).
- A maintenance policy is documented (e.g., "update this file when `.claude/commands/X.md` changes").

**Proposed explicit acceptance criteria** (if I were writing the task spec):
1. `docs/workflows/README.md` decision guide covers all 24 commands with at least one "I want to..." entry each.
2. New docs follow the existing style (decision guide + per-command sections + cross-links).
3. Extension-gated commands are flagged with a consistent callout.
4. No content is duplicated between new docs and existing `commands.md` or `agent-lifecycle.md` — workflow docs reference these rather than repeat them.
5. All new files are linked from `README.md`.

---

## Confidence

**Confidence: high** that the gaps and risks identified here are real — they are structural properties of the task definition and the existing documentation landscape, not speculation. The critique is grounded in direct reading of `docs/workflows/README.md`, `docs/agent-system/commands.md`, `docs/workflows/agent-lifecycle.md`, `docs/workflows/convert-documents.md`, and the `.claude/commands/` listing.

**Confidence: medium** on the proposed success criteria — these are reasonable inferences from the existing docs' style and scope, but the true intent can only be confirmed by the user who created the task.
