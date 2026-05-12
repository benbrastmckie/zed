# Research Report: Task #83

**Task**: Revise documentation to reflect new extensions
**Date**: 2026-05-12
**Mode**: Team Research (4 teammates)

## Summary

All four teammates converge on the same core finding: the documentation is structurally sound but factually wrong in several critical ways. The three highest-priority issues are (1) OpenCode has been deleted but is still presented as a co-equal system across all docs, (2) the `web` extension is completely absent from all documentation, and (3) the extension count is wrong everywhere (9 claimed, 10 actual). Secondary issues include the undocumented `/sheet` command, misattributed `/project-overview` command, 30+ broken links, and wrong paths for Python/R docs.

## Key Findings

### 1. OpenCode Removed but Pervasively Referenced (All 4 teammates)

The entire `.opencode/` directory (423 files) has been deleted. Documentation still describes "two AI agent systems -- Claude Code and OpenCode" throughout:
- `README.md` - describes OpenCode as "a parallel AI assistant"
- `docs/agent-system/opencode.md` - entire file about configuring/using OpenCode
- `docs/agent-system/README.md` - presents OpenCode as "the second AI agent system"
- `docs/agent-system/architecture.md` - dual-system architecture diagrams
- `docs/agent-system/commands.md` - "OC only" labels, broken OC links
- `docs/agent-system/extensions.md` - "CC/OC" version split columns
- `docs/agent-system/context-and-memory.md` - shared state descriptions
- Directory layout in README shows `.opencode/`

**Resolution needed**: Either remove all OpenCode references or replace with a brief note (e.g., "OpenCode support is planned/available separately").

### 2. Web Extension Completely Undocumented (All 4 teammates)

The `web` extension (v1.0.0) provides Astro, Tailwind CSS v4, TypeScript, and Cloudflare Pages support with:
- 2 agents: `web-research-agent`, `web-implementation-agent`
- 2 skills: `skill-web-research`, `skill-web-implementation`
- 1 rule: `web-astro.md`
- Rich context: Astro framework, Tailwind v4, web style guide, performance standards

Not mentioned in any docs file. Missing from the extension feature matrix, README, commands catalog, and toolchain docs.

### 3. Extension Count Wrong Everywhere (All 4 teammates)

All docs say "9 extensions" — the actual count is **10** (core, epidemiology, filetypes, latex, memory, present, python, slidev, typst, **web**). Wrong in at least 8 locations:
- `README.md` (lines 3, 239)
- `docs/README.md` (line 3)
- `docs/agent-system/README.md` (lines 3, 13, 48)
- `docs/agent-system/extensions.md` (line 3)
- `docs/agent-system/opencode.md` (lines 3, 99)

### 4. `/sheet` Command Undocumented (Teammates A, B, C)

The `/sheet` command (XLSX creation, editing, analysis via skill-sheet/sheet-agent) exists in `.claude/commands/sheet.md` but:
- Not in `docs/agent-system/commands.md`
- Not in `docs/workflows/edit-spreadsheets.md`
- Not in README.md Document Tools table
- `edit-spreadsheets.md` only covers raw MCP usage, not the structured `/sheet` command

### 5. `/project-overview` Misattributed as OC-Only (Teammates A, C)

`commands.md` lists `/project-overview` as "(OC only)" with a broken link to `.opencode/commands/project-overview.md`. Claude Code has its own `/project-overview` command and `skill-project-overview` skill in the core extension manifest.

### 6. 30+ Broken Links (Teammates A, C, D)

**Broken .opencode/ links** (all deleted):
- `.opencode/AGENTS.md` (referenced in README.md, docs/agent-system/README.md)
- `.opencode/docs/README.md` (referenced in README.md, docs/README.md, architecture.md)
- `.opencode/docs/guides/user-guide.md` (referenced in commands.md)
- `.opencode/commands/deck.md` (referenced in commands.md)
- `.opencode/commands/project-overview.md` (referenced in commands.md)

**Wrong paths for Python/R docs** (Teammate C):
- `docs/README.md` links to `general/python.md` and `general/R.md` -- should be `toolchain/python.md` and `toolchain/r.md`
- `docs/workflows/README.md` links to `../general/python.md` and `../general/R.md` -- broken
- `docs/agent-system/README.md` links to `../general/R.md` -- broken

### 7. Factual Claim Errors (Teammate C)

- `docs/agent-system/README.md` line 73 claims "No `.claude/extensions/` directory" -- false, the directory exists with 10 subdirectories
- Platform claim "macOS 11+" in README.md is misleading -- user is on NixOS Linux; the config works on Linux, only the install script is macOS-specific

## Synthesis

### Conflicts Resolved

No conflicts -- all four teammates identified the same core issues. Teammate D raised the strategic question of whether OpenCode should be fully removed or referenced as "planned/external." The consensus recommendation is to remove OpenCode references since the files are deleted, and the docs should reflect current reality.

### Gaps Identified

- The `python` extension provides agent routing (research/implementation) but no user-facing documentation beyond the toolchain setup guide
- The relationship between `/sheet`, `/edit`, and `/table` (three spreadsheet-adjacent commands) is never explained
- No web development workflow doc exists despite the extension having full research/implement routing
- `docs/toolchain/extensions.md` is missing sections for `python` and `web` prerequisites

### Recommendations

**Priority 1 -- Remove/replace OpenCode references** (biggest change):
- Delete or archive `docs/agent-system/opencode.md`
- Rewrite all dual-system language to single-system (Claude Code + Zed Agent Panel)
- Remove all `.opencode/` path references and broken links
- Remove "CC only" / "OC only" labels
- Simplify extension version table (no CC/OC split)
- Update README.md to remove OpenCode as a parallel system
- Remove `OC_` task prefix documentation

**Priority 2 -- Add web extension** (medium change):
- Add `web` row to extensions.md feature matrix
- Add web development mention to README.md
- Add `web` section to `docs/toolchain/extensions.md`
- Consider a `docs/workflows/web-development.md` if warranted

**Priority 3 -- Fix missing/incorrect commands** (small changes):
- Add `/sheet` to commands.md under Documents section
- Add `/sheet` to README.md Document Tools table
- Update `edit-spreadsheets.md` to feature `/sheet` as primary interface
- Move `/project-overview` from OC-only to main commands
- Remove `/deck` (OC-only, no longer available)

**Priority 4 -- Fix counts and broken links** (find-and-replace):
- Change "9 extensions" to "10 extensions" everywhere
- Fix Python/R doc paths (general/ -> toolchain/)
- Remove all .opencode/ links
- Fix "No `.claude/extensions/` directory" claim

**Priority 5 -- Balance and polish** (optional improvements):
- Mention `python` and `web` as "invisible" extensions with agent routing
- Remove README redundancy (AI Integration section overlaps Agent Commands)
- Remove "Common Scenarios" duplication with workflows decision guide
- Consider brief value proposition before Quick Start

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Accuracy audit (extension-by-extension) | completed | high |
| B | Structure, balance, and presentation | completed | high |
| C | Gaps, blind spots, and confusion points | completed | high |
| D | Strategic direction and long-term vision | completed | high |

## References

- Extension manifests: `.claude/extensions/*/manifest.json`
- Current docs: `docs/` (general/, agent-system/, toolchain/, workflows/)
- README: `README.md` (root)
- Git status: `.opencode/` files all deleted (D status)
