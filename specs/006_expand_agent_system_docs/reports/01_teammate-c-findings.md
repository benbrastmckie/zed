# Teammate C: Critique

**Task**: 6 - Expand docs/agent-system.md into a docs/ directory and extract installation guide
**Role**: Critic — gaps, blind spots, and unstated assumptions
**Date**: 2026-04-10

---

## Key Findings (gaps, assumptions, risks)

### 1. The task was 80% done by Task 5 — the user may not know this

Task 5 just completed a full rewrite of `docs/agent-system.md` (185 → 378 lines). The summary states: "Added a dedicated Main Workflow section covering /task, /research, /plan, /revise, /implement, /review, and /todo... Added a Command Catalog by Topic section grouping the remaining 17 commands into five topics... Added a dedicated Memory System section... Added an Architecture & Configuration section..."

The user's stated complaints in Task 6's description — "long and densely compressed," "mixes installation with system description" — describe the *pre-Task-5* document. The document the user is reading may already be the rewritten one. This creates a critical ambiguity: is the user reacting to the Task-5 output, or to the old document? If the former, the critique is legitimate; if the latter, the implementer will overengineer a solution for a problem that was already solved.

**Evidence**: Task 5 summary confirms the rewrite explicitly added "Installation, MCP Tool Setup, Zed Agent Panel (including keybindings table) are byte-identical to the original source content" — meaning installation was *preserved* and *not separated*, by design, per the plan. The user is now asking to separate it.

### 2. claude-acp is real, installed, and completely absent from agent-system.md

The user specifically mentions "lacks claude-acp coverage." This is accurate and significant. The package `@zed-industries/claude-agent-acp` is configured in `settings.json` under `agent_servers.claude-acp`. The exact entry:

```json
"agent_servers": {
  "claude-acp": {
    "type": "custom",
    "command": "/home/benjamin/.nix-profile/bin/npx",
    "args": ["@zed-industries/claude-agent-acp", "--serve"],
    "env": {}
  }
}
```

The `keybindings.md` file also documents it under "External agents (Claude ACP)" with the action `agent::NewExternalAgentThread` and `agent_name: "claude-acp"`. However, `docs/agent-system.md` has **zero occurrences** of "acp", "claude-acp", or "@zed-industries". This is a real gap, not a perception error.

The package name is `@zed-industries/claude-agent-acp` (NOT `claude-acp`, NOT `claude-code-acp`, NOT `@zed-industries/claude-code-acp`). The agent_name key used in Zed's keymap is `"claude-acp"`. The user's phrase "claude-acp" correctly describes the Zed agent_server entry name, not the npm package name.

### 3. "Directory expansion" is not well-defined — there are three plausible interpretations

The task says "expanded into a directory containing multiple clear, educational documents — one file per natural grouping." But the current `docs/` directory already has five files:
- `agent-system.md`
- `keybindings.md`
- `office-workflows.md`
- `settings.md`
- `README.md`

Three interpretations exist:
- **A**: Create `docs/agent-system/` as a subdirectory and split `agent-system.md` into files inside it (e.g., `docs/agent-system/commands.md`, `docs/agent-system/memory.md`).
- **B**: Create new peer files in `docs/` (e.g., `docs/commands.md`, `docs/memory.md`, `docs/installation.md`) and reduce `agent-system.md` to a landing page.
- **C**: Delete `agent-system.md` entirely and distribute its content across new peer files in `docs/`.

Each interpretation has different implications for existing links. The README.md links to `docs/agent-system.md` five times. `settings.md` and `office-workflows.md` also link to it. A directory-based approach (A) would break all these links unless `agent-system.md` is kept as a redirect or index file.

### 4. Link breakage risk is high and understated in the task description

The following files contain hard links to `docs/agent-system.md`:

- `/home/benjamin/.config/zed/README.md` — 5 references including: "For the full installation walkthrough... see docs/agent-system.md", "│   ├── agent-system.md" in the directory tree, and in a table row
- `/home/benjamin/.config/zed/docs/README.md` — "- [Agent System](agent-system.md)"
- `/home/benjamin/.config/zed/docs/settings.md` — "- [Agent system](agent-system.md)"
- `/home/benjamin/.config/zed/docs/office-workflows.md` — "See [MCP Tool Setup](agent-system.md#mcp-tool-setup)" and another reference

In particular, `office-workflows.md` uses a **fragment link** (`agent-system.md#mcp-tool-setup`). If MCP Tool Setup moves to `installation.md`, this fragment link silently breaks. The user has not acknowledged this maintenance cost.

### 5. "Each command should be presented with a brief explanation... usage example... then advanced details" — this conflicts with the existing .claude/docs/guides/user-guide.md

The task description asks for command-level educational prose for all 24 commands. But `docs/agent-system.md` currently links to `.claude/docs/guides/user-guide.md` as "the comprehensive command reference with examples and troubleshooting." If the new `docs/` files replicate that content, there will be two command references — one user-facing in `docs/`, one internal in `.claude/docs/`. These will diverge over time.

The current design intent (established in Task 5's research report, Decision D6) was: "Link to `.claude/CLAUDE.md` as the canonical command reference for power users, while keeping `docs/agent-system.md` focused on orientation and common workflows." The user's Task 6 request reverses this decision without acknowledging it.

### 6. "One file per natural grouping" — the groupings are not as obvious as the task implies

The current agent-system.md already has a topic-based grouping (established by Task 5):
1. Installation
2. Two AI Systems
3. Claude Code: Main Workflow
4. Command Catalog by Topic (5 sub-groups)
5. Memory System
6. Architecture & Configuration
7. MCP Tool Setup
8. Known Limitations
9. Related Documentation

"One file per natural grouping" could mean 9 files, 5 files, or 3 files depending on interpretation. The task does not say.

### 7. The .claude/docs/ vs docs/ boundary is undefined

The task says nothing about the relationship between:
- `docs/` — user-facing documentation (keybindings, office workflows, settings, agent system)
- `.claude/docs/` — internal agent system documentation (guides, examples, standards, architecture)

Does the user want the new `docs/` files to *replace* `.claude/docs/guides/`? Or to be a friendlier façade over them? Or to coexist as independent layers? This distinction matters enormously for what content goes where and what gets duplicated.

### 8. The task assumes the user knows what "install Zed via Homebrew on macOS" means in context

The installation section currently in `agent-system.md` (lines 5-37) covers:
1. Install Homebrew
2. Install Zed via `brew install --cask zed`
3. "See MCP Tool Setup below"

The task says this should become `docs/installation.md` for "macOS Homebrew." But the actual machine is **NixOS Linux** (`settings.json` comment: "Platform: NixOS Linux (binary: zeditor)"). The current installation section is aspirational documentation for a fresh macOS user, not a description of the actual install. An `installation.md` that says "brew install --cask zed" will be incorrect for the actual user's machine and potentially confusing.

### 9. Over-engineering risk: more files means more maintenance surface

The current `docs/` directory has 5 files and is already internally cross-linked. Splitting into 9+ files will require:
- Cross-links between all new files
- Updates to `README.md` (directory tree and navigation table)
- Fragment anchors that may become stale
- A reader who now must navigate multiple files to understand one workflow

The task's user goal is "accessible to new users." A single well-organized 400-line file may serve new users better than 6-9 files they have to navigate.

---

## Unanswered Questions

1. **Has the user read the Task 5 output?** If `docs/agent-system.md` (378 lines, rewritten 2026-04-10) is what prompted Task 6, the implementer needs to know which specific sections the user finds "long and densely compressed." If the user was reacting to the pre-Task-5 document, the problem statement changes significantly.

2. **What exactly is "claude-acp coverage"?** Installation instructions for the npm package? Explanation of what ACP is (Agent Communication Protocol)? A keybinding doc? A description of how it loads the slash commands? The user's sentence is: "it does not cover claude-acp, which is what the user actually runs in Zed and which successfully loads all agent system commands, skills, and context." This implies explaining the ACP mechanism, not just adding a setup step.

3. **Directory structure: subdirectory or peer files?** Does `docs/agent-system/` replace `docs/agent-system.md`, or do new peer files appear alongside it?

4. **What happens to the existing `docs/agent-system.md` links?** 9 links across 5 files point to it, including fragment links. Is the implementer expected to update all of them?

5. **Is `docs/installation.md` macOS-only?** The machine is NixOS Linux. Does the user want macOS-centric docs (for the "collaborator" the auto-memory mentions?) or machine-accurate docs?

6. **Does the new `docs/` replace `.claude/docs/guides/`?** Or supplement it? The answer determines whether command documentation gets duplicated.

7. **How many files is the right number?** 3? 5? 9? The task says "one per natural grouping" but does not define the groupings.

8. **Will the ACP section cover setup, usage, or both?** Currently `keybindings.md` has a minimal ACP section (6 lines). Should `agent-system.md` (or a new file) expand this? Should `keybindings.md` be updated to cross-reference?

---

## Evidence/Examples

**claude-acp confirmed installed** (`settings.json` lines 136-144):
```json
"agent_servers": {
  "claude-acp": {
    "type": "custom",
    "command": "/home/benjamin/.nix-profile/bin/npx",
    "args": ["@zed-industries/claude-agent-acp", "--serve"],
```

**Package name**: `@zed-industries/claude-agent-acp` (not `claude-code-acp`)

**Zero ACP coverage in current agent-system.md**: grep of "acp", "claude-acp", "@zed-industries" returns no matches.

**Fragment link at risk** (`docs/office-workflows.md` line referencing):
```
See [MCP Tool Setup](agent-system.md#mcp-tool-setup) for the exact commands.
```

**Task 5 decision (from research report Decision D5)**: "Preserve the installation and MCP tool setup sections verbatim; they are accurate and load-bearing for a fresh reader." — The implementer explicitly chose to keep installation *in* agent-system.md. Task 6 reverses this without acknowledging D5.

**Current docs/ links** (`README.md` lines): 5 references to `docs/agent-system.md` including the directory tree entry `│   ├── agent-system.md     # AI systems overview + installation + MCP setup`.

**NixOS reality** (`settings.json` line 3): `// Platform: NixOS Linux (binary: zeditor)` — the Homebrew install steps are aspirational, not descriptive.

**keybindings.md ACP section** (lines 143-155): Already documents Claude ACP with the keymap JSON snippet, but agent-system.md makes no mention of this feature at all.

---

## Confidence Level: high

The factual findings (zero ACP coverage, link targets, package name, platform discrepancy, Task 5 context) are all directly verifiable from the codebase. The interpretive risks (over-engineering, user intent, boundary questions) are flagged as questions, not assertions.
