# Teammate C Findings: Critic — Documentation Gaps and Blind Spots

**Task**: 83 — Revise documentation to reflect new extensions
**Teammate**: C (Critic)
**Date**: 2026-05-11

## Key Findings

The documentation has a consistent, well-organized structure that would serve users well — if it were accurate. However, 423 files have been deleted from `.opencode/`, one extension (`web`) is completely undocumented, the extension count is wrong everywhere, and there are 30+ broken links across the docs. The docs present OpenCode as a fully functioning parallel system when its entire configuration tree has been removed.

## Critical Gaps

### 1. The `web` extension is completely missing from documentation

The `web` extension (Astro, Tailwind CSS v4, TypeScript, Cloudflare Pages) exists at `.claude/extensions/web/` with its own manifest, agents (`web-implementation-agent.md`, `web-research-agent.md`), skills, rules, and context. It provides `web` task type routing. **It does not appear in**:
- `docs/agent-system/extensions.md` feature matrix (lists only 9 extensions)
- `docs/agent-system/commands.md` (no web-related commands mentioned)
- `docs/agent-system/README.md` extensions summary
- `docs/README.md` hub description
- `README.md` (no mention of web development capabilities)

### 2. Extension count is wrong everywhere (says 9, should be 10)

All of these files say "9 extensions" when there are actually 10 (core, epidemiology, filetypes, latex, memory, present, python, slidev, typst, **web**):
- `README.md` (line 3, line 239)
- `docs/README.md` (line 3)
- `docs/agent-system/README.md` (lines 3, 13, 48)
- `docs/agent-system/extensions.md` (line 3)
- `docs/agent-system/opencode.md` (lines 3, 99)

### 3. OpenCode documentation is entirely stale — .opencode/ has been deleted

423 files have been deleted from `.opencode/`. The entire directory is empty. Yet the docs extensively reference it as a functioning parallel system:
- `docs/agent-system/opencode.md` — entire file is about configuring and using OpenCode
- `docs/agent-system/README.md` — presents OpenCode as "the second AI agent system"
- `docs/agent-system/architecture.md` — shows dual-system architecture diagrams with `.opencode/`
- `docs/agent-system/commands.md` — lists `/deck` and `/project-overview` as "OC only"
- `README.md` — describes OpenCode as "a parallel AI assistant" with its own capabilities

### 4. `/sheet` command is missing from commands.md

Claude Code has a `/sheet` command (`sheet.md` exists in `.claude/commands/`) and a `skill-sheet` skill, but `commands.md` does not document it at all. It's missing from every command table in the docs.

### 5. `/project-overview` is misattributed as OpenCode-only

`commands.md` (line 356-360) lists `/project-overview` as "OC only" with a broken link to `.opencode/commands/project-overview.md`. But Claude Code now has its own `/project-overview` command and `skill-project-overview` skill.

### 6. 30+ broken links to .opencode/ files

Every link to `.opencode/` is broken since the directory was deleted:
- `.opencode/AGENTS.md` — referenced in README.md, docs/agent-system/README.md, docs/agent-system/opencode.md
- `.opencode/docs/README.md` — referenced in README.md, docs/README.md, docs/agent-system/architecture.md, docs/agent-system/opencode.md
- `.opencode/docs/guides/user-guide.md` — referenced in docs/agent-system/commands.md
- `.opencode/commands/deck.md` — referenced in docs/agent-system/commands.md
- `.opencode/commands/project-overview.md` — referenced in docs/agent-system/commands.md
- `.opencode/commands/` — referenced in docs/agent-system/commands.md

### 7. Broken links to Python and R docs (wrong directory)

Multiple files reference `general/python.md` and `general/R.md`, but these files are actually in `toolchain/`:
- `docs/README.md` (line 7) links to `general/python.md` and `general/R.md` — broken
- `docs/workflows/README.md` (lines 12-13) links to `../general/python.md` and `../general/R.md` — broken  
- `docs/agent-system/README.md` (line 61) links to `../general/R.md` — broken
- Correct paths: `toolchain/python.md` and `toolchain/r.md`

## Potential Confusion Points

### 1. Platform claim is misleading
README.md states "**Platform**: macOS 11+" but the user is running NixOS Linux. The install script appears macOS-only (Homebrew-based), but the configuration itself works on Linux too. A new user on Linux would assume this project isn't for them.

### 2. "Both systems" language throughout
Many docs describe "both Claude Code and OpenCode" as parallel equals. Since OpenCode has been removed, this dual-system framing is confusing. Every comparison table, architecture diagram, and "per-system availability" section is now misleading.

### 3. The "OC_" task prefix system is orphaned
Docs explain that OpenCode tasks use `OC_{NNN}_{SLUG}/` prefixes. Since OpenCode is gone, this creates confusion about what those prefixes mean if any such directories still exist in `specs/`.

### 4. Extension versions reference "CC/OC" split
The extensions.md feature matrix shows versions like "2.0.0 (CC) / 1.0.0 (OC)" — this distinction is meaningless if OpenCode has been removed.

### 5. "No `.claude/extensions/` directory" claim is wrong
`docs/agent-system/README.md` (line 73) states: "No `.claude/extensions/` directory — Extensions are tracked via the flat `.claude/extensions.json` file rather than a directory tree." But `.claude/extensions/` absolutely exists with 10 subdirectories. This claim contradicts reality.

## Questions That Should Be Answered But Aren't

1. **What happened to OpenCode?** Was it permanently removed? Temporarily? Should docs still reference it?
2. **What does the `web` extension actually do from a user's perspective?** No user-facing documentation exists for web development support.
3. **How does a user on Linux install this?** The install guide assumes macOS/Homebrew.
4. **What is `/sheet` and when should I use it vs `/edit` vs `/table`?** Three spreadsheet-related commands exist but the relationships aren't documented.
5. **What is `/project-overview` and when should I use it?** Listed as OC-only but available in Claude Code — no usage guide exists.
6. **Which extensions need external tools?** The filetypes extension needs SuperDoc MCP, openpyxl, etc. The web extension presumably needs pnpm/Node.js. Memory needs MCP. These prerequisites are scattered or missing.

## Confidence Level

**High** — All findings verified against actual file system state (file existence checks, git status, grep results). The broken links and missing content are objective facts, not interpretive assessments.
