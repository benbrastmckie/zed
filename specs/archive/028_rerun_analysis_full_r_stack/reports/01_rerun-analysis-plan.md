# Research Report: Re-run Epi Study Analysis at New Location

- **Task**: 28 - rerun_analysis_full_r_stack
- **Parent Task**: 20 (test_epi_rct_ketamine_meth)
- **Depends On**: 27 (fix_task20_env_gaps)
- **Study Design**: RCT (two-arm parallel, 1:1 stratified, N=200, synthetic)
- **Reporting Guideline**: CONSORT
- **Ethics Status**: IRB_APPROVED (simulated; synthetic data)
- **Author**: epi-research-agent
- **Date**: 2026-04-10
- **Session**: sess_1775872843_e08192

## Executive Summary

The task 20 analysis has been copied into `examples/epi-study/` as a frozen runnable demo. This report plans a deterministic re-run at that new location, leveraging the richer R/Python stack that task 27 prescribes. The existing scripts were written for a bare R install (base-R-only fallbacks, no tidyverse, no `survival`, no `mice`, no Quarto) and already reproduce byte-identically with seed `20260410` when run from the `examples/epi-study/` directory as cwd. The re-run should therefore be a verification exercise first (prove identity with committed artifacts) and then an optional enrichment pass that swaps fallbacks for their proper package-backed counterparts once task 27 has actually landed its NixOS changes. The largest risk is that **task 27 is `[RESEARCHED]` but not `[IMPLEMENTED]`** -- the rWrapper.override / home.nix edits and `nixos-rebuild switch` have not been applied, so at the time of writing the "full R stack" is still planned, not present.

## Background

### Origin of the Analysis

Task 20 produced a complete, runnable CONSORT-style RCT pipeline:

- **Population**: 200 adults with methamphetamine use disorder
- **Exposure**: Ketamine-assisted therapy (KAT) vs Treatment-as-usual (TAU)
- **Primary outcome**: 12-week sustained abstinence (binary)
- **Primary model**: `glm(abstinent_12wk ~ arm + severity_stratum + age + sex + baseline_asi, family = binomial)` on complete cases
- **Secondary**: time-to-first-use (Cox fallback via base-R log-rank + Gamma-GLM), 12-week ASI linear model
- **Sensitivity**: per-protocol, single-imputation, worst/best-case bounds, severity interaction
- **Headline result**: Adjusted OR for KAT = **3.29 (95% CI 1.57-6.89, p = 0.00161)**

### The Move

The analysis has been copied (byte-for-byte) to `/home/benjamin/.config/zed/examples/epi-study/` as a pedagogical snapshot. Directory layout:

```
examples/epi-study/
├── README.md                     full walkthrough of /epi workflow
├── EPI_ANSWERS.md                literal Stage 0 answers from task 20
├── scripts/                      00_check_env -> 05_sensitivity (7 scripts)
├── data/
│   ├── raw/                      participants.csv, outcomes.csv, adverse_events.csv
│   └── derived/                  analytic.csv + models/
├── reports/
│   ├── consort_report.md         Markdown CONSORT narrative
│   ├── consort_report.qmd        Quarto source (optional render)
│   ├── zed_verification_summary.md
│   └── tables/                   primary_results.txt, sensitivity_results.txt
└── logs/
    ├── env_check.txt             task 20 environment probe
    ├── config_gaps.md            package gap inventory (feeds task 27)
    └── reproduction_check.txt    earlier re-run log (task 22, 2026-04-10)
```

### Task 27 Status (Critical Dependency)

Task 27 currently holds a **research report only** (`specs/027_fix_task20_env_gaps/reports/01_fix-env-gaps.md`). It has no plan and no implementation summary. The planned fixes:

1. Replace bare `R` + flat `rPackages.*` in `~/.dotfiles/configuration.nix` with a single `rWrapper.override { packages = [ survival MASS nlme lme4 tidyverse broom gtsummary mice knitr rmarkdown languageserver styler lintr ]; }`.
2. Append `scipy statsmodels scikit-learn seaborn pyarrow` to `python312.withPackages` in `~/.dotfiles/home.nix`.
3. Add `pkgs.quarto` to `environment.systemPackages`.
4. `sudo nixos-rebuild switch --flake ~/.dotfiles#$(hostname)`.
5. Verify via `Rscript -e 'library(tidyverse); library(survival); ...'` and `quarto check`.

**Until task 27's /implement runs, task 28 cannot claim "full R stack" -- only "base-R reproduction."** Task 28's re-run must either block on task 27 implementation or split into two passes (see Procedure below).

## Current State of the Moved Study

### Path Assumptions (Move Risk Audit)

I inspected every script for path brittleness:

| Script | Working-directory assumption | Verdict |
|--------|------------------------------|---------|
| `00_check_env.py` | none (prints info only) | Safe |
| `00_check_env.R` | none (prints info only) | Safe |
| `01_generate_data.py` | `Path(__file__).resolve().parent.parent` | **Safe -- cwd-independent** |
| `02_generate_outcomes.R` | `data/raw/participants.csv` (relative) | **Requires cwd = examples/epi-study/** |
| `03_merge_data.py` | `Path(__file__).resolve().parent.parent` | **Safe -- cwd-independent** |
| `04_primary_analysis.R` | `data/derived/analytic.csv`, writes to `reports/tables/` and `data/derived/models/` | **Requires cwd = examples/epi-study/** |
| `05_sensitivity.R` | `data/derived/analytic.csv`, writes to `reports/tables/` | **Requires cwd = examples/epi-study/** |

No script contains an absolute path. The Python scripts are cwd-safe by construction. The three R scripts all assume cwd is the project root. **This is a convention, not a bug** -- the README instructs users to `cd zed/examples/epi-study` first.

One known gotcha from the earlier reproduction (see `logs/reproduction_check.txt`): `04_primary_analysis.R` calls `saveRDS(m_primary, "data/derived/models/primary_logistic.rds")` without a `dir.create()`. The committed `data/derived/models/` directory currently exists, but a clean checkout or an accidental `rm -rf data/derived/models` breaks the run. The re-run procedure must either pre-create this directory or the implementation phase should patch the script with `dir.create("data/derived/models", recursive = TRUE, showWarnings = FALSE)`.

### Package Usage in the Existing Scripts

I `grep`'d for `library(` / `require(` in the scripts:

- **Only `00_check_env.R`** calls `library()`, and only via `library(pkg, character.only = TRUE)` inside a probe loop wrapped in `tryCatch`. Missing packages don't abort it.
- **No analysis script** calls `library(tidyverse)`, `library(survival)`, `library(mice)`, etc. Every script uses base R primitives: `read.csv`, `glm`, `lm`, `rweibull`, `rbinom`, `aggregate`, hand-rolled log-rank.
- **Python scripts** use only `numpy` and `pandas` (already present per `logs/env_check.txt`).

**Consequence**: The existing scripts will run unchanged on the pre-task-27 environment. Task 27 adds capability but does not unblock the re-run itself. This means task 28 can be executed immediately as a **pure reproducibility check**; enriching the analysis with tidyverse/survival/mice is an optional extension that only becomes possible after task 27's rebuild.

### Determinism Record (from `reproduction_check.txt`)

Task 22 already performed one re-run on 2026-04-10 and recorded:

- All three CSVs (`participants`, `outcomes`, `adverse_events`) and `analytic.csv` regenerated **byte-identically** against the committed snapshots via `diff`.
- `reports/tables/primary_results.txt` **byte-identical**.
- Headline OR = 3.287, 95% CI 1.570-6.885, p = 0.00161 -- matches to machine precision.

So the bar for task 28 is: **reproduce these same identities a second time**, optionally on an upgraded R stack.

## Re-run Procedure

### Phase 0: Preconditions

1. Confirm `pwd` points inside the repo.
2. Confirm task 27 status via `specs/state.json`. Decide branch:
   - **Branch A (recommended if task 27 NOT yet implemented)**: run a base-R-only reproducibility pass; defer the "full stack" pass.
   - **Branch B (if task 27 IS implemented)**: run both the reproducibility pass AND an optional enrichment pass that uses tidyverse/survival/mice.
3. Create a fresh log directory for this re-run's output:
   ```bash
   mkdir -p examples/epi-study/logs/rerun_028
   ```
   Avoid overwriting `env_check.txt`, `config_gaps.md`, `reproduction_check.txt` -- those are frozen snapshots.

### Phase 1: Environment Snapshot

From `/home/benjamin/.config/zed/examples/epi-study/` as cwd:

```bash
cd /home/benjamin/.config/zed/examples/epi-study

# Capture the current environment fingerprint BEFORE touching anything
{
  date -Iseconds
  echo "---"
  which R Rscript python3 quarto 2>&1
  echo "---"
  R --version 2>&1
  python3 --version 2>&1
  quarto --version 2>&1 || echo "quarto: MISSING"
  echo "---"
  Rscript -e '.libPaths(); cat(length(installed.packages()[,"Package"]), "packages visible\n")' 2>&1
} | tee logs/rerun_028/env_snapshot.txt

# Re-run the env probes and tee their output (non-destructive)
python3 scripts/00_check_env.py   2>&1 | tee logs/rerun_028/00_env_py.txt
Rscript scripts/00_check_env.R    2>&1 | tee logs/rerun_028/00_env_r.txt
```

The env snapshot is the single most important artifact of this re-run: it lets a future reader tell which branch was active (pre- or post- task 27).

### Phase 2: Preflight Safety

```bash
# Back up the committed outputs so we can compare byte-for-byte after the run
mkdir -p logs/rerun_028/baseline
cp data/raw/participants.csv      logs/rerun_028/baseline/
cp data/raw/outcomes.csv          logs/rerun_028/baseline/
cp data/raw/adverse_events.csv    logs/rerun_028/baseline/
cp data/derived/analytic.csv      logs/rerun_028/baseline/
cp reports/tables/primary_results.txt    logs/rerun_028/baseline/
cp reports/tables/sensitivity_results.txt logs/rerun_028/baseline/

# Ensure the saveRDS target dir exists (fixes the known footgun)
mkdir -p data/derived/models
```

Do NOT delete the existing outputs before the run. The whole point of the identity test is that re-running over them produces no diff.

### Phase 3: Pipeline Execution (Branch A -- base R only)

Execute in order, teeing every stdout/stderr into the rerun log:

```bash
python3 scripts/01_generate_data.py      2>&1 | tee logs/rerun_028/01_generate_data.log
Rscript  scripts/02_generate_outcomes.R  2>&1 | tee logs/rerun_028/02_generate_outcomes.log
python3  scripts/03_merge_data.py        2>&1 | tee logs/rerun_028/03_merge_data.log
Rscript  scripts/04_primary_analysis.R   2>&1 | tee logs/rerun_028/04_primary_analysis.log
Rscript  scripts/05_sensitivity.R        2>&1 | tee logs/rerun_028/05_sensitivity.log
```

Expected stdout highlights (match-to-console sanity checks):

- `01_generate_data.py`: "Seed: 20260410", "N: 200", baseline mean/SD table, arm x stratum 100/100 balance, "Wrote .../participants.csv (200 rows, 12 columns)".
- `02_generate_outcomes.R`: "Loaded 200 baseline rows", marginal abstinence lines, "Completed study: 170/200 (85%)", "Wrote data/raw/outcomes.csv with 200 rows", "Wrote data/raw/adverse_events.csv with 50 rows".
- `03_merge_data.py`: "Baseline: (200, 12)", "Outcomes: (200, 7)", "Merged: (200, 18)", arm x completed_study 2x2 with roughly 85/15 split per arm, abstinence means by arm, "Wrote .../analytic.csv".
- `04_primary_analysis.R`: writes (via `sink`) all tables to `reports/tables/primary_results.txt`; terminal shows only the wrap banners. The OR for `armKAT` in the sinked file must round to **3.29** with 95% CI **1.57-6.89** and p = **0.0016**.
- `05_sensitivity.R`: sinked table lists five rows (complete case, per-protocol, single-imp, worst-case KAT, best-case KAT); all five ORs must match the committed values in the baseline backup.

### Phase 4: Byte-Identity Verification

```bash
cd /home/benjamin/.config/zed/examples/epi-study

for f in \
  data/raw/participants.csv \
  data/raw/outcomes.csv \
  data/raw/adverse_events.csv \
  data/derived/analytic.csv \
  reports/tables/primary_results.txt \
  reports/tables/sensitivity_results.txt
do
  if diff -q "logs/rerun_028/baseline/$(basename "$f")" "$f" >/dev/null; then
    echo "IDENTICAL   $f"
  else
    echo "DIFFERS     $f"
    diff -u "logs/rerun_028/baseline/$(basename "$f")" "$f" | head -40
  fi
done | tee logs/rerun_028/identity_check.txt
```

Success criterion: every line prints `IDENTICAL`. Any `DIFFERS` line is a critical finding and must be investigated before marking the task complete.

Additionally, extract the headline OR into a stable scalar and assert it:

```bash
grep -A1 'armKAT' reports/tables/primary_results.txt | tee -a logs/rerun_028/identity_check.txt
# Expect a line whose OR column reads 3.287 (±1e-3), CI 1.570-6.885, p 0.00161
```

### Phase 5: Session Info and Provenance

```bash
Rscript -e 'sink("logs/rerun_028/session_info_r.txt"); sessionInfo(); sink()'
python3 -c 'import sys, numpy, pandas; print(sys.version); print("numpy", numpy.__version__); print("pandas", pandas.__version__)' \
  > logs/rerun_028/session_info_py.txt
git -C /home/benjamin/.config/zed rev-parse HEAD > logs/rerun_028/git_commit.txt
```

This gives a future auditor the ability to link this re-run to a specific commit and a specific set of package versions.

### Phase 6: Optional Enrichment (Branch B -- only if task 27 implemented)

**Gate**: only execute this phase if `Rscript -e 'library(tidyverse); library(survival); library(gtsummary); library(mice); cat("OK\n")'` prints `OK`. Otherwise skip.

This phase does NOT modify the committed scripts. It adds parallel scripts under a new subdirectory so the original snapshot remains byte-identical and reproducible:

```
examples/epi-study/scripts/enriched/
├── 04b_primary_tidy.R        gtsummary Table 1 + broom::tidy OR table
├── 04c_primary_survival.R    survival::coxph proper Cox model
├── 05b_sensitivity_mice.R    mice multiple imputation (m=20, pool OR)
└── 06_consort_qmd_render.sh  quarto render consort_report.qmd
```

Each enriched script:

1. `04b_primary_tidy.R` -- drop-in replacement for the Table 1 + OR section of `04_primary_analysis.R`, using `gtsummary::tbl_summary`, `gtsummary::tbl_regression`, and `broom::tidy(m_primary, exponentiate = TRUE, conf.int = TRUE)`. Writes to `reports/tables/primary_results_tidy.txt` so both outputs coexist.
2. `04c_primary_survival.R` -- replaces the hand-rolled log-rank + Gamma-GLM with `survival::coxph(Surv(days_to_use, event) ~ arm + severity_stratum + age + sex + baseline_asi)` and `survival::survfit` for Kaplan-Meier. Writes to `reports/tables/cox_results.txt`.
3. `05b_sensitivity_mice.R` -- runs `mice::mice(analytic[, mice_vars], m = 20, seed = 20260410)`, fits the primary logistic to each imputed dataset with `with()`, pools with `pool()`, and compares the pooled OR to the complete-case OR. Writes to `reports/tables/sensitivity_mice.txt`.
4. `06_consort_qmd_render.sh` -- runs `quarto render reports/consort_report.qmd` to produce `consort_report.html` (and/or PDF). The .qmd already exists; only rendering is new.

**Design constraint for enriched scripts**: they must read from `data/derived/analytic.csv` produced by Phase 3, NOT regenerate data. The determinism guarantee is over the raw/derived CSVs; the enriched outputs are additional statistical views, not replacements.

**Success criterion for Phase 6**: the enriched Cox HR for `armKAT` should be directionally consistent with the base-R exponential fallback (HR < 1, reflecting longer time to relapse on KAT), and the `mice`-pooled OR for `armKAT` should be qualitatively consistent with the complete-case OR of 3.29 (expect the pooled OR to be slightly attenuated toward the null, typical for pooling across imputed datasets).

### Phase 7: Regenerate the CONSORT Report

If Quarto is available (Branch B only):

```bash
cd /home/benjamin/.config/zed/examples/epi-study
quarto render reports/consort_report.qmd --to html 2>&1 | tee logs/rerun_028/quarto_render.log
```

If Quarto is not available (Branch A), leave `consort_report.md` unchanged -- it already contains the final numbers.

### Phase 8: Write Re-run Summary

Produce `logs/rerun_028/rerun_summary.md` containing:

- Date, session ID, git commit hash
- Branch taken (A or B)
- Environment fingerprint (R version, libPaths length, quarto version or MISSING)
- Byte-identity table from Phase 4
- Headline OR re-assertion
- Phase 6 enrichment results (if applicable)
- Any deviations or warnings

This summary is the canonical artifact that `/implement` should reference when marking task 28 complete.

## Verification Plan

### Primary Success Criteria

1. **Byte identity** of all six regenerated artifacts against the committed snapshots:
   - `data/raw/participants.csv`
   - `data/raw/outcomes.csv`
   - `data/raw/adverse_events.csv`
   - `data/derived/analytic.csv`
   - `reports/tables/primary_results.txt`
   - `reports/tables/sensitivity_results.txt`

2. **Headline reproducibility**: Adjusted OR for KAT rounds to **3.29**, 95% CI **1.57-6.89**, p = **0.0016**.

3. **Exit codes**: Every script exits with code 0. No uncaught errors in tee'd logs.

4. **Env snapshot**: `logs/rerun_028/env_snapshot.txt` exists and documents the active R/Python/Quarto versions and libPaths.

### Secondary Success Criteria (Branch B only)

5. **Full-stack package availability**: `library(tidyverse); library(survival); library(gtsummary); library(mice); library(broom); library(knitr); library(rmarkdown)` all load without error.
6. **Python scientific stack**: `import scipy, statsmodels, sklearn, seaborn, pyarrow` all succeed.
7. **Quarto**: `quarto check` passes and `quarto render reports/consort_report.qmd` exits 0 producing `consort_report.html`.
8. **Enriched analyses**: cox_results.txt and sensitivity_mice.txt are produced; pooled-mice OR is within ~20% of complete-case OR.

### Acceptable Deviations

- Trailing whitespace in Rscript output that differs due to locale changes is acceptable if the numerical contents match. Use `diff --ignore-trailing-space` as a secondary comparison if a strict diff flags only whitespace.
- Session info differences (R minor version, package versions) are expected between Branch A and Branch B and are NOT a failure.
- If `quarto render` is run, the resulting `consort_report.html` is an ADDITION, not a diff target.

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Task 27 not yet implemented; "full R stack" unavailable | **HIGH** (currently the case) | Enrichment blocked | Run Branch A (base-R reproducibility) unconditionally; treat Branch B as optional follow-up after task 27 /implement. Document the branch taken in the rerun summary. |
| `data/derived/models/` does not exist after a hypothetical clean checkout | MED | `04_primary_analysis.R` aborts at `saveRDS` | `mkdir -p data/derived/models` in Phase 2. Consider patching the script to `dir.create(..., recursive = TRUE, showWarnings = FALSE)` as a minor hardening. |
| Running scripts from the wrong cwd (e.g., from repo root) | MED | R scripts fail with "file not found" | Explicit `cd examples/epi-study` at the top of every phase; re-run procedure documents the cwd assumption. |
| R version drift between the original task 20 run (R 4.5.3) and the re-run (if host R updates) | LOW | Could change `rbinom`/`rweibull`/`sample` RNG output and break byte identity | Capture `R.version$version.string` in the env snapshot; if a mismatch is detected and byte identity fails, treat as a legitimate environmental change and document -- do not chase a spurious fix. Base-R RNG streams have been stable since R 3.6 (`Rounding`/`Rejection` default for `sample`); R 4.5.x -> 4.6.x is unlikely to change them, but is worth logging. |
| Python package drift (numpy/pandas) affecting CSV output formatting | LOW | Whitespace or float-format differences | numpy/pandas have not changed default CSV formatting in years; if a diff surfaces, inspect whether it is numerical or formatting-only and report both. |
| Locale differences altering number formatting in `print.data.frame` output inside sinked files | LOW | Could break diff on `primary_results.txt` | Set `LC_ALL=C.UTF-8` at the top of Phase 3: `export LC_ALL=C.UTF-8`. Matches the convention used in the original task 20. |
| `sessionInfo()` accidentally tee'd into a file that gets diffed | LOW | False positive on identity check | Session info is written only to `logs/rerun_028/session_info_r.txt`, which is NOT in the identity check list. |
| `mice::mice` in Branch B produces non-deterministic imputations if a different seed is used | LOW | Enriched pooled OR not reproducible | Pin `mice(..., seed = 20260410)`; capture full `sessionInfo()` for `mice` in `session_info_r.txt`. |
| Task 27 rebuild partially succeeds (e.g., tidyverse but not quarto), causing Phase 6 to half-run | LOW | Confusing partial output | Gate each enriched script individually on its required packages; skip with a logged warning if missing. |
| `rWrapper.override` installs tidyverse behind a different `.libPaths()` entry that shadows user-installed packages | LOW | Unexpected package versions used | Run `Rscript -e '.libPaths(); find.package(c("tidyverse","survival","mice"))'` as part of Phase 1 to document which library each key package resolves to. |

## Reproducibility Notes

- **Seeds**: Both the Python generator (`numpy.random.default_rng(20260410)`) and the R outcome generator (`set.seed(20260410)`) use the same numeric seed. The R primary/sensitivity scripts call `set.seed(20260410)` before any stochastic operation (currently only `05_sensitivity.R` uses randomness beyond the fitted GLMs).
- **RNG algorithm**: Default R RNG (`Mersenne-Twister`, `Inversion`, `Rejection`) as of R 3.6+. Do not change `RNGkind()`; doing so would break byte identity.
- **Renv**: Not in scope. Task 20 did not use `renv` and the current Nix environment does not have it. A follow-up task (noted in task 27) could add a per-project `flake.nix` or `renv.lock`.
- **Targets**: Not in use. The pipeline is a simple ordered list of 5 scripts; a `targets` DAG is overkill for a pedagogical demo.
- **Session info**: Always captured to `logs/rerun_028/session_info_r.txt` and `session_info_py.txt`.

## Artifacts to Regenerate (vs Preserve)

| Artifact | Regenerate? | Notes |
|----------|-------------|-------|
| `data/raw/participants.csv` | YES | Overwritten by `01_generate_data.py` |
| `data/raw/outcomes.csv` | YES | Overwritten by `02_generate_outcomes.R` |
| `data/raw/adverse_events.csv` | YES | Overwritten by `02_generate_outcomes.R` |
| `data/derived/analytic.csv` | YES | Overwritten by `03_merge_data.py` |
| `data/derived/models/*.rds` | YES | Overwritten by `04_primary_analysis.R` (binary, not diffed; covered by identity of `primary_results.txt`) |
| `reports/tables/primary_results.txt` | YES | Overwritten by `04_primary_analysis.R` |
| `reports/tables/sensitivity_results.txt` | YES | Overwritten by `05_sensitivity.R` |
| `reports/consort_report.md` | NO | Frozen narrative; update only if numerical results change |
| `reports/consort_report.qmd` | NO | Frozen source; render is optional (Branch B) |
| `reports/zed_verification_summary.md` | NO | Frozen; documents the original task 20 verification |
| `logs/env_check.txt` | NO | Historical snapshot from task 20 |
| `logs/config_gaps.md` | NO | Historical snapshot; feeds task 27 |
| `logs/reproduction_check.txt` | NO | Historical snapshot from task 22 |
| `logs/rerun_028/*` | YES (new) | Task 28's re-run log directory |

## Open Questions

1. **Scope question**: Is task 28 scoped purely to re-run the existing base-R pipeline (reproducibility verification), or does it additionally require creating the `scripts/enriched/` alternatives? The task description says "re-run the analysis with the full R/tidyverse stack once task 27 is complete," which reads as the latter -- but that is blocked on task 27's implementation. Recommended resolution: /plan should create two phases (A and B) and `/implement` executes A unconditionally and B only if task 27 is implemented.

2. **Should task 28 block on task 27 implementation?** Task 27 is currently `[RESEARCHED]` only. If task 28 requires the full stack (Branch B), it cannot proceed until task 27 is planned + implemented + rebuilt. If task 28 accepts a base-R reproduction (Branch A) as success, it can run immediately. Recommendation: proceed with Branch A as the mandatory success criterion, mark Branch B as `[PARTIAL]` pending task 27.

3. **Do we want the enriched scripts committed to `examples/epi-study/`?** The README currently says this directory is a frozen snapshot. Adding `scripts/enriched/` changes the snapshot. Option 1: commit them to `examples/epi-study/scripts/enriched/` and update the README to explain the "base vs enriched" split. Option 2: keep enriched scripts in `specs/028_rerun_analysis_full_r_stack/artifacts/` so the demo directory stays frozen. Recommendation: Option 2 to preserve the pedagogical snapshot; link from the task summary.

4. **Quarto render output location**: If `consort_report.qmd` renders successfully in Branch B, should the `.html` / `.pdf` be committed? These are derived artifacts and typically gitignored. Recommendation: render to `examples/epi-study/reports/rendered/` and add that path to `.gitignore` if not already excluded.

5. **How strict should "byte identity" be?** The earlier task 22 re-run (`reproduction_check.txt`) reported IDENTICAL via plain `diff`. Task 28 should match that bar. If Branch B produces new outputs in enriched files, those are not in scope for the identity check -- only the original six files are.

## R Package Recommendations (Branch B enrichment)

| Phase | Package | Use |
|-------|---------|-----|
| Data prep | `readr::read_csv` | Faster, typed replacement for `read.csv` |
| Data prep | `dplyr`, `tidyr` | Factor releveling, derived variable creation |
| EDA | `gtsummary::tbl_summary` | Table 1 (vs hand-rolled `aggregate` / `table`) |
| EDA | `naniar` | Missingness visualization across the 15% MCAR |
| Primary | `glm` (base) | Unchanged; already adequate |
| Primary | `broom::tidy` | Exponentiated OR table with CI and p |
| Secondary | `survival::coxph`, `survival::survfit` | Replace base-R log-rank and Gamma-GLM fallback |
| Secondary | `survminer::ggsurvplot` | Kaplan-Meier figure (new, not in original pipeline) |
| Sensitivity | `mice::mice`, `mice::pool` | Replace single-imputation with proper MI |
| Sensitivity | `EValue` | Unmeasured confounding (not relevant for RCT but documents robustness) |
| Reporting | `gtsummary::tbl_regression`, `flextable` | Publication tables inside the Quarto .qmd |
| Reporting | `quarto` (binary) + `knitr` + `rmarkdown` | Render `consort_report.qmd` to HTML/PDF |

## Summary for /plan

The `/plan` phase should produce a plan with at minimum these phases:

1. **Phase 1: Environment snapshot and preflight** (branch detection, baseline backup, `mkdir data/derived/models`).
2. **Phase 2: Base-R reproducibility re-run** (scripts 01-05 in order, tee'd logs).
3. **Phase 3: Byte-identity verification** (diff, headline OR assertion).
4. **Phase 4: Session info and provenance capture**.
5. **Phase 5 (conditional): Enriched analyses** (tidyverse Table 1, coxph, mice, quarto render). Gate on package availability at runtime; skip with a logged warning if task 27 is not yet implemented.
6. **Phase 6: Re-run summary** (`logs/rerun_028/rerun_summary.md`).

Phases 1-4 and 6 are mandatory. Phase 5 is conditional.

## References

- Task 20 research report: `specs/020_test_epi_rct_ketamine_meth/reports/01_epi-research.md`
- Task 20 implementation plan: `specs/020_test_epi_rct_ketamine_meth/plans/01_epi-rct-test-study.md`
- Task 20 summary: `specs/020_test_epi_rct_ketamine_meth/summaries/01_epi-rct-test-study-summary.md`
- Task 27 research report: `specs/027_fix_task20_env_gaps/reports/01_fix-env-gaps.md`
- Moved study README: `examples/epi-study/README.md`
- Stage 0 answers: `examples/epi-study/EPI_ANSWERS.md`
- Config gaps inventory: `examples/epi-study/logs/config_gaps.md`
- Prior reproduction log: `examples/epi-study/logs/reproduction_check.txt`
