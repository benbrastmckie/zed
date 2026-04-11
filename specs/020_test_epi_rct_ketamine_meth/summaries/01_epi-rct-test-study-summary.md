# Implementation Summary: Ketamine RCT Toolchain Verification

- **Task**: 20 - test_epi_rct_ketamine_meth
- **Type**: epi:study
- **Study Design**: RCT (synthetic, N=200)
- **Reporting Guideline**: CONSORT
- **Status**: Completed (with graceful degradation of R packages and Quarto)

## Overview

Executed a synthetic ketamine-assisted therapy vs therapy-as-usual RCT
pipeline end-to-end primarily to verify Zed's R, Python, and Quarto toolchains
on NixOS. The analysis pipeline (data generation -> merge -> regression ->
sensitivity -> CONSORT report) ran successfully on base R + numpy/pandas,
but revealed that the R environment is a bare-base install with no
`tidyverse`, `survival`, `gtsummary`, `mice`, or `languageserver`, and that
Quarto is not installed at all. The configuration gap log is the primary
deliverable of this task.

## Scripts Created

| Script | Purpose | Status |
|---|---|---|
| scripts/00_check_env.R | R version + package availability | Complete |
| scripts/00_check_env.py | Python version + module availability | Complete |
| scripts/01_generate_data.py | 200 participants, stratified 1:1 randomization | Complete |
| scripts/02_generate_outcomes.R | Abstinence, time-to-use, ASI, AEs, 15% MCAR | Complete |
| scripts/03_merge_data.py | Merge + derive analytic.csv | Complete |
| scripts/04_primary_analysis.R | Logistic + Cox-fallback + linear regression | Complete |
| scripts/05_sensitivity.R | CC, PP, interaction, tipping-point | Complete |
| reports/05_consort_report.qmd | CONSORT Quarto source (not rendered) | Source only |
| reports/05_consort_report.md | Markdown fallback with embedded numbers | Complete |
| reports/06_zed_verification_summary.md | 10 configuration test points | Complete |

## Key Results (Synthetic)

**Primary** (logistic, adjusted, complete-case n=170):
OR for KAT vs TAU = **3.29 (95% CI 1.57 - 6.89), p = 0.002**
Observed abstinence: KAT 42.4% vs TAU 22.4%.

**Secondary**:
- Time-to-relapse (exponential-GLM Cox surrogate): KAT extends time
  (log-rank + exp GLM; full numbers in primary_results.txt).
- ASI at 12 weeks (linear regression): arm beta = -0.100, p = 1.2e-10.

**Sensitivity**:
Primary result robust under per-protocol (OR 2.52) and single-imputation
(OR 3.13). Worst-case tipping point collapses OR to 1.29 (ns); best-case
pushes to 5.88.

## Toolchain Verification Scoreboard

| Component | Result |
|---|---|
| R runtime | PASS (R 4.5.3 via Nix) |
| R analysis packages (tidyverse/survival/gtsummary/mice/broom) | FAIL (all missing) |
| R LSP (languageserver) | FAIL (missing) |
| R formatter/linter (styler/lintr) | FAIL (missing) |
| Python runtime | PASS (3.12.13) |
| Python stack (numpy/pandas/matplotlib) | PASS |
| Python stack (scipy/statsmodels/seaborn/sklearn/pyarrow) | FAIL |
| Quarto | FAIL (missing) |
| Cross-language CSV handoff | PASS |
| End-to-end pipeline from terminal | PASS |

**4 pass / 1 partial / 4 fail / 1 unknown** (interactive Zed LSP behavior
not observable from headless agent -- see test point 8 in
`reports/06_zed_verification_summary.md`).

## Consolidated Configuration Gap List

Sorted by priority (full details with nix snippets in
[`logs/config_gaps.md`](../logs/config_gaps.md)).

### HIGH priority (blocks standard epi work)

1. **R: survival** -- required for Cox, KM, Surv(). Install via
   `rPackages.survival` in `configuration.nix` or `nix profile`.
2. **R: tidyverse** (dplyr/readr/ggplot2/tidyr/purrr) -- blocks most
   modern R code. Install via `rPackages.tidyverse`.
3. **R: languageserver** -- Zed has no R LSP at all without this.
   Install via `rPackages.languageserver`, then register in
   Zed `settings.json`.
4. **Python: scipy + statsmodels** -- standard distributions and regression
   helpers. Install via `python312Packages.scipy python312Packages.statsmodels`.

### MEDIUM priority

5. **R: gtsummary, broom, mice, knitr, rmarkdown** -- Table 1, tidy output,
   multiple imputation, knitr reporting.
6. **R: styler, lintr** -- format-on-save and diagnostics in Zed.
7. **Quarto** -- for reproducible CONSORT reports. `pkgs.quarto` +
   dependencies on knitr/rmarkdown and jupyter.
8. **Python: seaborn, scikit-learn, pyarrow** -- plotting, ML helpers,
   fast IO.

### LOW priority / structural

9. Create a project-level `flake.nix` so each epi task gets a pinned R +
   Python + Quarto environment independently of system config.
10. Add `uv` project with `pyproject.toml` for Python dependency pinning.
11. Consider `renv` for R (requires `renv` package first).

## Recommended Zed `settings.json` Additions

(See `logs/config_gaps.md` "Recommended Zed settings.json Additions" for the
full JSON snippet.)

Priority additions: register `r-languageserver` under `lsp.r-languageserver`
with `Rscript -e "languageserver::run()"`, and under
`languages.R.language_servers` list `["r-languageserver"]`. Python should
already work with the Python extension's default pyright + ruff registration.

## Deviations From Plan

- **Phase 1**: Verification of interactive Zed LSP/format-on-save behavior
  (test points 6-8) could not be done from a headless agent. Documented
  as "Unknown" and deferred to manual verification.
- **Phase 3**: `library(survival)` not loaded (package missing). Proceeded
  with a custom base-R log-rank implementation and an exponential GLM in
  place of `coxph`.
- **Phase 5**: `gtsummary` Table 1 replaced with base-R `aggregate()` and
  `table()` output dumped to a text file via `sink()`.
- **Phase 6**: `mice` multiple imputation replaced with single-imputation
  (mode/mean) plus worst-/best-case tipping-point bounds.
- **Phase 7**: `quarto render` skipped (binary missing). `.qmd` source
  preserved and a hand-maintained `05_consort_report.md` with pre-computed
  numbers from phase-5/6 RDS files was produced as the deliverable report.

## Outputs

| Output | Path |
|---|---|
| Config gap log | `logs/config_gaps.md` |
| Env check log | `logs/00_env_check.txt` |
| Analytic dataset | `data/derived/analytic.csv` |
| Model objects | `data/derived/models/{primary_logistic,secondary_exponential,secondary_linear}.rds` |
| Primary results text | `reports/tables/primary_results.txt` |
| Sensitivity results text | `reports/tables/sensitivity_results.txt` |
| CONSORT report (md) | `reports/05_consort_report.md` |
| CONSORT report (qmd) | `reports/05_consort_report.qmd` |
| Zed verification summary | `reports/06_zed_verification_summary.md` |

## Next Steps

1. Apply the HIGH-priority remediations from `logs/config_gaps.md` (R
   package set + Quarto).
2. Re-run this task's scripts after remediation to confirm `survival`,
   `gtsummary`, and `quarto render` now work end-to-end. None of the scripts
   need edits for that re-run; they are forward-compatible.
3. Register the R language server in `settings.json` and verify
   completion/hover/diagnostics interactively in Zed on
   `scripts/04_primary_analysis.R`.
4. Consider creating a project-local `flake.nix` to pin the epi environment.
