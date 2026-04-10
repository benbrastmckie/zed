# Office File Workflows

Working with Office documents (Word, Excel, PowerPoint, PDF) on Linux using Zed and Claude Code.

## Quick Start

There are three ways to work with Office files from Zed:

1. **LibreOffice** -- Open files directly for visual editing
2. **Claude Code commands** -- Convert, extract, and transform documents
3. **Zed task runner** -- Quick-launch LibreOffice from the editor

## Opening Files in LibreOffice

### From the task runner

1. Open the file you want to edit in Zed (or just have it selected in the file explorer)
2. Open the command palette: **Ctrl+Shift+P**
3. Type "task" and select **task: spawn**
4. Choose **Open in LibreOffice**

This runs `libreoffice $ZED_FILE` -- it opens the current file in LibreOffice.

### From the terminal

Press **Ctrl+`** to open the terminal, then:

```bash
libreoffice path/to/document.docx
```

## Document Conversion with Claude Code

Claude Code can convert between formats without leaving Zed. Open the terminal (Ctrl+`) and use these commands:

### Convert documents

```
/convert report.pdf          # PDF to Markdown
/convert notes.docx          # Word to Markdown
/convert draft.md            # Markdown to PDF
```

The `/convert` command detects the input format and converts to a useful output format. You can specify the target format if needed.

### Extract tables from spreadsheets

```
/table data.xlsx             # Excel to LaTeX or Typst table
/table budget.csv            # CSV to formatted table
```

This reads the spreadsheet and produces a clean table in LaTeX or Typst format, ready to paste into a document.

### Convert presentations

```
/slides deck.pptx            # PowerPoint to Beamer/Polylux/Touying slides
```

Extracts slide content and converts to a source-based presentation format.

### Extract PDF annotations

```
/scrape paper.pdf            # Highlights and notes to Markdown/JSON
```

Pulls out all highlights, sticky notes, and margin comments from a PDF. Useful for reading papers and collecting notes.

### Edit Word documents in-place

```
/edit report.docx "Fix the methodology section"
```

Edits a DOCX file directly with tracked changes, without converting to another format first.

## Workflow Examples

### Reviewing a PDF paper

1. Open Zed, press Ctrl+` for terminal
2. Run `/scrape paper.pdf` to extract annotations
3. Review the extracted notes in Markdown
4. Use the agent panel (Ctrl+?) to discuss the paper

### Creating a report from data

1. Run `/table results.xlsx` to get formatted tables
2. Write the report in Markdown
3. Run `/convert report.md` to produce a PDF
4. Or open in LibreOffice for final formatting

### Editing a collaborator's Word document

1. Run `/edit document.docx "instruction"` for AI-assisted edits with tracked changes
2. Or open in LibreOffice via the task runner for manual edits

## Available Tasks (tasks.json)

| Task | What it does |
|------|-------------|
| Open in LibreOffice | Opens the current file in LibreOffice |
| Export Agent System | Exports the .claude/ config to a single Markdown file |
| Git Status | Shows a short git status summary |

## Related Documentation

- [Settings reference](settings.md) -- Task runner configuration
- [Agent system](agent-system.md) -- Claude Code commands
- [Keybindings guide](guides/keybindings.md) -- Terminal and editor shortcuts
- [README](../README.md) -- Navigation hub
