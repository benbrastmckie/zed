> **Synthetic data, no real participants.** Everything in this directory is
> fabricated for demonstration. Released as CC0 / public domain. Do NOT
> cite clinically.

# Example: Epidemiology Study Walkthrough (`/epi`)

A frozen, runnable snapshot of a synthetic randomized controlled trial
(RCT) produced by running the `/epi` command end to end. Use this as a
template for creating your own epidemiology studies with Claude Code's
epidemiology extension.

## About This Snapshot

This demo is a **snapshot of task 20** (`specs/020_test_epi_rct_ketamine_meth/`)
captured on **2026-04-10** against `.claude/commands/epi.md` as of that
date. The scripts, data, and results here are byte-for-byte copies
regenerable from a deterministic RNG seed (`20260410`). If the `/epi`
command schema evolves, the verbatim answers in `EPI_ANSWERS.md` may
drift -- the underlying analysis will still run.

## What This Demo Shows

A complete, minimum-viable epidemiology pipeline:

1. A simple two-arm parallel RCT comparing ketamine-assisted therapy
   (KAT) versus treatment-as-usual (TAU) for methamphetamine use
   disorder (N=200, 1:1 stratified randomization).
2. Synthetic data generation in both Python (baseline covariates) and
   R (outcomes), exercising both toolchains.
3. A primary logistic-regression analysis of 12-week abstinence with
   covariate adjustment for precision.
4. Secondary time-to-event and continuous-outcome analyses as
   fallbacks when the `survival` package is unavailable.
5. A CONSORT-style report assembled as Markdown (Quarto source is
   included but does not need to render).

**Headline result**: KAT vs TAU adjusted odds ratio for 12-week
abstinence = **3.29** (95% CI 1.57-6.89, p = 0.0016). See
`reports/tables/primary_results.txt` for the full model output.

## Prerequisites

| Tool | Minimum | Required For |
|------|---------|--------------|
| Python | 3.10+ with `numpy`, `pandas` | Baseline data generation, data merge |
| R | 4.0+ (base R only) | Outcome generation, primary/sensitivity analysis |
| Quarto | Optional | Rendering `reports/consort_report.qmd` |

The scripts deliberately use **only base R** and numpy/pandas so the
demo runs on a minimal environment. See `logs/config_gaps.md` for the
packages that would make this analysis richer (tidyverse, survival,
MICE, etc.).

## The `/epi` Workflow

The task that produced this example went through four Claude Code
commands, in order. You can reproduce this for your own study.

### Step 1: `/epi` -- Create the Task

From inside your Zed/Claude Code project:

```
/epi "Simple test RCT study on fake generated data to verify R and
Python are configured correctly in Zed"
```

The `/epi` command enters a Stage 0 interactive flow and asks up to 10
forcing questions about your study design, data, causal structure, and
reporting requirements. See `EPI_ANSWERS.md` for the literal answers
used to create task 20.

Stage 0 produces a new entry in `specs/TODO.md` and a task directory at
`specs/{NNN}_{slug}/` with the task in `[NOT STARTED]` status.

### Step 2: `/research N` -- Generate the Study Design Report

```
/research 20
```

This delegates to `epi-research-agent`, which produces a study design
report at `specs/{NNN}_{slug}/reports/01_epi-research.md` covering:

- PICO framing
- Causal DAG
- Data inventory and variable mapping
- Analysis plan (primary + sensitivity)
- Reporting checklist (CONSORT for RCTs)
- Risks, limitations, and ethics

### Step 3: `/plan N` -- Create the Implementation Plan

```
/plan 20
```

This produces a phased implementation plan at
`specs/{NNN}_{slug}/plans/01_implementation-plan.md` with explicit
phases for environment check, data generation, merging, primary
analysis, sensitivity, and reporting.

### Step 4: `/implement N` -- Execute the Plan

```
/implement 20
```

The `epi-implement-agent` executes each phase of the plan, writing
scripts and running them, until the task reaches `[COMPLETED]` status.
The scripts, CSVs, results tables, and CONSORT report in this directory
are exactly the outputs of that `/implement` run.

## Reproduce Directly From Scripts

If you want to skip the Claude Code workflow and just re-run the
analysis, the scripts run directly from this directory:

```bash
cd zed/examples/epi-study

python scripts/00_check_env.py        # verify python deps
Rscript scripts/00_check_env.R        # verify R is reachable
python scripts/01_generate_data.py    # generate baseline (seed 20260410)
Rscript scripts/02_generate_outcomes.R # generate outcomes (seed 20260410)
python scripts/03_merge_data.py       # merge into analytic.csv
Rscript scripts/04_primary_analysis.R # primary logistic regression
Rscript scripts/05_sensitivity.R      # sensitivity analyses
```

**Determinism**: Both seeds are `20260410`. A fresh run should produce
byte-identical CSVs and results tables to the committed files.

## Expected Outputs

After a full run you should see:

- `data/raw/participants.csv` -- 201 lines (200 participants + header)
- `data/raw/outcomes.csv`, `data/raw/adverse_events.csv`
- `data/derived/analytic.csv` -- merged analytic dataset
- `reports/tables/primary_results.txt` -- primary + secondary models
- `reports/tables/sensitivity_results.txt` -- sensitivity analyses
- `reports/consort_report.md` -- full CONSORT-style narrative

The primary model odds ratio (`armKAT`) should round to **3.29** with a
95% CI of roughly **1.57-6.89** and a p-value near 0.0016.

## Known Environment Gaps

Task 20 was executed on a bare R install without tidyverse, survival,
MICE, or quarto. The scripts degrade gracefully to base R equivalents
(log-rank fallback for survival, glm-Gamma for parametric time-to-event,
etc.). See `logs/config_gaps.md` for the full list of missing packages
and the chosen fallbacks. `logs/env_check.txt` contains the raw
environment probe from task 20.

## Provenance

This demo is a copy-snapshot of task 20. The original artifacts live at:

- Research report: `specs/020_test_epi_rct_ketamine_meth/reports/01_epi-research.md`
- Implementation plan: `specs/020_test_epi_rct_ketamine_meth/plans/01_epi-rct-test-study.md`
- Implementation summary: `specs/020_test_epi_rct_ketamine_meth/summaries/01_epi-rct-test-study-summary.md`

Refer to those artifacts for the decision rationale behind every
script, the full CONSORT discussion, and the list of methodological
caveats.

## Extension Points

Natural next steps if you fork this demo for your own work:

- Swap the outcome model in `04_primary_analysis.R` (e.g., Cox model
  if `survival` is installed; Bayesian logistic with `rstanarm`).
- Add a proper missing-data imputation pass with `mice` in a new
  `06_mice.R` script.
- Replace the base-R tables with `gtsummary` once tidyverse is
  available.
- Render `reports/consort_report.qmd` through Quarto for a
  publication-ready PDF or HTML output.
- Adapt `EPI_ANSWERS.md` for your own study design and re-run `/epi`
  to scaffold a new task.

## Directory Layout

```
zed/examples/epi-study/
├── README.md                 (this file)
├── EPI_ANSWERS.md            literal /epi Stage 0 answers
├── scripts/
│   ├── 00_check_env.py
│   ├── 00_check_env.R
│   ├── 01_generate_data.py   (seed: numpy 20260410)
│   ├── 02_generate_outcomes.R (seed: set.seed(20260410))
│   ├── 03_merge_data.py
│   ├── 04_primary_analysis.R
│   └── 05_sensitivity.R
├── data/
│   ├── raw/{participants,outcomes,adverse_events}.csv
│   └── derived/analytic.csv
├── reports/
│   ├── consort_report.md     (Markdown CONSORT report)
│   ├── consort_report.qmd    (optional Quarto source)
│   ├── zed_verification_summary.md
│   └── tables/
│       ├── primary_results.txt
│       └── sensitivity_results.txt
└── logs/
    ├── env_check.txt
    ├── config_gaps.md
    └── reproduction_check.txt (written by Phase 6 verification)
```
