# Implementation Plan: Ketamine-Assisted Therapy Test RCT (Zed R/Python Verification)

- **Task**: 20 - test_epi_rct_ketamine_meth
- **Status**: [NOT STARTED]
- **Effort**: 9 hours
- **Dependencies**: None
- **Research Inputs**: reports/01_epi-research.md
- **Artifacts**: plans/01_epi-rct-test-study.md
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/plan-format-enforcement.md
- **Type**: epi:study
- **Lean Intent**: false

## Overview

This plan executes a small synthetic-data RCT (ketamine-assisted therapy vs therapy-alone for methamphetamine use disorder) whose primary purpose is to exercise Zed's R and Python toolchains end-to-end. The pipeline deliberately interleaves Python (numpy/pandas baseline generation) and R (outcome simulation, primary analysis, Quarto reporting) to verify both LSPs, formatters, and cross-language CSV handoff. Each phase produces tangible artifacts and records any configuration gaps encountered, so the final summary doubles as a Zed + NixOS R/Python readiness report.

### Research Integration

Integrates `reports/01_epi-research.md`: study design (200 participants, 1:1 RCT, stratified by severity), variable specification, CONSORT analysis pipeline (logistic/Cox/linear models + sensitivity analyses), R/Python package requirements, and Zed configuration gaps (missing tidyverse, scipy, Quarto extension).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

Consulted `specs/ROADMAP.md` (read-only). This task advances the development-environment verification theme by exercising the recently-installed Python and R toolchains end-to-end and surfacing remaining configuration gaps.

## Goals & Non-Goals

**Goals**:
- Produce a runnable R + Python + Quarto pipeline on synthetic RCT data
- Execute primary (logistic), secondary (Cox, linear), and sensitivity analyses per CONSORT
- Verify R LSP, Python LSP (pyright + ruff), formatters, and diagnostics in Zed
- Exercise cross-language handoff (Python writes CSV -> R reads CSV -> Python reads CSV)
- Render a Quarto CONSORT report
- Produce a written configuration-gap log with concrete remediations

**Non-Goals**:
- Real-data analysis or clinical inference
- Full pre-registration or IRB documentation (simulated)
- Optimizing synthetic data realism beyond what is needed to exercise models
- Setting up full renv lockfile or uv project isolation (note gaps only)
- Modifying `configuration.nix` (recommendations only)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| R analysis packages (tidyverse, survival, gtsummary) missing | H | H | Phase 1 verifies and documents; fallback to base-R-only code path for all core analyses |
| Python scipy missing | M | H | Use numpy-only Weibull generation (`numpy.random.weibull`); note gap |
| Quarto engine not installed | M | M | Render to HTML only; if unavailable, emit Markdown report with knitted chunks |
| R LSP (`languageserver`) not installed | M | M | Document in gap log; proceed without LSP features |
| Model convergence warnings on small synthetic data | L | L | Use well-separated effect sizes; pre-specify seeds |
| Cross-language CSV encoding issues | L | L | Standardize on UTF-8 CSV with explicit column types |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5, 6 | 4 |
| 6 | 7 | 5, 6 |

Phases within the same wave can execute in parallel.

### Phase 1: Project Scaffolding and Toolchain Verification [COMPLETED]

**Goal**: Create the directory structure, verify R and Python are runnable from Zed's integrated terminal, and capture the initial state of installed packages.

**Tasks**:
- [ ] Create directories: `specs/020_test_epi_rct_ketamine_meth/{scripts,data/raw,data/derived,reports,logs}`
- [ ] Write `scripts/00_check_env.R` that prints `R.version`, `.libPaths()`, and attempts `library(survival)`, `library(tidyverse)`, `library(gtsummary)` with graceful fallback messages
- [ ] Write `scripts/00_check_env.py` that prints `sys.version` and attempts `import numpy, pandas, scipy, matplotlib` with graceful fallback messages
- [ ] Run both scripts; capture output to `logs/00_env_check.txt`
- [ ] Create `logs/config_gaps.md` seeded with findings
- [ ] Open one `.R` and one `.py` file in Zed; note LSP startup behavior, diagnostics, hover, format-on-save behavior in `config_gaps.md`

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `specs/020_test_epi_rct_ketamine_meth/scripts/00_check_env.R` - new
- `specs/020_test_epi_rct_ketamine_meth/scripts/00_check_env.py` - new
- `specs/020_test_epi_rct_ketamine_meth/logs/00_env_check.txt` - new
- `specs/020_test_epi_rct_ketamine_meth/logs/config_gaps.md` - new

**Verification**:
- Both env-check scripts exit 0
- `config_gaps.md` lists which R packages and Python modules are present/missing
- Zed LSP behavior noted for both languages

---

### Phase 2: Synthetic Baseline Data Generation (Python) [COMPLETED]

**Goal**: Generate 200 participants with baseline covariates and stratified 1:1 randomization using Python.

**Tasks**:
- [ ] Write `scripts/01_generate_data.py`:
  - Set seed 20260410
  - Generate `participant_id`, `age`, `sex`, `race_ethnicity`, `years_use`, `prior_treatment`, `baseline_asi`, `severity_stratum`
  - Implement stratified 1:1 randomization within severity strata -> `arm`
  - Use numpy-only distributions (avoid scipy dependency)
  - Write `data/raw/participants.csv` (UTF-8)
- [ ] Verify: 200 rows, balanced arms within strata (chi-square or simple count check), no NAs in baseline
- [ ] Run via Zed integrated terminal and via save-triggered workflow if available

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `specs/020_test_epi_rct_ketamine_meth/scripts/01_generate_data.py` - new
- `specs/020_test_epi_rct_ketamine_meth/data/raw/participants.csv` - new

**Verification**:
- `participants.csv` has 200 rows, 12 columns
- Balanced randomization (each stratum split within +/-2)
- Ruff format-on-save behavior documented in `config_gaps.md`

---

### Phase 3: Synthetic Outcomes Generation (R) [NOT STARTED]

**Goal**: Generate longitudinal outcomes conditional on treatment and baseline covariates, with realistic effect sizes and ~15% MCAR missingness.

**Tasks**:
- [ ] Write `scripts/02_generate_outcomes.R`:
  - Set seed 20260410
  - Read `data/raw/participants.csv` with `read.csv` (base) or `readr::read_csv` if available
  - Generate `abstinent_12wk` with ~40% KAT, ~25% TAU via logistic model on baseline covariates
  - Generate `days_to_use` (Weibull via base R `rweibull`) and censoring event indicator
  - Generate `asi_12wk` (normal, shifted by arm)
  - Generate `adverse_events` log (~50 rows)
  - Introduce ~15% MCAR on 12-week outcomes; set `completed_study` flag
  - Write `data/raw/outcomes.csv` and `data/raw/adverse_events.csv`
- [ ] Run script; confirm output row counts and arm effect directions

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `specs/020_test_epi_rct_ketamine_meth/scripts/02_generate_outcomes.R` - new
- `specs/020_test_epi_rct_ketamine_meth/data/raw/outcomes.csv` - new
- `specs/020_test_epi_rct_ketamine_meth/data/raw/adverse_events.csv` - new

**Verification**:
- Marginal abstinence proportions match targets within +/-10 percentage points
- ~15% missingness on `abstinent_12wk`
- R styler format-on-save behavior noted in `config_gaps.md`
- `library(survival)` load status recorded

---

### Phase 4: Merge and Derive Analytic Dataset (Python) [NOT STARTED]

**Goal**: Merge baseline, outcomes, and event data into the analytic dataset consumed by the analysis phase.

**Tasks**:
- [ ] Write `scripts/03_merge_data.py`:
  - Read participants.csv and outcomes.csv with pandas
  - Left-join on `participant_id`
  - Derive: `event` (1 = used meth, 0 = censored), `compliance` (fraction of 6 sessions), `arm_label`
  - Basic sanity checks (row count = 200, no duplicate IDs)
  - Write `data/derived/analytic.csv`
- [ ] Run and record any warnings

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `specs/020_test_epi_rct_ketamine_meth/scripts/03_merge_data.py` - new
- `specs/020_test_epi_rct_ketamine_meth/data/derived/analytic.csv` - new

**Verification**:
- `analytic.csv` has 200 rows and expected derived columns
- No merge-induced NAs in baseline covariates
- Pyright and ruff warnings (if any) logged

---

### Phase 5: Primary and Secondary Analyses (R) [NOT STARTED]

**Goal**: Execute the pre-specified primary logistic regression plus secondary Cox and linear models; produce a baseline Table 1.

**Tasks**:
- [ ] Write `scripts/04_primary_analysis.R`:
  - Read `data/derived/analytic.csv`
  - Primary: `glm(abstinent_12wk ~ arm + severity_stratum + age + sex + baseline_asi, family=binomial)` -> OR + 95% CI
  - Secondary: `coxph(Surv(days_to_use, event) ~ arm + covariates)` using `survival`
  - Secondary: `lm(asi_12wk ~ arm + covariates)`
  - If `gtsummary` loads: Table 1 by arm; else base-R `table()` + `summary()` fallback
  - Save tidy model outputs to `data/derived/models/*.rds` and a human-readable `reports/tables/primary_results.txt`
- [ ] Run the script and confirm all three models converge

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- `specs/020_test_epi_rct_ketamine_meth/scripts/04_primary_analysis.R` - new
- `specs/020_test_epi_rct_ketamine_meth/data/derived/models/` - new (model RDS files)
- `specs/020_test_epi_rct_ketamine_meth/reports/tables/primary_results.txt` - new

**Verification**:
- All three models converge without errors
- Primary OR direction matches simulated effect (KAT > TAU)
- Package-load successes/failures recorded in `config_gaps.md`

---

### Phase 6: Sensitivity Analyses (R) [NOT STARTED]

**Goal**: Run pre-specified sensitivity analyses (complete case, per-protocol, interaction test, and optional multiple imputation).

**Tasks**:
- [ ] Write `scripts/05_sensitivity.R`:
  - Complete-case analysis (filter `completed_study == 1`)
  - Per-protocol (filter `compliance >= 4/6`)
  - Treatment x severity interaction LRT
  - If `mice` available: 5-imputation MI; else document fallback
- [ ] Append results to `reports/tables/sensitivity_results.txt`

**Timing**: 1 hour

**Depends on**: 4

**Files to modify**:
- `specs/020_test_epi_rct_ketamine_meth/scripts/05_sensitivity.R` - new
- `specs/020_test_epi_rct_ketamine_meth/reports/tables/sensitivity_results.txt` - new

**Verification**:
- All sensitivity models run (or are documented as skipped with reason)
- LRT p-value reported for interaction test

---

### Phase 7: Quarto CONSORT Report and Configuration Summary [NOT STARTED]

**Goal**: Render a CONSORT-style Quarto report and finalize the Zed/R/Python configuration gap document.

**Tasks**:
- [ ] Write `reports/05_consort_report.qmd`:
  - YAML header (format html; fallback gfm if html engine unavailable)
  - Sections: Background, Methods, CONSORT flow numbers, Table 1, Primary results, Secondary results, Sensitivity, Limitations
  - R code chunks reading `data/derived/analytic.csv` and model RDS files
- [ ] Attempt `quarto render reports/05_consort_report.qmd`; on failure, capture error and fall back to knitr `rmarkdown::render` or plain Markdown
- [ ] Finalize `logs/config_gaps.md` with prioritized remediation list (package installs, settings.json additions, configuration.nix suggestions)
- [ ] Write short `reports/06_zed_verification_summary.md` capturing test-point results from research report section "Summary of Configuration Test Points" (10 items)

**Timing**: 2 hours

**Depends on**: 5, 6

**Files to modify**:
- `specs/020_test_epi_rct_ketamine_meth/reports/05_consort_report.qmd` - new
- `specs/020_test_epi_rct_ketamine_meth/reports/05_consort_report.html` (or .md) - new
- `specs/020_test_epi_rct_ketamine_meth/logs/config_gaps.md` - finalize
- `specs/020_test_epi_rct_ketamine_meth/reports/06_zed_verification_summary.md` - new

**Verification**:
- Quarto (or fallback) report rendered and readable
- `config_gaps.md` contains concrete remediation steps for each gap
- Verification summary addresses all 10 configuration test points from the research report

---

## Testing & Validation

- [ ] All 5 scripts (`00`-`05`) run to completion from Zed's integrated terminal
- [ ] Cross-language handoff verified: Python CSV -> R reads cleanly; R CSV -> Python reads cleanly
- [ ] Primary analysis OR has correct direction and plausible magnitude
- [ ] CONSORT-style report rendered (HTML preferred, Markdown fallback)
- [ ] All 10 Zed configuration test points from research report addressed in `reports/06_zed_verification_summary.md`
- [ ] `logs/config_gaps.md` provides concrete next steps for each gap

## Artifacts & Outputs

- `scripts/00_check_env.R`, `scripts/00_check_env.py`
- `scripts/01_generate_data.py`
- `scripts/02_generate_outcomes.R`
- `scripts/03_merge_data.py`
- `scripts/04_primary_analysis.R`
- `scripts/05_sensitivity.R`
- `data/raw/{participants,outcomes,adverse_events}.csv`
- `data/derived/analytic.csv`
- `data/derived/models/*.rds`
- `reports/tables/{primary_results,sensitivity_results}.txt`
- `reports/05_consort_report.qmd` (+ rendered output)
- `reports/06_zed_verification_summary.md`
- `logs/00_env_check.txt`
- `logs/config_gaps.md`

## Rollback/Contingency

- All artifacts live under `specs/020_test_epi_rct_ketamine_meth/`; rollback = delete that directory (no system state modified)
- No changes to `configuration.nix`, `settings.json`, or global R/Python environments are made in this plan; recommendations are written to `logs/config_gaps.md` only
- If R analysis packages are entirely unavailable, all analyses have base-R fallbacks; if base R is also unavailable, phases 3, 5, 6 are marked BLOCKED and the gap log is still produced as the primary deliverable
- If Quarto is unavailable, Phase 7 falls back to plain Markdown report; task remains COMPLETED with the fallback noted
