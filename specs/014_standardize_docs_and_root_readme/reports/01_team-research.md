# Research Report: Task #14

**Task**: Standardize docs/ README files and improve root README for Zed + Claude Code epi/medical research config
**Date**: 2026-04-10
**Mode**: Team Research (4 teammates)

## Summary

All four teammates converged on the same core findings: the repository's documentation systematically misrepresents the platform (macOS instead of NixOS Linux), completely hides the primary use case (epidemiology/medical research), and lacks critical cross-links to `.memory/README.md` and `.claude/README.md`. The docs/ README files have no shared structural template and vary from 9 lines (docs/README.md) to 110 lines (docs/workflows/README.md). Multiple Neovim carry-overs remain in `.claude/` files, and shortcut keys throughout use `Cmd` instead of `Ctrl`.

## Key Findings

### Primary Approach (from Teammate A)

**Complete documentation inventory** (8 README files total):
- `README.md` (root, 94 lines) -- generic Zed setup, macOS-oriented
- `docs/README.md` (9 lines) -- extremely sparse pass-through
- `docs/general/README.md` (27 lines) -- well-structured
- `docs/agent-system/README.md` (67 lines) -- most developed, has "Zed adaptations" section
- `docs/workflows/README.md` (110 lines) -- richest, with decision guide and scenarios
- `.memory/README.md` (101 lines) -- complete but disconnected from docs/ tree
- `.claude/README.md` (260 lines) -- architecture hub, one broken link
- `.claude/docs/README.md` (101 lines) -- has stale Neovim branding

**Verified link issues**:
- 1 broken link: `.claude/README.md` line 202 -> `extensions/README.md` (directory doesn't exist)
- 2 stale labels: `.claude/docs/README.md` says "Neovim Configuration" for Zed repo root link
- 6 missing cross-links identified (root -> .memory, root -> .claude/README, docs/ -> .memory, etc.)

### Alternative Approaches (from Teammate B)

**Repository identity** (the value proposition the README should communicate):
1. **Zed editor settings** optimized for research: R language support, Fira Code font, markdownlint, NixOS-specific agent server config
2. **Claude Code agent system** with full task lifecycle: `/task` -> `/research` -> `/plan` -> `/implement`
3. **Domain extensions** for medical/epi research: `/epi`, `/grant`, `/budget`, `/timeline`, `/funds`, `/slides`, `/convert`, `/learn`
4. **Shared memory vault** (`.memory/`) -- Obsidian-compatible, shared between AI systems

**Proposed root README structure**:
- Identity statement (Zed + Claude Code for epi/medical research)
- Research quick-start (domain commands)
- Editor quick-start (shortcuts)
- What This Config Provides (grouped: editor, agent system, domain extensions)
- Documentation table (including .memory and .claude links)
- Directory layout
- Platform notes

**Proposed docs/ README template**:
```markdown
# {Section Name}
{One paragraph: what, who, where it fits}
## Navigation
- **[file.md](file.md)** -- {one sentence}
## {Quick Start | Decision Guide}
## See also
- [{Path}]({relative-path}) -- {description}
```

Consistency rules: use `--` separator (not em dash), bold filenames, "See also" always last.

### Gaps and Shortcomings (from Critic)

**15 findings organized by severity**:

| Severity | Count | Key Issues |
|----------|-------|------------|
| Critical | 3 | Platform macOS vs NixOS; Cmd vs Ctrl pervasive; root README zero epi content |
| High | 5 | Ctrl+H/J/K/L only H/L bound; broken extensions/README.md link; Neovim labels in .claude/docs/; .claude/README.md references `<leader>ac` and extensions/ dir; anchor mismatch in workflows/README.md |
| Medium | 4 | agent-lifecycle.md listed in wrong section; docs/README.md omits epi/grant workflows; project-overview.md describes Neovim project; .memory/README.md has Neovim examples |
| Low | 3 | Font listed as JetBrains Mono (actual: Fira Code); Neovim integration guide listed in docs hub; Cmd+Shift+? in workflow scenarios |

**Broken links confirmed**:
1. `.claude/README.md` line 248: `extensions/README.md` -- file does not exist
2. `docs/workflows/README.md` line 65: anchor `#slides--presentations-to-source-based-slides` doesn't match actual heading `#slides--research-talk-creation`

**Shortcut three-way inconsistency** for agent panel:
- `zed-agent-panel.md`: **Ctrl+?** (correct, matches keymap.json)
- `agent-system/README.md`: **Cmd+?** (partially fixed in task 13)
- Root README, installation.md, workflow docs: **Cmd+Shift+?** (wrong, stale)

**Notable**: Task 13 summary identified 7 remaining files with stale `Cmd+Shift+?` but left them unfixed.

### Strategic Horizons (from Teammate D)

**Documentation ecosystem observations**:
1. The docs/ structure (general/, agent-system/, workflows/) scales well and should be preserved
2. The real scaling risk is `commands.md` as more commands are added
3. The docs/ vs .claude/ audience distinction (human vs AI) is never stated -- should be explicit
4. Root README targets the wrong primary audience: new Zed setup rather than returning researcher
5. The `.memory/` system is a key differentiator for repeated epi work but is invisible from root

**Creative approaches worth considering**:
- Workflow decision tree at root README (condensed from workflows/README.md)
- Extension status summary table
- Architecture Decision Records (ADRs) for key design choices (lower priority)

## Synthesis

### Conflicts Resolved

1. **Platform question**: Teammate A flagged that macOS docs might be intentional for a collaborator (auto-memory: "Zed shared with collaborator"). However, all teammates agree `settings.json` says "Platform: NixOS Linux" and the actual system is Linux. **Resolution**: Document the actual platform (NixOS Linux). The collaborator sharing note refers to not using vim mode, not to platform documentation. The platform should be accurately documented.

2. **Scope of docs/ README restructuring**: Teammate B proposed a full template rewrite; Teammate D suggested "lightweight template that doesn't require rewriting content." **Resolution**: Use the lightweight approach -- standardize "See also" sections, normalize headings, expand docs/README.md. Don't rewrite docs that are already well-structured (general/, agent-system/).

3. **How much epi content in root README**: Teammate B proposed a full "What This Config Provides" section with grouped capabilities. Teammate D proposed a quick-start research command table. **Resolution**: Do both -- a brief "About" paragraph identifying the repo purpose, then a concise research commands reference, then the existing editor shortcuts.

### Gaps Identified

1. **project-overview.md** (Critic finding 11): `.claude/context/repo/project-overview.md` describes a "Neovim configuration project using Lua and lazy.nvim." This is loaded as agent context every session. This is functionally incorrect and could cause incorrect agent behavior. Should be updated but is outside docs/ scope -- flag as follow-up.

2. **Office workflow docs** (tips-and-troubleshooting.md, edit-word-documents.md, edit-spreadsheets.md): Written entirely for macOS Word/Excel automation. On NixOS Linux with LibreOffice, these workflows don't apply. Updating these is out of scope for this task but should be noted.

3. **Ctrl+J/K pane navigation**: README claims Ctrl+H/J/K/L for pane navigation but only H and L are actually bound (J/K omitted due to Ctrl+K chord conflict). This is a factual error in the root README.

### Recommendations

**Priority 1 -- Root README.md rewrite** (critical):
- Reframe opening as "Zed + Claude Code configuration for epidemiology and medical research on NixOS Linux"
- Add research commands quick-reference (epi, grant, budget, funds, timeline, slides)
- Add links to `.claude/README.md` and `.memory/README.md` in documentation table
- Fix platform statement (NixOS Linux, not macOS)
- Fix font (Fira Code, not JetBrains Mono)
- Fix shortcuts (Ctrl, not Cmd; H/L not H/J/K/L)
- Remove Homebrew install instructions

**Priority 2 -- docs/README.md expansion** (high):
- Expand from 9 lines to ~30-40 lines
- Add brief section descriptions
- State docs/ vs .claude/ relationship (human vs AI audience)
- Add "See also" with .memory/README.md and .claude/README.md links
- Update workflows description to include epi/grant content

**Priority 3 -- docs/ README standardization** (medium):
- Add "See also" sections where missing
- Normalize separator style to `--` throughout
- Fix platform references (macOS -> NixOS Linux) in docs/general/README.md and docs/workflows/README.md
- Fix agent-lifecycle.md listing in agent-system/README.md (note it lives in workflows/)

**Priority 4 -- Fix broken/stale links** (medium):
- `.claude/README.md`: Remove or replace `extensions/README.md` link
- `docs/workflows/README.md`: Fix anchor to `#slides--research-talk-creation`
- `.claude/docs/README.md`: Replace "Neovim Configuration" labels with "Zed Configuration"
- `.claude/README.md`: Update extensions section to note Zed pre-merges extensions (no `<leader>ac`)

**Priority 5 -- Fix Cmd+Shift+? shortcut references** (medium):
- 7+ files still use `Cmd+Shift+?` instead of `Ctrl+?`
- Files: keybindings.md, installation.md (x4), workflows/README.md, maintenance-and-meta.md, tips-and-troubleshooting.md, edit-spreadsheets.md, edit-word-documents.md

**Priority 6 -- Peripheral fixes** (low):
- `.memory/README.md`: Update Neovim-specific naming examples to epi/research examples
- `.claude/README.md`: Remove Neovim integration guide from docs hub listing
- `project-overview.md`: Update to describe Zed repo (flag for separate task if out of scope)

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary (inventory) | completed | high |
| B | Alternatives (structure) | completed | high |
| C | Critic (gaps/errors) | completed | high |
| D | Horizons (strategy) | completed | high/medium |

## References

- Individual teammate reports in `specs/014_standardize_docs_and_root_readme/reports/`
- Task 13 summary (identified 7 unfixed Cmd+Shift+? references)
- `settings.json` line 2: Platform comment
- `keymap.json`: Ground truth for keyboard shortcuts
- Auto-memory: "Zed shared with collaborator; use standard keybindings, not vim"
