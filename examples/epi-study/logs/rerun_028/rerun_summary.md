# Re-run Summary: Task 28 -- rerun_analysis_full_r_stack

## Provenance

- **Date**: 2026-04-10 (ISO: 2026-04-10T19:15:55-07:00)
- **Session ID**: sess_1775873625_54d6eb
- **Git commit (pre-run HEAD)**: 41736645c18046a6872801a4140ae4203797ac2e
- **Task**: 28 - rerun_analysis_full_r_stack
- **Dependency**: 27 (landed externally via ~/.dotfiles task 47, commit 06c14e1)

## Branch Taken

**A+B (Base-R reproducibility + Full enrichment stack)**

Rationale: Phase 1 branch probe showed the full tidyverse/survival/gtsummary/
mice/broom/knitr/rmarkdown stack is available in the active nix R environment,
confirming task 27 has landed. Python enrichment (scipy/statsmodels/sklearn/
seaborn/pyarrow) is also present. Quarto 1.8.26 available for HTML render.

## Environment Fingerprint

| Tool | Version |
|------|---------|
| R | 4.5.3 (2026-03-11) "Reassured Reassurer" |
| Python | 3.12.13 (GCC 15.2.0) |
| Quarto | 1.8.26 |
| Platform | x86_64-pc-linux-gnu (NixOS) |

**R library**: 178 packages visible across ~165 nix store library paths.
**Python**: numpy 2.4.2, pandas 2.3.3, scipy 1.17.1, statsmodels 0.14.6,
sklearn 1.8.0, seaborn 0.13.2.

## Byte-Identity Verification (Branch A)

| # | File | Verdict |
|---|------|---------|
| 1 | data/raw/participants.csv | IDENTICAL |
| 2 | data/raw/outcomes.csv | IDENTICAL |
| 3 | data/raw/adverse_events.csv | IDENTICAL |
| 4 | data/derived/analytic.csv | IDENTICAL |
| 5 | reports/tables/primary_results.txt | IDENTICAL |
| 6 | reports/tables/sensitivity_results.txt | IDENTICAL |

SHA256: all six hashes match Phase 2 baseline (see `identity_check.txt`).

## Headline Re-assertion (Branch A)

From `reports/tables/primary_results.txt`, `armKAT` row:

> **OR = 3.28721, 95% CI [1.570, 6.885], p = 0.00161**

Expected: OR ≈ 3.287, 95% CI 1.570-6.885, p = 0.00161. **PASS** (exact match
to ≥ 4 significant figures).

Sensitivity cross-check (`sensitivity_results.txt`, Complete case row):
`3.29  1.57  6.89  1.61e-03` — matches.

## Phase 6 Enrichment Results (Branch B)

All four enriched scripts executed against the frozen analytic.csv. Frozen
scripts `scripts/01_*.py` through `scripts/05_*.R` were NOT modified (verified
via `git status --porcelain examples/epi-study/scripts/` returning empty).

### 04b -- tidyverse/broom/gtsummary primary (`primary_results_tidy.txt`)

- Package stack: `readr`, `dplyr`, `broom`, `gtsummary`.
- `broom::tidy(fit, exponentiate = TRUE, conf.int = TRUE)` succeeded.
- `gtsummary::tbl_summary(by = arm)` succeeded.
- `gtsummary::tbl_regression` **skipped** because `broom.helpers` is absent
  from the current nix profile; broom::tidy output covers the same fields.
- **Headline**: armKAT OR = 3.2872, 95% CI [1.5954, 7.0465], p = 0.00161.
  Matches base-R result to 4 sig figs. (CI upper differs slightly from base-R
  because broom uses profile-likelihood CIs by default vs Wald in base-R.)

### 04c -- survival::coxph (`cox_results.txt`)

- Package stack: `survival`.
- `coxph(Surv(days_to_use, event) ~ arm + severity_stratum + age + sex + baseline_asi)`.
- `cox.zph` proportional hazards test: GLOBAL p = 0.55 (PH assumption holds).
- Kaplan-Meier medians: TAU 25.4 days (95% CI 22.5-31.9); KAT 40.5 days
  (95% CI 36.5-53.2).
- **Headline**: armKAT HR = 0.4260, 95% CI [0.3114, 0.5826], p < 1e-5.
  **HR < 1 assertion: PASS**.

### 05b -- mice multiple imputation (`sensitivity_mice.txt`)

- Package stack: `mice`.
- `mice(..., m = 20, seed = 20260410)` on 30 missing `abstinent_12wk` values.
- Pooled via `mice::pool()` then `summary(conf.int = TRUE, exponentiate = TRUE)`.
- **Headline pooled**: armKAT OR = 3.2620, 95% CI [1.5660, 6.7947], p = 0.00176.
- Complete-case OR = 3.2872; pooled deviation = 0.77%.
- **within-20% assertion: PASS**.

### 06 -- quarto render (`reports/rendered/consort_report.html`)

- `quarto render reports/consort_report.qmd --to html --output-dir reports/rendered/`.
- Exit 0. Output file: `reports/rendered/consort_report.html` (plus
  supporting `consort_report_files/` and Markdown preview).
- Output directory is gitignored via `examples/epi-study/.gitignore`.

## Provenance Artifacts

- `env_snapshot.txt` -- dates, `which` results, version strings, libPaths.
- `00_env_py.txt`, `00_env_r.txt` -- script probes from `scripts/00_check_env.*`.
- `branch_probe.txt` -- per-package requireNamespace / find_spec results.
- `branch_decision.txt` -- "A+B".
- `baseline/*.csv`, `*.txt`, `sha256sums.txt` -- pre-run baseline snapshot.
- `01_generate_data.log` ... `05_sensitivity.log` -- Branch A pipeline logs.
- `identity_check.txt` -- diff verdicts, SHA256 comparison, headline grep.
- `session_info_r.txt`, `session_info_py.txt` -- sessionInfo dumps.
- `git_commit.txt`, `git_status.txt` -- source provenance.
- `phase6_04b_primary_tidy.log`, `phase6_04c_primary_survival.log`,
  `phase6_05b_sensitivity_mice.log`, `phase6_06_quarto_render.log` --
  Branch B run logs.
- `rerun_summary.md` -- **this file**.

## Deviations and Observations

1. **`broom.helpers` not installed**: `gtsummary::tbl_regression` requires
   broom.helpers >= 1.20.0, which is not in the current nix R profile.
   Handled by conditional gating (`requireNamespace("broom.helpers")`) and
   skipping that specific table while retaining `broom::tidy` output. This
   is a minor nix derivation gap that does not affect scientific conclusions.
2. **gtsummary HTML output in sinked file**: `tbl_summary()` print method
   emits raw HTML when sinked. The `broom::tidy()` data frame provides the
   numerical content cleanly; the HTML blob in primary_results_tidy.txt is
   visual noise but not a correctness issue.
3. **Wald vs profile-likelihood CIs**: base-R script 04 uses Wald CIs; broom's
   `conf.int = TRUE` defaults to profile likelihood for glm. Upper CI for
   armKAT differs slightly (6.885 Wald vs 7.047 profile). Both bracket the
   point estimate 3.287 and neither contains 1.0. This is methodological,
   not a regression.
4. **Git status clean at frozen scripts**: after all phases, `git status
   --porcelain examples/epi-study/scripts/` returns empty, confirming the
   frozen snapshot constraint was honored.

## Links

- Identity check: `examples/epi-study/logs/rerun_028/identity_check.txt`
- R session info: `examples/epi-study/logs/rerun_028/session_info_r.txt`
- Git commit: `examples/epi-study/logs/rerun_028/git_commit.txt`
- Enriched scripts: `specs/028_rerun_analysis_full_r_stack/artifacts/enriched/`
- Implementation plan: `specs/028_rerun_analysis_full_r_stack/plans/01_rerun-analysis-plan.md`
