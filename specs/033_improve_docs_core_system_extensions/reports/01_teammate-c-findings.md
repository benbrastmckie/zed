# Research Report: Task #33 — Teammate C (Critic) Findings

**Task**: 33 - Improve README.md and supporting documentation
**Role**: Teammate C — Critic
**Approach**: Identify gaps, shortcomings, and blind spots
**Started**: 2026-04-11
**Completed**: 2026-04-11
**Sources**: README.md, docs/README.md, docs/agent-system/README.md, .claude/CLAUDE.md, .claude/README.md, .claude/extensions.json

---

## Key Findings

### 1. Stale References Are the Biggest Problem

The most concrete and actionable issue is stale Neovim/VimTeX content embedded in machine-facing files that agents read. These incorrect references pollute the agent context and will mislead any agent reasoning about this workspace.

**Specific stale references found**:

**In `.claude/CLAUDE.md`** (loaded every session by every agent):
- Line 73: `"Extension Task Types (available when extensions are loaded via `<leader>ac`)"` — `<leader>ac` is a Neovim keybinding with no meaning in Zed
- Line 75: `"See .claude/extensions/*/manifest.json"` — no `.claude/extensions/` directory exists here; the actual mechanism is `.claude/extensions.json`
- Lines 120: Example `task_type: "neovim"` in state.json schema — this is a Neovim-specific task type, potentially confusing in a Zed workspace
- Lines 200, 222, 293: Multiple references to `<leader>ac` for loading extensions
- Lines 445-448: VimTeX keybindings (`:VimtexCompile` with `<leader>lc`, etc.) documented under the LaTeX extension — VimTeX does not exist in Zed

**In `.claude/README.md`** (architecture reference file):
- Line 113: `"Extensions are loaded via <leader>ac keybinding"` — invalid in Zed
- Lines 119, 187: `nvim` extension listed as available, `Neovim Integration` guide linked — neither applies to this workspace

**Why this matters**: These files are loaded into agent context on every session. An agent reading `.claude/CLAUDE.md` will believe `<leader>ac` is a valid operation, that a `nvim` extension exists, and that VimTeX keybindings are applicable. This is a correctness problem, not just a presentation problem.

**What's actually true**: Extensions in this workspace are pre-merged, always-on, and tracked in `.claude/extensions.json`. There is no manual loading step. The `docs/agent-system/README.md` correctly states this ("All extensions are pre-merged into the active configuration; there is no manual loading step") — but the authoritative `.claude/CLAUDE.md` contradicts it.

---

### 2. Audience Confusion: No Clear Separation of Concerns

The documentation has three implicit audiences but no explicit routing:

1. **New user** — "How do I install and use this?"
2. **Day-to-day user** — "What can I do with this system?"
3. **Agent/system internals** — "How does routing and state management work?"

The boundary is partially stated in `docs/README.md` (which correctly says "For the machine-facing agent system internals, see `.claude/README.md`"), but it breaks down in practice:

- `docs/agent-system/README.md` starts with a user-facing "Quick start: your first task" section but also includes the architecture pipeline and skill-to-agent mappings — mixing user and developer concerns
- `.claude/README.md` contains a "Getting Started" section with a `[User Installation Guide]` link — user content buried in agent-facing docs
- The top-level `README.md` is appropriately user-facing and well-scoped, but it links to `.claude/CLAUDE.md` as `[Claude Code System] — Full agent system reference (commands, skills, agents)` — directing users into the agent internals without warning

The core issue: the README.md audience boundary is stated but not maintained across files.

---

### 3. Missing Narrative: "What Can This Do For Me?" Is Fragmented

The task asks to "highlight the range of commands the .claude/ agent system provides with the task management workflow system at the core." The current docs do not tell a coherent "here's what you can DO" story.

**Specific gaps**:

- The top-level `README.md` presents commands in two flat tables with no narrative connecting them. There is no explanation of *why* the workflow is `/task` -> `/research` -> `/plan` -> `/implement` or what the user gains from this structure
- The domain extensions (epi, grant, budget, slides) are described in bullet fragments. A user encountering the system for the first time cannot easily understand how `/epi` relates to `/research` and `/implement` — is `/epi` a replacement? A wrapper? An add-on?
- The task management system (specs/TODO.md, state.json, task lifecycle, artifact directories) is mentioned but never explained from a user benefit perspective. What does a user *get* from the structured artifact trail vs. just asking Claude ad hoc?
- No "choose your path" entry point: a user who only cares about grant writing has no fast path to the three commands they need; they encounter all domain extensions simultaneously

---

### 4. Extension Presentation Is Table-Heavy, Story-Light

The `.claude/CLAUDE.md` documents each extension with routing tables, skill-to-agent mappings, and context file paths. This level of detail serves agents and developers, not users.

From a user perspective, what's missing:

- **What does the output look like?** The README.md links to `examples/epi-study/` and `examples/epi-slides/` — useful. But for grants, slides, and budget outputs, there are no example links
- **What inputs does each command need?** The `/grant` command table shows six usage variants, but a first-time user cannot tell from the docs what information they should have ready before running `/grant "My NIH proposal"`
- **What is the relationship between extensions?** Epi studies often become slides (`/epi` -> `/slides`). Grant proposals often need budgets (`/grant` -> `/budget` -> `/timeline`). These natural workflows are invisible in the current docs

---

### 5. Scope Creep Risk Is Real

The task description is broad: "Improve README.md and supporting documentation." The risk is making surface-level changes across all files without fixing the root problems. Specific scope risks:

- Rewriting extension descriptions without fixing the stale `<leader>ac` references (cosmetic over correctness)
- Adding more tables to already table-heavy docs (more structure without more clarity)
- Writing a new "workflow narrative" in the README without updating the fragmented docs it links to (creating a disconnect between entry point and details)

**Minimum effective changes** (prioritized):
1. Fix stale references in `.claude/CLAUDE.md` — VimTeX keybindings, `<leader>ac`, `extensions/*/manifest.json` path, `nvim` task type example
2. Fix `.claude/README.md` — remove Neovim integration link and nvim extension row
3. Add 2-3 sentences of narrative to README.md explaining the task workflow benefit
4. Optionally: add a brief "natural workflows" section showing how extensions compose (epi -> slides, grant -> budget -> timeline)

---

### 6. "Python Extension" Listed but Does Not Exist as an Extension

`docs/agent-system/README.md` lists "Python" as a domain extension ("General Python development with pytest, mypy, ruff, and library research"). But examining `.claude/extensions.json`, there is no Python extension. The active extensions are: `present`, `filetypes`, `latex`, `epidemiology`, `memory`, `typst`.

Python is a core language toolchain (covered via general task type routing and the docs/toolchain/python.md guide), not an extension. Listing it alongside epi and present in the extensions section overpromises and misrepresents the architecture.

---

## Recommended Approach

### High Priority (Fix These First)

1. **Patch `.claude/CLAUDE.md`** — Remove or replace all `<leader>ac` references with accurate descriptions of the Zed workspace extension mechanism. Remove VimTeX keybindings from the LaTeX section (or replace with Zed-appropriate compilation instructions). Update the extension loading description to match the flat `extensions.json` approach. Update the example `task_type` in the state.json schema.

2. **Patch `.claude/README.md`** — Remove the `nvim` extension row from the extensions table. Remove the Neovim Integration link from the documentation hub.

3. **Remove "Python" from the extensions list** in `docs/agent-system/README.md` — it is not an extension.

### Medium Priority (Narrative Improvement)

4. **Add a "Why the workflow?" section to README.md** — 3-5 sentences explaining what users gain from `/task` -> `/research` -> `/plan` -> `/implement` vs. ad hoc prompting (traceable artifact trail, resumable phases, multi-agent parallelism).

5. **Add a "Natural workflows" callout** — Show 2-3 example command chains (e.g., `/epi` study -> `/slides`; `/grant` draft -> `/budget` -> `/timeline`) to communicate how extensions compose.

### Lower Priority (If Scope Allows)

6. **Add example output links for non-epi extensions** — If grant or slides examples exist in the repo, link them from the README.md examples table.

7. **Tighten docs/agent-system/README.md audience** — Move the quick-start to a user-facing section and clearly mark the architecture/routing content as "for developers and advanced users."

---

## Evidence and Examples

### Stale Reference: VimTeX in a Zed Workspace

`.claude/CLAUDE.md` contains:
```
### VimTeX Integration
- Compile: `:VimtexCompile` (`<leader>lc`)
- View PDF: `:VimtexView` (`<leader>lv`)
- Clean: `:VimtexClean` (`<leader>lk`)
- TOC: `:VimtexTocOpen` (`<leader>li`)
```

VimTeX is a Neovim plugin. It has no presence in Zed. The LaTeX extension installed in this workspace (per `.claude/extensions.json`) has compilation via `latexmk` from the terminal, not VimTeX.

### Stale Reference: Extension Loading Mechanism

`.claude/CLAUDE.md` line 73: `"Extension Task Types (available when extensions are loaded via <leader>ac)"`

`.claude/README.md` line 113: `"The extension system provides task-type-specific support. Extensions are loaded via <leader>ac keybinding."`

Actual state per `docs/agent-system/README.md` line 41: `"All extensions are pre-merged into the active configuration; there is no manual loading step."`

The human-facing docs are correct. The machine-facing docs are wrong.

### Stale Reference: extensions/*/manifest.json Path

`.claude/CLAUDE.md` line 75: `"See .claude/extensions/*/manifest.json for available extensions"`

Actual state: no `.claude/extensions/` directory. Extensions tracked in `.claude/extensions.json` (flat JSON, no manifests).

### Non-Existent Python Extension

`docs/agent-system/README.md` line 34: `"Python -- General Python development with pytest, mypy, ruff, and library research."`

`.claude/extensions.json`: No Python extension entry. The six active extensions are present, filetypes, latex, epidemiology, memory, typst.

---

## What Is Working Well (Do Not Change)

1. **Top-level README.md structure** — The overall organization (Quick Start, Languages, Commands, Directory Layout, Documentation table) is clear and appropriate for the user audience. The command tables are concise and correct for user-facing content.

2. **docs/agent-system/README.md — Extensions section** — The listing of extensions with brief descriptions and "no manual loading step" note is accurate and useful. Only the Python item needs removal.

3. **docs/README.md audience statement** — The explicit statement "These docs are written for day-to-day users... For the machine-facing agent system internals, see .claude/README.md" is the right model and should be preserved.

4. **The quick-start task workflow in docs/agent-system/README.md** — The five-step example (create, research, plan, implement) is a good model and should be preserved or expanded, not replaced.

5. **The "Zed adaptations" section in docs/agent-system/README.md** — This section explicitly documents deviations from the upstream configuration (no Co-Authored-By, no extensions/ directory). It is accurate and valuable. It should be the authoritative source and the `.claude/CLAUDE.md` discrepancies should be corrected to match it.

---

## Questions That Should Be Asked But Aren't

1. **Who actually reads `.claude/CLAUDE.md`?** If it is loaded into agent context on every session, the stale references there are actively harmful (not just confusing). If it is also read by humans as a reference, the problem is doubled. The fix priority depends on the answer.

2. **Are there currently any broken agent behaviors caused by the stale `<leader>ac` references?** An agent that tries to execute `<leader>ac` as a command will fail silently or confusingly. Knowing whether this has caused problems would confirm the fix priority.

3. **Does the `/slides` command produce Slidev output (as stated in CLAUDE.md) or a different format?** The present extension documentation in CLAUDE.md mentions Slidev. The filetypes extension documentation mentions Beamer/Polylux/Touying. Clarifying which is used for which workflow would prevent user confusion.

4. **Should `.claude/README.md` be user-facing or agent-facing?** Currently it is formatted for agents (architecture diagrams, skill tables) but has user-guide links and a version history section. Deciding this would clarify what content belongs there.

---

## Confidence Level

| Finding | Confidence |
|---------|-----------|
| Stale `<leader>ac` references in .claude/CLAUDE.md | High — verified by direct file inspection |
| VimTeX keybindings inapplicable in Zed | High — VimTeX is a Neovim plugin, not a Zed extension |
| extensions/*/manifest.json path incorrect | High — no .claude/extensions/ directory exists |
| Python listed as extension but is not one | High — verified against extensions.json |
| Missing "why the workflow?" narrative | Medium — present docs may implicitly cover this in linked files not reviewed |
| Extension composition workflows not documented | Medium — workflows/README.md not reviewed; may cover this |
| Scope creep risk | Medium — depends on implementation decisions |
