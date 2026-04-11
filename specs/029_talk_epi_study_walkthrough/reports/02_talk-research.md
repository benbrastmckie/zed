# Talk Research Report (Round 2): The /epi Workflow — A Synthetic RCT Walkthrough

- **Task**: 29 — talk_epi_study_walkthrough
- **Talk Type**: CONFERENCE (15–20 minutes)
- **Pattern**: conference-standard (target 14 slides, range 12–18)
- **Source Materials**: Full re-review of `examples/epi-study/` after task 28 completion, plus prior report `reports/01_talk-research.md`, task 28 plan/summary/logs, and commits `4173664`, `ddd7294`, `d9e1f20`, `0750680`, `b172244`.
- **Audience**: Mixed clinical + informatics; conference format
- **Recommended duration**: 18 minutes talk + 2 minutes Q&A buffer
- **Prior report**: `specs/029_talk_epi_study_walkthrough/reports/01_talk-research.md`

---

## What's New Since Report 01

Report 01 was written against a "hostile environment" snapshot: bare-base R
with 0/13 optional packages installed, Quarto unavailable, `survival`/`mice`/
`gtsummary`/`broom` all missing, and the only reproducibility evidence a
small `reproduction_check.txt` diff. Task 28 has since completed with
**Branch A+B**: it re-ran the frozen pipeline end-to-end against the now-
available full tidyverse/survival/mice/Quarto stack (dependency task 27
landed via `~/.dotfiles` task 47, commit `06c14e1`), captured full
provenance, **and** ran an enrichment suite.

The talk can now tell a materially stronger story. Specifically, the
following are new:

1. **Byte-identical reproduction verified against the frozen baseline, with
   SHA256 receipts.** Six target files — `participants.csv`, `outcomes.csv`,
   `adverse_events.csv`, `analytic.csv`, `primary_results.txt`,
   `sensitivity_results.txt` — all IDENTICAL in both `diff -q` and
   SHA256 comparison across a fresh rerun on a *different* R stack.
   Evidence: `examples/epi-study/logs/rerun_028/identity_check.txt`.
2. **Headline re-asserted at ≥4 sig figs on the new stack.** `armKAT` row
   of `primary_results.txt` reads `OR = 3.28721, 95% CI [1.570, 6.885],
   p = 0.00161` — byte-identical to the frozen baseline. The talk no
   longer has to hedge "byte identical on re-run on the same environment";
   it can claim "byte identical across an environment upgrade".
3. **`survival::coxph` now actually runs.** Slide 10's "graceful degradation
   via log-rank + Gamma-GLM surrogate" slide gains a second act: the Cox
   model, run against the frozen `analytic.csv`, reports **HR = 0.4260
   (95% CI 0.3114–0.5826, p < 1e-5)**. The PH assumption holds
   (`cox.zph` GLOBAL p = 0.55). Kaplan-Meier medians are TAU 25.4 days
   vs KAT 40.5 days. Evidence: `reports/tables/cox_results.txt`.
4. **`mice` multiple imputation corroborates complete-case.** m = 20
   imputations, seed 20260410, pooled via `mice::pool()`:
   **pooled OR = 3.2620 (95% CI 1.5660–6.7947, p = 0.00176)**; deviation
   from the complete-case OR = 3.2872 is **0.77%**. The prior talk had
   to rely on single-imputation (3.13) and the tipping-point collapse
   (1.29) alone; now the robustness story gains a proper pooled MI.
   Evidence: `reports/tables/sensitivity_mice.txt`.
5. **`broom::tidy` profile-likelihood CI** for the primary model is
   `1.5954–7.0465` vs Wald `1.570–6.885`. Point estimate matches to
   4 sig figs. Evidence: `reports/tables/primary_results_tidy.txt`.
6. **Quarto HTML render succeeds.** `quarto render reports/consort_report.qmd
   --to html` exits 0, producing `reports/rendered/consort_report.html`
   and supporting `consort_report_files/`. The report is now a real
   publication-quality CONSORT document, not a hand-authored Markdown
   mirror. Quarto 1.8.26 on R 4.5.3 / Python 3.12.13 / NixOS 26.05.
7. **Full provenance capture.** `env_snapshot.txt`, `session_info_r.txt`,
   `session_info_py.txt`, `git_commit.txt`, `git_status.txt`, per-phase
   log files, a `branch_probe.txt` and `branch_decision.txt`, plus
   SHA256 baselines under `baseline/sha256sums.txt`. The talk can now
   point to a single directory — `logs/rerun_028/` — as an auditable
   environment fingerprint.
8. **The workflow is now self-referential.** Task 28 *itself* exercised
   the `/epi → /research → /plan → /implement` loop on a task that
   re-ran the pipeline from a prior round. The talk can mention this
   as "the extension regenerated its own re-run plan", an on-brand
   meta-point for the tooling thread.

### Slide-level impact

| Slide | Change vs Report 01 |
|---|---|
| 1–3 | No content change. |
| 4   | Optional: mention that task 28's `01_rerun-analysis-plan.md` was itself produced by the same four-command loop. |
| 5   | No content change. |
| 6   | Add row: "06 quarto render" producing `rendered/consort_report.html`. |
| 7   | No content change. |
| 8   | Mention Quarto render now lands; CONSORT flow rendered natively. |
| 9   | Headline OR re-asserted across stack upgrade (strengthens confidence without changing the number). |
| 10  | **Major rewrite**: the Cox model now exists. Replace "what ran instead" panel with a before/after: base-R log-rank fallback (prior snapshot) vs `coxph` HR 0.426 (new stack). Keep the fallback as the "graceful degradation" story. |
| 11  | **Add MICE row**: pooled OR 3.262 (0.77% from complete-case). Keeps the tipping-point row as the honesty anchor; MICE now sits between single-imputation and tipping-point. |
| 12  | **Major rewrite**: "Hostile environment" scoreboard replaced with a **two-snapshot diff**. Snapshot A = bare base-R (prior). Snapshot B = full stack (task 28). Headline: byte-identical across the environment upgrade. Add SHA256 receipts. |
| 13  | Remove limitations that no longer apply: "no Cox", "no MICE", "no Quarto", "no R LSP" (partial — still check). Keep "synthetic data" and "scale / renv pinning" limitations. |
| 14  | Update "what's next": renv lockfile, `broom.helpers` install, `flake.nix` pinning, CI loop that re-runs the pipeline on every commit and checks SHA256. |

Net result: slide count stays at 14; slide content gets tighter, more
confident, and gains two new numerical anchors (HR 0.426, pooled MI
OR 3.262). The tooling/reproducibility thread gets the biggest lift.

---

## Executive Summary

This is a **tooling/workflow showcase** framed around a fully synthetic
RCT. The `/epi` Claude Code extension turns one natural-language prompt
plus ten forcing questions into a reproducible, CONSORT-compliant analysis
pipeline. Task 28's re-run has now demonstrated that the pipeline's
headline finding survives both (a) a hostile bare-base R environment and
(b) a full tidyverse/survival/mice/Quarto upgrade, **byte-identically**.

**Three key messages** (each gets roughly one-third of the talk):

1. **The `/epi` workflow compresses a week of scaffolding into four
   commands.** `/epi → /research → /plan → /implement` produced the
   research report, phased plan, Python + R scripts, CONSORT `.qmd`,
   and sensitivity tables from a single forcing-question session.
   Task 28 then re-ran the *same* loop on the re-run itself.

2. **CONSORT rigor and robustness are enforced, not bolted on.** Pre-
   specified primary model: `abstinent_12wk ~ arm + severity_stratum
   + age + sex + baseline_asi`. **Headline: OR = 3.29 (95% CI 1.57–6.89,
   p = 0.0016).** Robustness suite — now including `survival::coxph`
   HR 0.426 (p < 1e-5) and a pooled `mice` OR 3.262 — all corroborate.
   Tipping-point worst case collapses to OR 1.29, which the talk uses
   as the honesty anchor.

3. **Reproducibility is a property of the code, not a promise.** Task 28
   re-ran the frozen scripts against the upgraded stack and produced
   SHA256-identical artifacts. The talk can now claim "byte-identical
   across an environment upgrade", with `identity_check.txt` and
   `baseline/sha256sums.txt` as receipts.

---

## Audience Analysis

(Unchanged from Report 01. Mixed clinical + informatics governs every
slide; tooling and methods threads interleave so neither audience
disengages for more than ~90 seconds; acronyms defined inline on first
use; the synthetic-data caveat appears on slides 1, 7, 9, and 13.)

---

## Source Material Synthesis — New/Updated Files

Files that **did not exist** or were empty at the time of Report 01:

| File | Role in talk | Key content |
|---|---|---|
| `reports/consort_report.qmd` | Slide 8 — the real CONSORT source | Quarto document with YAML header, dynamic R code chunks reading from `data/derived/analytic.csv` and the saved `.rds` models; now renders to HTML |
| `reports/rendered/consort_report.html` | Slide 8/12 — publication-quality render | Exit 0 on Quarto 1.8.26; supporting `consort_report_files/` with bootstrap + quarto-html JS/CSS |
| `reports/tables/cox_results.txt` | Slide 10 — the Cox panel replacement | `coxph` fit, armKAT HR 0.4260 [0.3114, 0.5826], p < 1e-5; `cox.zph` GLOBAL p = 0.55; KM medians TAU 25.4 vs KAT 40.5 days |
| `reports/tables/primary_results_tidy.txt` | Slide 9 footnote | `broom::tidy(exponentiate=TRUE, conf.int=TRUE)` output; armKAT OR 3.2872 [1.5954, 7.0465] profile-likelihood; noisy `gtsummary::tbl_summary` HTML block |
| `reports/tables/sensitivity_mice.txt` | Slide 11 — new MICE row | `mice(m=20, seed=20260410)` + `pool()`; pooled armKAT OR 3.2620 [1.5660, 6.7947], p = 0.00176; 0.77% deviation; "within-20% assertion PASS" |
| `logs/rerun_028/rerun_summary.md` | Slide 12 backup content | Full re-run provenance, branch decision, headline re-assertion, deviations (broom.helpers missing, Wald vs profile CIs) |
| `logs/rerun_028/identity_check.txt` | Slide 12 receipts panel | 6/6 IDENTICAL diff lines, "SHA256: all match", grepped headline OR line |
| `logs/rerun_028/baseline/sha256sums.txt` | Slide 12 receipts panel | Pre-run SHA256 baseline for all six target files |
| `logs/rerun_028/session_info_r.txt` | Backup slide material | R 4.5.3 sessionInfo dump, .libPaths enumerating ~165 nix store entries |
| `logs/rerun_028/session_info_py.txt` | Backup slide material | Python 3.12.13, numpy 2.4.2, pandas 2.3.3, scipy 1.17.1, statsmodels 0.14.6 |
| `logs/rerun_028/env_snapshot.txt` | Backup slide material | `which` results, version strings, Quarto 1.8.26, NixOS 26.05 Yarara |
| `logs/rerun_028/branch_probe.txt` | Slide 12 contrast | Per-package `requireNamespace`/`find_spec` results — all 13 previously-missing R packages now TRUE (except `broom.helpers`) |
| `logs/rerun_028/branch_decision.txt` | Narrative anchor | Single line: "A+B" |
| `logs/rerun_028/phase6_*.log` | Backup slide material | Per-enrichment-script run logs (tidy primary, coxph, mice, quarto render) |
| `specs/028_rerun_analysis_full_r_stack/summaries/01_rerun-analysis-plan-summary.md` | Meta-slide 4 material | Evidence that task 28 itself went through `/research → /plan → /implement`, useful for the "self-referential workflow" hook |

Files reviewed in Report 01 and unchanged (reconfirmed on re-inspection):
README.md, EPI_ANSWERS.md, all 7 scripts, `data/raw/*.csv`,
`data/derived/analytic.csv`, `reports/consort_report.md`,
`reports/tables/primary_results.txt`, `reports/tables/sensitivity_results.txt`,
`reports/zed_verification_summary.md`, `logs/config_gaps.md`,
`logs/env_check.txt`, `logs/reproduction_check.txt`.

---

## Recommended Narrative Arc (Refined)

Same three acts as Report 01. The Act III reproducibility climax is now
stronger because slides 10, 11, and 12 all gain new numerical content.
Recommended pacing adjustment: give slide 12 an extra ~15 seconds for
the two-snapshot diff panel, and trim slide 6 by ~10 seconds (the
pipeline anatomy is more familiar in the CONSORT+Quarto era).

---

## Slide Map (Updated)

Only slides with content changes vs Report 01 are reproduced in full.
Slides 1, 2, 3, 5, 7, 13 (mostly), 14 (mostly) are unchanged — see
Report 01 for their content; the Delta column flags adjustments.

### Slide 1: Title & Synthetic-Data Caveat

**Delta**: No change. Optional: small date stamp updated to "re-verified
2026-04-10 (task 28)".

### Slide 2: Motivation — The Scaffolding Tax

**Delta**: No change.

### Slide 3: The Four-Command Workflow

**Delta**: No change.

### Slide 4: `/epi` Stage 0 — Forcing Questions Are the Feature

**Delta**: Add a small footer callout: *"Task 28 ran this same loop on
itself to produce the re-run plan — the workflow is self-referential."*
Speaker note: "This isn't a toy example — the extension regenerated its
own re-run plan when the R stack was upgraded, and it landed byte-
identical results. I'll show you the receipts on slide 12."

### Slide 5: The Study Design That Fell Out (PICO + DAG)

**Delta**: No change.

### Slide 6: Pipeline Anatomy — Python ↔ R Handoff

**Delta**: Add a final row to the script table:

| # | Script | Lang | Input | Output |
|---|---|---|---|---|
| 06 | quarto render | Quarto | consort_report.qmd | reports/rendered/consort_report.html |

And update the callout: "CSV is the lingua franca; Quarto is the report
substrate." Speaker note update: "Step 6 — new in the enriched re-run —
is a Quarto render producing a real HTML CONSORT report with dynamic
code chunks reading from the saved `.rds` models. Exit zero, takes under
two seconds."

### Slide 7: The Data-Generating Process (Honesty Slide)

**Delta**: No change.

### Slide 8: CONSORT Flow & Table 1

**Delta**: Update the Table 1 footnote from "Base R aggregation;
`gtsummary` not installed" to: *"Rendered via Quarto from
`consort_report.qmd`. `gtsummary::tbl_summary` output included; base-R
aggregate retained as fallback anchor."* Optional: show a small thumbnail
of the rendered `consort_report.html` in the bottom-right corner of the
slide, with caption "Live document — dynamic R chunks read `.rds` models".

### Slide 9: Primary Result — Adjusted Logistic Regression

**Delta**: No change to the large number. Add a small tertiary strip
below the p-value: *"Re-asserted across stack upgrade (task 28,
2026-04-10): byte-identical. Tidyverse/broom profile-likelihood CI
1.595–7.047 agrees to 4 sig figs."* Speaker note addendum: "This
number survived an environment upgrade. Same seed, same scripts,
different R stack — `diff -q` reports IDENTICAL and SHA256 hashes match.
That's not a rerun; that's a *reproduction*."

### Slide 10: Cox Now Runs — Before and After Graceful Degradation

**Delta**: **Major rewrite.** Replace the two-panel "what you'd write vs
what ran" layout with a before/after strip, then the new Cox panel.

**Content**:

- **Band 1 — Before (prior talk / hostile environment)**:
  > `library(survival)` unavailable. The implementation agent shipped a
  > hand-written Mantel-Cox log-rank in ~20 lines of base R plus a
  > Gamma-family GLM surrogate. Result: log-rank χ² = 26.5, p ≈ 0;
  > exp-GLM HR ≈ 0.61.

- **Band 2 — After (task 28 re-run on upgraded stack)**:
  ```r
  library(survival)
  fit <- coxph(Surv(days_to_use, event) ~ arm + severity_stratum +
                age + sex + baseline_asi, data = dat)
  cox.zph(fit)        # GLOBAL p = 0.55  (PH assumption holds)
  ```
  **Headline: HR = 0.426 (95% CI 0.311–0.583, p < 1e-5).**
  Kaplan-Meier medians: TAU **25.4 days**, KAT **40.5 days**.

- **Caption**: *"Graceful degradation was never the point — it was
  insurance. When the environment improved, the pipeline simply ran
  `coxph` and the hand-written fallback was retired to a backup slide.
  Both answers agree directionally (HR well under 1)."*

**Speaker notes**:
> "Here's the punchline for the R users who laughed at the base-R
> Mantel-Cox on the prior slide. When task 28 re-ran the pipeline on
> the upgraded stack, `survival::coxph` was available, so it ran. And
> it reports a hazard ratio of 0.426 — meaning KAT participants have
> about 57% lower hazard of first relapse compared to TAU, with
> proportional-hazards assumption cleanly satisfied. The earlier
> hand-written log-rank gave the same directional answer. Graceful
> degradation was never meant to be permanent; it was meant to keep
> the CONSORT analysis running until the environment caught up."

### Slide 11: Sensitivity Suite — MICE Row Added

**Delta**: Replace the sensitivity table with an expanded version
including the pooled MICE row, placed between single-imputation and
worst-case:

| Analysis | n | OR (KAT vs TAU) | 95% CI | p |
|---|---|---|---|---|
| Complete-case (primary) | 170 | **3.29** | 1.57 – 6.89 | 0.0016 |
| Per-protocol (≥4/6 sessions) | 125 | 2.52 | 1.04 – 6.13 | 0.041 |
| Single-imputation (mode) | 200 | 3.13 | 1.55 – 6.33 | 0.0015 |
| **MICE pooled (m = 20)** *new* | 200 | **3.26** | 1.57 – 6.79 | 0.0018 |
| **Worst-case for KAT** | 200 | **1.29** | 0.69 – 2.42 | 0.425 |
| Best-case for KAT | 200 | 5.88 | 2.90 – 11.91 | < 0.001 |

- Arm × severity interaction LRT: p = 0.7725 (unchanged).
- **Callout on MICE row**: *"Proper multiple imputation: 20 chains,
  pooled via Rubin's rules. 0.77% deviation from complete case."*
- **Callout on worst-case row** (unchanged): *"Tipping point: extreme
  informative dropout collapses the effect."*

**Speaker notes**:
> "Report the MICE row next. Twenty multiple imputations, seed
> 20260410, pooled via Rubin's rules with `mice::pool()`. The pooled
> odds ratio is 3.26, within 0.8% of the complete-case estimate.
> Single-imputation and MICE agree. Per-protocol is a little lower
> but still significant. And the tipping-point worst case still
> collapses to 1.29 — that's the honesty anchor. The extension
> generated this whole suite from the Stage 0 `analysis_hints`
> field. MICE only landed after task 27 installed `mice`; task 28
> re-ran the pipeline to pick it up."

### Slide 12: Byte-Identical Across an Environment Upgrade

**Delta**: **Major rewrite.** Replace the verification scoreboard with
a two-snapshot diff panel. This is now the strongest slide of the talk.

**Content**:

**Two columns — snapshot comparison**:

| Dimension | Snapshot A (task 20, hostile) | Snapshot B (task 28, full stack) |
|---|---|---|
| R version | 4.5.3 | 4.5.3 |
| R library packages attached | base only | base + tidyverse + survival + mice + broom + knitr + rmarkdown |
| `survival::coxph` available | NO | YES |
| `mice` available | NO | YES |
| Quarto | NOT INSTALLED | 1.8.26 |
| Python scientific stack | numpy/pandas only | numpy/pandas/scipy/statsmodels/sklearn/seaborn |
| Pipeline result: `primary_results.txt` | OR 3.29 | **IDENTICAL (SHA256 match)** |
| Pipeline result: `analytic.csv` | 200 × 21 rows | **IDENTICAL (SHA256 match)** |

**Bottom strip — the receipts** (verbatim from `identity_check.txt`):
```
=== diff -q per file ===
IDENTICAL: data/raw/participants.csv
IDENTICAL: data/raw/outcomes.csv
IDENTICAL: data/raw/adverse_events.csv
IDENTICAL: data/derived/analytic.csv
IDENTICAL: reports/tables/primary_results.txt
IDENTICAL: reports/tables/sensitivity_results.txt

=== SHA256 comparison ===
SHA256: all match

=== Headline OR assertion ===
armKAT   1.19004   0.37724   3.155   0.00161 **
         armKAT    3.28721   1.57e+00   6.885   0.00161
```

**Large caption**: *"Same scripts. Same seed. Different R stack. Byte-
identical outputs. This is reproducibility as a property of the code,
not a promise from the environment."*

**Speaker notes**:
> "Here is the slide I wish more methods talks had. On the left:
> the pipeline running on bare-base R with zero optional packages —
> the hostile environment from the original task 20 snapshot. On the
> right: the same pipeline after task 27 landed the full tidyverse
> stack and we re-ran it under task 28. Different R library entirely.
> Different Python library. Quarto now available. *Every one of the
> six target files is byte-identical.* The SHA256 hashes match. The
> headline OR of 3.29 re-asserts to four significant figures. That's
> what 'deterministic seed plus pinned inputs' buys you. The receipt
> at the bottom is verbatim from `logs/rerun_028/identity_check.txt`
> — you can clone the repo and reproduce it yourself."

### Slide 13: Limitations & What's Synthetic

**Delta**: Shrink the limitations list. Old items that **no longer
apply** and should be removed:
- ~~"No Cox model"~~ — `coxph` now runs.
- ~~"No multiple imputation"~~ — MICE m=20 runs.
- ~~"No Quarto render"~~ — HTML render succeeds.

Items that **remain**:
1. **Synthetic data** — effect sizes pre-specified by DGP on slide 7. *Not a clinical finding.*
2. **Scale** — toy demo; real studies need renv lockfiles, `targets`,
   `flake.nix` pinning, a real IRB.
3. **No preregistration** — simulated IRB approval.
4. **`broom.helpers` still missing** — `gtsummary::tbl_regression`
   skipped via `requireNamespace` gate; `broom::tidy` covers the same
   numeric content. Minor nix derivation gap.
5. **Wald vs profile-likelihood CIs** — primary uses Wald (6.885);
   `broom::tidy` profile-likelihood reports 7.047. Methodological
   difference, not a regression.

Speaker note: "Three limitations from the original talk are now
retired — task 28 added Cox, MICE, and a working Quarto render.
Two new minor footnotes: `broom.helpers` is the last missing R
package, and there's a small Wald-vs-profile CI difference in the
upper bound that doesn't change any conclusion."

### Slide 14: Takeaways & What's Next

**Delta**: Retune the takeaways and the "what's next" list.

**Three takeaways** (mirroring the executive summary):

1. **One prompt → CONSORT-compliant scaffold, including Quarto render.**
2. **Pre-specification is enforced by construction, and robustness is
   too**: every sensitivity scenario the forcing questions asked for
   ran automatically.
3. **Reproducibility survives environment upgrades.** Bare-base R to
   full tidyverse — byte-identical outputs, SHA256-verified, across
   a fresh stack.

**What's next** (updated):
- **Install `broom.helpers`** to unlock `gtsummary::tbl_regression` and
  retire the last conditional gate.
- **renv lockfile** on `examples/epi-study/` so the repro claim is
  tooled, not narrative.
- **`flake.nix`** per project, pinning the exact nix store paths
  captured in `session_info_r.txt` / `session_info_py.txt`.
- **CI loop** that re-runs the pipeline on every commit and fails if
  any SHA256 drifts.
- **Try `/epi` on your own study**: `EPI_ANSWERS.md` is a fork-ready
  template.

**Footer**: "Everything in this talk is at `examples/epi-study/`.
Receipts at `logs/rerun_028/`."

---

## Suggested Theme

**Recommendation unchanged: `academic-clean`**, with the same amber
caveat banner and Py/R/Quarto language badges. Quarto badges are a
new addition for slides 6, 8, and 12.

---

## Risks / Things to Foreground (Updated)

1. **Synthetic-data risk** remains #1. Mitigations unchanged: amber
   banner on 1, 7, 9, 13; explicit speaker-note cue; slide 7 shows
   the DGP.
2. **Cox HR 0.426 may get misquoted as "KAT reduces relapse risk by
   57%" without the synthetic caveat.** Add a small "(synthetic DGP
   — slide 7)" strap line to slide 10.
3. **"Byte-identical across an environment upgrade" is a subtle
   claim.** Informatics audience will understand it immediately;
   clinicians may need the speaker-note sentence "same scripts, same
   seed, different R stack, same bytes out" verbatim.
4. **Time budget still 17.5 minutes** at 14 × 75 seconds. Slide 12's
   two-snapshot diff deserves 90 seconds; steal 15 from slide 6
   (pipeline anatomy is now better supported by slide 12, so slide 6
   can be faster).
5. **Do not attempt live `/epi`**; same as Report 01. The pre-recorded
   screencap option is more compelling now because task 28 provides
   a second loop iteration to point at.
6. **Cox + MICE together may tempt a clinician to believe this is real
   evidence.** Slide 13's first bullet must remain the loudest thing
   on the slide.

---

## Open Questions (same as Report 01)

Unresolved — carry forward to `/slides 29 --design`:

1. Target venue / audience specifics.
2. Time budget: firm 15 or 20 minutes.
3. Speaker identity / affiliation / Anthropic acknowledgment.
4. Live-demo appetite (30-second pre-recorded screencap on slide 4?).
5. Backup Q&A slides — candidates now include:
   - `rerun_summary.md` verbatim as a backup scoreboard
   - `cox_results.txt` full output with `cox.zph` diagnostics
   - `sensitivity_mice.txt` full MICE pooled table
   - `session_info_r.txt` / `session_info_py.txt` environment dumps
   - Wald vs profile-likelihood explainer
6. Slidev Vue components: FigurePanel, StatResult, FlowDiagram,
   DataTable — all apply. Add a new CodeDiff component for slide 10
   (before/after bands).
7. Figure assets: Mermaid strongly preferred for CONSORT flow and DAG
   so they render natively in Slidev. The rendered Quarto HTML provides
   an alternate source if the speaker wants a screenshot instead.
8. Caveat banner wording.

---

## Content Gaps

None. Task 28's outputs comprehensively fill every new slide content
slot. The only "gaps" are the speaker/venue/design questions deferred
to `/slides 29 --design`.

---

## Key Messages (for metadata)

1. The `/epi` workflow compresses scaffolding for a CONSORT-compliant
   RCT into four commands with pre-specification enforced by Stage 0
   forcing questions, and it is **self-referential** — task 28 re-ran
   the same loop on the pipeline itself.
2. Headline recovered-effect OR = 3.29 (95% CI 1.57–6.89) is now
   corroborated by `survival::coxph` HR 0.426 (p < 1e-5, PH holds) and
   pooled `mice` OR 3.262 (0.77% deviation from complete-case), while
   the tipping-point worst case still collapses to 1.29 — honesty baked
   into the pipeline.
3. **Byte-identical reproducibility across an environment upgrade**
   (bare-base R → full tidyverse/survival/mice/Quarto stack) with
   SHA256 receipts — reproducibility is a property of the generated
   code, verifiable by `diff -q` and `sha256sum`.
