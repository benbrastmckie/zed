# Shell Tools

## Quick install (script)

```
bash scripts/install/install-shell-tools.sh              # interactive
bash scripts/install/install-shell-tools.sh --dry-run    # preview only
bash scripts/install/install-shell-tools.sh --check      # presence report
```

Installs `jq`, `gh`, `fontconfig`, and optionally GNU `make`. Every action is guarded by a presence check and is safe to re-run. See [`scripts/install/install-shell-tools.sh`](../../scripts/install/install-shell-tools.sh) for the exact invocations. The manual walkthrough below is the source of truth for what the script automates.

## Manual installation (advanced)

The `.claude/` agent system, its hooks, and several commands assume a small set of shell utilities are on PATH. Most are part of a standard developer environment; this file documents them for completeness and so a missing utility can be diagnosed quickly.

## Before you begin

Homebrew is required. See [docs/general/installation.md](../general/installation.md) if you do not have it set up.

## git

Version control — used by every skill that commits task artifacts, and by `/merge` to create pull requests.

### Check

```
git --version
```

If this prints a version, you are done. On macOS, `git` is provided by the Xcode Command Line Tools.

### Install

**macOS**:

```
xcode-select --install
```

Or via Homebrew: `brew install git`

### Verify

```
git --version
git config --global user.name   # should print your configured name
```

## jq

JSON processor — used heavily by hook scripts, `skill-status-sync`, context discovery queries against `.claude/context/index.json`, and state.json reads.

### Check

```
jq --version
```

### Install

```
brew install jq
```

### Verify

```
echo '{"a":1}' | jq .a
```

Should print `1`.

> **jq escaping caveat**: Claude Code Issue #1132 causes jq parse errors with the `!=` operator and with `|` inside quoted strings. The agent-system rules (`.claude/rules/error-handling.md`) document the `select(.type == "X" | not)` workaround. This is a harness bug, not a jq install issue.

## gh (GitHub CLI)

Used by `/merge` to create pull requests and by agents working with GitHub Issues or PRs.

### Check

```
gh --version
```

### Install

```
brew install gh
```

### Verify

```
gh --version
gh auth status
```

First-time setup requires `gh auth login` (browser-based OAuth).

## make

Some projects and epidemiology analyses use a `Makefile` for reproducible pipelines.

### Check

```
make --version
```

On macOS, `make` is provided by the Xcode Command Line Tools.

### Install

**macOS** -- if `make` is missing:

```
xcode-select --install
```

Or a newer GNU make via Homebrew: `brew install make` (installs as `gmake` to avoid shadowing the system `make`).

### Verify

```
make --version
```

## fontconfig (optional, for font Check commands)

`fc-list` is used by [typesetting.md](typesetting.md#fonts) to verify that typesetting fonts are installed.

### Check

```
fc-list --version 2>&1 | head -1
```

### Install

```
brew install fontconfig
```

### Verify

```
fc-list | head -1
```

## od / date (already present)

Several scripts use `od` and `date` for session ID generation (see [`.claude/rules/git-workflow.md`](../../.claude/rules/git-workflow.md)). Both are part of macOS; no install needed.

### Check

```
command -v od date
date +%s
od -An -N3 -tx1 /dev/urandom | tr -d ' '
```

The second command prints the current Unix timestamp; the third prints 6 random hex chars.

## See also

- [docs/general/installation.md](../general/installation.md) — base install including Xcode CLT (git, make) and Homebrew
- [docs/toolchain/README.md](README.md) — toolchain directory index
- [`.claude/rules/error-handling.md`](../../.claude/rules/error-handling.md) — jq escaping workarounds for Claude Code Issue #1132
