# Research Findings: Task #8 — Teammate B (Alternative Approaches & Prior Art)

**Task**: 8 - Split office-workflows.md into workflows/ directory
**Role**: Teammate B — Alternative Decomposition Patterns & Prior Art
**Started**: 2026-04-10
**Completed**: 2026-04-10
**Artifact number**: 01

---

## Existing Docs Patterns

### What task 6 established as the conventions for this repo

Task 6 (`specs/006_expand_agent_system_docs/`) is the closest prior art — it executed exactly the same move: single `.md` file -> named subdirectory with a `README.md` table of contents. From the team research synthesis and implementation plan:

1. **Subdirectory + README pattern**: The canonical move is `docs/{single-file}.md` -> `docs/{name}/README.md` + N focused sibling files. This was adopted unanimously across four research teammates in task 6.
2. **Progressive disclosure structure per file**: Each file gets (a) one-paragraph summary, (b) minimal working example, (c) detailed sections, (d) "See also" links. Files do NOT try to be self-contained reference documents.
3. **Thin wrapper + strong link policy**: New user-facing docs introduce Zed-specific context and link into `.claude/docs/` for the authoritative reference. They do not duplicate prose.
4. **File count discipline**: Task 6 landed on 6 files for ~378 lines of source. The research process explicitly compared 4-file (Diátaxis flat) vs 6-file vs more-granular splits and chose 6 as the pragmatic middle.
5. **Link repair is a first-class phase**: Task 6 devoted a dedicated implementation phase to auditing and updating every inbound link. Fragment links (`#section-id`) are treated as high-risk.
6. **Non-redundancy by "thin wrapper"**: When two files would cover overlapping content, one gets the detail and the other gets a one-sentence summary + a link.

### Current docs/ directory shape (as of task 7)

```
docs/
├── README.md                  # Index with 5-entry table
├── installation.md            # macOS install (new in task 6)
├── keybindings.md             # Stable, no changes planned
├── settings.md                # Reference, stable
├── office-workflows.md        # Source for task 8 (211 lines)
└── agent-system/
    ├── README.md
    ├── workflow.md             # Other source for task 8 (123 lines)
    ├── commands.md
    ├── context-and-memory.md
    ├── architecture.md
    └── zed-agent-panel.md
```

`docs/agent-system/` has 6 peer files plus a README — exactly the structure task 8 must replicate for `docs/workflows/`.

### office-workflows.md content map

| Lines | Section | User action | Command |
|-------|---------|-------------|---------|
| 1-8 | Quick Start (3 methods) | Overview | — |
| 9-28 | How Claude Edits Word Documents | Conceptual | `/edit` |
| 29-67 | Document Conversion | Conversion | `/convert`, `/table`, `/slides`, `/scrape` |
| 68-96 | Edit Word Documents In-Place | Edit single file | `/edit` |
| 97-120 | Batch Document Editing | Edit folder | `/edit folder/` |
| 121-138 | Create New Documents | Create DOCX | `/edit --new` |
| 139-152 | Prompt Examples | Reference table | multiple |
| 153-170 | Workflow Examples | End-to-end | combo |
| 171-196 | OneDrive and SharePoint Tips | Troubleshooting | — |
| 197-210 | Troubleshooting | Troubleshooting | — |
| 211 | Available Tasks (tasks.json) | Reference | — |

### agent-system/workflow.md content

123-line lifecycle state machine doc covering: `/task`, `/research`, `/plan`, `/implement`, `/todo`, multi-task syntax, `--team`, `--remember`, and exception states.

---

## Alternative Decomposition Axes

### Option A: By workflow TYPE (office/document/agent) — the primary split

```
docs/workflows/
├── README.md
├── office-editing.md        # /edit (single, batch, --new, tracked changes)
├── document-conversion.md   # /convert, /table, /slides, /scrape
├── agent-workflow.md        # moved workflow.md content
└── cloud-storage.md         # OneDrive/SharePoint tips + troubleshooting
```

**Trade-offs**:
- Pro: Direct mapping to how users think ("I want to edit a Word file" vs "I want to convert a PDF")
- Pro: Each file has a coherent scope and a clear command cluster
- Pro: Mirrors the exact split task 6 used for agent-system/
- Con: "How Claude Edits Word Documents" (conceptual) and "Edit Word Documents In-Place" (procedural) are both `/edit` — risk of duplication between office-editing.md and a generic intro
- Con: Troubleshooting and OneDrive tips are cross-cutting — they affect editing AND conversion, so they belong in README or a dedicated file

**Verdict**: Closest to the established pattern. Low maintenance burden. Aligns with how commands are grouped in `.claude/CLAUDE.md`.

### Option B: By USER ROLE (end user vs developer/agent author)

```
docs/workflows/
├── README.md
├── office-user.md           # All office tasks for document workers
├── agent-developer.md       # Agent task lifecycle for developers
└── troubleshooting.md       # Shared troubleshooting
```

**Trade-offs**:
- Pro: Obvious routing ("I'm an end user" / "I'm configuring agents")
- Pro: Eliminates the awkward co-habitation of `/edit` and `/research` in the same directory
- Con: High redundancy risk — office-user.md would duplicate much of office-workflows.md
- Con: Obscures the internal structure of office tasks (editing vs conversion vs scraping)
- Con: "agent-developer.md" would be a thin wrapper around existing agent-system/ docs, giving this directory almost no value over just keeping workflow.md where it is

**Verdict**: Role-based split adds one navigation level without reducing file size meaningfully. Not recommended.

### Option C: By INVOCATION METHOD (slash-command vs manual vs automatic)

```
docs/workflows/
├── README.md
├── slash-commands.md        # All /command workflows
├── manual-editing.md        # Direct Word/Excel edit + Zed task runner
├── agent-lifecycle.md       # Automated agent pipeline (/task through /todo)
└── troubleshooting.md
```

**Trade-offs**:
- Pro: Technically precise — cleanly separates CLI commands from UI interactions
- Con: Unnatural user mental model; users think "I want to edit a DOCX" not "I want to use a slash command"
- Con: slash-commands.md would be enormous (all office commands + all agent commands) and require heavy internal structure
- Con: Creates a structural mismatch with existing docs/ conventions where files are topic-based, not method-based

**Verdict**: Method-based split optimizes for implementer understanding, not user discoverability. Reject.

### Option D: By DOMAIN (grant/talk/convert/edit/research/plan)

```
docs/workflows/
├── README.md
├── document-management.md   # /edit, /convert, /scrape, /table, /slides
├── research-planning.md     # /research, /plan, /implement lifecycle
├── grant-and-talks.md       # /grant, /talk, /budget, /timeline, /funds
└── spreadsheets.md          # /table, direct Excel editing
```

**Trade-offs**:
- Pro: Groups by use-case domain — each file serves a professional activity
- Pro: Exposes grant/talk workflows that are currently undocumented in docs/
- Con: Far exceeds the scope of task 8 — grant/talk workflows are not in either source file
- Con: Creates many files with thin content (spreadsheets.md would be short)
- Con: Introduces scope creep — requires writing new documentation not derived from existing files

**Verdict**: Interesting long-term direction but wrong scope for this task. Out of scope.

### Option E: Hybrid — 2-tier with command-cluster files + a shared reference

```
docs/workflows/
├── README.md                # TOC + "which file for what" decision guide
├── office-editing.md        # /edit variants (single, batch, --new) + direct Word/Excel
├── document-conversion.md   # /convert, /table, /slides, /scrape
├── agent-lifecycle.md       # Moved from agent-system/workflow.md
└── tips-and-troubleshooting.md  # OneDrive, macOS permissions, common errors
```

**Trade-offs**:
- Pro: Pulls cross-cutting concerns (OneDrive, troubleshooting) into a shared file, eliminating the "where does this go" problem
- Pro: Mirrors the exact 4-5 file count that task 6's Diátaxis option B proposed (and nearly adopted)
- Pro: README becomes a genuine TOC + decision guide rather than just a link list
- Con: tips-and-troubleshooting.md is a "miscellaneous" file, which can accumulate over time
- Con: Slightly higher maintenance burden than Option A (one extra file)

**Verdict**: Best balance. The addition of a dedicated tips/troubleshooting file solves the cross-cutting concern problem that Option A leaves implicit.

---

## Recommendation vs Primary

### Recommended approach: Option E (Hybrid)

The hybrid 5-file approach is slightly better than the simple type-split (Option A) for one concrete reason: `office-workflows.md` mixes procedural command workflows with non-command reference material (OneDrive pausing, macOS permissions, tasks.json catalog). If the non-command material is distributed into command-cluster files (e.g., OneDrive tips into office-editing.md), those files become harder to read because users following a conversion workflow don't need OneDrive guidance. A dedicated `tips-and-troubleshooting.md` keeps the command-workflow files clean.

**Proposed structure**:

```
docs/workflows/
├── README.md                          # TOC + decision guide ("I want to... -> see...")
├── office-editing.md                  # /edit (single file, batch, --new) + direct Word/Excel
├── document-conversion.md             # /convert, /table, /slides, /scrape
├── agent-lifecycle.md                 # Moved from docs/agent-system/workflow.md
└── tips-and-troubleshooting.md        # OneDrive, macOS perms, tasks.json, common errors
```

**Rationale for moving workflow.md**:
The task requires moving `docs/agent-system/workflow.md` into `docs/workflows/`. Renaming it `agent-lifecycle.md` (rather than `workflow.md`) distinguishes it from the `workflows/` directory itself and makes its content clear. It should NOT duplicate the agent-system/README.md quick-start — only the lifecycle narrative belongs here.

**Link repair required** (from prior art analysis):
- `docs/agent-system/README.md` line 19 links to `workflow.md` — must update to `../workflows/agent-lifecycle.md`
- `docs/agent-system/workflow.md` internal "See also" links must be updated
- `docs/README.md` must add `docs/workflows/` to its contents table and remove or update the `office-workflows.md` entry
- Any references to `office-workflows.md` in README.md root or elsewhere must be updated

**What Teammate A likely proposes**: A direct file-per-type split (Option A) — `office-editing.md`, `document-conversion.md`, `agent-workflows.md` — possibly without a dedicated troubleshooting file. This is a sound approach and would work. The difference is modest: Option E vs Option A is mainly whether cross-cutting tips get their own file or are distributed.

**If there is conflict**: Defer to whichever approach produces cleaner, more scannable individual files. The key invariant from task 6 is non-redundancy and thin-wrapper linking, not the exact file count.

---

## Confidence Level

**High** for structural recommendation.

The existing pattern from task 6 provides a direct template. The content of `office-workflows.md` is well-structured and maps cleanly to command clusters. The main uncertainty is whether `tips-and-troubleshooting.md` should be a standalone file or folded into README.md — either is defensible.

**Medium** for the `agent-lifecycle.md` rename. The task says "moving docs/agent-system/workflow.md into this folder for agent workflows." The rename is suggested for clarity but the implementer may reasonably keep `workflow.md` as the filename if that matches what Teammate A proposes for the main workflow file.

---

## Appendix: Key Sources Examined

- `/home/benjamin/.config/zed/docs/office-workflows.md` (211 lines)
- `/home/benjamin/.config/zed/docs/agent-system/workflow.md` (123 lines)
- `/home/benjamin/.config/zed/docs/README.md` (12 lines)
- `/home/benjamin/.config/zed/docs/agent-system/README.md` (59 lines)
- `/home/benjamin/.config/zed/specs/006_expand_agent_system_docs/reports/01_team-research.md` — synthesized team research from prior expansion task
- `/home/benjamin/.config/zed/specs/006_expand_agent_system_docs/plans/01_expand-docs-directory.md` (first 60 lines) — implementation plan for task 6
- `/home/benjamin/.config/zed/specs/TODO.md` — task 8 description
