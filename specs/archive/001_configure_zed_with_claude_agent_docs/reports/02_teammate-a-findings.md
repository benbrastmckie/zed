# Teammate A: Zed Extensions Research Findings

**Focus**: Best Zed Extensions for Claude Code, Markdown, and Office Files
**Date**: 2026-04-09
**Confidence**: High (sourced directly from zed.dev/extensions marketplace and official documentation)

---

## Key Findings

### 1. Claude Code Integration: Built-in via ACP (No Extension Needed)

Claude Code is **not** a separate extension -- it is built into Zed natively via the **Agent Client Protocol (ACP)**. Key facts:

- Zed "runs the Claude Agent SDK, which runs Claude Code under the hood, and communicates to it over ACP"
- Activated by opening the agent panel (`Ctrl+?`) and clicking the `+` button to start a new Claude Agent thread
- Authentication: run `/login` inside the thread (supports API key entry or Claude Pro/Max subscription OAuth)
- Zed automatically manages the ACP adapter, installs it on first use, and keeps it updated
- The `CLAUDE_CODE_EXECUTABLE` environment variable can override which Claude Code binary is used

Known limitations of the ACP integration vs native Claude:
- No message editing after send
- No thread history resuming
- No checkpoint support
- Token usage display unavailable

**Configuration option** (custom executable path):
```json
{
  "agent_servers": {
    "claude-acp": {
      "type": "registry",
      "env": {
        "CLAUDE_CODE_EXECUTABLE": "/path/to/executable"
      }
    }
  }
}
```

**Anthropic API key configuration** (for direct Claude model use, separate from Claude Code agent):
- Set in agent settings via `agent: open settings` command palette action
- Or set `ANTHROPIC_API_KEY` environment variable
- Keys stored in OS secure credential storage (not plain text in settings.json)
- Custom models configured under `language_models.anthropic.available_models`

### 2. Markdown: Good Extension Ecosystem

Markdown has native built-in support in Zed plus several strong extensions:

**Built-in features** (no extension needed):
- Tree-sitter syntax highlighting with embedded code block language highlighting
- List continuation on Enter (configurable via `extend_list_on_newline`)
- List indentation on Tab (configurable via `indent_list_on_tab`)
- Prettier-based formatting on save via `format_on_save`
- No built-in markdown preview panel (this is a gap)

**Available extensions**:
- **Markdown Oxide** (86k downloads) -- Obsidian-inspired PKM language server; adds wiki-link support, backlinks, note graph features; ideal for knowledge management workflows
- **Markdownlint** (37k downloads) -- LSP-backed linting via markdownlint rules; catches style/structure issues
- **Rumdl Markdown Linter** (17k downloads) -- High-performance Rust-based markdown linter; low false positives; alternative to Markdownlint
- **MarkItDown MCP Server** (21k downloads) -- MCP server that converts various formats to Markdown; useful for Office-to-Markdown workflows
- **Markdown Snippets** (1k downloads) -- Snippet templates for faster markdown writing

**Notable gap**: No dedicated markdown preview extension exists in the marketplace. Zed does not currently have a markdown preview pane like VS Code's built-in preview or Typora.

### 3. Office File Formats (DOCX, XLSX, PDF): No Extensions Available

Search results were definitive:
- "No extensions found for 'office'" -- confirmed
- "No extensions found for 'docx'" -- confirmed
- "No extensions found for 'pdf'" -- confirmed
- "No extensions found for 'excel xlsx csv'" -- confirmed

**Exception**: CSV files do have extensions:
- **CSV** (117k downloads) -- CSV language support (syntax highlighting, basic editing)
- **Rainbow CSV** (101k downloads) -- Column-colored CSV viewing for readability

**Implication**: For DOCX/XLSX/PDF workflows, users must rely on external tools (e.g., the `markitdown` MCP server to convert Office files to Markdown for editing in Zed, then convert back). The MarkItDown MCP Server extension (21k downloads) specifically addresses this gap by enabling format conversion via AI agents.

### 4. General Productivity: Top Recommended Extensions

Based on download counts and utility:

**Language Support** (most downloaded):
- HTML (4.9M), TOML (901k), Java (706k), PHP (547k), SQL (530k)

**Git Integration**:
- **Git Firefly** (738k) -- Git syntax highlighting
- **GitHub MCP Server** (79k) -- GitHub API integration for AI agents
- **GitHub Actions** (30k) -- GitHub Actions LSP support
- **GitLab MCP Server** (37k) -- GitLab integration

**Spell Checking** (relevant for markdown/documentation writing):
- **Codebook Spell Checker** (98k) -- Fast, code-aware spell checker
- **Typos Spell Checker** (44k) -- Low false-positive source code spell checker
- **CSpell** (44k) -- CSpell language server integration

**MCP Servers** (enhance Claude Code agent capabilities):
- **Context7 MCP Server** (122k) -- Provides up-to-date library documentation to LLMs; directly benefits Claude Code by injecting current, version-specific API docs into context
- **GitHub MCP Server** (79k) -- Repository management and GitHub API access for agents
- **Sequential Thinking MCP Server** (62k) -- Step-by-step reasoning enhancement for AI
- **Brave Search MCP Server** (48k) -- Web search capability for AI agents
- **GitLab MCP Server** (37k) -- GitLab integration
- **GitHub Activity Summarizer** (33k) -- Summarizes GitHub activity via AI

**Themes** (for comfort during long sessions):
- Catppuccin (823k), Tokyo Night (283k), One Dark Pro (195k)
- **Claude Code Inspired Dark** (27k) -- Dark theme inspired by Anthropic/Claude brand colors (semi-transparent backgrounds)

### 5. Extension Installation on Linux

**Method 1 (GUI)**: `Ctrl+Shift+X` or select "Zed > Extensions" from the menu bar

**Method 2 (Command Palette)**: Open command palette (`Ctrl+Shift+P`) and run `zed: extensions`

**Installation directories on Linux**:
- `$XDG_DATA_HOME/zed/extensions` (preferred)
- `~/.local/share/zed/extensions` (fallback)

**Auto-install setting** (configure in settings.json):
```json
{
  "auto_install_extensions": {
    "markdown-oxide": true,
    "markdownlint": true,
    "context7-mcp": true,
    "codebook": true,
    "csv": true
  }
}
```

---

## Recommended Extensions List

### Priority 1: Install for This Setup (Claude Code + Markdown + Office)

| Extension | Category | Downloads | Why Install |
|-----------|----------|-----------|-------------|
| Context7 MCP Server | MCP Server | 122k | Injects live library docs into Claude Code context; directly enhances AI agent quality |
| GitHub MCP Server | MCP Server | 79k | Gives Claude Code direct GitHub API access for PR/issue management |
| Markdown Oxide | Language Server | 86k | PKM-style markdown with backlinks and wiki-links; fills the markdown preview gap with navigation |
| Markdownlint | Language Server | 37k | Enforces markdown style consistency across docs/reports |
| MarkItDown MCP Server | MCP Server | 21k | Converts Office files (DOCX, XLSX, PDF) to Markdown via MCP; bridges the Office gap |
| Codebook Spell Checker | Language Server | 98k | Code-aware spell checking for markdown documentation |
| CSV | Language | 117k | CSV support for data files |

### Priority 2: Consider Based on Workflow

| Extension | Category | Downloads | Why Consider |
|-----------|----------|-----------|-------------|
| Rumdl Markdown Linter | Language Server | 17k | Alternative to Markdownlint; Rust-based, faster |
| Sequential Thinking MCP | MCP Server | 62k | Better Claude Code reasoning on complex tasks |
| Brave Search MCP Server | MCP Server | 48k | Web search capability for Claude Code agent |
| Rainbow CSV | Language | 101k | Better CSV readability |
| Typos Spell Checker | Language Server | 44k | Complement to Codebook for typo detection |
| GitHub Activity Summarizer | Tool | 33k | AI-powered GitHub activity summaries |
| Claude Code Inspired Dark | Theme | 27k | Aesthetic match for Claude Code users |

### Not Available (No Extensions Exist)

| Desired Capability | Status |
|-------------------|--------|
| DOCX preview/editing | No extension -- use MarkItDown MCP for conversion |
| XLSX preview | No extension -- use MarkItDown MCP for conversion |
| PDF preview | No extension -- no workaround via extensions |
| Markdown preview pane | No extension -- Markdown Oxide partially fills gap |
| Prettier formatting | No extension -- built-in formatter handles markdown |

---

## Evidence and Examples

### ACP Architecture (from official docs)
> "Zed runs the Claude Agent SDK, which runs Claude Code under the hood, and communicates to it over ACP."

This means Claude Code CLI is not installed as an extension but as an automatically managed background process that Zed communicates with via ACP.

### Claude Code is Pre-installed as External Agent
From the agent panel documentation:
> External agents like Claude Agent appear "out of the box" in the agent panel -- you can "choose another agent by clicking the plus button in the top-right of the Agent Panel and pick one of the external agents installed out of the box."

### Context7 Benefit for Claude Code
Context7 specifically lists "Claude Code" as a supported AI coding tool:
> "Pull up-to-date, version-specific documentation and code examples for any library directly into Cursor, Claude Code, Windsurf, and other AI coding tools."

This makes Context7 one of the highest-value extensions for this setup.

### MarkItDown as Office Bridge
The MarkItDown MCP Server (21k downloads) is the only available mechanism to bridge Office document formats (DOCX, XLSX) into Zed workflows -- it converts them to Markdown via Microsoft's MarkItDown tool, enabling AI agents to process the content.

---

## Confidence Level

**High** for:
- Claude Code ACP integration (sourced directly from official Zed external-agents documentation)
- Extension existence/non-existence (confirmed via direct marketplace searches)
- Installation instructions (sourced from official installing-extensions documentation)

**Medium** for:
- Context7 + Claude Code integration quality (confirmed compatibility, but depth of integration untested)
- Markdown Oxide as preview substitute (based on description; actual Zed behavior with PKM features unknown)

**Low** for:
- Download counts as quality proxy (could reflect marketing over utility)
- MarkItDown MCP Server reliability (relatively new, 21k downloads, limited reviews)
