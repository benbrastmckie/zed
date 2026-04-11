# Implementation Summary: Re-run Epi Study with Full R Stack

- **Task**: 28 - rerun_analysis_full_r_stack
- **Session**: sess_1775873625_54d6eb
- **Date**: 2026-04-10
- **Branch Taken**: **A+B** (Base-R reproducibility verified + Full enrichment executed)
- **Plan**: [01_rerun-analysis-plan.md](../plans/01_rerun-analysis-plan.md)
- **Canonical re-run log**: `examples/epi-study/logs/rerun_028/rerun_summary.md`

## Overview

Re-ran the `examples/epi-study/` CONSORT RCT pipeline end-to-end at the current
location, verified byte-identical reproduction of all six committed target
artifacts against a Phase 2 baseline, and additionally executed the full
tidyverse/survival/mice/quarto enrichment stack that became available when
task 27 landed externally (via ~/.dotfiles task 47, commit 06c14e1). Headline
adjusted OR for `armKAT` re-asserted to match the committed value to ≥ 4
significant figures.

## Phase Outcomes

| Phase | Name | Status | Key Output |
|-------|------|--------|-----------|
| 1 | Environment Snapshot and Branch Detection | COMPLETED | Branch decision: A+B |
| 2 | Preflight Safety and Baseline Backup | COMPLETED | 6 baseline files + SHA256 |
| 3 | Base-R Pipeline Execution (Branch A) | COMPLETED | All 5 scripts exit 0 |
| 4 | Byte-Identity Verification and Headline Assertion | COMPLETED | 6/6 IDENTICAL, headline match |
| 5 | Provenance Capture | COMPLETED | sessionInfo + git commit |
| 6 | Optional Enrichment (Branch B) | COMPLETED | 4/4 enriched scripts ran |
| 7 | Re-run Summary Artifact | COMPLETED | rerun_summary.md written |

## Headline Results

**Branch A (frozen base-R, expected byte-identical)**:
- armKAT OR = **3.28721**, 95% CI [1.570, 6.885], p = **0.00161**.
- All six target files (3 raw CSVs, 1 derived CSV, 2 result tables) IDENTICAL
  to Phase 2 baseline, SHA256 verified.

**Branch B (enriched; actually ran this time)**:
- **04b tidyverse/broom**: armKAT OR 3.2872 (95% CI [1.5954, 7.0465], profile
  likelihood), p = 0.00161.
- **04c survival::coxph**: armKAT HR **0.4260** (95% CI [0.3114, 0.5826]),
  p < 1e-5. HR < 1 assertion PASS.
- **05b mice multiple imputation** (m=20, seed=20260410): pooled armKAT OR
  **3.2620** (95% CI [1.5660, 6.7947]), p = 0.00176. Deviation from complete-
  case 3.2872 = 0.77%. Within-20% assertion PASS.
- **06 quarto render**: `consort_report.qmd` → `reports/rendered/consort_report.html`,
  exit 0.

## R Stack Verification (the point of this re-run)

The Phase 1 branch probe confirmed task 27 has successfully landed:

```
tidyverse TRUE     survival TRUE      gtsummary TRUE
mice TRUE          broom TRUE         knitr TRUE         rmarkdown TRUE
```

Python enrichment stack is also present: scipy, statsmodels, sklearn, seaborn,
pyarrow all available. Quarto 1.8.26 renders HTML successfully. This is a
decisive positive result for the rWrapper rebuild.

## Deviations

1. **broom.helpers missing**: `gtsummary::tbl_regression` cannot be called;
   skipped via `requireNamespace` gate. `broom::tidy` output in the same file
   provides identical numerical content. Minor nix derivation gap; does not
   affect the re-run's scientific conclusions.
2. **Profile vs Wald CIs**: enriched tidyverse CI for armKAT upper bound is
   7.047 (profile likelihood) vs 6.885 (Wald in base-R script). Both exclude
   1.0 and differ by <3% in the upper limit; this is a methodological choice,
   not a regression.
3. **gtsummary HTML in sinked text file**: `print.tbl_summary` emits raw HTML
   when sinked; the result is visually noisy but numerically redundant with
   the broom::tidy output above it in `primary_results_tidy.txt`.

## Artifacts Created

Under `examples/epi-study/logs/rerun_028/`:
- env_snapshot.txt, 00_env_py.txt, 00_env_r.txt, branch_probe.txt, branch_decision.txt
- baseline/ (6 files + sha256sums.txt)
- 01_generate_data.log ... 05_sensitivity.log
- identity_check.txt
- session_info_r.txt, session_info_py.txt, git_commit.txt, git_status.txt
- phase6_04b_primary_tidy.log, phase6_04c_primary_survival.log,
  phase6_05b_sensitivity_mice.log, phase6_06_quarto_render.log
- rerun_summary.md (canonical)

Under `specs/028_rerun_analysis_full_r_stack/artifacts/enriched/`:
- 04b_primary_tidy.R
- 04c_primary_survival.R
- 05b_sensitivity_mice.R
- 06_consort_qmd_render.sh

Under `examples/epi-study/reports/tables/` (additive, new, not replacing):
- primary_results_tidy.txt
- cox_results.txt
- sensitivity_mice.txt

Under `examples/epi-study/reports/rendered/` (new, gitignored):
- consort_report.html

Frozen (unchanged, verified clean):
- `examples/epi-study/scripts/0[0-5]_*` (7 files)
- All 6 committed target outputs (byte-identical)

## Validation Checklist

- [x] All five base-R scripts exit 0
- [x] Six byte-identity checks pass (IDENTICAL via diff -q and SHA256)
- [x] Headline armKAT OR = 3.29 (95% CI 1.57-6.89, p = 0.0016) reasserted
- [x] env_snapshot, session_info, git_commit captured
- [x] rerun_summary.md documents branch taken and all outcomes
- [x] Branch B: pooled-mice OR within 20% of 3.29 (0.77%)
- [x] Branch B: coxph HR for KAT < 1 (0.426)
- [x] Branch B: quarto render exits 0
- [x] Frozen scripts 01-05 unchanged (git status clean)
- [x] Historical logs (env_check.txt, config_gaps.md, reproduction_check.txt) untouched

## Next Steps

Task is ready for postflight status transition. Subsequent tasks may wish to
add `broom.helpers` to the nix rWrapper derivation to enable the full
`gtsummary::tbl_regression` workflow, but this is a minor enhancement and does
not gate any downstream work.
