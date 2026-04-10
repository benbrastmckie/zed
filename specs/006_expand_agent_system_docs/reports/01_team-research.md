# Research Report: Task #6

**Task**: Expand `docs/agent-system.md` into a `docs/` directory and extract installation guide
**Date**: 2026-04-10
**Mode**: Team Research (4 teammates: Primary, Alternatives, Critic, Horizons)
**Session**: sess_1775848282_0a1943

---

## Summary

The current `docs/agent-system.md` (378 lines, recently rewritten by task 5) mixes installation steps, system description, workflow guidance, command catalog, memory model, and architecture into a single dense file. It also makes zero mention of `claude-acp` — the `@zed-industries/claude-agent-acp` npm package that actually bridges Zed's Agent Panel to Claude Code and is configured in this workspace's `settings.json` under `agent_servers`. The user's request is twofold: (1) extract installation content into an independent `docs/installation.md` focused on macOS Homebrew plus claude-acp setup, and (2) expand the remainder into a `docs/agent-system/` subdirectory with one focused file per natural grouping, each following a progressive-disclosure pattern (brief explanation → example → advanced details).

All four teammates converge on the same structural recommendation: **replace `docs/agent-system.md` with a `docs/agent-system/` subdirectory plus a new top-level `docs/installation.md`, keeping the existing `keybindings.md`, `settings.md`, and `office-workflows.md` unchanged.** The main resolved tension was granularity (4 vs 6 files vs a command-split model); consensus lands on ~6 files balancing coverage and navigability. The critical non-structural finding is that several existing hard links — including a fragment link from `office-workflows.md` to `agent-system.md#mcp-tool-setup` — will silently break if the split is executed carelessly.

---

## Key Findings

### Primary Approach (Teammate A)

Proposes a 6-file `docs/agent-system/` subdirectory plus a standalone `docs/installation.md`, with a detailed line-by-line mapping of current `agent-system.md` sections to their target files:

| Current lines | Section | Target file |
|---|---|---|
| 1–37 | Installation (Homebrew, Zed, MCP stub) | `docs/installation.md` |
| 38–50 | Two AI Systems overview | `docs/agent-system/README.md` |
| 51–103 | Claude Code Main Workflow | `docs/agent-system/workflow.md` |
| 104–165 | Command Catalog by Topic (24 commands) | `docs/agent-system/commands.md` |
| 166–213 | Memory System (vault, auto-memory, layers) | `docs/agent-system/context-and-memory.md` |
| 214–265 | Architecture & Configuration (pipeline, state) | `docs/agent-system/architecture.md` |
| 266–295 | MCP Tool Setup (SuperDoc, openpyxl) | `docs/installation.md` (final step) |
| 296–328 | Zed Agent Panel + keybindings | `docs/agent-system/zed-agent-panel.md` |
| 329–378 | Related Documentation (22 cross-refs) | Distributed per file |

Each new file gets a clear target audience (new user → intermediate → advanced) and a progressive-disclosure structure (summary → example → flags → links). Advanced material lives at the bottom of each file, not in a separate tree. Confidence: high.

### Alternative Approaches (Teammate B)

Ground-truths the claude-acp config and adds the **Diátaxis framework** (tutorial / how-to / reference / explanation) as the organizing principle. Recommends a flatter 4-file split:

```
docs/agent-system/
├── README.md       (orientation / explanation)
├── commands.md     (reference)
├── memory.md       (explanation)
└── architecture.md (explanation, mostly links)
```

Provides the complete claude-acp installation matrix — including the **registry vs custom distinction** that Teammate A partially missed:

- **Registry (recommended for Homebrew users)**: `{ "type": "registry", "env": {} }` — Zed auto-installs `@zed-industries/claude-acp` on first thread creation and updates it automatically.
- **Custom (what this NixOS machine currently uses)**: explicit `command` + `args` pointing to an npx path. Required when Zed cannot find npx on PATH.

Also flags that `docs/settings.md` currently has no `agent_servers` section at all, which is a separate documentation gap the split should address. Critical clarification: the `claude-code-extension` listed in `auto_install_extensions` (settings.json line 119) is a Zed UI extension that adds the menu entry; the ACP server is the separate `@zed-industries/claude-agent-acp` npm package. Both are needed. Confidence: high.

### Gaps and Shortcomings (Teammate C — Critic)

Raises eight substantive issues that the Primary/Alternatives approaches do not address:

1. **Task 5 overlap.** Task 5 just completed a full rewrite of `agent-system.md` (185 → 378 lines) specifically to add Main Workflow and Command Catalog sections and preserve installation inline. Task 6 partially reverses Decision D5 of Task 5 ("keep installation in agent-system.md") without acknowledging it. Neither is wrong, but the implementer must treat the rewritten document as the starting point, not the old one.
2. **Link breakage is high and understated.** Nine hard links across 5 files point to `docs/agent-system.md`, including **fragment links** that will silently break:
   - `README.md` (5 references, including directory tree)
   - `docs/README.md` — `[Agent System](agent-system.md)`
   - `docs/settings.md` — `[Agent system](agent-system.md)`
   - `docs/office-workflows.md` — **`agent-system.md#mcp-tool-setup`** (fragment)
   - `docs/office-workflows.md` — second reference to MCP Tool Setup
3. **Platform mismatch.** `settings.json` line 3 states `// Platform: NixOS Linux (binary: zeditor)`. A macOS-only `installation.md` is aspirational, not descriptive of the actual machine. Either make the audience explicit ("for a fresh macOS user") or include a NixOS adaptation note.
4. **Double-reference drift risk.** If `docs/agent-system/commands.md` writes new user-oriented command prose, it will coexist with `.claude/docs/guides/user-guide.md` and `.claude/CLAUDE.md` as a third command reference. These will diverge over time. The remedy is to link, not duplicate.
5. **"One file per natural grouping" is undefined.** The current file has 9 section headings; "natural grouping" could mean 9, 5, or 3 files. The planner must make a judgment call.
6. **The `docs/` ↔ `.claude/docs/` boundary is undefined.** Does the new `docs/` replace, supplement, or link to `.claude/docs/`?
7. **Over-engineering risk.** 6+ files require more cross-linking, more fragment anchors, and force users to navigate multiple files to understand one workflow.
8. **"claude-acp coverage" is ambiguous.** The user's phrasing — "loads all my commands" — implies explaining the ACP mechanism, not just adding a setup line. Setup + usage + mechanism are three different things.

Confidence: high. All eight findings are directly verifiable from the codebase.

### Strategic Horizons (Teammate D)

Frames the Zed `docs/` as the **only Zed-specific documentation layer** — `.claude/docs/` is a verbatim copy of the upstream nvim config and should be treated as a linked library, not customized. This leads to a "thin wrapper + strong link" principle: new `docs/` files should introduce Zed-specific context and link into `.claude/docs/` for full reference, never duplicate the prose.

Key strategic points:

- **claude-acp is a factual error, not just a gap.** The current `agent-system.md` line 47 says "start it by running `claude`", but the user actually runs `claude-acp`. This is incorrect documentation, not missing documentation.
- **Progressive disclosure within topic files is the right model.** The problem with `agent-system.md` is scale (24 commands in one file), not the summary → example → flags pattern itself. Keep the pattern; split the file.
- **Discoverability gap.** There is no path from `.claude/CLAUDE.md` or the terminal back to `docs/`. A one-line back-reference in `.claude/CLAUDE.md` closes this.
- **Extensions keep growing.** 6+ extensions are active (latex, typst, epidemiology, memory, present, filetypes), each adding commands. A flat command file will not scale; a command-group split (`docs/commands/lifecycle.md`, `docs/commands/documents.md`, etc.) is more sustainable long-term.
- **Auto-generation from frontmatter is premature.** Command frontmatter is agent-oriented (terse, technical); generating user docs from it yields low-quality prose. Better investment: a link-check script that verifies every command mentioned in `docs/` exists in `.claude/commands/`.
- **Platform siblings.** `installation.md` should be macOS-specific now but structured so a `linux.md` sibling can be added later.

Confidence: high.

---

## Synthesis

### Conflicts Resolved

| # | Conflict | Resolution |
|---|---|---|
| 1 | **Subdirectory vs peer files** (A: subdir, B: subdir, D: `docs/commands/` split) | Use `docs/agent-system/` subdirectory. It's the minimum-disruption option that preserves the existing `docs/` top-level shape. Do not adopt D's `docs/commands/` split in this task — defer as a future refactor if the single `commands.md` becomes unwieldy. |
| 2 | **File count: 6 (A) vs 4 (B) vs more granular (D)** | Land on 6 files (A's proposal) as the default, with explicit justification per file. `zed-agent-panel.md` is load-bearing for claude-acp content and should not be merged into `README.md`. `workflow.md` is distinct from `commands.md` by audience (lifecycle narrative vs reference). |
| 3 | **Installation doc: macOS-only vs multi-platform** (C: NixOS reality) | Make `installation.md` macOS-focused as requested, but add a clearly labeled `## Platform Notes` section at the bottom covering NixOS/Linux npx adaptation. This satisfies both the user's explicit macOS request and the actual machine's NixOS reality. Do not create `installation/` subdirectory yet. |
| 4 | **claude-acp config: custom vs registry** (A uses custom; B clarifies both exist) | Document **registry as the recommended default** for Homebrew users; document custom as the fallback when Zed cannot find npx. Current `settings.json` uses custom because NixOS, but this should not be the example in macOS install docs. |
| 5 | **Duplicate content risk** (C, D) | Enforce "thin wrapper + strong link" policy: every new file must link to at least one canonical source in `.claude/docs/`, `.claude/CLAUDE.md`, or `.claude/README.md`. Command descriptions in `commands.md` stay short; link to `.claude/docs/guides/user-guide.md` for the comprehensive reference. |
| 6 | **Task 5 overlap** (C raises) | Accept Task 5's rewritten file as the starting point. The split is additive editing: extract installation, split the remainder, preserve the recently-added Main Workflow and Command Catalog content verbatim into the new files. Do not re-research material Task 5 already covered. |
| 7 | **Fragment link from office-workflows.md** (C flags) | Update `docs/office-workflows.md` to point at `docs/installation.md#mcp-tools` (the new target). This is a required repair step, not optional. |

### Gaps Identified (remaining after synthesis)

1. **`docs/settings.md` is missing an `agent_servers` section entirely.** Task 6 should add this as part of the split, since it explains the claude-acp configuration in reference form. (B's finding; A and D did not explicitly mention it.)
2. **`.claude/CLAUDE.md` has no back-reference to `docs/`.** D flags this but it is out of scope for Task 6. Record as a follow-up opportunity, do not execute.
3. **Link-check script.** D recommends it but this is new scope and should not be bundled. Record as follow-up.
4. **Collaborator quick-start.** D suggests a `quick-start.md` for the shared collaborator. Not in the task request; record as follow-up.
5. **Definition of "claude-acp coverage"** (C question). Resolve to: installation.md covers *setup*; `zed-agent-panel.md` covers *usage + mechanism*. Split across two files gives each audience what they need.

### Recommendations

#### Target Structure

```
docs/
├── README.md                         # UPDATE: expand table of contents
├── installation.md                   # NEW: Homebrew + Zed + claude-acp + MCP
├── agent-system/
│   ├── README.md                     # NEW: orientation, two AI systems, navigation
│   ├── zed-agent-panel.md            # NEW: panel usage + claude-acp mechanism
│   ├── workflow.md                   # NEW: task lifecycle narrative
│   ├── commands.md                   # NEW: command catalog (thin wrapper + links)
│   ├── context-and-memory.md         # NEW: memory vault + context layers
│   └── architecture.md               # NEW: pipeline internals (advanced)
├── keybindings.md                    # KEEP (no change)
├── office-workflows.md               # UPDATE: fix fragment link to installation.md
├── settings.md                       # UPDATE: add agent_servers section
└── agent-system.md                   # DELETE after split (no redirect needed)
```

#### Per-File Specification

Every new file follows the progressive-disclosure pattern:
1. **One-paragraph summary** (audience: new user scanning)
2. **Minimal working example** (audience: new user trying it)
3. **Detailed section(s)** covering flags, integration, edge cases (audience: intermediate)
4. **"See also" links** into `.claude/docs/` or `.claude/README.md` (audience: power user)

**`docs/installation.md`** (NEW) — audience: fresh macOS user.
Sections:
1. Prerequisites
2. Install Homebrew
3. Install Zed (`brew install --cask zed`; mention `zed@preview` variant)
4. Install Claude Code CLI (`brew install anthropics/claude/claude-code` + `claude auth login`)
5. **Configure claude-acp** — the missing piece:
   - Explain what it is: the npm-based bridge Zed uses to talk to Claude Code via the Agent Client Protocol.
   - Registry config (recommended for Homebrew):
     ```json
     "agent_servers": {
       "claude-acp": { "type": "registry", "env": {} }
     }
     ```
   - Authenticate inside Zed with `/login` (NOT `claude auth login`; they are separate auth contexts).
6. Install MCP tools (SuperDoc, openpyxl — moved from `agent-system.md` lines 266–295)
7. Verify everything works (checklist)
8. **Platform Notes** (bottom):
   - NixOS/Linux: use `type: "custom"` with explicit `/path/to/npx` if Zed cannot find npx on PATH. Include the example from current `settings.json` lines 137–144.

Cross-references: `docs/settings.md` (for full `agent_servers` schema), `docs/agent-system/zed-agent-panel.md` (for using the panel after install), `.claude/docs/guides/user-installation.md` (for Claude Code CLI details).

**`docs/agent-system/README.md`** (NEW) — audience: new user who has installed.
Sections:
1. Two AI systems in this workspace (Zed's built-in AI vs Claude Code via claude-acp) — comparison table
2. When to use each
3. Navigation — what each doc in this subdirectory covers
4. Quick-start: first task walkthrough (`/task` → `/research` → `/implement`)

**`docs/agent-system/zed-agent-panel.md`** (NEW) — audience: new to intermediate.
Sections:
1. Opening the panel
2. Starting a built-in AI thread vs a Claude Code thread
3. **How claude-acp works under the hood** — explains that `@zed-industries/claude-agent-acp` is a WebSocket server launched by Zed per the `agent_servers` config, which then spawns the Claude Code binary. This is the "mechanism" the user's request mentions.
4. Authenticating (`/login` inside a thread)
5. Keybindings quick reference (links to full `keybindings.md`)
6. Inline Assist
7. Edit Predictions
8. Troubleshooting (`dev: open acp logs`, ACP connection issues)

**`docs/agent-system/workflow.md`** (NEW) — audience: new user learning the lifecycle.
Sections:
1. The state machine diagram (NOT STARTED → RESEARCHED → PLANNED → COMPLETED)
2. Creating a task (`/task "description"` with full example output)
3. Researching (`/research N [focus]`)
4. Planning (`/plan N`)
5. Implementing (`/implement N`)
6. Finishing (`/todo`)
7. Advanced: `--team`, multi-task syntax, `--remember`
8. Exception states: BLOCKED, PARTIAL, EXPANDED

Cross-references: `commands.md`, `.claude/docs/examples/research-flow-example.md`, `.claude/rules/workflows.md`.

**`docs/agent-system/commands.md`** (NEW) — audience: intermediate reference.
Groups (5):
1. **Lifecycle**: task, research, plan, implement, revise
2. **Maintenance**: review, todo, errors, fix-it, refresh, spawn, merge, meta, tag
3. **Memory**: learn
4. **Documents** (filetypes extension): convert, table, slides, scrape, edit
5. **Research & Grants** (present extension): grant, budget, timeline, funds, talk

Per-command format: one-sentence summary, minimal example, flag list, link to `.claude/commands/{name}.md` or `.claude/docs/guides/user-guide.md` for full reference. **Do not duplicate command specs.**

**`docs/agent-system/context-and-memory.md`** (NEW) — audience: intermediate.
Sections:
1. The two memory layers (project vault `.memory/` vs auto-memory `~/.claude/projects/`)
2. Project memory vault structure, write path, read path
3. Auto-memory (harness-managed, don't touch)
4. `/learn` usage
5. `/research --remember`
6. The five context layers (table)
7. Decision flowchart: where should new content go?

Cross-references: `.memory/README.md`, `.claude/context/architecture/context-layers.md`.

**`docs/agent-system/architecture.md`** (NEW) — audience: advanced/contributor.
Sections:
1. Three-layer pipeline (commands → skills → agents)
2. Checkpoint-based execution (GATE IN → DELEGATE → GATE OUT → COMMIT)
3. Session IDs and traceability
4. State files (TODO.md, state.json, errors.json)
5. Configuration layout tree
6. Extensions system (explains why `<leader>ac` does not apply in Zed)
7. Task routing by task_type

Cross-references: `.claude/README.md`, `.claude/docs/architecture/system-overview.md`, `.claude/docs/guides/component-selection.md`.

#### Required Link Repairs

1. `/home/benjamin/.config/zed/README.md` — 5 references to `docs/agent-system.md` → update to `docs/agent-system/README.md` (or `docs/installation.md` where context is install-related).
2. `/home/benjamin/.config/zed/docs/README.md` — `[Agent System](agent-system.md)` → `[Agent System](agent-system/README.md)` and add `[Installation](installation.md)`.
3. `/home/benjamin/.config/zed/docs/settings.md` — `[Agent system](agent-system.md)` → `[Agent system](agent-system/README.md)`. Also add a new `agent_servers` / claude-acp reference section.
4. `/home/benjamin/.config/zed/docs/office-workflows.md` — `[MCP Tool Setup](agent-system.md#mcp-tool-setup)` → `[MCP Tool Setup](installation.md#install-mcp-tools)`. Fix the second reference too.

#### Out-of-Scope (Record for Follow-up)

- Link-check script for `docs/**/*.md` ↔ `.claude/commands/` (Teammate D, medium-term)
- Back-reference from `.claude/CLAUDE.md` to `docs/README.md` (Teammate D)
- `docs/quick-start.md` for collaborator onboarding (Teammate D)
- Platform siblings for `installation.md` (`installation/macos.md`, `installation/linux.md`) (Teammate D)
- `docs/extensions/` as first-class docs (Teammate D, long-term)

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary structure + file-by-file spec | completed | high |
| B | Diátaxis framing + claude-acp registry/custom | completed | high |
| C | Gaps: Task 5 overlap, link breakage, NixOS reality | completed | high |
| D | Strategic: thin-wrapper, extension growth, discoverability | completed | high |

---

## References

**Prior task artifacts** (highly relevant, must be consulted during implementation):
- `specs/005_update_agent_system_docs/reports/01_agent-system-docs.md` — Task 5 research (decisions D1-D6)
- `specs/005_update_agent_system_docs/plans/01_implementation-plan.md` — Task 5 plan
- `specs/001_configure_zed_with_claude_agent_docs/reports/01_teammate-a-findings.md` — claude-acp findings
- `specs/002_add_claude_acp_keybindings_docs/reports/01_claude-acp-keybindings.md` — web-verified ACP keybindings

**Current documentation (source material)**:
- `docs/agent-system.md` (378 lines — the file being split)
- `docs/README.md`, `docs/keybindings.md`, `docs/settings.md`, `docs/office-workflows.md`

**Internal canonical references (to be linked, not duplicated)**:
- `.claude/README.md` — agent system architecture hub
- `.claude/CLAUDE.md` — command catalog and routing
- `.claude/docs/guides/user-guide.md` — comprehensive user guide
- `.claude/docs/architecture/system-overview.md` — three-layer pipeline
- `.claude/docs/guides/component-selection.md` — command/skill/agent decision tree
- `.claude/rules/{state-management,git-workflow,artifact-formats,workflows}.md`

**External references**:
- https://zed.dev/docs/ai/external-agents — official Zed ACP server docs (registry vs custom)
- https://zed.dev/blog/claude-code-via-acp — Zed's claude-acp announcement
- https://diataxis.fr/ — documentation framework adopted as organizing principle

**Configuration references**:
- `settings.json` lines 136–144 — current claude-acp custom config (NixOS)
- `settings.json` line 119 — `claude-code-extension` in `auto_install_extensions`
- `extensions.json` — active extension list (latex, typst, epidemiology, memory, present, filetypes)
