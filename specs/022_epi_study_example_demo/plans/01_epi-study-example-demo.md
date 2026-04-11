# Implementation Plan: Task #22

- **Task**: 22 - epi_study_example_demo
- **Status**: [IMPLEMENTING]
- **Effort**: 3-4 hours
- **Dependencies**: None (reads from task 20 artifacts)
- **Research Inputs**: specs/022_epi_study_example_demo/reports/01_epi-study-example-demo.md
- **Artifacts**: plans/01_epi-study-example-demo.md (this file)
- **Standards**: .claude/rules/artifact-formats.md, .claude/rules/plan-format-enforcement.md, .claude/context/formats/plan-format.md
- **Type**: general
- **Lean Intent**: false

## Overview

Create `zed/examples/epi-study/` as a newcomer-facing, frozen snapshot of
the synthetic ketamine-assisted therapy RCT produced by task 20, with a
polished README walkthrough of the `/epi -> /research -> /plan ->
/implement` flow. The demo ships as copies (not symlinks) of scripts,
data, logs, and the CONSORT report, plus two new newcomer-oriented
documents: `README.md` and `EPI_ANSWERS.md`. Script path portability and
RNG seed determinism are audited and fixed during implementation so the
pipeline reproduces end-to-end from a fresh checkout.

### Research Integration

The research report supplied a complete artifact disposition matrix (11
copy-verbatim, 2 copy-with-rename, 1 copy-with-light-edit, 3
reference-only, 2 new, 2 omit), the recommended flat layout, a full
README outline, the 10-question `/epi` Stage 0 flow, and 8 open
questions. This plan adopts the research recommendations wholesale and
resolves all 8 open questions in the "Open Questions Resolved" section
below.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

Checked `specs/ROADMAP.md`. This task advances the "newcomer
onboarding / executable demos" theme: it establishes the
`zed/examples/` convention with a worked example of the epidemiology
extension. No other roadmap items directly depend on this task.

## Goals & Non-Goals

**Goals**:
- Establish `zed/examples/epi-study/` as a self-contained, runnable
  demo of the task 20 synthetic RCT.
- Provide a newcomer-friendly `README.md` that walks through the full
  `/epi -> /research -> /plan -> /implement` flow with expected outputs.
- Provide an `EPI_ANSWERS.md` literal transcript of the Stage 0
  answers used to create task 20, so a new user can reproduce exactly.
- Guarantee the scripts are path-portable (relative to the example
  root) and seeded (deterministic) so results match the checked-in
  CSVs and CONSORT report.
- Link provenance back to task 20 without duplicating its research
  report, plan, or summary.

**Non-Goals**:
- Fixing the environment gaps documented in task 20's
  `config_gaps.md` (tidyverse, survival, quarto, etc.).
- Re-running the analysis with the full R/tidyverse stack.
- Adding new statistical methods or sensitivity analyses.
- Creating a `flake.nix` or per-project environment pinning.
- Rendering the `.qmd` via Quarto.
- Modifying any task 20 artifacts in place.

## Open Questions Resolved

These resolve the 8 open questions from the research report:

1. **Location**: `zed/examples/epi-study/`. Rationale: more discoverable
   than burying under the extension directory. A one-line
   cross-reference may be added from the extension README in a
   follow-up task if desired.
2. **Script path portability**: Audit every script for absolute paths
   in Phase 2; rewrite to relative paths anchored at the example
   root using `Sys.getenv` / `os.path.dirname(__file__)` patterns as
   needed. This is mandatory before the demo ships.
3. **RNG seed hygiene**: Audit `01_generate_data.py` (numpy seed) and
   `02_generate_outcomes.R` (`set.seed()`) in Phase 2. If seeds are
   missing, add them and regenerate the committed CSVs so the
   checked-in data matches a deterministic run. Document the seed
   values in the README.
4. **Commit CSVs**: Yes -- commit `data/raw/*.csv` and
   `data/derived/analytic.csv`. They are tiny (201 rows) and provide
   a reproducibility anchor. Newcomers without R can still inspect
   the analytic dataset.
5. **License / attribution**: Add a one-line "synthetic data, public
   domain / CC0, no real participants" banner at the top of the
   README and in `consort_report.md` (light edit).
6. **Cross-linking**: Add a short pointer from
   `.claude/extensions/epidemiology/README.md` (if it exists) to the
   demo in a follow-up note during Phase 5; do NOT touch
   `zed/README.md` in this task (out of scope, avoid bikeshedding
   top-level readme).
7. **`.qmd` handling**: Leave `consort_report.qmd` unrendered; copy
   verbatim as an illustrative Quarto source. README notes that
   Quarto is optional.
8. **Stage 0 transcript format**: Narrative Markdown in
   `EPI_ANSWERS.md` (primary) with a small JSON snippet appended for
   machine consumption.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Scripts use absolute paths to task 20 directory | H | M | Phase 2 explicit audit + rewrite; verification step runs scripts from a fresh cwd |
| RNG seeds missing -> demo not deterministic | M | M | Phase 2 audit; add seeds and regenerate CSVs if necessary |
| Task 20 archived/vaulted, breaking provenance links | L | L | Use copies not symlinks; README records "snapshot of task 20 as of {date}" |
| Newcomer without R packages sees base-R fallback output unexpectedly | M | H | README prominently documents the bare-R fallback and links `logs/config_gaps.md` |
| `/epi` Stage 0 flow evolves, `EPI_ANSWERS.md` goes stale | L | M | Record capture date and pin to the `.claude/commands/epi.md` revision |
| Readers mistake synthetic results for real | H | L | Prominent "synthetic data" banner at top of README and CONSORT report |
| Binary `.rds` files accidentally copied | L | L | Phase 2 uses explicit file list, not `cp -r` of `data/derived/` |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4, 5 | 2 |
| 4 | 6 | 3, 4, 5 |

Phases within the same wave can execute in parallel.

### Phase 1: Scaffold Directory Structure [COMPLETED]

**Goal**: Create the empty `zed/examples/epi-study/` tree so subsequent
phases can populate it.

**Tasks**:
- [ ] Create `zed/examples/` if it does not exist
- [ ] Create `zed/examples/epi-study/`
- [ ] Create `zed/examples/epi-study/scripts/`
- [ ] Create `zed/examples/epi-study/data/raw/`
- [ ] Create `zed/examples/epi-study/data/derived/`
- [ ] Create `zed/examples/epi-study/reports/tables/`
- [ ] Create `zed/examples/epi-study/logs/`
- [ ] Add a placeholder `.gitkeep` only if directories would otherwise
      be empty at end of phase (none should remain empty; skip unless needed)

**Timing**: 15 minutes

**Depends on**: none

**Files to modify**:
- `zed/examples/epi-study/` (new directory tree)

**Verification**:
- `ls zed/examples/epi-study/` shows 4 subdirectories: scripts, data,
  reports, logs
- `find zed/examples/epi-study -type d` lists all 7 directories

---

### Phase 2: Copy and Adapt Task 20 Artifacts [IN PROGRESS]

**Goal**: Populate the demo with scripts, data, logs, and the CONSORT
report from task 20, with path-portability and seed-hygiene fixes
applied.

**Tasks**:
- [ ] Copy 7 scripts verbatim from `specs/020_test_epi_rct_ketamine_meth/scripts/`
      to `zed/examples/epi-study/scripts/`:
      `00_check_env.py`, `00_check_env.R`, `01_generate_data.py`,
      `02_generate_outcomes.R`, `03_merge_data.py`,
      `04_primary_analysis.R`, `05_sensitivity.R`
- [ ] **Audit each script for absolute paths** referencing task 20 or
      user home. For each hit, rewrite to a relative path anchored at
      the script's own directory (Python: `os.path.dirname(__file__)`;
      R: `this.path::here()` fallback to `commandArgs()` or
      `Sys.getenv("R_SCRIPT_DIR")`). Prefer a minimal, package-free
      solution in R to respect the bare-install constraint.
- [ ] **Audit RNG seeds**: grep for `np.random.seed`, `random.seed`,
      `set.seed` in the data-generating scripts. If absent from
      `01_generate_data.py` or `02_generate_outcomes.R`, add
      `np.random.seed(2026)` and `set.seed(2026)` respectively.
- [ ] If scripts were modified (paths or seeds), re-run
      `01_generate_data.py` -> `02_generate_outcomes.R` ->
      `03_merge_data.py` to regenerate the CSVs before copying, so
      checked-in data matches a fresh deterministic run.
- [ ] Copy `data/raw/participants.csv`, `data/raw/outcomes.csv`,
      `data/raw/adverse_events.csv` to `zed/examples/epi-study/data/raw/`
- [ ] Copy `data/derived/analytic.csv` to
      `zed/examples/epi-study/data/derived/`
- [ ] **Do NOT** copy `data/derived/models/*.rds` (binary; regenerable)
- [ ] **Do NOT** copy the empty `output/` directory
- [ ] Copy `logs/00_env_check.txt` -> `zed/examples/epi-study/logs/env_check.txt`
- [ ] Copy `logs/config_gaps.md` -> `zed/examples/epi-study/logs/config_gaps.md`
      and lightly edit: change top heading to "Known Environment Gaps"
      and add a one-sentence lead-in noting this is a snapshot from
      task 20
- [ ] Copy `reports/05_consort_report.md` -> `zed/examples/epi-study/reports/consort_report.md`
      and add a one-line "synthetic data, no real participants" banner
      at the top
- [ ] Copy `reports/05_consort_report.qmd` -> `zed/examples/epi-study/reports/consort_report.qmd` verbatim
- [ ] Copy `reports/06_zed_verification_summary.md` -> `zed/examples/epi-study/reports/zed_verification_summary.md`
- [ ] Copy `reports/tables/primary_results.txt` and
      `reports/tables/sensitivity_results.txt` to
      `zed/examples/epi-study/reports/tables/`

**Timing**: 1 hour (including path/seed audit + potential regeneration)

**Depends on**: 1

**Files to modify**:
- `zed/examples/epi-study/scripts/*.py, *.R` (copy, possibly path/seed-patched)
- `zed/examples/epi-study/data/raw/*.csv` (copy)
- `zed/examples/epi-study/data/derived/analytic.csv` (copy)
- `zed/examples/epi-study/logs/env_check.txt` (copy, renamed)
- `zed/examples/epi-study/logs/config_gaps.md` (copy + light edit)
- `zed/examples/epi-study/reports/consort_report.md` (copy + banner)
- `zed/examples/epi-study/reports/consort_report.qmd` (copy)
- `zed/examples/epi-study/reports/zed_verification_summary.md` (copy)
- `zed/examples/epi-study/reports/tables/*.txt` (copy)

**Verification**:
- `find zed/examples/epi-study -type f` matches the expected file list
  from the research report layout (Section 4) -- no `.rds`, no empty
  dirs
- `grep -rnE "/(home|Users)/" zed/examples/epi-study/scripts/` returns
  no hits
- `grep -E "(set\\.seed|np\\.random\\.seed|random\\.seed)"
  zed/examples/epi-study/scripts/01_generate_data.py
  zed/examples/epi-study/scripts/02_generate_outcomes.R` returns at
  least one hit per file
- `wc -l zed/examples/epi-study/data/raw/participants.csv` equals 201

---

### Phase 3: Write README.md Walkthrough [NOT STARTED]

**Goal**: Author the primary newcomer-facing `README.md` following the
outline in Finding 5 of the research report.

**Tasks**:
- [ ] Draft `README.md` with these sections:
      synthetic-data banner, title, "What This Demo Shows",
      Prerequisites (R 4.0+ base, Python 3.10+ numpy/pandas, optional
      packages), Step 1 `/epi` invocation, Step 2 `/research`, Step 3
      `/plan`, Step 4 `/implement`, "Reproduce Directly from Scripts"
      section with the 7-script run order, "Expected Outputs",
      "Known Environment Gaps" (link to `logs/config_gaps.md`),
      "Provenance" (links to task 20 research/plan/summary),
      "Extension Points"
- [ ] Include the key task-20 result (OR 3.29, 95% CI 1.57-6.89) as
      the "you should see roughly this" anchor
- [ ] Reference `EPI_ANSWERS.md` for the exact Stage 0 answers
- [ ] Note the RNG seeds chosen in Phase 2 so readers can verify
      determinism
- [ ] Pin the `/epi` command snapshot date ("as of 2026-04-10")

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `zed/examples/epi-study/README.md` (new)

**Verification**:
- `README.md` exists and contains all 11 sections listed above
- All internal relative links (`logs/config_gaps.md`,
  `EPI_ANSWERS.md`, `reports/consort_report.md`,
  `reports/tables/primary_results.txt`) resolve to real files
- All external references to task 20 use valid
  `specs/020_test_epi_rct_ketamine_meth/...` paths

---

### Phase 4: Write EPI_ANSWERS.md Stage 0 Transcript [NOT STARTED]

**Goal**: Provide a literal transcript of the 10 Stage 0 forcing
answers used to create task 20, formatted for readability plus a JSON
appendix.

**Tasks**:
- [ ] Read task 20's `.return-meta.json` and/or state.json entry for
      any captured `forcing_data` / Stage 0 answers
- [ ] Reconstruct or cross-check the 10 answers from task 20's
      research report and plan if the state file is silent
- [ ] Write `EPI_ANSWERS.md` with a table/list format answering each
      of the 10 `/epi` Stage 0 questions (design, research_question,
      causal_structure, data_paths, descriptive_paths, prior_work,
      ethics_status, reporting_guideline, r_preferences,
      analysis_hints)
- [ ] Append a small JSON snippet with the same data for machine
      consumption
- [ ] Note at the top: "captured 2026-04-10 against
      .claude/commands/epi.md as of this snapshot"

**Timing**: 30 minutes

**Depends on**: 2

**Files to modify**:
- `zed/examples/epi-study/EPI_ANSWERS.md` (new)

**Verification**:
- File exists and contains 10 numbered answers matching the Stage 0
  question keys (0.1 through 0.10)
- JSON appendix is valid (`jq . <<< "$(extract)"` or mental parse)
- Answers are consistent with task 20's research report framing (RCT,
  CONSORT, NOT_APPLICABLE ethics, etc.)

---

### Phase 5: Provenance and Cross-References [NOT STARTED]

**Goal**: Ensure the demo has clear, unambiguous pointers back to task
20 without duplicating its research/plan/summary.

**Tasks**:
- [ ] Confirm the README "Provenance" section contains relative paths
      to all three task 20 artifacts:
      `specs/020_test_epi_rct_ketamine_meth/reports/01_epi-research.md`,
      `specs/020_test_epi_rct_ketamine_meth/plans/01_epi-rct-test-study.md`,
      `specs/020_test_epi_rct_ketamine_meth/summaries/01_epi-rct-test-study-summary.md`
- [ ] Add a one-paragraph "About this snapshot" block near the top of
      README.md noting the snapshot date and the source task number
- [ ] If `.claude/extensions/epidemiology/README.md` exists, add a
      one-line "See the worked example at
      `zed/examples/epi-study/`" pointer (optional; gracefully skip
      if file missing)

**Timing**: 20 minutes

**Depends on**: 2

**Files to modify**:
- `zed/examples/epi-study/README.md` (edit)
- `.claude/extensions/epidemiology/README.md` (optional, one-line edit)

**Verification**:
- `grep -c "020_test_epi_rct_ketamine_meth" zed/examples/epi-study/README.md`
  returns >= 3
- Snapshot date appears near top of README
- If extension README was touched, it still parses as valid Markdown

---

### Phase 6: Verification and Reproduction [NOT STARTED]

**Goal**: Prove the demo actually runs end-to-end from a fresh cwd
using only the files inside `zed/examples/epi-study/`.

**Tasks**:
- [ ] From a fresh shell, `cd zed/examples/epi-study/` and run the
      scripts in order: `python scripts/00_check_env.py`,
      `Rscript scripts/00_check_env.R`,
      `python scripts/01_generate_data.py`,
      `Rscript scripts/02_generate_outcomes.R`,
      `python scripts/03_merge_data.py`,
      `Rscript scripts/04_primary_analysis.R`,
      `Rscript scripts/05_sensitivity.R`
- [ ] Compare regenerated `data/raw/*.csv` and `data/derived/analytic.csv`
      against the committed copies (`diff`); they must match byte-for-byte
      (confirms deterministic seed)
- [ ] Compare regenerated `reports/tables/primary_results.txt` against
      the committed copy; OR must match to two decimal places
- [ ] If any diff fails: debug (seed not set, path not portable, or
      non-deterministic R code), fix in-place, re-run until green
- [ ] Run `markdownlint` or a quick manual read of `README.md` and
      `EPI_ANSWERS.md` for typos and broken links
- [ ] Write a short `logs/reproduction_check.txt` recording the
      verification run timestamp, R/Python versions, and any diffs

**Timing**: 45-60 minutes

**Depends on**: 3, 4, 5

**Files to modify**:
- `zed/examples/epi-study/logs/reproduction_check.txt` (new)
- (possibly) `zed/examples/epi-study/scripts/*` if bugs surface
- (possibly) `zed/examples/epi-study/data/**/*.csv` if regeneration
  differs from committed copy

**Verification**:
- All 7 scripts exit 0
- `diff` against committed CSVs shows no differences
- Primary result OR matches task 20 (~3.29) within rounding
- `reproduction_check.txt` is present and non-empty

---

## Testing & Validation

- [ ] Every script in `scripts/` runs successfully from
      `zed/examples/epi-study/` as cwd
- [ ] Checked-in CSVs are byte-identical to a fresh deterministic
      regeneration
- [ ] `README.md` internal links all resolve
- [ ] Task 20 provenance paths exist and are readable
- [ ] No absolute paths in any script
- [ ] No binary files (`.rds`, `.pdf`, images) accidentally committed
- [ ] Synthetic-data banner appears in both README and
      `consort_report.md`
- [ ] Primary analysis reproduces OR ~3.29 for KAT vs TAU

## Artifacts & Outputs

- `zed/examples/epi-study/README.md`
- `zed/examples/epi-study/EPI_ANSWERS.md`
- `zed/examples/epi-study/scripts/{00_check_env.py,00_check_env.R,01_generate_data.py,02_generate_outcomes.R,03_merge_data.py,04_primary_analysis.R,05_sensitivity.R}`
- `zed/examples/epi-study/data/raw/{participants,outcomes,adverse_events}.csv`
- `zed/examples/epi-study/data/derived/analytic.csv`
- `zed/examples/epi-study/reports/consort_report.md`
- `zed/examples/epi-study/reports/consort_report.qmd`
- `zed/examples/epi-study/reports/zed_verification_summary.md`
- `zed/examples/epi-study/reports/tables/{primary_results,sensitivity_results}.txt`
- `zed/examples/epi-study/logs/env_check.txt`
- `zed/examples/epi-study/logs/config_gaps.md`
- `zed/examples/epi-study/logs/reproduction_check.txt`

## Rollback/Contingency

If the demo cannot be made to reproduce deterministically within the
Phase 6 budget:

1. Mark Phase 6 `[PARTIAL]`, commit what works, and document the
   non-determinism in `README.md` under "Known Limitations" with the
   specific variance observed.
2. If a script has a hard-to-fix absolute-path dependency, revert that
   script to a stub that prints "see task 20" and document the
   limitation.
3. To fully revert: `rm -rf zed/examples/epi-study/` removes the
   entire demo. No task 20 artifacts are touched by this plan, so
   rollback is isolated.
4. If `/epi` command schema has drifted since task 20 capture,
   regenerate `EPI_ANSWERS.md` only -- other artifacts remain valid.
