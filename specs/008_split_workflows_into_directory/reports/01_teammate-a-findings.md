# Research Report: Task #8 — Teammate A Findings

**Task**: 8 — Split workflows into docs/workflows/ directory
**Role**: Teammate A — Primary Approach (content analysis and concrete decomposition)
**Completed**: 2026-04-10
**Sources**: docs/office-workflows.md, docs/agent-system/workflow.md, docs/README.md, docs/agent-system/README.md

---

## Key Findings

### docs/office-workflows.md

This file covers working with Office files (Word, Excel, PowerPoint, PDF) on macOS using Zed and Claude Code. It contains five distinct workflow types interleaved with supporting reference material:

1. **In-place Word editing** (`/edit`) — The primary editorial workflow. Describes how Claude saves, edits, and reloads `.docx` files using SuperDoc with optional tracked changes. Covers the macOS permissions dialog.
2. **Document conversion** (`/convert`, `/table`, `/slides`, `/scrape`) — Four discrete conversion commands, each targeting a different source format. Logically these are one "conversion" workflow family but each command has a different use case.
3. **Direct spreadsheet editing** — Separate from `/table`; describes editing `.xlsx` values and formulas via the openpyxl MCP tool. Different tool, different UX pattern (requires closing the file in Excel first).
4. **Batch document editing** — Variant of Word editing across an entire folder. Shares the `/edit` command but has different preconditions (OneDrive pause step) and output semantics.
5. **New document creation** — `(/edit --new)`. Uses the same command as in-place editing but creates a new file from a description.

Supporting sections (not standalone workflows):
- **Prompt Examples** table — a reference card, not a workflow
- **Workflow Examples** section — three brief end-to-end scenarios (reviewing a PDF paper, creating a report from data, editing a collaborator's document). These are high-level walkthroughs that _combine_ the above workflows.
- **OneDrive and SharePoint Tips** — a prerequisite/caveat for batch editing
- **Troubleshooting** — diagnostic information for setup issues
- **Available Tasks (tasks.json)** — runner tasks, not workflows

### docs/agent-system/workflow.md

This file covers the Claude Code task lifecycle — the sequence of `/task`, `/research`, `/plan`, `/implement`, `/todo` commands. It is coherent and focused. Content breakdown:

1. **Task lifecycle state machine** — the core workflow concept: state transitions, checkpoint pipeline, session IDs, artifact locations
2. **Creating a task** (`/task`) — entry point, subcommands
3. **Researching** (`/research`) — routing, agent, artifact output, flags
4. **Planning** (`/plan`) — planner agent, model, flags
5. **Implementing** (`/implement`) — resumability, flags, output
6. **Finishing with /todo** — archival, ROAD_MAP annotation, vault operation
7. **Advanced flags** — multi-task syntax, `--team`, `--remember`
8. **Exception states** — BLOCKED, PARTIAL, EXPANDED, ABANDONED

This file is already well-structured and cohesive. It describes a single workflow (the agent task lifecycle) with its variations and edge cases.

---

## Recommended Decomposition

Proposed `docs/workflows/` file structure with one-sentence descriptions:

| Filename | Description |
|---|---|
| `README.md` | Table of contents and brief descriptions for all workflow documents |
| `agent-task-lifecycle.md` | The Claude Code task lifecycle: `/task`, `/research`, `/plan`, `/implement`, `/todo`, state machine, and exception handling |
| `edit-word-documents.md` | Editing `.docx` files in-place with Claude using tracked changes, including single-file, batch-folder, and create-new variants |
| `convert-documents.md` | Converting between document formats: PDF/DOCX to Markdown, Markdown to PDF, using `/convert` |
| `convert-spreadsheets.md` | Extracting spreadsheet data to formatted tables using `/table` (Excel/CSV to LaTeX or Typst) |
| `convert-presentations.md` | Converting PowerPoint presentations to source-based slide formats using `/slides` |
| `extract-pdf-annotations.md` | Extracting highlights and notes from PDF files to Markdown or JSON using `/scrape` |
| `edit-spreadsheets.md` | Directly editing `.xlsx` spreadsheet values and formulas using the openpyxl MCP tool |

**Total: 7 workflow files + README.md**

### Rationale for this split

- **agent-task-lifecycle.md** is the moved-and-lightly-renamed `docs/agent-system/workflow.md`. Its content is already a clean, self-contained document.
- The office file workflows split at natural command and tool boundaries. Each command maps to a different MCP tool (SuperDoc vs openpyxl vs pandoc/etc.) and has distinct prerequisites, steps, and use cases.
- The batch editing and create-new variants of `/edit` are grouped into `edit-word-documents.md` because they share the same tool, command, and Word-centric UX. The file is a natural home for "everything you can do with `/edit`."
- Conversion commands could be merged into a single `convert-documents.md`, but keeping them separate allows each to be a clear, focused reference. Alternatively, they could be grouped under a single `convert-and-extract.md` if brevity is preferred (see alternative below).

### Alternative: consolidated conversion file

If four separate conversion files feels granular:

| Filename | Description |
|---|---|
| `convert-and-extract.md` | Converting documents, extracting spreadsheet tables, converting presentations, and extracting PDF annotations — all `/convert`, `/table`, `/slides`, `/scrape` commands |

This reduces the count to 4 workflow files + README.md and is appropriate if the individual conversion workflows are short (they are: each command in the source file is ~3–6 lines).

---

## Content Mapping

### agent-task-lifecycle.md
- Entire contents of `docs/agent-system/workflow.md` (all 124 lines)
- Update internal links: `commands.md` -> `../agent-system/commands.md`, `architecture.md` -> `../agent-system/architecture.md`, `context-and-memory.md` -> `../agent-system/context-and-memory.md`
- Update cross-references in `docs/agent-system/README.md` to point to `../workflows/agent-task-lifecycle.md`

### edit-word-documents.md
From `docs/office-workflows.md`:
- "How Claude Edits Word Documents" section (lines 14–25) — mechanism overview
- "Edit Word Documents In-Place" section (lines 67–83) — step-by-step `/edit` workflow
- "Batch Document Editing" section (lines 105–120) — folder-level `/edit`
- "Create New Documents" section (lines 122–137) — `/edit --new`
- "Prompt Examples" table (lines 139–149) — reference card
- "Editing a collaborator's Word document" from Workflow Examples (lines 166–169) — brief scenario
- "macOS permissions dialog" troubleshooting entry (lines 194–195)

### convert-documents.md
From `docs/office-workflows.md`:
- "Document Conversion with Claude Code" section header/intro (lines 29–39) — `/convert`
- "Reviewing a PDF paper" workflow example (lines 153–158) — uses `/scrape` + conversion chain
- "Creating a report from data" workflow example (lines 160–164) — uses `/table` + `/convert`
- Troubleshooting entries for "command not found" and MCP tools (lines 185–191) — apply to all commands

### convert-spreadsheets.md
From `docs/office-workflows.md`:
- "Extract tables from spreadsheets" section (lines 44–49) — `/table` command

### convert-presentations.md
From `docs/office-workflows.md`:
- "Convert presentations" section (lines 51–54) — `/slides` command

### extract-pdf-annotations.md
From `docs/office-workflows.md`:
- "Extract PDF annotations" section (lines 56–64) — `/scrape` command

### edit-spreadsheets.md
From `docs/office-workflows.md`:
- "Direct Spreadsheet Editing" section (lines 86–103) — openpyxl editing workflow
- "OneDrive and SharePoint Tips" section (lines 171–182) — applies specifically to batch editing but is worth noting here too as a prerequisite tip

**Sections of office-workflows.md not mapped to individual workflow files:**
- "Quick Start" (lines 5–11) — belongs in `workflows/README.md` as an orientation summary
- "Available Tasks (tasks.json)" (lines 197–201) — belongs in `workflows/README.md` or `docs/settings.md`
- "Related Documentation" (lines 203–210) — split into per-file "See also" sections
- "Agent panel not responding" troubleshooting (lines 192–195) — better in `docs/agent-system/zed-agent-panel.md`

---

## Cross-Link Opportunities

### Within docs/workflows/

| From | To | Link text suggestion |
|---|---|---|
| `edit-word-documents.md` | `edit-spreadsheets.md` | "For editing spreadsheet values, see [Editing Spreadsheets](edit-spreadsheets.md)" |
| `edit-spreadsheets.md` | `edit-word-documents.md` | "For editing Word documents with tracked changes, see [Editing Word Documents](edit-word-documents.md)" |
| `convert-documents.md` | `convert-spreadsheets.md` | "To extract a spreadsheet as a table first, see [Converting Spreadsheets](convert-spreadsheets.md)" |
| `convert-documents.md` | `extract-pdf-annotations.md` | "To extract PDF annotations before converting, see [Extracting PDF Annotations](extract-pdf-annotations.md)" |
| `edit-word-documents.md` | `convert-documents.md` | "To convert a completed document to PDF, see [Converting Documents](convert-documents.md)" |
| `agent-task-lifecycle.md` | all others | "For document workflows in Zed, see [workflows/README.md](README.md)" (in "See also") |

### From docs/workflows/ to docs/agent-system/

| From | To | Link text suggestion |
|---|---|---|
| `agent-task-lifecycle.md` | `../agent-system/commands.md` | Full command catalog |
| `agent-task-lifecycle.md` | `../agent-system/architecture.md` | How commands, skills, and agents fit together |
| `agent-task-lifecycle.md` | `../agent-system/context-and-memory.md` | Memory vault |
| All office workflow files | `../installation.md#install-mcp-tools` | MCP tools installation prerequisite |

### From docs/agent-system/ to docs/workflows/

| From | To | Update needed |
|---|---|---|
| `docs/agent-system/README.md` | `../workflows/agent-task-lifecycle.md` | Update `workflow.md` link in Navigation section |
| `docs/README.md` | `workflows/README.md` | Replace `office-workflows.md` entry; add `workflows/` entry |

---

## README.md TOC Proposal

```markdown
# Workflows

Guides for common tasks in Zed with Claude Code.

## Agent Workflows

- [Agent Task Lifecycle](agent-task-lifecycle.md) — The Claude Code task lifecycle:
  create, research, plan, implement, and archive using `/task`, `/research`, `/plan`,
  `/implement`, and `/todo`. Includes the state machine, resumability, team mode, and
  exception handling.

## Office File Workflows

Working with Word, Excel, PowerPoint, and PDF files on macOS using Claude Code commands
and MCP tools (SuperDoc, openpyxl).

- [Editing Word Documents](edit-word-documents.md) — Edit `.docx` files in-place with
  Claude using tracked changes. Covers single-file editing, batch folder editing, and
  creating new documents from a description.
- [Editing Spreadsheets](edit-spreadsheets.md) — Edit `.xlsx` spreadsheet values and
  formulas directly using the openpyxl MCP tool.
- [Converting Documents](convert-documents.md) — Convert PDF or DOCX to Markdown, or
  Markdown to PDF, using `/convert`.
- [Converting Spreadsheets to Tables](convert-spreadsheets.md) — Extract Excel or CSV
  data as a formatted LaTeX or Typst table using `/table`.
- [Converting Presentations](convert-presentations.md) — Convert PowerPoint decks to
  Beamer, Polylux, or Touying slide source using `/slides`.
- [Extracting PDF Annotations](extract-pdf-annotations.md) — Pull highlights, sticky
  notes, and margin comments from a PDF into Markdown or JSON using `/scrape`.

## Quick Start

Three ways to work with Office files from Zed:
1. **Word / Excel** — Open files directly for visual editing
2. **Claude Code commands** — Use `/edit`, `/convert`, `/table`, `/slides`, `/scrape`
3. **Zed task runner** — Quick-launch files from the editor (see [Settings](../settings.md))

## See Also

- [Installation](../installation.md#install-mcp-tools) — Install the MCP tools used by these workflows
- [Agent System](../agent-system/README.md) — Orientation to Claude Code and Zed AI integration
- [Keybindings](../keybindings.md) — Terminal and editor shortcuts
```

---

## Confidence Level

**High**

The content mapping is deterministic: both source files have clear section boundaries with distinct topics. The only judgment call is whether to keep the four conversion commands as separate files or consolidate them. Given that each command targets a different file format and MCP tool, separate files are the cleaner long-term choice (easier to link to and extend). The merged alternative is documented above if brevity is preferred.

The `agent-task-lifecycle.md` file is a straightforward rename-and-move with link updates; no content restructuring is needed.
