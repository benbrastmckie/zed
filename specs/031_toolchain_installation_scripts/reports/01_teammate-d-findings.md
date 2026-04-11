# Teammate D Findings: Horizons / Strategic Direction

- **Task**: 31 — toolchain_installation_scripts
- **Angle**: Horizons (long-term alignment, strategic framing, unconventional alternatives)
- **Date**: 2026-04-10
- **Sources/Inputs**:
  - `specs/030_audit_missing_dependencies_docs/summaries/01_toolchain-docs-summary.md`
  - `specs/030_audit_missing_dependencies_docs/plans/01_toolchain-docs.md`
  - `specs/029_talk_epi_study_walkthrough/reports/02_talk-research.md`
  - `specs/TODO.md` (task 31 description)
  - `docs/general/installation.md`
  - `docs/toolchain/README.md` and file index
  - Recent task trajectory (20, 21, 27, 28, 29, 30)
  - `~/.claude/projects/.../memory/MEMORY.md` (Zed shared with collaborator)
- **Artifacts**: this report
- **Standards**: report-format.md

---

## Key Findings

### 1. Task 31 sits at the center of a three-task "onboarding triangle"

The recent trajectory is clearer than it looks. Read in order, the last six
tasks tell a single story:

| Task | Layer | Role in the story |
|------|-------|-------------------|
| 20 | epi demo built | "Here's a reproducible synthetic RCT." |
| 21 | macOS-Zed reframing | "For macOS users editing in Zed." |
| 27 | dotfiles env gaps fixed | "…assuming the author's toolchain is present." |
| 28 | rerun with full R stack | "Proved reproducibility across an environment upgrade." |
| 29 | conference talk | "Here is that reproducibility story, on stage." |
| 30 | toolchain docs audit | "Here is every dependency you need, documented." |
| **31** | **install scripts + wizard** | **"Here is the button that installs them for you."** |

Task 31 is not a cosmetic automation layer over task 30. It is the **missing
executable half** of the reproducibility thesis that tasks 20/27/28/29
have been building. Until task 31 lands, the repo's answer to "how does a
new user reproduce this?" is "read seven docs and copy-paste about 40 commands
correctly, in order, on macOS 11+". After task 31 lands, the answer becomes
"clone, run one script, answer a few prompts".

That is a qualitatively different repository. Frame the task accordingly.

### 2. The task 30 plan explicitly pre-wired the follow-ons that task 31 should coordinate with

Reading `specs/030_.../summaries/01_toolchain-docs-summary.md` "Follow-ups"
section, task 30 left behind three explicit successors:

1. A `/doctor` runtime-check command that parses `docs/toolchain/` and runs
   `command -v` for each binary (recommended by all four teammates in task 30).
2. A stale `.claude/docs/guides/user-installation.md` rewrite/delete.
3. A cross-repo `manifest.json` schema extension for `external_prerequisites`.

Task 31 is the natural peer of #1 — **install scripts remediate, `/doctor`
diagnoses**. They form a matched pair. Every design choice in task 31 should
be scored against whether it makes `/doctor` easier or harder to write later.
Concretely:

- If install scripts write a small ledger of "what was actually installed and
  when" (e.g. `~/.config/zed/.install-state/{group}.json`), `/doctor` gets
  a cheap, accurate "last-known-good" baseline instead of having to re-derive
  state from `brew list`, `R -e 'installed.packages()'`, `pip list`, etc.
- If the per-group install scripts emit a common JSON status line on exit
  (`{"group": "r", "status": "ok", "installed": [...], "skipped": [...]}`),
  the master wizard's prompt loop AND a future `/doctor` both consume the
  same structure. Two commands, one contract.
- If each install script has a `--check` flag that runs only the Check
  sections from the corresponding `docs/toolchain/*.md` file, `/doctor`'s
  MVP becomes `for s in scripts/install-*.sh; do $s --check; done`.

Recommendation: **treat `/doctor` as a co-design constraint for task 31**,
even though it is a separate task. One hour of interface design during task 31
saves days of refactor later.

### 3. Task 31 unblocks task 29's talk in a way that was previously not on the table

Task 29's research report (`02_talk-research.md`) describes an 18-minute
conference talk centered on byte-identical reproduction across environment
upgrades. The current talk structure cannot include a live demo, because a
live demo on a fresh laptop would take 20+ minutes of `brew install` commands
before the first R line runs. With task 31 finished, a live demo collapses
to `./install.sh --preset=epi-demo` followed by `quarto render`, which is
well under the talk's time budget.

That changes the talk from "a slide deck about a study" to "a slide deck
**plus a working demo** of a study". For a conference audience skeptical of
reproducibility claims, the demo is the strongest rhetorical move available.
Task 31 is therefore not just infrastructure — it is a talk deliverable.

If task 29 has not yet been implemented, flag this in the task 31 plan so
that task 29 can opt in to using the wizard in its live-demo slot.

### 4. The `zed/` repo is shared with a collaborator, which changes the design criteria

User memory (`feedback_no_vim_mode_zed.md`) records that this Zed config is
shared with a collaborator, unlike the `nvim/` config which is author-only.
This is the first `.config/zed/` task where that fact materially affects the
deliverable:

- The install scripts will be run by someone who is **not the author** and
  who did not write any of the docs. They need to be forgiving.
- The prompts in the master wizard need to assume a **reader who has never
  heard of MCP servers, renv, or Quarto** — and who also does not necessarily
  want every extension's toolchain (a collaborator may never touch LaTeX or
  Typst, but will almost certainly want R).
- **Presets matter more than defaults**. A single `install.sh` that installs
  everything is unfriendly to a collaborator who only wants epi R; a
  per-group prompt loop is better but still tedious for the author who
  wants "everything, no questions". Supporting both via `--preset=epi-demo`,
  `--preset=everything`, `--preset=minimal`, plus an interactive default,
  is cheap and directly serves the two-user reality.

Suggested presets:

| Preset | Includes | Use case |
|--------|----------|----------|
| `minimal` | Base install.md only (Zed, claude-code, node, 2 MCPs) | First-time setup, will add later |
| `epi-demo` | Base + r.md + Quarto + shell-tools.md | Collaborator reproducing the study |
| `writing` | Base + typesetting.md + shell-tools.md | LaTeX/Typst users only |
| `everything` | Base + all toolchain/*.md | Author on a fresh machine |
| (interactive) | Base + user prompted per group | Default when no flag given |

### 5. This wizard is a replicable pattern for the user's other repos

The user's memory system flags that `nvim/` is shared with a collaborator
via `~/.dotfiles` and that `zed/` has similar aspirations. Whatever
install-script convention task 31 establishes will likely be copy-pasted
into `nvim/` next, and possibly into `~/.dotfiles` itself. That means:

- The scripts should be **self-contained per group**, not hard-coded to
  `zed/` paths, so `install-r.sh` can be lifted into `nvim/` unchanged.
- The master wizard should **read a manifest file** (e.g.
  `scripts/install/groups.toml`) listing group name, script path, doc path,
  and description. Porting to another repo then becomes "copy the scripts
  dir, edit the manifest".
- The script naming convention should match a pattern (`install-<group>.sh`)
  so a future meta task can auto-scan and generate the wizard from the
  `docs/toolchain/` directory listing.

This is low-cost to do now and high-cost to retrofit later.

### 6. The "README onboarding" question is bigger than the task description admits

The task description says to update `docs/general/installation.md` to lead
with the wizard. That is the right local change, but it is not the most
visible one. A new user who clones this repo hits `README.md` at the repo
root first, and `README.md` currently links out to the docs tree. Leading
with the wizard in `installation.md` without updating `README.md` means the
wizard is still three clicks deep from the repo root.

Strong recommendation: **add a "Quick start" section to the repo root
`README.md`** that is literally three lines:

```
git clone https://github.com/<user>/config-zed ~/.config/zed
cd ~/.config/zed
./install.sh
```

The wizard's value to a new user is a function of how quickly they find it.
One paragraph in `README.md` dominates the entire rest of the task.

---

## Recommended Framing

**Pitch task 31 as the onboarding entry point for the reproducibility story,
not as a documentation polish task.**

Specifically, frame the plan around this hierarchy:

1. **The master wizard is an onboarding command.** Its success metric is
   "time from `git clone` to `quarto render examples/epi-study/` producing
   the same OR = 3.28721 headline that task 28 locked in." Target: under
   30 minutes on a clean macOS 11+ machine, unattended after prompts.
2. **Per-group scripts are reusable building blocks.** Their success metric
   is "can be lifted into `nvim/` or `~/.dotfiles` without edits", and
   "can be driven by a future `/doctor` command via a `--check` flag".
3. **Doc reshuffling is a consequence of (1) and (2)**, not the point of
   the task. The toolchain files get a "Run this script" preamble because
   the scripts exist, not the other way around.

Concrete plan phases this framing implies:

| Phase | Name | Deliverable |
|-------|------|-------------|
| 1 | Design the contract | groups.toml, script interface (`--check`, `--install`, `--json`), exit codes, state ledger format |
| 2 | Base installer | `install-base.sh` covering everything in `docs/general/installation.md` |
| 3 | Per-group scripts | One script per `docs/toolchain/*.md` file (r, python, typesetting, mcp-servers, shell-tools; extensions.md is a router so no script) |
| 4 | Master wizard | `install.sh` with presets, interactive prompts, calls base then iterates groups |
| 5 | Docs update | `installation.md` and each toolchain file get "Run the script" preamble |
| 6 | Repo entry point | `README.md` Quick start section linking to the wizard |
| 7 | Verification | Run on a clean VM or `brew bundle dump --force` diff to confirm coverage |

Task 30 used `extensions.md` as a router doc rather than an install doc;
task 31 should mirror that by **not** producing an `install-extensions.sh`.
That keeps the "one script per file" rule intact without forcing a redundant
script.

---

## Creative Alternatives

### Alternative A: A Brewfile-first wizard with bash as the prompt layer

The base install and most toolchain groups are "a list of Homebrew formulae
and casks". `brew bundle` already exists, takes a `Brewfile`, supports
`brew bundle check` (the Check phase!), and handles `--force` / `--no-upgrade`
flags. Replace most per-group bash scripts with per-group `Brewfile-<group>`
files, and let the wizard be 50 lines of bash that prompts and calls
`brew bundle --file=Brewfile-<group>`. R and Python package installs stay
in bash scripts because `brew bundle` can't express them, but everything else
collapses.

**Trade-offs**:
- Pro: Much less code; `brew bundle check` gives `/doctor` for free;
  `brew bundle dump` gives the author a one-command "what did I install on
  this machine" dump for future edits; Brewfiles are a well-understood idiom.
- Pro: Idempotent by construction.
- Con: Splits the "one script per doc" invariant in a slightly weird way
  (mix of .sh and Brewfile). Worth it.
- Con: R `install.packages()` and Python `uv tool install` still need
  bash wrappers.

**Verdict**: Strong candidate. Probably the best pure-engineering choice.
Pitch it in the plan as the default unless the user pushes back.

### Alternative B: A Claude Code slash command `/install` instead of bash

Every user of this repo is, by definition, a Claude Code user. The wizard
could be a slash command that Claude drives via Bash tool calls, prompts
the user through the Agent Panel, explains errors in natural language,
reads `docs/toolchain/*.md` as source of truth, and skips whatever the user
already has.

**Trade-offs**:
- Pro: Lives in the same interaction surface as everything else in this
  repo. Explanations are higher-quality than any comments the wizard can
  embed. Handles errors gracefully (e.g. "brew: command not found" becomes
  a paragraph explaining Xcode CLT + Homebrew bootstrapping).
- Pro: Self-updating: when a new toolchain file is added, the command picks
  it up automatically without editing the wizard.
- Con: **Chicken-and-egg problem.** The user needs Claude Code installed
  before they can run `/install`, which defeats the "clone and run"
  onboarding story. A Claude Code user who does not yet have a functioning
  Claude Code install cannot bootstrap with this.
- Con: Doesn't run on CI, VMs, or collaborator machines that aren't Claude-
  enabled.

**Verdict**: Not as the primary wizard, but **useful as a secondary
command for environment drift**. Worth proposing as a stretch goal: the bash
wizard handles first-run, `/install --update` (a slash command) handles
"my environment has drifted since last month, fix it". That matches the
diagnose/remediate pairing from finding #2.

### Alternative C: Justfile recipes

`just install`, `just install r`, `just install typesetting`. A Justfile
recipe is a named bash block with built-in dependency tracking and `just -l`
as documentation.

**Trade-offs**:
- Pro: Discoverable (`just -l`), composable, shorter than bash.
- Con: Requires `just` installed, which is itself a new dependency.
  Bootstrapping `just` via a bash script to then run Justfile recipes is
  absurd.
- Con: Doesn't match the "one script per toolchain file" framing.

**Verdict**: **Skip.** The bootstrapping issue is decisive.

### Alternative D: A static HTML form → clipboard

A single-page HTML file (`install.html`) with checkboxes for each group,
generating a `brew bundle` command on the fly. User opens it in a browser,
clicks what they want, copies the command, pastes.

**Trade-offs**:
- Pro: Zero dependencies, works offline, visually explains what each group
  contains (same explanatory purpose the wizard prompts serve).
- Pro: Makes a great **talk slide** for task 29 ("Here's the wizard, running
  in a browser, no install required").
- Con: Requires two-step copy-paste, which is worse UX than `./install.sh`.
- Con: Doesn't handle the non-`brew bundle` items (R packages, uv tools).

**Verdict**: **Skip as primary wizard, consider as companion.** A static
HTML "what would this install?" preview page is a cheap addition and
rhetorically powerful; it is not a replacement.

### Alternative E: Do nothing — just add a copy-pasteable appendix

The existing `docs/general/installation.md` already has a "comfortable with
the terminal" fast-path block (lines 5-14) with all base commands. The task
could be reduced to: expand that block into one giant copy-pasteable script
in each file, plus a `docs/general/quick-install.md` with every command in
order. No new scripts, no prompts.

**Trade-offs**:
- Pro: Trivial; satisfies the "wizard" framing weakly.
- Con: Not idempotent. A user who has R already would re-install it.
  Defeats the Check/Install/Verify structure task 30 built.
- Con: Zero preset support, zero `/doctor` integration path.

**Verdict**: **Skip.** Underpowered for what the trajectory calls for.

### Recommendation ranking

1. **Alternative A (Brewfile-first wizard)** — primary recommendation, best
   engineering fit.
2. **Straight bash scripts** (the task description's implicit framing) —
   acceptable fallback if Brewfile idiom feels too prescriptive.
3. **Alternative B (/install slash command)** as a stretch/secondary command
   for drift correction.
4. **Alternative D (static HTML)** only as a task-29 talk aid.

The user's task description leans toward straight bash, so unless the plan
explicitly re-pitches Alternative A, the implementation will probably be
straight bash. That is still fine — the important thing is that the
**contract** (exit codes, `--check`, state ledger, groups.toml) is
designed well, regardless of whether Brewfile or bash is the backing
implementation.

---

## Follow-on Roadmap

Task 31 directly unlocks or enables:

| Follow-on | Relationship | Recommended priority |
|-----------|--------------|---------------------|
| `/doctor` meta task | Consumes the `--check` interface and state ledger that task 31 exposes | High — do this next |
| Task 29 talk live demo | Wizard makes live-demo feasible in 18-minute budget | Depends on task 29's status |
| Repo root `README.md` Quick start | Should be part of task 31, but if scope creep concerns, spin out | Inside task 31 ideally |
| `nvim/` repo install scripts | Port the pattern to the shared Neovim config | Low — author initiates when ready |
| `manifest.json` `external_prerequisites` schema | Cross-repo; if schema lands, scripts can be generated from manifests | Low — probably never, unless task 31 + /doctor expose a clear duplication pain |
| macOS "pre-prerequisites" guide | Xcode CLT + Homebrew bootstrap; the wizard's first screen already covers this in prose, but a standalone guide is useful | Optional — low cost |
| `brew bundle dump` diff tooling | "What did I add since last install?" for the author; cheap spinoff of Alternative A | Optional |
| Collaborator-facing `CONTRIBUTING.md` | With the wizard existing, it's finally possible to onboard a collaborator in a documented way | Medium — once wizard is stable |

The cleanest sequencing is:

```
31 (this task)
  -> 32 (/doctor, runtime health check reading groups.toml + --check)
    -> 33 (optional: /install slash command for drift correction)
    -> 34 (optional: port pattern to nvim/)
```

If task 29 is still [RESEARCHED] or [PLANNED] when task 31 starts, add a
note to the task 29 plan that the live-demo slot should assume the wizard
exists.

---

## Confidence Level

**High** for the strategic framing (findings 1-3 and 6).
**High** for the `/doctor` co-design recommendation (finding 2) — this is
the single most leveraged design choice in the task.
**Medium-high** for the preset list (finding 4) — the exact presets may
need adjustment but the presence of presets is correct.
**Medium** for Alternative A (Brewfile-first) as a primary recommendation —
the user's task description implies straight bash, and I am proposing a
reframing. Worth raising; not worth dying on.
**Medium** for the task 29 live-demo claim (finding 3) — depends on what
task 29 implementation chooses to do.
**Low-confidence caveats**:
- I did not verify that `brew bundle check` behavior matches my
  description. If the plan adopts Alternative A, the Phase 1 contract
  design should include a quick `brew bundle check --help` spike.
- I did not verify whether the collaborator on `zed/` is a programmer. The
  beginner-friendliness of the prompts should be tuned once the planner
  knows that.

---

## Appendix

### Relevant files consulted

- `specs/030_audit_missing_dependencies_docs/summaries/01_toolchain-docs-summary.md` — task 30 follow-ups, Lean prune decision, scope of each toolchain file
- `specs/029_talk_epi_study_walkthrough/reports/02_talk-research.md` — task 29 talk structure and reproducibility headline
- `docs/general/installation.md` — existing base install guide, fast-path block (lines 5-14)
- `docs/toolchain/README.md` — directory index, Check/Install/Verify template, `/doctor` hint in "Follow-on work" section
- `specs/TODO.md` entry for task 31
- Task trajectory: commits `aa7134d`, `910423f`, `b172244`, `0750680`, `d9e1f20` (recent session)

### Not consulted (intentional)

- Individual `docs/toolchain/r.md`, `python.md`, `typesetting.md`, etc. — Teammates A/B/C are covering implementation-close angles. Horizons work does not need the per-file details.
- Web documentation for `brew bundle` — flagged as a verification task for Phase 1 of the plan.

### Strategic summary (one sentence)

Task 31 is the executable half of the reproducibility thesis that tasks 20,
27, 28, and 29 have been telling; it should be designed as the first half
of a diagnose/remediate pair with a future `/doctor` command, pitched
through a repo-root Quick Start, and structured so that per-group scripts
are portable to the user's other repos.
