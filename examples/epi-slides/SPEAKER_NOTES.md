# Speaker Notes -- The /epi Workflow Talk

This is a consolidated, read-through view of every slide's speaker notes.
The authoritative copy lives inline in `slides.md` under each slide's
`<!-- ... -->` block -- keep both in sync if you edit.

## Slide 1: Title & Synthetic-Data Caveat (70s)

Welcome. Before any content, one disclaimer that will repeat on five
slides: every number in this talk comes from a synthetic data-generating
process. The study is a demo -- a toy RCT -- built to showcase a Claude
Code workflow called `/epi`, not to report clinical evidence. The point
is the tooling, the reproducibility, and the pre-specified methods. Say
it once here; I'll remind you on slides 7, 9, 10, and 13 where the
numbers get loudest. Date stamp: re-verified 2026-04-10 under task 28
after an R stack upgrade.

## Slide 2: Motivation -- The Scaffolding Tax (70s)

This talk is not about statistics. It is about the tax we pay before
statistics. The week of scaffolding that eats motivation, buries
pre-specification, and makes six-month reproducibility a fiction. I want
to show you what a workflow looks like when that tax is near zero, using
a four-command Claude Code loop on a synthetic RCT. Keep the word
"scaffolding" in your head -- we come back to it on the final slide.

## Slide 3: The Four-Command Workflow (70s)

Four commands. `/epi` asks ten forcing questions -- these are the
feature, not a chore, and I'll come back to that on the next slide.
`/research` writes the literature + methods report. `/plan` phases it
into verifiable chunks. `/implement` writes the Python and R and Quarto
source and runs them. The dotted feedback arrow is the self-referential
bit: when task 28 had to re-run the same pipeline under a new R stack,
it fed the re-run itself through the same loop. We'll see the receipts
on slide 12.

## Slide 4: `/epi` Stage 0 -- Forcing Questions Are the Feature (70s)

These questions are the feature. Everything downstream -- the CONSORT
report, the MICE sensitivity, the tipping-point analysis -- exists
because a forcing question asked for it at Stage 0. Pre-specification
is not a document; it is a side-effect of answering questions you
cannot skip. And the self-referential point: when task 28 re-ran this
whole pipeline on a fresh R stack, the re-run itself went through
`/epi -> /research -> /plan -> /implement`. The workflow regenerated
its own re-run. I will show you the receipts on slide 12.

## Slide 5: Study Design (PICO + DAG) (70s)

Here is the PICO and the DAG that fell out of the forcing questions.
Severity stratum is both a confounder and a randomization stratum;
baseline ASI captures dependence severity. The model is pre-specified:
arm plus four covariates, logistic link, complete-case primary with a
pre-declared sensitivity suite. No decisions are being made here now;
every choice on this slide was locked at Stage 0.

## Slide 6: Pipeline Anatomy -- Py/R/Quarto Handoff (60s, TRIMMED)

Six steps. Python generates, R analyzes, Quarto renders. CSV is the
lingua franca between languages; Quarto is the report substrate. Step
6 -- new in the task-28 enriched re-run -- is a Quarto render producing
a publication-quality HTML CONSORT report with dynamic R chunks reading
the saved `.rds` models. Exit zero, under two seconds. Trim this slide
if running long; slide 12 does a lot of the heavy lifting for step 6.

## Slide 7: The Data-Generating Process (Honesty) (70s)

Honesty slide. Before the big OR, this is the DGP. The effect you are
about to see -- OR ~ 3.3 -- is a property of the +1.2 coefficient in the
logit, plus MAR missingness, plus a fixed seed. Nothing more. If a
clinician comes up afterward excited about KAT, point them back to this
slide. Amber banner stays up.

## Slide 8: CONSORT Flow & Table 1 (70s)

Standard CONSORT flow: 240 screened, 200 randomized 1:1 stratified by
severity, 85 per arm analyzed complete-case. Table 1 footnote notes the
new Quarto render -- that thumbnail bottom-right links to the live HTML
report with dynamic R chunks reading the saved `.rds` models. The
base-R aggregate that ran under the hostile environment is retained as
a fallback; nothing gets deleted when better tooling lands.

## Slide 9: Primary Result -- OR 3.29 (70s)

This is the headline. Adjusted odds ratio of 12-week abstinence, KAT
vs TAU, complete-case primary: 3.29, 95% CI 1.57 to 6.89, p = 0.0016.
The small strip at the bottom is the new thing since the last time I
gave this talk: this number survived an environment upgrade. Same
seed, same scripts, different R stack -- `diff -q` reports IDENTICAL
and SHA256 hashes match. That is not a rerun; that is a reproduction.
Profile-likelihood CI from `broom::tidy` agrees to four significant
figures. Amber banner up. Synthetic.

## Slide 10: Cox Now Runs (80s)

Here is the punchline for the R users who laughed at the base-R
Mantel-Cox on the prior slide. When task 28 re-ran the pipeline on the
upgraded stack, `survival::coxph` was available, so it ran. Hazard
ratio of 0.426 -- KAT participants have about 57 percent lower hazard
of first relapse compared to TAU, with the proportional-hazards
assumption cleanly satisfied, global `cox.zph` p = 0.55. The earlier
hand-written log-rank gave the same directional answer. Graceful
degradation was never meant to be permanent; it was meant to keep the
CONSORT analysis running until the environment caught up. And
loud-amber-banner reminder: the 57 percent is a property of the
synthetic DGP on slide 7.

## Slide 11: Sensitivity Suite -- MICE Row (80s)

MICE row next. Twenty multiple imputations, seed 20260410, pooled via
Rubin's rules with `mice::pool`. Pooled odds ratio is 3.26, within 0.8
percent of the complete-case estimate. Single-imputation and MICE
agree. Per-protocol is a little lower but still significant. And the
tipping-point worst case still collapses to 1.29 -- that is the honesty
anchor. The whole suite was generated from the Stage 0 `analysis_hints`
field. MICE only landed after task 27 installed the package; task 28
re-ran the pipeline to pick it up, byte-identically.

## Slide 12: Byte-Identical Across an Environment Upgrade (90s, CLIMAX)

This is the slide I wish more methods talks had. On the left: the
pipeline running on bare-base R with zero optional packages -- the
hostile environment from the original task 20 snapshot. On the right:
the same pipeline after task 27 landed the full tidyverse stack and we
re-ran it under task 28. Different R library entirely. Different
Python library. Quarto now available. Every one of the six target
files is byte-identical. The SHA256 hashes match. The headline OR of
3.29 re-asserts to four significant figures. That's what deterministic
seed plus pinned inputs buys you. The receipt at the bottom is verbatim
from `logs/rerun_028/identity_check.txt` -- you can clone the repo and
reproduce it yourself. Budget this slide 90 seconds; it is the climax.

## Slide 13: Limitations & What's Synthetic (70s)

Three limitations from the original talk are now retired -- task 28
added Cox, MICE, and a working Quarto render. Two new minor footnotes:
`broom.helpers` is the last missing R package, small nix derivation
gap; and there is a small Wald-versus-profile CI difference in the
upper bound that doesn't change any conclusion. The loudest thing on
this slide is and remains bullet 1: synthetic data. Not a clinical
finding.

## Slide 14: Takeaways & What's Next (70s)

Three takeaways mirroring the executive summary. One: four commands
versus a week of scaffolding. Two: pre-specification and robustness
are side-effects of the forcing questions, not discipline the team has
to muster. Three: reproducibility is a property of the code, verifiable
by `diff` and `sha256sum`. What's next: finish the last R package, drop
a `renv` lockfile, write a `flake.nix`, stand up a CI loop. And if any
of this resonates, `EPI_ANSWERS.md` is a fork-ready template for your
own study. Thank you. Questions?
