# Research Report: Task #11 (Teammate B - Alternative Approaches)

**Task**: 11 - Fix Zed ACP subagent invocation to match Neovim Claude Code plugin behavior
**Started**: 2026-04-10T00:00:00Z
**Completed**: 2026-04-10T00:30:00Z
**Effort**: ~1.5 hours
**Dependencies**: None
**Sources/Inputs**: Codebase (local ACP adapter source), Zed docs, GitHub discussions, npm package inspection
**Artifacts**: `specs/011_fix_zed_acp_subagent_invocation/reports/01_teammate-b-findings.md`
**Standards**: report-format.md

---

## Key Findings

### 1. Subagents technically work via ACP — the problem is rendering, not spawning

From [zed-industries/zed Discussion #49452](https://github.com/zed-industries/zed/discussions/49452):
> "The data is already flowing through the protocol — it's just not rendered."
> The thread view has: `if step.kind.is_subagent() { continue; }` — it skips rendering subagent steps.

Subagents are spawned and run. The activity is invisible in the Zed panel. For a `claude code` session doing complex multi-skill work with 3-5 subagents, the UI shows "a single frozen stream."

This is a Zed rendering bug, not a fundamental ACP capability gap. Phase 1 fix is a UI change to replace the skip with collapsible disclosure widgets.

### 2. The current config uses a community fork — the official ACP package is the same thing under a renamed namespace

The user's current config uses:
```json
"command": "/home/benjamin/.nix-profile/bin/npx",
"args": ["@agentclientprotocol/claude-agent-acp", "--serve"]
```

`@agentclientprotocol/claude-agent-acp` was renamed from `@zed-industries/claude-agent-acp` when the project moved to the ACP org. They are the same codebase. The locally cached version is **v0.26.0**.

The Zed docs for `type: "registry"` agents reference `claude-acp` as the registry key, not the npm package name. If the user switches `type` from `"custom"` to `"registry"`, Zed manages the adapter itself (and keeps it updated).

### 3. `CLAUDE_CODE_EXECUTABLE` env var routes the ACP adapter to any claude binary

Inspecting the actual adapter source at:
`~/.npm/_npx/d820eb7d96bc2600/node_modules/@agentclientprotocol/claude-agent-acp/dist/acp-agent.js`

The adapter contains this logic:
```js
...(process.env.CLAUDE_CODE_EXECUTABLE
    ? { pathToClaudeCodeExecutable: process.env.CLAUDE_CODE_EXECUTABLE }
    : isStaticBinary()
        ? { pathToClaudeCodeExecutable: await claudeCliPath() }
        : {}),
```

Setting `CLAUDE_CODE_EXECUTABLE` in the `env` block of `agent_servers` will tell the adapter to use a specific `claude` binary. The nix-installed binary at `/home/benjamin/.nix-profile/bin/claude` is version 2.1.87.

A wrapper script placed at that path (that sets additional env vars and execs the real binary) would therefore be fully transparent to the adapter.

### 4. A shell wrapper script approach is viable and transparent

Because the adapter passes `CLAUDE_CODE_EXECUTABLE` straight to the Claude Agent SDK as `pathToClaudeCodeExecutable`, creating a wrapper like:

```bash
#!/usr/bin/env bash
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
export CLAUDE_CODE_SUBAGENT_MODEL=claude-opus-4-20250514
exec /home/benjamin/.nix-profile/bin/claude "$@"
```

...and pointing `CLAUDE_CODE_EXECUTABLE` at it from Zed settings would inject env vars for every session the ACP adapter spawns. No ACP protocol changes needed. The adapter env spread (`...process.env, ...userProvidedOptions?.env`) means vars set in the Zed `env: {}` block also flow through.

### 5. Team mode (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) is NOT supported via ACP

From the Zed ACP docs:
> "Agent teams are currently not supported."

The ACP protocol would need extensions beyond the current subagent/create messages to support team orchestration. This is a hard architectural limit at the protocol level, not solvable with a wrapper script. Individual subagents work; parallel team orchestration does not.

### 6. Running `claude` in Zed's terminal panel gives full CLI behavior — including teams and skills

A task entry in `tasks.json` launches a full interactive `claude` session in a Zed terminal pane:

```json
{
  "label": "Claude Code (interactive)",
  "command": "/home/benjamin/.nix-profile/bin/claude",
  "args": ["--dangerously-skip-permissions"],
  "use_new_terminal": true,
  "reveal": "always"
}
```

In this mode: subagents, skills, the Agent tool, `/research`, `/implement` all work exactly as they do in any terminal. The trade-off is losing the Zed agent panel UI features (inline diff review, change acceptance/rejection in editor panes).

This is the approach used by [benswift.me](https://benswift.me/blog/2025/07/23/running-claude-code-within-zed/) and others who migrated from the Agent panel to the Claude Code subscription model.

### 7. The Neovim plugin connects via WebSocket MCP — ACP is structurally different

The Neovim Claude Code plugin (what the user wants parity with) uses Claude Code's built-in WebSocket-based MCP server. It does not use ACP. Claude Code runs as the primary process; the plugin connects to its tool stream. This gives full access to every tool including the Agent tool.

ACP inverts this: Zed is the host, Claude Code SDK runs as a subprocess managed by the ACP adapter. The SDK wrapper strips or gates certain capabilities. This is the root architectural difference explaining why subagents show no UI.

---

## Recommended Approach (ranked by trade-offs)

### Option A: Switch to `type: "registry"` + pass env vars (Low effort, highest compatibility)

**What it does**: Use Zed's managed ACP registry entry instead of the custom npx command. Pass env vars directly in the `env` block.

```json
"agent_servers": {
  "claude-acp": {
    "type": "registry",
    "env": {
      "CLAUDE_CODE_EXECUTABLE": "/home/benjamin/.nix-profile/bin/claude"
    }
  }
}
```

**Trade-offs**:
- Pro: Zed manages version updates automatically
- Pro: Explicit binary path ensures the correct claude is used
- Pro: Subagents work (they already do — just not rendered)
- Con: Does not fix invisible subagent activity (rendering bug)
- Con: Team mode still not supported

### Option B: Wrapper script + CLAUDE_CODE_EXECUTABLE (Low effort, env injection)

**What it does**: Create a wrapper at e.g. `~/.config/zed/scripts/claude-wrapper.sh` that exports needed env vars and execs the real claude. Point `CLAUDE_CODE_EXECUTABLE` at it.

```bash
#!/usr/bin/env bash
export CLAUDE_CODE_SUBAGENT_MODEL=claude-opus-4-20250514
export ENABLE_TOOL_SEARCH=1
export MAX_THINKING_TOKENS=8000
exec /home/benjamin/.nix-profile/bin/claude "$@"
```

Zed config:
```json
"agent_servers": {
  "claude-acp": {
    "type": "custom",
    "command": "/home/benjamin/.nix-profile/bin/npx",
    "args": ["@agentclientprotocol/claude-agent-acp", "--serve"],
    "env": {
      "CLAUDE_CODE_EXECUTABLE": "/home/benjamin/.config/zed/scripts/claude-wrapper.sh"
    }
  }
}
```

**Trade-offs**:
- Pro: Fine-grained env var control per-project
- Pro: Transparent to the adapter
- Pro: Works today without any upstream changes
- Con: Does not fix rendering of subagent activity
- Con: Team mode still not supported; wrapper cannot fix protocol-level gaps

### Option C: Zed terminal task (Full CLI parity, zero restrictions)

**What it does**: Add a task entry to `tasks.json` that launches `claude` interactively in a Zed terminal pane.

```json
{
  "label": "Claude Code",
  "command": "/home/benjamin/.nix-profile/bin/claude",
  "args": ["--dangerously-skip-permissions"],
  "use_new_terminal": true,
  "reveal": "always"
}
```

**Trade-offs**:
- Pro: Full feature parity with Neovim plugin behavior — Agent tool, skills, `/research`, `/implement`, team mode all work
- Pro: No ACP limitations
- Con: Loses Zed agent panel UI (inline diff review, multibuffer change acceptance)
- Con: No LSP diagnostics directly (requires MCP workaround for language-aware tooling)
- Con: Requires tmux or manual session management for persistent sessions

### Option D: ACPX headless client (Advanced, multi-editor orchestration)

**What it does**: [ACPX](https://github.com/openclaw/acpx) is a headless CLI ACP client that lets Claude Code orchestrate other agents through structured protocol calls rather than PTY scraping. It adds multi-agent orchestration beyond what either Zed's built-in panel or the terminal provide alone.

**Trade-offs**:
- Pro: Structured tool call reports; cross-agent orchestration
- Pro: Works independently of Zed's panel rendering limitations
- Con: Significant setup complexity
- Con: Third-party project; less stable than official paths

---

## Evidence / Examples

| Finding | Source |
|---------|--------|
| Subagent data flows but isn't rendered | [Discussion #49452](https://github.com/zed-industries/zed/discussions/49452) |
| `if step.kind.is_subagent() { continue; }` skip logic | Same discussion |
| Agent teams not supported in ACP | [Zed External Agents docs](https://zed.dev/docs/ai/external-agents) |
| `CLAUDE_CODE_EXECUTABLE` in adapter source | `~/.npm/_npx/d820eb7d96bc2600/.../acp-agent.js` (local) |
| `env` block in Zed settings flows through | [Zed External Agents docs](https://zed.dev/docs/ai/external-agents), adapter source |
| Terminal task approach (benswift) | [benswift.me blog](https://benswift.me/blog/2025/07/23/running-claude-code-within-zed/) |
| Package rename: zed-industries -> agentclientprotocol | [npm](https://www.npmjs.com/package/@zed-industries/claude-code-acp), search results |
| In-process team agents lack Agent tool (related bug) | [Issue #31977](https://github.com/anthropics/claude-code/issues/31977) |
| `CLAUDE_CODE_SUBAGENT_MODEL` and other env vars | [jedisct1 gist](https://gist.github.com/jedisct1/9627644cda1c3929affe9b1ce8eaf714) |
| Zed ACP blog announcement | [Zed blog](https://zed.dev/blog/claude-code-via-acp) |
| Claude Code 2.1.87 installed at `/home/benjamin/.nix-profile/bin/claude` | Local inspection |

---

## Confidence Level

- **Subagents work but aren't rendered**: HIGH — confirmed by Zed discussion with source code reference
- **Team mode not supported via ACP**: HIGH — stated explicitly in Zed docs
- **`CLAUDE_CODE_EXECUTABLE` wrapper approach**: HIGH — confirmed from local adapter source code
- **Terminal task gives full parity**: HIGH — confirmed by multiple blog posts and CLI inspection
- **ACPX as alternative**: MEDIUM — third-party project, less documented
- **`type: "registry"` being equivalent to current custom config**: HIGH — confirmed same package

---

## Context Extension Recommendations

- **Topic**: Zed ACP adapter subagent rendering limitations
- **Gap**: No project context documents that ACP subagents run but are invisible, the `CLAUDE_CODE_EXECUTABLE` env var trick, or the terminal task alternative
- **Recommendation**: Add a note to `.claude/context/repo/project-overview.md` or a new `zed-acp-limitations.md` once the fix approach is confirmed
