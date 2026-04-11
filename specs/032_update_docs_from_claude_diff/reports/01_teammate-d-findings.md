# Teammate D (Horizons): Strategic Documentation Findings

**Task 32**: Update documentation to reflect current .claude/ configuration changes without historical declarations.

**Date**: 2026-04-10

---

## Key Findings

### 1. ROADMAP.md Has No Stale Content

`specs/ROADMAP.md` currently contains only placeholder text (no items yet defined). It does not reference python extension, talk-agent, epidemiology, or any other removed components. No changes are needed to ROADMAP.md.

### 2. Stale References Are Concentrated in Documentation (Not Core System)

The python extension, talk-agent, and old epidemiology task type references do NOT appear in active system files (agents/, skills/, commands/). They are gone cleanly. The contamination is in the **documentation layer only** — guides, architecture docs, and the context layer:

**Files requiring updates**:

| File | Stale Content |
|------|---------------|
| `.claude/README.md` | Extensions table lists `python` as active extension (line 123) |
| `.claude/context/routing.md` | Routing table includes `python` row (line 12) |
| `.claude/docs/README.md` | Header/footer breadcrumbs reference "Neovim Configuration" (wrong project) |
| `.claude/docs/architecture/system-overview.md` | "Adding New Language Support" example uses python (lines 252-255) |
| `.claude/docs/guides/creating-extensions.md` | section-applicability matrix example lists `python` and `epidemiology` as extension names (line 139) |
| `.claude/docs/guides/creating-skills.md` | Trigger conditions example says `"python"` (line 185); skill template uses `skill-python-research` pattern (lines 312-424) |
| `.claude/docs/guides/creating-agents.md` | Example uses `"python"` task language (line 276); context table shows `python` (line 297) |
| `.claude/docs/guides/adding-domains.md` | Decision tree example lists `python` as a non-persistent extension (line 24) |
| `.claude/docs/guides/component-selection.md` | Example uses `skill-python-research` in new component examples (lines 105-170, 314-315) |
| `.claude/context/architecture/component-checklist.md` | Checklist example uses `skill-python-research` (lines 191-192) |

**False positives** (code blocks with `python` as code fence language, not as python-extension references):
- `self-healing-implementation-details.md` — pseudocode in python syntax, not the extension
- `orchestration-core.md`, `delegation.md` — code fence examples, not routing references
- `fix-it-flow-example.md`, `multi-task-creation-standard.md` — code fence examples

### 3. Documentation Architecture Is Sound for Post-Cleanup State

The three-layer structure (docs/README.md as hub, guides/, architecture/, examples/) is well-organized and needs no structural refactoring during this update. The architecture handles the new state well:
- Extension lifecycle (install/load/unload) is already described cleanly
- The `extensions.json` approach to tracking loaded extensions is healthy
- Creating-extensions.md already provides a generic extension template pattern

The only structural issue is that breadcrumb links in docs/README.md point to a "Neovim Configuration" project hierarchy (`../../README.md`), which belongs to the nvim project, not this zed project. This is a navigation mismatch introduced by the project-overview rewrite.

### 4. Extension Lifecycle: Clean Deletion Is Correct, No Deprecation Process Needed

Reviewing the extension system, extensions are:
- Installed files (tracked in `extensions.json`)
- Loaded/unloaded dynamically via `<leader>ac`

When an extension is removed from the source (nvim/.claude/extensions/), the install-extension.sh / uninstall-extension.sh scripts handle clean removal. The python extension was removed at the source level. The correct documentation posture is:
- **Do not document python extension** (pretend it never existed in current docs)
- **Do not add an extension deprecation/removal guide** (clean deletion is appropriate for a private system with no external consumers)

A deprecation/removal guide would only be warranted if extensions were published packages with external consumers. This system is single-user.

### 5. Lean MCP Scripts Are Undocumented

Two new scripts (`setup-lean-mcp.sh`, `verify-lean-mcp.sh`) were added to `.claude/scripts/`. These scripts:
- Add the `lean-lsp` MCP server to user-scope `~/.claude.json`
- Address a platform bug (Claude Code Issue: custom subagents cannot access project-scoped MCP servers)
- Are well-commented internally

Currently, these scripts are **not referenced from any documentation**. The existing CLAUDE.md Utility Scripts section only mentions `export-to-markdown.sh` and `check-extension-docs.sh`. The lean MCP setup scripts should be referenced from:
1. `.claude/CLAUDE.md` — Utility Scripts section (one-liner reference)
2. The lean extension's README or MCP Setup section (if a lean extension README exists here)

### 6. Naming Consistency: talk→slides Was Clean, No Other Inconsistencies Found

The rename from `talk-agent`/`skill-talk` to `slides-agent`/`skill-slides` appears complete — no residual `talk-agent` or `skill-talk` references found in active system files. The CLAUDE.md and extensions.json both show `skill-slides`/`slides-agent` correctly.

A scan for other potential naming inconsistencies did not surface obvious problems:
- `epi` vs `epidemiology` — CLAUDE.md correctly shows `epi` as primary, with `epidemiology` as alias (in the routing table); routing.md only shows `epi`; the extension name in `extensions.json` remains `epidemiology` (which is the internal key, not the task type)
- All agent/skill names follow consistent `{domain}-{type}-agent` / `skill-{domain}-{type}` patterns

One nuance: The CLAUDE.md Epidemiology Extension section still lists `epidemiology` as a task type key in its routing table alongside `epi` and `epi:study`. The question of whether `epidemiology` as a task type alias should remain is an implementation question for other teammates to assess.

### 7. Future-Proofing: The Documentation Gap Is in Examples, Not Structure

The most common failure mode for documentation drift is **examples that hardcode specific domain names**. The current guides use `python` as the canonical example domain throughout (creating-skills.md, creating-agents.md, component-selection.md, system-overview.md). Since python is no longer loaded, these examples have become misleading.

**Recommendation**: Replace all `python`-specific examples in guides with a neutral, fictional `your-domain` placeholder that mirrors the extension template pattern already used in `creating-extensions.md`. This creates durability — no specific removed domain will leave stale examples.

---

## Recommended Approach

### Priority 1 — High Impact, Required

1. **Remove `python` from active extension tables** in `.claude/README.md` and `.claude/context/routing.md`. These affect agent routing behavior at runtime.

2. **Replace python-specific examples** with generic `your-domain` throughout the guides (creating-skills.md, creating-agents.md, component-selection.md, system-overview.md, adding-domains.md). Use the pattern already established in creating-extensions.md.

3. **Fix docs/README.md breadcrumbs** — the "Neovim Configuration" project reference should reflect that this is the Zed configuration project (or be made generic).

### Priority 2 — Correctness, Should Fix

4. **Update creating-extensions.md section-applicability matrix** to not list `python` or `epidemiology` as concrete examples; use generic `simple-domain` / `complex-domain` placeholders.

5. **Add lean MCP scripts to CLAUDE.md Utility Scripts section**. One-liner: `setup-lean-mcp.sh` for lean-lsp MCP setup and `verify-lean-mcp.sh` for verification.

### Priority 3 — Optional Improvement

6. **Project-overview.md** already shows Neovim (per change 4 in the summary). Verify it accurately describes the zed project structure (it currently describes nvim/ tree structure, which is correct if this zed/.claude/ system manages the nvim project via the zed editor).

---

## Evidence/Examples

**Python in active routing context** (high priority):
- `/home/benjamin/.config/zed/.claude/context/routing.md:12` — `| python | skill-python-research | skill-python-implementation |`
- `/home/benjamin/.config/zed/.claude/README.md:123` — `| python | Python development | Python patterns, tools |`

**Python in guide examples** (creates confusion):
- `/home/benjamin/.config/zed/.claude/docs/guides/creating-skills.md:185,312-424` — skill template uses python-research pattern throughout
- `/home/benjamin/.config/zed/.claude/docs/guides/creating-agents.md:276,297` — agent template uses python
- `/home/benjamin/.config/zed/.claude/docs/guides/component-selection.md:105,167,170,314-315` — new component examples use python

**Breadcrumb navigation mismatch**:
- `/home/benjamin/.config/zed/.claude/docs/README.md:3,100` — links to `../../README.md` labeled "Neovim Configuration"
- `/home/benjamin/.config/zed/.claude/docs/README.md:5` — text says "Neovim configuration development"

**Lean MCP scripts with no documentation pointer**:
- `/home/benjamin/.config/zed/.claude/scripts/setup-lean-mcp.sh` — new, undocumented in CLAUDE.md
- `/home/benjamin/.config/zed/.claude/scripts/verify-lean-mcp.sh` — new, undocumented in CLAUDE.md

**ROADMAP.md is clean** (no action needed):
- `/home/benjamin/.config/zed/specs/ROADMAP.md` — placeholder only, no stale content

---

## Confidence Level

**High** (85-90%) on:
- Scope of stale python references in docs (comprehensive grep coverage)
- No stale talk-agent/skill-talk references (agents/ and skills/ directories verified)
- ROADMAP.md clean status (direct read)
- Lean MCP scripts being undocumented (no matches in grep of docs/)
- Extension deletion approach (no external consumers)

**Medium** (70%) on:
- Whether `epidemiology` task type alias in CLAUDE.md should be removed — depends on whether any existing tasks use that type key
- Whether docs/README.md breadcrumb fix is within scope (may depend on how the zed project's README structure is organized)
- The correct generic replacement example domain name (this is a style judgment)
