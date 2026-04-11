# Research Report: Task #31 — Toolchain Installation Scripts

- **Task**: 31 - toolchain_installation_scripts
- **Status**: [COMPLETED]
- **Date**: 2026-04-10
- **Mode**: Team Research (4 teammates: A primary, B alternatives, C critic, D horizons)
- **Session**: sess_1775875778_26e9ec
- **Inputs**: `docs/general/installation.md`, all files under `docs/toolchain/`, task 30 plan and summary, prior-art scripts in `~/.config/nvim/scripts/` and `~/.dotfiles/.claude/scripts/`, recent task trajectory (20, 27, 28, 29, 30).
- **Artifacts**:
  - `01_teammate-a-findings.md` (Primary Approach)
  - `01_teammate-b-findings.md` (Alternatives & Prior Art)
  - `01_teammate-c-findings.md` (Critic — gaps and unresolved questions)
  - `01_teammate-d-findings.md` (Horizons — strategic framing)
  - this synthesis
- **Standards**: report-format.md, plan-format-enforcement.md

## Executive Summary

Task 31 is the **executable half of the reproducibility story** that tasks 20/27/28/30 have been telling: docs already enumerate every dependency; this task makes them runnable. All four teammates converge on a hybrid approach — **per-toolchain bash scripts plus a shared `lib.sh` plus an interactive master wizard**, with Brewfile/gum/whiptail/Just/Nix all consciously rejected for chicken-and-egg or coverage reasons. Disagreement is concentrated in three places: (1) script-naming convention (`install-<group>.sh` vs `toolchain-<group>.sh`), (2) whether to add presets and a `groups.toml` manifest for portability, and (3) whether the design contract should be co-designed with a future `/doctor` command. The Critic surfaces **20 unresolved spec questions** that the planner must answer (or the planner must own as named assumptions) before phase design — most importantly: granularity inside heterogeneous files, topological ordering, the git-before-clone bootstrap, the Lean MCP resurrection risk, and `extensions.md`'s status as a router-not-installer.

**Strong recommendation to the planner**: open the plan with an "Assumptions & Decisions" section that resolves the critic's 20 questions explicitly, then proceed to phase design. Do NOT silently embed those decisions in phase tasks.

## Synthesis

### Where the team agrees (high confidence)

| Decision | Rationale | Source |
|---|---|---|
| **One bash script per `docs/toolchain/*.md` file** | Matches user spec ("each group of dependencies as documented by the different files"); 1:1 doc-to-script mapping is mechanically greppable. | A, B, D |
| **Shared `lib.sh` with `prompt_yn`/`log_*`/`brew_install_*`/`check_command` helpers** | Without it scripts duplicate ~50 lines and drift; nvim's `check-dependencies.sh` and `setup-with-claude.sh` are ready-to-adapt templates. | A, B |
| **Plain `read -r -p` accept/skip/cancel prompt loop, NO TUI library** | `gum`/`whiptail`/`fzf`/`just` all create chicken-and-egg with fresh-Mac bootstrap; `bash` + core utilities is the only safe assumption. | A, B |
| **Reject Brewfile-first as primary mechanism** | ~40-50% of install verbs in `docs/toolchain/` are non-brew (`install.packages`, `uv tool install`, `uvx`, `pip install`, `claude mcp add`, `npm install -g`); a Brewfile would force a shell-script tail anyway. | B (with caveat from D as Alt A) |
| **Reject Nix/home-manager/Just/Make as user-facing entry point** | Out of scope per task 30's macOS/Homebrew-only invariant; bootstrapping any of these defeats the "fresh Mac" framing. | A, B, D |
| **Use `claude mcp add --scope user` (NOT hand-edit `.mcp.json`)** | Validation; user-scope persistence; matches existing `installation.md` pattern at lines 246-274. | A |
| **Each per-group script runs in a subprocess from the master** | `set -euo pipefail` inside a group only kills that group; failure isolation per-collection; recorded into a final summary. | A |
| **Idempotency via `command -v`, `brew list --formula`, `brew list --cask`, `Rscript -e "packageVersion(...)"` checks** | Make re-runs cheap and safe; the master script is then resumable after Ctrl-C or partial failure. | A, B |
| **`HOMEBREW_NO_AUTO_UPDATE=1`** on every brew invocation | Otherwise each call re-fetches taps, making the wizard unbearable. | A |
| **Doc layout: "Quick install (script)" section ABOVE manual content in every toolchain file; new "Installation wizard" lead in `docs/general/installation.md`; existing manual sections preserved verbatim** | Non-breaking; serves both beginners (wizard path) and power users (manual path); preserves task 30's Check/Install/Verify template intact below the script section. | A, B, D |
| **Xcode CLT via GUI dialog + Enter-prompt, NOT scripted headless install** | Apple-specific softwareupdate trick is fragile; honest handoff to the dialog is the only durable path. | A |
| **`extensions.md` does NOT get its own script** | It is a router/index, not a tool-install file; per-extension references point at the other group scripts. | A, D (C flags this as ambiguous and worth confirming) |
| **macOS gate at top of master**: `[[ "$(uname -s)" == "Darwin" ]] || exit 1` | Hard-fail loudly; do not silently degrade. | A |

### Where the team diverges (planner must choose)

#### Divergence 1: Script-naming convention

- **Teammate A**: `scripts/install/install-<group>.sh` (master = `install.sh`, helpers = `lib.sh`)
- **Teammate B**: `scripts/install/toolchain-<group>.sh` (master = `install.sh`, helpers = `_lib.sh`)
- **Synthesis verdict**: Either works; A's scheme is shorter and more 1:1 with the doc filenames (`install-r.sh` ↔ `r.md`). Recommend A's convention. The leading underscore on `_lib.sh` (B's choice) is a stylistic preference with no operational difference.

#### Divergence 2: Presets vs interactive-only

- **Teammate D**: Strongly advocates presets (`--preset=epi-demo`, `--preset=writing`, `--preset=everything`, `--preset=minimal`) because the zed/ repo is shared with a collaborator who may want only R, while the author wants everything-no-questions.
- **Teammate A**: Interactive prompts only, with optional `--yes` (auto-accept), `--only <group>`, `--dry-run`, `--skip-base` flags.
- **Synthesis verdict**: D's preset framing is high-leverage AND cheap. Add presets as named bundles of `--only` flags. The interactive default mode remains the entry point for first-time users; presets serve the author + collaborator dual-audience. **Recommend including presets in the plan**.

#### Divergence 3: `/doctor` co-design

- **Teammate D**: Strong recommendation — design the script contract (exit codes, `--check` flag, `~/.config/zed/.install-state/` ledger, optional JSON status output) so a future `/doctor` can call `for s in scripts/install-*.sh; do "$s" --check; done` and get a clean health report. Treat task 31 and `/doctor` as a diagnose/remediate pair.
- **Teammate A**: Doesn't address `/doctor`; focuses on the install path.
- **Teammate B**: Doesn't address `/doctor`.
- **Teammate C**: Confirms task 30's plan explicitly listed `/doctor` as a follow-on.
- **Synthesis verdict**: D is right that one hour of contract design now saves days later. **Recommend the plan include a Phase 1 "Design the contract" deliverable**: per-script `--check` flag (runs Check sections only, exit 0 = present, 1 = missing), uniform exit codes, optional JSON output via `--json`. Defer the state ledger to `/doctor` itself unless cheap.

#### Divergence 4: Brewfile as additive supplement

- **Teammate D (Alt A)**: Pitches a Brewfile-first wizard with bash as a thin prompt layer.
- **Teammate B**: Rejects Brewfile-first (40-50% non-brew); proposes optional per-group `Brewfile.<group>` artifacts as a side deliverable for power users.
- **Synthesis verdict**: D's Brewfile-first vision is engineering-elegant but B's quantitative coverage analysis is correct: too much of the toolchain is non-brew. **Reject Brewfile as primary**. Side-artifact Brewfiles are deferrable — include only if plan budget allows.

#### Divergence 5: `groups.toml` manifest for portability

- **Teammate D**: Recommends a `scripts/install/groups.toml` manifest (group name, script path, doc path, description) so the master wizard reads the manifest instead of hard-coding paths, making the pattern portable to `nvim/` and `~/.dotfiles`.
- **Teammate A**: Hard-codes the dispatch loop in `install.sh`.
- **Synthesis verdict**: A manifest is overkill for v1 and adds a TOML parser dependency (no `tomlq` on a fresh Mac without brew). Reject for v1; revisit if/when porting to `nvim/` actually happens. The hard-coded dispatch in A's recommendation is fine; portability can be re-engineered later if needed.

### Critic's unresolved questions — planner MUST address (or own as named assumptions)

The critic surfaced 20 questions; the synthesis triages them by urgency:

**Tier 1 (must resolve before Phase design)**:

| # | Question | Synthesis recommendation |
|---|---|---|
| 1 | Granularity inside heterogeneous files (epi 25-package R bundle, typesetting LaTeX/Typst/Pandoc/markitdown/fonts) — file-level only or sub-prompts? | **Allow nested sub-prompts**: each per-group script may have 2-4 internal y/N prompts (R core / renv / Quarto / epi bundle; LaTeX variant / Typst / Pandoc / markitdown / fonts; etc.). The "accept/skip" at the master wizard level is for the whole group; finer choices happen inside. Document this in `lib.sh` as a `prompt_yn` reuse pattern. |
| 2 | Topological ordering of toolchain scripts | **Hard-code in master**: base → shell-tools → python → r → typesetting → mcp-servers. Justified by: markitdown needs uv (python before typesetting); rmcp needs uv + R (python + r before mcp); claude-mcp-add needs `claude` CLI (base before mcp). |
| 3 | Bootstrap chicken-and-egg: git-before-clone | **Document, don't bootstrap**: the wizard's lead section in `installation.md` walks through Terminal → `xcode-select --install` → `git clone` → `bash scripts/install/install.sh`. The wizard itself does NOT try to bootstrap git; it asserts git is present and points the user at the lead docs if not. |
| 4 | extensions.md script scope | **No script for `extensions.md`**: it is a router/index. The epidemiology R-package block currently inside it is ALREADY covered by `install-r.sh`'s "epi bundle" sub-prompt (per Teammate A); any other extras (Slidev npm, Stan toolchain) get sub-prompts in their natural home script. |
| 5 | Lean MCP resurrection guard | **Hard invariant**: scripts must NEVER scrape markdown for install commands. Each script hard-codes its install actions in bash. The Lean MCP "To restore" JSON snippet in `mcp-servers.md` is text-only; it never appears in `install-mcp-servers.sh`. Add a comment at the top of `install-mcp-servers.sh`: `# Lean MCP intentionally absent; see task 30 plan and mcp-servers.md decision record.` |
| 6 | Granularity for `obsidian-memory` (GUI-driven dependency) | **Print-and-skip**: `install-mcp-servers.sh` has an `obsidian-memory` step that prints the multi-step setup pointer and `prompt_yn "Open the setup guide now?"` (offering to `open` the markdown file in the user's default app). It does NOT attempt automation. |
| 7 | Verify policy | **Run Verify after each group's Install, log result, do NOT abort on failure**: failed verification is recorded into `GROUPS_FAILED` and the wizard continues. Final summary highlights failures. |
| 8 | settings.json mutations | **Out of scope for v1**: scripts install software only, never edit `.claude/settings.json`. The typst allowlist is already fixed in task 30; document in `install-typesetting.sh`'s comment header that the allowlist is a separate concern. |

**Tier 2 (planner should explicitly own as a documented assumption)**:

| # | Question | Synthesis recommendation |
|---|---|---|
| 9 | Idempotency depth (per tool, per file, per session) | **Per tool**: every install action is preceded by a `command -v` / `brew list` / `packageVersion()` check. No master-level state tracking. |
| 10 | Sudo/CRAN-mirror/cask-admin-password handling | **Document, don't hide**: each script that needs sudo or interactive input prints a clear "this step needs sudo" or "first-run R prompt" warning before invoking. CRAN mirror is forced via `repos="https://cloud.r-project.org"` to avoid the prompt entirely. |
| 11 | Ctrl-C / partial state | **`trap on_exit EXIT INT TERM`** prints a partial-install summary; idempotency means re-run picks up where the user left off. Per Teammate A. |
| 12 | Double-install dedup (git/make in installation.md AND shell-tools.md) | **Trust idempotency**: the `command -v git` / `brew list git` checks make repeats free. No master-level dedup needed. |
| 13 | Dry-run mode | **Add `--dry-run` to master and per-group scripts**: prints what would be installed without invoking brew/uv/Rscript. Cheap and dramatically eases testing. |
| 14 | Logging | **Log to stderr; no file**: the user can redirect with `bash install.sh 2>&1 | tee install.log` if they want a transcript. Trying to manage log files is scope creep. |
| 15 | Topological order vs user override | **Master enforces order** in interactive mode; users who want a single group can use `--only <group>` and own the prereq risk. |
| 16 | Shell compatibility | **`#!/usr/bin/env bash`**, target bash 3.2+ (the version bundled with macOS) AND bash 5+ (Homebrew bash). Avoid bash-4-only features (`mapfile`, `${var,,}`). |
| 17 | Working directory / CWD | **Master script discovers its own dir** via `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`; runs from anywhere. |

**Tier 3 (out of scope for task 31)**:

- **Uninstall** (#18 in critic): out of scope; document as "use `brew uninstall <pkg>`" in a one-line note.
- **Upgrade mode** (#19): out of scope; the wizard installs missing items only. A future `/doctor --update` could handle this.
- **Version pinning** (#20): out of scope; we pin nothing, take whatever Homebrew has.
- **CI testability**: acknowledge and defer; the realistic test is one fresh-Mac VM run.

### Strategic framing (from Teammate D)

This is not "automate the docs"; this is "**make the reproducibility story executable**". Task 31 is the natural peer of:

1. **Future `/doctor` command** (task 30 follow-on): install scripts remediate, `/doctor` diagnoses. Co-design the `--check` interface.
2. **Task 29 conference talk**: the wizard makes a live demo feasible inside the 18-minute talk budget — `./install.sh --preset=epi-demo` + `quarto render` instead of 20+ minutes of brew commands. **Flag this in the task 31 plan** so task 29 can opt in to a live demo.
3. **Repo-root `README.md` Quick Start** (3-line clone+cd+run block) so the wizard is one click from the GitHub landing page. **Strongly recommend including in scope**.
4. **Portability to `nvim/` and `~/.dotfiles`**: write the per-group scripts so they can be lifted unchanged. (D's `groups.toml` manifest is overkill for v1 but the per-group scripts being self-contained is essentially free.)

### Conflicts resolved during synthesis

| Conflict | Resolution |
|---|---|
| A's interactive-first vs D's preset-first framing | Both: presets layer on top of interactive default; presets are bundles of `--only` flags. |
| B's "no Brewfile" vs D's "Brewfile-first Alternative A" | B wins on quantitative coverage; defer optional Brewfiles as side artifact. |
| A's `install-<group>.sh` vs B's `toolchain-<group>.sh` naming | A wins (shorter, 1:1 with doc filenames). |
| A's hard-coded master dispatch vs D's `groups.toml` manifest | A wins for v1; manifest is YAGNI without a second-repo consumer. |
| C's "Verify must abort on failure" possibility vs A's "log and continue" | A: log and continue; final summary highlights failures. |

### Gaps remaining after synthesis

- **Test plan**: no teammate proposed a concrete test harness. Realistic options: (a) fresh-Mac VM (Tart, UTM), (b) GitHub Actions macOS runner with `--dry-run`, (c) manual checklist on the author's machine. **Recommend the plan include a Phase 7 "Verification" that runs `--dry-run` against a clean environment + manual smoke test on the author's Mac**.
- **README.md update**: Teammate D flags this; A and B don't address it. **Recommend explicit inclusion in scope** as a small phase.
- **Talk integration with task 29**: noted by D; should be captured as a cross-task note in the task 31 plan rather than a hard dependency.

## Recommendations to the Planner

1. **Open the plan with an "Assumptions & Decisions" section** that resolves the critic's Tier-1 and Tier-2 questions explicitly. Do not silently embed.
2. **Adopt Teammate A's primary design** as the spine: `scripts/install/` directory, `install.sh` master, `lib.sh` shared helpers, six per-group scripts (`install-base.sh`, `install-r.sh`, `install-python.sh`, `install-typesetting.sh`, `install-mcp-servers.sh`, `install-shell-tools.sh`), no `install-extensions.sh`.
3. **Layer in Teammate D's strategic enhancements**: `--preset=<minimal|epi-demo|writing|everything>` flag, `--check` flag for `/doctor` co-design, repo-root `README.md` Quick Start section (3 lines), explicit cross-task note flagging task 29 live-demo opportunity.
4. **Adopt Teammate B's prior-art reuse**: lift `print_section`/`log_*`/`check_command` shape from `~/.config/nvim/scripts/check-dependencies.sh` and `setup-with-claude.sh`. Save invention budget for the master orchestration.
5. **Honor every Tier-1 critic finding**: especially Lean MCP resurrection guard (hard-coded install actions, not markdown scraping), `extensions.md` no-script policy, `obsidian-memory` print-and-skip, `settings.json` out-of-scope.
6. **Plan phase shape** (suggested):

   | Phase | Name | Deliverable | Depends on |
   |---|---|---|---|
   | 1 | Contract design + scaffold | `scripts/install/lib.sh` skeleton, exit code conventions, `--check`/`--dry-run`/`--yes`/`--only`/`--preset` flag contracts, directory created | — |
   | 2 | Base installer | `install-base.sh` covering everything in `installation.md` | 1 |
   | 3 | Per-group scripts (parallel) | `install-shell-tools.sh`, `install-python.sh`, `install-r.sh`, `install-typesetting.sh`, `install-mcp-servers.sh` | 1 |
   | 4 | Master wizard | `install.sh` with topological dispatch, presets, prompt loop, summary | 2, 3 |
   | 5 | Doc updates | "Quick install (script)" sections in every `docs/toolchain/*.md` (except README + extensions); "Installation wizard (recommended)" lead in `docs/general/installation.md`; preserve manual content verbatim | 4 |
   | 6 | Repo-root README Quick Start | 3-line clone+cd+run block in `README.md`, link to wizard | 5 |
   | 7 | Verification | `--dry-run` smoke test, manual Verify checklist, optional Brewfile side artifacts (deferrable) | 6 |

7. **Cross-task note**: in the plan's "Roadmap Alignment" section, flag (a) the `/doctor` co-design opportunity, (b) the task 29 live-demo unlock. Do NOT make either a hard dependency.

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Length |
|---|---|---|---|---|
| A | Primary Approach | completed | HIGH (layout, lib design, doc integration); MEDIUM (sub-prompts, Xcode dialog) | 619 lines |
| B | Alternatives & Prior Art | completed | HIGH (Brewfile rejection, prior-art reuse) | 547 lines |
| C | Critic | completed | HIGH (Lean resurrection, chicken-and-egg, granularity, ordering) | 273 lines |
| D | Horizons / Strategic | completed | HIGH (framing, /doctor co-design); MEDIUM (Brewfile-first reframe, talk live-demo claim) | 400 lines |

## References

- `specs/031_toolchain_installation_scripts/reports/01_teammate-a-findings.md`
- `specs/031_toolchain_installation_scripts/reports/01_teammate-b-findings.md`
- `specs/031_toolchain_installation_scripts/reports/01_teammate-c-findings.md`
- `specs/031_toolchain_installation_scripts/reports/01_teammate-d-findings.md`
- `specs/030_audit_missing_dependencies_docs/plans/01_toolchain-docs.md`
- `specs/030_audit_missing_dependencies_docs/summaries/01_toolchain-docs-summary.md`
- `docs/general/installation.md`
- `docs/toolchain/README.md`, `r.md`, `python.md`, `typesetting.md`, `mcp-servers.md`, `shell-tools.md`, `extensions.md`
- `~/.config/nvim/scripts/check-dependencies.sh`, `setup-with-claude.sh`
- `~/.dotfiles/.claude/scripts/install-extension.sh`

## Synthesis Stats

- Conflicts found: 5 (naming, presets, /doctor co-design, Brewfile primacy, manifest)
- Conflicts resolved: 5
- Critic questions: 20 (8 Tier 1, 9 Tier 2, 3 Tier 3)
- Gaps remaining post-synthesis: 3 (test plan, README.md, talk integration — all addressed in recommendations)
- Wave 2 triggered: no
