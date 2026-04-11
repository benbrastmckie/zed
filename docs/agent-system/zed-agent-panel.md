# Zed Agent Panel

Zed provides two ways to use Claude Code: the **agent panel** (ACP adapter) for quick inline tasks, and a **terminal task** that launches the full CLI for complete feature parity. This page covers both modes, their trade-offs, keybindings, configuration, and troubleshooting.

## Summary

- **Ctrl+Shift+A** — launch Claude Code CLI in a terminal panel (full parity, multiple concurrent sessions)
- **Ctrl+?** — toggle the agent panel (ACP adapter, limited capabilities, discouraged)

The terminal task is the recommended path. It supports multiple simultaneous sessions, subagents, skills, `--team` mode, and hooks. The agent panel exists as an alternative but is discouraged due to SDK isolation constraints that strip most functionality.

## Two modes of Claude Code in Zed

### Terminal task (full CLI) — recommended

A Zed terminal task (`.zed/tasks.json`) launches the `claude` binary directly. This gives you the exact same experience as running `claude` in a standalone terminal — all commands, skills, agents, and team mode work.

Because `allow_concurrent_runs` can be set to `true` (or you can define multiple task entries), you can run **multiple independent Claude Code sessions** simultaneously in separate terminal tabs. This is useful when you want to research in one session while implementing in another, or run parallel investigations on different parts of the codebase. Each session has its own context, conversation history, and tool permissions.

**When to use**: Multi-step workflows (`/research`, `/plan`, `/implement`), `--team` mode, anything that spawns subagents, or any time you need multiple concurrent sessions.

### Agent panel (ACP adapter) — discouraged

The agent panel uses the `claude-acp` bridge to connect Zed's UI to Claude Code. However, the ACP adapter runs in **SDK isolation mode**, which means:

- No `Skill` or `Agent` tools are available
- Subagent spawning does not work
- `--team` mode is unavailable
- Slash commands that delegate to skills/agents will not function as expected
- Only one session at a time per panel

The `CLAUDE_CODE_EXECUTABLE` environment variable is configured to point the adapter to the installed `claude` binary, which improves basic functionality but does not overcome SDK isolation constraints.

Given that the terminal task provides full CLI parity, multiple concurrent sessions, and no tool restrictions, the agent panel is generally not worth the trade-offs. Prefer **Ctrl+Shift+A** for all Claude Code work.

**When to use (if at all)**: Quick one-off questions where you don't need full CLI capabilities.

### Feature comparison

| Feature | Terminal task | Agent panel (ACP) |
|---------|-------------|-------------------|
| Keybinding | Ctrl+Shift+A | Ctrl+? |
| Multiple concurrent sessions | Yes | No |
| Subagent spawning | Yes | No (SDK isolation) |
| `--team` mode | Yes | No |
| All slash commands | Yes | Limited |
| Skills and hooks | Yes | No |
| Inline diff review | No (terminal UI) | Yes |
| File context awareness | Manual | Automatic (open files) |
| Recommended | **Yes** | No |

## Configuration

### Terminal task (`.zed/tasks.json`)

```jsonc
[
  {
    // Full Claude Code CLI via terminal for complete feature parity
    "label": "Claude Code",
    "command": "claude",
    "args": ["--dangerously-skip-permissions"],
    "use_new_terminal": true,
    "allow_concurrent_runs": true,
    "reveal": "always",
    "reveal_target": "dock"
  }
]
```

Setting `allow_concurrent_runs` to `true` lets you launch multiple independent Claude Code sessions by pressing Ctrl+Shift+A repeatedly. Each invocation opens a new terminal tab with its own session. This is the primary advantage over the agent panel, which is limited to a single thread at a time.

The terminal opens in the dock panel. To control which side the dock appears on, set `terminal.dock` in `settings.json`:

```jsonc
"terminal": {
    "dock": "right",  // "bottom" (default), "left", or "right"
    ...
}
```

Note: `terminal.dock` is a global setting that affects all terminal panels, not just the Claude Code task.

### Agent panel (`settings.json`)

```jsonc
"agent_servers": {
    "claude-acp": {
        "type": "custom",
        "command": "npx",
        "args": ["@agentclientprotocol/claude-agent-acp", "--serve"],
        "env": {
            "CLAUDE_CODE_EXECUTABLE": "claude",
            "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
        }
    }
}
```

**Environment variables**:
- `CLAUDE_CODE_EXECUTABLE` — tells the ACP adapter where to find the `claude` binary (required for the adapter to use the installed CLI rather than its bundled SDK). A bare `"claude"` is resolved from PATH; on Apple Silicon Homebrew installs to `/opt/homebrew/bin/claude`, on Intel Macs to `/usr/local/bin/claude`.
- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` — enables team mode support (though SDK isolation still prevents it from working in the panel)

`HOME` is inherited from the launching environment on macOS and does not need to be set explicitly.

### Keybindings (`keymap.json`)

```jsonc
// Workspace context
{
    "context": "Workspace",
    "bindings": {
        "ctrl-shift-a": ["task::Spawn", { "task_name": "Claude Code" }]
    }
},
// Terminal context (so Ctrl+Shift+A works from within a terminal too)
{
    "context": "Terminal",
    "bindings": {
        "ctrl-shift-a": ["task::Spawn", { "task_name": "Claude Code" }]
    }
}
```

The binding uses `task::Spawn` with a `task_name` parameter that matches the `label` in `.zed/tasks.json`. Both `Workspace` and `Terminal` contexts are needed so the shortcut works regardless of which pane has focus.

## How claude-acp works under the hood

`claude-acp` is the package `@agentclientprotocol/claude-agent-acp`. It is an **ACP bridge** (Agent Client Protocol) that Zed spawns according to the `agent_servers` block in `settings.json`. The bridge process launches the local `claude` binary and proxies messages between Zed's panel UI and the CLI.

```
Zed Agent Panel
     |
     v
agent_servers.claude-acp  (config in settings.json)
     |
     v
@agentclientprotocol/claude-agent-acp  (spawned ACP bridge)
     |
     v
claude  (the CLI binary on PATH, e.g. /opt/homebrew/bin/claude)
```

**SDK isolation**: The ACP adapter runs Claude Code in a restricted SDK mode. This means the `Skill` and `Agent` tools are not available to the adapter, and commands that rely on subagent spawning will not work. This is a fundamental constraint of the ACP architecture, not a configuration issue.

## Authenticating with /login

Inside a Claude Code thread in the agent panel, run:

```
/login
```

and follow the prompts. This is distinct from `claude auth login` in the terminal — that one authenticates the CLI binary, while `/login` authenticates the ACP bridge path. You only need to do this once per machine.

## Keybindings quick reference

| Shortcut | What it does | Context |
|----------|-------------|---------|
| Ctrl+Shift+A | Launch Claude Code CLI (terminal task) | Global + Terminal |
| Ctrl+? | Toggle agent panel (right dock) | Global |
| Ctrl+N | New thread | Agent panel focused |
| Enter | Send message | Message editor |
| Ctrl+Shift+R | Review agent changes (diff) | Agent panel |
| Ctrl+; | Inline assist | Text selected in editor |
| Tab | Accept edit prediction | Editor |
| Alt+] / Alt+[ | Next/previous edit prediction | Editor |

For the full keymap, see [../general/keybindings.md](../general/keybindings.md).

## Troubleshooting

**Terminal task does not appear in task picker.**
Check that `.zed/tasks.json` exists in the project root and contains valid JSONC. Restart Zed after creating the file.

**Terminal opens on the bottom instead of the right.**
Add `"dock": "right"` to the `"terminal"` block in `settings.json`. This is a global setting affecting all terminals.

**Claude Code thread is missing from the agent panel thread picker.**
The `agent_servers.claude-acp` block in `settings.json` is missing or malformed. See configuration section above. Restart Zed after editing.

**Claude Code thread opens but errors immediately.**
Open the ACP log viewer from the command palette (Ctrl+Shift+P, type `dev: open acp logs`). The log usually shows whether the bridge failed to spawn, the `claude` binary is missing from PATH, or authentication is stale.

**Slash commands don't spawn subagents in the agent panel.**
This is expected. The ACP adapter runs in SDK isolation mode — subagent spawning is not available. Use the terminal task (Ctrl+Shift+A) instead for commands that need full CLI capabilities.

**`/login` loops forever.**
Usually means the terminal CLI side is not authenticated. Run `claude auth login` in a terminal first, then retry `/login` in the panel thread.

**MCP tools don't work inside the panel thread.**
MCP scope matters: the tools must be installed with `--scope user`. Re-run `claude mcp add --scope user ...` and then `claude mcp list` to verify.

## See also

- [../general/installation.md](../general/installation.md) — Installing Zed, Claude Code CLI, and `claude-acp`
- [../general/settings.md](../general/settings.md#agent_servers) — `agent_servers` configuration reference
- [../general/keybindings.md](../general/keybindings.md) — Full keymap reference
- [agent-lifecycle.md](../workflows/agent-lifecycle.md) — Task lifecycle once you are inside a Claude Code thread
- [`.claude/docs/guides/user-guide.md`](../../.claude/docs/guides/user-guide.md) — Comprehensive Claude Code command reference
