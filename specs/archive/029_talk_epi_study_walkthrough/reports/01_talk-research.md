# Talk Research Report: The /epi Workflow — A Synthetic RCT Walkthrough

- **Task**: 29 — talk_epi_study_walkthrough
- **Talk Type**: CONFERENCE (15–20 minutes)
- **Pattern**: conference-standard (target 14 slides, range 12–18)
- **Source Materials**: Complete systematic review of `/home/benjamin/.config/zed/examples/epi-study/` (README.md, EPI_ANSWERS.md, 7 scripts, 4 CSVs, consort_report.md, 2 results tables, zed_verification_summary.md, 3 log files)
- **Audience**: Mixed clinical + informatics; conference format
- **Recommended duration**: 18 minutes talk + 2 minutes Q&A buffer

---

## Executive Summary

This is a **tooling/workflow showcase** framed around a completely synthetic RCT. The goal is not to persuade clinicians of a ketamine effect; it is to show how the Claude Code `/epi` extension turns a single natural-language prompt into a fully reproducible, CONSORT-compliant analysis pipeline — in an environment where almost every "standard" R package is missing.

**Three key messages** (each gets roughly one-third of talk time):

1. **The `/epi` workflow compresses a week of scaffolding into four commands.** `/epi` → `/research` → `/plan` → `/implement` took a single forcing-question session and produced research report, phased plan, Python + R scripts, CONSORT report, and sensitivity tables — all committed, all reproducible from a single seed (`20260410`).

2. **CONSORT rigor is enforced by the extension, not bolted on.** The `/epi` Stage 0 forcing questions capture design, PICO, causal structure, ethics, reporting guideline, and analysis hints *before* any code is written. The resulting analysis has a pre-specified primary model, pre-specified sensitivity analyses (per-protocol, single-imputation, tipping-point), and a baked-in CONSORT flow diagram. Headline result: adjusted **OR = 3.29 (95% CI 1.57–6.89, p = 0.0016)** for 12-week abstinence, with a tipping-point worst-case of OR = 1.29 that honestly communicates fragility.

3. **Reproducibility survives a hostile environment.** The demo ran on NixOS with bare-base R (0/13 of `tidyverse`, `survival`, `gtsummary`, `broom`, `mice`, `knitr`, `rmarkdown`, `languageserver`, `styler`, `lintr` available), no Quarto, and no scipy/statsmodels in Python. Every script degrades gracefully to base-R and numpy/pandas fallbacks. A fresh-checkout rerun produces **byte-identical** CSVs and results tables.

---

## Audience Analysis

**Mixed clinical + informatics** — this is the governing constraint on every slide.

| Sub-audience | What they care about | What to give them | What loses them |
|---|---|---|---|
| Clinicians / epidemiologists | Study design validity, CONSORT rigor, effect size, uncertainty, confounding, robustness | DAG, Table 1, OR with CI, sensitivity forest, CONSORT flow | Scrolling terminal transcripts, nix config, LSP settings |
| Informatics / data engineers | Workflow automation, reproducibility, failure modes, tooling integration | Command sequence, forcing-question JSON, seed → byte-identical claim, graceful degradation story | Clinical jargon without definitions (PICO, ASI), SUD epidemiology |

**Design implications**:
- Every "tooling" slide must be followed (or preceded) by a "methods" slide so neither audience disengages for more than ~90 seconds.
- Define acronyms on first use in a subtle label: ASI = Addiction Severity Index; KAT = ketamine-assisted therapy; TAU = treatment-as-usual; SUD = substance use disorder; MUD = methamphetamine use disorder.
- The synthetic-data caveat must appear on slide 1 **and** be revisited at the results slide so neither audience walks away misremembering the finding as real clinical evidence.

---

## Source Material Synthesis

What each file in `zed/examples/epi-study/` contributes to the talk:

| File | Role in talk | Key content |
|---|---|---|
| `README.md` | Frames the whole talk arc; confirms the four-step workflow and headline OR = 3.29 | "Snapshot of task 20", deterministic seed 20260410, four-step command sequence, "minimum-viable epi pipeline" |
| `EPI_ANSWERS.md` | **Critical** — shows the Stage 0 forcing-question structure. This is the "money slide" for the tooling thread | 10 forcing questions: design, research_question (PICO), causal_structure, data_paths, descriptive_paths, prior_work, ethics_status, reporting_guideline, r_preferences, analysis_hints. JSON appendix |
| `scripts/00_check_env.{py,R}` | Opens the "hostile environment" subthread | Probes for tidyverse, survival, gtsummary, mice, quarto; writes env_check.txt |
| `scripts/01_generate_data.py` | Python side: stratified randomization, baseline covariates | Seed 20260410, N=200, stratified 1:1 by ASI tertile, numpy + pandas only |
| `scripts/02_generate_outcomes.R` | R side: the data-generating process; makes the synthetic-data caveat concrete | logit(p) = -1.10 + 0.95·KAT − 1.50·ASI − 0.02·age − 0.30·prior, Weibull time-to-relapse, 15% MCAR dropout |
| `scripts/03_merge_data.py` | Cross-language CSV handoff | Produces analytic.csv (200×21) |
| `scripts/04_primary_analysis.R` | Primary logistic regression + base-R Cox fallback | Hand-written Mantel-Cox log-rank function, Gamma-GLM as Cox surrogate, linear regression on 12wk ASI |
| `scripts/05_sensitivity.R` | Sensitivity suite (base R) | Per-protocol, single-imputation, tipping-point worst/best case, arm×severity interaction LRT |
| `data/raw/participants.csv` | 201 lines (header + 200 participants); evidence of determinism | Sample rows: P0001 TAU Mid age 35, P0003 KAT Low age 43 |
| `data/derived/analytic.csv` | Merged analytic set, 200 × 21 | Variables include abstinent_12wk, asi_12wk, days_to_use, event, sessions_attended, completed_study, per_protocol |
| `reports/consort_report.md` | Primary source for CONSORT flow + Table 1 + results narrative | CONSORT flow (200 → 100/100 → 85/85 complete), Table 1 skeleton, KAT 42.4% vs TAU 22.4%, adjusted OR = 3.29 |
| `reports/tables/primary_results.txt` | **Exact numbers to quote** | armKAT logit coef 1.190 (SE 0.377, z = 3.155, p = 0.00161), OR 3.287 [1.57, 6.885]; linear ASI β_arm = −0.100, p = 1.19e-10; log-rank χ² = 26.5, p ≈ 0 |
| `reports/tables/sensitivity_results.txt` | The honesty slide | CC 3.29, PP 2.52, single-imp 3.13, worst-case 1.29, best-case 5.88; interaction LRT p = 0.7725 |
| `reports/zed_verification_summary.md` | The "hostile environment" scoreboard | 4 pass / 1 partial / 4 fail / 1 unknown across 10 test points; remediation list |
| `logs/config_gaps.md` | Depth material for the reproducibility thread | tidyverse/survival/gtsummary/mice/quarto all missing; nix remediation snippets |
| `logs/env_check.txt` | Evidence: 0/13 R packages available | Bare-base R 4.5.3 on NixOS |
| `logs/reproduction_check.txt` | The "byte-identical" claim with evidence | diff against committed snapshots: IDENTICAL for participants.csv, outcomes.csv, adverse_events.csv, analytic.csv, primary_results.txt |

---

## Recommended Narrative Arc

A three-act structure, ~6 minutes each, interleaving the tooling and methods threads:

**Act I — Setup (slides 1–4, ~4 min)**. Frame as tooling talk. State the synthetic-data caveat up front and often. Motivate: "what if a single prompt could scaffold a CONSORT-compliant RCT analysis?" Introduce the four-command workflow.

**Act II — The pipeline (slides 5–9, ~7 min)**. Walk through `/epi` Stage 0 forcing questions, show the study design that fell out, then show the data-generating process (this is where clinicians get a DAG + randomization scheme, and where informatics people see Python → R handoff). End Act II on the primary result slide.

**Act III — Rigor & honesty (slides 10–14, ~6 min)**. Sensitivity analyses including the worst-case collapse to OR 1.29 (models honesty), hostile-environment reproducibility (byte-identical rerun on bare R), limitations, and takeaways.

This arc lets you close on reproducibility/tooling rather than a clinical claim — important because the data are synthetic.

---

## Slide Map

### Slide 1: Title & Synthetic-Data Caveat

**Template**: `title/title-basic.md` (customized with prominent caveat banner)
**Status**: mapped

**Content**:
- Title: **The /epi Workflow: Scaffolding a CONSORT-Compliant RCT in Four Commands**
- Subtitle: *A Claude Code extension walkthrough using a synthetic ketamine-assisted therapy trial*
- Author / affiliation
- **Prominent banner** (red or amber, not a footer): `SYNTHETIC DATA — no real participants. Released as CC0. Do not cite clinically.`
- Small caption: "Task 20, 2026-04-10, N=200, deterministic seed 20260410"

**Speaker notes**:
> "Before I say anything else: every number you're about to see is fabricated. This is a tooling talk. We built a synthetic RCT so we could stress-test Claude Code's `/epi` extension end-to-end, and I'm going to walk you through what it produced. The clinical 'finding' is an artifact of a data-generating process I'll show you explicitly on slide 7. Please don't tweet OR 3.29."

**Why this matters**: Establishes honesty up front; neither audience can walk away confused.

---

### Slide 2: Motivation — The Scaffolding Tax

**Template**: `title/motivation.md`
**Status**: mapped

**Content**:
- The pain: every new epi study repeats the same scaffolding — PICO, DAG, analysis plan, CONSORT checklist, environment setup, data generation, models, sensitivity, report
- Typical cost: ~1 week of an epidemiologist's time before the first model runs
- The question: **what if one prompt could scaffold it all, with CONSORT built in?**
- Tease: "Four commands. One seed. Byte-identical reruns."

**Speaker notes**:
> "Raise your hand if you've ever spent three days setting up a project structure before writing a line of analysis code. Now keep it up if your analysis plan was still accidentally out of sync with your code by the end. That's the problem."

---

### Slide 3: The Four-Command Workflow

**Template**: `methods/workflow-diagram.md` (FlowDiagram component)
**Status**: mapped

**Content**: Horizontal flow with commands as nodes:

```
/epi "description"
      ↓
  Stage 0: 10 forcing questions
      ↓
/research N    →  epi-research-agent  →  01_epi-research.md (PICO, DAG, analysis plan, CONSORT checklist)
      ↓
/plan N        →  planner-agent       →  01_implementation-plan.md (phased)
      ↓
/implement N   →  epi-implement-agent →  scripts/, data/, reports/, commits
      ↓
  [COMPLETED]
```

- Label each agent with its model (opus for research/plan)
- Note: "Each command is a gate: preflight → delegate → postflight → commit"

**Speaker notes**:
> "This is the whole talk in one slide. `/epi` creates the task with ten forcing questions. `/research` produces the study design report. `/plan` produces a phased implementation plan. `/implement` writes the scripts and runs them. Each step is a separate agent. Each step commits. The pipeline is resumable if anything breaks."

---

### Slide 4: `/epi` Stage 0 — Forcing Questions Are the Feature

**Template**: `methods/config-highlight.md`
**Status**: mapped

**Content**: Two-column layout.
- **Left**: the invocation
  ```
  /epi "Simple test RCT on fake data to verify
        R and Python are configured correctly"
  ```
- **Right**: the 10 forcing questions (compact list)
  1. design → `RCT`
  2. research_question → PICO sentence
  3. causal_structure → exposure/outcome/confounders
  4. data_paths → `will be generated`
  5. descriptive_paths → N, cols, variables
  6. prior_work
  7. ethics_status → `IRB_APPROVED (simulated)`
  8. reporting_guideline → `CONSORT`
  9. r_preferences → base R
  10. analysis_hints → primary/secondary/sensitivity

- Callout: "These aren't niceties — they're the lock that forces pre-specification."

**Speaker notes**:
> "This is the slide the informatics people came for, and it's also the slide that makes epidemiologists happy. Before any code exists, the user has to answer ten questions that map directly onto CONSORT. You can't *not* pre-specify your primary analysis, because Stage 0 won't let you proceed without it. The answers end up in `EPI_ANSWERS.md` as a machine-readable JSON appendix, which the agents downstream read verbatim."

---

### Slide 5: The Study Design That Fell Out (PICO + DAG)

**Template**: `methods/study-design.md` (FigurePanel with DAG)
**Status**: mapped

**Content**:
- **PICO box**:
  - **P**: Adults 18–65 with methamphetamine use disorder
  - **I**: Ketamine-assisted therapy (KAT, 6 sessions over 12 weeks)
  - **C**: Therapy-as-usual (TAU)
  - **O**: 12-week sustained abstinence (binary)
- **Causal DAG** (simple):
  ```
  [Arm: KAT vs TAU] ───► [Abstinence_12wk]
         ▲
         │ (randomized — no confounding arrow)
  [Severity, Age, Sex, Baseline ASI] ──► (precision covariates only)
  ```
- Caption: "Randomized exposure → no confounders by design. Baseline covariates used for precision, not confounding control. 1:1 stratified by ASI tertile."

**Speaker notes**:
> "For the clinicians: this is a standard 1:1 stratified RCT with complete-case primary analysis and adjustment for precision. For the informatics folks: notice the causal DAG is trivial because randomization does the work — but the extension still forced us to declare it. That's the point."

---

### Slide 6: Pipeline Anatomy — Python ↔ R Handoff

**Template**: `methods/pipeline-diagram.md`
**Status**: mapped

**Content**: Seven-script pipeline with language badges:

| # | Script | Lang | Input | Output |
|---|---|---|---|---|
| 00 | check_env | Py + R | — | env_check.txt |
| 01 | generate_data | Py | seed 20260410 | participants.csv (200×11) |
| 02 | generate_outcomes | R | participants.csv | outcomes.csv (200×7), adverse_events.csv (50×4) |
| 03 | merge_data | Py | raw/*.csv | analytic.csv (200×21) |
| 04 | primary_analysis | R | analytic.csv | primary_results.txt, .rds models |
| 05 | sensitivity | R | analytic.csv | sensitivity_results.txt |

- Callout: "CSV is the lingua franca. Python writes → R reads → Python merges → R analyzes. No special configuration."

**Speaker notes**:
> "Cross-language handoff in epi is usually a nightmare. Here, CSV with UTF-8 defaults just works. Python generates covariates because numpy has great RNGs; R generates outcomes because the data-generating process was easier to write in R; Python merges because pandas is better at joins; R analyzes because that's where GLM lives. Every file is deterministic from seed 20260410."

---

### Slide 7: The Data-Generating Process (Honesty Slide)

**Template**: `results/data-generation.md` (code block + effect annotation)
**Status**: mapped

**Content**: Show the actual DGP from `02_generate_outcomes.R`:

```r
# Logit data-generating process (02_generate_outcomes.R)
lin <- -1.10 + 0.95 * arm_kat \
       - 1.50 * asi_c \
       - 0.02 * age_c \
       - 0.30 * prior_treatment
p_abstinent <- 1 / (1 + exp(-lin))
abstinent_12wk <- rbinom(n, 1, p_abstinent)

# Weibull time-to-relapse: shape = 1.3,
# scale = 55 (KAT) vs 35 (TAU), adjusted for ASI
# Administrative censor at 84 days.

# 15% MCAR dropout on 12-week outcomes
```

- Annotation: "The KAT effect (0.95 on logit) corresponds to roughly OR ≈ 2.6 *marginally* — the adjusted model recovers 3.29 because covariates sharpen the estimate."
- Bold: **This is the effect the model is recovering. There is no clinical claim here.**

**Speaker notes**:
> "I want to show you the actual data-generating process so you can't accuse me of hiding anything. KAT adds 0.95 to the logit; ASI shrinks it; age shrinks it slightly. Abstinence is Bernoulli on that logit. Time-to-relapse is Weibull with different scales by arm. Fifteen percent MCAR dropout. This is the ground truth. Our primary analysis is a logistic regression trying to recover the arm coefficient. The fact that it succeeds isn't surprising — the interesting question is whether the pipeline's plumbing, CONSORT report, and sensitivity suite are all internally consistent."

---

### Slide 8: CONSORT Flow & Table 1

**Template**: `results/consort-flow.md` + table component
**Status**: mapped

**Content**:
- **Left**: CONSORT flow diagram
  ```
  Enrolled: 200
       │
  Randomized (stratified 1:1, ASI tertile)
       ├─ KAT: 100 ─► Completed 12wk: 85   Lost to FU: 15
       └─ TAU: 100 ─► Completed 12wk: 85   Lost to FU: 15
  ```
- **Right**: Table 1 (complete case n = 170), using exact numbers from `primary_results.txt`:

| Characteristic | KAT (n = 85) | TAU (n = 85) |
|---|---|---|
| Age, mean (SD) | 35.3 (8.4) | 35.4 (6.8) |
| Baseline ASI, mean (SD) | 0.544 (0.222) | 0.509 (0.210) |
| Sex: Male / Female | 50 / 35 | 56 / 29 |
| Severity Low / Mid / High | 14 / 43 / 28 | 17 / 41 / 27 |
| Prior treatment (yes) | 40 | 50 |

- Footnote: "Base R aggregation; `gtsummary` not installed in this environment."

**Speaker notes**:
> "Arms are balanced on everything measurable. Complete-case n is 170 after 15% dropout per arm. For the informatics crowd, note: this Table 1 was written by base-R `aggregate()` calls because `gtsummary` wasn't available. The extension degraded gracefully."

---

### Slide 9: Primary Result — Adjusted Logistic Regression

**Template**: `results/primary-result.md` (StatResult component — large central number)
**Status**: mapped

**Content**:
- **Huge centered**:
  ```
  Adjusted OR = 3.29
  (95% CI 1.57 – 6.89)
  p = 0.0016
  ```
- **Model**: `abstinent_12wk ~ arm + severity_stratum + age + sex + baseline_asi`
- **Observed abstinence**: KAT 42.4% (36/85) vs TAU 22.4% (19/85)
- **Secondary**: time-to-relapse log-rank χ² = 26.5, p < 0.001; exponential-GLM HR ≈ 0.61 (Cox fallback)
- **Continuous secondary**: 12-wk ASI β_arm = −0.100, p = 1.2e-10
- Small caveat strip at bottom: *synthetic data — recovers pre-specified DGP from slide 7*

**Speaker notes**:
> "Here's the headline. Adjusted odds ratio of 3.29 for 12-week abstinence in the KAT arm — the confidence interval excludes 1 cleanly, p is a hair under 0.002. Clinically meaningful if this were real. The secondary time-to-relapse analysis agrees directionally. The continuous ASI analysis agrees too. All three models were pre-specified in Stage 0. But remember: we baked the effect into the DGP. The real question is coming up on slide 11."

---

### Slide 10: The Cox Fallback — Graceful Degradation in Action

**Template**: `methods/code-highlight.md`
**Status**: mapped

**Content**: Side-by-side.
- **Left**: "What you'd normally write"
  ```r
  library(survival)
  coxph(Surv(days_to_use, event) ~ arm +
        severity_stratum + age + sex + baseline_asi,
        data = dat)
  ```
- **Right**: "What ran on this environment"
  ```r
  # survival::coxph unavailable — handwritten log-rank
  log_rank_test <- function(time, event, group) {
    # ... Mantel-Cox implementation in pure base R ...
  }
  # + exponential GLM as parametric Cox surrogate
  glm(days_to_use ~ arm + ...,
      family = Gamma(link = "log"))
  ```
- Result: **log-rank χ² = 26.5, p ≈ 0; exp-GLM HR ≈ 0.61**
- Caption: "Zero of thirteen optional R packages available. Pipeline ran anyway."

**Speaker notes**:
> "This is the slide that always gets a laugh from the R users. The `survival` package — which ships with base R on almost every distribution — wasn't installed. So the implementation agent wrote a Mantel-Cox log-rank test by hand in twenty lines of base R, and used a Gamma-family GLM on the censored time as a parametric Cox surrogate. The two approaches agree. This is what I mean by graceful degradation: the plan was pre-specified, the environment was hostile, and the output is still CONSORT-compliant."

---

### Slide 11: Sensitivity Suite — Forcing the Pipeline to Be Honest

**Template**: `results/sensitivity-forest.md`
**Status**: mapped

**Content**: Horizontal forest-style plot (or table rendered as forest), exact numbers from `sensitivity_results.txt`:

| Analysis | n | OR (KAT vs TAU) | 95% CI | p |
|---|---|---|---|---|
| Complete-case (primary) | 170 | **3.29** | 1.57 – 6.89 | 0.0016 |
| Per-protocol (≥4/6 sessions) | 125 | 2.52 | 1.04 – 6.13 | 0.041 |
| Single-imputation (mode) | 200 | 3.13 | 1.55 – 6.33 | 0.0015 |
| **Worst-case for KAT** | 200 | **1.29** | 0.69 – 2.42 | 0.425 |
| Best-case for KAT | 200 | 5.88 | 2.90 – 11.91 | < 0.001 |

- Arm × severity interaction LRT: p = 0.7725 (no effect modification)
- **Callout bubble on worst-case row**: "Tipping point: extreme informative dropout collapses the effect."

**Speaker notes**:
> "This is the most important slide in the talk, and the reason I wrote it this way. The primary complete-case OR is 3.29. Per-protocol — dropping anyone with fewer than four sessions — shrinks it to 2.52 but stays significant. Single-imputation agrees. Then the tipping-point analysis: if every dropout in the KAT arm was actually a failure and every dropout in the TAU arm was actually a success, the OR collapses to 1.29 with p 0.42. **That's not a bug; that's the feature.** The extension generated this sensitivity automatically because `analysis_hints` in Stage 0 said "per-protocol, complete-case vs imputation, severity interaction". The tipping-point was a bonus the implement agent added to honestly communicate the fragility of a complete-case analysis."

---

### Slide 12: Hostile Environment, Byte-Identical Reproducibility

**Template**: `methods/environment-scoreboard.md`
**Status**: mapped

**Content**: Two panels.

**Top — the scoreboard** (from `zed_verification_summary.md`):

| # | Test point | Result |
|---|---|---|
| 1 | R resolvable | PASS |
| 2 | Python resolvable | PASS |
| 3 | R contributed packages (tidyverse, survival, gtsummary, broom, mice) | **FAIL — 0/13** |
| 4 | Python scientific stack | PARTIAL (numpy/pandas/matplotlib ok; scipy/statsmodels/sklearn missing) |
| 5 | Quarto | **FAIL** |
| 6 | R LSP (languageserver) | FAIL |
| 7 | R formatter / linter | FAIL |
| 8 | Python LSP | UNKNOWN |
| 9 | Cross-language CSV handoff (UTF-8) | PASS |
| 10 | End-to-end pipeline from Zed terminal | **PASS** |

**Bottom — the determinism claim** (from `logs/reproduction_check.txt`):
```
Fresh checkout, seed 20260410, diff against committed:
  data/raw/participants.csv         IDENTICAL
  data/raw/outcomes.csv             IDENTICAL
  data/raw/adverse_events.csv       IDENTICAL
  data/derived/analytic.csv         IDENTICAL
  reports/tables/primary_results.txt IDENTICAL
```

- Caption: "4 pass / 1 partial / 4 fail / 1 unknown — and the pipeline still produces byte-identical artifacts on re-run."

**Speaker notes**:
> "Here's the environment the pipeline actually ran in. Four out of ten checks fail. Zero out of thirteen optional R packages are installed. Quarto isn't installed. The R LSP isn't installed. And yet — every CSV, every results table, is byte-for-byte identical across re-runs. Seed 20260410, both sides. Reproducibility is not a promise from the extension; it's a property of the generated code, because the forcing questions asked for it."

---

### Slide 13: Limitations & What's Synthetic

**Template**: `discussion/limitations.md`
**Status**: mapped

**Content**: Explicit limitations list:

1. **Synthetic data** — effect sizes are pre-specified by the DGP on slide 7. *Not a clinical finding.*
2. **No Cox model** — `survival` unavailable; log-rank + exponential GLM used as surrogate.
3. **No multiple imputation** — `mice` unavailable; mean/mode single-imputation used. Tipping-point shows fragility.
4. **No Quarto render** — CONSORT report is hand-authored Markdown with pre-computed numbers.
5. **No R LSP** — Zed is effectively a text editor for `.R` files until `languageserver` is installed.
6. **Scale** — this demo is a toy. Real studies need renv, targets, flake.nix pinning, and a real IRB.
7. **No preregistration** — simulated IRB approval; treat as `NOT_APPLICABLE`.

**Speaker notes**:
> "I want to be absolutely clear about what this is and isn't. It's a toolchain demonstration. It is not — under any circumstances — evidence about ketamine for methamphetamine use disorder. The real KAT-for-SUD literature has far more nuance and far less effect. If you take one thing from this slide, take the first bullet."

---

### Slide 14: Takeaways & What's Next

**Template**: `conclusions/takeaways.md`
**Status**: mapped

**Content**: Three takeaways mirroring the executive summary:

1. **One prompt → CONSORT-compliant scaffold.** Four commands (`/epi → /research → /plan → /implement`) produced the entire pipeline from a single forcing-question session.

2. **Pre-specification is enforced by construction.** Stage 0's 10 forcing questions make you declare design, PICO, causal structure, ethics, reporting guideline, and analysis hints *before* any code is written. CONSORT rigor becomes the default, not a discipline.

3. **Reproducibility survives hostile environments.** Bare-base R, no tidyverse, no survival, no Quarto — byte-identical re-runs from seed `20260410`, all fallbacks baked into the generated scripts.

**What's next**:
- Swap `coxph` back in once `survival` is installed
- Add `mice` multiple imputation as `06_mice.R`
- Replace base-R Table 1 with `gtsummary`
- Per-project `flake.nix` for pinned environments
- Try `/epi` on your own study: `EPI_ANSWERS.md` is a fork-ready template

**Footer**: Repository path + "Everything in this talk: `zed/examples/epi-study/`"

**Speaker notes**:
> "If you want to try this yourself, clone the repo, open `EPI_ANSWERS.md`, edit the ten answers for your study, and run `/epi`. The extension will do the rest. Questions?"

---

## Suggested Theme

**Recommendation: `academic-clean`**, with two small customizations:

1. **Caveat banner**: Amber/warning-colored strip on slides 1, 7, 9, and 13 for the synthetic-data warning. Do not use red (reads as error/alarm); amber reads as "advisory, please read".
2. **Language badges**: Small pill-shaped badges (Py / R) next to code on slides 6, 7, 10.

Why not `clinical-teal`?
- Teal reads as "real clinical" and fights the synthetic-data framing. The audience is half-informatics — academic-clean is neutral between both halves.

Why not `conference-bold`?
- Too visually loud for a mixed-audience methods talk. The content is already carrying the narrative; the theme should stay out of the way.

---

## Risks / Things to Foreground

1. **The synthetic-data risk is the #1 thing to manage.** A clinician photographing slide 9 and tweeting "OR 3.29 for ketamine + MUD" without the caveat is the nightmare scenario. Mitigations:
   - Caveat banner on slide 1, slide 7 (DGP), slide 9 (primary result), and slide 13 (limitations)
   - Speaker-note cue on slide 1: "please don't tweet OR 3.29"
   - Slide 7 shows the exact DGP so any clinician in the audience can see where the effect came from

2. **Tooling narcolepsy for clinicians.** If slides 3, 4, 6 run back-to-back the clinicians disengage. The arc interleaves tooling and methods — do not reorder.

3. **Methods overload for informatics.** Slides 5 and 8 have clinical jargon (PICO, ASI, CONSORT). Define acronyms subtly on first use.

4. **Time budget.** 14 slides × ~75 seconds = 17.5 min. Leaves ~2 min Q&A buffer in a 20-min slot. If the talk is firmly 15 min, consider merging slide 5 and slide 8 (study design + CONSORT flow on one slide) and dropping slide 12 to a single-panel version.

5. **Live demo temptation.** Do not attempt `/epi` live — the forcing-question flow is interactive and the rendering of outputs takes minutes. Use the frozen snapshot.

6. **Cox fallback may confuse survival analysts.** Slide 10 needs the speaker to explicitly say "exponential GLM with log link approximates a hazard-ratio interpretation, it is not a Cox model" — otherwise a survival analyst in the audience will correctly object.

---

## Open Questions for `/slides 29 --design`

These should be resolved before implementation:

1. **Target venue / audience specifics** — is this a named conference? A lab meeting framed as a conference talk? The tone of slide 1 depends on the answer.

2. **Time budget confirmation** — firm 15 min or 20 min? Drives whether slide 12 gets the full scoreboard or a compressed version, and whether to merge slides 5+8.

3. **Speaker identity on title slide** — single author, lab affiliation, acknowledgment of Claude Code / Anthropic?

4. **Live-demo appetite** — genuinely no live demo? Or a 30-second pre-recorded screencap of `/epi` Stage 0 on slide 4?

5. **Q&A backup slides** — would the speaker want backup slides for predictable questions? Candidates:
   - Full `EPI_ANSWERS.md` JSON appendix
   - Log-rank function source code (base R Mantel-Cox)
   - Full Table 1 with all covariates
   - Cost/time comparison: "how long would this take manually?"
   - Contrast with ChatGPT Data Analyst / other tools

6. **Slidev format** — render as Slidev markdown with Vue components (FigurePanel, StatResult, FlowDiagram, DataTable)? Or simpler Markdown-only output?

7. **Figure assets** — does the speaker want the CONSORT flow and DAG as proper SVG/Mermaid diagrams, or are ASCII boxes acceptable? Strong preference for Mermaid so they render natively in Slidev.

8. **Caveat banner wording** — does "SYNTHETIC DATA — no real participants. Do not cite clinically." land correctly, or should it be longer/shorter?

---

## Content Gaps

None — the source directory was comprehensive enough to fully populate all 14 slides. The only "gap" is speaker identity + venue context, which is deliberately deferred to `/slides 29 --design`.

---

## Key Messages (for metadata)

1. The `/epi` workflow compresses scaffolding for a CONSORT-compliant RCT into four commands with pre-specification enforced by Stage 0 forcing questions.
2. Headline recovered-effect OR = 3.29 (95% CI 1.57–6.89) is robust to per-protocol and single-imputation sensitivity but collapses to 1.29 under a worst-case tipping-point — honesty baked into the pipeline.
3. Byte-identical reproducibility on a hostile bare-base R environment (0/13 optional packages) proves reproducibility is a property of the generated code, not a promise from the extension.
