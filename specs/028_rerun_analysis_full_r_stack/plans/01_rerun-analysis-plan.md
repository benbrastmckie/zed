# Implementation Plan: Re-run Epi Study Analysis at New Location

- **Task**: 28 - rerun_analysis_full_r_stack
- **Status**: [IN PROGRESS]
- **Effort**: 3.5 hours
- **Dependencies**: 27
- **Research Inputs**: specs/028_rerun_analysis_full_r_stack/reports/01_rerun-analysis-plan.md
- **Artifacts**: plans/01_rerun-analysis-plan.md
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/plan-format-enforcement.md
- **Type**: epi:study
- **Lean Intent**: false

## Overview

Re-run the CONSORT-style RCT pipeline at `examples/epi-study/` and verify byte-identical reproduction of the committed CSVs and results tables, then optionally enrich with the full tidyverse/survival/mice stack if task 27's NixOS rebuild has landed. The existing scripts use only base R, so Branch A (base-R reproducibility) is mandatory and unblocked; Branch B (enriched analyses) is a conditional phase gated on runtime package availability. Definition of done: all six target artifacts reproduce byte-identically against baseline backups, the headline adjusted OR for KAT reads 3.29 (95% CI 1.57-6.89, p = 0.0016), and a re-run summary with session info and git commit hash is written to `examples/epi-study/logs/rerun_028/`.

### Research Integration

The research report (`reports/01_rerun-analysis-plan.md`) establishes that: (a) scripts are cwd-dependent and must run from `examples/epi-study/`; (b) `04_primary_analysis.R` has a `saveRDS` footgun requiring `data/derived/models/` to exist; (c) task 22 already proved byte-identical reproduction with seed `20260410`; (d) only `00_check_env.R` calls `library()`, so the base-R pipeline runs on the pre-task-27 environment; (e) task 27 currently holds research only, so Branch B must be gated at runtime and will most likely be skipped this run.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted.

## Goals & Non-Goals

**Goals**:
- Reproduce six target artifacts byte-identically at the new location.
- Reassert the headline adjusted OR for KAT (3.29; 95% CI 1.57-6.89; p = 0.0016).
- Capture environment snapshot, session info, and git commit hash to `logs/rerun_028/`.
- Conditionally run tidyverse/survival/mice/quarto enrichment if task 27 is implemented, without modifying the frozen scripts.
- Produce `logs/rerun_028/rerun_summary.md` as the canonical artifact of this re-run.

**Non-Goals**:
- Modifying `examples/epi-study/scripts/0[1-5]_*` (frozen snapshot).
- Implementing task 27's NixOS rebuild (out of scope; separate task).
- Updating `reports/consort_report.md` or `reports/zed_verification_summary.md`.
- Adding `renv` or `targets` to the pipeline.
- Committing rendered `consort_report.html` as a diff target.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task 27 not yet implemented; full R stack unavailable | M | H | Run Branch A unconditionally; gate Branch B (Phase 6) on runtime `library()` probe; document branch taken in summary. |
| `data/derived/models/` missing -> `saveRDS` aborts | H | L | `mkdir -p data/derived/models` in Phase 2 preflight. |
| Scripts run from wrong cwd -> "file not found" | H | M | Every phase uses absolute `cd /home/benjamin/.config/zed/examples/epi-study` preamble. |
| R version drift breaks RNG byte identity | M | L | Capture `R.version$version.string` in env snapshot; if mismatch detected, document rather than chase fix. |
| Locale differences affect sinked table formatting | M | L | `export LC_ALL=C.UTF-8` at top of Phase 3. |
| Branch B partial rebuild (e.g. tidyverse without quarto) | L | M | Gate each enriched script on its specific `library()` probe; skip with logged warning. |
| Accidental overwrite of frozen historical logs (`env_check.txt`, `config_gaps.md`, `reproduction_check.txt`) | M | L | All new logs written under `logs/rerun_028/` subdirectory. |

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

Phases within the same wave can execute in parallel. Phase 6 is conditional on package availability and may be skipped.

---

### Phase 1: Environment Snapshot and Branch Detection [COMPLETED]

**Goal**: Capture a complete fingerprint of the active R/Python/Quarto environment and determine whether to run Branch A only or Branch A + B.

**Tasks**:
- [ ] `cd /home/benjamin/.config/zed/examples/epi-study`
- [ ] `mkdir -p logs/rerun_028`
- [ ] Write `logs/rerun_028/env_snapshot.txt` with `date -Iseconds`, `which R Rscript python3 quarto`, `R --version`, `python3 --version`, `quarto --version` (or "MISSING"), and `Rscript -e '.libPaths(); cat(length(installed.packages()[,"Package"]), "packages visible\n")'`.
- [ ] Run `python3 scripts/00_check_env.py 2>&1 | tee logs/rerun_028/00_env_py.txt`.
- [ ] Run `Rscript scripts/00_check_env.R 2>&1 | tee logs/rerun_028/00_env_r.txt`.
- [ ] Probe Branch B availability: `Rscript -e 'for (p in c("tidyverse","survival","gtsummary","mice","broom","knitr","rmarkdown")) cat(p, requireNamespace(p, quietly=TRUE), "\n")' | tee logs/rerun_028/branch_probe.txt`.
- [ ] Probe Python enrichment stack: `python3 -c 'import importlib; [print(m, bool(importlib.util.find_spec(m))) for m in ["scipy","statsmodels","sklearn","seaborn","pyarrow"]]' | tee -a logs/rerun_028/branch_probe.txt`.
- [ ] Record branch decision (A or A+B) in `logs/rerun_028/branch_decision.txt`.

**Timing**: 20 minutes.

**Depends on**: none.

**Files to modify**:
- `examples/epi-study/logs/rerun_028/env_snapshot.txt` (new)
- `examples/epi-study/logs/rerun_028/00_env_py.txt` (new)
- `examples/epi-study/logs/rerun_028/00_env_r.txt` (new)
- `examples/epi-study/logs/rerun_028/branch_probe.txt` (new)
- `examples/epi-study/logs/rerun_028/branch_decision.txt` (new)

**Verification**:
- `logs/rerun_028/env_snapshot.txt` exists and is non-empty.
- `branch_decision.txt` contains either "A" or "A+B".
- `00_env_r.txt` shows no aborted tryCatch blocks.

---

### Phase 2: Preflight Safety and Baseline Backup [COMPLETED]

**Goal**: Back up the six committed output artifacts so Phase 4 can diff against them, and pre-create the `data/derived/models/` directory to defuse the `saveRDS` footgun.

**Tasks**:
- [ ] `cd /home/benjamin/.config/zed/examples/epi-study`
- [ ] `mkdir -p logs/rerun_028/baseline data/derived/models`
- [ ] Copy `data/raw/participants.csv`, `data/raw/outcomes.csv`, `data/raw/adverse_events.csv`, `data/derived/analytic.csv`, `reports/tables/primary_results.txt`, `reports/tables/sensitivity_results.txt` into `logs/rerun_028/baseline/`.
- [ ] Record each baseline file's SHA256 to `logs/rerun_028/baseline/sha256sums.txt`.
- [ ] Confirm no other target outputs are deleted (verify via `ls -la` of `data/` and `reports/tables/`).

**Timing**: 10 minutes.

**Depends on**: 1.

**Files to modify**:
- `examples/epi-study/logs/rerun_028/baseline/*.csv`, `*.txt` (new)
- `examples/epi-study/logs/rerun_028/baseline/sha256sums.txt` (new)
- `examples/epi-study/data/derived/models/` (dir, ensure exists)

**Verification**:
- `ls logs/rerun_028/baseline/` shows 6 files plus `sha256sums.txt`.
- `data/derived/models/` exists.
- No committed source files modified.

---

### Phase 3: Base-R Pipeline Execution (Branch A) [COMPLETED]

**Goal**: Execute scripts 01-05 in documented order with locale pinned and all stdout/stderr tee'd into the re-run log directory.

**Tasks**:
- [ ] `cd /home/benjamin/.config/zed/examples/epi-study`
- [ ] `export LC_ALL=C.UTF-8`
- [ ] `python3 scripts/01_generate_data.py 2>&1 | tee logs/rerun_028/01_generate_data.log`
- [ ] `Rscript scripts/02_generate_outcomes.R 2>&1 | tee logs/rerun_028/02_generate_outcomes.log`
- [ ] `python3 scripts/03_merge_data.py 2>&1 | tee logs/rerun_028/03_merge_data.log`
- [ ] `Rscript scripts/04_primary_analysis.R 2>&1 | tee logs/rerun_028/04_primary_analysis.log`
- [ ] `Rscript scripts/05_sensitivity.R 2>&1 | tee logs/rerun_028/05_sensitivity.log`
- [ ] Spot-check each log for expected sentinel strings (Seed: 20260410, N: 200, 170/200, "Wrote .../analytic.csv").
- [ ] Record exit codes for each script (`echo $?` or wrap in `set -e` verification).

**Timing**: 20 minutes (mostly script runtime).

**Depends on**: 2.

**Files to modify**:
- `examples/epi-study/data/raw/participants.csv` (overwrite)
- `examples/epi-study/data/raw/outcomes.csv` (overwrite)
- `examples/epi-study/data/raw/adverse_events.csv` (overwrite)
- `examples/epi-study/data/derived/analytic.csv` (overwrite)
- `examples/epi-study/data/derived/models/*.rds` (overwrite)
- `examples/epi-study/reports/tables/primary_results.txt` (overwrite)
- `examples/epi-study/reports/tables/sensitivity_results.txt` (overwrite)
- `examples/epi-study/logs/rerun_028/*.log` (new)

**Verification**:
- All five scripts exit 0.
- Sentinel strings present in each log.
- All six target outputs refreshed (mtime after Phase 2 baseline copy).

---

### Phase 4: Byte-Identity Verification and Headline Assertion [NOT STARTED]

**Goal**: Diff the six regenerated artifacts against the Phase 2 baseline and assert the headline adjusted OR matches the committed value.

**Tasks**:
- [ ] `cd /home/benjamin/.config/zed/examples/epi-study`
- [ ] For each of the six target files, run `diff -q` against the corresponding `logs/rerun_028/baseline/` copy, teeing results to `logs/rerun_028/identity_check.txt`.
- [ ] On any `DIFFERS` result, append `diff -u | head -40` output to `identity_check.txt` for diagnosis.
- [ ] Compute and compare SHA256 of regenerated files against `logs/rerun_028/baseline/sha256sums.txt`; append to `identity_check.txt`.
- [ ] Extract and assert headline from `reports/tables/primary_results.txt`: the `armKAT` row must show OR ~= 3.287, CI 1.570-6.885, p = 0.00161. Append extraction to `identity_check.txt`.
- [ ] Fallback: if strict diff fails only on whitespace, rerun with `diff --ignore-trailing-space` and document the deviation.
- [ ] If any DIFFERS and not whitespace-only, mark task failing and stop; otherwise proceed.

**Timing**: 15 minutes.

**Depends on**: 3.

**Files to modify**:
- `examples/epi-study/logs/rerun_028/identity_check.txt` (new)

**Verification**:
- `identity_check.txt` contains six `IDENTICAL` lines.
- SHA256 comparison line shows zero mismatches.
- Headline OR matches within 1e-3.

---

### Phase 5: Provenance Capture [NOT STARTED]

**Goal**: Record the exact R/Python versions, package versions, and source commit so a future auditor can link this re-run to a reproducible environment.

**Tasks**:
- [ ] `cd /home/benjamin/.config/zed/examples/epi-study`
- [ ] `Rscript -e 'sink("logs/rerun_028/session_info_r.txt"); sessionInfo(); cat("\n\n"); print(.libPaths()); cat("\n"); for (p in c("base","stats","survival","tidyverse","mice")) try(print(tryCatch(find.package(p), error=function(e) NA))); sink()'`
- [ ] `python3 -c 'import sys, numpy, pandas; print(sys.version); print("numpy", numpy.__version__); print("pandas", pandas.__version__)' > logs/rerun_028/session_info_py.txt`
- [ ] `git -C /home/benjamin/.config/zed rev-parse HEAD > logs/rerun_028/git_commit.txt`
- [ ] `git -C /home/benjamin/.config/zed status --porcelain > logs/rerun_028/git_status.txt`

**Timing**: 10 minutes.

**Depends on**: 4.

**Files to modify**:
- `examples/epi-study/logs/rerun_028/session_info_r.txt` (new)
- `examples/epi-study/logs/rerun_028/session_info_py.txt` (new)
- `examples/epi-study/logs/rerun_028/git_commit.txt` (new)
- `examples/epi-study/logs/rerun_028/git_status.txt` (new)

**Verification**:
- `session_info_r.txt` contains `R version` line and at least one libPath.
- `git_commit.txt` contains a 40-character SHA.

---

### Phase 6: Optional Enrichment (Branch B, Conditional) [NOT STARTED]

**Goal**: If task 27 is implemented, run parallel tidyverse/survival/mice/quarto analyses under `specs/028_rerun_analysis_full_r_stack/artifacts/enriched/` without modifying the frozen `examples/epi-study/scripts/`. If the stack is unavailable, log a skip and continue.

**Tasks**:
- [ ] Check `logs/rerun_028/branch_decision.txt` from Phase 1. If "A" only, create `logs/rerun_028/phase6_skipped.txt` with rationale ("task 27 not implemented; full stack unavailable") and mark phase complete-by-skip.
- [ ] If "A+B": `mkdir -p specs/028_rerun_analysis_full_r_stack/artifacts/enriched` and create four scripts there:
  - [ ] `04b_primary_tidy.R` -- reads `examples/epi-study/data/derived/analytic.csv`; uses `gtsummary::tbl_summary`, `gtsummary::tbl_regression`, `broom::tidy(..., exponentiate=TRUE, conf.int=TRUE)`; writes `examples/epi-study/reports/tables/primary_results_tidy.txt`.
  - [ ] `04c_primary_survival.R` -- uses `survival::coxph(Surv(days_to_use, event) ~ arm + severity_stratum + age + sex + baseline_asi)` and `survival::survfit`; writes `examples/epi-study/reports/tables/cox_results.txt`.
  - [ ] `05b_sensitivity_mice.R` -- runs `mice::mice(..., m=20, seed=20260410)`, pools primary logistic with `pool()`; writes `examples/epi-study/reports/tables/sensitivity_mice.txt`.
  - [ ] `06_consort_qmd_render.sh` -- runs `quarto render examples/epi-study/reports/consort_report.qmd --to html` with output into `examples/epi-study/reports/rendered/` (add to `.gitignore` if absent).
- [ ] Gate each enriched script with a `requireNamespace` probe; skip individually if its package is missing and log to `logs/rerun_028/phase6_run.log`.
- [ ] Execute each applicable script, teeing to `logs/rerun_028/phase6_*.log`.
- [ ] Assert pooled-mice OR is within ~20% of complete-case OR (3.29) and coxph HR for `armKAT` < 1.

**Timing**: 60 minutes (mostly new code + runtime; skipped entirely on Branch A only -> 2 minutes).

**Depends on**: 4.

**Files to modify**:
- `specs/028_rerun_analysis_full_r_stack/artifacts/enriched/04b_primary_tidy.R` (new, Branch B only)
- `specs/028_rerun_analysis_full_r_stack/artifacts/enriched/04c_primary_survival.R` (new, Branch B only)
- `specs/028_rerun_analysis_full_r_stack/artifacts/enriched/05b_sensitivity_mice.R` (new, Branch B only)
- `specs/028_rerun_analysis_full_r_stack/artifacts/enriched/06_consort_qmd_render.sh` (new, Branch B only)
- `examples/epi-study/reports/tables/primary_results_tidy.txt` (new, Branch B only; additive, not diffed)
- `examples/epi-study/reports/tables/cox_results.txt` (new, Branch B only; additive)
- `examples/epi-study/reports/tables/sensitivity_mice.txt` (new, Branch B only; additive)
- `examples/epi-study/reports/rendered/consort_report.html` (new, Branch B only; gitignored)
- `examples/epi-study/logs/rerun_028/phase6_*.log` (new)
- `examples/epi-study/logs/rerun_028/phase6_skipped.txt` (new, Branch A only)

**Verification**:
- Either `phase6_skipped.txt` exists with rationale OR all enriched scripts produced output files.
- If Branch B ran: pooled-mice OR within 20% of 3.29; coxph HR < 1.
- `examples/epi-study/scripts/0[1-5]_*` are unchanged (verify via `git diff`).

---

### Phase 7: Re-run Summary Artifact [NOT STARTED]

**Goal**: Produce `logs/rerun_028/rerun_summary.md` as the canonical record of this re-run, referenced by the task 28 execution summary.

**Tasks**:
- [ ] Write `examples/epi-study/logs/rerun_028/rerun_summary.md` containing:
  - [ ] Date (ISO), session ID, git commit hash (from Phase 5).
  - [ ] Branch taken (A or A+B) and rationale.
  - [ ] Environment fingerprint (R version, Python version, Quarto version or MISSING, libPaths summary).
  - [ ] Byte-identity table: one row per target file with IDENTICAL/DIFFERS verdict.
  - [ ] Headline OR re-assertion: `armKAT` row values vs expected 3.287 / 1.570-6.885 / 0.00161.
  - [ ] Phase 6 results summary (or "skipped: rationale").
  - [ ] Any deviations, warnings, or notable observations.
  - [ ] Links to `identity_check.txt`, `session_info_r.txt`, `git_commit.txt`.
- [ ] Cross-link the summary from `specs/028_rerun_analysis_full_r_stack/` so `/implement` postflight can find it.

**Timing**: 20 minutes.

**Depends on**: 5, 6.

**Files to modify**:
- `examples/epi-study/logs/rerun_028/rerun_summary.md` (new)

**Verification**:
- `rerun_summary.md` exists and contains all seven required sections.
- Headline OR line matches expected values.
- Byte-identity table has six rows, all IDENTICAL (or deviations explicitly justified).

---

## Testing & Validation

- [ ] All five scripts (`01`-`05`) exit with code 0.
- [ ] Six byte-identity checks all pass (`diff -q` reports no differences).
- [ ] SHA256 hashes of regenerated files match baseline hashes captured in Phase 2.
- [ ] Headline adjusted OR for `armKAT` rounds to 3.29 (95% CI 1.57-6.89; p = 0.0016).
- [ ] `logs/rerun_028/env_snapshot.txt`, `session_info_r.txt`, `session_info_py.txt`, `git_commit.txt` all populated.
- [ ] `rerun_summary.md` documents branch taken and all verification outcomes.
- [ ] No files outside `logs/rerun_028/`, `data/`, `reports/tables/` are modified (unless Branch B ran, in which case `reports/tables/primary_results_tidy.txt` / `cox_results.txt` / `sensitivity_mice.txt` are additive).
- [ ] Frozen historical logs (`env_check.txt`, `config_gaps.md`, `reproduction_check.txt`) are untouched.
- [ ] If Branch B: pooled-mice OR within 20% of 3.29; coxph HR < 1 for KAT arm; `quarto render` exits 0.

## Artifacts & Outputs

Within `examples/epi-study/logs/rerun_028/`:
- `env_snapshot.txt` -- R/Python/Quarto fingerprint
- `00_env_py.txt`, `00_env_r.txt` -- probe outputs
- `branch_probe.txt`, `branch_decision.txt` -- Branch A vs A+B decision
- `baseline/` -- pre-run copies of six target artifacts + `sha256sums.txt`
- `01_generate_data.log` ... `05_sensitivity.log` -- pipeline logs
- `identity_check.txt` -- diff verdicts + SHA256 comparison + headline OR extraction
- `session_info_r.txt`, `session_info_py.txt` -- session info dumps
- `git_commit.txt`, `git_status.txt` -- source provenance
- `phase6_*.log` or `phase6_skipped.txt` -- Branch B outputs or skip record
- `rerun_summary.md` -- canonical task-28 re-run summary

Within `examples/epi-study/` (regenerated in place, byte-identical to committed):
- `data/raw/participants.csv`, `data/raw/outcomes.csv`, `data/raw/adverse_events.csv`
- `data/derived/analytic.csv`, `data/derived/models/*.rds`
- `reports/tables/primary_results.txt`, `reports/tables/sensitivity_results.txt`

Conditional (Branch B only, additive):
- `specs/028_rerun_analysis_full_r_stack/artifacts/enriched/04b_primary_tidy.R`
- `specs/028_rerun_analysis_full_r_stack/artifacts/enriched/04c_primary_survival.R`
- `specs/028_rerun_analysis_full_r_stack/artifacts/enriched/05b_sensitivity_mice.R`
- `specs/028_rerun_analysis_full_r_stack/artifacts/enriched/06_consort_qmd_render.sh`
- `examples/epi-study/reports/tables/primary_results_tidy.txt`
- `examples/epi-study/reports/tables/cox_results.txt`
- `examples/epi-study/reports/tables/sensitivity_mice.txt`
- `examples/epi-study/reports/rendered/consort_report.html` (gitignored)

## Rollback/Contingency

- **If byte identity fails**: Restore the six target files from `logs/rerun_028/baseline/` (`cp logs/rerun_028/baseline/*.csv data/raw/` etc.) and annotate `rerun_summary.md` with the observed deviation. Do NOT commit the divergent outputs. Investigate whether the divergence is (a) whitespace/locale only (use `diff --ignore-trailing-space`, document, and if acceptable proceed), (b) R version drift in RNG (capture `R.version$version.string` and treat as legitimate environmental change), or (c) a script logic bug (escalate; do not commit).
- **If a script aborts mid-pipeline**: Restore from baseline backup, capture the failure log in `rerun_summary.md`, and either fix the precondition (e.g. `mkdir -p data/derived/models`) and re-execute from Phase 3, or mark task `[PARTIAL]` and escalate.
- **If Branch B partially runs**: Discard any partial enriched outputs (they are additive and gitignored-or-task-scoped, so no rollback needed for frozen artifacts). Log the partial state in `phase6_run.log` and `rerun_summary.md`.
- **If git state is dirty before run**: Record in `git_status.txt` and proceed; dirty state does not block reproducibility verification but is noted in the summary.
