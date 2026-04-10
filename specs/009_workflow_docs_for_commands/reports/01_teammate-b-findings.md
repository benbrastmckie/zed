# Teammate B: Alternative Approaches

**Task**: 9 - Populate docs/workflows/ with workflows covering all commands
**Teammate**: B — Alternative Approaches & Prior Art
**Started**: 2026-04-10T00:00:00Z
**Completed**: 2026-04-10T00:20:00Z
**Effort**: ~1 hour research
**Sources**: Codebase glob/grep/read, sibling nvim config

---

## Prior Art Found

### 1. `docs/workflows/agent-lifecycle.md` (already exists)

**Path**: `/home/benjamin/.config/zed/docs/workflows/agent-lifecycle.md`

Covers the five core lifecycle commands (`/task`, `/research`, `/plan`, `/implement`, `/todo`) in full narrative form with state machine diagram, artifact paths, exception states, and advanced flags (`--team`, `--remember`, multi-task syntax). **High-quality existing content that must not be duplicated** — any new lifecycle doc should simply point here.

Also contains a "For the rest of the command catalog, see commands.md" line (line 116), establishing that `commands.md` is the cross-reference destination for commands not covered.

### 2. `docs/agent-system/commands.md` (already exists)

**Path**: `/home/benjamin/.config/zed/docs/agent-system/commands.md`

Already contains a full catalog of all 24 commands, grouped as: Lifecycle, Maintenance, Memory, Documents, Research & Grants. Each entry has a one-sentence summary, minimal usage example, flag list, and a link into `.claude/commands/` and `user-guide.md`. This file was written for terse reference. The existing groupings here are the "obvious" first cut and are the most likely scheme Teammate A recommends.

**Implication**: Any new `docs/workflows/` files should not duplicate this reference material. Instead they should provide *narrative workflows* — step-by-step use cases that link back to `commands.md` for flag details, just as `agent-lifecycle.md` does.

### 3. `docs/workflows/convert-documents.md` (already exists)

**Path**: `/home/benjamin/.config/zed/docs/workflows/convert-documents.md`

Covers `/convert`, `/table`, `/slides`, `/scrape` in a decision-guide + per-command section structure. This is the gold-standard pattern for what new workflow files should look like: decision table at the top, then sections per command, using scenario-driven prose not reference tables.

### 4. `.claude/docs/guides/user-guide.md` (internal, not user-facing docs/)

**Path**: `/home/benjamin/.config/zed/.claude/docs/guides/user-guide.md`

A comprehensive command-by-command reference with status progression table, examples per command, and troubleshooting. This is the **internal** authoritative reference and is identical in structure to the nvim sibling at `/home/benjamin/.config/nvim/.claude/docs/guides/user-guide.md`. Both use "Core Workflow / Maintenance / Utility" groupings. New workflow docs should link here for flag-level details rather than duplicating.

### 5. `.claude/docs/examples/research-flow-example.md` and `fix-it-flow-example.md`

**Paths**:
- `/home/benjamin/.config/zed/.claude/docs/examples/research-flow-example.md`
- `/home/benjamin/.config/zed/.claude/docs/examples/fix-it-flow-example.md`

Trace single commands through the three-layer architecture. These are internal developer-facing examples. They are a good reference for the narrative content of maintenance workflow docs, but should not be directly replicated in user-facing `docs/workflows/`.

### 6. nvim sibling: `.claude/context/workflows/` and `.claude/context/processes/`

**Paths**:
- `/home/benjamin/.config/nvim/.claude/context/workflows/command-lifecycle.md` — 8-stage lifecycle, status transitions
- `/home/benjamin/.config/nvim/.claude/context/processes/research-workflow.md` — routing logic
- `/home/benjamin/.config/nvim/.claude/context/workflows/review-process.md`
- `/home/benjamin/.config/nvim/.claude/context/workflows/task-breakdown.md`

These are agent-internal context files (not user docs). They document internal mechanics (routing tables, preflight/postflight). They are **poor models for user-facing workflows** but confirm what is covered internally, which informs what is still missing for users.

### 7. nvim deprecated task-delegation docs

**Path**: `/home/benjamin/.config/nvim/deprecated/task-delegation/docs/SUBAGENT_WORKFLOW_COMPARISON.md`

Pre-dates the current three-layer architecture. Not directly adaptable but shows that the comparison "narrative approach" (comparing workflows) has been tried before.

### 8. `docs/workflows/README.md` (existing index)

**Path**: `/home/benjamin/.config/zed/docs/workflows/README.md`

Already contains a "decision guide" table mapping user intentions to workflow docs, plus "common scenarios" section. This is the entry point. Any new files must be registered here with a decision-guide row.

---

## Alternative Grouping Schemes

The obvious scheme (used in `docs/agent-system/commands.md`) is **by workflow phase**: Lifecycle / Maintenance / Memory / Documents / Research & Grants. Below are two distinct alternatives.

### Scheme A: By Output Artifact Type

Group commands by what they produce, not when you use them.

| Group | Commands | Output Artifact |
|-------|----------|----------------|
| Task artifacts | `/task`, `/research`, `/plan`, `/implement`, `/revise`, `/todo` | specs/ task directories, reports, plans, summaries |
| Codebase intelligence | `/review`, `/errors`, `/fix-it` | Analysis reports, error fix plans, task lists |
| Memory & knowledge | `/learn` | .memory/ vault entries |
| Document conversions | `/convert`, `/table`, `/slides`, `/scrape`, `/edit` | Markdown, PDF, LaTeX/Typst, DOCX |
| Research outputs | `/grant`, `/budget`, `/timeline`, `/funds`, `/talk` | Proposals, XLSX budgets, timelines, Slidev decks |
| Infrastructure | `/meta`, `/refresh`, `/spawn`, `/merge`, `/tag` | .claude/ system changes, git tags, PRs |

**Pros**:
- Matches how users think when they know *what they want to produce*, not which command to use
- Natural fit for a "cookbook" or "recipe" doc structure ("I want a LaTeX table from my data")
- Minimal overlap between groups

**Cons**:
- `/task` and `/research` feel strange grouped with heavy artifact producers like `/implement`
- Infrastructure group is a heterogeneous catch-all (meta, refresh, spawn, merge, tag have very different purposes)
- Doesn't map to the natural workflow order, so onboarding is harder

### Scheme B: By User Role / Intent (Who Runs This?)

Group commands by the primary activity or role of the person invoking them.

| Group | Commands | Who / When |
|-------|----------|-----------|
| Doing a development task | `/task`, `/research`, `/plan`, `/implement`, `/revise`, `/todo` | Primary development loop |
| Reviewing & quality | `/review`, `/errors`, `/fix-it` | Periodic housekeeping, CI-adjacent |
| Building the agent system | `/meta`, `/spawn`, `/refresh`, `/tag`, `/merge` | System administrator / maintainer |
| Academic / research work | `/grant`, `/budget`, `/timeline`, `/funds`, `/talk` | Academic researcher role |
- Working with documents | `/convert`, `/table`, `/slides`, `/scrape`, `/edit` | Office doc user |
| Building institutional memory | `/learn` | Anyone after completing work |

**Pros**:
- Aligns with real user personas (the "grant writer" vs "developer" vs "system admin")
- Very scannable: user self-selects their role and sees only relevant commands
- Avoids splitting commands that naturally co-occur (grant + budget + timeline are always together)

**Cons**:
- Role assignment is fuzzy — the same user wears all hats
- `/learn` is separated from the task lifecycle even though it logically follows implementation
- Requires each doc to be written for a persona, not a procedure, which is a harder writing style
- Does not match the existing files in docs/workflows/ which are task/tool-oriented

---

## Document Structure Alternatives

Four structure types were considered against the existing `docs/workflows/` files:

### 1. Narrative workflow (current pattern — agent-lifecycle.md)

Prose description of a workflow from start to finish: "First you do X, which produces Y, then you do Z." Has a summary diagram, then each step with examples.

**Best for**: Lifecycle commands that flow in sequence (task → research → plan → implement → todo).
**Not suitable for**: Independent commands that don't chain together (refresh, merge, tag).

### 2. Decision guide + per-command sections (current pattern — convert-documents.md)

Leads with "I want to... → Use" table, then each command gets its own headed section with minimal usage examples.

**Best for**: Command families that solve similar problems with different inputs (convert/table/slides/scrape all transform files). This is the **recommended pattern for new files** given the established precedent.
**Not suitable for**: Commands with rich multi-step workflows (grant, budget, timeline are too complex for this format).

### 3. Cookbook / Recipe per scenario

Each doc is a collection of named "recipes": "Convert a PDF paper to Markdown for annotation", "Extract a table from Excel for a thesis", etc. Each recipe has numbered steps.

**Pros**: Highly discoverable via search; each recipe is self-contained.
**Cons**: Significant duplication when commands are used in multiple scenarios; harder to maintain; not established by existing files.

### 4. Command-by-command reference

One section per command with full flag docs, edge cases, error handling. Essentially a man page.

**Assessment**: Already exists at `.claude/docs/guides/user-guide.md` and `docs/agent-system/commands.md`. Creating this in `docs/workflows/` would duplicate those.

**Recommendation**: New workflow files should use the **decision guide + per-command sections** structure (pattern 2), matching `convert-documents.md`. For the grant/present cluster which has true multi-step workflows, a **hybrid** of pattern 1 (narrative intro) and pattern 2 (per-command sections) is appropriate.

---

## Cross-References to Existing Docs (Avoid Duplication)

New workflow files should **link to**, not duplicate, the following:

| Content | Canonical Location | Link from new files |
|---------|--------------------|---------------------|
| Full command flag reference | `.claude/docs/guides/user-guide.md` | "For full flags, see user-guide.md" |
| Command catalog (terse) | `docs/agent-system/commands.md` | "For a full command list, see commands.md" |
| Task lifecycle state machine | `docs/workflows/agent-lifecycle.md` | "For the task lifecycle, see agent-lifecycle.md" |
| Document conversion commands | `docs/workflows/convert-documents.md` | Already covered — do not add new file |
| DOCX editing | `docs/workflows/edit-word-documents.md` | Already covered |
| Spreadsheet editing | `docs/workflows/edit-spreadsheets.md` | Already covered |
| Troubleshooting | `docs/workflows/tips-and-troubleshooting.md` | Link for MCP errors, permissions |
| Architecture internals | `docs/agent-system/architecture.md` | Link when explaining agent routing |
| Memory system | `docs/agent-system/context-and-memory.md` | Link from /learn workflow |
| Installation/MCP setup | `docs/general/installation.md` | Link when commands require MCP tools |

**Commands already fully covered** (no new file needed):
- `/convert`, `/table`, `/slides`, `/scrape` — `convert-documents.md`
- `/edit` — `edit-word-documents.md`
- `/task`, `/research`, `/plan`, `/implement`, `/revise`, `/todo` — `agent-lifecycle.md`

**Commands documented in commands.md but lacking a dedicated workflow doc**:
- `/grant`, `/budget`, `/timeline`, `/funds`, `/talk` — need narrative workflow
- `/review`, `/errors`, `/fix-it` — need maintenance workflow
- `/meta`, `/refresh`, `/spawn`, `/merge`, `/learn` — need supporting workflow docs

---

## Outlier Commands

Several commands do not fit naturally into any clean group:

### `/merge`

Creates a GitHub PR / GitLab MR. It is entirely infrastructure-facing (git) and has no domain overlap with any other command. It could belong in a "system administration" group or a "publishing your work" group, but neither group has other members in this command set.

**Suggested handling**: Include in a "maintenance and housekeeping" workflow file alongside `/refresh`, `/tag`, and note it is distinct from the task system.

### `/tag`

User-only semantic version tag creation. Cannot be invoked by agents. Pure git/infrastructure. No scenario where a user would open documentation to learn how to use `/tag` — the flags are self-evident (`--patch`, `--minor`, `--major`).

**Suggested handling**: Include in a brief mention inside a maintenance/housekeeping file. Does not warrant its own section.

### `/spawn`

Only used when a task is `[BLOCKED]`. Most users will rarely encounter this. It is a recovery command that sits between the lifecycle commands (it feeds back into `/research` → `/plan` → `/implement`) and the maintenance commands.

**Suggested handling**: Include in the maintenance/housekeeping workflow as a "when things go wrong" section, with a reference back to `agent-lifecycle.md` for the blocked state. A brief recipe "My task is blocked — what do I do?" would capture the scenario.

### `/meta`

Highly specialized — only used to modify the `.claude/` agent system itself. Most users of this Zed config will never run `/meta`. It is "for developers of the agent system."

**Suggested handling**: Either include in a maintenance doc with a clear note ("Only needed if you modify the agent system itself") or create a standalone `system-development.md` file. Given its rarity, the former is more practical.

---

## Confidence: high

Research was conducted by reading all existing workflow files, the commands catalog, all 24 `.claude/commands/` files (via commands.md summaries), and the sibling nvim configuration. No web search was required — all relevant prior art is in the local codebase.

## Appendix: Gap Summary for Planning

Commands without dedicated workflow docs in `docs/workflows/`:

| Command | Natural Group | Notes |
|---------|---------------|-------|
| `/grant` | Research & grant writing | Multi-step, has workflow stages in context/project/present/ |
| `/budget` | Research & grant writing | Usually follows /grant |
| `/timeline` | Research & grant writing | Usually follows /grant |
| `/funds` | Research & grant writing | Standalone or pre-grant |
| `/talk` | Research & grant writing | Independent |
| `/review` | Maintenance | Creates tasks, links to errors.json |
| `/errors` | Maintenance | Reads errors.json, creates fix tasks |
| `/fix-it` | Maintenance | Tag scanning, interactive task creation |
| `/refresh` | Housekeeping | Process/file cleanup |
| `/spawn` | Housekeeping / recovery | Blocked task recovery |
| `/meta` | System development | Agent architecture changes |
| `/merge` | Housekeeping | Git/PR creation |
| `/learn` | Memory management | .memory/ vault |

**Suggested new files** (avoiding duplication):
1. `docs/workflows/grant-research.md` — grant, budget, timeline, funds, talk
2. `docs/workflows/maintenance.md` — review, errors, fix-it, spawn, refresh, merge, learn (with /meta noted)
