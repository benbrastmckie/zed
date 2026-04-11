# Research Report: Revise docs/installation.md to target macOS only

**Task**: #7 - revise_installation_md_macos
**Date**: 2026-04-10
**Session**: sess_1775851753_218c6d
**Status**: Complete

## Executive Summary

The current `docs/installation.md` is already macOS-first but retains a NixOS platform-notes section and an outdated Claude Code install command. The revision should (1) delete all NixOS references, (2) switch Claude Code to the current official cask `brew install --cask claude-code`, (3) add a Node.js section (required by the SuperDoc and openpyxl MCP tools via `npx`), and (4) apply a uniform "check if already installed -> install -> verify" pattern to every dependency section. Recommended dependency order: Xcode Command Line Tools (git) -> Homebrew -> Node.js -> Zed -> Claude Code CLI -> claude-acp bridge config -> MCP tools (SuperDoc, openpyxl) -> Zed-side authentication -> end-to-end verification.

## Context

Task #7 requests a rewrite of `docs/installation.md` targeted exclusively at macOS users who have only WezTerm (or the default macOS Terminal) installed. Each section must guide users to detect whether a dependency is already present and skip to the next step if so. The current file has NixOS content to remove and was authored assuming a more knowledgeable reader; the new version should be strictly linear and self-skipping.

## Current State Audit

### NixOS references to remove

All NixOS / nix-profile mentions live in a handful of locations. Inventory:

- `docs/installation.md:3` - intro sentence: "see [Platform Notes](#platform-notes) at the bottom for NixOS adjustments". Remove the trailing clause.
- `docs/installation.md:137-154` - entire `## Platform Notes` -> `### NixOS` subsection, including the hard-coded `/home/benjamin/.nix-profile/bin/npx` custom `agent_servers` block. Delete the whole section.
- `docs/installation.md:141` - prose mentioning `~/.nix-profile` path assumptions.
- `docs/installation.md:147` - literal `"command": "/home/benjamin/.nix-profile/bin/npx"`.
- `docs/installation.md:154` - "Homebrew is not used on NixOS; install Zed and the Claude Code CLI via Nix..."

### Adjacent docs with NixOS content (out of scope but worth noting)

These are NOT part of task #7 but are cross-referenced from `installation.md` and mention NixOS:

- `docs/settings.md:79` - "...for platforms where the registry version does not work, such as NixOS".
- `docs/settings.md:94-107` - `#### Custom config (NixOS and other non-standard setups)` subsection with the `/home/benjamin/.nix-profile/bin/npx` example.
- `docs/settings.md:136,148` - `"nix": true` auto-install entry and its description (Nix *language* support in Zed; unrelated to NixOS the OS and should stay).
- `docs/agent-system/zed-agent-panel.md:58` - "...and the NixOS notes in [../installation.md](../installation.md#platform-notes)". This inbound link will break after the revision; must be updated or removed in the same PR or flagged as follow-up.

### Outdated / incorrect content to fix while revising

- `docs/installation.md:12,56` - `brew install anthropics/claude/claude-code` uses a third-party tap path. The current official Homebrew cask is `brew install --cask claude-code` (or `claude-code@latest` for the latest channel). Source: https://code.claude.com/docs/en/setup. The revision should switch to the official cask.
- `docs/installation.md:57` - `claude auth login` is documented as the CLI auth step, but the current official docs say to simply run `claude` and follow browser prompts; there is no `claude auth login` subcommand in the current CLI. Recommend: replace with `claude` (first run) or direct users to run `claude` inside any directory and follow the authentication prompt. Keep the distinction from the Zed-side `/login` step.
- `docs/installation.md:45-51` - mentions `brew install --cask zed@preview` for the preview channel. This still works; keep but optional.
- `docs/installation.md:104,112` - MCP tools are installed with `npx @superdoc-dev/mcp` and `npx @jonemo/openpyxl-mcp`. These require Node.js on PATH. The current file does not list Node as a dependency, which is a gap the revision must close.

### Structure of the current file

```
Line  Section
1     # Installation
3     (intro paragraph)
5     ## Summary (4-command quick start)
18    ## Prerequisites
25    ## Install Homebrew
39    ## Install Zed
53    ## Install the Claude Code CLI
68    ## Configure claude-acp
85    ## Authenticate in Zed
95    ## Install MCP Tools
99    ### SuperDoc -- Word document editing
107   ### openpyxl -- Spreadsheet editing
115   ### Verify both tools
123   ## Verify
137   ## Platform Notes
139   ### NixOS                                    [DELETE]
156   ## See also
```

The ordering is reasonable but missing Node.js as an explicit step, and the per-section pattern is inconsistent: Homebrew has a verification step, Zed does not, Claude Code has one, MCP tools share a single verification. The revision should unify this and insert a detection block at the top of each section.

## Dependencies Required

| # | Dependency | Why it is needed | Source |
|---|------------|------------------|--------|
| 1 | Xcode Command Line Tools | Provides `git`, compilers, and headers required by Homebrew. Usually preinstalled or triggered on first `git` run. | https://developer.apple.com/xcode/resources/ |
| 2 | Homebrew | macOS package manager; used to install Zed, Node, and Claude Code. | https://brew.sh |
| 3 | Node.js (with npm/npx) | Required by `npx` used to run the SuperDoc and openpyxl MCP servers. Not required by Claude Code itself, but required by the MCP tools this repo installs. | https://nodejs.org |
| 4 | Zed | The editor this configuration targets. | https://zed.dev/docs/getting-started |
| 5 | Claude Code CLI | The `claude` binary; powers both terminal usage and the Zed Agent Panel bridge. | https://code.claude.com/docs/en/setup |
| 6 | `@zed-industries/claude-agent-acp` bridge | Connects Zed Agent Panel to Claude Code CLI over ACP. Managed by Zed when `agent_servers` uses `"type": "registry"` on macOS (no manual install needed). | https://github.com/zed-industries/claude-code-acp |
| 7 | SuperDoc MCP (`@superdoc-dev/mcp`) | Lets Claude edit `.docx` files with tracked changes. | https://www.npmjs.com/package/@superdoc-dev/mcp |
| 8 | openpyxl MCP (`@jonemo/openpyxl-mcp`) | Lets Claude edit `.xlsx` files (values, formulas, rows). | https://www.npmjs.com/package/@jonemo/openpyxl-mcp |
| 9 | WezTerm *or* macOS Terminal | Assumed present; not a section. WezTerm preferred. | https://wezterm.org |

Git is provided by (1) and does not need its own section. `ripgrep` ships with Claude Code by default, so no section is needed.

## Per-Dependency Details

### 1. Xcode Command Line Tools (git, compilers)

- **Purpose**: Provides `git` and the compiler toolchain Homebrew needs.
- **Detection command**: `xcode-select -p >/dev/null 2>&1 && git --version`
  - Exits 0 if installed. Prints the developer-dir path and git version.
- **Install command (macOS)**: `xcode-select --install`
  - Opens a GUI installer. Takes several minutes.
- **Verification**: `git --version`
- **Minimum version**: Any recent macOS (11+) ships a compatible toolchain; no specific version pin.
- **Official source**: https://developer.apple.com/xcode/resources/

### 2. Homebrew

- **Purpose**: macOS package manager used for everything else below.
- **Detection command**: `command -v brew >/dev/null 2>&1 && brew --version`
- **Install command (macOS)**:
  ```bash
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  ```
  Follow on-screen prompts (requires user password for sudo). After install, restart the terminal or run the `eval "$(...)"` line it prints so `brew` is on `PATH` (on Apple Silicon this is `eval "$(/opt/homebrew/bin/brew shellenv)"`).
- **Verification**: `brew --version` (should print `Homebrew X.Y.Z`).
- **Minimum version**: None; the install script always yields a current release.
- **Official source**: https://brew.sh

### 3. Node.js

- **Purpose**: Provides `node`, `npm`, and `npx`. The MCP tools (SuperDoc, openpyxl) are run via `npx`, so Node must be on `PATH` before those sections.
- **Detection command**: `command -v node >/dev/null 2>&1 && node --version && command -v npx >/dev/null 2>&1`
- **Install command (macOS)**: `brew install node`
- **Verification**: `node --version && npx --version`
- **Minimum version**: Node.js 18 LTS or newer (Claude Code's own optional npm install path requires Node 18+; MCP tools inherit this baseline). `brew install node` installs the current LTS by default, which is well above 18.
- **Official source**: https://nodejs.org/en/download

### 4. Zed

- **Purpose**: The editor this repository configures.
- **Detection command**: `ls /Applications/Zed.app >/dev/null 2>&1 || command -v zed >/dev/null 2>&1`
  - True if either the app bundle exists in `/Applications` or the `zed` CLI shim is on PATH.
- **Install command (macOS)**: `brew install --cask zed`
  - Optional preview channel: `brew install --cask zed@preview` (can be installed alongside stable).
- **Verification**: open from Applications / Spotlight; or in terminal `zed --version` (if the CLI helper was installed; otherwise launching the app is enough).
- **Minimum version**: Any recent Zed; `claude-code-extension` works on current stable.
- **Official source**: https://zed.dev/docs/getting-started

### 5. Claude Code CLI

- **Purpose**: The `claude` binary; powers the terminal workflow and, via the ACP bridge, the Zed Agent Panel.
- **Detection command**: `command -v claude >/dev/null 2>&1 && claude --version`
- **Install command (macOS)**: `brew install --cask claude-code`
  - `claude-code` tracks the stable channel (recommended).
  - `claude-code@latest` tracks the latest channel (newer features, possibly less stable). The two casks can be swapped but not installed simultaneously in most setups.
- **Verification**: `claude --version`, then `claude doctor` for a detailed health check.
- **First-run authentication**: Run `claude` in any directory; it opens a browser to sign into your Anthropic Pro/Max/Team/Enterprise/Console account (free claude.ai accounts are not supported). This is separate from the Zed-side `/login` described below.
- **Minimum version**: Any currently shipping release; the Homebrew cask always pins a recent build.
- **Official source**: https://code.claude.com/docs/en/setup

### 6. `claude-acp` bridge (Zed side, registry config)

- **Purpose**: Zed's Agent Panel talks to `claude` through the `@zed-industries/claude-agent-acp` bridge.
- **Detection**: inspect `~/.config/zed/settings.json` for an `agent_servers.claude-acp` block. On macOS the recommended form is `"type": "registry"`.
- **Install**: no binary to install; Zed downloads and manages the bridge when the registry config is present.
- **Configuration** (to paste into `settings.json`):
  ```jsonc
  "agent_servers": {
    "claude-acp": {
      "type": "registry",
      "env": {}
    }
  }
  ```
- **Verification**: after restarting Zed, open the Agent Panel (Cmd+Shift+?) and confirm a "Claude Code" thread option appears.
- **Source of truth**: `docs/settings.md#agent_servers`, upstream https://github.com/zed-industries/claude-code-acp

### 7. SuperDoc MCP (`@superdoc-dev/mcp`)

- **Purpose**: Enables Claude to edit `.docx` files with full formatting and tracked changes.
- **Detection command**: `claude mcp list 2>/dev/null | grep -q '^superdoc'`
- **Install command (macOS)**:
  ```bash
  claude mcp add --scope user superdoc -- npx @superdoc-dev/mcp
  ```
  Requires Node.js (section 3) for `npx`.
- **Verification**: `claude mcp list` shows `superdoc`.
- **Minimum version**: unpinned (fetched on first run by `npx`).
- **Official source**: https://www.npmjs.com/package/@superdoc-dev/mcp

### 8. openpyxl MCP (`@jonemo/openpyxl-mcp`)

- **Purpose**: Enables Claude to read and edit `.xlsx` files.
- **Detection command**: `claude mcp list 2>/dev/null | grep -q '^openpyxl'`
- **Install command (macOS)**:
  ```bash
  claude mcp add --scope user openpyxl -- npx @jonemo/openpyxl-mcp
  ```
- **Verification**: `claude mcp list` shows `openpyxl`.
- **Official source**: https://www.npmjs.com/package/@jonemo/openpyxl-mcp

## Recommended Section Order

1. **Prerequisites** (macOS 11+, internet, WezTerm or Terminal, 20-30 min, Anthropic account).
2. **Summary / four-line quickstart** for experienced readers (optional; can be kept at top as in current version).
3. **Xcode Command Line Tools** (unlocks `git`, needed by Homebrew; detection-first so most users skip immediately).
4. **Homebrew** (package manager, precondition for all `brew` steps).
5. **Node.js** (precondition for MCP tools; installed early so later sections just work).
6. **Zed** (the editor itself).
7. **Claude Code CLI** (terminal binary + first-run browser auth).
8. **Configure `agent_servers` in Zed settings** (paste the registry block; restart Zed).
9. **Authenticate in Zed** (`/login` inside the Agent Panel thread; explicitly distinct from step 7's CLI auth).
10. **Install MCP Tools** (SuperDoc, then openpyxl; both rely on Node from step 5).
11. **End-to-end Verify checklist** (all detection commands plus the Zed panel smoke test).
12. **See also / Next steps** (links to `settings.md`, `agent-system/zed-agent-panel.md`, `office-workflows.md`, `.claude/docs/guides/user-installation.md`).

Rationale: dependencies strictly precede their dependents (git -> brew -> node/zed/claude -> bridge/mcp -> verify). The order matches the mental model "install binaries, then configure, then authenticate, then verify," which lets users cleanly resume mid-flow.

## Proposed Section Template

Every dependency section after Prerequisites should follow this exact shape so the page reads consistently and users can skip past anything already present.

````markdown
## N. <Dependency Name>

<One-sentence purpose: why this dependency is needed in this setup.>

### Check if already installed

```bash
<detection command>
```

If the command prints a version (and exits without error), skip to [Section N+1](#section-anchor).

### Install

```bash
<install command>
```

<1-3 sentences of install notes: password prompts, PATH activation, alternate channels, etc.>

### Verify

```bash
<verification command>
```

Expected output: <what the user should see>.
````

Concrete example for Node.js:

````markdown
## 5. Node.js

Node.js provides `npx`, which is used to launch the SuperDoc and openpyxl MCP servers that let Claude edit Word and Excel files.

### Check if already installed

```bash
command -v node >/dev/null && node --version && command -v npx >/dev/null
```

If this prints a Node version (e.g. `v20.17.0`) and exits cleanly, skip to [Install Zed](#6-zed).

### Install

```bash
brew install node
```

Homebrew installs the current LTS. Node 18 or newer is required by the MCP tools; the default Homebrew release is well above that.

### Verify

```bash
node --version && npx --version
```

You should see a Node version on one line and an npx version on the next.
````

## Cross-References

Files that reference `docs/installation.md` or its sections and may need companion updates:

- `docs/installation.md:135` - points at `agent-system/zed-agent-panel.md#troubleshooting` on failure; verify anchor still exists after any edits.
- `docs/installation.md:158-160` - "See also" links to `settings.md#agent_servers`, `agent-system/zed-agent-panel.md`, and `.claude/docs/guides/user-installation.md`; keep these, but drop any that reference the deleted Platform Notes anchor.
- `docs/agent-system/zed-agent-panel.md:58` - links to `../installation.md#platform-notes`. **Will break** once the NixOS section is removed. Fix in the same PR: either drop the sentence or repoint to the upstream `zed-industries/claude-code-acp` README for non-standard setups.
- `docs/settings.md:79,94-107` - still mentions NixOS as the exemplar for `"type": "custom"`. Out of scope for task #7, but worth flagging as a follow-up task so both files agree.
- `docs/README.md:7` and `docs/office-workflows.md:186` - reference installation.md anchors; verify they still resolve after the rewrite (`#install-mcp-tools`, Homebrew troubleshooting).
- `README.md` (repo root) - quickstart at lines 9-14 references `brew install --cask zed` and links to `docs/installation.md`; should continue to work unchanged.
- `settings.json:138-145` - the live config uses `"type": "custom"` pointing at a NixOS `npx` path. This is the author's development machine and is deliberately not macOS; leave it alone but note in the new installation.md that the example config shown is the macOS-recommended registry form, not what is currently in `settings.json`.

## Open Questions

1. **Claude Code auth wording**: current docs use `claude auth login`, but the upstream docs only mention running `claude` and following the browser prompt. Confirm which form the user wants documented. Recommendation: use `claude` (canonical) and note in prose that the browser window authenticates the CLI binary.
2. **Preview channel**: keep the `zed@preview` and `claude-code@latest` mentions or drop them to reduce noise for first-time setup? Recommendation: keep as short notes inside the Install section, not as separate subsections.
3. **Xcode CLT section**: should this be promoted to its own numbered section, or folded into a one-line note under "Prerequisites"? Recommendation: make it Section 1 with the detection-first template, because users who lack it will hit an error halfway through the Homebrew install.
4. **Cross-doc NixOS cleanup**: should the revision also strip NixOS from `docs/settings.md` and `docs/agent-system/zed-agent-panel.md`, or defer that to a follow-up task? Recommendation: defer, but at minimum fix the broken `#platform-notes` anchor in `zed-agent-panel.md` within the same PR to avoid a dangling link.
5. **`claude doctor`**: include a mention in the Verify checklist for a deeper health check? Recommendation: yes, as an optional one-liner in the Claude Code section.

## Context Extension Recommendations

None required. This task is a documentation rewrite against external reference material (brew.sh, code.claude.com, nodejs.org, zed.dev); the relevant sources are single-page docs that do not warrant a new context file.

## Sources

- https://brew.sh (Homebrew official install command)
- https://code.claude.com/docs/en/setup (Claude Code system requirements, install methods, Homebrew cask, verification)
- https://nodejs.org/en/download (Node.js install; Node 18+ required for npm-based tools)
- https://zed.dev/docs/getting-started (Zed install for macOS)
- https://www.npmjs.com/package/@superdoc-dev/mcp (SuperDoc MCP server package)
- https://www.npmjs.com/package/@jonemo/openpyxl-mcp (openpyxl MCP server package)
- https://github.com/zed-industries/claude-code-acp (ACP bridge upstream)
- Local repository files cited inline throughout this report (paths with `file:line` references).
