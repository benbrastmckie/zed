# Implementation Summary: Task 31 — Toolchain Installation Scripts & Wizard

**Completed**: 2026-04-10
**Phases**: 7 of 7 completed

## Changes Made

Shipped `scripts/install/`: a shared `lib.sh` helper library, six per-group installers (`install-base.sh`, `install-shell-tools.sh`, `install-python.sh`, `install-r.sh`, `install-typesetting.sh`, `install-mcp-servers.sh`), and a master wizard `install.sh` that dispatches each group in a failure-isolated subprocess with accept/skip/cancel prompts, presets (`minimal`, `epi-demo`, `writing`, `everything`), and `--dry-run` / `--check` / `--yes` / `--only` / `--help` flags. All seven group scripts mirror the Check/Install/Verify verbs documented in `docs/general/installation.md` and `docs/toolchain/*.md` but hard-code every install action in bash — no script reads any markdown file at runtime. `install-mcp-servers.sh` carries a prominent comment header documenting the Lean MCP resurrection guard.

Every toolchain doc (`docs/toolchain/shell-tools.md`, `python.md`, `r.md`, `typesetting.md`, `mcp-servers.md`) was prefixed with a "Quick install (script)" section that points at the matching script, and every pre-existing Check/Install/Verify content was preserved verbatim under a new "Manual installation (advanced)" heading. `docs/general/installation.md` now leads with a beginner-friendly "Installation wizard (recommended)" walkthrough (open Terminal, `xcode-select --install`, `git clone`, `cd`, `bash scripts/install/install.sh`); the entire original manual walkthrough is preserved under "Manual installation (advanced)". `docs/toolchain/README.md` gained a prominent wizard callout at the top; `docs/toolchain/extensions.md` gained a router clarification note. The repo-root `README.md` Quick Start was rewritten to lead with the three-line wizard invocation.

## Files Created

- `scripts/install/lib.sh` — shared helpers (logging, prompts, presence checks, flag parsing, `parse_common_flags`, `preset_groups`, `on_exit` trap, `assert_macos`, `require_brew`)
- `scripts/install/install-base.sh` — Xcode CLT, Homebrew, Node, Zed, Claude Code CLI, SuperDoc + openpyxl MCP
- `scripts/install/install-shell-tools.sh` — jq, gh, fontconfig, optional GNU make
- `scripts/install/install-python.sh` — python, uv, ruff + optional uv tools + filetypes packages
- `scripts/install/install-r.sh` — R, languageserver/lintr/styler + optional renv/Quarto/epi bundle (CRAN mirror pinned)
- `scripts/install/install-typesetting.sh` — LaTeX (BasicTeX default, MacTeX opt-in), Typst, Pandoc, markitdown, fonts
- `scripts/install/install-mcp-servers.sh` — rmcp, markitdown-mcp, mcp-pandoc + obsidian pointer (Lean MCP guard header)
- `scripts/install/install.sh` — master wizard
- `specs/031_toolchain_installation_scripts/summaries/01_install-wizard-summary.md` — this file

## Files Modified

- `docs/general/installation.md` — prepended "Installation wizard (recommended)" lead section; existing manual walkthrough preserved verbatim under "Manual installation (advanced)"
- `docs/toolchain/README.md` — wizard callout at top
- `docs/toolchain/shell-tools.md` — "Quick install (script)" prefix; existing manual content preserved verbatim
- `docs/toolchain/python.md` — "Quick install (script)" prefix
- `docs/toolchain/r.md` — "Quick install (script)" prefix
- `docs/toolchain/typesetting.md` — "Quick install (script)" prefix
- `docs/toolchain/mcp-servers.md` — "Quick install (script)" prefix with Lean MCP invariant note
- `docs/toolchain/extensions.md` — router clarification note at top
- `README.md` — three-line wizard Quick Start section
- `specs/031_toolchain_installation_scripts/plans/01_install-wizard-scripts.md` — phase status markers and plan metadata set to COMPLETED

## Verification

**Syntax**: `bash -n` passes on all 8 scripts in `scripts/install/`. `shellcheck` was not run because it is unavailable in the NixOS agent sandbox; scripts were authored to its recommendations (quoted expansions, `$(...)` over backticks, `command -v` over `which`, no bashisms above 3.2).

**Functional smoke tests** (run on Linux by faking `uname` to return `Darwin`, since the hard `assert_macos` gate would otherwise block any non-Mac run):

- `bash scripts/install/install.sh --help` lists all six groups, four presets, and every common flag.
- `bash scripts/install/install.sh --check` produces a consolidated health report across all six groups and exits non-zero because tools are missing on this non-Mac host (expected).
- `bash scripts/install/install.sh --preset everything --dry-run --yes` dispatches all six groups successfully and prints the final `OK: base shell-tools python r typesetting mcp-servers` summary.
- `bash scripts/install/install.sh --preset epi-demo --dry-run --yes` dispatches the expected five groups.
- `bash scripts/install/install.sh --only r --dry-run --yes` dispatches the single `r` group.
- Each per-group script responds to `--help` with its own help block followed by the common flags footer.

**Invariants**:

- No script reads, parses, or scrapes any `.md` file at runtime (verified by `grep` — every `.md` reference is a comment, a log message, or a path argument to `open`).
- `install-mcp-servers.sh` lines 3-19 carry the LEAN MCP RESURRECTION GUARD comment header.
- Every install action is preceded by a presence check (`command -v`, `brew list --formula/--cask`, `Rscript -e requireNamespace`, `uv tool list`, `claude mcp list`) — scripts are idempotent.
- All `install.packages()` calls pin `repos="https://cloud.r-project.org"` to skip the CRAN mirror prompt.
- Master wizard subprocess-isolates each group (a failing group logs to `GROUPS_FAILED` and the wizard continues).
- `trap on_exit EXIT INT TERM` prints the partial summary on Ctrl-C.

## Deviations from the Plan

- **shellcheck**: not run (not available on the NixOS agent sandbox). Scripts hand-audited against shellcheck conventions. On a real Mac, running `shellcheck scripts/install/*.sh` is the recommended follow-up; zero errors are expected.
- **Mac-only smoke test**: all `--dry-run` scenarios were exercised on Linux with a PATH-shadowed `uname` stub returning `Darwin`. A real Mac run is still recommended to confirm the Xcode CLT handoff prompt and the `open` command in `install-mcp-servers.sh` behave as intended.
- **`require_brew` helper**: added to `lib.sh` during Phase 7 after the initial smoke test showed that the four non-base group scripts' brew hard-gate prevented `--dry-run --preset everything` from completing when Homebrew isn't yet installed. In dry-run mode `require_brew` warns and continues; in real-install mode it still exits 3 with the "run install-base.sh first" error. This is a small improvement on the plan and does not violate any constraint.
- **extensions.md pointer note**: added as specified in the plan (optional router clarification only, not a script prefix).

## Next Steps (optional follow-ups)

1. Run `shellcheck scripts/install/*.sh` on a real Mac.
2. Run `bash scripts/install/install.sh --check` on a real Mac to validate the consolidated health report against a real Homebrew install.
3. Eventual `/doctor` command can consume the per-script `--check` contract established here (uniform exit codes: 0 = all present, 1 = missing).
