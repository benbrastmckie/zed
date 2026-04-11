# Toolchain Reference

This directory documents every **external dependency** assumed by the active `.claude/` extensions in this repository. It is the single authoritative source for "what do I need to install so that the extensions in this repo actually work."

The parent [docs/general/installation.md](../general/installation.md) covers the base environment (Zed, Claude Code CLI, Homebrew, Node.js, the two MCP tools required by `filetypes`). Everything here is **in addition to** that base install: language runtimes (R, Python), typesetting tools (LaTeX, Typst, Pandoc), additional MCP servers, extension-specific prerequisites, and the small set of shell utilities the agents assume are present.

## Platform scope

This documentation is **macOS / Homebrew only**. Linux install paths (apt, nix, pacman, dnf) are explicitly out of scope per the task-21 "macOS Zed IDE" reframing. If you are installing on another platform, consult the relevant upstream docs directly; the Check / Verify sections below still apply regardless of platform.

Homebrew itself is a prerequisite for every install step below. If you do not have it yet, follow [docs/general/installation.md](../general/installation.md) first.

## File index

| File | Covers |
|------|--------|
| [r.md](r.md) | R interpreter, `languageserver`, `lintr`, `styler`, `renv`, Quarto, rmcp MCP prereqs |
| [python.md](python.md) | Python interpreter, `uv`/`uvx`, `ruff`, pytest, mypy, and Python packages used by MCP servers and extensions |
| [typesetting.md](typesetting.md) | LaTeX (MacTeX/BasicTeX), Typst, Pandoc, markitdown, and required fonts |
| [mcp-servers.md](mcp-servers.md) | MCP servers beyond those in installation.md: obsidian-memory, rmcp, markitdown-mcp, mcp-pandoc (plus the recorded Lean MCP decision) |
| [extensions.md](extensions.md) | Per-extension prerequisite summary — points into the other files and lists any extension-specific extras |
| [shell-tools.md](shell-tools.md) | Shell utilities assumed present: `jq`, `gh`, `git`, `make` |

## Check / Install / Verify template

Every dependency in this directory is documented with the same three-section structure, mirroring the gold-standard pattern from `.claude/context/project/filetypes/tools/dependency-guide.md` and the existing `docs/general/installation.md`:

### Check

A single command the reader can run to detect whether the tool is already present, and a note on what a "yes" result looks like (so they can skip the install step if applicable).

```
command -v <tool> && <tool> --version
```

### Install

The Homebrew command (or, for Python/R packages, the in-runtime install command). Always a single runnable block the reader can copy.

```
brew install <formula>
```

### Verify

A follow-up command to confirm the install succeeded, plus any post-install sanity check. This should be distinct from Check — Verify confirms a successful install where Check was a pre-install detection.

```
<tool> --version
```

When writing a new toolchain doc, copy the three sub-headings (**Check**, **Install**, **Verify**) verbatim for every tool so the file stays greppable and consistent.

## Network at runtime

Several tools documented here require **network access at runtime**, not just at install time. This is worth flagging explicitly because it can cause confusing failures in restricted environments:

- `typst compile` fetches packages from `packages.typst.app` on first compile of a file that `#import`s a new package.
- `renv::restore()` hits CRAN.
- `uvx <tool>` fetches the tool (and dependencies) on first invocation and caches them.
- `npx -y @...@latest` re-fetches on every invocation when given `@latest`.
- Stan-backed R packages (`brms`, `EpiNow2`) download CmdStan on first use.

Individual toolchain docs note this per tool where relevant.

## Optional author-personal tooling

A few pieces of infrastructure referenced from `.claude/` are **not project dependencies** — they are the author's personal UX layer shared with the Neovim config repository. These are intentionally not documented here:

- WezTerm hooks (`.claude/hooks/wezterm-*.sh`) — require WezTerm specifically; no-op on other terminals.
- Piper TTS (`.claude/hooks/tts-notify.sh`) — requires `piper` binary + a voice model file at a hardcoded path.
- The `SessionStart` hook reference to `~/.config/nvim/scripts/claude-ready-signal.sh` — only works when the author's Neovim config is co-installed.

If you want any of these, consult the author's dotfiles / nvim config repositories. None of the agent-system functionality in this repo depends on them.

## Follow-on work

A future `/doctor` command (tracked as a follow-on meta task) will automate `command -v` checks against the contents of this directory, removing the need to read through each file manually before onboarding or after environment changes. Until then, a quick sanity pass is `command -v R python3 uv ruff typst pandoc jq gh`.

## See also

- [docs/general/installation.md](../general/installation.md) — base install (Homebrew, Node.js, Zed, Claude Code CLI, SuperDoc, openpyxl)
- [docs/general/README.md](../general/README.md) — documentation index
- [.claude/context/project/filetypes/tools/dependency-guide.md](../../.claude/context/project/filetypes/tools/dependency-guide.md) — gold-standard template this directory mirrors
