# Installation

## Installation wizard (recommended)

The interactive installation wizard at `scripts/install/install.sh` walks through six groups of installs (base tools, shell utilities, Python, R, typesetting, MCP servers), lets you accept or skip each group, and is safe to re-run -- every step is guarded by a presence check.

**Supported platforms**: macOS, Debian/Ubuntu, Arch/Manjaro. Distributions with declarative package management are detected and exit with guidance to use the native configuration approach instead.

**Step by step** (macOS):

1. Press **Cmd+Space** to open Spotlight, type **Terminal**, and press Enter to open the Terminal app.
2. Install the Xcode Command Line Tools (provides `git`). A dialog will appear; click **Install** and wait for it to finish:

   ```
   xcode-select --install
   ```

3. Clone this repository into your Zed config directory:

   ```
   git clone <repo-url> ~/.config/zed
   cd ~/.config/zed
   ```

4. Run the wizard:

   ```
   bash scripts/install/install.sh
   ```

   For each group, press **a** to accept (install it), **s** to skip, or **c** to cancel the wizard. Accepted groups are dispatched in a safe topological order (`base` runs first so build tools and the package manager are available for later groups).

**Step by step** (Linux -- Debian/Ubuntu or Arch/Manjaro):

1. Ensure `git` is installed (`sudo apt install git` or `sudo pacman -S git`).
2. Clone this repository into your Zed config directory:

   ```
   git clone <repo-url> ~/.config/zed
   cd ~/.config/zed
   ```

3. Run the wizard:

   ```
   bash scripts/install/install.sh
   ```

   The wizard auto-detects your platform and uses the appropriate package manager (Homebrew on macOS, apt on Debian/Ubuntu, pacman on Arch). Steps requiring sudo use an interactive prompt pattern that defers to a manual hint if no tty is available.

**Non-interactive shortcuts**:

- `bash scripts/install/install.sh --dry-run` — preview every action without installing anything.
- `bash scripts/install/install.sh --check` — health report only (prints which tools are present or missing).
- `bash scripts/install/install.sh --preset minimal` — base + shell-tools only.
- `bash scripts/install/install.sh --preset epi-demo` — base + shell-tools + Python + R + typesetting (everything except the extension MCP servers).
- `bash scripts/install/install.sh --preset writing` — base + shell-tools + typesetting.
- `bash scripts/install/install.sh --preset everything` — all six groups.
- `bash scripts/install/install.sh --only base,python --yes` — pick specific groups and auto-accept prompts.

Each group script (`scripts/install/install-<group>.sh`) can also be run directly and supports the same flags. See [docs/toolchain/README.md](../toolchain/README.md) for a per-group breakdown.

If you prefer to install everything by hand, keep reading — the rest of this page is the authoritative manual walkthrough and is the source of truth for what the wizard automates.

## Manual installation (advanced)

This guide walks through installing Zed, the Claude Code CLI, the `claude-acp` bridge that connects them, and the MCP tools used for Word and Excel editing. The primary walkthrough below uses macOS commands; Linux alternatives are noted in each section. For a fully automated cross-platform install, use the wizard above instead.

> **Already comfortable with the terminal?** Here is the full sequence of install commands. Skip any tool you already have, then jump to [Configure claude-acp](#configure-claude-acp).
>
> ```
> xcode-select --install
> /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
> brew install node
> brew install --cask zed
> brew install --cask claude-code
> claude
> ```

> **Setting up Python or R?** After finishing this guide, see [Python Setup](../toolchain/python.md) or [R Setup](../toolchain/r.md) for language-specific install instructions (interpreters, linters, formatters, and LSP).
>
> **Extension toolchains?** For every external dependency assumed by the `.claude/` agent extensions in this repo (LaTeX, Typst, Pandoc, MCP servers, epidemiology R packages, shell utilities), see [docs/toolchain/README.md](../toolchain/README.md) — the authoritative toolchain reference.

## Before you begin

You will run every command in this guide inside a **terminal emulator**. On macOS, press **Cmd+Space** to open Spotlight, type **Terminal**, and press Enter (you can also find Terminal in Applications > Utilities). On Linux, open your distribution's terminal application (e.g. GNOME Terminal, Konsole, or Alacritty).

When the terminal opens, you see a prompt -- a short line ending in `$` or `%`. To run a command, paste or type it after the prompt and press **Enter**. The examples in this guide show only the command itself, not the prompt character.

If a command produces a lot of output, wait until the prompt appears again before running the next one. That means the previous command has finished.

## Prerequisites

- **macOS**: macOS 11 (Big Sur) or newer
- **Debian/Ubuntu**: A recent release with `apt` available
- **Arch/Manjaro**: A recent release with `pacman` available
- An internet connection
- About 20-30 minutes for initial setup
- An Anthropic account for the Claude Code CLI

Every dependency section below follows the same three-step pattern: **Check if already installed**, **Install**, **Verify**. Run the detection command first; if it prints a version number, skip to the next section.

## Install build tools and git

These provide basic developer tools (like `git` and a C/C++ compiler) that other installers in this guide depend on.

### Check if already installed

```
git --version
```

If this prints a version number (e.g. `git version 2.39.5`), skip to [Install Homebrew](#install-homebrew).

### Install

**macOS** -- Install the Xcode Command Line Tools. A dialog box appears; click **Install** and wait a few minutes:

```
xcode-select --install
```

> **Linux alternatives**:
> - **Debian/Ubuntu**: `sudo apt install build-essential git`
> - **Arch/Manjaro**: `sudo pacman -S base-devel git`

### Verify

```
git --version
```

You should see a line like `git version 2.39.5`. The exact number does not matter.

## Install Homebrew

Homebrew is the macOS package manager used by the remaining install steps in this guide. On Linux, your system package manager (`apt` or `pacman`) is used instead -- skip this section if you are on Linux.

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

Node.js is a programming runtime. You will not write any Node code, but two helper tools later in this guide need it to run.

### Check if already installed

```
node --version
```

If this prints a version number (e.g. `v20.17.0`), skip to [Install Zed](#install-zed).

### Install

```
brew install node
```

> **Linux alternatives**:
> - **Debian/Ubuntu**: `sudo apt install nodejs npm`
> - **Arch/Manjaro**: `sudo pacman -S nodejs npm`

The package manager downloads and installs Node. This takes a minute or two. When you see your terminal prompt again, it is finished.

### Verify

```
node --version
```

You should see a version number like `v20.17.0`.

## Install Zed

Zed is the code editor you will use day-to-day. Think of it as a modern alternative to apps like TextEdit, but built for programming and AI-assisted work.

### Check if already installed

If Zed is already in your Applications folder, skip to [Install the Claude Code CLI](#install-the-claude-code-cli).

### Install

**macOS**:

```
brew install --cask zed
```

Optional: to track the preview channel, install `zed@preview` alongside (or instead of) stable: `brew install --cask zed@preview`. Both channels can be installed simultaneously.

> **Linux alternatives**: Download Zed from [zed.dev](https://zed.dev), or install via your distribution's package manager or the official `.deb`/AUR package.

### Verify

Open Zed from Applications/Spotlight (macOS) or your app launcher (Linux) to confirm it launches.

## Install the Claude Code CLI

This is the AI assistant that runs inside Zed. Installing it here means both your terminal and your editor can use it.

### Check if already installed

```
claude --version
```

If this prints a version number, skip the install command below and go directly to the first-run authentication.

### Install

**macOS**:

```
brew install --cask claude-code
```

The `claude-code` cask tracks the stable channel (recommended). If you prefer the latest channel, use `brew install --cask claude-code@latest` instead.

> **Linux alternatives**: Install via npm (`npm install -g @anthropic-ai/claude-code`) or download directly from [claude.ai/code](https://claude.ai/code). See the [official setup docs](https://code.claude.com/docs/en/setup) for details.

### First-run authentication

Run `claude` in your terminal:

```
claude
```

Your browser opens so you can sign into your Anthropic account (Pro, Max, Team, Enterprise, or Console -- free claude.ai accounts are not supported). Follow the prompts in the browser, then return to the terminal. Authoritative upstream docs: https://code.claude.com/docs/en/setup.

### Verify

```
claude --version
```

You should see a version number. Optional deeper health check:

```
claude doctor
```

Note: this authenticates the terminal CLI. Authenticating the Claude Code thread inside Zed is a separate step (see [Authenticate in Zed](#authenticate-in-zed) below).

## Configure claude-acp

This step connects Zed to the Claude Code CLI you installed above. You only need to do it once.

**Already configured?** In Zed, press **Cmd+,** to open your settings file and look for an `agent_servers` block. If it already contains `"claude-acp"` with `"type": "registry"`, skip to [Authenticate in Zed](#authenticate-in-zed).

In Zed, press **Cmd+,** to open your settings file (`~/.config/zed/settings.json`). Scroll to the bottom and paste the following block before the closing `}`:

```jsonc
"agent_servers": {
  "claude-acp": {
    "type": "registry",
    "env": {}
  }
}
```

Save the file (**Cmd+S**) and restart Zed to pick up the change.

See [settings.md](settings.md#agent_servers) for the full `agent_servers` reference, including environment variables.

## Authenticate in Zed

This step links your Anthropic account to the Claude Code thread inside Zed. It is separate from the terminal authentication you completed earlier -- both are required.

**Already authenticated?** Open the Agent Panel (**Ctrl+?**). If a Claude Code thread is already listed and opens without asking you to log in, skip to [Install MCP Tools](#install-mcp-tools).

1. Open the Agent Panel with **Ctrl+?**
2. Start a new Claude Code thread (the thread picker shows both the built-in agent and the Claude Code bridge)
3. Type `/login` in the thread and follow the prompts

## Install MCP Tools

These tools run behind the scenes -- you install them once and forget about them. They let Claude edit Word and Excel files properly, preserving formatting and tracked changes. Both require the Node.js you installed earlier.

### SuperDoc -- Word document editing

SuperDoc lets Claude edit `.docx` files with full formatting and tracked-changes support.

#### Check if already installed

```
claude mcp list
```

Look through the output for a line that starts with `superdoc`. If you see it, skip to the openpyxl section below.

#### Install

```
claude mcp add --scope user superdoc -- npx @superdoc-dev/mcp
```

#### Verify

```
claude mcp list
```

You should see a `superdoc` entry in the list.

### openpyxl -- Spreadsheet editing

The openpyxl tool lets Claude read and edit `.xlsx` files (values, formulas, rows).

#### Check if already installed

```
claude mcp list
```

Look for a line that starts with `openpyxl`. If you see it, skip to the [Verify](#verify) checklist below.

#### Install

```
claude mcp add --scope user openpyxl -- npx @jonemo/openpyxl-mcp
```

#### Verify

```
claude mcp list
```

You should see both `superdoc` and `openpyxl` in the list. If either is missing, re-run the corresponding `claude mcp add` command above.

## Verify

Run each command below in your terminal. If every one prints a version number or success message, you are done.

1. `git --version` -- should print a version (Xcode CLT)
2. `brew --version` -- should print a version (Homebrew)
3. `node --version` -- should print a version (Node.js)
4. `claude --version` -- should print a version (Claude Code CLI)
5. `claude doctor` -- should report a healthy install (optional but recommended)
6. `claude mcp list` -- should show both `superdoc` and `openpyxl`

Then confirm the Zed integration:

7. Open Zed and press **Ctrl+?** to open the Agent Panel -- you should see a Claude Code thread option
8. Start a Claude Code thread and type `/login` -- it should complete without error
9. Type `/task "test"` in the Claude Code thread -- it should create a task entry

If any step fails, see [Troubleshooting in the agent panel doc](../agent-system/zed-agent-panel.md#troubleshooting).

## See also

- [../toolchain/README.md](../toolchain/README.md) — Toolchain reference: every external dependency assumed by the `.claude/` extensions (LaTeX, Typst, Pandoc, MCP servers, epi R packages, shell tools)
- [../toolchain/python.md](../toolchain/python.md) — Python setup guide (interpreter, uv, ruff, Zed configuration)
- [../toolchain/r.md](../toolchain/r.md) — R setup guide (interpreter, languageserver, lintr, styler, Zed configuration)
- [settings.md](settings.md#agent_servers) — `agent_servers` configuration reference
- [../agent-system/zed-agent-panel.md](../agent-system/zed-agent-panel.md) — How the Agent Panel and claude-acp bridge work at runtime
- [../toolchain/slidev.md](../toolchain/slidev.md) — Slidev CLI, Playwright browsers, and Zed keybindings
- [../../.claude/docs/guides/user-installation.md](../../.claude/docs/guides/user-installation.md) — Quick-start reference for the Claude Code framework itself
