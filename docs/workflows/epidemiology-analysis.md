# Epidemiology Analysis

Design and execute epidemiological studies with R-based statistical analysis. The `/epi` command scopes a study through structured forcing questions, then the standard task lifecycle drives it to completion.

> **Requires the `epidemiology` extension.** Ensure the extension is loaded before using these commands.

## Decision guide

| I want to... | Use |
|---|---|
| Start a new epidemiology study | `/epi "Description"` |
| Resume research on an existing study | `/epi N` |
| Use a protocol file as input | `/epi /path/to/protocol.md` |

## When to use /epi

Use `/epi` when your task involves epidemiological study design, observational data analysis, or statistical modeling in R. The command handles eight study design types: cohort, case-control, cross-sectional, RCT, meta-analysis, quasi-experimental, surveillance, and modeling studies.

If you already have a task created with task type `epi`, `epi:study`, or `epidemiology`, you can also run `/research N`, `/plan N`, and `/implement N` directly -- the system routes to the epidemiology-specific agents automatically.

## Task type routing

Three task type keys route to the epidemiology agents:

| Task Type | Research Skill | Implementation Skill |
|-----------|----------------|---------------------|
| `epi` | skill-epi-research | skill-epi-implement |
| `epi:study` | skill-epi-research | skill-epi-implement |
| `epidemiology` | skill-epi-research | skill-epi-implement |

All three are functionally equivalent. `/epi` creates tasks with type `epi:study` by default.

## Starting a new study

```
/epi "Cohort study of vaccine effectiveness in elderly populations"
```

The command asks 10 forcing questions covering:

1. **Study design type** -- cohort, case-control, cross-sectional, RCT, meta-analysis, quasi-experimental, surveillance, or modeling
2. **Research question** -- PICO/PECO format encouraged
3. **Causal structure** -- DAG notation, confounders, mediators (optional)
4. **Data paths** -- file or directory paths to datasets
5. **Descriptive content** -- protocols, codebooks, data dictionaries
6. **Prior work** -- existing analyses, task references, citations
7. **Ethics status** -- IRB approved, exempt, pending, or not applicable
8. **Reporting guideline** -- STROBE, CONSORT, PRISMA, RECORD, TRIPOD, or auto-detect
9. **R preferences** -- packages, statistical framework, output format
10. **Analysis hints** -- models, sensitivity analyses, subgroups, estimands

After answering, the task is created at `[NOT STARTED]` with all forcing data stored in task metadata.

## Example workflow

```
/epi "Case-control study of air pollution exposure and childhood asthma"
  # -> answers forcing questions, creates task #42 at [NOT STARTED]

/research 42
  # -> epi-research-agent investigates study design, data quality, confounders
  # -> produces report at specs/042_air_pollution_asthma/reports/01_epi-research.md

/plan 42
  # -> planner-agent creates phased analysis plan
  # -> produces plan at specs/042_air_pollution_asthma/plans/01_analysis-plan.md

/implement 42
  # -> epi-implement-agent executes R code: data cleaning, modeling, sensitivity analysis
  # -> produces summary at specs/042_air_pollution_asthma/summaries/01_execution-summary.md
```

## R-based analysis capabilities

The epidemiology agents have access to context covering:

- **Study designs** -- cohort, case-control, cross-sectional, RCT, meta-analysis, quasi-experimental, surveillance, modeling
- **Statistical modeling** -- GLM, mixed effects, survival analysis, Bayesian methods (brms, rstanarm)
- **Causal inference** -- DAGs, propensity scores, inverse probability weighting, mediation analysis
- **Missing data** -- MICE, sensitivity analysis, pattern diagnostics
- **Data management** -- tidyverse workflows, validation, REDCap integration
- **Reporting** -- STROBE, CONSORT, PRISMA checklists; Quarto output
- **R workflow tools** -- renv for reproducibility, targets for pipelines, Quarto for literate programming

## Resuming an existing study

```
/epi 42
```

When given a task number, `/epi` validates the task type starts with `epi` and delegates to the research skill. This is equivalent to running `/research 42` on an epidemiology task.

## Using a protocol file

```
/epi /path/to/protocol.pdf
```

Reads the file as study protocol context, then runs the same forcing questions. The protocol content informs the scoping and is stored alongside the forcing data.

## See also

- [agent-lifecycle.md](agent-lifecycle.md) -- The core task lifecycle that epidemiology tasks follow
- [`../agent-system/commands.md`](../agent-system/commands.md) -- Full command reference with flags
- [grant-development.md](grant-development.md) -- Grant proposals and funding analysis (complementary workflow)
- [memory-and-learning.md](memory-and-learning.md) -- Save study findings for future analyses
