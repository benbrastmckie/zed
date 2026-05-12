# Teammate D Findings: Strategic Documentation Assessment

**Task**: 83 — Revise documentation to reflect new extensions
**Date**: 2026-05-12
**Angle**: Horizons — long-term documentation strategy and alignment

## Key Findings

1. **Extension count is wrong everywhere**: The docs say "9 extensions" in 8+ locations across README.md, docs/README.md, docs/agent-system/README.md, docs/agent-system/extensions.md, and docs/agent-system/opencode.md. There are actually **10 extensions** (core, epidemiology, filetypes, latex, memory, present, python, slidev, typst, **web**). The `web` extension is entirely absent from the extension feature matrix in `docs/agent-system/extensions.md`.

2. **OpenCode directory deleted but extensively referenced**: The `.opencode/` directory has been fully deleted (visible in git status as `D .opencode/*` across dozens of files), but the documentation still treats OpenCode as a co-equal system. The README.md describes "two AI agent systems -- Claude Code and OpenCode", the directory layout shows `.opencode/`, the Documentation table links to `.opencode/docs/README.md`, and the AI Integration section describes OpenCode in detail. This creates a fundamentally misleading picture of the project.

3. **`/sheet` command undocumented in command catalog**: The `docs/agent-system/commands.md` file has no entry for `/sheet` (XLSX creation/editing/analysis), though it's referenced in `docs/agent-system/opencode.md` and exists as a skill in `.claude/skills/skill-sheet/`.

4. **`web` extension completely undocumented**: The web extension (Astro, Tailwind CSS v4, TypeScript, Cloudflare Pages) is loaded as an extension, has agents, skills, rules, and context files, but receives zero mention in user-facing docs. It's missing from the extension feature matrix, the README, and the command catalog (though it uses the generic `/research`, `/plan`, `/implement` lifecycle rather than custom commands).

5. **Broken links to OpenCode**: At least 15 links across the documentation point to `.opencode/` paths that no longer exist, including `.opencode/AGENTS.md`, `.opencode/docs/README.md`, `.opencode/commands/`, etc.

6. **ROADMAP.md is empty**: Contains only placeholder text ("No items yet"). Not blocking but represents a missed opportunity for strategic alignment signaling.

## Strategic Assessment

### Audience Analysis

The documentation serves three audiences, but doesn't always distinguish them well:

| Audience | Needs | Current Coverage |
|----------|-------|-----------------|
| **New users** | Quick start, installation, "what does this do?" | Good (README Quick Start is solid) |
| **Power users** | Command reference, workflow guides, extension capabilities | Good but incomplete (missing web, sheet) |
| **Contributors/developers** | Architecture, extension development, system internals | Separately covered in `.claude/docs/` (appropriate) |

### Positioning Problem

The biggest strategic issue is **identity crisis caused by OpenCode deletion**. The project description says "two AI agent systems" but now only has one. This needs a clean resolution:
- Option A: Remove all OpenCode references (if OpenCode is permanently gone)
- Option B: Treat OpenCode as "available but not included" (if it can be installed separately)
- Option C: Maintain the dual-system description with a note that OpenCode is optional/external

The README opening line is the project's elevator pitch — it must be accurate.

### Information Hierarchy

The README has good structure but some redundancy:
- "Agent Commands" section and "AI Integration" section overlap significantly
- "Custom Keybindings" appears twice (once in Essential Shortcuts, once in its own section)
- "Common Scenarios" table duplicates what's in Workflows README decision guide

### First-Impression Quality

The README is well-written and scannable. The Quick Start is immediately actionable. The walkthrough example is excellent. The main weakness is accuracy (wrong extension count, phantom OpenCode references, missing extensions).

## Long-term Documentation Vision

### What "done right" looks like:

1. **README.md** (250-300 lines): Accurate elevator pitch, quick start, one walkthrough, command overview table, link to docs. No redundancy with docs/.
2. **docs/general/**: Installation + editor setup. Stays as-is (well-structured).
3. **docs/agent-system/**: Commands, extensions, architecture, memory. Needs extension count fix, web extension addition, OpenCode resolution.
4. **docs/toolchain/**: Language setup. Well-structured, good check/install/verify pattern.
5. **docs/workflows/**: Narrative guides. Good coverage, may need web development workflow if web extension should be showcased.

### Documentation Principles

- **Single source of truth**: Extension counts should be generated from manifest.json, not hardcoded
- **No phantom references**: Every link must resolve to an existing file
- **Balanced representation**: All loaded extensions deserve at least a mention in the feature matrix
- **Concise README**: The README should be a gateway, not a reference manual — link to docs/ for details

## Creative/Unconventional Suggestions

1. **Extension auto-inventory**: Consider a script that generates the extension feature matrix from manifest.json files, preventing count drift. Even a simple `ls .claude/extensions | wc -l` in the install wizard would catch mismatches.

2. **Web development workflow doc**: If the web extension is intended for users (not just internal use), add a `docs/workflows/web-development.md` similar to the epidemiology and grant workflows.

3. **"Why this config?" section**: The README jumps straight to Quick Start without explaining why someone would want this setup. A 2-3 sentence value proposition before Quick Start could improve GitHub discoverability and conversion.

4. **Remove README redundancy**: The "AI Integration", "Custom Keybindings", and "Common Scenarios" sections duplicate content already covered earlier or in docs/. The README would be tighter and more compelling at ~200 lines if these were consolidated or linked rather than repeated.

5. **OpenCode as "coming soon" or "external"**: Rather than deleting all OpenCode references, consider a brief note: "OpenCode support is planned/available separately" — this signals ambition without misleading about current state.

## Confidence Level

**High** — The findings are based on direct file system inspection. The extension count discrepancy (9 vs 10) and OpenCode deletion are factual. The strategic recommendations are subjective but grounded in standard documentation practices.
