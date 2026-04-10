# Research Report: Task #11

**Task**: 11 - Fix Zed ACP subagent invocation to match Neovim Claude Code plugin behavior
**Date**: 2026-04-10
**Mode**: Team Research (4 teammates)
**Session**: sess_1775856824_ed8b3b

---

## Summary

The Zed ACP adapter (`@agentclientprotocol/claude-agent-acp`) runs the Claude Agent SDK with a bundled CLI binary — NOT the user's installed `claude` CLI. By default the SDK runs in **isolation mode**: no filesystem settings loaded (`settingSources` unset), and `Skill`/`Agent` tools not included in `allowedTools`. This causes the model to execute all work inline rather than delegating to skills and subagents. The empty `"env": {}` in settings.json compounds the problem by forwarding no environment variables.

The fix is a configuration change: either switch to `type: "registry"` (Zed-managed adapter with correct defaults) or set `CLAUDE_CODE_EXECUTABLE` to the user's installed `claude` binary. Additionally, team mode (`--team`) is a **hard SDK constraint** — sub-subagents cannot spawn their own subagents, making Tier 3 team skills (skill-team-research, skill-team-plan, skill-team-implement) structurally incompatible with ACP today.

## Key Findings

### 1. Root Cause: SDK Isolation Mode (High Confidence)

The `@agentclientprotocol/claude-agent-acp@0.26.0` depends on `@anthropic-ai/claude-agent-sdk@0.2.96`, which ships a **bundled** `cli.js` — not the user's `~/.nix-profile/bin/claude`. The SDK starts in isolation mode by default:

- No `settingSources` → Skills not loaded from filesystem
- `Skill` and `Agent` not in `allowedTools` → model cannot invoke them
- No `CLAUDE_CODE_EXECUTABLE` → uses bundled CLI, not user's binary

The Neovim Claude Code plugin runs the actual `claude` CLI binary directly, which natively supports all tools.

### 2. The Model Executed Inline — No Delegation Attempted (Certain)

Analysis of all 1,757 lines of `output/test.md` confirms:
- Tool calls used: Bash (jq, ls, grep, date), Read, Write, Edit, git commit
- **Zero** `Skill` or `Task`/`Agent` tool calls
- **Zero** error messages about unavailable tools
- The model replicated skill-implementer + general-implementation-agent behavior inline — reading the plan, updating status, creating all 5 files, committing

The absence of errors is consistent with the tools simply not being in the available tool set (the model never considers tools it doesn't know about).

### 3. `CLAUDE_CODE_EXECUTABLE` Is the Key Configuration Lever (High Confidence)

The ACP adapter checks this env var first:
```js
process.env.CLAUDE_CODE_EXECUTABLE
    ? { pathToClaudeCodeExecutable: process.env.CLAUDE_CODE_EXECUTABLE }
    : isStaticBinary() ? { pathToClaudeCodeExecutable: await claudeCliPath() } : {}
```

Setting `CLAUDE_CODE_EXECUTABLE=/home/benjamin/.nix-profile/bin/claude` in the Zed `env:` block redirects the adapter to the user's installed binary with full tool support.

### 4. Subagent Activity Is Invisible in Zed UI (Separate Issue)

Zed's thread view has `if step.kind.is_subagent() { continue; }` — it literally skips rendering subagent activity ([Discussion #49452](https://github.com/zed-industries/zed/discussions/49452)). Even after fixing tool availability, subagent work will appear as a "frozen stream" in the panel. The data flows through; it just isn't shown.

### 5. Team Mode Is a Hard SDK Constraint (High Confidence)

Official SDK docs: "Subagents cannot spawn their own subagents. Don't include `Agent` in a subagent's `tools` array."

The team skills (skill-team-research/plan/implement) use a two-level spawn chain (Skill → Agent → sub-Agent). This is structurally incompatible with the SDK's single-level subagent limit. Team mode is CLI-only.

### 6. Model Mismatch May Compound the Issue (Medium Confidence)

Zed settings use `claude-sonnet-4-20250514` as default. Command frontmatter declares `model: opus`. Whether the ACP adapter respects frontmatter `model:` overrides is unconfirmed. Sonnet may be less inclined to delegate than opus.

### 7. Task 9 Still Completed Correctly (Context)

Despite the architectural issue, task 9 was implemented correctly — all files created, status updated, committed. The problem is architectural (no subagent isolation, no opus routing, no parallel execution) rather than functional for simple tasks.

## Synthesis

### Conflicts Resolved

| Conflict | Teammate A/D | Teammate B | Resolution |
|----------|-------------|------------|------------|
| "Subagents don't work" vs "Subagents work but aren't rendered" | Tools unavailable in SDK isolation | Subagent data flows but skip-rendered | **Both are true at different layers.** Tools are unavailable in current config (primary issue). Even after fixing, rendering is a separate Zed UI bug. |
| "Definitely fixable" vs "Root cause ambiguous" | Config change will fix it | Cannot distinguish tool-absent vs model-choice from test.md alone | **Tool absence is the more parsimonious explanation.** No error messages + zero delegation attempts + known SDK isolation defaults = tools not available. |

### Gaps Identified

1. **Unverified**: Whether the `type: "registry"` adapter correctly sets `settingSources` and includes `Skill`/`Agent` in `allowedTools` — needs testing
2. **Unverified**: Whether the user's `claude` binary version supports `Skill` tool (check `claude --version`)
3. **Unknown**: Whether ACP adapter respects frontmatter `model:` overrides
4. **Rendering gap**: No fix available for subagent activity visibility in Zed panel

### Recommendations

#### Immediate Fix (Try in Order)

**Option A — Switch to registry type + set CLAUDE_CODE_EXECUTABLE**:
```json
"agent_servers": {
  "claude-acp": {
    "type": "registry",
    "default_config_options": {"mode": "bypassPermissions"},
    "env": {
      "CLAUDE_CODE_EXECUTABLE": "/home/benjamin/.nix-profile/bin/claude",
      "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
    }
  }
}
```

**Option B — Keep custom type, add env vars**:
```json
"agent_servers": {
  "claude-acp": {
    "type": "custom",
    "command": "/home/benjamin/.nix-profile/bin/npx",
    "args": ["@agentclientprotocol/claude-agent-acp", "--serve"],
    "default_config_options": {"mode": "bypassPermissions"},
    "env": {
      "CLAUDE_CODE_EXECUTABLE": "/home/benjamin/.nix-profile/bin/claude",
      "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
      "HOME": "/home/benjamin"
    }
  }
}
```

**Option C — Terminal task for full CLI parity** (if panel approach doesn't work):
```json
// .zed/tasks.json
[{
  "label": "Claude Code",
  "command": "/home/benjamin/.nix-profile/bin/claude",
  "args": ["--dangerously-skip-permissions"],
  "use_new_terminal": true,
  "reveal": "always"
}]
```
Trade-off: Full feature parity (including team mode) but loses Zed inline diff review UI.

#### Architectural Improvements (Future Tasks)

1. **CHECKPOINT 0**: Add environment detection at skill entry — probe for Agent/Skill tool availability before attempting delegation
2. **`/doctor` command**: Diagnose runtime environment (tools available, settings sources loaded, CLI version, ACP vs CLI mode)
3. **Skill tiering**: Classify skills by orchestration depth:
   - Tier 1 (no subagents): ACP-compatible now — skill-todo, skill-refresh, skill-status-sync
   - Tier 2 (single spawn): ACP-compatible with correct config — skill-researcher, skill-planner, skill-implementer
   - Tier 3 (team/multi-spawn): CLI-only — skill-team-research, skill-team-plan, skill-team-implement
4. **Graceful degradation**: Skills detect missing Agent tool and run agent prompt inline instead of failing silently
5. **`requires-tools` frontmatter**: Declare orchestration requirements in skill metadata

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary approach (root cause + fix) | completed | high |
| B | Alternative approaches + prior art | completed | high |
| C | Critic (gap analysis + assumptions) | completed | high |
| D | Strategic horizons + architecture | completed | high |

## References

- [Agent SDK Subagents Docs](https://code.claude.com/docs/en/agent-sdk/subagents)
- [Agent SDK Skills Docs](https://code.claude.com/docs/en/agent-sdk/skills)
- [Zed External Agents Docs](https://zed.dev/docs/ai/external-agents)
- [Zed ACP Blog](https://zed.dev/blog/claude-code-via-acp)
- [Zed Roadmap](https://zed.dev/roadmap) — Multi-Agent Collaboration: In Progress
- [zed-industries/claude-agent-acp#305](https://github.com/zed-industries/claude-agent-acp/issues/305) — subagent tool access bug
- [Zed Discussion #49452](https://github.com/zed-industries/zed/discussions/49452) — subagent visibility
- [benswift.me: Running Claude Code within Zed](https://benswift.me/blog/2025/07/23/running-claude-code-within-zed/)
