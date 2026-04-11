# Research Report: Task #31 — Teammate B (Alternative Approaches & Prior Art)

**Task**: 31 - toolchain_installation_scripts
**Teammate**: B (Alternative Patterns & Prior Art)
**Started**: 2026-04-10
**Completed**: 2026-04-10
**Effort**: ~1h
**Dependencies**: task 30 (toolchain docs), teammate A (primary shell-script approach)
**Sources/Inputs**:
- `/home/benjamin/.dotfiles/install.sh`, `update.sh`, `.claude/scripts/install-extension.sh`
- `/home/benjamin/.config/nvim/scripts/check-dependencies.sh`, `setup-with-claude.sh`
- `/home/benjamin/.config/zed/docs/toolchain/*.md`, `docs/general/installation.md`
- General knowledge of Brewfile / gum / whiptail / Just / Make / rustup / nvm / pyenv idioms
**Artifacts**: `specs/031_toolchain_installation_scripts/reports/01_teammate-b-findings.md`
**Standards**: report-format.md, plan-format-enforcement.md

## Executive Summary

- Substantive prior art exists in this user's adjacent repos: `~/.config/nvim/scripts/check-dependencies.sh` and `setup-with-claude.sh` are near-perfect templates for (a) a color-coded `check_command` helper and (b) an interactive sectioned wizard with `print_section` / `print_success` / `print_warning`. These should be **directly adapted**, not reinvented.
- A pure **Brewfile + `brew bundle`** approach is tempting but **does not fit** because ~40% of the toolchain install verbs in `docs/toolchain/` are not brew — `install.packages()` (R, runs inside the R REPL), `uv tool install`, `uvx`, `pip install`, `claude mcp add`, `npm install -g @slidev/cli`. A Brewfile would only cover the brew subset and we'd still need shell scripts for the rest, doubling the surface area.
- **Recommended hybrid**: one shell script per toolchain doc (matches task spec) with a shared `_lib.sh` providing logging / prompting / `check_command` helpers adapted from nvim's `check-dependencies.sh`. Master wizard uses a plain bash `read -p` accept/skip/cancel loop — no `gum`/`whiptail` dependency, since requiring a TUI library before running the installer is a chicken-and-egg problem on a fresh Mac.
- Consider generating (optional, non-canonical) **per-group Brewfiles as a side artifact** that power users can feed to `brew bundle --file=` if they want declarative/idempotent batch install. This is additive; it does not replace the scripts.
- The nvim repo's wizard has one anti-pattern worth flagging: it uses `read -p "Press Enter after..."` as a poor-man's pause, which is cancel-hostile. The master wizard should use a proper 3-choice prompt (`[a]ccept / [s]kip / [c]ancel`) with an explicit default.
- Reject Nix / home-manager / `gum` / `whiptail` / Just / Make-target idioms for this task. Rationale captured below.

## Context & Scope

Task 31 requires per-toolchain install scripts plus an interactive master wizard that installs the base stack (from `docs/general/installation.md`) and then iterates over each toolchain group with accept/skip/cancel prompts. Teammate A is handling the primary design; this report focuses on **prior art we can reuse** and **alternative idioms we should consciously accept or reject** so the plan does not accidentally reinvent infrastructure that exists 100 feet away in `~/.config/nvim/`.

Scope constraint (inherited from task 30): **macOS + Homebrew only**. No NixOS, no apt, no pacman.

## Findings

### 1. Prior Art in Adjacent Repos

#### 1a. `~/.config/nvim/scripts/check-dependencies.sh` (HIGH VALUE)

This 123-line script is an almost-perfect template for our `check_command` helper. Key reusable patterns:

```bash
# Color palette (standard ANSI, widely portable)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Counters for summary
MISSING_CORE=0
MISSING_RECOMMENDED=0

check_command() {
  local cmd=$1
  local name=$2
  local required=$3
  local min_version=$4

  if command -v "$cmd" &>/dev/null; then
    # ... per-command version extraction via case statement
    echo -e "${GREEN}✓${NC} $name: $version"
  else
    if [ "$required" = "true" ]; then
      echo -e "${RED}✗${NC} $name: not found (REQUIRED)"
      MISSING_CORE=$((MISSING_CORE + 1))
    else
      echo -e "${YELLOW}!${NC} $name: not found (recommended)"
    fi
  fi
}
```

Additionally, its **summary block** pattern (lines 96-122) with `Next Steps` and exit code based on missing-core count is directly applicable to per-toolchain scripts: run the Check phase, then short-circuit Install if nothing is missing. This aligns cleanly with the docs' existing Check/Install/Verify structure.

**Caveat**: the script uses Unicode check/cross/bang glyphs (`✓`, `✗`, `!`). These render fine in iTerm2, Terminal.app, WezTerm, and Zed's integrated terminal. Keep them — they match `docs/toolchain/README.md`'s "gold-standard" tone.

#### 1b. `~/.config/nvim/scripts/setup-with-claude.sh` (HIGH VALUE)

This 180-line script is a working **interactive sectioned wizard** with the exact UX shape task 31 needs. Reusable idioms:

```bash
print_section() {
  echo ""
  echo -e "${BLUE}>>> $1${NC}"
  echo ""
}
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}!${NC} $1"; }
print_error()   { echo -e "${RED}✗${NC} $1"; }
```

And the high-level flow:

```
Step 1: Checking Claude Code Installation  -> check_command
Step 2: Backing Up Existing Configuration  -> conditional
Step 3: Repository Setup                   -> conditional + read -p pause
Step 4: Checking Dependencies              -> delegate to check-dependencies.sh
Step 5: Verifying Git Remotes              -> conditional
Step 6: Ready for First Launch             -> summary + optional exec
```

This is exactly the "section / check / install / verify / next-section" rhythm the master wizard wants. We should:

- Copy the `print_*` helpers verbatim into a shared `_lib.sh`.
- Adopt the numbered-section structure, but **replace** the pause-based `read -p "Press Enter after..."` pattern (cancel-hostile) with a proper 3-choice prompt.
- Borrow the "offer to exec next step" tail pattern.

**Anti-pattern to NOT copy**: The `read -p "Press Enter after you've cloned..."` pattern at line 101 is a classic shell-wizard mistake — it has no cancel path, no skip path, and no validation that the user actually did the thing. Task 31's accept/skip/cancel requirement is explicitly designed to avoid this.

#### 1c. `~/.dotfiles/install.sh` (LOW VALUE for us)

A 24-line `nixos-rebuild` + `home-manager switch` wrapper. Not applicable — we are macOS/Homebrew, not NixOS. Worth noting only because it confirms the user's "one-shot rebuild" mental model, which maps to "run the master wizard" at the top level.

#### 1d. `~/.dotfiles/.claude/scripts/install-extension.sh` (MEDIUM VALUE)

A 280-line `set -euo pipefail` script with `log_info` / `log_warn` / `log_error` helpers using the same color palette. Reinforces that the color + prefix pattern is the house style across the author's repos. The `set -euo pipefail` guard should be adopted (the nvim scripts only use `set -e`).

#### 1e. `.claude/scripts/` in zed repo itself (NONE directly applicable)

The zed repo has plenty of bash infrastructure (postflight-*, validate-*, export-to-markdown, install-extension) but **no user-facing install wizards** — task 31 is the first one. This confirms we are not duplicating existing work within the zed repo.

### 2. Brewfile + `brew bundle` Analysis

Homebrew ships a first-party `bundle` subcommand that reads a declarative `Brewfile` listing taps, formulae, casks, and Mac App Store apps, then installs them idempotently. Typical shape:

```ruby
tap "homebrew/cask-fonts"

brew "r"
brew "python"
brew "uv"
brew "ruff"
brew "jq"
brew "gh"
brew "pandoc"
brew "typst"
brew "node"

cask "zed"
cask "claude-code"
cask "basictex"
cask "quarto"
cask "font-latin-modern"
cask "font-latin-modern-math"
```

Invocation: `brew bundle --file=Brewfile.r` (group-scoped) and `brew bundle check` (idempotency check).

**Strengths**:
- Declarative (one place to read "what will be installed")
- Idempotent by default (`brew bundle` skips installed packages)
- Can be grouped by file (`Brewfile.r`, `Brewfile.python`, `Brewfile.typesetting`, etc.)
- Users can edit before running ("pin python to 3.12")
- `brew bundle cleanup` can detect drift

**Fatal weakness for this task**: the Brewfile format covers only brew (`tap`, `brew`, `cask`, `mas`, `whalebrew`). Quick audit of actual install verbs in `docs/toolchain/` (grep output in the appendix below):

| Toolchain file | Brew verbs | Non-brew verbs |
|---|---|---|
| r.md | `brew install r`, `brew install --cask quarto` | 4× `install.packages()` inside R REPL, 1× `uvx rmcp` |
| python.md | `brew install python`, `brew install uv`, `brew install ruff` | 2× `uv tool install`, 1× `pip install` (7 packages) |
| typesetting.md | `brew install --cask basictex`/`mactex`, `brew install typst`/`pandoc`, 3× `brew install --cask font-*` | 1× `uv tool install markitdown` |
| mcp-servers.md | (none) | 3× `uvx ...` (rmcp, markitdown-mcp, mcp-pandoc), implicit `claude mcp add` |
| shell-tools.md | `brew install` × 5 (git, jq, gh, make, fontconfig) | (none — pure brew) |
| extensions.md | (none) | 1× `install.packages(c(...))` for epi, 1× `npm install -g @slidev/cli` |

**Verdict**: Roughly 40-50% of install verbs are NOT brew. Only `shell-tools.md` and `typesetting.md` could plausibly be driven purely by a Brewfile. A Brewfile-first design would force every non-shell-tools group to still ship a shell script for the non-brew tail, doubling the surface area.

**Secondary weakness**: Brewfile has no native concept of "section selection" — `brew bundle` either runs the whole file or nothing. You can split into multiple files, but then you need an orchestrator to decide which files to run, and you're back to writing a shell wizard anyway.

**Conclusion**: Reject Brewfile as the primary mechanism. However, see Recommended Approach below for an additive role.

### 3. Alternative Prompt UI Libraries

#### 3a. `gum` (charmbracelet)

```bash
gum choose "Install R toolchain" "Skip R toolchain" "Cancel"
gum confirm "Install R and its development packages?"
```

Pretty TUI, keyboard-friendly, supports multi-select. **Reject** because:

1. `gum` is a brew-installable dependency (`brew install gum`) — requiring it in a wizard that bootstraps a fresh Mac creates a chicken-and-egg problem unless we install it unconditionally as the first step.
2. Requiring a dependency *just for the installer UI* is a poor trade — the wizard should be runnable with nothing but bash + core utilities.
3. Master wizard cancel/skip/accept is 3 options; plain `read -p` handles this fine.

#### 3b. `whiptail` / `dialog`

Ncurses-based menus. **Reject** because:
1. `whiptail` is not preinstalled on macOS (linuxey). `dialog` requires `brew install dialog`.
2. Same chicken-and-egg problem as `gum`.
3. Ncurses dialogs feel anachronistic in a 2026 Zed-targeted installer.

#### 3c. `fzf` multi-select

```bash
selected=$(printf "r\npython\ntypesetting\nmcp-servers\nshell-tools\nextensions" | \
  fzf --multi --prompt="Select toolchain groups to install: ")
```

**Reject for the master wizard** (chicken-and-egg again — `fzf` isn't guaranteed present on a fresh Mac), but **consider** for a power-user "preselect groups non-interactively" flag (`--groups=r,python,typesetting`).

#### 3d. Plain `read` with validation loop

```bash
prompt_action() {
  local group_name="$1"
  local explanation="$2"
  echo ""
  echo "=== $group_name ==="
  echo "$explanation"
  echo ""
  while true; do
    read -p "Install $group_name? [a]ccept / [s]kip / [c]ancel (default: accept): " choice
    choice="${choice:-a}"
    case "$choice" in
      a|A|accept) return 0 ;;
      s|S|skip)   return 2 ;;
      c|C|cancel) echo "Installation cancelled."; exit 0 ;;
      *) echo "Please enter a, s, or c." ;;
    esac
  done
}
```

**Accept** as the primary prompt mechanism. Zero dependencies, 15 lines, obvious behavior, non-interactive fallback trivial (`if [ ! -t 0 ]`).

### 4. Other Orchestration Alternatives

#### 4a. `Makefile` target approach

```make
.PHONY: install install-base install-r install-python install-typesetting

install: install-base install-r install-python install-typesetting

install-r:
	./scripts/install/toolchain-r.sh

install-python:
	./scripts/install/toolchain-python.sh
```

**Reject** as the user-facing entry point (the task specifies a master script, not a Makefile). But **consider** adding a thin Makefile as a discoverability aid: `make install` -> runs the master wizard. Low cost, standard idiom.

#### 4b. `Justfile`

Same shape as Makefile but with a `just` dependency. **Reject** — requires `brew install just`, same chicken-and-egg problem.

#### 4c. Nix / home-manager declarative

**Reject** — task 30's plan explicitly locked in macOS/Homebrew-only scope. The `~/.dotfiles/flake.nix` exists but is for the author's NixOS boxes, not the Zed/Mac target audience.

### 5. How Open-Source Projects Handle This

Brief survey of idioms in comparable install wizards (drawing from general knowledge — no web fetch needed for well-known patterns):

| Project | Approach | Accept/Skip/Cancel? |
|---|---|---|
| **rustup** | Single curl\|sh; interactive main menu with 1/2/3 numeric choices; "proceed with installation (default)" / "customize installation" / "cancel". | Yes, numeric menu |
| **nvm** | curl\|bash; non-interactive; modifies shell rc. | No — unconditional |
| **pyenv (installer.sh)** | curl\|bash; non-interactive. | No |
| **Homebrew itself** | curl\|bash; single Y/n confirmation for the whole install; then unconditional. | Single gate only |
| **Oh My Zsh** | curl\|bash; single Y/n for shell change; no per-component. | Single gate only |
| **Rails devcontainer** | Dockerfile + features; no interactive UX. | N/A |
| **kubectl krew** | Non-interactive. | No |

**Observation**: Very few public wizards do per-group accept/skip/cancel. Those that do (rustup) use numeric menus. Task 31's requirement is legitimately uncommon but well-motivated — the toolchain groups are genuinely optional (a user who only uses R extensions does not want LaTeX/Typst), and the groups are large enough (MacTeX is 5 GB) that skipping matters.

The closest public match is **rustup's "customize installation" flow**. We should mirror its tone: clear section header, 1-2 sentence explanation of what and why, explicit default, explicit cancel path that exits cleanly.

### 6. Shell Script Hygiene Checklist

Drawing from `install-extension.sh` (the best-engineered of the prior-art scripts):

- [ ] `set -euo pipefail` (not just `set -e`)
- [ ] `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` idiom for path resolution
- [ ] `log_info` / `log_warn` / `log_error` functions with color
- [ ] Explicit `Usage:` message and `[ $# -ne N ]` arg check
- [ ] Validate external commands with `command -v` before invoking
- [ ] Trap `ERR` for cleanup (the nvim scripts don't do this; we should)
- [ ] Respect `NO_COLOR` env var (neither prior-art script does; cheap to add)
- [ ] Detect non-interactive stdin (`[ ! -t 0 ]`) and refuse to prompt (auto-cancel or auto-accept via flag)

## Recommended Approach

**Adopt a hybrid: shell scripts per toolchain doc + shared `_lib.sh` + optional generated Brewfiles.**

### Structure

```
scripts/install/
├── _lib.sh                    # Shared: log helpers, check_command, prompt_action
├── install.sh                 # Master wizard (entry point)
├── base.sh                    # docs/general/installation.md content
├── toolchain-r.sh             # docs/toolchain/r.md content
├── toolchain-python.sh        # docs/toolchain/python.md content
├── toolchain-typesetting.sh   # docs/toolchain/typesetting.md content
├── toolchain-mcp-servers.sh   # docs/toolchain/mcp-servers.md content
├── toolchain-shell-tools.sh   # docs/toolchain/shell-tools.md content
└── toolchain-extensions.sh    # docs/toolchain/extensions.md content
```

One script per toolchain file, per task spec. Numbering mirrors the docs directory for easy cross-reference.

### Master wizard flow

1. `set -euo pipefail`; source `_lib.sh`.
2. Detect non-interactive mode; bail with explanation if stdin is not a TTY (unless `--yes` flag).
3. Print banner + summary of what will happen (list of groups, rough sizes).
4. **Phase 1 — base**: run `base.sh` unconditionally (or with single Y/n gate mirroring Homebrew's own installer). This is Xcode CLT, Homebrew, Node, Zed, Claude Code CLI, SuperDoc, openpyxl — everything from `docs/general/installation.md`.
5. **Phase 2 — toolchain loop**: for each `toolchain-*.sh`:
   - Call `prompt_action "R toolchain" "Installs R interpreter + languageserver/lintr/styler/renv, Quarto. Needed for the epidemiology extension. ~400 MB."` — returns 0 (accept), 2 (skip), or exits on cancel.
   - On accept, `bash toolchain-r.sh`.
   - On skip, log and continue.
6. **Phase 3 — verify**: run Check phase from each accepted group, print summary.

### Per-group script shape (based on nvim's `check-dependencies.sh`)

```bash
#!/usr/bin/env bash
# toolchain-r.sh - Install the R toolchain for .claude/ extensions
# Mirrors docs/toolchain/r.md

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/_lib.sh"

print_section "R interpreter"
if check_command R; then
  log_info "R already installed, skipping"
else
  brew install r
fi

print_section "R development packages"
# Idempotent: install.packages skips if up-to-date in most cases
R --quiet --no-save <<'EOF'
pkgs <- c("languageserver", "lintr", "styler", "renv")
missing <- setdiff(pkgs, rownames(installed.packages()))
if (length(missing)) install.packages(missing, repos = "https://cloud.r-project.org")
EOF

print_section "Quarto"
if check_command quarto; then
  log_info "quarto already installed, skipping"
else
  brew install --cask quarto
fi

print_section "Verify"
R --version
quarto --version
log_info "R toolchain installation complete"
```

Each script is **self-contained and idempotent**: every step checks first, installs only if missing.

### Optional side artifact: per-group Brewfiles

As a non-canonical supplement (not the main wizard path), generate per-group Brewfiles for the brew-only subsets:

```
scripts/install/brewfiles/
├── Brewfile.base            # node, zed cask, claude-code cask
├── Brewfile.r               # r, quarto cask
├── Brewfile.python          # python, uv, ruff
├── Brewfile.typesetting     # basictex OR mactex, typst, pandoc, font casks
└── Brewfile.shell-tools     # git, jq, gh, make, fontconfig
```

Power users can run `brew bundle --file=scripts/install/brewfiles/Brewfile.python` for declarative batch install, then manually handle the `uv tool install` tail. This is additive and costs ~10 lines per file. **Low priority — include only if plan budget allows.**

### Cancel-hostile pause anti-pattern avoided

Unlike `setup-with-claude.sh`, **no `read -p "Press Enter to continue..."` pauses**. Every prompt is a real decision with a default and a cancel path. If the user wants to pause, they can Ctrl-Z.

### Documentation integration

Per task spec:
- `docs/general/installation.md` gains a lead section: "**Quickest path: run the installer wizard.** `bash scripts/install/install.sh`" followed by the existing manual instructions as a fallback.
- Each `docs/toolchain/*.md` gains a "**Install via script**" lead-in: `bash scripts/install/toolchain-r.sh` followed by the existing Check/Install/Verify manual content.

## Evidence / Examples

### Brewfile sample (if additive artifact is adopted)

```ruby
# scripts/install/brewfiles/Brewfile.python
# Generated from docs/toolchain/python.md
# Usage: brew bundle --file=scripts/install/brewfiles/Brewfile.python
# Note: follow up with `uv tool install pytest mypy ipython markitdown`

brew "python"
brew "uv"
brew "ruff"
```

### Plain-bash prompt (recommended)

```bash
# _lib.sh excerpt
prompt_action() {
  local title="$1"
  local blurb="$2"
  echo ""
  echo "=============================================="
  echo "  $title"
  echo "=============================================="
  echo "$blurb"
  echo ""
  while true; do
    read -r -p "[a]ccept / [s]kip / [c]ancel (default: accept): " choice
    choice="${choice:-a}"
    case "$choice" in
      a|A) return 0 ;;
      s|S) log_warn "Skipping $title"; return 2 ;;
      c|C) log_error "Installation cancelled by user"; exit 130 ;;
      *)   echo "Please enter a, s, or c." ;;
    esac
  done
}
```

### check_command helper (adapted from nvim)

```bash
# _lib.sh excerpt
check_command() {
  local cmd=$1
  local name=${2:-$cmd}
  if command -v "$cmd" &>/dev/null; then
    local version
    case "$cmd" in
      R)        version=$(R --version 2>&1 | head -n1) ;;
      python3)  version=$(python3 --version 2>&1) ;;
      node)     version=$(node --version 2>&1) ;;
      typst)    version=$(typst --version 2>&1) ;;
      *)        version="installed" ;;
    esac
    log_ok "$name: $version"
    return 0
  else
    log_warn "$name: not found"
    return 1
  fi
}
```

## Decisions

- **Reject Brewfile as primary mechanism** (coverage gap; ~40-50% of install verbs are non-brew).
- **Reject gum/whiptail/fzf for the wizard** (chicken-and-egg with fresh-Mac bootstrap).
- **Reject Just/Make as user-facing entry point** (task spec is a shell wizard; Make can optionally be a thin alias).
- **Reject Nix / home-manager** (out of scope per task 30's macOS-only framing).
- **Accept plain `read -p` loop for 3-way prompts**.
- **Accept `set -euo pipefail` and `_lib.sh` extraction** (best practice from `install-extension.sh`).
- **Accept color palette and `print_section` / `log_*` helpers** from nvim scripts (house style).
- **Accept one-script-per-doc mapping** (task spec) + master wizard orchestrator.
- **Defer decision on additive Brewfile artifacts** — include only if plan budget allows and if Teammate A's design confirms it adds value without duplication.

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| `install.packages()` inside `R --quiet --no-save <<EOF` heredoc is not perfectly idempotent (CRAN mirror prompt on fresh install) | Medium | Low | Pass `repos = "https://cloud.r-project.org"` explicitly (shown in example above) |
| MacTeX is 5 GB; users who accept without reading the blurb are surprised | High | Medium | Blurb for typesetting group MUST include "~5 GB (MacTeX) or ~100 MB (BasicTeX)" and offer a sub-choice |
| `brew install --cask` prompts for sudo password mid-script, breaking the prompt loop flow | Medium | Medium | Run `sudo -v` at the start of master wizard to cache credentials; document in the blurb |
| Unicode glyphs (`✓`, `✗`) break on exotic terminals | Low | Low | Respect `NO_COLOR` and provide ASCII fallback (`[OK]`, `[FAIL]`) |
| Non-interactive CI users want to run the wizard unattended | Low | Low | Support `--yes` / `--groups=r,python` flags; detect `[ ! -t 0 ]` and refuse interactive prompts without `--yes` |
| `uvx` and `uv tool install` both need `uv` installed first, so ordering matters across groups | Medium | Medium | Master wizard runs `base.sh` first (which installs `uv` as part of python group? or base?) — resolve this in plan phase with Teammate A |
| User runs a single `toolchain-*.sh` directly without the master, missing a transitive prerequisite (e.g. `toolchain-extensions.sh` needs R installed first for epi packages) | Medium | Medium | Each per-group script's Check phase validates its prereqs and errors helpfully: "This script requires R; run `bash toolchain-r.sh` first." |

## Context Extension Recommendations

- **Topic**: Installer script patterns for Zed repo
- **Gap**: No `.claude/context/` coverage for shell wizard idioms; nvim repo has excellent prior art but no pattern doc references it
- **Recommendation**: After task 31 completes, consider a `.claude/context/patterns/install-wizard-patterns.md` documenting the `_lib.sh` shape, `prompt_action` contract, and chicken-and-egg constraints for future install-related tasks (e.g., a `/doctor` command from task 30's follow-on list).

## Confidence Levels

| Recommendation | Confidence | Rationale |
|---|---|---|
| Reject Brewfile as primary | **High** | Direct grep of toolchain docs shows ~40-50% non-brew verbs; coverage gap is quantitative, not a guess |
| Reject gum/whiptail/fzf/Just | **High** | Chicken-and-egg is a hard constraint on fresh-Mac bootstrap |
| Adopt nvim `check-dependencies.sh` patterns verbatim | **High** | Script exists, is well-written, matches house style, directly applicable |
| Adopt `setup-with-claude.sh` section structure | **High** | Same |
| Replace `read -p "Press Enter..."` with 3-way prompt | **High** | Task spec explicitly requires accept/skip/cancel |
| Per-script one-per-doc structure | **High** | Task spec is explicit |
| Optional per-group Brewfiles as side artifact | **Low** | Additive, low cost, but unclear value over the shell scripts; defer to Teammate A / plan phase |
| `sudo -v` credential caching | **Medium** | Works for most casks but some installs still prompt mid-run (Xcode CLT dialog is unavoidable) |
| `set -euo pipefail` over `set -e` | **High** | Best practice; matches `install-extension.sh` |

## Appendix

### Install-verb inventory (grep-derived)

```
docs/toolchain/python.md:24:brew install python
docs/toolchain/python.md:52:brew install uv
docs/toolchain/python.md:78:brew install ruff
docs/toolchain/python.md:149:uv tool install pytest
docs/toolchain/python.md:163:uv tool install ipython
docs/toolchain/python.md:232:uv tool install pytest
docs/toolchain/python.md:256:uv tool install mypy
docs/toolchain/python.md:299:pip install pandas openpyxl python-pptx python-docx markitdown xlsx2csv pymupdf pdfannots
docs/toolchain/mcp-servers.md:51:uvx rmcp --help
docs/toolchain/mcp-servers.md:89:uvx markitdown-mcp --help
docs/toolchain/mcp-servers.md:125:uvx mcp-pandoc --help
docs/toolchain/extensions.md:110:install.packages(c(...))
docs/toolchain/extensions.md:178:npm install -g @slidev/cli
docs/toolchain/typesetting.md:36:brew install --cask basictex
docs/toolchain/typesetting.md:57:brew install --cask mactex
docs/toolchain/typesetting.md:86:brew install typst
docs/toolchain/typesetting.md:120:brew install pandoc
docs/toolchain/typesetting.md:144:uv tool install markitdown
docs/toolchain/typesetting.md:192:brew install --cask font-latin-modern font-latin-modern-math
docs/toolchain/typesetting.md:193:brew install --cask font-computer-modern
docs/toolchain/typesetting.md:194:brew install --cask font-noto-sans font-noto-serif font-noto-sans-mono
docs/toolchain/shell-tools.md:30:brew install git
docs/toolchain/shell-tools.md:53:brew install jq
docs/toolchain/shell-tools.md:79:brew install gh
docs/toolchain/shell-tools.md:114:brew install make
docs/toolchain/shell-tools.md:138:brew install fontconfig
docs/toolchain/r.md:29:brew install r
docs/toolchain/r.md:57:install.packages("languageserver")
docs/toolchain/r.md:58:install.packages("lintr")
docs/toolchain/r.md:59:install.packages("styler")
docs/toolchain/r.md:200:install.packages("renv")
docs/toolchain/r.md:226:brew install --cask quarto
```

Count: ~15 brew verbs, ~13 non-brew verbs (uv tool, uvx, install.packages, pip install, npm install). The non-brew tail is the load-bearing argument against a Brewfile-first design.

### Prior art files (absolute paths for reference)

- `/home/benjamin/.config/nvim/scripts/check-dependencies.sh`
- `/home/benjamin/.config/nvim/scripts/setup-with-claude.sh`
- `/home/benjamin/.dotfiles/install.sh`
- `/home/benjamin/.dotfiles/update.sh`
- `/home/benjamin/.dotfiles/.claude/scripts/install-extension.sh`

### Search queries used

- Filesystem glob: `install*.sh`, `setup*.sh`, `bootstrap*.sh`, `Brewfile*`, `Justfile`, `Makefile` across `~/.config/zed`, `~/.config/nvim`, `~/.dotfiles`
- Content grep: install verbs across `docs/toolchain/`
- General knowledge survey: rustup, nvm, pyenv, Homebrew, Oh My Zsh, Rails devcontainer, kubectl krew
