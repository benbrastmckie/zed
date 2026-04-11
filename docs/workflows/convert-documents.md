# Convert Documents

Extract, convert, and reformat documents between PDF, DOCX, Markdown, spreadsheets, presentations, and PDF annotations. All of these commands run from Claude Code (Ctrl+Shift+A) or a Zed terminal (Cmd+`).

## Decision guide

| I want to... | Use |
|---|---|
| Turn a PDF or Word file into Markdown | `/convert` |
| Turn Markdown into a PDF | `/convert` |
| Pull a table out of a spreadsheet into LaTeX/Typst | `/table` |
| Turn a PowerPoint deck into Beamer/Polylux/Touying source | `/convert --format` |
| Pull highlights and notes out of a PDF | `/scrape` |
| Edit an existing .docx in place | See [edit-word-documents.md](edit-word-documents.md) |

## /convert — documents between formats

```
/convert report.pdf          # PDF to Markdown
/convert notes.docx          # Word to Markdown
/convert draft.md            # Markdown to PDF
```

The `/convert` command detects the input format and converts to a useful output format. You can specify the target format if needed.

## /table — spreadsheets to formatted tables

```
/table data.xlsx             # Excel to LaTeX or Typst table
/table budget.csv            # CSV to formatted table
```

This reads the spreadsheet and produces a clean table in LaTeX or Typst format, ready to paste into a document. If you want to modify the underlying .xlsx instead, see [edit-spreadsheets.md](edit-spreadsheets.md).

## /slides — research talk creation

`/slides` now creates research talk tasks with forcing questions. For PPTX-to-slide conversion, use `/convert` with the `--format` flag:

```
/convert deck.pptx --format beamer     # PowerPoint to Beamer
/convert deck.pptx --format polylux    # PowerPoint to Polylux
/convert deck.pptx --format touying    # PowerPoint to Touying
```

See [commands.md](../agent-system/commands.md#slides) for talk modes and examples.

## /scrape — PDF annotations to Markdown or JSON

```
/scrape paper.pdf            # Highlights and notes to Markdown/JSON
```

Pulls out all highlights, sticky notes, and margin comments from a PDF. Useful for reading papers and collecting notes.

## Tips

- If your source files live in OneDrive, see the [OneDrive tips](tips-and-troubleshooting.md#onedrive-and-sharepoint-tips) before running batch conversions.
- The MCP tools that power these commands (SuperDoc, openpyxl, scrape) must be installed first — see [Install MCP Tools](../general/installation.md#install-mcp-tools).
- For the full flag reference on each command, see [`../agent-system/commands.md`](../agent-system/commands.md).

## See also

- [edit-word-documents.md](edit-word-documents.md) — Edit converted .docx output with tracked changes
- [edit-spreadsheets.md](edit-spreadsheets.md) — Direct .xlsx editing via openpyxl
- [tips-and-troubleshooting.md](tips-and-troubleshooting.md) — OneDrive, macOS permissions, common errors
- [`../agent-system/commands.md`](../agent-system/commands.md) — Full command reference
