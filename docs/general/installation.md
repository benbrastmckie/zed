# Installation

This guide walks through installing Zed, the Claude Code CLI, the `claude-acp` bridge that connects them, and the MCP tools used for Word and Excel editing. The target platform is macOS 11 (Big Sur) or newer.

## Summary

Minimum working setup, in order. Each line has a detection step in its full section below; skip any command whose tool is already installed.

```
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
brew install node
brew install --cask zed
brew install --cask claude-code
claude
```

Then open Zed, paste the `agent_servers` block from [Configure claude-acp](#configure-claude-acp) into `settings.json`, confirm the Claude Code thread is available in the Agent Panel (Ctrl+?), and run `/login` once inside the thread. Finally install the two MCP tools. Detailed steps follow.

## Before you begin

You will run every command in this guide inside a terminal. To open one, press **Cmd+Space** to open Spotlight, type **Terminal**, and press Enter. (You can also find Terminal in Applications > Utilities.)

When the terminal opens, you see a prompt -- a short line ending in `$` or `%`. To run a command, paste or type it after the prompt and press **Enter**. The examples in this guide show only the command itself, not the prompt character.

If a command produces a lot of output, wait until the prompt appears again before running the next one. That means the previous command has finished.

## Prerequisites

- macOS 11 (Big Sur) or newer
- An internet connection
- About 20-30 minutes for initial setup
- An Anthropic account for the Claude Code CLI

Every dependency section below follows the same three-step pattern: **Check if already installed**, **Install**, **Verify**. Run the detection command first; if it prints a version number, skip to the next section.

## Install Xcode Command Line Tools

These provide basic developer tools (like `git`) that other installers in this guide depend on. Most Macs already have them installed.

### Check if already installed

```
git --version
```

If this prints a version number (e.g. `git version 2.39.5`), skip to [Install Homebrew](#install-homebrew).

### Install

```
xcode-select --install
```

A dialog box appears. Click **Install** and wait a few minutes. When the dialog says the installation is complete, you can close it.

### Verify

```
git --version
```

You should see a line like `git version 2.39.5`. The exact number does not matter.

## Install Homebrew

Homebrew is a tool that lets you install software from the terminal with a single command, similar to an app store but for developer tools. Every remaining install in this guide uses it.

### Check if already installed

```
brew --version
```

If this prints a version number (e.g. `Homebrew 4.4.16`), skip to [Install Node.js](#install-nodejs).

### Install

Paste this command into your terminal:

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the on-screen instructions (you may need to enter your Mac password). The installer takes a few minutes.

When it finishes, the installer tells you to run one more command to make `brew` available. Copy the line it shows you, paste it into the terminal, and press Enter. If you are unsure which line to copy, closing and reopening the terminal works too.

### Verify

```
brew --version
```

You should see something like `Homebrew 4.4.16`. The exact number does not matter.

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

The editor this repository configures.

### Check if already installed

```
ls /Applications/Zed.app >/dev/null 2>&1 || command -v zed >/dev/null 2>&1
```

If either check succeeds, skip to [Install the Claude Code CLI](#install-the-claude-code-cli).

### Install

```
brew install --cask zed
```

Optional: to track the preview channel (nightly-ish builds with newer features), install `zed@preview` alongside (or instead of) stable:

```
brew install --cask zed@preview
```

Both channels can be installed simultaneously; they use separate config directories.

### Verify

Open Zed from Applications or Spotlight (Cmd+Space, type "Zed") to confirm it launches. If the optional `zed` CLI helper is installed, you can also run:

```
zed --version
```

## Install the Claude Code CLI

The `claude` binary; powers both terminal usage and the Zed Agent Panel bridge.

### Check if already installed

```
command -v claude >/dev/null 2>&1 && claude --version
```

If this prints a version, skip the install command below and go directly to the first-run authentication.

### Install

```
brew install --cask claude-code
```

The `claude-code` cask tracks the stable channel (recommended). If you prefer the latest channel, use `brew install --cask claude-code@latest` instead; the two casks cannot usually be installed simultaneously.

### First-run authentication

Run `claude` in any directory:

```
claude
```

It opens a browser to sign into your Anthropic Pro/Max/Team/Enterprise/Console account (free claude.ai accounts are not supported). Authoritative upstream docs: https://code.claude.com/docs/en/setup.

### Verify

```
claude --version
```

Optional deeper health check:

```
claude doctor
```

Note: this authenticates the terminal CLI. Authenticating the Claude Code thread inside Zed is a separate step (see [Authenticate in Zed](#authenticate-in-zed) below).

## Configure claude-acp

**Already configured?** Open `~/.config/zed/settings.json` (or Cmd+, inside Zed) and look for an `agent_servers.claude-acp` block. If it already contains `"type": "registry"`, you can skip straight to [Authenticate in Zed](#authenticate-in-zed).

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

See [settings.md](settings.md#agent_servers) for the full `agent_servers` reference, including environment variables.

## Authenticate in Zed

**Already authenticated?** Open the Agent Panel (Ctrl+?); if a Claude Code thread is already listed and opens without asking you to log in, you can skip to [Install MCP Tools](#install-mcp-tools).

Once `claude-acp` is configured, the Claude Code thread becomes available in Zed's Agent Panel.

1. Open the Agent Panel with **Ctrl+?**
2. Start a new Claude Code thread (the thread picker shows both the built-in agent and the Claude Code bridge)
3. Type `/login` in the thread and follow the prompts

`/login` authenticates the Zed-side thread and is distinct from the first-run `claude` authentication you completed in the terminal. Both are required: the CLI auth unlocks the binary; `/login` unlocks the ACP bridge inside Zed.

## Install MCP Tools

MCP (Model Context Protocol) tools give Claude the ability to edit Word and Excel files properly, preserving formatting and tracked changes. You never interact with these tools directly -- they work behind the scenes when Claude needs them. Both tools below require Node.js to be on your `PATH` (see [Install Node.js](#install-nodejs) above); `npx` is what launches each MCP server.

### SuperDoc -- Word document editing

SuperDoc lets Claude edit `.docx` files with full formatting and tracked-changes support.

#### Check if already installed

```
claude mcp list 2>/dev/null | grep -q '^superdoc' && echo "superdoc present"
```

If this prints `superdoc present`, skip to the openpyxl section.

#### Install

```
claude mcp add --scope user superdoc -- npx @superdoc-dev/mcp
```

#### Verify

```
claude mcp list
```

You should see a `superdoc` entry.

### openpyxl -- Spreadsheet editing

The openpyxl tool lets Claude read and edit `.xlsx` files (values, formulas, rows).

#### Check if already installed

```
claude mcp list 2>/dev/null | grep -q '^openpyxl' && echo "openpyxl present"
```

If this prints `openpyxl present`, skip to the [Verify](#verify) checklist below.

#### Install

```
claude mcp add --scope user openpyxl -- npx @jonemo/openpyxl-mcp
```

#### Verify

```
claude mcp list
```

You should see an `openpyxl` entry alongside `superdoc`. If either is missing, re-run the corresponding `claude mcp add` command with `--scope user`.

## Verify

Run through this checklist end-to-end. Every entry corresponds to one of the dependency sections above; a green check here means the full stack is working.

- [ ] `git --version` prints a version (Xcode CLT)
- [ ] `brew --version` prints a version (Homebrew)
- [ ] `node --version && npx --version` both print versions (Node.js)
- [ ] `zed --version` prints a version, or Zed launches from Applications
- [ ] `claude --version` prints a version
- [ ] `claude doctor` reports a healthy install (optional but recommended)
- [ ] `claude mcp list` shows both `superdoc` and `openpyxl`
- [ ] Zed's Agent Panel (Ctrl+?) offers a Claude Code thread
- [ ] Inside the Claude Code thread, `/login` completes without error
- [ ] Running `/task "test"` from the Claude Code thread creates a task entry

If any step fails, see [Troubleshooting in the agent panel doc](../agent-system/zed-agent-panel.md#troubleshooting).

## See also

- [settings.md](settings.md#agent_servers) — `agent_servers` configuration reference
- [../agent-system/zed-agent-panel.md](../agent-system/zed-agent-panel.md) — How the Agent Panel and claude-acp bridge work at runtime
- [../../.claude/docs/guides/user-installation.md](../../.claude/docs/guides/user-installation.md) — Quick-start reference for the Claude Code framework itself
