# Edit Word Documents

Use `/edit` to modify .docx files from Zed's Agent Panel. Claude handles save-edit-reload for you, can produce tracked changes, edit whole folders at once, or create new documents from scratch.

Open Claude Code in Zed with **Ctrl+Shift+A** and type your request. For macOS permission prompts and common errors, see [tips-and-troubleshooting.md](tips-and-troubleshooting.md). For the full `/edit` flag reference, see [`../agent-system/commands.md`](../agent-system/commands.md). The SuperDoc MCP tool must be installed first — see [Install MCP Tools](../general/installation.md#install-mcp-tools).

## How Claude edits Word documents

When you ask Claude to edit a Word document, here is what happens behind the scenes:

1. You type a request in Zed's Agent Panel (e.g., `/edit ~/Documents/contract.docx "Replace 'ACME Corp' with 'NewCo Inc.'"`)
2. Claude saves any unsaved changes in Word for you
3. Claude makes the edits using SuperDoc (with tracked changes if you ask)
4. Claude reloads the document in Word automatically
5. You see the tracked changes appear in Word -- no need to reopen anything

You stay in Zed to give instructions. Word stays open the whole time -- Claude handles the save-edit-reload cycle for you.

## Edit in-place with tracked changes

Use `/edit` when you want Claude to modify an existing .docx file with tracked changes, so you can review each change in Word before accepting it. Word can stay open -- Claude handles saving and reloading for you.

```
/edit report.docx "Fix the methodology section"
```

**Steps:**

1. Type your request using `/edit` in the Agent Panel
2. Wait for Claude to confirm the edits are done
3. Switch to **Word** -- the tracked changes will already be there

**Example prompt:**

> /edit ~/Documents/contract.docx "Replace every instance of 'ACME Corp' with 'NewCo Inc.' using tracked changes"

## Batch edit a folder

Use this when you need to make the same change across several Word files -- for example, updating a company name in all your contract templates.

```
/edit path/to/folder/ "your instructions"
```

**Steps:**

1. If your files are in OneDrive, **pause syncing** first (see [tips-and-troubleshooting.md](tips-and-troubleshooting.md#onedrive-and-sharepoint-tips))
2. Tell Claude which folder and what to change
3. Resume OneDrive syncing when done

**Example prompt:**

> /edit ~/Documents/Contracts/ "Replace 'Old Company LLC' with 'New Company LLC' using tracked changes. Give me a summary of how many changes were made in each file."

## Create new documents

Use this when you want Claude to draft and format a new Word document from scratch.

```
/edit --new path/to/file.docx "description of what you need"
```

**Steps:**

1. Describe what you need -- include the title, sections, and any specific content
2. Open the new file in Word to review and polish

**Example prompt:**

> /edit --new ~/Documents/memo.docx "Create a Q2 Budget Review memo, dated April 9, 2026, from Sarah Chen (Finance Director) to the Executive Team. Include a brief summary paragraph and a table with 4 columns: Department, Q1 Actual, Q2 Budget, and Variance."

## Prompt examples

Useful phrases for working with Claude and Word files. Start with `/edit` for any Word document task:

| I want to... | Example prompt |
|---|---|
| Find and replace text | `/edit file.docx "replace X with Y"` |
| Get reviewable tracked changes | `/edit file.docx "replace X with Y using tracked changes"` |
| Create a new document | `/edit --new file.docx "create a memo about..."` |
| Edit many files at once | `/edit ~/Documents/Contracts/ "replace X with Y in all files"` |
| Get a summary (no edits) | "Give me a summary of..." (no `/edit` needed) |

## See also

- [edit-spreadsheets.md](edit-spreadsheets.md) — Direct .xlsx editing via openpyxl
- [convert-documents.md](convert-documents.md) — Convert between PDF, DOCX, Markdown, and more
- [tips-and-troubleshooting.md](tips-and-troubleshooting.md) — OneDrive, macOS permissions, common errors
- [`../agent-system/commands.md`](../agent-system/commands.md) — Full `/edit` flag reference
