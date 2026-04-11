# Research Report: Epi Study Example Demo

- **Task**: 22 - epi_study_example_demo
- **Status**: [RESEARCHED]
- **Date**: 2026-04-10
- **Type**: research
- **Research-Type**: general (codebase design / documentation)
- **Artifacts**:
  - specs/022_epi_study_example_demo/reports/01_epi-study-example-demo.md
- **Standards**:
  - .claude/context/formats/report-format.md
  - .claude/rules/artifact-formats.md
- **Sources/Inputs**:
  - specs/020_test_epi_rct_ketamine_meth/ (all subdirectories)
  - .claude/commands/epi.md
  - .claude/CLAUDE.md (Epidemiology Extension section)
  - zed/ top-level layout (no pre-existing `examples/` directory)

## Executive Summary

- Task 20 produced a complete, self-contained synthetic ketamine-assisted
  therapy (KAT) vs therapy-as-usual (TAU) RCT pipeline (N=200) that is
  ideal demo material: 7 Python/R scripts, 3 raw CSVs + 1 derived
  analytic CSV, a CONSORT markdown report, a Quarto source, and a
  configuration-gap log.
- No `zed/examples/` directory currently exists in the repository, so
  task 22 establishes the convention. Recommendation: create
  `zed/examples/epi-study/` as a **flat mirror of the task 20 working
  tree** (scripts/, data/, reports/, logs/) rather than symlinks, so the
  example remains stable even if task 20 is archived/vaulted.
- The `/epi` command has a 10-question Stage 0 forcing flow (study
  design, research question, causal structure, data paths, descriptive
  paths, prior work, ethics, reporting guideline, R preferences,
  analysis hints) followed by task creation and a `/research -> /plan ->
  /implement` hand-off. The README walkthrough should mirror that exact
  sequence so newcomers can reproduce the demo step by step.
- The demo should ship with a top-level `README.md` containing: overview,
  prerequisites (R 4.5+, Python 3.12+, minimal numpy/pandas -- with the
  HIGH-priority gaps from `logs/config_gaps.md` surfaced as "known
  limitations"), an annotated `/epi` walkthrough using the exact answers
  used for task 20, a "how to reproduce" section using the bare scripts,
  expected outputs, and links back to the task 20 provenance artifacts
  (research report, plan, summary).
- Most artifacts should be **copied verbatim**. Only the CONSORT report
  and the README itself should be rewritten/polished for newcomer
  friendliness. The `config_gaps.md` should be copied but gently
  repositioned as a "known environment gaps" note rather than a primary
  deliverable.

## Research Questions

The focus prompt posed seven questions. Each is answered in Findings below.

1. Exact user-facing flow of `/epi` (Stage 0 forcing questions, routing)?
2. Which task 20 artifacts are demo-suitable vs need rewriting?
3. Ideal `zed/examples/epi-study/` layout (flat vs mirrored, symlink vs copy)?
4. What should top-level `README.md` contain?
5. How to reference task 20 provenance?
6. Prerequisites / setup notes?
7. Existing example directories to model after?

## Context & Scope

The user wants a **demo directory** in `zed/examples/epi-study/` that
organizes the synthetic RCT produced by task 20 and documents how to
reproduce it via `/epi`. Primary audience: new Zed-on-NixOS users
encountering the epidemiology extension for the first time. Success
criterion: a newcomer can read the README, answer the `/epi` questions,
and arrive at the same analytic dataset and CONSORT report.

Out of scope: fixing the environment gaps themselves (tracked in
`logs/config_gaps.md`), rerunning the analysis with the full R/tidyverse
stack, adding new statistical methods.

## Findings

### 1. `/epi` Command Flow (from `.claude/commands/epi.md`)

`/epi` is a thin scoping wrapper. It has three input modes:

| Input | Behavior |
|---|---|
| Description string | Run Stage 0 forcing questions, create task, stop at `[NOT STARTED]` |
| Task number | Load existing task, delegate to research |
| File path (`.md`, `.pdf`, etc.) | Read as protocol, run Stage 0, create task |

**Stage 0 -- 10 forcing questions** (each via `AskUserQuestion`):

| # | Field | Required | Options / Format |
|---|---|---|---|
| 0.1 | `study_design` | yes | COHORT, CASE_CONTROL, CROSS_SECTIONAL, RCT, META_ANALYSIS, QUASI_EXPERIMENTAL, SURVEILLANCE, MODELING |
| 0.2 | `research_question` | yes | Free text, PICO/PECO encouraged |
| 0.3 | `causal_structure` | no | DAG notation (`A->Y, C->A`) or `skip` |
| 0.4 | `data_paths` | no | Comma-separated paths, or `none` |
| 0.5 | `descriptive_paths` | no | Comma-separated (codebooks, protocols), or `none` |
| 0.6 | `prior_work` | no | `task:N`, file paths, citations, or `none` |
| 0.7 | `ethics_status` | yes | IRB_APPROVED, EXEMPT, PENDING, NOT_APPLICABLE |
| 0.8 | `reporting_guideline` | yes | STROBE, CONSORT, PRISMA, RECORD, TRIPOD, OTHER, AUTO_DETECT |
| 0.9 | `r_preferences` | no | Package/framework hints, or `skip` |
| 0.10 | `analysis_hints` | no | Models, sensitivity plans, subgroups, or `skip` |

**Auto-detection for reporting_guideline** when `AUTO_DETECT`:
- RCT -> CONSORT
- COHORT/CASE_CONTROL/CROSS_SECTIONAL -> STROBE
- META_ANALYSIS -> PRISMA
- SURVEILLANCE -> RECORD
- MODELING/QUASI_EXPERIMENTAL -> STROBE

**Post-Stage 0**: command updates `specs/state.json` (task_type
`epi:study`), prepends entry to `specs/TODO.md`, and git-commits with
message `task {N}: create {title}`. Task stops at `[NOT STARTED]`. User
then runs `/research {N}`, `/plan {N}`, `/implement {N}`.

**Routing** (from `.claude/CLAUDE.md`): `epi` and `epi:study` route
through `skill-epi-research` -> `epi-research-agent` -> `skill-planner`
-> `skill-epi-implement` -> `epi-implement-agent`.

### 2. Task 20 Artifact Inventory

Complete tree under `specs/020_test_epi_rct_ketamine_meth/`:

```
020_test_epi_rct_ketamine_meth/
├── data/
│   ├── raw/
│   │   ├── participants.csv   (201 lines, 200 subjects + header)
│   │   ├── outcomes.csv       (201 lines)
│   │   └── adverse_events.csv (51 lines)
│   └── derived/
│       ├── analytic.csv       (201 lines; merged dataset)
│       └── models/            (*.rds binary fit objects)
├── logs/
│   ├── 00_env_check.txt       (3.1 KB, R + Python env snapshot)
│   └── config_gaps.md         (6.9 KB, prioritized remediation)
├── output/                    (empty)
├── plans/
│   └── 01_epi-rct-test-study.md (14 KB, full phased plan)
├── reports/
│   ├── 01_epi-research.md     (18.6 KB, research report)
│   ├── 05_consort_report.md   (4.5 KB, final CONSORT report)
│   ├── 05_consort_report.qmd  (3.1 KB, Quarto source, not rendered)
│   ├── 06_zed_verification_summary.md (3.4 KB)
│   └── tables/
│       ├── primary_results.txt
│       └── sensitivity_results.txt
├── scripts/
│   ├── 00_check_env.py        (env check)
│   ├── 00_check_env.R
│   ├── 01_generate_data.py    (200 participants, stratified 1:1)
│   ├── 02_generate_outcomes.R (abstinence, time-to-use, ASI, 15% MCAR)
│   ├── 03_merge_data.py       (derive analytic.csv)
│   ├── 04_primary_analysis.R  (logistic + Cox fallback + linear)
│   └── 05_sensitivity.R       (CC, PP, interaction, tipping-point)
└── summaries/
    └── 01_epi-rct-test-study-summary.md (7 KB)
```

**Key results** (from summary): OR for KAT vs TAU = 3.29 (95% CI
1.57-6.89, p=0.002); 42.4% KAT vs 22.4% TAU abstinence at 12 weeks;
primary result robust under PP (OR 2.52) and single-imputation (OR
3.13); worst-case tipping-point collapses to OR 1.29 (ns).

**Environment reality** (from config_gaps): R 4.5.3 + Python 3.12.13 are
available but R is a bare install (no survival, tidyverse, gtsummary,
mice, languageserver); Python lacks scipy/statsmodels; Quarto is
missing. The scripts were written to degrade gracefully -- they use
base R log-rank + exponential GLM as a Cox surrogate, and pandas+numpy
only.

### 3. Copy / Reference / Rewrite Classification

| Source artifact | Demo disposition | Rationale |
|---|---|---|
| `scripts/00_check_env.py` | **Copy verbatim** | Self-contained env check |
| `scripts/00_check_env.R` | **Copy verbatim** | Self-contained env check |
| `scripts/01_generate_data.py` | **Copy verbatim** | Clean, runnable, reproducible (should inspect/confirm RNG seed) |
| `scripts/02_generate_outcomes.R` | **Copy verbatim** | Clean, runnable |
| `scripts/03_merge_data.py` | **Copy verbatim** | Clean |
| `scripts/04_primary_analysis.R` | **Copy verbatim** | Works on bare R; Cox-fallback already commented |
| `scripts/05_sensitivity.R` | **Copy verbatim** | Works on bare R |
| `data/raw/*.csv` | **Copy verbatim** | Synthetic, tiny, deterministic with seed |
| `data/derived/analytic.csv` | **Copy verbatim** | Lets readers inspect expected output without running pipeline |
| `data/derived/models/*.rds` | **Omit** | Binary artifacts; can be regenerated by scripts |
| `logs/00_env_check.txt` | **Copy verbatim** (as `logs/env_check.txt`) | Useful reference baseline |
| `logs/config_gaps.md` | **Copy with light edit** | Rename top header to "Known Environment Gaps"; add pointer from README as "why does the pipeline use base R instead of tidyverse?" |
| `reports/05_consort_report.md` | **Copy** (optionally rename to `reports/consort_report.md`) | Final deliverable newcomers should see |
| `reports/05_consort_report.qmd` | **Copy** | Illustrates Quarto source even if unrendered |
| `reports/06_zed_verification_summary.md` | **Copy** | Useful for newcomers seeing what Zed-on-NixOS gaps look like |
| `reports/tables/*.txt` | **Copy** | Machine-readable result fixtures |
| `reports/01_epi-research.md` | **Reference only** (link in README "Provenance") | Long internal research artifact, not needed to understand demo |
| `plans/01_epi-rct-test-study.md` | **Reference only** (link in README) | Large; shows the full `/plan` artifact for the curious |
| `summaries/01_epi-rct-test-study-summary.md` | **Reference only** (link in README) | Serves as the "what actually happened" retrospective |
| (new) `README.md` | **Rewrite fresh** | Polished newcomer walkthrough |
| (new) `EPI_ANSWERS.md` | **Rewrite fresh** | Literal transcript of Stage 0 answers for reproduction |

**Copy vs symlink vs fresh-rewrite decision**: copies. Symlinks would
break when task 20 is archived by `/todo` or vaulted (see `.claude/CLAUDE.md`
"Vault Operation"), and fresh rewrites would lose the authenticity of
"this is exactly what the agent produced". Copies are frozen snapshots
with a clear provenance pointer.

### 4. Recommended `zed/examples/epi-study/` Layout

No pre-existing `zed/examples/` directory. Task 22 establishes the
convention. Recommend a **flat mirror** of the task-20 working tree
plus a top-level README and a stage-0 transcript:

```
zed/examples/epi-study/
├── README.md                      # (new) main walkthrough
├── EPI_ANSWERS.md                 # (new) Stage 0 transcript
├── scripts/
│   ├── 00_check_env.py
│   ├── 00_check_env.R
│   ├── 01_generate_data.py
│   ├── 02_generate_outcomes.R
│   ├── 03_merge_data.py
│   ├── 04_primary_analysis.R
│   └── 05_sensitivity.R
├── data/
│   ├── raw/
│   │   ├── participants.csv
│   │   ├── outcomes.csv
│   │   └── adverse_events.csv
│   └── derived/
│       └── analytic.csv
├── reports/
│   ├── consort_report.md
│   ├── consort_report.qmd
│   ├── zed_verification_summary.md
│   └── tables/
│       ├── primary_results.txt
│       └── sensitivity_results.txt
└── logs/
    ├── env_check.txt
    └── config_gaps.md
```

**Alternative considered**: "mirrored spec structure" with
`plans/`, `summaries/`, `.return-meta.json` carried over. Rejected --
those are task-system artifacts, not demo artifacts; linking to them
via README "Provenance" keeps the demo focused on the study itself.

**Alternative considered**: Putting the demo under
`.claude/extensions/epidemiology/examples/epi-study/` next to the
extension it documents. **Worth discussing with the user in planning**
-- see Open Questions. Advantage: colocated with the extension.
Disadvantage: `zed/examples/` is more discoverable for a newcomer just
browsing the repo.

### 5. README.md Outline (section-by-section sketch)

```markdown
# Epi Study Example: Ketamine-Assisted Therapy RCT

> A worked example of the Zed epidemiology extension (`/epi` command)
> end-to-end: problem -> study design -> R/Python pipeline -> CONSORT
> report. All data synthetic, no real participants.

## What This Demo Shows
- The full `/epi` -> `/research` -> `/plan` -> `/implement` workflow
- A small but complete RCT analysis pipeline that runs on bare R +
  numpy/pandas (no tidyverse required)
- Cross-language handoff (Python generates baseline -> R simulates
  outcomes -> Python merges -> R analyses)
- CONSORT reporting + sensitivity analyses
- What "graceful degradation" looks like when R/Python packages are missing

## Prerequisites
- **R**: 4.0+ (base only; no tidyverse, no survival required)
- **Python**: 3.10+ with `numpy` and `pandas`
- **Zed**: with the epidemiology extension loaded (`<leader>ac` -> epi)
- **Optional (for full fidelity)**: `survival`, `tidyverse`, `gtsummary`,
  `mice`, `quarto`. See `logs/config_gaps.md` for install instructions.
  The demo runs without them -- results just use base-R fallbacks.

## Step 1: Create the Task with `/epi`
In Zed, run:
    /epi "Synthetic ketamine-assisted therapy RCT for meth use disorder"

You will be asked 10 forcing questions. The exact answers used to
produce this demo are in `EPI_ANSWERS.md`. Key ones:
- Study design: RCT
- Reporting guideline: CONSORT
- Ethics: NOT_APPLICABLE (synthetic data)
- Data paths: (leave empty; the scripts generate data)

`/epi` creates task `{N}` in `specs/{NNN}_{slug}/`, stops at [NOT STARTED].

## Step 2: Research
    /research {N}
The epi-research-agent drafts a study design report under
`specs/{NNN}_{slug}/reports/01_epi-research.md`. For reference, the
task-20 version of this report is linked under "Provenance" below.

## Step 3: Plan
    /plan {N}
Produces `specs/{NNN}_{slug}/plans/01_*.md` with phased steps.

## Step 4: Implement
    /implement {N}
Executes the scripts in order. For the demo, you can also run them
directly from `scripts/`:
    python scripts/00_check_env.py
    Rscript scripts/00_check_env.R
    python scripts/01_generate_data.py
    Rscript scripts/02_generate_outcomes.R
    python scripts/03_merge_data.py
    Rscript scripts/04_primary_analysis.R
    Rscript scripts/05_sensitivity.R

## Expected Outputs
- `data/raw/{participants,outcomes,adverse_events}.csv`
- `data/derived/analytic.csv` (201 rows including header)
- `reports/tables/primary_results.txt` (OR ~3.29 for KAT vs TAU)
- `reports/tables/sensitivity_results.txt`
- `reports/consort_report.md`

## Known Environment Gaps
See `logs/config_gaps.md`. In short: the scripts fall back to base R
log-rank + exponential GLM when `survival` is unavailable, to
mean/mode single-imputation when `mice` is unavailable, and to a plain
Markdown report when `quarto` is unavailable.

## Provenance
This demo is a polished copy of task 20 (`test_epi_rct_ketamine_meth`).
Full task artifacts:
- Research report: `specs/020_test_epi_rct_ketamine_meth/reports/01_epi-research.md`
- Implementation plan: `specs/020_test_epi_rct_ketamine_meth/plans/01_epi-rct-test-study.md`
- Summary: `specs/020_test_epi_rct_ketamine_meth/summaries/01_epi-rct-test-study-summary.md`

## Extension Points
- Swap in `mice` multiple imputation in `05_sensitivity.R`
- Add a `flake.nix` for per-project R + Python pinning
- Re-render the `.qmd` via Quarto once installed
- Add a per-protocol analysis on a subgroup of interest
```

### 6. Prerequisites / Setup Notes for Newcomers

Minimum working set to run the demo end-to-end:

- **R 4.0+** -- base only. `scripts/` uses only `stats`, `utils`, and a
  hand-rolled log-rank. Verified on R 4.5.3 (NixOS task 20 host).
- **Python 3.10+** with `numpy` and `pandas`. Verified on Python
  3.12.13.
- **No Quarto needed** for the demo -- the rendered report is checked
  in as `reports/consort_report.md`. `.qmd` source is provided for
  users who have Quarto.
- **HIGH-priority gaps to surface in README**: missing `survival`,
  `tidyverse`, `languageserver`, `scipy`, `statsmodels`. These are
  documented in `logs/config_gaps.md` with NixOS/nix-profile install
  snippets.
- **Zed editor config**: R LSP (`languageserver`) install + a
  `settings.json` stanza are provided in the copied
  `config_gaps.md`. README should link to it.

### 7. Existing Examples / Conventions

Searched for `**/examples/**` under `zed/`. Only hits are inside
`.claude/docs/examples/` (`fix-it-flow-example.md`,
`research-flow-example.md`) -- these are workflow walkthroughs, not
executable code demos. **No prior `zed/examples/` convention exists**,
so task 22 is establishing it.

Modeling suggestions:
- Use the README voice/structure of the `.claude/docs/examples/`
  walkthroughs (numbered steps, code blocks, expected outputs).
- Keep the top of the README short and action-oriented ("run this ->
  see this"); defer background to later sections.

## Recommendations

1. **Create `zed/examples/epi-study/`** with a flat layout mirroring
   the task 20 working tree (scripts/, data/, reports/, logs/).
2. **Copy** all scripts, raw + derived CSVs, CONSORT markdown + qmd,
   tables, env_check.txt, config_gaps.md, zed_verification_summary.md
   verbatim. **Omit** `.rds` binaries and `output/` (empty).
3. **Rewrite** `README.md` fresh following the outline in Finding 5.
4. **Add** `EPI_ANSWERS.md` -- a literal transcript of the answers used
   for task 20, so a newcomer can reproduce verbatim.
5. **Rename on copy**: `05_consort_report.md` -> `consort_report.md`,
   `06_zed_verification_summary.md` -> `zed_verification_summary.md`,
   `00_env_check.txt` -> `env_check.txt`. Keep script prefixes
   (`00_`..`05_`) -- they document run order.
6. **Link back** to task 20 provenance artifacts from the README
   "Provenance" section. Do not duplicate research report / plan /
   summary into the demo.
7. **Do not symlink** -- use copies so the demo survives `/todo`
   archival or a vault operation on task 20.
8. **Planning phase** should resolve the location question (`zed/examples/`
   vs `.claude/extensions/epidemiology/examples/`) before file copies
   happen.

## Decisions Made During Research

- **Flat layout over mirrored `specs/` layout**: matches the idiom of
  "example code project" rather than "task archive".
- **Copy over symlink**: stability against archival.
- **Reference task 20 research/plan/summary rather than copy**: keeps
  the demo focused on the study itself, not on the task-system
  metadata.
- **Keep script numeric prefixes**: they serve as run-order
  documentation.

## Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Task 20 may be archived/vaulted, breaking provenance links | README states "provenance at the time of snapshot" and records the task-20 directory name; copies not symlinks |
| Newcomer without `survival`/`tidyverse` gets unexpected base-R output | README prominently notes the bare-R fallback and links to `config_gaps.md` |
| Scripts have hard-coded absolute paths from task 20 | **Verify during planning**: inspect each script for absolute paths, convert to relative-to-script if needed |
| RNG seeds may not be set, making "reproduce" non-deterministic | **Verify during planning**: check `01_generate_data.py` and `02_generate_outcomes.R` for seed; if missing, add seeds during implementation |
| `/epi` command may evolve (new Stage 0 questions) and render `EPI_ANSWERS.md` stale | README notes the `.claude/commands/epi.md` revision or date the answers were captured |
| Readers may think results are real | Prominent "synthetic data" banner at top of README and CONSORT report |

## Open Questions for Planning

1. **Location**: `zed/examples/epi-study/` vs
   `.claude/extensions/epidemiology/examples/epi-study/`? The latter
   colocates with the extension but is less discoverable. Recommend
   `zed/examples/epi-study/` with a cross-reference from the extension
   README.
2. **Scripts path portability**: Do any of `01_generate_data.py` ..
   `05_sensitivity.R` use absolute paths to the task 20 directory?
   Needs audit in planning; if yes, rewrite to relative paths anchored
   at the example root.
3. **RNG seed hygiene**: Are seeds set in `01_generate_data.py` and
   `02_generate_outcomes.R`? If not, either set them during the
   implementation phase or document that results will vary slightly.
4. **Should the CSV files be committed** or regenerated by the
   scripts? Recommendation: commit them, since they are tiny (201
   rows) and provide a reproducibility anchor, but planning should
   confirm.
5. **License / attribution note** on the synthetic data?
6. **Should the demo be linked from the top-level `zed/README.md`**
   and/or from `.claude/extensions/epidemiology/README.md`?
7. **`.qmd` handling**: leave as-is (unrendered), or attempt to render
   during the implementation phase if Quarto becomes available?
8. **Stage 0 answers transcript**: pure narrative markdown, or JSON
   snapshot from task 20's `forcing_data` in state.json? Preference:
   narrative markdown for readability, with a JSON appendix.

## Context Extension Recommendations

- **Topic**: `zed/examples/` directory convention
- **Gap**: No prior examples directory; no documented convention for
  "executable demos shipped alongside the config".
- **Recommendation**: If the user approves establishing this
  convention, add a short section to `.claude/context/repo/project-overview.md`
  documenting `zed/examples/` as "newcomer-facing worked examples
  (read-only; frozen snapshots of completed tasks)".

## References

- `.claude/commands/epi.md` -- canonical Stage 0 flow
- `.claude/CLAUDE.md` (Epidemiology Extension section) -- routing table
- `specs/020_test_epi_rct_ketamine_meth/summaries/01_epi-rct-test-study-summary.md` -- authoritative task-20 retrospective
- `specs/020_test_epi_rct_ketamine_meth/logs/config_gaps.md` -- environment gaps with remediation snippets
- `specs/020_test_epi_rct_ketamine_meth/reports/05_consort_report.md` -- CONSORT narrative to copy forward
- `.claude/context/formats/report-format.md` -- report format used here

## Appendix: Search / Exploration Trace

- `ls specs/020_test_epi_rct_ketamine_meth/{data,logs,output,plans,reports,scripts,summaries}` -- full inventory
- `Read .claude/commands/epi.md` -- Stage 0 flow extraction
- `Glob **/examples/**` under `zed/` -- only hits in `.claude/docs/examples/`
- `Read specs/020_.../summaries/01_epi-rct-test-study-summary.md` -- authoritative task retrospective
- `Read specs/020_.../logs/config_gaps.md` -- prerequisite gap list
- `Read specs/020_.../reports/05_consort_report.md` -- candidate for copy
- `head specs/020_.../plans/01_*.md` -- plan overview
- `head specs/020_.../data/raw/participants.csv` -- synthetic data sanity check
- `wc -l specs/020_.../data/**/*.csv` -- dataset sizing (201/201/51/201)
