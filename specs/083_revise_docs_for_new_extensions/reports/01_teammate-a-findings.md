# Teammate A Findings: Documentation Accuracy Audit

**Task**: 83 - Revise documentation to reflect new extensions
**Date**: 2026-05-12
**Angle**: Primary - Factual accuracy of docs vs actual extensions
**Confidence**: High

## Key Findings

1. **OpenCode has been removed but is still pervasively referenced.** The entire `.opencode/` directory (423 files) is deleted from the working tree but not yet committed. All documentation still treats OpenCode as a co-equal system. This is the single largest documentation accuracy issue — it affects README.md, docs/agent-system/README.md, docs/agent-system/opencode.md (entire file), docs/agent-system/extensions.md, docs/agent-system/commands.md, docs/agent-system/architecture.md, docs/agent-system/context-and-memory.md, and docs/README.md.

2. **Extension count is wrong everywhere.** All docs say "9 extensions" but there are actually **10** extensions: core, epidemiology, filetypes, latex, memory, present, python, slidev, typst, **web**. The `web` extension (Astro, Tailwind CSS v4, TypeScript, Cloudflare Pages) is completely absent from all documentation.

3. **`/sheet` command is undocumented.** The `/sheet` command exists in `.claude/commands/sheet.md` and is provided by the filetypes extension (skill-sheet, sheet-agent), but it has no entry in `docs/agent-system/commands.md`. It is only mentioned in the opencode comparison table.

4. **`/project-overview` is mislabeled as OpenCode-only.** The command, skill (`skill-project-overview`), and rule (`project-overview-detection.md`) all exist in the Claude Code core extension manifest. Yet `docs/agent-system/commands.md` lists it as "(OC only)" and links to `.opencode/commands/project-overview.md` (a broken link since .opencode is deleted).

5. **Broken link**: `docs/agent-system/README.md` references `../general/R.md` which does not exist. The correct path is `../toolchain/r.md`.

6. **Dozens of broken links to `.opencode/`** across docs — all now point to deleted files.

## Extension-by-Extension Audit

### core (v1.0.0 in manifest, documented as v2.0.0 CC / v1.0.0 OC)
- **Manifest says**: v1.0.0. Provides 7 agents, 15 commands, 7 rules, 17 skills, 24+ scripts, 11 hooks, extensive context/docs.
- **Docs say**: v2.0.0 (CC). The "(CC) / (OC)" version split is now obsolete since OpenCode is removed.
- **Discrepancy**: Version number. The "CC/OC" versioning column should be simplified to a single version.
- **Missing from docs**: `/project-overview` is a core command but documented as OC-only.

### epidemiology (v2.0.0)
- **Manifest says**: v2.0.0. Provides 2 agents, 2 skills, 1 command (`/epi`), context, OpenCode JSON merge.
- **Docs say**: v2.0.0 (CC) / v1.0.0 (OC). Accurately described. Task types `epi`, `epi:study`, `epidemiology` match.
- **Discrepancy**: The "(CC)/(OC)" split is obsolete. Otherwise accurate.

### filetypes (v2.2.0)
- **Manifest says**: v2.2.0. Provides 7 agents, 6 skills, 5 commands (`/convert`, `/table`, `/scrape`, `/edit`, `/sheet`). MCP: superdoc, openpyxl.
- **Docs say**: Correctly lists the extension. Commands listed in commands.md include `/convert`, `/table`, `/scrape`, `/edit` but NOT `/sheet`.
- **Discrepancy**: `/sheet` command missing from commands.md. The edit-spreadsheets workflow doc exists but isn't linked from commands.md.

### latex (v1.0.0)
- **Manifest says**: v1.0.0. Provides 2 agents, 2 skills, 0 commands, 1 rule. Task type: `latex`.
- **Docs say**: Accurately described. No commands means nothing to check in commands.md.
- **Discrepancy**: None.

### memory (v1.0.0)
- **Manifest says**: v1.0.0. Provides 1 skill, 2 commands (`/learn`, `/distill`), context. MCP: obsidian-memory.
- **Docs say**: Accurately described. `/distill` marked as CC-only, which is correct (it was CC-only when OpenCode existed, now the distinction is moot).
- **Discrepancy**: The "CC only" label on `/distill` is no longer meaningful.

### present (v1.0.0)
- **Manifest says**: v1.0.0. Provides 9 agents, 7 skills, 5 commands (`/grant`, `/budget`, `/timeline`, `/funds`, `/slides`). Dependencies: core, slidev. MCP: superdoc. Routing includes critique for slides.
- **Docs say**: Accurately described. Commands match. The dependency on `slidev` is noted.
- **Discrepancy**: None significant.

### python (v1.0.0)
- **Manifest says**: v1.0.0. Provides 2 agents, 2 skills, 0 commands. Task type: `python`.
- **Docs say**: Listed in extensions.md correctly. No commands to document.
- **Discrepancy**: None. But neither extensions.md nor README.md mentions Python as a development extension (it's only listed as a language in the Languages table, not as an agent extension with research/implement capabilities).

### slidev (v1.0.0)
- **Manifest says**: v1.0.0. Routing-exempt (utility). Provides context only (animation patterns, CSS presets). Dependency of `present`. No agents, skills, or commands.
- **Docs say**: Listed in extensions.md correctly as a utility with no routing.
- **Discrepancy**: None.

### typst (v1.0.0)
- **Manifest says**: v1.0.0. Provides 2 agents, 2 skills, 0 commands. Task type: `typst`.
- **Docs say**: Accurately described.
- **Discrepancy**: None.

### web (v1.0.0) — COMPLETELY MISSING FROM ALL DOCS
- **Manifest says**: v1.0.0. Provides 2 agents (`web-implementation-agent`, `web-research-agent`), 2 skills (`skill-web-implementation`, `skill-web-research`), 0 commands, 1 rule (`web-astro.md`). Context: Astro, Tailwind v4, TypeScript, Cloudflare Pages. Task type: `web`.
- **Docs say**: Nothing. Not in extensions.md feature matrix, not in README.md, not mentioned anywhere in docs/ as an extension.
- **Discrepancy**: Entire extension undocumented. This is a significant gap since it provides full research and implementation routing for web development tasks.

## Recommended Approach

### Priority 1: Remove OpenCode references
- Remove or archive `docs/agent-system/opencode.md` entirely
- Rewrite all docs to describe a single agent system (Claude Code + Zed Agent Panel)
- Remove all `.opencode/` path references and broken links
- Remove "CC only" / "OC only" labels (everything is now CC)
- Simplify extension version table (no CC/OC split)
- Remove the OC_ prefix documentation for task directories
- Update README.md to remove OpenCode as a parallel system

### Priority 2: Add web extension
- Add `web` row to extensions.md feature matrix
- Add web development mention in README.md (with Astro/Tailwind/TypeScript/Cloudflare)
- Consider adding web workflow doc if warranted

### Priority 3: Fix missing/incorrect commands
- Add `/sheet` entry to commands.md under the Documents section
- Move `/project-overview` from "OC only" to the main commands section
- Remove `/deck` (OC-only, no longer available)

### Priority 4: Fix counts and broken links
- Change "9 extensions" to "10 extensions" everywhere
- Fix `../general/R.md` link to `../toolchain/r.md`
- Remove all links pointing to `.opencode/` paths

### Priority 5: Balance extension representation
- Python and web are "invisible" extensions — they provide task-type routing with research/implementation agents but have no dedicated commands. Consider briefly mentioning them in the extensions summary section of README.md alongside LaTeX/Typst.
