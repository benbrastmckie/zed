# Research Report: Task 31 — Teammate A (Primary Approach)

**Task**: 31 — toolchain_installation_scripts
**Angle**: Primary / Pragmatic Approach & Patterns
**Started**: 2026-04-10
**Completed**: 2026-04-10
**Sources/Inputs**: Local codebase inventory of `docs/general/installation.md`, every file in `docs/toolchain/`, existing script conventions in `.claude/scripts/`, predecessor task 30 artifacts.
**Artifacts**: this report
**Standards**: report-format.md

## Executive Summary

- The install surface has **6 toolchain groups** (`r.md`, `python.md`, `typesetting.md`, `mcp-servers.md`, `shell-tools.md`, `extensions.md`) plus **one base group** derived from `installation.md`. Every group is macOS/Homebrew-installable with three subtle wrinkles: R packages install from inside R, MCP servers install via `claude mcp add`, and the epidemiology R bundle is large (15-20 min for Stan-backed packages). `extensions.md` is a router — it gets NO script of its own; its per-extension check commands become part of the master-script "verify" pass instead.
- **Recommended layout**: `scripts/install/` at repo root, containing `install.sh` (master wizard), `lib.sh` (shared helpers), and one `install-<group>.sh` per toolchain file (`install-base.sh`, `install-r.sh`, `install-python.sh`, `install-typesetting.sh`, `install-mcp-servers.sh`, `install-shell-tools.sh`). Each per-group script is runnable standalone AND sourceable/invokable from the master.
- **Master UX**: For each group, print a short "what / why" block (package list + one-line rationale), then a `[y/N/q]` prompt with `y` = install, `N` = skip, `q` = quit wizard (saving progress). Homebrew preflight at the top (hard-fail if missing). Every tool install is idempotent: `command -v` or `brew list --formula` guards make re-runs cheap.
- **Doc integration**: each `docs/toolchain/*.md` file gains a "## Quick install (script)" section immediately after the H1 and the "Before you begin" block, pointing at `scripts/install/install-<group>.sh`. `docs/general/installation.md` gains a "## Installation wizard (recommended)" section at the very top (after the intro paragraph) walking a beginner through `git clone` -> `cd zed` -> `bash scripts/install/install.sh`, followed by the unchanged existing manual instructions.
- Confidence overall: **HIGH** on layout, shared lib, and doc integration pattern. **MEDIUM** on Quarto/MacTeX prompts (these are large, user probably wants fine-grained y/n per-tool inside the typesetting group). **MEDIUM** on MCP server handling (they need `claude` CLI to already be working AND a restart of Claude Code to pick up config changes — the script should print a "restart Claude Code now" reminder, not try to automate that).

## Context & Scope

Task 31 builds on task 30, which produced the `docs/toolchain/` directory as the authoritative dependency catalog. The remit now is to make that catalog *executable*: one bash script per toolchain file, a master script that wraps everything in `installation.md` + iterates through the toolchain scripts, and documentation updates so both the beginner wizard path and the existing manual path are discoverable.

Scope is strictly **macOS + Homebrew**. No apt/nix/pacman branches. Target reader: "a beginner who just got a fresh Mac" (per the doc intro language already in `installation.md`).

## Findings

### Current-state inventory

The following is a complete enumeration of every dependency documented in the docs in scope, grouped by the file that will own its install script.

#### Group 0: Base (`install-base.sh`, from `docs/general/installation.md`)

| Package | Install command | Check | Notes |
|---|---|---|---|
| Xcode CLT | `xcode-select --install` | `xcode-select -p` or `git --version` | Interactive GUI dialog; can't fully automate; script just invokes and tells user to click through. |
| Homebrew | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` | `command -v brew` | PREREQUISITE for everything else. Master script handles this first, then hard-asserts `brew` exists before touching any other group. |
| Node.js | `brew install node` | `command -v node` | Needed for `claude-acp`, `@superdoc-dev/mcp`, `@jonemo/openpyxl-mcp`, optionally Slidev. |
| Zed | `brew install --cask zed` | GUI app in `/Applications/Zed.app` | Cask; check via `[ -d /Applications/Zed.app ]` or `brew list --cask zed`. |
| Claude Code CLI | `brew install --cask claude-code` | `command -v claude` | First-run auth is manual (browser). Script can `brew install` but MUST NOT attempt `claude` login. |
| `superdoc` MCP | `claude mcp add --scope user superdoc -- npx @superdoc-dev/mcp` | `claude mcp list \| grep -q '^superdoc'` | Requires `claude` CLI to be on PATH (installed one step earlier). |
| `openpyxl` MCP | `claude mcp add --scope user openpyxl -- npx @jonemo/openpyxl-mcp` | `claude mcp list \| grep -q '^openpyxl'` | Same. |

Note: the `zed@preview` cask is an *optional* alternative (lines 141-147 in `installation.md`) and should be offered as a nested y/N inside the base group, not a separate group.

#### Group 1: R (`install-r.sh`, from `docs/toolchain/r.md`)

| Package | Install | Check |
|---|---|---|
| R | `brew install r` | `command -v R` |
| languageserver | `Rscript -e 'install.packages("languageserver", repos="https://cloud.r-project.org")'` | `Rscript -e 'packageVersion("languageserver")'` |
| lintr | (same pattern) | (same pattern) |
| styler | (same pattern) | (same pattern) |
| renv (optional) | `Rscript -e 'install.packages("renv", repos="...")'` | `Rscript -e 'packageVersion("renv")'` |
| Quarto (optional) | `brew install --cask quarto` | `command -v quarto` |
| Epidemiology R bundle (optional, large) | `Rscript -e 'install.packages(c("survival","survminer","lme4","glmnet","mgcv","brms","rstanarm","MatchIt","WeightIt","marginaleffects","dagitty","mice","VIM","EpiModel","EpiEstim","EpiNow2","epiparameter","epitools","Epi","gtsummary","flextable","kableExtra","tidyverse","here","targets","tarchetypes"), repos="...")'` | per-package `Rscript` checks (report count of installed) |

**Nested sub-prompts** inside the R script: (1) core R + lang server trio [y/N], (2) renv [y/N], (3) Quarto [y/N], (4) epidemiology bundle [y/N, warn about 15-20 min Stan compile].

#### Group 2: Python (`install-python.sh`, from `docs/toolchain/python.md`)

| Package | Install | Check |
|---|---|---|
| Python 3 | `brew install python` | `command -v python3` |
| uv (includes uvx) | `brew install uv` | `command -v uv && command -v uvx` |
| ruff | `brew install ruff` | `command -v ruff` |
| pytest (optional) | `uv tool install pytest` | `command -v pytest` |
| mypy (optional) | `uv tool install mypy` | `command -v mypy` |
| ipython (optional) | `uv tool install ipython` | `command -v ipython` |
| filetypes Python bundle (optional) | `pip3 install --user pandas openpyxl python-pptx python-docx markitdown xlsx2csv pymupdf pdfannots` | `python3 -c "import pandas,openpyxl,pptx,docx,markitdown,fitz"` |

Recommendation: prefer a venv for the filetypes bundle (`python3 -m venv ~/.venvs/claude-filetypes`) — offer as nested sub-prompt (system vs venv).

#### Group 3: Typesetting (`install-typesetting.sh`, from `docs/toolchain/typesetting.md`)

| Package | Install | Check |
|---|---|---|
| BasicTeX (recommended) | `brew install --cask basictex` | `command -v pdflatex` |
| MacTeX (alternative, 5GB) | `brew install --cask mactex` | same |
| tlmgr extras | `sudo tlmgr update --self && sudo tlmgr install latexmk collection-fontsrecommended collection-latexextra biber` | `command -v latexmk biber` |
| Typst | `brew install typst` | `command -v typst` |
| Pandoc | `brew install pandoc` | `command -v pandoc` |
| markitdown | `uv tool install markitdown` | `command -v markitdown` (prereq: `uv` from python group) |
| Latin Modern fonts | `brew install --cask font-latin-modern font-latin-modern-math` | `fc-list \| grep -qi "latin modern math"` |
| CMU fonts | `brew install --cask font-computer-modern` | `fc-list \| grep -qi cmu` |
| Noto fonts | `brew install --cask font-noto-sans font-noto-serif font-noto-sans-mono` | `fc-list \| grep -qi noto` |
| fontconfig (optional, for fc-list) | `brew install fontconfig` | `command -v fc-list` |

**Nested sub-prompts**: LaTeX variant picker (BasicTeX vs MacTeX vs skip), then tlmgr extras [y/N] (needs sudo, warn), Typst [y/N], Pandoc [y/N], markitdown [y/N] (warn: needs uv), fonts [y/N group of 3].

#### Group 4: MCP servers (`install-mcp-servers.sh`, from `docs/toolchain/mcp-servers.md`)

| Server | Install | Check |
|---|---|---|
| obsidian-memory | Manual — script prints pointer to `.claude/context/project/memory/memory-setup.md` and offers to open it | `claude mcp list \| grep -qE "obsidian\|memory"` |
| rmcp | `claude mcp add --scope user rmcp -- uvx rmcp` (prereqs: R, uv) | `claude mcp list \| grep -q rmcp` |
| markitdown-mcp | `claude mcp add --scope user markitdown -- uvx markitdown-mcp` | `claude mcp list \| grep -q markitdown` |
| mcp-pandoc | `claude mcp add --scope user pandoc -- uvx mcp-pandoc` | `claude mcp list \| grep -q pandoc` |

All of these require `claude` CLI present (base group) and `uvx` (python group). Script hard-checks both and exits with a clear message if missing. Ends by printing "Restart Claude Code (Cmd+Q + reopen) to pick up new MCP servers."

Note on the `claude mcp add` form: both `docs/general/installation.md` (SuperDoc/openpyxl) and the approach chosen for the extra servers use `claude mcp add --scope user <name> -- <command> <args>`. This is more robust than hand-editing `.mcp.json` because it goes through `claude`'s own validation. We should use this form uniformly and NOT hand-edit `.mcp.json` from the script.

#### Group 5: Shell tools (`install-shell-tools.sh`, from `docs/toolchain/shell-tools.md`)

| Package | Install | Check |
|---|---|---|
| git | `brew install git` (or rely on Xcode CLT) | `command -v git` |
| jq | `brew install jq` | `command -v jq` |
| gh | `brew install gh` | `command -v gh` |
| make (GNU) | `brew install make` (installs as `gmake`) | `command -v gmake` or `make --version` |
| fontconfig | `brew install fontconfig` | `command -v fc-list` |

All small, all idempotent via `brew list --formula`. Offer as one grouped y/N with an option to install all-at-once via `brew install jq gh make fontconfig`.

#### Group 6: Extensions router — NO script

`docs/toolchain/extensions.md` is explicitly a per-extension router that delegates to the other files (lines 17-31 of that file). It should NOT get its own script. Instead it gets a "Quick install (scripts)" pointer at the top that explains "Install the groups your extension needs — see the per-extension table below for which scripts to run." The extension Check commands become material for the master script's final `verify` step.

### Proposed directory/script layout

```
scripts/
└── install/
    ├── install.sh                  # Master wizard (<= 300 lines)
    ├── lib.sh                      # Shared helpers (<= 150 lines)
    ├── install-base.sh             # Group 0: installation.md dependencies
    ├── install-r.sh                # Group 1: r.md
    ├── install-python.sh           # Group 2: python.md
    ├── install-typesetting.sh      # Group 3: typesetting.md
    ├── install-mcp-servers.sh      # Group 4: mcp-servers.md
    └── install-shell-tools.sh      # Group 5: shell-tools.md
```

**Why `scripts/install/` at repo root, not `.claude/scripts/`**: `.claude/scripts/` is for agent-system tooling (`postflight-*.sh`, `validate-*.sh`) — operational infra the agents call. These install scripts are user-facing onboarding, referenced from user-facing docs (`docs/general/installation.md`). Keeping them at `scripts/install/` makes the repo layout self-documenting: `scripts/` = things a human runs, `.claude/scripts/` = things agents run. This also matches the pattern used in the predecessor task 28 (which produced `examples/epi-study/scripts/`).

Naming convention: `install-<group>.sh` matches the toolchain doc filenames 1:1 (minus the `.md`), so the doc-to-script mapping is mechanical and greppable. Master is the unadorned `install.sh`.

### Shared library (`scripts/install/lib.sh`)

Critical helpers (final size ~100-150 lines):

- `log_info` / `log_warn` / `log_error` — colorized stderr output using `tput` (fallback to plain if `tput` absent).
- `log_section "Title"` — bold heading + horizontal rule, used at the start of each group.
- `have_cmd <name>` — wrapper for `command -v <name> >/dev/null 2>&1`.
- `brew_has_formula <name>` — `brew list --formula --versions <name> >/dev/null 2>&1`.
- `brew_has_cask <name>` — `brew list --cask --versions <name> >/dev/null 2>&1`.
- `brew_install_formula <name>` — idempotent wrapper: checks `brew_has_formula`, installs with `HOMEBREW_NO_AUTO_UPDATE=1 brew install <name>` if missing, logs skip otherwise.
- `brew_install_cask <name>` — same for `--cask`.
- `ensure_brew` — hard-checks `command -v brew`; on failure prints the Homebrew one-liner from installation.md and `exit 1` with guidance.
- `prompt_yn "question" [default=N]` — reads a single character from `/dev/tty`, accepts `y/Y/n/N/q/Q/<Enter>`; returns 0 for yes, 1 for no, 2 for quit. Always reads from `/dev/tty` so the prompt works even when the script is piped.
- `prompt_choice "label" "opt1" "opt2" ...` — numbered menu, for the LaTeX variant picker and similar.
- `print_group_header "Group Name" "One-line what" "Why you want it"` — consistent 3-line block before the prompt.
- `list_packages "pkg1: reason" "pkg2: reason" ...` — bulletized package display for the "what will be installed" block.
- `require_cmd <name> "install hint"` — for cross-group prerequisites (e.g., MCP group requires `claude` and `uvx`).
- `on_exit` + `trap on_exit EXIT INT TERM` — print a "partial install" summary when the user hits Ctrl-C.

`lib.sh` is sourced via `source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"` at the top of every per-group script AND by `install.sh`. Every per-group script is a no-op if sourced directly (no top-level side effects) and does work inside a `main()` function that runs only when `"${BASH_SOURCE[0]}" == "$0"` — standard idiom, makes them both CLI-runnable and source-testable.

### Master script (`install.sh`) flow

```
1. Parse args: --skip-base, --only <group>, --yes (auto-accept), --dry-run
2. Print banner + overall "what this wizard does" explanation
3. Assert macOS (uname -s == Darwin) or exit 1
4. Run install-base.sh (prompts through Xcode CLT, Homebrew, Node, Zed, Claude Code CLI, MCP base tools)
5. After base: assert brew + claude are on PATH (they must be by now); if not, fail with guidance
6. Iterate toolchain scripts in a fixed order:
     install-shell-tools.sh   # cheapest, bootstraps jq/gh/make for later
     install-python.sh        # before typesetting (markitdown needs uv)
     install-r.sh             # standalone
     install-typesetting.sh   # needs uv (from python) for markitdown
     install-mcp-servers.sh   # needs claude + uvx, goes last
   For each: print header -> prompt [y/N/q] -> dispatch to the script -> record result (ok/skipped/failed/quit)
7. Print final summary table (group | status)
8. Print "Restart Claude Code now to pick up MCP server changes" if any MCP server was installed
9. Point at verification: "Run the Verify section of docs/general/installation.md"
```

Ordering rationale: shell-tools first (fast, no deps); python before typesetting (uv is a typesetting prereq); R is standalone so anywhere; MCP last because it depends on both claude (base) and uvx (python).

### Per-group UX template

Every group prompt should look like this (exemplified for typesetting):

```
===============================================================================
Group 3 of 6: Typesetting (LaTeX / Typst / Pandoc / markitdown / fonts)
===============================================================================

What this installs:
  - BasicTeX (~100 MB)    : LaTeX engine (pdflatex, bibtex, biber)
  - latexmk + extras      : Beamer/VimTeX workflow prerequisites
  - Typst                 : modern single-pass typesetting (for slides, talks)
  - Pandoc                : universal document converter (drives /convert)
  - markitdown            : "anything -> Markdown" extractor (uses uv)
  - Latin Modern fonts    : default LaTeX math font
  - Noto fonts            : broad Unicode coverage for Typst/Slidev themes

Why you want it:
  Needed by the latex, typst, filetypes, and present extensions. Skip only if
  you will never render PDFs or slides from this environment.

Proceed?  [y]es / [N]o / [q]uit wizard:
```

The "What / Why / Proceed" triad is the entire UX contract. Reader gets a scannable summary, knows the cost, and has one keystroke to decide.

### Documentation integration pattern

**For every `docs/toolchain/*.md` file** (except `README.md` and `extensions.md`), insert a new section directly after the H1 title block and any existing "Before you begin":

```markdown
## Quick install (script)

If you want to install everything in this file in one step, run the script
from the repo root:

    bash scripts/install/install-<group>.sh

The script is idempotent — you can re-run it anytime; already-installed tools
are skipped. It will prompt before each optional sub-group (e.g. Quarto,
epidemiology packages).

Prefer to run individual commands by hand? The rest of this file documents
each tool with Check / Install / Verify sections you can copy-paste.
```

Key points:
- Script block is **above** the manual instructions, not replacing them. The manual Check / Install / Verify stays as-is, unchanged.
- Relative path `scripts/install/install-<group>.sh` from repo root.
- Note on idempotency and sub-prompts manages expectations.
- "Prefer to run individual commands by hand?" bridges to the existing content without a jarring section break.

**For `docs/general/installation.md`**, insert a new "## Installation wizard (recommended)" section after the intro paragraph (after line 19, before "## Before you begin"):

```markdown
## Installation wizard (recommended)

If you are comfortable opening **Terminal** (the Mac app), the fastest way to
get a working environment is to clone this repo and run the master install
script. It walks you through every dependency group with a clear prompt at
each step, and you can skip anything you already have.

### Step 1 -- Open Terminal

Press **Cmd+Space** to open Spotlight, type **Terminal**, and press Enter.

### Step 2 -- Install git (once)

Paste this and press Enter. A dialog box appears -- click **Install** and wait.

    xcode-select --install

### Step 3 -- Clone this repository

Paste this and press Enter:

    git clone https://github.com/<owner>/<repo>.git ~/zed-config
    cd ~/zed-config

(Replace `<owner>/<repo>` with the actual repo URL.)

### Step 4 -- Run the installation wizard

    bash scripts/install/install.sh

The wizard prints a short explanation before each group (LaTeX, R, Python,
MCP servers, etc.) and prompts you to accept (**y**), skip (**N**), or quit
(**q**). Already-installed tools are detected and skipped automatically.

### Step 5 -- Verify

After the wizard finishes, follow the [Verify](#verify) checklist at the
bottom of this page.

---

**Prefer to install by hand?** The rest of this guide walks through every
dependency one-by-one with Check / Install / Verify commands you can copy and
paste. The wizard simply automates those same commands.
```

The `---` separator marks the handoff from wizard-path to manual-path, and the existing "## Before you begin" through "## Verify" sections are preserved verbatim below it. This way both audiences are first-class:
- Beginners who want one command → they see the wizard at the top.
- Readers who want to understand / troubleshoot / run piecemeal → they scroll past the wizard into the existing manual sections.

## Evidence / Examples

### Bash: prompt_yn with /dev/tty fallback and quit support

```bash
# Returns 0=yes, 1=no, 2=quit
prompt_yn() {
    local question="$1"
    local default="${2:-N}"
    local prompt reply
    if [[ "$default" == "Y" || "$default" == "y" ]]; then
        prompt="[Y]es / [n]o / [q]uit"
    else
        prompt="[y]es / [N]o / [q]uit"
    fi
    while true; do
        printf "%s  %s: " "$question" "$prompt" > /dev/tty
        IFS= read -r reply < /dev/tty || reply=""
        reply="${reply:-$default}"
        case "$reply" in
            y|Y) return 0 ;;
            n|N) return 1 ;;
            q|Q) return 2 ;;
            *)   printf "Please answer y, n, or q.\n" > /dev/tty ;;
        esac
    done
}
```

Reading from `/dev/tty` lets the prompt work even if stdout/stderr are piped or captured. Return-code 2 for quit lets the master script distinguish quit from skip and break out of its group loop.

### Bash: idempotent Homebrew formula install

```bash
brew_install_formula() {
    local formula="$1"
    if brew list --formula --versions "$formula" >/dev/null 2>&1; then
        log_info "  [skip] $formula already installed"
        return 0
    fi
    log_info "  [install] $formula"
    HOMEBREW_NO_AUTO_UPDATE=1 brew install "$formula" || {
        log_error "  [fail]   $formula"
        return 1
    }
}
```

`HOMEBREW_NO_AUTO_UPDATE=1` skips the "brew update" step on each install, which is what makes the master script tolerable to run end-to-end (otherwise each call re-fetches the brew taps).

### Bash: ensure_brew preflight (used by master)

```bash
ensure_brew() {
    if ! command -v brew >/dev/null 2>&1; then
        log_error "Homebrew is not installed."
        cat >&2 <<'EOF'

This wizard requires Homebrew. Install it by running:

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

Then re-run this wizard:

    bash scripts/install/install.sh

EOF
        exit 1
    fi
}
```

### Bash: trap for partial-run summary on Ctrl-C

```bash
declare -a GROUPS_DONE=()
declare -a GROUPS_SKIPPED=()
declare -a GROUPS_FAILED=()

on_exit() {
    local rc=$?
    printf "\n\n=== Installation wizard summary ===\n" > /dev/tty
    printf "Installed : %s\n" "${GROUPS_DONE[*]:-<none>}"     > /dev/tty
    printf "Skipped   : %s\n" "${GROUPS_SKIPPED[*]:-<none>}"  > /dev/tty
    printf "Failed    : %s\n" "${GROUPS_FAILED[*]:-<none>}"   > /dev/tty
    if (( rc != 0 )); then
        printf "\nWizard exited with status %d. Re-run 'bash scripts/install/install.sh' to resume.\n" "$rc" > /dev/tty
    fi
}
trap on_exit EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
```

Each group script updates the arrays so Ctrl-C produces a meaningful partial-install summary.

### Bash: per-group script skeleton (`install-r.sh`)

```bash
#!/usr/bin/env bash
# install-r.sh -- Install R and R development packages for Zed + epidemiology
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

install_r_core() {
    log_section "R core (interpreter + languageserver + lintr + styler)"
    ensure_brew
    brew_install_formula r
    for pkg in languageserver lintr styler; do
        if Rscript -e "packageVersion('$pkg')" >/dev/null 2>&1; then
            log_info "  [skip] R package $pkg already installed"
        else
            log_info "  [install] R package $pkg"
            Rscript -e "install.packages('$pkg', repos='https://cloud.r-project.org')"
        fi
    done
}

install_r_renv() {
    log_section "renv (project-local R environments)"
    if Rscript -e 'packageVersion("renv")' >/dev/null 2>&1; then
        log_info "  [skip] renv already installed"
    else
        Rscript -e "install.packages('renv', repos='https://cloud.r-project.org')"
    fi
}

install_r_quarto() {
    log_section "Quarto (analysis reports)"
    brew_install_cask quarto
}

install_r_epi_bundle() {
    log_section "Epidemiology R packages (Bayesian, causal, survival, ...)"
    log_warn "  First-time install of Stan-backed packages (brms, EpiNow2) can take 15-20 minutes."
    local pkgs='c("survival","survminer","lme4","glmnet","mgcv","brms","rstanarm","MatchIt","WeightIt","marginaleffects","dagitty","mice","VIM","EpiModel","EpiEstim","EpiNow2","epiparameter","epitools","Epi","gtsummary","flextable","kableExtra","tidyverse","here","targets","tarchetypes")'
    Rscript -e "install.packages($pkgs, repos='https://cloud.r-project.org')"
}

main() {
    print_group_header "R toolchain" \
        "R interpreter + languageserver, lintr, styler (required for Zed's R support)" \
        "Needed for any R editing or the epidemiology extension."
    if prompt_yn "Install R core packages?" Y; then
        install_r_core
    fi
    if prompt_yn "Install renv (project-local R envs)?" N; then
        install_r_renv
    fi
    if prompt_yn "Install Quarto (analysis reports)?" N; then
        install_r_quarto
    fi
    if prompt_yn "Install the epidemiology R bundle (SLOW, ~15-20 min)?" N; then
        install_r_epi_bundle
    fi
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    main "$@"
fi
```

The `"${BASH_SOURCE[0]}" == "$0"` guard makes the script source-safe: `install.sh` calls each group script as a subprocess (`bash scripts/install/install-r.sh`) so failure isolation is per-group, but in future we could also `source` them for in-process testing.

### Bash: master script dispatch loop

```bash
run_group() {
    local name="$1" script="$2"
    print_group_header "$name"
    if ! prompt_yn "Run the $name installer?" Y; then
        case $? in
            1) GROUPS_SKIPPED+=("$name"); log_info "Skipped $name."; return 0 ;;
            2) log_warn "Quitting wizard at user request."; exit 0 ;;
        esac
    fi
    if bash "$SCRIPT_DIR/$script"; then
        GROUPS_DONE+=("$name")
    else
        GROUPS_FAILED+=("$name")
        log_error "$name installer failed — continuing with remaining groups."
    fi
}

main() {
    [[ "$(uname -s)" == "Darwin" ]] || { log_error "macOS only."; exit 1; }
    log_section "Zed + Claude Code installation wizard"
    cat <<'EOF'
This wizard installs the base environment (Zed, Claude Code CLI, Homebrew,
Node.js, SuperDoc, openpyxl) plus optional toolchain groups (R, Python,
typesetting, MCP servers, shell utilities).

You will be prompted before each group with a short explanation. Skip any
group you already have or do not need. Already-installed tools are detected
automatically and skipped inside each group.
EOF
    run_group "Base environment"        "install-base.sh"
    ensure_brew
    run_group "Shell utilities"         "install-shell-tools.sh"
    run_group "Python toolchain"        "install-python.sh"
    run_group "R toolchain"             "install-r.sh"
    run_group "Typesetting toolchain"   "install-typesetting.sh"
    run_group "MCP servers"             "install-mcp-servers.sh"
}

main "$@"
```

Note the key detail: `bash "$SCRIPT_DIR/$script"` runs each group in a subprocess so a `set -e` inside a group only kills that group, not the whole wizard. Failures are recorded into `GROUPS_FAILED` and the wizard continues.

### Handling the Xcode CLT dialog

Xcode CLT install opens a native GUI dialog that the script cannot click through. Pattern:

```bash
ensure_xcode_clt() {
    if xcode-select -p >/dev/null 2>&1; then
        log_info "  [skip] Xcode Command Line Tools already installed"
        return 0
    fi
    log_warn "Xcode Command Line Tools are not installed."
    log_info "A dialog box will open. Click 'Install' and wait for it to finish, then press Enter."
    xcode-select --install || true   # returns non-zero if already installed or dialog dismissed
    read -r -p "Press Enter once the installation dialog has completed... " _ < /dev/tty
    if ! xcode-select -p >/dev/null 2>&1; then
        log_error "Xcode CLT still not detected. Please install manually and re-run this wizard."
        return 1
    fi
}
```

This is the honest-and-simple pattern: kick off the GUI, tell the user what to do, wait for them to confirm, re-check. Do NOT attempt silent/headless CLT install — the softwareupdate-based trick is fragile and Apple frequently changes it.

### MCP server install pattern (reuses `claude mcp add`)

```bash
install_mcp_server() {
    local name="$1" cmd="$2" args="$3"
    if claude mcp list 2>/dev/null | grep -q "^$name"; then
        log_info "  [skip] MCP server $name already registered"
        return 0
    fi
    log_info "  [install] MCP server $name"
    # shellcheck disable=SC2086
    claude mcp add --scope user "$name" -- $cmd $args
}

# Usage:
install_mcp_server rmcp       "uvx" "rmcp"
install_mcp_server markitdown "uvx" "markitdown-mcp"
install_mcp_server pandoc     "uvx" "mcp-pandoc"
```

Using `claude mcp add` rather than hand-editing `.mcp.json` is more robust because (a) `claude` validates the entry, (b) user-scope survives across projects, (c) the exact same command form is used in `docs/general/installation.md` lines 246-274 for SuperDoc/openpyxl, so behavior is consistent.

## Decisions

1. **Script location**: `scripts/install/` at repo root (NOT `.claude/scripts/`). Justification: `.claude/scripts/` is agent-system infra; these scripts are user-facing.
2. **One script per `docs/toolchain/*.md` file** EXCEPT `README.md` (is an index) and `extensions.md` (is a router). Six per-group scripts + one master + one `lib.sh` = **8 shell files total**.
3. **Shared `lib.sh`**. Strong yes — without it each script duplicates ~50 lines of prompt/log/brew helpers and they will drift.
4. **`claude mcp add --scope user`** is the canonical MCP install form (not `.mcp.json` editing).
5. **Each group runs in a subprocess** via `bash scripts/install/install-<group>.sh` so `set -euo pipefail` inside a group does not abort the whole wizard.
6. **Ordering**: base -> shell-tools -> python -> r -> typesetting -> mcp. Dictated by cross-group prereqs (markitdown needs uv; MCP servers need claude + uvx).
7. **Idempotency via `brew list --formula`, `brew list --cask`, `command -v`, and R `packageVersion()` checks.** No tool installs twice, so the master script is safe to re-run as often as needed.
8. **Xcode CLT via GUI dialog + Enter-prompt**, not automated. Scripted headless CLT install is brittle and Apple-specific; honest handoff to the dialog is cleaner.
9. **`HOMEBREW_NO_AUTO_UPDATE=1`** on every `brew install` to keep runtime tolerable (otherwise each call re-fetches taps).
10. **Doc layout**: "Quick install (script)" section ABOVE manual content in every toolchain doc; new "Installation wizard (recommended)" section at top of `docs/general/installation.md`. Existing manual sections preserved verbatim.

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| `brew` command fails mid-install (network, tap update) | Medium | `brew_install_formula` returns non-zero, subshell per-group isolates the failure, group reported in `GROUPS_FAILED`, wizard continues. User can re-run. |
| User hits Ctrl-C mid-wizard | High | `trap on_exit EXIT INT TERM` prints a partial summary; idempotency means re-running picks up where they left off. |
| Xcode CLT dialog is dismissed by user | Medium | Re-check `xcode-select -p` after the read-prompt; fail with clear message. |
| `claude mcp add` runs before `claude` is on PATH | Low | Master script asserts `claude` after base group; MCP group script has its own `require_cmd claude`. |
| Epidemiology R bundle takes 15-20 min and user thinks script hung | Medium | `log_warn` banner before the install, explicit "this will take 15-20 minutes" message, maybe a `&` tail of install.log if we get fancy. |
| User on Intel Mac vs Apple Silicon (different Homebrew prefix) | Low | Use `brew` from PATH, never hardcode `/opt/homebrew` or `/usr/local`. `brew --prefix` for any prefix query. |
| `sudo tlmgr install` requires sudo password mid-run | Medium | Print a clear "This step needs sudo; you may be asked for your password" warning before the tlmgr line. Offer skip. |
| Script runs on Linux (wrong platform) | Low | `[[ "$(uname -s)" == "Darwin" ]]` guard at top of master; per-group scripts echo a warning if not Darwin. |
| `fc-list` missing so font checks always return empty | Medium | Install `fontconfig` as part of typesetting group BEFORE font installs, guarded by `have_cmd fc-list`. |
| Claude Code not restarted after MCP changes | High | Master script prints a prominent "RESTART CLAUDE CODE NOW" banner if any MCP server was installed in this run. |
| Documentation wizard section drifts from actual script behavior | Medium | Both the wizard section in `installation.md` and the "Quick install (script)" stub in each toolchain file only reference the script filename + the y/N/q contract — no command-level details that could drift. |

## Context Extension Recommendations

- **Topic**: User-facing install wizards for agent-system repos.
- **Gap**: `.claude/context/` has no pattern doc for writing beginner-friendly bash install wizards with interactive group prompts. This task's script set will be the reference implementation; worth extracting a pattern note once the scripts land.
- **Recommendation**: After implementation, write `.claude/context/patterns/install-wizard-pattern.md` capturing the `lib.sh` helpers, the `[y/N/q]` contract, the per-group header template, and the doc integration pattern, so future projects can copy-paste the approach.

## Appendix

### Files read during this research
- `/home/benjamin/.config/zed/docs/general/installation.md` (311 lines)
- `/home/benjamin/.config/zed/docs/toolchain/README.md`
- `/home/benjamin/.config/zed/docs/toolchain/r.md` (264 lines)
- `/home/benjamin/.config/zed/docs/toolchain/python.md` (327 lines)
- `/home/benjamin/.config/zed/docs/toolchain/typesetting.md` (221 lines)
- `/home/benjamin/.config/zed/docs/toolchain/mcp-servers.md` (197 lines)
- `/home/benjamin/.config/zed/docs/toolchain/shell-tools.md` (166 lines)
- `/home/benjamin/.config/zed/docs/toolchain/extensions.md` (218 lines)
- `/home/benjamin/.config/zed/.claude/scripts/install-aliases.sh` (for style reference)

### Tool matrix at a glance

| Group | Hard deps (base) | Cross-group deps | Total packages | Est. install time (fresh Mac) |
|---|---|---|---|---|
| base | — | — | 7 (Xcode, brew, node, zed, claude, 2 mcp) | 10-15 min |
| shell-tools | brew | — | 5 (jq, gh, make, git, fontconfig) | 1-2 min |
| python | brew | — | 3 required + 3 optional + 8 filetypes pkgs | 3-5 min |
| r | brew | — | 1 + 3 packages + 2 optional + 25-pkg epi bundle | 2 min base, 15-20 min with epi bundle |
| typesetting | brew, uv (python) | python | 7-10 (LaTeX + Typst + Pandoc + markitdown + fonts) | 5-10 min (BasicTeX), 30+ min (MacTeX) |
| mcp-servers | claude (base), uvx (python) | base, python | 3 servers + 1 manual (obsidian) | 1-2 min |

**Total wizard runtime on a fresh Mac**: ~40 minutes for core (no MacTeX, no epi bundle), ~90+ min if user accepts everything.

## Confidence

| Recommendation | Confidence | Why |
|---|---|---|
| Script layout (`scripts/install/`) | HIGH | Clear convention separation from `.claude/scripts/`, matches predecessor patterns. |
| Six per-group scripts + `lib.sh` + master | HIGH | 1:1 with doc files, obvious mental model. |
| Per-group `[y/N/q]` prompt contract | HIGH | Standard bash idiom, well-understood. |
| Nested sub-prompts inside groups (LaTeX variant, R bundle, etc.) | MEDIUM | Adds UX surface but is necessary because the groups aren't uniformly "install everything". Validate with user in review. |
| `claude mcp add --scope user` over `.mcp.json` edits | HIGH | Matches existing `installation.md` pattern. |
| Subprocess per group (`bash install-X.sh`) | HIGH | Simple failure isolation. |
| `HOMEBREW_NO_AUTO_UPDATE=1` | HIGH | Well-known brew perf knob. |
| Doc layout (wizard-above-manual, manual preserved verbatim) | HIGH | Non-breaking, serves both audiences. |
| Xcode CLT via GUI dialog + Enter-prompt | MEDIUM | Only real option; user could find it janky but there is no cleaner path. |
| Epi bundle as a single 15-20 min install | MEDIUM | Could split into "core epi" + "Stan-backed extras" if too slow, but one prompt is cleaner first pass. |
