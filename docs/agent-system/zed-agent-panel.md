# Zed Agent Panel

Zed ships with an AI agent panel that can read and edit files in your project. It hosts two distinct threads: the **built-in agent** (Zed's own AI) and the **Claude Code thread** (connected via the `claude-acp` bridge). This page covers opening the panel, switching between threads, authentication, and troubleshooting.

## Summary

Press **Cmd+Shift+?** to open the panel, pick a thread type, type, and press Enter. For Claude Code specifically, the panel talks to your local `claude` CLI through the `@zed-industries/claude-agent-acp` bridge — so the same Claude Code environment is available whether you run `claude` in the terminal or use the panel thread.

## Opening the panel

Press **Cmd+Shift+?** (also bound to **Cmd+Shift+A**) to toggle the right sidebar where the agent panel lives.

Once the panel is open:

1. **Cmd+N** — start a new thread
2. Type a question or instruction
3. **Enter** — send (or **Cmd+Enter** if `agent.use_modifier_to_send` is enabled in [settings.json](../general/settings.md))

The built-in agent can see your open files and make edits directly. It is good for quick questions and simple edits.

## Built-in agent vs Claude Code thread

The panel offers two kinds of threads:

| Feature | Built-in agent | Claude Code thread |
|---------|----------------|--------------------|
| Backend | Zed's own AI integration | Local `claude` CLI via `claude-acp` bridge |
| Model selection | Set in `settings.json` `"agent"` block | Managed by Claude Code |
| Slash commands | Zed's built-ins | All 24 `.claude/commands/*` |
| Task lifecycle | No | Yes (`/task`, `/research`, `/plan`, `/implement`) |
| Artifacts | No | `specs/{NNN}_{slug}/` |
| Best for | Quick questions, inline edits | Multi-step work, anything worth tracking |

They do not share conversation history. For anything worth committing, use the Claude Code thread.

## How claude-acp works under the hood

`claude-acp` is the package `@zed-industries/claude-agent-acp`. It is an **ACP bridge** — ACP stands for Agent Client Protocol — that Zed spawns according to the `agent_servers` block in your `settings.json`. The bridge process then launches the local `claude` binary and proxies messages between Zed's panel UI and the CLI.

```
Zed Agent Panel
     |
     v
agent_servers.claude-acp  (config in settings.json)
     |
     v
@zed-industries/claude-agent-acp  (spawned ACP bridge)
     |
     v
claude  (the CLI binary installed by `brew install anthropics/claude/claude-code`)
```

Two things follow from this architecture:

1. The **CLI and the panel share the same Claude Code framework**: commands, tasks, memory, and artifacts live on disk and are visible to both.
2. **Two authentication steps are required**: `claude auth login` in the terminal (for the CLI binary) and `/login` inside the panel thread (for the bridge). See [installation.md](../general/installation.md#authenticate-in-zed).

For registry vs custom `agent_servers` configuration, see [../general/settings.md](../general/settings.md#agent_servers). For non-standard setups, see the upstream bridge project at [zed-industries/claude-code-acp](https://github.com/zed-industries/claude-code-acp).

## Authenticating with /login

Inside a Claude Code thread in the panel, run:

```
/login
```

and follow the prompts. This is distinct from `claude auth login` in the terminal — that one authenticates the CLI binary, while `/login` authenticates the ACP bridge path. You only need to do this once per machine.

## Keybindings quick reference

| Shortcut | What it does | Context |
|----------|-------------|---------|
| Cmd+Shift+? | Toggle agent panel | Global |
| Cmd+Shift+A | Toggle agent panel (alternate) | Global |
| Cmd+N | New thread | Agent panel focused |
| Enter | Send message | Message editor |
| Shift+Alt+J | Recent threads menu | Agent panel |
| Cmd+Shift+H | Full thread history | Agent panel |
| Cmd+Shift+R | Review agent changes (diff) | Agent panel |
| Cmd+Alt+/ | Toggle model selector | Agent panel |
| Alt+L | Cycle favorite models | Agent panel |
| Cmd+Enter | Inline assist | Text selected in editor |
| Tab / Alt+L | Accept edit prediction | Editor |
| Alt+] / Alt+[ | Next/previous edit prediction | Editor |

For the full keymap including profile management and external agent setup, see [../general/keybindings.md](../general/keybindings.md#how-do-i-use-the-ai-agent).

## Inline Assist

Select some text in the editor, then press **Cmd+Enter** to open the inline assistant. It edits the selected text in place rather than opening a full thread. Useful for rewording a paragraph, renaming a variable, or fixing an obvious bug.

Older Zed versions used **Cmd+;**; if **Cmd+Enter** does not work, check your keymap with **Cmd+K Cmd+S** or see [../general/keybindings.md](../general/keybindings.md).

## Edit Predictions

Zed's edit-prediction feature suggests continuations as you type. Accept with **Tab** (or **Alt+L**); cycle with **Alt+]** / **Alt+[**. Configure model and aggressiveness under the `"agent"` block in [settings.json](../general/settings.md).

## Troubleshooting

**Claude Code thread is missing from the thread picker.**
The `agent_servers.claude-acp` block in `settings.json` is missing or malformed. See [../general/installation.md](../general/installation.md#configure-claude-acp) for the registry config and [../general/settings.md](../general/settings.md#agent_servers) for the full reference. Restart Zed after editing.

**Claude Code thread opens but errors immediately.**
Open the ACP log viewer from the command palette (**Cmd+Shift+P**, type `dev: open acp logs`). The log usually shows whether the bridge failed to spawn, the `claude` binary is missing from PATH, or authentication is stale.

**`/login` loops forever.**
Usually means the terminal CLI side is not authenticated. Run `claude auth login` in a terminal first, then retry `/login` in the panel thread.

**MCP tools don't work inside the panel thread.**
MCP scope matters: the tools must be installed with `--scope user` (see [../general/installation.md](../general/installation.md#install-mcp-tools)). Re-run `claude mcp add --scope user ...` and then `claude mcp list` to verify.

**Panel is slow or unresponsive.**
Go to **Settings > Extensions** and confirm "Claude Code" is listed. If not, search for it and install it. Restart Zed.

## See also

- [../general/installation.md](../general/installation.md) — Installing Zed, Claude Code CLI, and `claude-acp`
- [../general/settings.md](../general/settings.md#agent_servers) — `agent_servers` configuration reference
- [../general/keybindings.md](../general/keybindings.md#how-do-i-use-the-ai-agent) — Full keymap for the panel
- [agent-lifecycle.md](../workflows/agent-lifecycle.md) — Task lifecycle once you are inside a Claude Code thread
- [`.claude/docs/guides/user-guide.md`](../../.claude/docs/guides/user-guide.md) — Comprehensive Claude Code command reference
- [`.claude/docs/architecture/system-overview.md`](../../.claude/docs/architecture/system-overview.md) — Detailed architecture walkthrough
