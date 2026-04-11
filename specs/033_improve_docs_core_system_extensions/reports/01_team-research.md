# Research Report: Task #33

**Task**: 33 - Improve documentation to present core agent system and extension architecture
**Date**: 2026-04-11
**Mode**: Team Research (4 teammates)

## Summary

The documentation has strong reference material but fails to tell the right story. The root README frames the system as "a Zed editor configuration for R and Python" when the distinctive product is the `.claude/` agent system with its task lifecycle and extension ecosystem. The task lifecycle is never explained in README.md, extensions are presented as afterthoughts ("Also available"), and stale Neovim references in machine-facing files actively mislead agents. The minimum effective intervention restructures README.md around the task lifecycle as the core narrative, fixes stale references in `.claude/CLAUDE.md` and `.claude/README.md`, and updates the factually wrong `project-overview.md`.

## Key Findings

### 1. The README tells the wrong story (All teammates agree — High confidence)

The README opens by describing a Zed editor configuration for R and Python. The actual product is a structured AI agent system that provides traceable research, planning, and implementation workflows via Claude Code, with domain extensions for epidemiology, grants, presentations, and more. R and Python are the target development languages, not the core value proposition.

The task lifecycle (`/task` -> `/research` -> `/plan` -> `/implement` -> `/todo`) is the conceptual spine of the entire system but is never explained in README.md. Users see a flat command table with no indication that these commands form a sequential state machine with resumable phases, structured artifacts, and git-committed history.

### 2. Extensions are presented as afterthoughts (Teammates A, B, D — High confidence)

The README phrase "Also available -- domain extensions" positions six production-grade extensions as supplementary add-ons. Each extension ships full agent/skill/command stacks:

| Extension | Version | Commands | What it does |
|-----------|---------|----------|-------------|
| epidemiology | v2.0.0 | `/epi` | R-based study design, causal inference, STROBE reporting |
| present | v1.0.0 | `/grant`, `/budget`, `/timeline`, `/funds`, `/slides` | Grant development, funding analysis, research talks |
| filetypes | v2.2.0 | `/convert`, `/edit`, `/table`, `/scrape` | Document conversion, Office editing |
| latex | v1.0.0 | (via task lifecycle) | LaTeX document development |
| typst | v1.0.0 | (via task lifecycle) | Typst document development |
| memory | v1.0.0 | `/learn`, `--remember` | Persistent knowledge vault |

The correct frame is "platform + plugins": a core task lifecycle that domain extensions augment with specialized commands, agents, and knowledge.

### 3. Stale Neovim references pollute agent context (Teammate C — High confidence)

`.claude/CLAUDE.md` (loaded every session by every agent) contains:
- Multiple `<leader>ac` references (a Neovim keybinding with no meaning in Zed)
- VimTeX keybindings (`:VimtexCompile`, `<leader>lc`, etc.) under the LaTeX extension
- `extensions/*/manifest.json` path (no such directory exists; uses flat `extensions.json`)
- `nvim` extension listed as available (not installed in this workspace)

`.claude/README.md` repeats the `<leader>ac` and `nvim` extension references.

The human-facing `docs/agent-system/README.md` correctly states "All extensions are pre-merged into the active configuration; there is no manual loading step" — but the machine-facing files contradict this.

### 4. project-overview.md is factually wrong (Teammate D — High confidence)

`.claude/context/repo/project-overview.md` still describes a "Neovim configuration project using Lua and lazy.nvim." Every agent loads this as workspace context. This is a critical fix — agents start from a false premise about the project they're working in.

### 5. No audience-specific entry points (Teammate B — High confidence)

Users arrive with different goals (grant writing, epi analysis, R/Python development) but all encounter the same front door. Well-documented CLI tools (Docker, GitHub CLI, Homebrew) provide persona-based "getting started" paths. The existing `docs/workflows/README.md` has an excellent decision guide and common scenarios section, but it's buried three levels deep and not surfaced in the README.

### 6. "Python" listed as extension but isn't one (Teammate C — High confidence)

`docs/agent-system/README.md` lists "Python" as a domain extension, but `.claude/extensions.json` has no Python extension. Python is core language toolchain support, not an extension.

### 7. Quick Start omits the primary workflow (Teammates B, D — High confidence)

The README Quick Start covers installation (Homebrew, Zed, `install.sh`) but shows zero Claude Code commands. The agent system's "Quick start: your first task" is buried in `docs/agent-system/README.md`. A user drawn by the agent system finds nothing useful on the first screen.

### 8. Examples are underutilized (Teammate B — Medium confidence)

`examples/epi-study/` and `examples/epi-slides/` are excellent end-to-end walkthroughs but are presented as frozen references rather than "quickstart templates." Adding a "to start your own, run X" framing would make them entry points instead of appendices.

## Synthesis

### Conflicts Resolved

**Scope**: Teammate C warned about scope creep ("improve all documentation" is too broad). Teammate D pushed for ambitious "platform-first" reframing. **Resolution**: The plan should prioritize correctness fixes (stale references, project-overview.md) and the README restructure. The platform-first reframe is the right direction but should be achieved through targeted README changes, not a documentation overhaul.

**project-overview.md**: Teammate D flagged it as critical; other teammates didn't examine it. **Resolution**: Verified the file contents — it genuinely describes a Neovim project with Lua/lazy.nvim. This is a critical fix that should be in Phase 1.

**Extension hub**: Teammate D recommended a new `docs/agent-system/extensions.md` page. Teammate B recommended audience-first guides. **Resolution**: Both are valid but the extension hub is lower priority than fixing what exists. The plan can include it as an optional phase.

### Gaps Identified

1. **No review of docs/agent-system/commands.md** for how well it already groups commands by lifecycle vs domain — Teammate A noted it has good grouping; the plan should check whether README.md can simply adopt that structure
2. **Natural workflow composition** (epi -> slides, grant -> budget -> timeline) is not documented anywhere — Teammate C and B both flagged this
3. **The "why this exists" value proposition** for the agent system is absent from all user-facing docs

### Recommendations

**Priority 1 — Correctness (must fix)**:
- Fix stale references in `.claude/CLAUDE.md`: `<leader>ac`, VimTeX keybindings, `extensions/*/manifest.json` path, `nvim` extension
- Fix `.claude/README.md`: remove nvim extension row, update extension loading description
- Rewrite `.claude/context/repo/project-overview.md` for the Zed workspace
- Remove "Python" from extensions list in `docs/agent-system/README.md`

**Priority 2 — README restructure (core task)**:
- Add 3-5 sentence "architecture in brief" prose explaining the task lifecycle and extension model
- Add a concrete lifecycle example (`/task` -> `/research` -> `/plan` -> `/implement`)
- Restructure command section: lifecycle core, then domain-grouped extensions with purpose statements, then housekeeping
- Replace "Also available -- domain extensions" with first-class extension presentation
- Surface the decision guide or common scenarios from `docs/workflows/README.md`

**Priority 3 — Supporting docs (if scope allows)**:
- Move "Quick start: your first task" earlier in `docs/agent-system/README.md`
- Add one framing sentence to `docs/README.md` about core + extensions
- Consider adding a Mermaid visual command map to README.md
- Consider creating `docs/agent-system/extensions.md` as a standalone catalog

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary: structural improvements to README | completed | high |
| B | Alternatives: prior art and documentation patterns | completed | high |
| C | Critic: gaps, stale references, scope risks | completed | high |
| D | Horizons: strategic direction and identity | completed | high |

## References

- specs/033_improve_docs_core_system_extensions/reports/01_teammate-a-findings.md
- specs/033_improve_docs_core_system_extensions/reports/01_teammate-b-findings.md
- specs/033_improve_docs_core_system_extensions/reports/01_teammate-c-findings.md
- specs/033_improve_docs_core_system_extensions/reports/01_teammate-d-findings.md
