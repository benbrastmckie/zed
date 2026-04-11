# /epi Stage 0 Answers

> Captured **2026-04-10** against `.claude/commands/epi.md` as of this
> snapshot. These are the literal forcing answers used to create task
> 20 (`specs/020_test_epi_rct_ketamine_meth/`). If the `/epi` command
> schema evolves, some keys or wording may drift -- the
> machine-readable JSON appendix is the source of truth for what
> task 20 was actually configured with.

## Invocation

```
/epi "Simple test RCT study on fake generated data to verify R and
Python are configured correctly in Zed"
```

## The 10 Forcing Questions

### 0.1 design

**Prompt**: What study design best fits this research?

**Answer**: `RCT` -- Randomized Controlled Trial. Two-arm,
parallel-group, 1:1 randomization, double-blind, placebo-controlled.

### 0.2 research_question

**Prompt**: State your primary research question (one sentence, PICO
if possible).

**Answer**: Does ketamine-assisted therapy (KAT) improve 12-week
sustained abstinence compared to therapy-alone (TAU) among adults
(18-65) with methamphetamine use disorder?

### 0.3 causal_structure

**Prompt**: Describe the causal structure (exposure, outcome,
confounders, mediators, colliders).

**Answer**: Treatment arm (KAT vs TAU) causes the recovery outcome
(abstinence, ASI). Because the exposure is randomized, there are no
confounders by design. Baseline severity, age, sex, years of use,
prior treatment attempts, and baseline ASI are included as
precision covariates only (not for confounding control). No
mediators or colliders adjusted for.

### 0.4 data_paths

**Prompt**: Where is the data? (File paths, database connections,
or "will be generated".)

**Answer**: `will be generated` -- synthetic data produced by the
task itself. Python generates baseline covariates
(`data/raw/participants.csv`); R generates outcomes
(`data/raw/outcomes.csv`, `data/raw/adverse_events.csv`).

### 0.5 descriptive_paths

**Prompt**: Describe each data source (N, rows/cols, key variables).

**Answer**:
- `participants.csv`: N=200, 12 cols, baseline + randomization
- `outcomes.csv`: 600 rows (3 timepoints x 200), 6 cols
- `adverse_events.csv`: ~50 rows, 5 cols
- `analytic.csv` (derived): 200 rows, 18 cols, merged analytic set

### 0.6 prior_work

**Prompt**: Any prior analyses, protocols, or literature to build on?

**Answer**: None. This is a toolchain-verification test study with
no published protocol or preregistration. Methods are inspired by
the general KAT-for-SUD literature but the numbers are entirely
fabricated.

### 0.7 ethics_status

**Prompt**: IRB/ethics status. (IRB_APPROVED, IRB_PENDING,
IRB_EXEMPT, NOT_APPLICABLE, etc.)

**Answer**: `IRB_APPROVED` (simulated) -- synthetic data with no
real participants, so no real IRB is involved. Treated as
`NOT_APPLICABLE` for all practical purposes.

### 0.8 reporting_guideline

**Prompt**: Which reporting guideline applies? (CONSORT, STROBE,
PRISMA, TRIPOD, ...)

**Answer**: `CONSORT` -- the study is an RCT.

### 0.9 r_preferences

**Prompt**: R workflow preferences (base R, tidyverse, renv, targets,
Quarto, ...)?

**Answer**: Base R preferred for this test because the Zed Nix R
install currently ships with only base packages. Falls back to
base-R equivalents for tidyverse and survival. Quarto is available
but not required -- the CONSORT report is a Markdown fallback with
the Quarto source kept alongside.

### 0.10 analysis_hints

**Prompt**: Any analysis hints (models, priors, sensitivity
analyses, missing-data handling)?

**Answer**:
- Primary: logistic regression on `abstinent_12wk ~ arm +
  severity_stratum + age + sex + baseline_asi`.
- Secondary: (a) time-to-first-use via `survival::coxph` with
  fallback to log-rank + glm-Gamma if `survival` is absent; (b)
  linear regression on 12-week ASI composite.
- Sensitivity: per-protocol subset, complete-case vs simple
  mean-imputation comparison, severity-stratum interaction test.
- Missing data: ~15% dropout by design; complete-case primary with
  sensitivity re-runs. No formal MICE unless the package is
  available.

## JSON Appendix (Machine-Readable)

```json
{
  "command": "/epi",
  "captured_at": "2026-04-10",
  "task_number": 20,
  "stage0_answers": {
    "design": "RCT",
    "research_question": "Does ketamine-assisted therapy improve 12-week sustained abstinence compared to therapy-alone among adults with methamphetamine use disorder?",
    "causal_structure": "Randomized exposure (arm) -> outcome (abstinence, ASI). No confounders by design. Baseline covariates used for precision only.",
    "data_paths": "will be generated",
    "descriptive_paths": {
      "participants.csv": {"n": 200, "cols": 12},
      "outcomes.csv": {"n": 600, "cols": 6},
      "adverse_events.csv": {"n": 50, "cols": 5},
      "analytic.csv": {"n": 200, "cols": 18}
    },
    "prior_work": "None -- toolchain verification study",
    "ethics_status": "IRB_APPROVED (simulated; treat as NOT_APPLICABLE)",
    "reporting_guideline": "CONSORT",
    "r_preferences": "base R (no tidyverse/survival/quarto required)",
    "analysis_hints": {
      "primary": "logistic regression with baseline covariates",
      "secondary": ["time-to-first-use", "12-week ASI linear regression"],
      "sensitivity": ["per-protocol", "complete-case vs mean-imputation", "severity interaction"],
      "missing_data": "complete-case with sensitivity reruns"
    }
  }
}
```
