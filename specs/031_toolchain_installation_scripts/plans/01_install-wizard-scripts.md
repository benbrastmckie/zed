# Implementation Plan: Toolchain Installation Scripts & Wizard

- **Task**: 31 - toolchain_installation_scripts
- **Status**: [IMPLEMENTING]
- **Effort**: 12 hours
- **Dependencies**: Task 30 (toolchain documentation) - COMPLETED
- **Research Inputs**: specs/031_toolchain_installation_scripts/reports/01_team-research.md (plus 01_teammate-{a,b,c,d}-findings.md)
- **Artifacts**: plans/01_install-wizard-scripts.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/plan-format-enforcement.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Task 30 shipped the documentation half of the reproducibility story for this zed/ configuration; Task 31 ships the executable half. We will create a `scripts/install/` tree containing a shared `lib.sh`, one bash script per `docs/toolchain/*.md` file (excluding the `README.md` index and the `extensions.md` router), and a master `install.sh` wizard that prompts accept/skip/cancel for each collection, supports presets, and dispatches each group in a failure-isolated subprocess. Doc files in `docs/toolchain/` and `docs/general/installation.md` will be rewritten to lead with a "Quick install (script)" section, preserving the existing manual Check/Install/Verify blocks verbatim below. The definition of done is: `bash scripts/install/install.sh --dry-run` completes cleanly on the author's Mac, every toolchain doc begins with its script invocation, and `installation.md` opens with a beginner-friendly wizard walkthrough (Terminal → `xcode-select --install` → `git clone` → `bash scripts/install/install.sh`).

### Research Integration

Four teammates converged on: per-doc bash scripts + shared `lib.sh` + interactive master wizard; plain `read -r -p` (no TUI lib); `HOMEBREW_NO_AUTO_UPDATE=1`; idempotency via `command -v` / `brew list` / `packageVersion()` checks; `claude mcp add --scope user` (not hand-edited JSON); subprocess-per-group failure isolation. The plan adopts Teammate A's directory layout and naming (`install-<group>.sh`), Teammate D's strategic enhancements (presets, `--check` for future `/doctor` co-design, repo-root README Quick Start), Teammate B's prior-art reuse from `~/.config/nvim/scripts/`, and honors every Tier-1 and Tier-2 question from the critic via an explicit "Assumptions & Decisions" block in Phase 1. The Lean MCP resurrection guard (Critic #5) is a hard invariant: scripts never scrape markdown; all install actions are hard-coded in bash.

### Prior Plan Reference

No prior plan. This is round 1 for task 31.

### Roadmap Alignment

- Advances the reproducibility/onboarding roadmap item initiated by tasks 20, 27, 28, 30.
- Cross-task note (not a hard dependency): unlocks a live-demo path for task 29 (conference talk) via `./install.sh --preset=epi-demo`.
- Cross-task note: co-designs the `--check` contract with a future `/doctor` command (task 30 follow-on); defer state-ledger design to `/doctor` itself.

## Assumptions & Decisions (resolving Critic Tier 1 & 2)

1. **Granularity**: Each group script may contain 2-4 nested sub-prompts (e.g., R core / renv / Quarto / epi bundle). Master-level accept/skip/cancel operates on the group; finer y/N happens inside.
2. **Topological order**: base → shell-tools → python → r → typesetting → mcp-servers (justified: markitdown needs uv; rmcp needs uv+R; claude-mcp-add needs the `claude` CLI from base).
3. **Git-before-clone bootstrap**: Documented, not automated. The wizard asserts git is present and points at the lead docs if not.
4. **`extensions.md`**: No script. It is a router; epi R bundle lives in `install-r.sh`, Slidev/npm lives in `install-shell-tools.sh` (or natural home).
5. **Lean MCP resurrection guard**: Scripts NEVER scrape markdown. Hard-coded install actions only. Comment header in `install-mcp-servers.sh` states Lean MCP is intentionally absent.
6. **`obsidian-memory`**: print-and-skip with an offer to `open` the setup guide.
7. **Verify policy**: Run Verify after each group's Install, log failure into `GROUPS_FAILED`, do NOT abort; final summary highlights failures.
8. **`settings.json` mutations**: Out of scope for v1.
9. **Idempotency depth**: Per-tool; every install action guarded by a presence check.
10. **Sudo / CRAN mirror**: Print warnings before sudo-requiring steps; force `repos="https://cloud.r-project.org"` to skip R's mirror prompt.
11. **Ctrl-C / partial state**: `trap on_exit EXIT INT TERM` prints a partial summary; idempotent re-run.
12. **Dry-run mode**: `--dry-run` on master and every group script.
13. **Logging**: stderr only; user redirects with `| tee` if desired.
14. **Topological order vs override**: Interactive mode enforces order; `--only <group>` lets users own the prereq risk.
15. **Shell compatibility**: `#!/usr/bin/env bash`, bash 3.2+ compatible (no `mapfile`, no `${var,,}`).
16. **CWD**: Scripts discover their own dir via `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`.
17. **Uninstall/Upgrade/Version pinning**: Out of scope.

## Goals & Non-Goals

**Goals**:
- Ship `scripts/install/lib.sh` shared helpers with `prompt_yn`, `log_info/warn/error`, `check_command`, `brew_install_formula`, `brew_install_cask`, `run_or_dry`.
- Ship 6 per-group scripts: `install-base.sh`, `install-shell-tools.sh`, `install-python.sh`, `install-r.sh`, `install-typesetting.sh`, `install-mcp-servers.sh`.
- Ship `install.sh` master wizard with accept/skip/cancel prompts, topological dispatch, subprocess isolation, `GROUPS_FAILED` summary.
- Support flags: `--dry-run`, `--yes`, `--only <group>`, `--preset <name>`, `--check`, `--help`.
- Support presets: `minimal`, `epi-demo`, `writing`, `everything`.
- Rewrite `docs/general/installation.md` to lead with the wizard walkthrough (beginner path), preserving all existing manual content below.
- Prefix every `docs/toolchain/*.md` (except `README.md` and `extensions.md`) with a "Quick install (script)" section pointing at the matching script, preserving existing Check/Install/Verify blocks verbatim.
- Add a 3-line Quick Start block to the repo-root `README.md` linking to the wizard.
- Pass `--dry-run` smoke test on the author's Mac.

**Non-Goals**:
- Brewfile as primary mechanism (side-artifact Brewfiles deferred).
- Nix / home-manager / Just / Make / TUI libraries.
- TOML manifest (`groups.toml`) for dispatch.
- Automated uninstall, upgrade, or version pinning.
- Editing `.claude/settings.json` or any runtime config.
- CI test harness (fresh-Mac VM runner is deferred; author-machine smoke test is sufficient for v1).
- Building `/doctor` itself (only the contract is co-designed).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Sudo / interactive prompts break non-interactive flow | M | M | Print clear warnings before sudo steps; force CRAN mirror; document interactive beats in comment headers. |
| Xcode CLT headless install is fragile | M | H | Honest GUI dialog handoff + Enter-to-continue prompt; do not try `softwareupdate` tricks. |
| Lean MCP accidentally re-added via markdown scraping | H | L | Hard invariant: all install verbs hard-coded in bash; comment header in `install-mcp-servers.sh` documents the intentional absence. |
| Script drift vs docs | M | M | Verify phase manually cross-checks each script against its doc's Install section; plan includes a consistency checklist. |
| bash 3.2 vs bash 5 compatibility bugs | M | M | `shellcheck` pass + explicit avoidance list in `lib.sh` header (`mapfile`, `${var,,}`, `nameref`, associative arrays at top level). |
| Partial-install state confuses re-run | M | L | Idempotency via presence checks; `trap on_exit` prints what ran and what remains. |
| Beginner user confused by Terminal steps | M | M | `installation.md` lead section is explicit: open Terminal, run `xcode-select --install`, `git clone`, `cd`, `bash scripts/install/install.sh`; screenshots not required but step-by-step. |
| Doc rewrites accidentally drop existing manual content | H | L | Append-only policy: add "Quick install" section above existing content; never delete manual Check/Install/Verify blocks. Phase 5 includes diff review. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Contract design & `lib.sh` scaffold [COMPLETED]

**Goal**: Establish the script contract (flags, exit codes, presets, `--check` interface) and implement the shared helper library with all primitives the per-group scripts will consume.

**Tasks**:
- [ ] Create `scripts/install/` directory.
- [ ] Write `scripts/install/lib.sh` with header comment documenting bash 3.2 compatibility constraints and the `--check` contract for `/doctor` co-design.
- [ ] Implement helpers: `log_info`, `log_warn`, `log_error`, `log_ok`, `print_section`, `prompt_yn`, `prompt_accept_skip_cancel`, `check_command`, `brew_install_formula`, `brew_install_cask`, `r_package_installed`, `uv_tool_installed`, `run_or_dry`, `on_exit` trap handler.
- [ ] Define uniform exit codes: 0=success, 1=missing (check mode), 2=user-cancelled, 3=prereq failure, 4=install failure.
- [ ] Define `--dry-run`, `--yes`, `--only`, `--preset`, `--check`, `--help` flag-parsing helper `parse_common_flags`.
- [ ] Define presets dictionary: `minimal` = base + shell-tools; `epi-demo` = base + shell-tools + python + r + typesetting; `writing` = base + typesetting + shell-tools; `everything` = all groups.
- [ ] Set `HOMEBREW_NO_AUTO_UPDATE=1` in `lib.sh` sourcing preamble.
- [ ] Add `SCRIPT_DIR` discovery pattern to `lib.sh`.
- [ ] Lift naming/shape patterns from `~/.config/nvim/scripts/check-dependencies.sh` and `setup-with-claude.sh` (prior art).
- [ ] Run `shellcheck scripts/install/lib.sh`.

**Timing**: 2 hours

**Depends on**: none

**Files to create**:
- `scripts/install/lib.sh` - shared helper library.
- `scripts/install/` - new directory.

**Verification**:
- `bash -n scripts/install/lib.sh` parses cleanly.
- `shellcheck scripts/install/lib.sh` reports no errors.
- Sourcing `lib.sh` from an ad-hoc test script exposes `prompt_yn` and `log_info` correctly.

---

### Phase 2: Base installer [COMPLETED]

**Goal**: Implement `install-base.sh` covering every tool mentioned in `docs/general/installation.md` (Homebrew bootstrap, Xcode CLT handoff, git, Claude Code CLI, Zed, core brew formulae).

**Tasks**:
- [ ] Create `scripts/install/install-base.sh` sourcing `lib.sh`.
- [ ] Implement `main()` calling `parse_common_flags`.
- [ ] Gate: `[[ "$(uname -s)" == "Darwin" ]] || { log_error "macOS only"; exit 3; }`.
- [ ] Check + handoff Xcode Command Line Tools (GUI dialog + Enter-to-continue prompt).
- [ ] Check + install Homebrew via its official bootstrap command.
- [ ] Check + install git (brew).
- [ ] Check + install Claude Code CLI per `installation.md` lines covering the `claude` install.
- [ ] Check + install Zed (cask).
- [ ] Install every other explicit dependency in `docs/general/installation.md` (enumerated during implementation by cross-referencing the file).
- [ ] Implement `--check` mode: runs Check block only, exits 0/1.
- [ ] Implement `--dry-run` mode: prints planned actions without executing.
- [ ] Run `shellcheck scripts/install/install-base.sh`.
- [ ] Test `bash scripts/install/install-base.sh --check` and `--dry-run` on author's Mac.

**Timing**: 1.5 hours

**Depends on**: 1

**Files to create**:
- `scripts/install/install-base.sh`.

**Verification**:
- `shellcheck` clean.
- `--check` reports accurately on author's Mac.
- `--dry-run` prints all planned actions without side effects.

---

### Phase 3: Per-group toolchain scripts [COMPLETED]

**Goal**: Implement the five remaining per-group installers in parallel, each mapping 1:1 with a `docs/toolchain/*.md` file (excluding `README.md` and `extensions.md`).

**Tasks**:
- [ ] `scripts/install/install-shell-tools.sh` — covers every verb in `docs/toolchain/shell-tools.md` (ripgrep, fd, bat, eza, jq, gh, yq, etc., plus any Slidev/npm bits that previously lived in `extensions.md`). Nested sub-prompts if needed.
- [ ] `scripts/install/install-python.sh` — covers `docs/toolchain/python.md` (uv, uv tool installs, uvx invocations, pip installs). Sub-prompts for: uv core, uv tools, markitdown.
- [ ] `scripts/install/install-r.sh` — covers `docs/toolchain/r.md` (R via brew cask, renv bootstrap, Quarto, epi-bundle R packages). Force CRAN mirror. Sub-prompts for: R core / renv / Quarto / epi bundle.
- [ ] `scripts/install/install-typesetting.sh` — covers `docs/toolchain/typesetting.md` (LaTeX variant choice, Typst, Pandoc, markitdown pointer, fonts). Sub-prompts for each. Comment header notes `.claude/settings.json` typst allowlist is a separate concern.
- [ ] `scripts/install/install-mcp-servers.sh` — covers `docs/toolchain/mcp-servers.md`, using `claude mcp add --scope user` exclusively. Sub-prompts per server. `obsidian-memory` uses print-and-skip with an `open` offer. Comment header states Lean MCP is intentionally absent (Critic #5 invariant).
- [ ] Each script: implements `main()`, `--check`, `--dry-run`, uniform exit codes, sources `lib.sh`, calls `parse_common_flags`.
- [ ] Each script: every install action preceded by a presence check (`command -v`, `brew list`, `Rscript -e 'packageVersion(...)'`, `uv tool list`).
- [ ] Run `shellcheck` on all five scripts.
- [ ] Test each with `--check` and `--dry-run` on author's Mac.

**Timing**: 3 hours (5 scripts in parallel-ish, ~35 min each)

**Depends on**: 1

**Files to create**:
- `scripts/install/install-shell-tools.sh`
- `scripts/install/install-python.sh`
- `scripts/install/install-r.sh`
- `scripts/install/install-typesetting.sh`
- `scripts/install/install-mcp-servers.sh`

**Verification**:
- `shellcheck` clean on all five.
- Each `--check` correctly reports present/missing on author's machine.
- Each `--dry-run` prints planned actions without side effects.
- No script references or reads any markdown file (Lean MCP resurrection guard).

---

### Phase 4: Master wizard `install.sh` [COMPLETED]

**Goal**: Implement the interactive master wizard that prompts accept/skip/cancel for each collection, dispatches each script in a subprocess, supports presets and flags, and prints a final summary.

**Tasks**:
- [ ] Create `scripts/install/install.sh`.
- [ ] Source `lib.sh`; set `set -euo pipefail`.
- [ ] Implement `parse_common_flags` with master-specific additions (`--preset`, `--only`).
- [ ] Hard-code topological group order: `base shell-tools python r typesetting mcp-servers`.
- [ ] For each group: print a 2-4 sentence explanation ("what will be installed and why"), then `prompt_accept_skip_cancel`.
- [ ] Dispatch each accepted group via `bash "$SCRIPT_DIR/install-<group>.sh" "$@"` (subprocess isolation).
- [ ] Record outcome in `GROUPS_OK` / `GROUPS_SKIPPED` / `GROUPS_FAILED` arrays.
- [ ] `trap on_exit EXIT INT TERM` prints partial summary.
- [ ] Implement preset expansion: `--preset epi-demo` → `--only base,shell-tools,python,r,typesetting` with `--yes`.
- [ ] Implement final summary block (OK / SKIPPED / FAILED with counts and next-step hints).
- [ ] Implement `--help` output listing all groups, presets, flags.
- [ ] Implement `--check` mode: runs `--check` on every group script and prints a consolidated health report.
- [ ] Assert macOS gate and git presence (point at `installation.md` lead if missing).
- [ ] Run `shellcheck scripts/install/install.sh`.
- [ ] Manual end-to-end test with `--dry-run` and `--preset epi-demo --dry-run`.

**Timing**: 2 hours

**Depends on**: 2, 3

**Files to create**:
- `scripts/install/install.sh`.

**Verification**:
- `shellcheck` clean.
- `bash scripts/install/install.sh --dry-run` walks through all six groups with accept/skip/cancel prompts.
- `bash scripts/install/install.sh --preset epi-demo --dry-run` runs non-interactively across 5 groups.
- `bash scripts/install/install.sh --check` produces a clean health report.
- Ctrl-C mid-wizard prints a partial summary.

---

### Phase 5: Documentation rewrites [COMPLETED]

**Goal**: Rewrite `docs/general/installation.md` with a beginner-friendly wizard lead and prefix every `docs/toolchain/*.md` (except `README.md` and `extensions.md`) with a "Quick install (script)" section, preserving all existing manual content verbatim.

**Tasks**:
- [ ] Rewrite `docs/general/installation.md` lead: new "Installation wizard (recommended)" section walks a beginner through (1) open Terminal, (2) `xcode-select --install`, (3) `git clone <repo>`, (4) `cd zed`, (5) `bash scripts/install/install.sh`. Mention presets briefly. Preserve the existing manual instructions below as "Manual installation (advanced)".
- [ ] Prefix `docs/toolchain/shell-tools.md` with a "Quick install (script)" section showing `bash scripts/install/install-shell-tools.sh`, `--check`, `--dry-run`. Preserve existing Check/Install/Verify content verbatim below.
- [ ] Same prefix for `docs/toolchain/python.md` pointing at `install-python.sh`.
- [ ] Same prefix for `docs/toolchain/r.md` pointing at `install-r.sh`.
- [ ] Same prefix for `docs/toolchain/typesetting.md` pointing at `install-typesetting.sh`.
- [ ] Same prefix for `docs/toolchain/mcp-servers.md` pointing at `install-mcp-servers.sh`.
- [ ] Update `docs/toolchain/README.md` index to note the wizard at the top and link to `scripts/install/`.
- [ ] Leave `docs/toolchain/extensions.md` unchanged except for an optional pointer at the top noting it is a router, not an installer; sub-topics live in their natural home scripts.
- [ ] Diff review: each rewritten toolchain file MUST preserve all prior Check/Install/Verify content byte-for-byte in the "Manual installation" section.

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `docs/general/installation.md` - add wizard lead section.
- `docs/toolchain/README.md` - note wizard at top.
- `docs/toolchain/shell-tools.md` - prefix Quick install section.
- `docs/toolchain/python.md` - prefix Quick install section.
- `docs/toolchain/r.md` - prefix Quick install section.
- `docs/toolchain/typesetting.md` - prefix Quick install section.
- `docs/toolchain/mcp-servers.md` - prefix Quick install section.
- `docs/toolchain/extensions.md` - optional router note (no script).

**Verification**:
- Every toolchain doc (except README.md, extensions.md) opens with a "Quick install (script)" section.
- `installation.md` opens with the wizard walkthrough; existing manual content intact below.
- `git diff --stat` shows only additions to the manual sections (no deletions).

---

### Phase 6: Repo-root README Quick Start [NOT STARTED]

**Goal**: Add a 3-line Quick Start block to the repo-root `README.md` so the wizard is discoverable from the GitHub landing page.

**Tasks**:
- [ ] Locate repo-root `README.md` (create a minimal stub if it does not exist).
- [ ] Add a "Quick Start" section near the top:
  ```
  git clone <repo-url> ~/.config/zed
  cd ~/.config/zed
  bash scripts/install/install.sh
  ```
- [ ] Link to `docs/general/installation.md` for the full walkthrough and `docs/toolchain/README.md` for per-group detail.
- [ ] Optionally mention presets (`--preset epi-demo`, `--preset writing`).

**Timing**: 0.5 hours

**Depends on**: 5

**Files to modify**:
- `README.md` (repo root).

**Verification**:
- README shows the 3-line block above the fold.
- Links resolve to the correct docs.

---

### Phase 7: Verification & smoke test [NOT STARTED]

**Goal**: Validate the full wizard + per-group scripts on the author's Mac via `--dry-run` and a manual consistency checklist; write a short verification log into the task summary.

**Tasks**:
- [ ] Run `shellcheck scripts/install/*.sh` with zero errors.
- [ ] Run `bash scripts/install/install.sh --help` and confirm all flags, groups, presets are listed.
- [ ] Run `bash scripts/install/install.sh --check` and capture the health report.
- [ ] Run `bash scripts/install/install.sh --dry-run` interactively, exercising accept, skip, and cancel on at least one group each.
- [ ] Run `bash scripts/install/install.sh --preset epi-demo --dry-run` and confirm non-interactive 5-group dispatch.
- [ ] Run `bash scripts/install/install.sh --preset everything --dry-run` and confirm all 6 groups dispatch.
- [ ] Run `bash scripts/install/install.sh --only r --dry-run` and confirm single-group override.
- [ ] Manual consistency checklist: for each per-group script, cross-check that every install verb in the corresponding `docs/toolchain/*.md` file has a matching action in the script (Lean MCP explicitly excluded).
- [ ] Test Ctrl-C mid-wizard and confirm the partial summary prints.
- [ ] Confirm no script reads any `.md` file at runtime (Lean MCP resurrection guard).
- [ ] Optionally run one real installation of a no-op group (e.g., `install-base.sh` on a machine where everything is already present) to confirm idempotency.

**Timing**: 1 hour

**Depends on**: 6

**Files to modify**:
- None (verification only).

**Verification**:
- All shellcheck passes.
- All dry-run scenarios above produce expected output with no errors.
- Consistency checklist complete for all six scripts.

## Testing & Validation

- [ ] `shellcheck` reports no errors on `scripts/install/lib.sh` and all 7 install scripts.
- [ ] `bash scripts/install/install.sh --help` lists groups, presets, and flags.
- [ ] `bash scripts/install/install.sh --check` produces a consolidated health report.
- [ ] `bash scripts/install/install.sh --dry-run` walks through all 6 groups interactively.
- [ ] `bash scripts/install/install.sh --preset epi-demo --dry-run` runs non-interactively.
- [ ] `bash scripts/install/install.sh --only <group> --dry-run` runs a single group.
- [ ] Ctrl-C mid-wizard prints partial summary via `trap on_exit`.
- [ ] Every toolchain doc opens with a "Quick install (script)" section; existing content preserved verbatim below.
- [ ] `installation.md` opens with the beginner wizard walkthrough.
- [ ] Repo-root README contains the 3-line Quick Start.
- [ ] No script reads any markdown file at runtime (grep check).
- [ ] `install-mcp-servers.sh` contains the "Lean MCP intentionally absent" comment header.

## Artifacts & Outputs

- `scripts/install/lib.sh`
- `scripts/install/install.sh` (master wizard)
- `scripts/install/install-base.sh`
- `scripts/install/install-shell-tools.sh`
- `scripts/install/install-python.sh`
- `scripts/install/install-r.sh`
- `scripts/install/install-typesetting.sh`
- `scripts/install/install-mcp-servers.sh`
- `docs/general/installation.md` (rewritten lead, manual content preserved)
- `docs/toolchain/README.md` (wizard note added)
- `docs/toolchain/shell-tools.md` (Quick install prefix)
- `docs/toolchain/python.md` (Quick install prefix)
- `docs/toolchain/r.md` (Quick install prefix)
- `docs/toolchain/typesetting.md` (Quick install prefix)
- `docs/toolchain/mcp-servers.md` (Quick install prefix)
- `docs/toolchain/extensions.md` (optional router note)
- `README.md` (repo root, Quick Start block)
- `specs/031_toolchain_installation_scripts/summaries/01_install-wizard-summary.md` (created at /implement postflight)

## Rollback/Contingency

- All changes are additive to docs and create new files under `scripts/install/`. Rollback is `git checkout -- docs/ README.md && rm -rf scripts/install/`.
- If a per-group script proves too complex in Phase 3, ship a stub that prints "Manual install — see docs/toolchain/<file>.md" and exits 0; master wizard continues unaffected. Flag the stub in Phase 7 summary.
- If `install.sh` cannot be completed in budget, ship the per-group scripts standalone and defer the master wizard to a follow-on task. Doc rewrites then point directly at per-group scripts and `installation.md` keeps its manual lead.
- If doc rewrites would destructively change existing content, abort the rewrite for that file and leave a `TODO:` comment at the top of the file referencing this plan.
