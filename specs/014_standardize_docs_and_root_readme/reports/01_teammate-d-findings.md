# Teammate D – Horizons: Strategic Documentation Findings

**Task 14**: Standardize docs/ README files and improve root README for Zed + Claude Code epi/medical research config
**Teammate role**: Long-term alignment and strategic direction
**Date**: 2026-04-10

---

## Key Findings

### 1. The root README undersells the project's actual identity

The current root README opens with "Zed editor configuration for macOS" and leads with Homebrew installation. This is accurate but insufficient. The repo is meaningfully more than a Zed configuration: it is an AI-assisted epidemiology and medical research workbench that uses Zed as the editor layer. The epidemiology and grant-development capabilities -- `/epi`, `/grant`, `/budget`, `/funds`, `/timeline`, `/slides` -- are buried in a two-line paragraph under "AI Integration" on line 80. A new user reading the README would have no idea this is a primary use case.

**Gap**: The README does not link to `.memory/README.md` or `.claude/README.md` -- two documents that explain essential systems (the shared AI memory vault and the full agent system). Both are mentioned only incidentally in directory layout comments.

### 2. The docs/ README files have structural inconsistencies

Across the four docs/ READMEs, there is no shared structural template:

| File | Has "Navigation" | Has "Quick start" | Has "See also" | Has "Contents" |
|------|-----------------|-------------------|----------------|----------------|
| `docs/README.md` | No | No | No | Yes |
| `docs/general/README.md` | Yes | Yes | Yes | No |
| `docs/agent-system/README.md` | Yes | Yes (verbose) | Yes | No |
| `docs/workflows/README.md` | No | No | Yes | Yes (called "Contents") |

`docs/README.md` is a thin 10-line index with no "See also" and no way to orient a new reader. `docs/agent-system/README.md` is the most developed (with a "Zed adaptations" section explaining how this config departs from the upstream neovim system), but that section has no equivalent in the other READMEs. `docs/workflows/README.md` is the richest, with a decision guide and common scenario walkthroughs -- a pattern worth propagating.

### 3. The relationship between .claude/CLAUDE.md and docs/ is implicit

`.claude/CLAUDE.md` is the canonical agent instructions file -- it is what Claude reads. `docs/` is the human-readable documentation layer. These serve different audiences (AI vs human), but this distinction is never stated. Users navigating the repo cannot easily understand:

- Why both `docs/agent-system/architecture.md` and `.claude/README.md` cover architecture
- Which version is authoritative for which audience
- That `docs/` adapts and explains `.claude/` content rather than duplicating it

`docs/agent-system/README.md` does have a "Zed adaptations" section (lines 30-37) that explains three specific deviations from the upstream neovim config. This is good practice -- but it does not articulate the general docs-vs-CLAUDE.md relationship principle.

### 4. The .memory/ system's relationship to documentation is invisible

The `.memory/README.md` is a well-written document, but it is completely disconnected from the docs/ tree. Neither `docs/README.md` nor the root `README.md` link to it. `docs/agent-system/context-and-memory.md` does explain the memory system thoroughly (and links to `.memory/README.md`), but the root README only mentions `.memory/` in the directory layout table with the comment "AI memory vault" -- no link, no explanation.

For a medical research user who stores study findings, funding notes, and protocol decisions in the memory vault, this invisibility creates friction. The memory system is a key differentiator for repeated epi work (reusing prior study patterns via `/research N --remember`), and it should be discoverable from the root.

### 5. The docs/ structure scales well as-is, but has an extension blindspot

The current three-directory structure (`general/`, `agent-system/`, `workflows/`) is clean and well-reasoned. It will scale to additional workflow guides without restructuring. However, the extension-based capabilities (epidemiology, grant development, memory, LaTeX, Typst) are documented within `docs/workflows/` as individual workflow files, but nowhere in the docs/ tree is there a conceptual "here is what extensions are and why they matter" document aimed at a human reader. `.claude/CLAUDE.md` has extension sections, but they are formatted as agent instructions, not user orientation.

As more extensions are added, the `docs/workflows/` directory will grow but remain coherent because each workflow file is already scoped to a domain. The real scaling risk is the `docs/agent-system/commands.md` file: it catalogs all 25 commands but will need to be maintained as new commands are added, and has no mechanism for extension-specific commands to self-register.

### 6. The README targets the wrong primary audience

The current README reads as if the primary audience is someone setting up Zed for the first time. The quick start leads with `brew install --cask zed` and focuses on essential shortcuts (Cmd+P, Cmd+S). But the actual primary user is a returning researcher who knows Zed is installed and wants to quickly find how to start an epidemiology study or resume a grant task.

The root README should serve two audiences explicitly: new setup (concise, pointing to installation.md) and returning researcher (quick command reference for the research workflows). Currently it only serves the first.

---

## Recommended Approach

### For the root README.md

1. **Reframe the opening**: Change the subtitle/description from "Zed editor configuration for macOS" to something that reflects the actual use case, for example: "Zed editor with Claude Code for epidemiology and medical research on macOS."

2. **Add a research quick-start table** near the top (before the editor quick-start) showing the most-used research commands: `/epi`, `/grant`, `/research`, `/plan`, `/implement`. Keep the existing editor shortcuts table but move it to a collapsible section or after the research section.

3. **Add explicit links to `.memory/README.md` and `.claude/README.md`** in the Documentation table. The current table has four rows; add two more:

   | Document | Description |
   |----------|-------------|
   | [Memory Vault](.memory/README.md) | Shared Obsidian vault for learned facts across sessions |
   | [Agent System Config](.claude/README.md) | Architecture navigation hub for the Claude Code framework |

4. **Add a one-paragraph "Who this is for" section** above the quick start that names the primary use case: epidemiology/medical research, grant development, document workflows.

### For docs/README.md

Expand from 10 lines to a proper landing page (~30-40 lines) that:
- Briefly explains the three sections and what audience each serves
- States the relationship between docs/ (human orientation) and .claude/ (agent instructions)
- Links to `.memory/README.md` for the memory system
- Has a "See also" section pointing to root README and .claude/README.md

### For docs/ README standardization

Adopt a lightweight template that all four READMEs follow:

```
# [Section Name]

One-sentence purpose statement.

## Navigation
[Table of files with descriptions]

## [Quick start | Decision guide | Common scenarios]
[Section-specific orientation content]

## See also
[Cross-links to related sections]
```

This does not require rewriting content -- mostly adding missing "See also" sections and normalizing heading names. `docs/README.md` and `docs/workflows/README.md` need the most work; `docs/general/README.md` and `docs/agent-system/README.md` are already close to this pattern.

### For communicating the docs/.claude/ relationship

Add a one-sentence note at the top of `docs/README.md` and in `docs/agent-system/README.md` clarifying the relationship:

> "These docs are human-readable orientation guides. `.claude/CLAUDE.md` and `.claude/README.md` are the authoritative agent instructions; `docs/` adapts and explains them for human readers."

### Creative approaches worth considering (lower priority)

**Workflow decision tree at the root README**: A simple "I want to..." table in the root README, similar to what `docs/workflows/README.md` already has, would let returning users find their entry point in under 5 seconds. The workflows README already has an excellent decision guide -- a condensed version of it belongs in the root README.

**Extension status summary**: A small table in `docs/README.md` or the root README listing which extensions are active and what they enable (epidemiology, grant development, memory, filetypes, LaTeX, Typst) would help users understand the full capability set without reading `.claude/CLAUDE.md`. The `docs/agent-system/architecture.md` file has a partial version of this (lines 119-122) but it is buried in a technical document.

**Architecture decision records (ADRs)**: Given the complexity of the multi-AI-system design (Zed Agent Panel + Claude Code + OpenCode + shared .memory/ vault), a lightweight ADR for key decisions (e.g., "why shared .memory/ vault", "why all extensions pre-merged in Zed vs on-demand in neovim") would help long-term maintainability. This is lower priority but would be valuable if the configuration is shared with collaborators.

---

## Evidence and Examples

**Root README undersells epi/medical use case**: Lines 78-81 are the only mention of epidemiology (`/epi` command), grant development, and research -- in a 94-line README. By contrast, the editor shortcuts section (lines 17-28) has a full table in the first screen. The primary use case is secondary to the editor setup.

**Missing .memory/README.md link**: The root README mentions `.memory/` in the directory layout (line 44) but never links to `.memory/README.md`. `docs/agent-system/context-and-memory.md` links to it in its "See also" section, but this is buried 3 clicks from the root.

**Missing .claude/README.md link**: The root README links to `.claude/CLAUDE.md` twice (lines 54, 92) but never to `.claude/README.md` (the architecture navigation hub). These are different documents with different purposes.

**Structural inconsistency example**: `docs/workflows/README.md` has a rich "Decision guide" and "Common scenarios" section that dramatically aids navigation. `docs/README.md` has neither -- just a 3-item list. Users landing in `docs/` have less orientation than users landing in `docs/workflows/`.

**"Zed adaptations" section is a good pattern**: `docs/agent-system/README.md` lines 30-37 explain three specific ways this Zed config deviates from the upstream neovim config. This is exactly the kind of context that helps a returning user understand why something works differently. This pattern should be considered for `docs/README.md` (e.g., "how this config differs from the neovim config").

---

## Confidence Level

**High confidence**:
- Root README needs to foreground the epi/medical research use case (structural, not subjective)
- `.memory/README.md` and `.claude/README.md` links are missing from the root README (factual gap)
- docs/README.md is underdeveloped relative to the other docs/ READMEs (measurable inconsistency)

**Medium confidence**:
- The two-audience problem (new setup vs returning researcher) is the right framing for root README restructuring -- this is an interpretation of intent, but strongly supported by the existing content structure
- docs/ "See also" standardization is worthwhile -- judgment call on effort vs value

**Lower confidence**:
- ADR recommendation is speculative about future collaborator needs; may be over-engineering for a personal config
- Extension status summary table: the `docs/agent-system/architecture.md` extension section may be sufficient if users know to look there
