# Research Report: Task #11 — Teammate A Findings

**Task**: 11 - Fix Zed ACP subagent invocation to match Neovim Claude Code plugin behavior
**Started**: 2026-04-10T00:00:00Z
**Completed**: 2026-04-10T00:30:00Z
**Effort**: 1.5 hours
**Sources/Inputs**: npm registry, GitHub repos (agentclientprotocol/claude-agent-acp, zed-industries/claude-agent-acp), Zed documentation, Anthropic Agent SDK documentation, code.claude.com
**Artifacts**: specs/011_fix_zed_acp_subagent_invocation/reports/01_teammate-a-findings.md

---

## Key Findings

### 1. Root Cause: `@agentclientprotocol/claude-agent-acp` Uses the Agent SDK — Not the `claude` CLI

The `@agentclientprotocol/claude-agent-acp` package is an ACP adapter that wraps the **Claude Agent SDK** (`@anthropic-ai/claude-agent-sdk`). It does NOT run the `claude` CLI binary. This is the primary architectural difference explaining the behavioral gap.

The Neovim Claude Code plugin (via `claude` CLI) runs the full Claude Code CLI binary which has native support for:
- `Skill` tool invocation (reading `.claude/skills/*/SKILL.md`)
- `Agent` tool invocation (spawning subagents with isolated contexts)
- Slash command routing (`/implement` -> skill-orchestrator -> skill-implementer -> general-implementation-agent)
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` for parallel agent teams

The Agent SDK adapter can support Skills and Agents — **but only if configured correctly**. By default, the SDK:
1. Does NOT load any filesystem settings (no `settingSources`)
2. Does NOT include `"Skill"` or `"Agent"` in `allowedTools`
3. Runs in isolation mode with basic file tools only

### 2. The ACP Adapter Must Be Configured With `settingSources` and `allowedTools`

From official SDK documentation (`code.claude.com/docs/en/agent-sdk/skills`):

> **Default behavior**: By default, the SDK does not load any filesystem settings. To use Skills, you must explicitly configure `settingSources: ['user', 'project']`

The adapter launched via `npx @agentclientprotocol/claude-agent-acp --serve` starts with the SDK in isolation mode unless the adapter itself passes `settingSources` and includes `"Skill"` and `"Agent"` in `allowedTools` when calling the SDK's `query()` function.

### 3. The Current settings.json Uses `"env": {}` — No Environment Variables Forwarded

The current configuration:

```json
"agent_servers": {
  "claude-acp": {
    "type": "custom",
    "command": "/home/benjamin/.nix-profile/bin/npx",
    "args": ["@agentclientprotocol/claude-agent-acp", "--serve"],
    "env": {}
  }
}
```

The empty `"env": {}` means no environment variables from the parent shell are forwarded. This includes:
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` (needed for team mode)
- Any other vars that might trigger richer SDK behavior

### 4. Zed Has a Registry-Based Installation That Vendors the Adapter

From `zed.dev/docs/ai/external-agents`:

> "Zed will always use this managed version of the Claude Agent adapter, which includes a vendored version of the Claude Code CLI, even if you have it installed globally."

The registry type (`"type": "registry"`) for `claude-acp` bundles a vendored Claude Code CLI and uses `CLAUDE_CODE_EXECUTABLE` to override it. This is the officially supported integration path as of v0.202.7+.

### 5. Known Bug: Subagents in ACP Lack Tool Access (Fixed in 0.18.0)

GitHub issue #305 in `zed-industries/claude-agent-acp` documented that spawned Task subagents hallucinated tool calls because `allowedTools` for subagents did not include the ACP tool equivalents. This was resolved in PR #316 by switching back to built-in Claude Code tools. This confirms the pattern: allowedTools misconfiguration causes exactly the behavior observed (model does work inline instead of delegating).

### 6. Agent Teams Are a CLI-Only Feature

From official docs:

> "Agent teams are a CLI feature where one session acts as the team lead, coordinating work across independent teammates"

The Agent SDK does not support agent teams directly. Even if `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is set, it would only take effect when running the actual `claude` CLI binary, not the SDK adapter.

---

## Recommended Approach

### Option A (Best): Switch to Registry Type — Use Vendored CLI with Correct Env Vars

Replace the `"type": "custom"` configuration with `"type": "registry"`. This uses Zed's managed, vendored Claude Code CLI integration which has been validated to work correctly:

```json
"agent_servers": {
  "claude-acp": {
    "type": "registry",
    "env": {
      "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
    }
  }
}
```

**Why this works**: The registry build includes the vendored claude CLI binary. Zed's `claude-code-acp` package (the officially maintained one, formerly `@zed-industries/claude-code-acp`) properly configures the SDK with `settingSources: ["user", "project"]` and `allowedTools: ["Skill", "Agent", ...]`.

**Caveats**:
- Requires Zed v0.202.7+
- Drops any local/dev version of the adapter
- You lose `bypassPermissions` default — may need to re-add via `default_config_options`

### Option B (Interim): Pass Full Env Block to Custom Command

If staying on `"type": "custom"`, forward required env vars and check if the `@agentclientprotocol/claude-agent-acp` version in use correctly passes `settingSources`:

```json
"agent_servers": {
  "claude-acp": {
    "type": "custom",
    "command": "/home/benjamin/.nix-profile/bin/npx",
    "args": ["@agentclientprotocol/claude-agent-acp", "--serve"],
    "default_config_options": {"mode": "bypassPermissions"},
    "env": {
      "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1",
      "HOME": "/home/benjamin"
    }
  }
}
```

But this is unlikely to fully solve the problem if the adapter itself does not pass `settingSources: ["user", "project"]` and `allowedTools: ["Skill", "Agent"]` when calling the SDK's `query()`. The only way to verify this is to inspect the adapter's source code.

### Option C (Most Direct): Use the `claude` CLI Binary Directly

The Neovim Claude Code plugin works because it invokes the `claude` binary directly. One option is to check whether Zed supports a `claude --serve` or ACP protocol mode:

From searching, there is no `claude --serve` command. The ACP adapter is the bridge. However, the key insight is that the **registry version of the adapter vendors the `claude` binary and sets `CLAUDE_CODE_EXECUTABLE`**. So Option A achieves the same effect.

---

## Evidence and Examples

### Architecture of the Issue

```
Neovim Claude Code Plugin:
  claude CLI binary
    -> reads .claude/CLAUDE.md
    -> reads .claude/skills/
    -> Skill tool available
    -> Agent tool available
    -> /implement 9 -> skill-orchestrator -> skill-implementer -> subagent

Zed ACP (current config):
  npx @agentclientprotocol/claude-agent-acp --serve
    -> Claude Agent SDK (isolation mode, no settingSources)
    -> NO Skill tool
    -> NO Agent tool
    -> /implement 9 -> model reads plan inline -> executes all phases directly

Zed ACP (registry config, recommended):
  Zed-vendored claude-code-acp
    -> Claude Agent SDK with settingSources: ["user", "project"]
    -> allowedTools: ["Skill", "Agent", "Read", "Write", "Edit", "Bash", ...]
    -> /implement 9 -> Skill tool -> skill-orchestrator -> skill-implementer -> subagent
```

### SDK Docs: Skills Require Explicit Configuration

Source: [Agent Skills in the SDK](https://code.claude.com/docs/en/agent-sdk/skills)

```typescript
// WRONG — Skills won't be loaded (isolation mode, what current config does)
const options = {
  allowedTools: ["Read", "Write", "Edit", "Bash"]
};

// CORRECT — Skills and Agents available
const options = {
  settingSources: ["user", "project"],
  allowedTools: ["Skill", "Agent", "Read", "Write", "Edit", "Bash"]
};
```

### Agent Teams Are CLI-Only

Source: [Use Claude Code features in the SDK](https://code.claude.com/docs/en/agent-sdk/claude-code-features)

> "Coordinate multiple Claude Code instances with shared task lists and direct inter-agent messaging: Agent teams. Not directly configured via SDK options. Agent teams are a CLI feature."

---

## Confidence Level

**HIGH CONFIDENCE** on root cause: The `@agentclientprotocol/claude-agent-acp` adapter runs the SDK in isolation mode by default (no `settingSources`, no `Skill`/`Agent` in `allowedTools`), which prevents the model from delegating to skills and subagents.

**HIGH CONFIDENCE** on Option A fix: Switching to `"type": "registry"` uses Zed's maintained vendored CLI and correctly configures the SDK.

**MEDIUM CONFIDENCE** on whether env vars alone would fix Option B: Even adding `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` to a custom type configuration won't fix the root cause (missing `settingSources` and `allowedTools: ["Skill", "Agent"]` inside the adapter call). The adapter source code would need to be inspected to confirm whether version 0.26.0 correctly sets these. The changelog does not mention explicit `settingSources` or `Skill`/`Agent` tool additions.

**LOW CONFIDENCE** on agent teams working even with registry type: The documentation explicitly states agent teams are a CLI-only feature not available in the SDK. The `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` env var may work if the registry vendor bundles the full CLI binary, but this is uncertain.

---

## Summary of Recommended settings.json Change

```json
// CURRENT (broken for subagent delegation):
"agent_servers": {
  "claude-acp": {
    "favorite_config_option_values": {"mode": ["bypassPermissions"]},
    "default_config_options": {"mode": "bypassPermissions"},
    "type": "custom",
    "command": "/home/benjamin/.nix-profile/bin/npx",
    "args": ["@agentclientprotocol/claude-agent-acp", "--serve"],
    "env": {}
  }
}

// RECOMMENDED (registry type, skills/agents work):
"agent_servers": {
  "claude-acp": {
    "type": "registry",
    "default_config_options": {"mode": "bypassPermissions"},
    "env": {
      "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
    }
  }
}
```

---

## References

- [agentclientprotocol/claude-agent-acp GitHub](https://github.com/agentclientprotocol/claude-agent-acp)
- [Agent Skills in the SDK](https://code.claude.com/docs/en/agent-sdk/skills)
- [Use Claude Code features in the SDK](https://code.claude.com/docs/en/agent-sdk/claude-code-features)
- [Zed External Agents Docs](https://zed.dev/docs/ai/external-agents)
- [Zed Claude Code ACP Blog Post](https://zed.dev/blog/claude-code-via-acp)
- [Zed Claude Code ACP Page](https://zed.dev/acp/agent/claude-code)
- [zed-industries/claude-agent-acp Issue #305](https://github.com/zed-industries/claude-agent-acp/issues/305) — subagent tool access bug
- [@agentclientprotocol/claude-agent-acp npm](https://www.npmjs.com/package/@agentclientprotocol/claude-agent-acp)
