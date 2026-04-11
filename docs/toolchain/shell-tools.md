# Shell Tools

The `.claude/` agent system, its hooks, and several commands assume a small set of shell utilities are on PATH. Most are part of a standard Homebrew developer environment; this file documents them for completeness and so a missing utility can be diagnosed quickly.

## Before you begin

Homebrew is required. See [docs/general/installation.md](../general/installation.md) if you do not have it.

## git

Version control — used by every skill that commits task artifacts, and by `/merge` to create pull requests.

### Check

```
git --version
```

If this prints a version, you are done. `git` is provided by the Xcode Command Line Tools covered in [docs/general/installation.md#install-xcode-command-line-tools](../general/installation.md#install-xcode-command-line-tools).

### Install

```
xcode-select --install
```

Or, if you prefer Homebrew's newer git:

```
brew install git
```

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

On macOS, `make` is provided by the Xcode Command Line Tools, so if you ran `xcode-select --install` from [docs/general/installation.md](../general/installation.md#install-xcode-command-line-tools), you already have it.

### Install

If `make` is missing:

```
xcode-select --install
```

Or a newer GNU make via Homebrew:

```
brew install make
```

Note: Homebrew's GNU make is installed as `gmake` to avoid shadowing the system `make`. Use `gmake` or add `$(brew --prefix make)/libexec/gnubin` to your PATH if you need GNU-specific features.

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

Several scripts use `od` and `date` for session ID generation (see [`.claude/rules/git-workflow.md`](../../.claude/rules/git-workflow.md)). Both are part of base macOS; no install needed.

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
