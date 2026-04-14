# Toolchain Reference

> **Quick install**: all dependencies below can be installed non-interactively via the wizard at [`scripts/install/install.sh`](../../scripts/install/) — see [docs/general/installation.md](../general/installation.md#installation-wizard-recommended) for the step-by-step walkthrough. Each per-group script (`install-<group>.sh`) can also be run directly and supports `--dry-run`, `--check`, `--yes`, and `--help`. The sections in this directory remain the authoritative manual walkthrough and are the source of truth for what the wizard automates.

This directory documents every **external dependency** assumed by the active `.claude/` extensions in this repository. It is the single authoritative source for "what do I need to install so that the extensions in this repo actually work."

The parent [docs/general/installation.md](../general/installation.md) covers the base environment (Zed, Claude Code CLI, package manager, Node.js, the two MCP tools required by `filetypes`). Everything here is **in addition to** that base install: language runtimes (R, Python), typesetting tools (LaTeX, Typst, Pandoc), additional MCP servers, extension-specific prerequisites, and the small set of shell utilities the agents assume are present.

## Platform scope

All tools are documented with cross-platform install commands for **macOS** (Homebrew), **Debian/Ubuntu** (apt), and **Arch/Manjaro** (pacman). Each tool section shows the macOS command inline, with Linux alternatives in a callout block. The install wizard (`scripts/install/install.sh`) auto-detects the platform and uses the correct package manager; these docs are the manual equivalent.

> **Note**: The wizard auto-detects the current platform. On distributions that use declarative package management, it exits with guidance to use the native configuration approach instead of the imperative instructions here.

The canonical package name mapping lives in [`scripts/install/lib.sh`](../../scripts/install/lib.sh) (`_pkg_map_add` entries). When docs and lib.sh disagree, lib.sh is the source of truth.

### Cross-platform package reference

| Tool | Homebrew (macOS) | apt (Debian/Ubuntu) | pacman (Arch/Manjaro) |
|------|-----------------|--------------------|-----------------------|
| jq | `jq` | `jq` | `jq` |
| gh | `gh` | `gh` | `github-cli` |
| fontconfig | `fontconfig` | `fontconfig` | `fontconfig` |
| make | `make` | `make` | `make` |
| Node.js | `node` | `nodejs` | `nodejs` |
| npm | (included with `node`) | `npm` | `npm` |
| Python | `python` | `python3` | `python` |
| R | `r` | `r-base` + `r-base-dev` | `r` |
| Pandoc | `pandoc` | `pandoc` | `pandoc` |
| Typst | `typst` | (not in repos; use `cargo install typst-cli` or `snap install typst`) | `typst` |
| C++ toolchain | Xcode CLT | `build-essential` | `base-devel` |
| git | `git` | `git` | `git` |
| curl | `curl` | `curl` | `curl` |
| LaTeX (basic) | `basictex` (cask) | `texlive-base texlive-latex-extra latexmk biber` | `texlive-basic texlive-latexextra texlive-binextra biber` |
| LaTeX (full) | `mactex` (cask) | `texlive-full` | `texlive-most` |
| Fonts (Latin Modern) | `font-latin-modern` + `font-latin-modern-math` (cask) | `fonts-lmodern fonts-cmu` | `otf-latin-modern noto-fonts` |
| Fonts (Noto) | `font-noto-sans` + `font-noto-serif` + `font-noto-sans-mono` (cask) | `fonts-noto fonts-noto-cjk` | `noto-fonts noto-fonts-cjk` |

Your platform's package manager is a prerequisite for every install step below. On macOS, install [Homebrew](https://brew.sh) first; on Linux, `apt` or `pacman` is already present. See [docs/general/installation.md](../general/installation.md) for the base setup.

## File index

| File | Covers |
|------|--------|
| [r.md](r.md) | R interpreter, `languageserver`, `lintr`, `styler`, `renv`, Quarto, rmcp MCP prereqs |
| [python.md](python.md) | Python interpreter, `uv`/`uvx`, `ruff`, pytest, mypy, and Python packages used by MCP servers and extensions |
| [typesetting.md](typesetting.md) | LaTeX (MacTeX/BasicTeX), Typst, Pandoc, markitdown, and required fonts |
| [mcp-servers.md](mcp-servers.md) | MCP servers beyond those in installation.md: obsidian-memory, rmcp, markitdown-mcp, mcp-pandoc (plus the recorded Lean MCP decision) |
| [extensions.md](extensions.md) | Per-extension prerequisite summary — points into the other files and lists any extension-specific extras |
| [slidev.md](slidev.md) | Slidev CLI, Playwright browsers, Zed integration |
| [shell-tools.md](shell-tools.md) | Shell utilities assumed present: `jq`, `gh`, `git`, `make` |

## Check / Install / Verify template

Every dependency in this directory is documented with the same three-section structure, mirroring the gold-standard pattern from `.claude/context/project/filetypes/tools/dependency-guide.md` and the existing `docs/general/installation.md`:

### Check

A single command the reader can run to detect whether the tool is already present, and a note on what a "yes" result looks like (so they can skip the install step if applicable).

```
command -v <tool> && <tool> --version
```

### Install

The platform-appropriate install command. macOS commands use Homebrew; Linux alternatives are shown in a callout block. Always a single runnable block the reader can copy.

```
brew install <formula>           # macOS
sudo apt install <package>       # Debian/Ubuntu
sudo pacman -S <package>         # Arch/Manjaro
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

A few pieces of infrastructure referenced from `.claude/` are **not project dependencies** — they are the author's personal UX layer. These are intentionally not documented here:

- WezTerm hooks (`.claude/hooks/wezterm-*.sh`) — require WezTerm specifically; no-op on other terminals.
- Piper TTS (`.claude/hooks/tts-notify.sh`) — requires `piper` binary + a voice model file at a hardcoded path.
- Some hooks reference external scripts not included in this repository.

None of the agent-system functionality in this repo depends on them.

## Follow-on work

A future `/doctor` command (tracked as a follow-on meta task) will automate `command -v` checks against the contents of this directory, removing the need to read through each file manually before onboarding or after environment changes. Until then, a quick sanity pass is `command -v R python3 uv ruff typst pandoc jq gh`.

## See also

- [docs/general/installation.md](../general/installation.md) — base install (Homebrew, Node.js, Zed, Claude Code CLI, SuperDoc, openpyxl)
- [docs/general/README.md](../general/README.md) — documentation index
- [.claude/context/project/filetypes/tools/dependency-guide.md](../../.claude/context/project/filetypes/tools/dependency-guide.md) — gold-standard template this directory mirrors
