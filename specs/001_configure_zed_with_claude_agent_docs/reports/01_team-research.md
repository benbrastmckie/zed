# Research Report: Task #1

**Task**: Configure Zed with Claude agent system documentation
**Date**: 2026-04-09
**Mode**: Team Research (4 teammates)

## Summary

Zed needs `settings.json`, `keymap.json`, documentation (`README.md` + `docs/`), and a corrected `project-overview.md`. The .claude/ agent system already works via ACP — no modifications needed. The office guide requires a Linux-native rewrite (not just Cmd→Ctrl), and documentation must serve two audiences: an expert primary user and a beginner collaborator. Keep docs minimal (README + 3-4 files), following established patterns from the nvim config.

## Key Findings

### 1. Configuration Files (Blocking Prerequisites)

Both `settings.json` and `keymap.json` are missing and must be created before anything else works.

**settings.json** must include:
- Vim mode with detailed `vim` block (smartcase, system clipboard, relative line numbers)
- `languages` block: Markdown format-on-save OFF, soft wrap ON (critical for .claude/ docs)
- `agent` block for Claude Code ACP model selection
- `assistant` block for Zed's built-in AI (separate from Claude Code)
- `context_servers` block for MCP servers (SuperDoc, openpyxl) — NOT `claude mcp add` which only works for CLI

**keymap.json** must use Ctrl (not Cmd) throughout. Key bindings: agent panel toggle, vim leader-space shortcuts, jk escape in insert mode.

**Project-level `.zed/settings.json`**: Useful for markdown-specific overrides but cannot set vim_mode or theme (user-level only).

### 2. Claude Code Integration Architecture

Claude Code in Zed uses **Agent Client Protocol (ACP)**, not a traditional extension:
- Auto-installs on first use — no manual extension install needed
- Authentication via `/login` in the agent panel
- Opens with `Ctrl+?` on Linux (medium confidence — may be `Ctrl+Shift+?`)
- The `assistant` settings block controls Zed's **built-in** AI, not Claude Code
- The `agent` settings block controls Claude Code ACP

**Critical distinction for docs**: Zed's built-in AI assistant and the Claude Code agent panel are different systems. Only Claude Code runs the .claude/ command system (`/research`, `/plan`, `/implement`).

### 3. MCP Server Configuration

MCP servers for Zed go in `settings.json` under `context_servers`, not via `claude mcp add`:

```json
{
  "context_servers": {
    "superdoc": {
      "source": "custom",
      "command": "npx",
      "args": ["@superdoc-dev/mcp"]
    }
  }
}
```

The `"source": "custom"` field is mandatory. The `claude mcp add --scope user` pattern from the office guide only configures the terminal CLI, not Zed.

### 4. Platform Mismatch Is Fundamental (Not Cosmetic)

The `zed-claude-office-guide.md` is macOS-only. On this NixOS system:
- **No Microsoft Word** — LibreOffice 25.8.5.2 is installed instead
- **No AppleScript** — the automatic save-edit-reload-in-Word workflow doesn't exist
- **Binary is `zeditor`** not `zed` (NixOS naming to avoid conflict)
- All Cmd shortcuts → Ctrl
- No Homebrew, no Spotlight, no OneDrive menu bar

SuperDoc on Linux edits DOCX via python-docx (headless). openpyxl works identically. But the live-reload-in-Word workflow must be replaced with a manual "open in LibreOffice after editing" step.

### 5. Two Audiences Require Separate Documentation Paths

| Audience | Profile | Needs |
|----------|---------|-------|
| **A: Primary user** | NixOS expert, Neovim power user | Zed-specific differences, keybinding reference, agent system cross-reference |
| **B: Collaborator** | Comfortable with computers, new to Zed/vim/agents | 5-minute quick start, plain-English Office workflows, vim_mode escape hatch |

"Beginner" does not mean "computer novice" — NixOS users aren't beginners. It means "new to this Zed setup."

### 6. Documentation Scale: Minimal, Not Nvim-Scale

The nvim config has 20+ docs files because it manages hundreds of Lua modules. Zed has 2 JSON config files. The right scale is:

```
README.md              # Navigation hub, quick start (150-200 lines)
docs/
  settings.md          # settings.json + keymap.json reference
  agent-system.md      # Thin bridge to .claude/README.md and .memory/README.md
  office-workflows.md  # Linux-native Office file workflows (replaces macOS guide)
```

**Do not duplicate** content from `.claude/README.md` or `.memory/README.md`. The `docs/agent-system.md` should be a bridge document that explains the relationship and links out.

### 7. project-overview.md Is Wrong

`.claude/context/repo/project-overview.md` describes "Neovim Configuration Project" with Lua/lazy.nvim. This was copied verbatim and never updated. Agents reading this get incorrect context about the repository.

Must be replaced with Zed-appropriate content: JSON-based config, Office file workflows, .claude/ agent system, no Lua files.

### 8. vim_mode Is a Usability Decision

`vim_mode: true` is correct for the primary user (Neovim expert) but a collaborator who encounters vim Normal mode without explanation will think Zed is broken. The docs must:
- Explain that vim_mode is enabled and what it means
- Provide escape hatch: how to type (press `i`), how to exit insert mode (press `Esc`)
- Note how to disable it (`"vim_mode": false` in settings.json)

### 9. One Dark Theme and Font Status

- **RobotoMono Nerd Font**: Confirmed available under correct name via `fc-list`
- **One Dark**: Likely a Zed built-in theme (bundled since 2023), but themes/ directory is empty. If missing, Zed falls back silently — low risk but should be verified during implementation.

### 10. .claude/ Agent System Works As-Is

The agent system at `.config/zed/.claude/` is already fully functional via ACP. All skills, agents, commands, and extensions are present. The CLAUDE.md hierarchy is correct. No modifications needed to the agent system itself.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution | Reasoning |
|----------|------------|-----------|
| Docs structure: 5 files (A) vs 3 files (B) | **4 files**: README.md + settings.md + agent-system.md + office-workflows.md | Teammate B's minimal approach is right for Zed's simplicity, but Office workflows need a dedicated file (Teammate C's platform rewrite) |
| Agent panel shortcut: `Ctrl+?` (A) vs `Ctrl+Shift+?` (C) | **Document both, verify during implementation** | Both appear in Zed docs; exact binding depends on version and keymap config |
| MCP config: CLI `claude mcp add` (guide) vs `context_servers` (A) | **Both are valid for different contexts** | `context_servers` for Zed's built-in integration; `claude mcp add` for terminal Claude Code CLI. Document both. |
| Audience: beginner (task) vs expert (reality) | **"New to this setup"** — not a computer beginner | Teammate C's analysis is correct: NixOS users aren't beginners. Target "new to Zed and this agent system." |

### Gaps Identified

1. **No verification of exact agent panel shortcut** — needs hands-on testing during implementation
2. **One Dark theme availability** — should be confirmed when creating settings.json
3. **Whether Claude Code extension needs manual install** vs auto-discovery via ACP — unclear from docs alone
4. **LibreOffice integration testing** — SuperDoc's Linux behavior with LibreOffice needs verification
5. **Extension recommendations** — only `html` is installed; Nix extension would be valuable

### Recommendations

**Implementation order**:
1. Create `settings.json` (with MCP, vim, agent, language blocks)
2. Create `keymap.json` (Linux Ctrl-based)
3. Create `.zed/settings.json` (project-level markdown overrides)
4. Update `project-overview.md` (fix Neovim → Zed)
5. Create `README.md` (navigation hub with quick start)
6. Create `docs/settings.md` (configuration reference)
7. Create `docs/agent-system.md` (thin bridge to .claude/ and .memory/)
8. Create `docs/office-workflows.md` (Linux-native, replaces macOS guide)

**Documentation principles**:
- Present tense, active voice (per nvim DOCUMENTATION_STANDARDS.md)
- NixOS-first: `zeditor` not `zed`, Ctrl not Cmd, Linux paths
- Progressive depth: quick start → topic pages → linked deep docs
- No duplication of .claude/README.md or .memory/README.md content
- Cross-link generously: every doc links back to README and to related docs

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary implementation approach | completed | high |
| B | Alternative patterns and prior art | completed | high |
| C | Critic — gaps and blind spots | completed | high |
| D | Horizons — strategic direction | completed | high |

## References

- Zed docs: https://zed.dev/docs
- Zed vim mode: https://zed.dev/docs/vim
- Zed AI/agents: https://zed.dev/docs/ai/external-agents
- Zed configuration: https://zed.dev/docs/configuring-zed
- Zed key bindings: https://zed.dev/docs/key-bindings
- Zed Linux: https://zed.dev/docs/linux
- config-report.md (system state assessment)
- zed-claude-office-guide.md (macOS office workflows — source material for Linux adaptation)
- nvim/docs/DOCUMENTATION_STANDARDS.md (writing style reference)
