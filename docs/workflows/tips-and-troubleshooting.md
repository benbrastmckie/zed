# Tips and Troubleshooting

Cross-cutting tips and common errors for the Office document workflows in this directory. If you are hitting the same macOS permissions dialog or OneDrive sync conflict from multiple workflows, the canonical instructions live here.

## Opening the Agent Panel

All the workflows in this directory start the same way: press **Ctrl+Shift+A** to open Claude Code, then type your request. Terminal commands (like `/convert`, `/table`, `/scrape`) can also run from a Zed terminal opened with **Cmd+`**. Alternatively, the Agent Panel sidebar (Ctrl+?) provides a lighter-weight interface for quick questions.

## First-time macOS permissions for Word automation

The first time Claude edits a document while Word is open, macOS will ask you to grant Zed (or WezTerm) permission to control Microsoft Word. Click **OK** when the dialog appears. This only happens once per application.

If you dismissed the dialog by mistake, open **System Settings > Privacy & Security > Automation**, find Zed (or WezTerm) in the list, and enable the checkbox next to **Microsoft Word**.

## OneDrive and SharePoint tips

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
Re-run the `claude mcp add` command with `--scope user`. See [Install MCP Tools](../general/installation.md#install-mcp-tools) for the exact commands.

**Agent panel not responding**
In Zed, go to **Settings > Extensions** and confirm "Claude Code" is listed. If not, search for it and install it.

**macOS permissions dialog for Word automation**
See the [First-time macOS permissions](#first-time-macos-permissions-for-word-automation) section above. You only need to click OK once.

**openpyxl cannot write to the spreadsheet**
Save and close the file in Excel first. The automatic reload that Word enjoys does not apply to Excel yet.

## tasks.json runners

Zed's `tasks.json` registers a few runners that complement these workflows:

| Task | What it does |
|------|-------------|
| Export Agent System | Exports the .claude/ config to a single Markdown file |
| Git Status | Shows a short git status summary |

For full task runner configuration, see [../general/settings.md](../general/settings.md).

## See also

- [Workflows index](README.md) — All workflows in this directory
- [edit-word-documents.md](edit-word-documents.md) — Edit .docx files with tracked changes
- [edit-spreadsheets.md](edit-spreadsheets.md) — Direct .xlsx editing via openpyxl
- [convert-documents.md](convert-documents.md) — Convert between PDF, DOCX, Markdown, XLSX, PPTX
- [Install MCP Tools](../general/installation.md#install-mcp-tools)
