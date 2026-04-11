# Edit Spreadsheets

Use this when you need to change values, add rows, or update formulas in an .xlsx file. Claude uses the openpyxl MCP tool to edit spreadsheets directly from Zed's Agent Panel.

**Important:** Save and close the file in Excel first -- the automatic reload only works with Word for now. If Excel has the file open, openpyxl cannot write to it.

## Steps

1. **Save and close** the spreadsheet in Excel
2. Open Claude Code in Zed (**Ctrl+Shift+A**)
3. Describe what you want changed, being specific about sheet names, row labels, or column headers
4. Open the file in Excel to verify the changes

## Example prompt

> In ~/Documents/budget.xlsx on the "Q2" sheet, change the Marketing row from 5000 to 7500, change Engineering from 12000 to 14000, and add a new row called "Cloud Services" with values 3000, 3200, 3500.

## Tips

- Be explicit about which sheet and which rows/columns. Labels are more reliable than cell coordinates.
- For bulk structural changes (reformatting, inserting columns), describe the intent and let Claude decide the cell ops.
- If you want a formatted table instead of a direct edit, see [convert-documents.md](convert-documents.md) for the `/table` command.
- For macOS permission prompts and common errors, see [tips-and-troubleshooting.md](tips-and-troubleshooting.md).
- The openpyxl MCP tool must be installed first — see [Install MCP Tools](../general/installation.md#install-mcp-tools).

## See also

- [edit-word-documents.md](edit-word-documents.md) — Edit .docx files with tracked changes
- [convert-documents.md](convert-documents.md) — Extract spreadsheets as LaTeX/Typst tables with `/table`
- [tips-and-troubleshooting.md](tips-and-troubleshooting.md) — OneDrive, macOS permissions, common errors
