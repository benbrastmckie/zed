# Workflows

End-to-end usage narratives for working in **R** and **Python** with **Claude Code** in this Zed configuration. Each guide covers "when and why" to use a group of commands — for flag-level reference, see [`../agent-system/commands.md`](../agent-system/commands.md).

> **Note**: These docs are narrative guides. When something looks out of date, check [`../agent-system/commands.md`](../agent-system/commands.md) for the authoritative flag reference.

## Languages

For day-to-day R and Python development, the generic agent task lifecycle ([agent-lifecycle.md](agent-lifecycle.md)) is the primary workflow: `/research`, `/plan`, `/implement` over your R or Python codebase. For language-level setup, see:

- [../general/python.md](../general/python.md) — Python (pyright + ruff + uv) setup in Zed
- [../general/R.md](../general/R.md) — R (r-language-server + lintr + styler) setup in Zed

## Contents

### Agent system

| File | Description |
|---|---|
| [agent-lifecycle.md](agent-lifecycle.md) | Task lifecycle: `/task`, `/research`, `/plan`, `/implement`, `/todo`, `/revise`, `/spawn` |
| [maintenance-and-meta.md](maintenance-and-meta.md) | Code quality, error tracking, cleanup, system building, shipping: `/review`, `/errors`, `/fix-it`, `/refresh`, `/meta`, `/merge`, `/tag` |

### Epidemiology

| File | Description |
|---|---|
| [epidemiology-analysis.md](epidemiology-analysis.md) | Epidemiological study design and R-based analysis: `/epi` *(requires `epidemiology` extension)* |

### Grant development

| File | Description |
|---|---|
| [grant-development.md](grant-development.md) | Research proposals, budgets, timelines, funding analysis, talks: `/grant`, `/budget`, `/timeline`, `/funds`, `/slides` *(requires `present` extension)* |

### Memory

| File | Description |
|---|---|
| [memory-and-learning.md](memory-and-learning.md) | Persistent knowledge across sessions: `/learn`, `--remember` flag *(requires `memory` extension)* |

### Office documents

| File | Description |
|---|---|
| [edit-word-documents.md](edit-word-documents.md) | Edit .docx files with tracked changes, batch edit folders, create new documents |
| [edit-spreadsheets.md](edit-spreadsheets.md) | Direct .xlsx editing via the openpyxl MCP tool |
| [convert-documents.md](convert-documents.md) | Convert between PDF, DOCX, Markdown, XLSX, PPTX; extract PDF annotations; generate LaTeX/Typst tables |
| [tips-and-troubleshooting.md](tips-and-troubleshooting.md) | OneDrive sync pauses, first-time macOS permissions, common errors, tasks.json runners |

## Decision guide

| I want to... | See |
|---|---|
| Understand how `/task` / `/research` / `/plan` / `/implement` fit together | [agent-lifecycle.md](agent-lifecycle.md) |
| Revise a plan or unblock a task | [agent-lifecycle.md](agent-lifecycle.md#revising-a-plan) |
| Investigate code quality or errors | [maintenance-and-meta.md](maintenance-and-meta.md#reviewing-code-quality) |
| Scan for FIX/TODO tags and create tasks | [maintenance-and-meta.md](maintenance-and-meta.md#finding-and-fixing-errors) |
| Build or modify the agent system | [maintenance-and-meta.md](maintenance-and-meta.md#changing-the-agent-system) |
| Create a pull request | [maintenance-and-meta.md](maintenance-and-meta.md#shipping-changes) |
| Design and run an epidemiology study in R | [epidemiology-analysis.md](epidemiology-analysis.md) |
| Develop a grant proposal or budget | [grant-development.md](grant-development.md#starting-a-grant-proposal) |
| Plan a research timeline | [grant-development.md](grant-development.md#planning-a-research-timeline) |
| Explore funding sources | [grant-development.md](grant-development.md#exploring-funding-sources) |
| Prepare a research talk | [grant-development.md](grant-development.md#preparing-a-research-talk) |
| Save or recall knowledge across sessions | [memory-and-learning.md](memory-and-learning.md) |
| Edit a Word document with tracked changes | [edit-word-documents.md](edit-word-documents.md#edit-in-place-with-tracked-changes) |
| Update many Word files at once | [edit-word-documents.md](edit-word-documents.md#batch-edit-a-folder) |
| Create a new Word document from scratch | [edit-word-documents.md](edit-word-documents.md#create-new-documents) |
| Change values in an .xlsx file | [edit-spreadsheets.md](edit-spreadsheets.md) |
| Turn a PDF into Markdown (or back) | [convert-documents.md](convert-documents.md#convert--documents-between-formats) |
| Pull a table out of a spreadsheet as LaTeX/Typst | [convert-documents.md](convert-documents.md#table--spreadsheets-to-formatted-tables) |
| Convert a PowerPoint deck into Beamer/Polylux/Touying | [convert-documents.md](convert-documents.md#slides--research-talk-creation) |
| Extract highlights and notes from a PDF | [convert-documents.md](convert-documents.md#scrape--pdf-annotations-to-markdown-or-json) |
| Pause OneDrive sync before a batch edit | [tips-and-troubleshooting.md](tips-and-troubleshooting.md#onedrive-and-sharepoint-tips) |
| Grant Zed permission to control Word | [tips-and-troubleshooting.md](tips-and-troubleshooting.md#first-time-macos-permissions-for-word-automation) |

## Common scenarios

### Developing a grant proposal

1. Run `/grant "NIH R01 on neural mechanisms of decision-making"` to create the task (see [grant-development.md](grant-development.md#starting-a-grant-proposal))
2. Use `/research N` and `/plan N` to investigate and design the proposal
3. Run `/grant N --draft` to draft narrative sections, `/grant N --budget` for the budget
4. Use `/learn --task N` to save key findings for future proposals (see [memory-and-learning.md](memory-and-learning.md#harvesting-task-artifacts))

### Investigating and fixing codebase issues

1. Run `/review` for a broad code quality assessment (see [maintenance-and-meta.md](maintenance-and-meta.md#reviewing-code-quality))
2. Run `/fix-it src/` to scan for inline tags and create tasks (see [maintenance-and-meta.md](maintenance-and-meta.md#finding-and-fixing-errors))
3. Work through the created tasks with `/research` -> `/plan` -> `/implement`
4. Run `/merge` to ship the fixes

### Reviewing a PDF paper

1. Open Zed, press **Cmd+`** for a terminal
2. Run `/scrape paper.pdf` to extract annotations (see [convert-documents.md](convert-documents.md#scrape--pdf-annotations-to-markdown-or-json))
3. Review the extracted notes in Markdown
4. Use the Agent Panel (**Ctrl+?**) to discuss the paper with Claude

### Creating a report from data

1. Run `/table results.xlsx` to get formatted tables (see [convert-documents.md](convert-documents.md#table--spreadsheets-to-formatted-tables))
2. Write the report in Markdown
3. Run `/convert report.md` to produce a PDF

### Editing a collaborator's Word document

1. Run `/edit document.docx "instruction"` for AI-assisted edits with tracked changes (see [edit-word-documents.md](edit-word-documents.md#edit-in-place-with-tracked-changes))
2. Or open the file in Word for manual edits
3. If you hit a macOS permissions dialog, see [tips-and-troubleshooting.md](tips-and-troubleshooting.md#first-time-macos-permissions-for-word-automation)

## See also

- [`../agent-system/README.md`](../agent-system/README.md) — Claude Code agent system reference (commands, architecture, context, memory)
- [`../general/settings.md`](../general/settings.md) — Zed settings and task runner configuration
- [`../general/installation.md`](../general/installation.md) — Installation and MCP tool setup
