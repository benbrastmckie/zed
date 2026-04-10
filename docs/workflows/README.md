# Workflows

End-to-end usage narratives for working with this Zed configuration on macOS. The agent-system workflow explains how Claude Code tasks move through their lifecycle; the office workflows explain how to use `/edit`, `/convert`, and related commands to work with Word, Excel, PowerPoint, and PDF files. For flag-level command reference, see [`../agent-system/commands.md`](../agent-system/commands.md).

## Contents

### Agent system

| File | Description |
|---|---|
| [agent-lifecycle.md](agent-lifecycle.md) | Claude Code task lifecycle state machine and the seven main-workflow commands (`/task`, `/research`, `/plan`, `/implement`, `/todo`) |

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
| Edit a Word document with tracked changes | [edit-word-documents.md](edit-word-documents.md#edit-in-place-with-tracked-changes) |
| Update many Word files at once | [edit-word-documents.md](edit-word-documents.md#batch-edit-a-folder) |
| Create a new Word document from scratch | [edit-word-documents.md](edit-word-documents.md#create-new-documents) |
| Change values in an .xlsx file | [edit-spreadsheets.md](edit-spreadsheets.md) |
| Turn a PDF into Markdown (or back) | [convert-documents.md](convert-documents.md#convert--documents-between-formats) |
| Pull a table out of a spreadsheet as LaTeX/Typst | [convert-documents.md](convert-documents.md#table--spreadsheets-to-formatted-tables) |
| Convert a PowerPoint deck into Beamer/Polylux/Touying | [convert-documents.md](convert-documents.md#slides--presentations-to-source-based-slides) |
| Extract highlights and notes from a PDF | [convert-documents.md](convert-documents.md#scrape--pdf-annotations-to-markdown-or-json) |
| Pause OneDrive sync before a batch edit | [tips-and-troubleshooting.md](tips-and-troubleshooting.md#onedrive-and-sharepoint-tips) |
| Grant Zed permission to control Word | [tips-and-troubleshooting.md](tips-and-troubleshooting.md#first-time-macos-permissions-for-word-automation) |

## Common scenarios

### Reviewing a PDF paper

1. Open Zed, press **Cmd+`** for a terminal
2. Run `/scrape paper.pdf` to extract annotations (see [convert-documents.md](convert-documents.md#scrape--pdf-annotations-to-markdown-or-json))
3. Review the extracted notes in Markdown
4. Use the Agent Panel (**Cmd+Shift+?**) to discuss the paper with Claude

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
