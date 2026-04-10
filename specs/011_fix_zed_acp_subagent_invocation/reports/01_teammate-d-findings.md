# Research Report: Task #11 — Teammate D (Horizons/Strategic)

**Task**: 11 - Fix Zed ACP subagent invocation to match Neovim Claude Code plugin behavior
**Teammate**: D — Horizons/Strategic
**Started**: 2026-04-10T00:00:00Z
**Completed**: 2026-04-10T01:00:00Z
**Effort**: Medium (web research + codebase audit)
**Focus**: Long-term editor-agnostic agent system design
**Sources**: Zed roadmap, Claude Agent SDK docs, ACP spec, github.com/agentclientprotocol/claude-agent-acp, github.com/zed-industries/zed discussions, Piebald-AI system prompt dumps

---

## Key Findings

### 1. The Task Tool IS Available in Zed ACP — But Requires Explicit Configuration

The Claude Agent SDK (which powers `@agentclientprotocol/claude-agent-acp`) DOES support the `Agent` tool (formerly named `Task`) for spawning subagents. The critical requirements that the current claude-agent-acp adapter likely omits:

- `allowedTools` must explicitly include `"Agent"` (or `"Task"` for SDK < v2.1.63)
- `settingSources: ["user", "project"]` must be set to load Skills from filesystem
- `allowedTools` must include `"Skill"` for skills to be discovered and invoked

Without these three settings, subagent spawning and skill invocation silently fail — Claude appears to work but its orchestration tools are neutered.

### 2. The "Subagent Tool Silently Fails" Bug Was a Real Issue — Now Fixed

GitHub issue zed-industries/claude-agent-acp#305 ("Task subagent cannot execute tools — Write/Edit operations silently fail") was confirmed and closed via PR #316. The fix switched from custom MCP server integrations (which "don't play nicely" with subagents) to **built-in Claude Code tools**. This fix was released and is now in the current ACP adapter. If the user is running an outdated adapter version, updating resolves this.

### 3. The Skill Tool IS Supported in SDK Mode — With a Critical Caveat

Per official SDK documentation, the `Skill` tool IS available when using the Claude Agent SDK. However:
- The `allowed-tools` frontmatter in `SKILL.md` files is **ignored** in SDK mode
- Tool access is controlled entirely by the caller's `allowedTools` option
- Skills are only loaded if `settingSources: ["user", "project"]` is set

**Impact on this project**: 26 of 32 skills have `allowed-tools: Task` in their frontmatter. In SDK/ACP mode this declaration is inert — the `Agent` tool must be in the adapter's `allowedTools`. If the adapter does not include it, all orchestrating skills appear to run but spawn no subagents.

### 4. Subagents Cannot Spawn Sub-Subagents (Critical Architecture Constraint)

The SDK documentation states explicitly: **"Subagents cannot spawn their own subagents. Don't include `Agent` in a subagent's `tools` array."**

This has profound implications for this project's architecture. The current system uses a two-level delegation chain:
- Skill invoked (via `Skill` tool) → Skill invokes Task tool → Task spawns agent → Agent does work

In SDK/ACP mode, the first spawn works, but any agent spawned by a skill cannot further delegate. Skills like `skill-team-research` and `skill-team-implement` that spawn multiple parallel teammates will fail at the second delegation level.

### 5. ACP Is Converging With the A2A Standard Under Linux Foundation

The original ACP (Agent Client Protocol) from Zed has been contributed to the Linux Foundation and merged conceptually with the A2A (Agent-to-Agent) protocol. The `@agentclientprotocol/claude-agent-acp` package moved from `@zed-industries/claude-agent-acp` to the ACP org. Zed's current roadmap (Spring 2026) marks "Multi-Agent Collaboration" as **In Progress** and "Subagent Support" as **Done**.

Zed 1.0 (Spring 2026) will ship with multi-agent support. JetBrains has launched an ACP Agent Registry. The ecosystem is consolidating, not fragmenting.

### 6. Claude Code Native Integration for Zed Is Not Planned by Anthropic

GitHub discussion zed-industries/zed#31234 documents a community request for Claude Code integration in Zed equivalent to JetBrains/VS Code. The ACPX article confirms: "Anthropic closed the feature request for native ACP support in Claude Code as **NOT_PLANNED**." Zed integration will remain ACP-based (via the SDK adapter), not a first-party Claude Code CLI plugin.

### 7. Skills That Do NOT Require Subagent Spawning Work Today

Auditing the local `.claude/skills/` directory: 6 of 32 skills do NOT use the `Task` tool and are immediately compatible with ACP as-is:

| Skill | Allowed Tools |
|-------|--------------|
| skill-fix-it | Bash, Grep, Read, Write, Edit, AskUserQuestion |
| skill-refresh | Bash, AskUserQuestion |
| skill-todo | Bash, Edit, Read, Write, Grep, AskUserQuestion |
| skill-memory | Bash, Grep, Read, Write, Edit, AskUserQuestion |
| skill-status-sync | Bash, Edit, Read |
| skill-git-workflow | Bash(git:*) |

The other 26 skills require `Task`/`Agent` tool access — they work only if the ACP adapter includes `Agent` in `allowedTools`.

---

## Strategic Recommendations

### Recommendation 1: Fix the Adapter Configuration First (Low-Cost, High-Impact)

Before any architectural redesign, verify and update the `claude-agent-acp` adapter configuration to include:

```json
{
  "allowedTools": ["Agent", "Skill", "Read", "Write", "Edit", "Bash", "Glob", "Grep", "WebSearch", "WebFetch", "AskUserQuestion", "TodoWrite"],
  "settingSources": ["user", "project"]
}
```

This is the most likely cause of the current breakage and may be the entire fix. Update to the latest adapter version (post-PR #316) to also resolve the Write/Edit silently failing bug.

### Recommendation 2: Add a CHECKPOINT 0 Capability Detection Pattern

Add an environment probe at the start of orchestrating skills. The pattern: before invoking `Skill` or `Task`, check if those tools are available by testing with a trivial call or by reading a well-known environment indicator. Suggested approach:

```markdown
## CHECKPOINT 0: Environment Detection

Before routing, determine available orchestration tools:
1. Check if `$CLAUDE_AGENT_SDK` env var is set (ACP/SDK mode indicator)
2. Or attempt a minimal Skill invocation and observe failure
3. If orchestration tools unavailable: run skill content inline instead of delegating

Set `$ENV_MODE = "cli" | "sdk" | "acp"` for downstream decision-making.
```

This aligns with the project's existing GATE IN / GATE OUT checkpoint pattern and would add a GATE 0 before the standard flow.

### Recommendation 3: Implement Graceful Inline Degradation for Tier-1 Skills

For the most-used skills (skill-researcher, skill-planner, skill-implementer), add an inline fallback path that activates when subagent spawning fails or is unavailable:

```markdown
## Degraded Mode (no Agent tool available)

If Agent tool is not available:
- Do NOT delegate to a subagent
- Execute the agent's full prompt inline within this context
- Use the agent's system prompt as section guidance
- Write outputs to the same artifact paths
- Note "(inline execution - no subagent)" in metadata
```

This makes the system functional in ACP mode for common single-agent workflows, even though parallel team-mode operations would still be unavailable.

### Recommendation 4: Declare Tool Requirements in Skill Frontmatter

Extend the `SKILL.md` frontmatter schema with a `requires-tools` field (separate from `allowed-tools`) that declares what orchestration capabilities a skill needs to operate at full capacity:

```yaml
---
name: skill-researcher
requires-tools: [Agent, Skill]          # full orchestration required
degraded-mode: inline-research-agent    # fallback if requirements unmet
allowed-tools: Task, Bash, Edit, Read, Write
---
```

This lets the CHECKPOINT 0 detection logic make fast/fail decisions and tell the user precisely what is missing rather than silently degrading.

### Recommendation 5: Add a `/doctor` Command

Create a `.claude/commands/doctor.md` that diagnoses the runtime environment:

**What it checks**:
1. Available tools (can Agent tool be invoked? Skill tool? AskUserQuestion?)
2. Settings sources loaded (is `.claude/skills/` being discovered?)
3. Skills count (how many skills are visible to the current session?)
4. ACP vs CLI mode detection
5. MCP servers connected
6. Git repo health (state.json, TODO.md in sync?)
7. Extension loading status

**Why this matters**: The collaborator sharing Zed may not know why commands silently fail. A `/doctor` output is the fastest path to diagnosing environment issues and is also a good onboarding tool.

### Recommendation 6: Tier the Skill System by Orchestration Depth

Formally classify skills into three tiers for the roadmap:

| Tier | Orchestration | ACP-compatible today? | Examples |
|------|--------------|----------------------|---------|
| Tier 1 | No subagents | Yes | skill-todo, skill-status-sync, skill-refresh, skill-git-workflow |
| Tier 2 | Single subagent spawn | Yes (with correct adapter config) | skill-researcher, skill-planner, skill-implementer |
| Tier 3 | Multi-subagent / team | No (SDK constraint: no sub-subagents) | skill-team-research, skill-team-plan, skill-team-implement |

This tiering informs which commands to advertise as "Zed-compatible" and which to mark as "CLI-only" in documentation.

### Recommendation 7: Consider ACP Protocol Extension for Team Mode

The ACP ecosystem is actively evolving (Zed 1.0 roadmap: "Multi-Agent Collaboration — In Progress"). The team-mode skills (Tier 3) could be adapted to use ACP's own parallel agent mechanism rather than Claude Code's internal `TeamCreate` tool. This would be a medium-term adaptation (6-12 months) as Zed's multi-agent support stabilizes.

---

## Evidence and URLs

| Finding | Source |
|---------|--------|
| SDK supports Agent tool for subagents; requires explicit allowedTools | [Agent SDK Subagents Docs](https://code.claude.com/docs/en/agent-sdk/subagents) |
| Skill tool supported in SDK; settingSources required; allowed-tools frontmatter ignored | [Agent SDK Skills Docs](https://code.claude.com/docs/en/agent-sdk/skills) |
| Subagents cannot spawn sub-subagents (hard SDK constraint) | [Agent SDK Subagents Docs](https://code.claude.com/docs/en/agent-sdk/subagents) — "Subagents cannot spawn their own subagents" |
| Write/Edit silently failing bug — fixed in PR #316 | [GitHub Issue #305](https://github.com/zed-industries/claude-agent-acp/issues/305) |
| Zed 1.0 roadmap: Multi-Agent Collaboration In Progress; Subagent Support Done | [Zed Roadmap](https://zed.dev/roadmap) |
| ACP Claude Code beta — "SDK to parity" request to Anthropic | [Zed Blog: Claude Code via ACP](https://zed.dev/blog/claude-code-via-acp) |
| Anthropic closed native ACP support as NOT_PLANNED | [ACPX Blog](https://casys.ai/blog/acpx-multi-agent-orchestration) |
| ACP Agent Registry launched with JetBrains | [JetBrains AI Blog](https://blog.jetbrains.com/ai/2026/01/acp-agent-registry/) |
| ACP merged with A2A under Linux Foundation | [goose ACP intro](https://block.github.io/goose/blog/2025/10/24/intro-to-agent-client-protocol-acp/) |
| claude-agent-acp moved from zed-industries to agentclientprotocol org | [GitHub: agentclientprotocol/claude-agent-acp](https://github.com/agentclientprotocol/claude-agent-acp) |
| Subagent activity invisible in Zed agent panel (visibility gap) | [Zed Discussion #49452](https://github.com/zed-industries/zed/discussions/49452) |
| Task tool renamed to Agent in Claude Code v2.1.63 | [Agent SDK Subagents Docs](https://code.claude.com/docs/en/agent-sdk/subagents) — "tool name was renamed from Task to Agent" |

---

## Confidence Level

**High confidence** (directly from official docs and confirmed GitHub issues):
- Skills ARE loadable in SDK/ACP mode with correct configuration
- Agent/Task tool IS available but must be in allowedTools
- Sub-subagent spawning is a hard constraint (cannot be worked around)
- The Write/Edit silently failing bug was real and fixed
- allowed-tools frontmatter is ignored in SDK mode

**Medium confidence** (inferred from adapter architecture):
- The current adapter likely lacks Agent/Skill in allowedTools (not directly verified against deployed adapter config)
- CHECKPOINT 0 capability detection would work as described (pattern is implementable, not yet proven in this codebase)

**Lower confidence** (strategic/speculative):
- Timeline for ACP multi-agent team support in Zed (roadmap says "In Progress" but no date)
- Whether A2A/Linux Foundation merger will introduce backward-incompatible changes to ACP

---

## Summary for Synthesizer

The core problem is almost certainly a configuration issue in the ACP adapter, not a fundamental protocol limitation. The SDK supports Agent, Skill, and Task tools — they just require explicit opt-in. The immediate fix is updating the adapter configuration. The strategic constraints are: (1) sub-subagent spawning is a hard SDK limit that makes Tier 3 team-mode skills incompatible with ACP today, (2) Anthropic will not build native ACP into Claude Code CLI, so ACP mode will always be the SDK path in Zed, and (3) the ecosystem is consolidating toward ACP/A2A as the standard. The recommended architecture additions — CHECKPOINT 0, `/doctor` command, skill tiering, and `requires-tools` declarations — provide a durable editor-agnostic foundation as the ACP ecosystem matures.
