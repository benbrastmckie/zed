---
title: "Zed AI modes: terminal CLI vs agent panel"
created: 2026-04-15
tags: [TECHNIQUE, zed, claude-code, agent-panel, acp]
topic: "zed/ai-modes"
source: "docs/agent-system/zed-agent-panel.md"
modified: 2026-04-15
retrieval_count: 0
last_retrieved: null
keywords: [agent, panel, terminal, cli, acp, bridge, modes, zed]
summary: "Terminal CLI vs agent panel modes with ACP bridge integration"
---

# Zed AI Modes: Terminal CLI vs Agent Panel

## Two Modes

### Terminal Task (Ctrl+Shift+A) — RECOMMENDED
- Full Claude Code CLI parity
- Multiple concurrent sessions (`allow_concurrent_runs: true`)
- All commands, skills, agents, --team mode, hooks work
- Configured in `.zed/tasks.json` as `task::Spawn` with label "Claude Code"
- Runs `claude --dangerously-skip-permissions`
- Terminal opens in dock panel (position: `terminal.dock` in settings.json)

### Agent Panel (Ctrl+?) — DISCOURAGED
- Uses `claude-acp` bridge (ACP = Agent Client Protocol)
- Runs in **SDK isolation mode** — fundamental constraint:
  - No Skill or Agent tools available
  - No subagent spawning
  - No --team mode
  - Slash commands delegating to skills/agents won't work
  - One session at a time
- Only useful for quick one-off questions

## Feature Comparison
| Feature | Terminal | Agent Panel |
|---------|---------|-------------|
| Concurrent sessions | Yes | No |
| Subagents | Yes | No (SDK isolation) |
| --team mode | Yes | No |
| All slash commands | Yes | Limited |
| Inline diff review | No | Yes |
| File context awareness | Manual | Automatic |

## claude-acp Architecture
```
Zed Agent Panel -> agent_servers.claude-acp (settings.json)
  -> @agentclientprotocol/claude-agent-acp (spawned bridge)
  -> claude binary (CLI on PATH)
```

## Authentication
- Terminal: `claude auth login` (one-time)
- Agent panel: `/login` in a Claude Code thread (separate from terminal auth)

## Troubleshooting
- ACP logs: Command palette -> "dev: open acp logs"
- MCP tools need `--scope user` to work in panel
- `CLAUDE_CODE_EXECUTABLE: "claude"` in env tells adapter where to find CLI

## Connections
<!-- Add links to related memories using [[filename]] syntax -->
