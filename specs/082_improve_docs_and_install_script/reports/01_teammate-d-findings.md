# Teammate D (Horizons) Findings: Strategic Direction for Documentation and Installation

**Task**: #82 — Improve documentation and installation script for dual agent systems
**Date**: 2026-05-11
**Angle**: Long-term strategic alignment, installation philosophy, documentation architecture

## Key Findings

### 1. OpenCode Is Invisible in Current Documentation

The README.md and docs/ directory mention Claude Code 30+ times but reference OpenCode exactly once (a passing mention of shared memory in `context-and-memory.md`). Yet `.opencode/` is a fully parallel agent system with 30 agents, 38 skills, 25 commands, and all 9 extensions installed. This is a significant documentation gap — a major feature of the repo is entirely undocumented for end users.

### 2. Extensions Are Sourced from a Shared Upstream

Both `.claude/extensions.json` and `.opencode/extensions.json` track the same 9 extensions (core, epidemiology, filetypes, latex, memory, present, python, slidev, typst), all sourced from `~/.config/nvim/.claude/extensions/` and `~/.config/nvim/.opencode/extensions/` respectively. The upstream nvim repo holds 17 extensions total (including lean, z3, formal, nix, web, founder, nvim) — the Zed repo only installs a subset. This reveals a clear pattern: extensions are portable building blocks designed for cross-project reuse, with per-project cherry-picking.

### 3. The Extension Architecture Is Already Platform-Portable

OpenCode manifests use an identical JSON schema to Claude Code extensions but with different target paths (`.opencode/agent/subagents/` vs `.claude/agents/`, `.opencode/skills/` vs `.claude/skills/`). The `merge_targets` field in each manifest specifies platform-specific merge targets. This means extensions are structurally portable — the same logical extension maps to different directory layouts per platform. Documentation should explain this design, as it's a key architectural insight.

### 4. Installation Script Doesn't Know About Agent Systems

The current `install.sh` wizard handles 6 groups: base, shell-tools, python, r, typesetting, mcp-servers. None of these groups install or configure agent systems. Claude Code CLI is bundled into the "base" group alongside Homebrew and Node.js, but OpenCode has no installation path at all. The install script also doesn't handle:
- Extension loading/syncing from upstream
- Agent system verification (are all expected skills/commands present?)
- OpenCode binary installation or configuration

### 5. Shared State Creates Coupling

Both agent systems share `specs/` (TODO.md, state.json, task directories) and `.memory/`. This means:
- Tasks created by one system are visible to the other
- Memory learned in one system is retrieved by the other
- But task directory prefixes differ: Claude Code uses `specs/{NNN}_` while OpenCode uses `specs/OC_{NNN}_`

This is an important architectural detail that documentation must explain clearly.

## Strategic Assessment

### Project Trajectory

The roadmap is empty, but recent task history (65-82) reveals a clear direction: the project is actively building out the OpenCode parallel system and ensuring feature parity with Claude Code. Tasks 79-81 (xlsx skill) explicitly worked on both systems. Task 65 stripped nvim references. Task 66 (still open) is about updating docs to reflect refactoring.

**This task (82) is a natural convergence point** — it unifies the documentation debt from tasks 65/66 with the new OpenCode reality from tasks 79-81.

### Should Documentation Treat Systems as Equal Peers?

**Recommendation: Equal-but-distinct peers.** Both systems share the same extension architecture, same task management, and same memory vault. They differ in:
- Access method (Claude Code via terminal/Ctrl+Shift+A vs OpenCode via its own interface)
- Configuration layout (`.claude/` vs `.opencode/`)  
- Model availability and pricing

Treating them as peers reflects reality and future-proofs documentation for additional agent platforms.

## Installation Approach Recommendation

### Recommended: Layered Install Script

The install script should add a new top-level choice before the existing 6 groups:

```
Agent System Selection
  [1] Claude Code only (requires Anthropic API key)
  [2] OpenCode only (requires configured OpenCode binary)
  [3] Both (recommended for full experience)
  [4] Neither (Zed editor only, no agent system)
```

**Implementation approach**: Add a new `install-agent-systems.sh` group script that:
1. Installs Claude Code CLI (currently in base group — factor it out)
2. Installs OpenCode binary (new)
3. Verifies extension state (all 9 extensions loaded)
4. Sets up MCP servers for the selected system(s)
5. Validates shared state directories (specs/, .memory/)

**Do NOT make it a separate script.** Keep it within the existing wizard flow so users get a single, coherent installation experience. The existing 6 groups should remain but Claude Code CLI should move from "base" to the new "agent-systems" group.

### Alternative: Nix Flake

The repo doesn't use Nix, and adding it would be a significant complexity increase. Not recommended for this task.

## Documentation Architecture Recommendation

### Current Structure (adequate, needs expansion)

```
docs/
├── general/          # Installation, keybindings, settings
├── agent-system/     # AI systems overview (currently Claude Code only)
├── toolchain/        # Python, R, typesetting setup
└── workflows/        # End-to-end usage guides
```

### Recommended Changes

1. **Rename `docs/agent-system/` to stay but expand scope**: Add an OpenCode section alongside the existing Claude Code content. Don't create separate `docs/claude-code/` and `docs/opencode/` directories — the systems share too much for separate documentation to avoid duplication.

2. **Add `docs/agent-system/opencode.md`**: Parallel to `zed-agent-panel.md`, explaining how to access and use OpenCode within this workspace.

3. **Add `docs/agent-system/extensions.md`**: A single page documenting all 9 extensions with what each provides (commands, agents, skills), shared across both systems. This is the highest-value new page because it answers "what can I do?" in one place.

4. **Update `docs/agent-system/architecture.md`**: Add the dual-system architecture diagram showing shared specs/ and .memory/ with separate .claude/ and .opencode/ trees.

5. **Update README.md**: Add an "Agent Systems" section acknowledging both Claude Code and OpenCode, with a comparison table and links to relevant docs.

### Documentation Scaling Strategy

With 9 extensions now and the upstream holding 17, a per-extension documentation page would create maintenance burden. Instead:
- One `extensions.md` page with a table (extension name, commands, agents, what it does)
- Extension-specific details in workflow pages (e.g., `/epi` details in `epidemiology-analysis.md`)
- Link to extension manifests for the complete technical reference

## Opportunities and Risks

### Opportunities

1. **Task 66 overlap**: Task 66 ("Update docs/ and README.md to reflect .claude/ refactoring") is marked [RESEARCHED] and covers overlapping ground. This task should subsume or reference task 66's research report.

2. **Extension catalog as a selling point**: A clear extension catalog would help new users understand the value proposition — "this isn't just an editor config, it's an agent-powered development environment."

3. **Installation wizard as onboarding**: The install wizard is the first user touchpoint. Making agent system selection a first-class choice communicates that this is a dual-agent workspace, not just a Claude Code config.

4. **Cross-system task visibility**: Both systems can see each other's tasks. This is a unique feature worth highlighting — users can start research in one system and continue implementation in the other.

### Risks

1. **OpenCode maturity**: If OpenCode support is still evolving, documenting it as an equal peer could set expectations too high. The docs should note any known limitations.

2. **Maintenance burden**: Dual-system docs must stay synchronized. Any command or extension change needs updating in two places. Mitigate by keeping the documentation shared wherever possible.

3. **Install script complexity**: Adding agent system selection to the wizard increases complexity. Keep it simple — a single prompt with 4 choices, then dispatch to the appropriate sub-installer.

4. **Extension source dependency**: Extensions are sourced from `~/.config/nvim/`. If a user doesn't have the nvim config, extensions can't be installed. The install script should either bundle extensions or handle this dependency.

## Confidence Level

**High** on the documentation architecture recommendations — the current gap is clear and the proposed structure follows established patterns.

**Medium** on the installation approach — the factoring of Claude Code CLI out of the "base" group needs careful testing, and OpenCode installation requirements need further research.

**Medium** on the extension portability assessment — the manifest schema is consistent, but I haven't verified that all 9 extensions function identically across both systems (there may be behavioral differences).
