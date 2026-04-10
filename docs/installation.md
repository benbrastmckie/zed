# Installation

This guide walks through installing Zed, the Claude Code CLI, the `claude-acp` bridge that connects them, and the MCP tools used for Word and Excel editing. The target platform is macOS 11 (Big Sur) or newer.

## Summary

Minimum working setup in four commands:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install --cask zed
brew install --cask claude-code
claude
```

Then open Zed, confirm the Claude Code thread is available in the Agent Panel (Cmd+Shift+?), and run `/login` once inside the thread. Detailed steps follow.

## Prerequisites

- macOS 11 (Big Sur) or newer
- An internet connection
- About 20-30 minutes for initial setup
- An Anthropic account for the Claude Code CLI

Every dependency section below follows the same three-step pattern: **Check if already installed** -> **Install** -> **Verify**. Run the detection command first; if it succeeds, skip to the next section.

## Install Xcode Command Line Tools

Provides `git` and the compiler toolchain Homebrew needs. Most Macs already have these installed.

### Check if already installed

```
xcode-select -p >/dev/null 2>&1 && git --version
```

If this prints a `git version ...` line and exits cleanly, skip to [Install Homebrew](#install-homebrew).

### Install

```
xcode-select --install
```

A GUI installer window appears; click through it. Installation takes several minutes.

### Verify

```
git --version
```

Expected output: a line like `git version 2.xx.x`.

## Install Homebrew

Open **WezTerm** (or any terminal) and paste:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the on-screen instructions (you may need your Mac password). Close and reopen the terminal when it finishes, then verify:

```
brew --version
```

## Install Node.js

Provides `npx`, required by the SuperDoc and openpyxl MCP tools installed later in this guide.

### Check if already installed

```
command -v node >/dev/null && node --version && command -v npx >/dev/null
```

If this prints a Node version (e.g. `v20.17.0`) and exits cleanly, skip to [Install Zed](#install-zed).

### Install

```
brew install node
```

Homebrew installs the current LTS. Node 18 or newer is required by the MCP tools; the default Homebrew release is well above that.

### Verify

```
node --version && npx --version
```

Expected output: a Node version on one line and an npx version on the next.

## Install Zed

```
brew install --cask zed
```

Open Zed from Applications or Spotlight (Cmd+Space, type "Zed") to confirm it launches. To track the preview channel (nightly-ish builds with newer features), install `zed@preview` instead:

```
brew install --cask zed@preview
```

You can have both channels installed simultaneously; they use separate config directories.

## Install the Claude Code CLI

```
brew install --cask claude-code
claude
```

Run `claude` in any directory; it opens a browser to sign into your Anthropic Pro/Max/Team/Enterprise/Console account (free claude.ai accounts are not supported). Verify with:

```
claude --version
```

Note: this authenticates the terminal CLI. Authenticating the Claude Code thread inside Zed is a separate step (see [Authenticate in Zed](#authenticate-in-zed) below). Authoritative upstream docs: https://code.claude.com/docs/en/setup.

## Configure claude-acp

Zed talks to the Claude Code CLI through `@zed-industries/claude-agent-acp`, an ACP (Agent Client Protocol) bridge. Zed spawns this bridge per the `agent_servers` block in `settings.json`, and the bridge in turn launches the `claude` binary. The recommended default on macOS is the **registry** config, which lets Zed manage the bridge version for you:

```jsonc
"agent_servers": {
  "claude-acp": {
    "type": "registry",
    "env": {}
  }
}
```

Paste that into your `settings.json` (Cmd+, in Zed). Restart Zed to pick up the change.

See [docs/settings.md](settings.md#agent_servers) for the full `agent_servers` reference, including environment variables.

## Authenticate in Zed

Once `claude-acp` is configured, the Claude Code thread becomes available in Zed's Agent Panel.

1. Open the Agent Panel with **Cmd+Shift+?**
2. Start a new Claude Code thread (the thread picker shows both the built-in agent and the Claude Code bridge)
3. Type `/login` in the thread and follow the prompts

`/login` authenticates the Zed-side thread and is distinct from the first-run `claude` authentication you completed in the terminal. Both are required: the CLI auth unlocks the binary; `/login` unlocks the ACP bridge inside Zed.

## Install MCP Tools

MCP (Model Context Protocol) tools give Claude the ability to edit Word and Excel files properly, preserving formatting and tracked changes. You never interact with these tools directly — they work behind the scenes when Claude needs them.

### SuperDoc — Word document editing

SuperDoc lets Claude edit .docx files with full formatting and tracked-changes support. Install it by running this in the terminal:

```
claude mcp add --scope user superdoc -- npx @superdoc-dev/mcp
```

### openpyxl — Spreadsheet editing

The openpyxl tool lets Claude read and edit .xlsx files (values, formulas, rows). Install it:

```
claude mcp add --scope user openpyxl -- npx @jonemo/openpyxl-mcp
```

### Verify both tools

```
claude mcp list
```

You should see `superdoc` and `openpyxl` in the output. If either is missing, re-run the `claude mcp add` command with `--scope user`.

## Verify

Run through this checklist end-to-end:

- [ ] `brew --version` prints a version
- [ ] `zed --version` (or launch from Applications) works
- [ ] `claude --version` prints a version
- [ ] `claude mcp list` shows both `superdoc` and `openpyxl`
- [ ] Zed's Agent Panel (Cmd+Shift+?) offers a Claude Code thread
- [ ] Inside the Claude Code thread, `/login` completes without error
- [ ] Running `/task "test"` from the Claude Code thread creates a task entry

If any step fails, see [Troubleshooting in the agent panel doc](agent-system/zed-agent-panel.md#troubleshooting).

## See also

- [docs/settings.md](settings.md#agent_servers) — `agent_servers` configuration reference
- [docs/agent-system/zed-agent-panel.md](agent-system/zed-agent-panel.md) — How the Agent Panel and claude-acp bridge work at runtime
- [.claude/docs/guides/user-installation.md](../.claude/docs/guides/user-installation.md) — Quick-start reference for the Claude Code framework itself
