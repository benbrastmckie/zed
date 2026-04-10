# Research Report: Task #8 — Teammate C (Critic)

**Task**: 8 - Split workflows into docs/workflows/ directory
**Role**: Teammate C — Critic: gaps, shortcomings, and blind spots
**Started**: 2026-04-10T00:00:00Z
**Completed**: 2026-04-10T00:30:00Z
**Effort**: 30 min
**Sources/Inputs**: Codebase grep, file reads
**Artifacts**: This report

---

## Inbound References

### References to `docs/office-workflows.md`

Active documentation files that link to the source:

| File | Location | Link text |
|------|----------|-----------|
| `docs/README.md` | Line 11 | `[Office Workflows](office-workflows.md)` |
| `docs/settings.md` | Line 250 | `[Office workflows](office-workflows.md)` |
| `docs/agent-system/commands.md` | Line 202 | `[office workflows](../office-workflows.md)` |
| `docs/agent-system/commands.md` | Line 254 | `[office workflows](../office-workflows.md)` |
| `README.md` (root) | Line 43 (tree) | `office-workflows.md` (prose description) |
| `README.md` (root) | Line 57 (table) | `[Office Workflows](docs/office-workflows.md)` |
| `README.md` (root) | Line 92 | `[docs/office-workflows.md](docs/office-workflows.md)` |

**Verdict**: 7 reference points in 4 live files. All will break on rename/move.

### References to `docs/agent-system/workflow.md`

Active documentation files that link to the source:

| File | Location | Link text |
|------|----------|-----------|
| `docs/agent-system/README.md` | Line 19 | `[workflow.md](workflow.md)` (relative) |
| `docs/agent-system/README.md` | Line 52 | `[workflow.md](workflow.md)` (relative) |
| `docs/agent-system/architecture.md` | Line 3 | `[workflow.md](workflow.md)` (relative) |
| `docs/agent-system/architecture.md` | Line 117 | `[workflow.md](workflow.md)` (relative) |
| `docs/agent-system/commands.md` | Line 3 | `[workflow.md](workflow.md)` (relative) |
| `docs/agent-system/commands.md` | Line 9 | `[workflow.md](workflow.md)` (relative) |
| `docs/agent-system/commands.md` | Line 334 | `[workflow.md](workflow.md)` (relative) |
| `docs/agent-system/zed-agent-panel.md` | Line 121 | `[workflow.md](workflow.md)` (relative) |
| `docs/agent-system/context-and-memory.md` | Line 109 | `[workflow.md](workflow.md)` (relative) |

**Verdict**: 9 reference points in 5 live files, all using relative paths. Every single sibling file in `docs/agent-system/` links to `workflow.md`. Moving this file will break all of them.

---

## Semantic Concerns

**These two files describe entirely different concepts that happen to share the word "workflow".**

| Attribute | `docs/office-workflows.md` | `docs/agent-system/workflow.md` |
|-----------|---------------------------|----------------------------------|
| Subject | User-facing document manipulation (Word, Excel, PDF, PowerPoint) | Claude Code task lifecycle state machine |
| Audience | End-user doing office work on macOS | Developer/user managing AI-assisted coding tasks |
| Primitive concept | "workflow" = sequence of UI steps to accomplish a document task | "workflow" = command pipeline (GATE IN -> DELEGATE -> GATE OUT -> COMMIT) |
| Verbs | Open, convert, edit, scrape, pause OneDrive | /task, /research, /plan, /implement, /todo |
| Dependencies | SuperDoc, openpyxl, Word, Excel, OneDrive | skill-researcher, planner-agent, state.json, TODO.md |

**Colocation risk**: Putting `agent-system/workflow.md` inside `docs/workflows/` alongside office workflow files creates false equivalence. A user reading the `workflows/` directory will expect all files to be about the same kind of workflow. An agent-system lifecycle file does not belong next to "How to edit a Word document with tracked changes." The word overlap is coincidental; the concepts are orthogonal.

**Proposed concern**: If the new `docs/workflows/README.md` tries to unify these into a single table of contents, the table will be incoherent. Readers coming from `docs/agent-system/` expect `workflow.md` to be a peer of `architecture.md` and `commands.md` — not a sibling of `pdf-annotations.md`.

---

## Granularity Concerns

### office-workflows.md breakdown

The current file (211 lines) contains these candidate sections for splitting:

| Section | Lines | Standalone viability |
|---------|-------|---------------------|
| How Claude Edits Word Documents | ~15 lines | Too thin. Just prose explaining the mechanism. |
| Document Conversion (`/convert`) | ~10 lines | Stub; would be 15 lines including header/nav. |
| Extract tables (`/table`) | ~6 lines | Sub-stub. One paragraph. |
| Convert presentations (`/slides`) | ~4 lines | Sub-stub. |
| Extract PDF annotations (`/scrape`) | ~5 lines | Sub-stub. |
| Edit Word In-Place (`/edit`) | ~20 lines | Reasonable but still thin (~25 lines with nav). |
| Direct Spreadsheet Editing | ~15 lines | Thin. |
| Batch Document Editing | ~15 lines | Thin. |
| Create New Documents | ~15 lines | Thin. |
| Prompt Examples | ~10 lines (table) | Not a standalone workflow. |
| Workflow Examples | ~15 lines | Multi-step composites; belong in a separate "recipes" or "examples" file, not individual workflow files. |
| OneDrive and SharePoint Tips | ~12 lines | Too thin for a standalone file; configuration advisory, not a workflow. |
| Troubleshooting | ~15 lines | Should stay consolidated (cross-workflow troubleshooting is more useful than per-file troubleshooting). |
| Available Tasks | ~6 lines | Meta, belongs in settings.md or a tasks reference. |

**Verdict**: "One file per workflow" at the granularity of the conversion commands (`/convert`, `/table`, `/slides`, `/scrape`) produces files of 10–20 lines each. These are dangerously thin and will harm navigability. A reader who clicks into `workflows/pdf-annotations.md` and finds 15 lines would have been better served by a single consolidated reference.

**Reasonable alternative granularity** (3–5 files instead of 10+):
1. `word-editing.md` — in-place editing, tracked changes, batch edits, new document creation (~60 lines)
2. `document-conversion.md` — convert, table, slides, scrape (the `/convert`-family commands) (~50 lines)
3. `spreadsheet-editing.md` — direct spreadsheet edits via openpyxl (~25 lines, borderline)
4. `onedrive-sharepoint.md` — OneDrive tips, troubleshooting (~30 lines, borderline; could fold into word-editing.md)

Even at this granularity, `spreadsheet-editing.md` and `onedrive-sharepoint.md` are marginal. A 2-file split (word-editing + document-conversion) plus keeping troubleshooting/OneDrive in a shared section may be the practical minimum.

---

## Redundancy Risks

### Cross-file redundancy if split naively

1. **macOS permissions dialog** (currently in "How Claude Edits Word Documents" and again in "Troubleshooting"): already duplicated within the source file; splitting will spread it further.
2. **Agent Panel opening instructions** (Cmd+Shift+?): repeated in Edit, Spreadsheet, and Batch sections. Splitting creates 3+ files each repeating the same prerequisite step.
3. **Word staying open / save-edit-reload cycle**: described in the intro and again in the `/edit` section. Any split along these lines must decide which file owns this explanation.
4. **`/edit` command appears in multiple sections**: Edit In-Place, Batch Document Editing, and Create New Documents are all driven by `/edit` with different flags. Splitting these into separate files risks creating three files that all need to explain `/edit` from scratch, or three files that each say "see the edit workflow for details" and provide no value alone.

### Overlap between `office-workflows.md` and `agent-system/commands.md`

`docs/agent-system/commands.md` already documents `/convert`, `/table`, `/slides`, `/scrape`, and `/edit` with examples, flags, and links. Any new `docs/workflows/document-conversion.md` will substantially overlap this existing reference. The implementer must decide whether the workflows/ files are *usage narratives* (step-by-step, macOS-focused) and the commands.md entries are *command references* (flags, syntax, links), or whether one of these becomes redundant.

---

## Open Questions for Implementer

1. **Destination of `agent-system/workflow.md`**: Should it move to `docs/workflows/agent-workflow.md`? If so, all 9 relative links in `docs/agent-system/` break. Moving requires updating every sibling file in `docs/agent-system/`. A backward-compatibility stub (`workflow.md` -> redirect note or symlink) may be needed for any external bookmarks. The task description says "moving" it — the implementer must confirm this is intentional and update all 9 inbound links.

2. **Naming of the `agent-system/workflow.md` file in the new location**: If colocated with office workflow files, what name distinguishes it clearly? `agent-lifecycle.md`? `claude-code-workflow.md`? `task-lifecycle.md`? The word "workflow" alone is ambiguous in this new context.

3. **`docs/README.md` table**: Currently lists `office-workflows.md` as a single entry. After the split, does this table grow to list every workflow file individually, or does it point to `workflows/README.md`? The latter is cleaner but requires updating the top-level README entry.

4. **`README.md` (root) directory tree**: Line 43 shows `office-workflows.md` as a leaf. After the split, this becomes `workflows/` (a directory). The tree description on line 43 and the documentation table on lines 56–57 both need updating.

5. **`docs/agent-system/commands.md` links**: Lines 202 and 254 link `[office workflows](../office-workflows.md)`. After the move these become broken. If split into multiple files, which file do these links point to? The implementer needs a clear mapping.

6. **Minimum viable file size**: What is the minimum acceptable line count for a standalone workflow file? If the answer is "20 lines," then `/table`, `/slides`, and `/scrape` workflows cannot stand alone.

7. **Troubleshooting and OneDrive sections**: These are cross-workflow concerns. Do they go into a shared `troubleshooting.md`, fold into a specific workflow file, or stay in a `workflows/README.md` appendix?

8. **Specs/archive references**: Historical specs (003, 006) reference `office-workflows.md` by path. These are archived artifacts and do not need updating, but the implementer should be aware of the noise in grep results.

---

## Confidence Level

**High confidence on risks**: The inbound link count is definitive (grep-verified). The semantic divergence between the two "workflow" files is clear from reading both. The granularity concern is quantifiable from line counts.

**Medium confidence on granularity recommendations**: The right split depends on user intent. If the goal is better navigability, 3 files is likely the sweet spot. If the goal is one-command-per-file composability (for future automation), more files may be warranted — but at the cost of thin stubs.

**Key unresolved risk**: Moving `docs/agent-system/workflow.md` has the highest blast radius of any single action in this task (9 broken links in 5 files, all in the `docs/agent-system/` subdirectory). This should be treated as a first-class implementation concern, not a side effect of the restructuring.
