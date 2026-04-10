# Office File Workflows

Working with Office documents (Word, Excel, PowerPoint, PDF) on macOS using Zed and Claude Code.

## Quick Start

There are three ways to work with Office files from Zed:

1. **Word / Excel** -- Open files directly for visual editing and review
2. **Claude Code commands** -- Convert, extract, edit, and create documents
3. **Zed task runner** -- Quick-launch files from the editor

## How Claude Edits Word Documents

When you ask Claude to edit a Word document, here is what happens behind the scenes:

1. You type a request in Zed's Agent Panel (e.g., `/edit ~/Documents/contract.docx "Replace 'ACME Corp' with 'NewCo Inc.'"`)
2. Claude saves any unsaved changes in Word for you
3. Claude makes the edits using SuperDoc (with tracked changes if you ask)
4. Claude reloads the document in Word automatically
5. You see the tracked changes appear in Word -- no need to reopen anything

You stay in Zed to give instructions. Word stays open the whole time -- Claude handles the save-edit-reload cycle for you.

**First-time macOS permissions**: The first time Claude edits a document while Word is open, macOS will ask you to grant Zed (or WezTerm) permission to control Microsoft Word. Click **OK** when the dialog appears. This only happens once.

## Document Conversion with Claude Code

Open the terminal (Cmd+`) and use these commands:

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

## Edit Word Documents In-Place

Use `/edit` when you want Claude to modify an existing .docx file with tracked changes, so you can review each change in Word before accepting it. Word can stay open -- Claude handles saving and reloading for you.

```
/edit report.docx "Fix the methodology section"
```

**Steps:**

1. Open **Zed** and press **Cmd+Shift+?** to open the Agent Panel
2. Type your request using `/edit` (see examples below)
3. Wait for Claude to confirm the edits are done
4. Switch to **Word** -- the tracked changes will already be there

**Example prompt:**

> /edit ~/Documents/contract.docx "Replace every instance of 'ACME Corp' with 'NewCo Inc.' using tracked changes"

## Direct Spreadsheet Editing

Use this when you need to change values, add rows, or update formulas in an .xlsx file. Claude uses the openpyxl MCP tool to edit spreadsheets directly.

**Important:** Save and close the file in Excel first -- the automatic reload only works with Word for now.

**Steps:**

1. **Save and close** the spreadsheet in Excel
2. Open the Agent Panel in Zed (Cmd+Shift+?)
3. Describe what you want changed, being specific about sheet names, row labels, or column headers
4. Open the file in Excel to verify

**Example prompt:**

> In ~/Documents/budget.xlsx on the "Q2" sheet, change the Marketing row from 5000 to 7500, change Engineering from 12000 to 14000, and add a new row called "Cloud Services" with values 3000, 3200, 3500.

## Batch Document Editing

Use this when you need to make the same change across several Word files -- for example, updating a company name in all your contract templates.

```
/edit path/to/folder/ "your instructions"
```

**Steps:**

1. If your files are in OneDrive, **pause syncing** first (see [OneDrive tips](#onedrive-and-sharepoint-tips) below)
2. Open the Agent Panel in Zed (Cmd+Shift+?)
3. Tell Claude which folder and what to change
4. Resume OneDrive syncing when done

**Example prompt:**

> /edit ~/Documents/Contracts/ "Replace 'Old Company LLC' with 'New Company LLC' using tracked changes. Give me a summary of how many changes were made in each file."

## Create New Documents

Use this when you want Claude to draft and format a new Word document from scratch.

```
/edit --new path/to/file.docx "description of what you need"
```

**Steps:**

1. Open the Agent Panel in Zed (Cmd+Shift+?)
2. Describe what you need -- include the title, sections, and any specific content
3. Open the new file in Word to review and polish

**Example prompt:**

> /edit --new ~/Documents/memo.docx "Create a Q2 Budget Review memo, dated April 9, 2026, from Sarah Chen (Finance Director) to the Executive Team. Include a brief summary paragraph and a table with 4 columns: Department, Q1 Actual, Q2 Budget, and Variance."

## Prompt Examples

Useful phrases for working with Claude and Office files. Start with `/edit` for any Word document task:

| I want to... | Example prompt |
|---|---|
| Find and replace text | `/edit file.docx "replace X with Y"` |
| Get reviewable tracked changes | `/edit file.docx "replace X with Y using tracked changes"` |
| Create a new document | `/edit --new file.docx "create a memo about..."` |
| Edit many files at once | `/edit ~/Documents/Contracts/ "replace X with Y in all files"` |
| Get a summary (no edits) | "Give me a summary of..." (no `/edit` needed) |

## Workflow Examples

### Reviewing a PDF paper

1. Open Zed, press Cmd+` for terminal
2. Run `/scrape paper.pdf` to extract annotations
3. Review the extracted notes in Markdown
4. Use the agent panel (Cmd+Shift+?) to discuss the paper

### Creating a report from data

1. Run `/table results.xlsx` to get formatted tables
2. Write the report in Markdown
3. Run `/convert report.md` to produce a PDF

### Editing a collaborator's Word document

1. Run `/edit document.docx "instruction"` for AI-assisted edits with tracked changes
2. Or open in Word for manual edits

## OneDrive and SharePoint Tips

If your documents sync with OneDrive or SharePoint:

**Pause OneDrive sync for batch edits.** If you are editing many files at once (batch editing), pause syncing so OneDrive does not try to upload files mid-edit:

1. Click the **OneDrive icon** in your menu bar (top-right of screen)
2. Click the gear icon, then **Pause Syncing**
3. Choose a duration (2 hours is plenty)
4. Do your edits with Claude
5. Click the OneDrive icon again and choose **Resume Syncing**

## Troubleshooting

**"command not found" after installing Homebrew**
Close WezTerm completely (Cmd+Q) and reopen it. Homebrew needs a fresh terminal session.

**"superdoc" or "openpyxl" not showing in `claude mcp list`**
Re-run the `claude mcp add` command with `--scope user`. See [MCP Tool Setup](agent-system.md#mcp-tool-setup) for the exact commands.

**Agent panel not responding**
In Zed, go to **Settings > Extensions** and confirm "Claude Code" is listed. If not, search for it and install it.

**macOS permissions dialog for Word automation**
Click **OK** when macOS asks to grant Zed or WezTerm permission to control Microsoft Word. This only happens once.

## Available Tasks (tasks.json)

| Task | What it does |
|------|-------------|
| Export Agent System | Exports the .claude/ config to a single Markdown file |
| Git Status | Shows a short git status summary |

## Related Documentation

- [Settings reference](settings.md) -- Task runner configuration
- [Agent system](agent-system.md) -- Claude Code commands and MCP setup
- [Keybindings guide](keybindings.md) -- Terminal and editor shortcuts
- [README](../README.md) -- Navigation hub
