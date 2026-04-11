# Study Design Report: Ketamine-Assisted Therapy for Methamphetamine Use Disorder (Test RCT)

- **Task**: 20 - Simple test RCT study on fake generated data to verify R and Python are configured correctly in Zed
- **Study Design**: RCT (Randomized Controlled Trial)
- **Research Question**: Does ketamine-assisted therapy improve recovery from methamphetamine use disorder?
- **Reporting Guideline**: CONSORT
- **Ethics Status**: IRB_APPROVED (simulated -- synthetic data)

## Executive Summary

This is a **test study using synthetic data** designed to verify that R and Python are correctly configured in Zed. The study simulates a parallel-group RCT comparing ketamine-assisted therapy versus therapy-alone for methamphetamine use disorder. The primary analysis uses logistic regression for binary abstinence outcome, with secondary time-to-event and continuous outcomes to exercise multiple modeling approaches. The synthetic data generation uses both R and Python to verify both toolchains. Key configuration gaps identified: R has only base packages installed (no tidyverse, no analysis packages), and Python lacks scipy.

## Study Overview

### Research Question (PICO)

| Component | Value |
|-----------|-------|
| **P**opulation | Adults (18-65) with methamphetamine use disorder (DSM-5 criteria) |
| **I**ntervention | Ketamine-assisted therapy (KAT): 6 sessions of psychotherapy + sub-anesthetic IV ketamine |
| **C**omparator | Therapy-alone (TAU): 6 sessions of psychotherapy + IV saline placebo |
| **O**utcome (primary) | Sustained abstinence at 12 weeks (binary: yes/no, verified by urine drug screen) |
| **O**utcome (secondary) | Days to first methamphetamine use; Addiction Severity Index (ASI) composite score at 12 weeks |

### Study Design

Two-arm, parallel-group, double-blind, placebo-controlled RCT with 1:1 randomization. Target N=200 (100 per arm). Follow-up at 4, 8, and 12 weeks. Simple randomization stratified by baseline severity (mild vs. moderate-severe).

### Causal Structure

```
Treatment (KAT vs TAU)
    |
    v
Recovery (abstinence, ASI score)
    ^          ^
    |          |
Baseline     Demographics
Severity     (age, sex)
```

The DAG is simple by design:
- **Exposure**: Treatment assignment (randomized, so no confounding by design)
- **Outcome**: 12-week abstinence
- **Baseline covariates** (for precision, not confounding control): age, sex, baseline severity, years of use, prior treatment attempts

In an RCT, randomization handles confounding. Baseline covariates are included for precision gains (pre-specified in the analysis plan) rather than confounding adjustment.

## Data Inventory

### Synthetic Data to Be Generated

No existing data files. The following synthetic datasets will be generated as part of implementation to test R and Python toolchains.

| File | Format | Rows | Columns | Purpose |
|------|--------|------|---------|---------|
| `data/raw/participants.csv` | CSV | 200 | 12 | Baseline demographics and randomization |
| `data/raw/outcomes.csv` | CSV | 600 | 6 | Longitudinal outcomes (3 timepoints x 200) |
| `data/raw/adverse_events.csv` | CSV | ~50 | 5 | Adverse event log |
| `data/derived/analytic.csv` | CSV | 200 | 18 | Merged analytic dataset |

### Variable Mapping

| Role | Variable | Type | Distribution / Values | Notes |
|------|----------|------|----------------------|-------|
| **ID** | `participant_id` | character | P001-P200 | Unique identifier |
| **Treatment** | `arm` | binary | 1=KAT, 0=TAU (1:1 ratio) | Randomized allocation |
| **Stratifier** | `severity_stratum` | binary | 0=mild, 1=moderate-severe | Randomization stratum |
| **Primary outcome** | `abstinent_12wk` | binary | ~40% KAT, ~25% TAU | 12-week sustained abstinence |
| **Secondary outcome** | `days_to_use` | integer | Weibull(shape=1.2) | Days until first meth use (censored at 84) |
| **Secondary outcome** | `asi_12wk` | continuous | Normal(mean varies by arm) | ASI composite at 12 weeks |
| **Covariate** | `age` | continuous | Normal(38, 10), truncated 18-65 | Years |
| **Covariate** | `sex` | binary | 0=male, 1=female, ~40% female | Biological sex |
| **Covariate** | `race_ethnicity` | categorical | 4 levels | Self-reported |
| **Covariate** | `years_use` | continuous | Gamma(shape=3, rate=0.5) | Years of meth use |
| **Covariate** | `prior_treatment` | integer | Poisson(1.5) | Prior treatment attempts |
| **Covariate** | `baseline_asi` | continuous | Beta(2,5) scaled to 0-1 | Baseline ASI composite |
| **Missingness** | `completed_study` | binary | ~85% complete | Study completion indicator |

### Data Generation Strategy

Generate data in **both R and Python** to verify both toolchains:

1. **Python script** (`scripts/01_generate_data.py`): Generate baseline participant data using numpy/pandas
2. **R script** (`scripts/02_generate_outcomes.R`): Generate outcomes conditional on treatment and covariates using base R + optional tidyverse
3. **Python script** (`scripts/03_merge_data.py`): Merge and create analytic dataset
4. **R script** (`scripts/04_primary_analysis.R`): Run primary and sensitivity analyses
5. **Quarto document** (`reports/05_consort_report.qmd`): CONSORT-style results report

This interleaving deliberately exercises both languages and the handoff between them.

## Proposed Analysis Phases

### Phase 1: Data Generation and Preparation

**Python** (`scripts/01_generate_data.py`):
- Generate 200 participants with baseline covariates
- Implement stratified randomization (1:1 within severity strata)
- Write `data/raw/participants.csv`
- Packages needed: `numpy`, `pandas`

**R** (`scripts/02_generate_outcomes.R`):
- Read participants.csv
- Generate outcomes conditional on treatment arm and baseline covariates
- Introduce ~15% MCAR missingness for testing missing data handling
- Write `data/raw/outcomes.csv` and `data/raw/adverse_events.csv`
- Packages needed: `readr` (or base R `read.csv`)

**Python** (`scripts/03_merge_data.py`):
- Merge participants + outcomes into analytic dataset
- Create derived variables (treatment duration, compliance indicators)
- Write `data/derived/analytic.csv`
- Packages needed: `pandas`

### Phase 2: Exploratory Data Analysis

**R** (part of `scripts/04_primary_analysis.R` or separate EDA script):
- CONSORT flow diagram numbers (enrolled, randomized, analyzed)
- Table 1: Baseline characteristics by treatment arm
- Check covariate balance (standardized mean differences)
- Missing data assessment (patterns, proportions)
- Outcome distributions by arm
- Packages needed: `gtsummary` (Table 1), `naniar` (missing data), `ggplot2` (plots)

### Phase 3: Primary Analysis

**Primary model**: Logistic regression for binary primary outcome.

```r
# Primary analysis: intention-to-treat logistic regression
model_primary <- glm(
  abstinent_12wk ~ arm + severity_stratum + age + sex + baseline_asi,
  data = analytic,
  family = binomial(link = "logit")
)
summary(model_primary)

# Odds ratio with 95% CI
exp(cbind(OR = coef(model_primary), confint(model_primary)))
```

**Secondary analyses**:

```r
# Time-to-event: Cox proportional hazards
library(survival)
model_tte <- coxph(
  Surv(days_to_use, event) ~ arm + severity_stratum + age + sex + baseline_asi,
  data = analytic
)

# Continuous outcome: linear regression for ASI score
model_asi <- lm(
  asi_12wk ~ arm + severity_stratum + age + sex + baseline_asi,
  data = analytic
)
```

Packages needed: `survival` (Cox model), base R `glm`/`lm`

### Phase 4: Sensitivity Analyses

1. **Complete case analysis**: Restrict to participants who completed the study
2. **Per-protocol analysis**: Restrict to participants with >= 4/6 sessions attended
3. **Interaction test**: Treatment x baseline severity interaction
4. **Multiple imputation** (if mice package available): Impute missing 12-week outcomes

```r
# Sensitivity: treatment x severity interaction
model_interaction <- glm(
  abstinent_12wk ~ arm * severity_stratum + age + sex + baseline_asi,
  data = analytic,
  family = binomial(link = "logit")
)
anova(model_primary, model_interaction, test = "LRT")
```

Packages needed: `mice` (multiple imputation, optional)

### Phase 5: Reporting

**Quarto document** (`reports/05_consort_report.qmd`):
- CONSORT flow diagram
- Table 1 (baseline characteristics)
- Table 2 (primary and secondary outcomes by arm)
- Forest plot of treatment effects
- Kaplan-Meier curves for time-to-use

Packages needed: `quarto`, `gtsummary`, `ggplot2`, `flextable` or `knitr`

## Statistical Approach

### Primary Model

Logistic regression with pre-specified covariates (age, sex, baseline severity, baseline ASI). This is appropriate for:
- Binary outcome (12-week abstinence)
- RCT design (covariates for precision, not confounding)
- Moderate sample size (N=200)

The treatment effect is reported as an odds ratio (OR) with 95% CI. A two-sided p-value < 0.05 is considered statistically significant.

### Sample Size Justification

With N=200 (100/arm), assuming 25% abstinence in control and 40% in treatment (OR = 2.0), this study has approximately 80% power at alpha=0.05. This is adequate for a configuration test while being realistic for a Phase II substance use trial.

### Assumptions and Diagnostics

| Assumption | Diagnostic | R Code |
|-----------|-----------|--------|
| Linearity of log-odds | Component-plus-residual plots | `car::crPlots(model)` |
| No multicollinearity | VIF | `car::vif(model)` |
| Model fit | Hosmer-Lemeshow test | `ResourceSelection::hoslem.test()` |
| Influential observations | Cook's distance | `plot(model, which=4)` |
| Proportional hazards (Cox) | Schoenfeld residuals | `cox.zph(model_tte)` |

## R Package Requirements

### Required for Minimal Test (Base R Only)

These analyses can run with **zero additional packages** using base R:

| Function | Base R | Purpose |
|----------|--------|---------|
| `read.csv()` | base | Read CSV data |
| `glm(..., family=binomial)` | stats | Logistic regression |
| `lm()` | stats | Linear regression |
| `confint()` | stats | Confidence intervals |
| `t.test()`, `chisq.test()` | stats | Simple comparisons |

### Recommended Packages (Tidyverse Workflow)

| Phase | Package | Purpose | CRAN |
|-------|---------|---------|------|
| Data Prep | `readr` | Fast CSV reading | Yes |
| Data Prep | `dplyr` | Data manipulation | Yes |
| Data Prep | `tidyr` | Reshaping | Yes |
| Data Prep | `janitor` | Clean column names | Yes |
| EDA | `gtsummary` | Table 1, regression tables | Yes |
| EDA | `naniar` | Missing data visualization | Yes |
| EDA | `ggplot2` | Plotting | Yes |
| Analysis | `survival` | Cox PH, Kaplan-Meier | Yes |
| Analysis | `broom` | Tidy model output | Yes |
| Sensitivity | `mice` | Multiple imputation | Yes |
| Sensitivity | `car` | Diagnostics (VIF, CR plots) | Yes |
| Reporting | `quarto` | Literate programming | Yes |
| Reporting | `flextable` | Publication tables | Yes |
| Reporting | `knitr` | Quarto/Rmarkdown engine | Yes |

### Installation Commands

```r
# Minimal test (just survival for Cox model)
install.packages("survival")

# Full tidyverse workflow
install.packages(c(
  "tidyverse",     # includes dplyr, ggplot2, readr, tidyr, etc.
  "gtsummary",     # Table 1 and regression summaries
  "survival",      # Time-to-event analysis
  "broom",         # Tidy model output
  "janitor",       # Data cleaning
  "naniar",        # Missing data
  "mice",          # Multiple imputation
  "car",           # Regression diagnostics
  "flextable",     # Tables for Word/PDF
  "quarto"         # Quarto integration
))
```

## Python Package Requirements

| Package | Version Available | Purpose |
|---------|-------------------|---------|
| `numpy` | 2.4.2 (installed) | Random number generation, arrays |
| `pandas` | 2.3.3 (installed) | DataFrames, CSV I/O |
| `matplotlib` | 3.10.8 (installed) | Plotting (optional) |
| `scipy` | NOT INSTALLED | Statistical distributions (needed for Weibull generation) |

### Installation Commands

```bash
# scipy is needed for data generation
pip install scipy

# Or via nix (preferred on NixOS)
# Add python312Packages.scipy to configuration.nix
```

## Zed Configuration Assessment

### Current Configuration Status

| Component | Status | Notes |
|-----------|--------|-------|
| Python extension | Configured | Auto-install enabled, pyright + ruff LSP |
| R extension | Configured | Auto-install enabled, r-language-server |
| Pyright LSP | Configured | typeCheckingMode: basic, openFilesOnly |
| Ruff LSP | Configured | Format on save via ruff |
| R LSP | Configured | Diagnostics + rich documentation enabled |
| R formatter | Configured | styler via r-language-server |

### Configuration Issues to Test

| Issue | Severity | Description | Test |
|-------|----------|-------------|------|
| R packages missing | Critical | Only base R installed -- no tidyverse, survival, gtsummary | Open .R file, try `library(tidyverse)` |
| scipy missing | Important | Python scipy not installed, needed for Weibull distributions | `import scipy` in .py file |
| R LSP startup | Important | r-language-server requires `languageserver` R package -- verify it is installed | Open .R file, check LSP status |
| Quarto support | Minor | No Quarto extension in auto_install_extensions | Open .qmd file, check syntax highlighting |
| R format on save | Minor | styler must be installed for R formatting to work | Edit .R file, save, check formatting |
| lintr diagnostics | Minor | lintr must be installed for R linting | Open .R file, check for diagnostic squiggles |

### Recommended settings.json Additions

```jsonc
// Add Quarto extension for .qmd support
"auto_install_extensions": {
  // ... existing entries ...
  "quarto": true
}

// Optional: Add Quarto language settings
"languages": {
  "Quarto": {
    "soft_wrap": "editor_width",
    "tab_size": 2
  }
}
```

### NixOS Package Additions Needed

For the R analysis pipeline to work, these packages should be added to `configuration.nix`:

```nix
# In the R packages section of configuration.nix
(rWrapper.override {
  packages = with rPackages; [
    languageserver
    lintr
    styler
    # Add for this test study:
    tidyverse
    survival
    gtsummary
    broom
    janitor
    naniar
    mice
    car
    flextable
    quarto
  ];
})
```

For Python:
```nix
# In the Python packages section
(python312.withPackages (ps: with ps; [
  # existing packages...
  scipy  # Add this
]))
```

## Content Gaps

| # | Gap | Severity | Suggested Resolution |
|---|-----|----------|---------------------|
| 1 | No R analysis packages installed | Critical | Install tidyverse + survival + gtsummary via `install.packages()` or nix |
| 2 | Python scipy not available | Important | Install via pip or add to nix config |
| 3 | Quarto not configured in Zed | Minor | Add quarto extension to auto_install_extensions |
| 4 | R languageserver/lintr/styler installation status unknown | Important | Verify these are installed in R (they were in task 19 NixOS config) |
| 5 | No project-level renv lockfile | Minor | Consider `renv::init()` for reproducible R environment |
| 6 | No Python virtual environment | Minor | Consider `uv venv` for project isolation |
| 7 | CONSORT flow diagram tooling | Minor | May need `consort` R package or manual diagram |

## CONSORT Reporting Checklist

Applicable items for this test RCT (CONSORT 2010):

- [x] **1a** Title: Identified as randomized trial
- [x] **2a** Background: Scientific rationale
- [x] **2b** Objectives: Specific hypothesis (KAT > TAU for abstinence)
- [x] **3a** Trial design: Parallel group, 1:1 randomization
- [x] **4a** Eligibility criteria: Adults 18-65 with meth use disorder
- [x] **4b** Settings: Not applicable (synthetic data)
- [x] **5** Interventions: KAT (ketamine + therapy) vs TAU (placebo + therapy)
- [x] **6a** Outcomes: Primary (abstinence), secondary (days-to-use, ASI)
- [x] **7a** Sample size: N=200, 80% power for OR=2.0
- [x] **8a** Randomization sequence: Simple randomization, stratified by severity
- [ ] **8b** Type of randomization: Block size not specified (synthetic)
- [x] **9** Allocation concealment: Double-blind (simulated)
- [x] **10** Implementation: Automated (synthetic)
- [x] **11a** Blinding: Double-blind (participants + assessors)
- [x] **12a** Statistical methods: Logistic regression, Cox PH, linear regression
- [x] **13a** CONSORT flow: To be generated from data
- [x] **14a** Dates of recruitment: Not applicable (synthetic)
- [~] **15** Baseline characteristics: Table 1 planned, not yet generated
- [~] **16** Outcomes: Analysis planned, not yet executed
- [~] **17a** Estimation: OR with 95% CI planned
- [ ] **19** Harms: Adverse events dataset planned
- [~] **20** Limitations: To be addressed in discussion
- [ ] **22** Interpretation: Pending analysis
- [x] **23** Registration: Not applicable (test study)
- [x] **25** Protocol: This document serves as protocol

Legend: [x] Addressed | [ ] Requires additional work | [~] Partially addressed

## Implementation File Structure

```
specs/020_test_epi_rct_ketamine_meth/
├── reports/
│   └── 01_epi-research.md          # This report
├── scripts/
│   ├── 01_generate_data.py          # Python: baseline data generation
│   ├── 02_generate_outcomes.R       # R: outcome generation
│   ├── 03_merge_data.py             # Python: merge and derive
│   └── 04_primary_analysis.R        # R: all analyses
├── reports/
│   └── 05_consort_report.qmd        # Quarto: CONSORT results
└── data/
    ├── raw/
    │   ├── participants.csv
    │   ├── outcomes.csv
    │   └── adverse_events.csv
    └── derived/
        └── analytic.csv
```

## Summary of Configuration Test Points

This study is specifically designed to exercise and verify:

1. **R base functionality**: Can R read/write CSVs, run `glm()`, `lm()` from base?
2. **R package installation**: Can tidyverse, survival, gtsummary be installed and loaded?
3. **R LSP in Zed**: Does r-language-server provide diagnostics, completion, formatting?
4. **Python base functionality**: Can Python generate data with numpy/pandas?
5. **Python scipy**: Is scipy available (or can it be installed)?
6. **Python LSP in Zed**: Does pyright provide type checking, ruff provide formatting?
7. **Cross-language handoff**: Can R read Python-generated CSVs and vice versa?
8. **Quarto rendering**: Can a .qmd file compile to HTML/PDF with R code chunks?
9. **Format on save**: Does both R and Python formatting work on save?
10. **Diagnostics**: Do both languages show inline errors/warnings?
