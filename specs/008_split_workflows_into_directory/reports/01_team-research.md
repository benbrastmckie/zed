# Research Report: Task #8 — Split office-workflows.md into docs/workflows/

**Task**: 8 — Turn `docs/office-workflows.md` into a `docs/workflows/` directory with separate documents per workflow, moving `docs/agent-system/workflow.md` into the new directory for agent workflows. Non-redundant, cross-linked, with a `workflows/README.md` TOC.
**Date**: 2026-04-10
**Mode**: Team Research (4 teammates)
**Session**: sess_1744315000_res008

---

## Summary

Task 8 continues the directory-extraction pattern established by task 6 (`agent-system.md` → `docs/agent-system/`). The implementation should create `docs/workflows/` as a **sibling** of `docs/agent-system/`, populate it with a small number of focused, command-cluster workflow files, move `docs/agent-system/workflow.md` into the new directory (renamed for clarity), and repair all inbound links.

The key non-trivial decisions surfaced by the team are:

1. **File granularity**: One file per goal-cluster, not per command. A naïve per-command split produces 10–20 line stubs (`/table`, `/slides`, `/scrape` sections are each 4–6 lines in the source). The recommended split is **4–5 workflow files + README.md**.
2. **Semantic tension**: "Office workflows" and "agent task lifecycle workflow" are different concepts sharing a word. The moved agent file must be renamed (e.g., `agent-lifecycle.md`) so that its colocation with Word/PDF how-tos does not create false equivalence, and the `README.md` must group them into distinct sections.
3. **Blast radius**: Moving `agent-system/workflow.md` breaks **9 inbound links in 5 files** (all sibling files in `docs/agent-system/`). Splitting `office-workflows.md` breaks **7 inbound links in 4 files** (root README, `docs/README.md`, `docs/settings.md`, `docs/agent-system/commands.md`). Link repair is a first-class implementation phase.
4. **Cross-cutting content**: OneDrive tips, macOS permissions prompts, and the Agent Panel invocation instructions appear in multiple sections of the source file. Splitting without consolidation would amplify this redundancy.

All four teammates reported **high confidence** in the overall direction.

---

## Key Findings

### Primary Approach (Teammate A) — Content-driven decomposition

Teammate A read both source files end-to-end and produced a concrete content-mapping plan.

**Source content inventory**:
- `docs/office-workflows.md` (210 lines): Five distinct workflow types — in-place Word editing (`/edit`), document conversion (`/convert`, `/table`, `/slides`, `/scrape`), direct spreadsheet editing (openpyxl), batch folder editing, and new document creation (`/edit --new`). Plus non-workflow supporting content: Prompt Examples table, Workflow Examples (end-to-end scenarios), OneDrive/SharePoint tips, Troubleshooting, and the tasks.json runner catalog.
- `docs/agent-system/workflow.md` (123 lines): A coherent single-purpose document describing the Claude Code task lifecycle state machine. No restructuring needed — just a rename-and-move.

**Proposed structure** (granular variant, 7 files + README):
```
docs/workflows/
├── README.md
├── agent-task-lifecycle.md      (was docs/agent-system/workflow.md)
├── edit-word-documents.md       (/edit variants: single, batch, --new)
├── convert-documents.md         (/convert)
├── convert-spreadsheets.md      (/table)
├── convert-presentations.md     (/slides)
├── extract-pdf-annotations.md   (/scrape)
└── edit-spreadsheets.md         (openpyxl direct editing)
```

Teammate A also proposed a consolidated fallback: merge the four conversion commands into a single `convert-and-extract.md` for 4 workflow files total.

### Alternative Approaches (Teammate B) — Five decomposition axes evaluated

Teammate B surveyed the existing docs layout and prior art from task 6, then evaluated five alternative decomposition patterns:

| Option | Axis | Verdict |
|---|---|---|
| A | By TYPE (office/document/agent) | Closest to established pattern; low maintenance; mirrors task 6 |
| B | By USER ROLE (end-user vs developer) | Rejected — high redundancy with existing docs, thin agent file |
| C | By INVOCATION METHOD (slash-command vs manual) | Rejected — unnatural user mental model |
| D | By DOMAIN (grant/talk/convert/edit) | Out of scope — grant workflows not in source files |
| **E** | **Hybrid: command clusters + shared tips file** | **Recommended** |

**Teammate B's recommendation (Option E)** — 4 workflow files + README:
```
docs/workflows/
├── README.md                      (TOC + decision guide)
├── office-editing.md              (/edit single, batch, --new + direct Word/Excel)
├── document-conversion.md         (/convert, /table, /slides, /scrape)
├── agent-lifecycle.md             (moved from docs/agent-system/workflow.md)
└── tips-and-troubleshooting.md    (OneDrive, macOS perms, common errors)
```

**Rationale for the hybrid**: `office-workflows.md` mixes procedural command workflows with non-command reference material (OneDrive pause steps, macOS permissions). Distributing this material into command-cluster files clutters them; a dedicated `tips-and-troubleshooting.md` keeps command workflows scannable.

**Key prior art from task 6**:
- Subdirectory + README is the canonical move pattern.
- Progressive disclosure per file: one-paragraph summary → minimal example → detail → "See also".
- Thin-wrapper linking to `.claude/docs/` (no duplicated prose).
- Link repair is a dedicated implementation phase.
- Task 6 landed on 6 files for ~378 source lines; task 8 has ~333 source lines across two files, so 4–5 files is the proportional analog.

### Gaps and Shortcomings (Teammate C, Critic)

Teammate C identified four critical blind spots.

**1. Inbound link blast radius (grep-verified)**:

References to `docs/office-workflows.md` — 7 points in 4 live files:
| File | Lines | Status |
|---|---|---|
| `docs/README.md` | 11 | Breaks |
| `docs/settings.md` | 250 | Breaks |
| `docs/agent-system/commands.md` | 202, 254 | Breaks (2 refs) |
| `README.md` (root) | 43, 57, 92 | Breaks (3 refs) |

References to `docs/agent-system/workflow.md` — 9 points in 5 live files (all relative paths):
| File | Count |
|---|---|
| `docs/agent-system/README.md` | 2 (lines 19, 52) |
| `docs/agent-system/architecture.md` | 2 (lines 3, 117) |
| `docs/agent-system/commands.md` | 3 (lines 3, 9, 334) |
| `docs/agent-system/zed-agent-panel.md` | 1 (line 121) |
| `docs/agent-system/context-and-memory.md` | 1 (line 109) |

Every sibling file in `docs/agent-system/` links to `workflow.md` with a relative path.

**2. Semantic divergence**: "Office workflow" (UI steps to manipulate a document) and "task lifecycle workflow" (command pipeline: GATE IN → DELEGATE → GATE OUT → COMMIT) are orthogonal concepts that happen to share a word. Colocating them without renaming and section-separating creates false equivalence. Readers navigating `docs/workflows/` should not see `agent-lifecycle.md` sitting beside `edit-word-documents.md` as an implied peer.

**3. Granularity danger**: Per-command splitting produces stubs too thin to be useful:

| Section | Source lines | Viability |
|---|---|---|
| `/convert` | ~10 | Thin |
| `/table` | ~6 | Sub-stub |
| `/slides` | ~4 | Sub-stub |
| `/scrape` | ~5 | Sub-stub |
| Edit In-Place | ~20 | Borderline |
| Direct Spreadsheet | ~15 | Thin |

Teammate C recommends a 3–5 file practical minimum, with 4 as the sweet spot.

**4. Cross-file redundancy if split naïvely**:
- **macOS permissions dialog** — already duplicated in source between "How Claude Edits" and "Troubleshooting"; splitting spreads it further.
- **Agent Panel invocation (Cmd+Shift+?)** — repeated in Edit, Spreadsheet, and Batch sections.
- **Word save-edit-reload explanation** — appears in intro and `/edit` section.
- **`/edit` appears in three sections** (In-Place, Batch, Create New); splitting all three into separate files forces triple-explanation of the same command.
- **Overlap with `docs/agent-system/commands.md`**: commands.md already documents `/convert`, `/table`, `/slides`, `/scrape`, `/edit`. The implementer must decide whether workflows/ files are *usage narratives* (step-by-step, macOS-focused) and commands.md entries are *command references* (flags, syntax), or the two duplicate each other.

**Open questions raised by C**:
1. Is moving `agent-system/workflow.md` intentional given the 9 broken links? (Yes per task description, but requires first-class link-repair phase.)
2. What name distinguishes the moved file? `agent-lifecycle.md`, `claude-code-workflow.md`, or `task-lifecycle.md`?
3. Does `docs/README.md` table list every workflow file individually, or point to `workflows/README.md`?
4. What do the `docs/agent-system/commands.md` `[office workflows](../office-workflows.md)` links map to after the split?
5. What is the minimum acceptable file size? (If 20 lines, then `/table`, `/slides`, `/scrape` cannot stand alone.)
6. Where do cross-cutting troubleshooting / OneDrive tips live?

### Strategic Horizons (Teammate D) — Project trajectory alignment

Teammate D placed task 8 in the context of the ongoing docs reorganization arc (tasks 1–8) and surveyed all 24 slash commands to identify future workflows.

**Docs reorganization arc**: Tasks 6/7/8 follow a **directory extraction** pattern — flat `.md` files grow dense enough to warrant subdirectories. Task 6 extracted `agent-system/`, task 7 narrows `installation.md` audience, task 8 extracts `workflows/`. The long-term endgame is a docs/ root that serves as a navigation hub, with two complementary subdirectories:
- **`docs/agent-system/`** — reference documentation (how the system works, for people understanding internals)
- **`docs/workflows/`** — how-to documentation (goal-oriented, for people accomplishing tasks)

**Structural recommendation**: `docs/workflows/` should be a **sibling** of `docs/agent-system/`, not nested inside it. Reasons:
1. Audience separation — reference vs how-to.
2. Cross-cutting — workflows will contain agent, document, AND grant workflows; not all are "agent system" internals.
3. Precedent — task 6 established agent-system/; workflows/ is its user-facing complement.
4. Navigation symmetry — docs/README.md currently has 5 entries; adding workflows/ as a 6th is clean.

**Future workflows inventory** (22 of 24 slash commands are user-facing workflows):
| Cluster | Commands | Current status |
|---|---|---|
| Task lifecycle | /task, /research, /plan, /implement, /todo | In agent-system/workflow.md (to be moved) |
| Office documents | /edit, /convert, /table, /slides, /scrape | In office-workflows.md (to be split) |
| Grant writing | /grant, /budget, /timeline, /funds | **Undocumented** at user level |
| Research talks | /talk | **Undocumented** at user level |
| Memory | /learn | **Undocumented** at user level |
| Maintenance | /errors, /fix-it, /spawn, /refresh | **Undocumented** at user level |
| Release | /tag, /merge | **Undocumented** at user level |

**Extensibility design**:
1. One file per workflow **cluster** (goal-oriented), not per command. `/grant`, `/budget`, `/timeline`, `/funds` naturally cluster into a single `grant-writing.md`.
2. README.md as the single authoritative TOC, extended with one row per new workflow file.
3. **Flat**, not nested. Single-level directory; if a workflow grows to 500+ lines, split it into sections rather than a sub-subdirectory.

**Teammate D's proposed structure** (4 office files, matching Teammate B's file count but with different naming):
```
docs/workflows/
├── README.md
├── agent-workflow.md          (moved)
├── word-editing.md            (/edit cluster)
├── document-conversion.md     (/convert, /scrape)
├── spreadsheet-tables.md      (/table + direct editing)
└── presentations.md           (/slides)
```

---

## Synthesis

### Conflicts Detected and Resolved

**Conflict 1: File count and granularity**

| Teammate | Proposed count | Grain |
|---|---|---|
| A | 7 workflow files + README | One file per command/tool |
| A (alt) | 4 workflow files + README | Consolidated conversion |
| B | 4 workflow files + README | Command clusters + tips file |
| C | 3–4 workflow files + README | Practical minimum |
| D | 5 workflow files + README | One per goal-cluster |

**Resolution**: Converge on **4–5 workflow files**. Teammate A's granular 7-file plan is rejected because teammate C's line-count audit shows the per-command files would be 4–15 lines each, too thin to justify. Teammates B, C, and D all independently arrive at the 4–5 file range. The concrete recommended structure (see below) takes B's hybrid tips-file idea and D's cluster grain.

**Conflict 2: Naming of the moved agent-system/workflow.md**

| Teammate | Proposed name |
|---|---|
| A | `agent-task-lifecycle.md` |
| B | `agent-lifecycle.md` |
| C | `agent-lifecycle.md`, `claude-code-workflow.md`, or `task-lifecycle.md` (undecided) |
| D | `agent-workflow.md` |

**Resolution**: Use **`agent-lifecycle.md`**. Reasons: it disambiguates from "workflows/" directory name (solving C's semantic concern), it is concise (shorter than `agent-task-lifecycle.md`), and it does not repeat the word "workflow" that appears in the enclosing directory (which `agent-workflow.md` does). This name also matches B's and C's top preferences.

**Conflict 3: Naming of office-workflow files**

Teammates A, B, and D used different filename conventions:

| Concept | A | B | D |
|---|---|---|---|
| Word editing | `edit-word-documents.md` | `office-editing.md` | `word-editing.md` |
| Doc conversion | `convert-documents.md` | `document-conversion.md` | `document-conversion.md` |
| Spreadsheet | `convert-spreadsheets.md` + `edit-spreadsheets.md` | (in office-editing.md) | `spreadsheet-tables.md` |
| Presentations | `convert-presentations.md` | (in document-conversion.md) | `presentations.md` |
| PDF annotations | `extract-pdf-annotations.md` | (in document-conversion.md) | (in document-conversion.md) |

**Resolution**: Use verb-prefixed kebab-case, matching the Teammate A convention (`edit-word-documents.md`, `convert-documents.md`) because it is consistent and self-describing when listed in a README TOC. Consolidate PDF annotation, spreadsheet-to-table, and presentation conversion into a single `convert-documents.md` because individually they are too thin. Direct spreadsheet editing is kept separate only if it crosses a ~20-line threshold; otherwise fold into `edit-word-documents.md` or the tips file.

**Conflict 4: How to handle cross-cutting content (OneDrive, troubleshooting, macOS permissions)**

| Teammate | Proposal |
|---|---|
| A | Distribute across command files; troubleshooting entries mostly into `convert-documents.md` |
| B | Dedicated `tips-and-troubleshooting.md` |
| C | Flag as unresolved open question |
| D | Did not address directly |

**Resolution**: Adopt B's **`tips-and-troubleshooting.md`** as a dedicated file. This directly solves C's cross-cutting redundancy concern (macOS permissions, Agent Panel invocation, Word save-edit-reload cycle) by centralizing the explanation once and letting the command-workflow files link to it.

**Conflict 5: Relationship to `docs/agent-system/commands.md`**

Teammate C flagged that `commands.md` already documents `/convert`, `/table`, `/slides`, `/scrape`, `/edit` with examples and flags. Teammates A, B, D did not address this.

**Resolution (judgment call)**: The workflows/ files are **usage narratives** (macOS-focused, step-by-step, scenario-driven) and `commands.md` remains the **command reference** (flags, syntax, canonical description). Workflows/ files should link back to `commands.md` for command reference details rather than duplicating flag tables. This is the thin-wrapper pattern from task 6. The planner phase must make this distinction explicit.

### Gaps Identified (to be addressed by planner)

1. **Minimum file-size threshold**: The team did not agree on an explicit line count. A reasonable rule: a standalone workflow file must contain ≥25 lines of content (not counting frontmatter/TOC). Anything smaller folds into a sibling or into `tips-and-troubleshooting.md`.
2. **Exact cross-link contract**: Teammate A provided a table of proposed cross-links. The planner should formalize which files link to which, and ensure every link is bidirectional or explicitly one-way.
3. **Deletion or redirect of source files**: Teammate D says delete `office-workflows.md` after splitting. Teammate C raised whether a backward-compatibility stub is needed. Since all inbound refs are inside this repo and can be fixed mechanically, **delete both source files** once link repair is complete. No redirect stubs needed.
4. **Workflow Examples scenarios**: The source has three end-to-end scenarios ("Reviewing a PDF paper", "Creating a report from data", "Editing a collaborator's document"). Teammate A proposed distributing them; teammates B/C/D did not address. **Planner decision**: move these into `README.md` as a "Common scenarios" section at the bottom, since they cross multiple workflow files.
5. **tasks.json runner content**: Both A and C said this belongs in `docs/settings.md`, not workflows/. Planner should include a phase that removes it from workflows source and ensures it is covered in settings.md (or create a small supplementary entry).

---

## Recommended Approach

### Final Structure

```
docs/workflows/
├── README.md                       # TOC + decision guide + common scenarios
├── agent-lifecycle.md              # moved from docs/agent-system/workflow.md
├── edit-word-documents.md          # /edit single, batch, --new; tracked changes
├── edit-spreadsheets.md            # openpyxl direct spreadsheet editing
├── convert-documents.md            # /convert, /table, /slides, /scrape
└── tips-and-troubleshooting.md     # OneDrive, macOS permissions, Agent Panel, errors
```

**Five workflow files + README.md = 6 total files in `docs/workflows/`.**

This matches task 6's proportional file count (task 6: 6 files for 378 source lines; task 8: 6 files for 333 source lines), adopts Teammate B's hybrid tips approach, uses Teammate A's naming convention, respects Teammate C's granularity floor, and aligns with Teammate D's goal-cluster grain and sibling-of-agent-system placement.

### Content Mapping (high-level)

| Destination file | Source content | Approximate size |
|---|---|---|
| `README.md` | New content: TOC, decision guide ("I want to… → see…"), 3 common scenarios from source Workflow Examples, See Also links | ~60 lines |
| `agent-lifecycle.md` | Entire contents of `docs/agent-system/workflow.md` with internal links updated (`commands.md` → `../agent-system/commands.md`, etc.) | ~125 lines |
| `edit-word-documents.md` | "How Claude Edits Word Documents" + "Edit In-Place" + "Batch Editing" + "Create New Documents" + "Prompt Examples" table | ~80 lines |
| `edit-spreadsheets.md` | "Direct Spreadsheet Editing" section + specific troubleshooting | ~30 lines |
| `convert-documents.md` | "Document Conversion" intro + `/convert` + `/table` + `/slides` + `/scrape` sections, each as a subsection | ~60 lines |
| `tips-and-troubleshooting.md` | "OneDrive and SharePoint Tips" + "Troubleshooting" + deduplicated Agent Panel and macOS permissions content | ~50 lines |

### Link Repair Phases (mandatory first-class implementation phases)

Based on Teammate C's blast radius analysis, the implementation plan MUST include two dedicated link repair phases:

**Phase: Repair references to `office-workflows.md`** (7 references in 4 files)
- `README.md` (root): lines 43, 57, 92 — update directory tree, docs table, and body prose
- `docs/README.md`: line 11 — replace entry with `workflows/` directory entry
- `docs/settings.md`: line 250 — update link target
- `docs/agent-system/commands.md`: lines 202, 254 — point to specific workflow file (`edit-word-documents.md` or `convert-documents.md` depending on context)

**Phase: Repair references to `agent-system/workflow.md`** (9 references in 5 files, all relative paths)
- `docs/agent-system/README.md`: lines 19, 52 → `../workflows/agent-lifecycle.md`
- `docs/agent-system/architecture.md`: lines 3, 117 → `../workflows/agent-lifecycle.md`
- `docs/agent-system/commands.md`: lines 3, 9, 334 → `../workflows/agent-lifecycle.md`
- `docs/agent-system/zed-agent-panel.md`: line 121 → `../workflows/agent-lifecycle.md`
- `docs/agent-system/context-and-memory.md`: line 109 → `../workflows/agent-lifecycle.md`

Plus internal link updates within `agent-lifecycle.md` itself (was `commands.md` → now `../agent-system/commands.md`).

### Cross-Link Contract

Within `docs/workflows/`:
- `edit-word-documents.md` ↔ `edit-spreadsheets.md` (bidirectional "see also")
- `edit-word-documents.md` → `convert-documents.md` ("to convert a finished doc…")
- `convert-documents.md` → `tips-and-troubleshooting.md` (OneDrive prerequisite reference)
- `edit-word-documents.md` → `tips-and-troubleshooting.md` (macOS permissions, Agent Panel)
- All office workflow files → `agent-lifecycle.md` (one-way "agents that execute these commands")
- `agent-lifecycle.md` → README.md (one-way "office workflows overview")

From `docs/workflows/` outward:
- `agent-lifecycle.md` → `../agent-system/{commands,architecture,context-and-memory}.md` (reference documentation)
- All office workflow files → `../installation.md#install-mcp-tools` (MCP prerequisite)
- `README.md` → `../agent-system/README.md` (internal reference docs)
- `README.md` → `../settings.md` (for tasks.json runner, keybindings)

### Implementation Phase Outline (suggested input to planner)

1. **Create directory and README skeleton** — `docs/workflows/README.md` with placeholder TOC
2. **Move and rename agent-system/workflow.md** → `docs/workflows/agent-lifecycle.md`, update internal links within the moved file
3. **Repair agent-system/ internal links** (Phase-level: 9 refs in 5 files)
4. **Create edit-word-documents.md** (consolidate `/edit` variants, deduplicate with intro)
5. **Create edit-spreadsheets.md** (openpyxl section)
6. **Create convert-documents.md** (four conversion commands as subsections)
7. **Create tips-and-troubleshooting.md** (cross-cutting content, deduplicated)
8. **Populate README.md** (TOC, decision guide, 3 common scenarios, See Also)
9. **Repair office-workflows.md references** (Phase-level: 7 refs in 4 files)
10. **Delete `docs/office-workflows.md` and `docs/agent-system/workflow.md`**
11. **Verification pass**: grep for `office-workflows`, `agent-system/workflow`, and broken relative links; verify all markdown renders

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key contribution |
|---|---|---|---|---|
| A | Primary approach (content analysis) | Completed | High | Concrete section-to-file mapping with line numbers; 7-file granular proposal |
| B | Alternative patterns + prior art | Completed | High | Evaluated 5 decomposition axes; recommended hybrid with dedicated tips file |
| C | Critic (gaps and blind spots) | Completed | High | Grep-verified 16 total inbound links; flagged semantic divergence and granularity floor |
| D | Strategic horizons (trajectory) | Completed | High | Placed task in docs-reorg arc; recommended sibling placement; inventoried future workflows |

---

## References

### Source files
- `docs/office-workflows.md` (210 lines) — primary source
- `docs/agent-system/workflow.md` (123 lines) — secondary source to be moved
- `docs/README.md` — navigation hub needing update
- `docs/agent-system/README.md` — inbound-link file needing update
- `docs/agent-system/{architecture,commands,zed-agent-panel,context-and-memory}.md` — inbound-link files

### Prior art
- `specs/006_expand_agent_system_docs/` — directly analogous prior task
- `specs/006_expand_agent_system_docs/plans/01_expand-docs-directory.md` — phase structure template
- `specs/006_expand_agent_system_docs/reports/01_team-research.md` — team research pattern

### Teammate findings (complete)
- `specs/008_split_workflows_into_directory/reports/01_teammate-a-findings.md`
- `specs/008_split_workflows_into_directory/reports/01_teammate-b-findings.md`
- `specs/008_split_workflows_into_directory/reports/01_teammate-c-findings.md`
- `specs/008_split_workflows_into_directory/reports/01_teammate-d-findings.md`
