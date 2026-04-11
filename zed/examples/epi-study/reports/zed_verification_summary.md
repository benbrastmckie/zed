# Zed R/Python/Quarto Verification Summary

**Task 20**: test_epi_rct_ketamine_meth
**Date**: 2026-04-10
**Host**: NixOS
**Verifier**: epi-implement-agent

This document addresses the 10 configuration test points from
`reports/01_epi-research.md` "Summary of Configuration Test Points".

## Test-Point Results

| # | Test Point | Result | Notes |
|---|---|---|---|
| 1 | R interpreter resolvable from Zed terminal | PASS | `/run/current-system/sw/bin/Rscript`, R 4.5.3 |
| 2 | Python 3 resolvable from Zed terminal | PASS | `/home/benjamin/.nix-profile/bin/python3`, 3.12.13 |
| 3 | R contributed packages for epi workflow | FAIL | `tidyverse`, `survival`, `gtsummary`, `broom`, `mice` all missing; base-R-only install |
| 4 | Python scientific stack | PARTIAL | `numpy`, `pandas`, `matplotlib` present; `scipy`, `statsmodels`, `seaborn`, `sklearn`, `pyarrow` missing |
| 5 | Quarto rendering | FAIL | `quarto` binary not installed; used Markdown fallback with pre-computed numbers |
| 6 | R LSP (languageserver) | FAIL | Not installed -- Zed cannot provide R completion/hover/diagnostics |
| 7 | R formatter / linter (`styler`, `lintr`) | FAIL | Neither installed |
| 8 | Python LSP / formatter (pyright, ruff) | UNKNOWN | Interactive Zed behavior not testable from headless agent; verify manually |
| 9 | Cross-language CSV handoff (UTF-8) | PASS | Python -> CSV -> R read with `read.csv`, no encoding issues; R -> CSV -> Python read via `pandas.read_csv` |
| 10 | End-to-end pipeline runs from Zed terminal | PASS | All 6 executable scripts (00-05) run to completion via `Rscript` and `python3` |

## Scoreboard

- **Pass**: 4 / 10 (1, 2, 9, 10)
- **Partial**: 1 / 10 (4)
- **Fail**: 4 / 10 (3, 5, 6, 7)
- **Unknown**: 1 / 10 (8)

## Minimum Remediation to Unblock a Real Epi Workflow

To move from "4 pass" to "8+ pass", the following items are the highest-value
changes. Full details are in [`../logs/config_gaps.md`](../logs/config_gaps.md).

1. **Install R analysis packages** (nix):
   `rPackages.tidyverse rPackages.survival rPackages.gtsummary rPackages.broom
    rPackages.mice rPackages.knitr rPackages.rmarkdown`
2. **Install R editor tooling**: `rPackages.languageserver rPackages.styler rPackages.lintr`
3. **Install Python completions**: `python312Packages.scipy python312Packages.statsmodels`
4. **Install Quarto**: `pkgs.quarto`
5. **Configure Zed `settings.json`** to register `r-languageserver` (example
   snippet in config_gaps.md). Ruff and pyright should already be configured
   by the Python extension loaded on 2026-04-10.

## What Works Well

- Running scripts from Zed's integrated terminal is frictionless on NixOS
- Cross-language CSV handoff needs no special configuration
- Base-R-only fallbacks are viable for simple GLM and log-rank analyses
- Commit-per-phase git workflow functioned cleanly end-to-end

## What Needs Attention

- R environment is too minimal for modern epidemiology workflows -- even the
  `survival` package (shipped with base R on most distributions) is absent
- No R LSP means Zed is essentially a plain text editor for .R files until
  `languageserver` is installed
- Quarto absence forces hand-maintained Markdown reports, defeating
  the reproducibility promise of the format
- Consider a project-local `flake.nix` so future epi tasks get a pinned
  environment without touching system config
