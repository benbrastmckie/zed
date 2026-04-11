# Zed R/Python/Quarto Configuration Gaps

Task 20: Ketamine-Assisted Therapy Test RCT
Verification date: 2026-04-10
Host: NixOS

## Executive Summary

Zed can launch both R and Python scripts via the integrated terminal. Python has
a partial scientific stack (numpy, pandas, matplotlib) but is missing scipy and
other common libraries. R is a bare-base install with no recommended packages
(no `survival`, `MASS`, `nlme`) and no contributed packages (no `tidyverse`,
`gtsummary`, `mice`, `languageserver`, `styler`). Quarto is not installed.
All analyses in this task use base-R-only fallbacks and pandas+numpy only.

## Test Environment

| Component | Version / Path | Status |
|-----------|----------------|--------|
| R | 4.5.3 (Nix store) | OK |
| Rscript | /run/current-system/sw/bin/Rscript | OK |
| Python | 3.12.13 (nix-profile) | OK |
| Quarto | -- | MISSING |
| R lib path | /nix/store/.../R-4.5.3/lib/R/library | bare base only |

## R Package Gaps

### Priority 0 -- Blocks standard epi workflows

| Package | Purpose | Remediation |
|---------|---------|-------------|
| survival | Cox model, Kaplan-Meier, Surv() | Add `rPackages.survival` to nix config |
| MASS | GLM extensions, polr, stepwise | Add `rPackages.MASS` |
| nlme, lme4 | Mixed effects models | Add `rPackages.nlme`, `rPackages.lme4` |

### Priority 1 -- Standard analysis packages

| Package | Purpose | Remediation |
|---------|---------|-------------|
| tidyverse (dplyr, readr, ggplot2, tidyr, purrr) | Data manipulation, plotting | Add `rPackages.tidyverse` |
| gtsummary | Publication tables (Table 1, regression tables) | Add `rPackages.gtsummary` |
| broom | Tidy model outputs | Add `rPackages.broom` |
| mice | Multiple imputation | Add `rPackages.mice` |
| knitr, rmarkdown | Reports | Add `rPackages.knitr`, `rPackages.rmarkdown` |

### Priority 2 -- LSP / editor tooling

| Package | Purpose | Remediation |
|---------|---------|-------------|
| languageserver | R LSP for Zed (completion, hover, diagnostics) | Add `rPackages.languageserver` |
| styler | R code formatter | Add `rPackages.styler` |
| lintr | R linter | Add `rPackages.lintr` |

### Recommended NixOS remediation snippet

Add to `configuration.nix` (or a home-manager module):

```nix
environment.systemPackages = with pkgs; [
  (rWrapper.override {
    packages = with rPackages; [
      # Base stats stack
      survival MASS nlme lme4
      # Tidyverse
      tidyverse broom
      # Reporting / tables
      gtsummary knitr rmarkdown
      # Missing data
      mice
      # Editor integration
      languageserver styler lintr
    ];
  })
];
```

Alternative (user-scoped, without touching system config):

```bash
nix profile install nixpkgs#rstudioWrapper   # or
nix shell nixpkgs#R nixpkgs#rPackages.tidyverse nixpkgs#rPackages.survival ...
```

A reproducible alternative is to create a `flake.nix` in the project root and
launch Zed from a `nix develop` shell so the R and Python environments are
pinned per-project.

## Python Module Gaps

| Module | Purpose | Remediation |
|--------|---------|-------------|
| scipy | Weibull, stats distributions, tests | `nix profile install nixpkgs#python312Packages.scipy` |
| statsmodels | Regression with SE, GLMs in Python | `python312Packages.statsmodels` |
| scikit-learn | ML helpers, preprocessing | `python312Packages.scikit-learn` |
| seaborn | Publication-style plots | `python312Packages.seaborn` |
| pyarrow | Parquet, fast CSV IO | `python312Packages.pyarrow` |

### Recommended nix-profile snippet

```bash
nix profile install \
  nixpkgs#python312Packages.scipy \
  nixpkgs#python312Packages.statsmodels \
  nixpkgs#python312Packages.scikit-learn \
  nixpkgs#python312Packages.seaborn \
  nixpkgs#python312Packages.pyarrow
```

For project-level pinning, prefer `uv` with a `pyproject.toml`:

```toml
[project]
name = "epi-rct"
requires-python = ">=3.12"
dependencies = [
    "numpy>=2.0",
    "pandas>=2.2",
    "scipy>=1.13",
    "statsmodels>=0.14",
    "matplotlib>=3.9",
    "seaborn>=0.13",
]
```

## Quarto Gap

Quarto is not installed at all. Options:

1. System-wide: add `pkgs.quarto` to `configuration.nix`.
2. User-scoped: `nix profile install nixpkgs#quarto`.
3. Containerized: run Quarto from a `devcontainer` or `flake.nix` shell.

Quarto depends on `rmarkdown`, `knitr` (R engine) and `jupyter` (Python engine).
For this task both engines are unavailable, so Phase 7 will fall back to a plain
Markdown report with pre-computed numbers embedded as code fences.

## Zed Editor LSP / Formatter Observations

Because this task runs in a headless automation context, interactive Zed LSP
behavior cannot be introspected directly from the shell. The following items
should be verified by a human opening `scripts/01_generate_data.py` and
`scripts/02_generate_outcomes.R` in Zed:

| Test point | Expected | Likely status |
|------------|----------|---------------|
| R LSP starts on `.R` open | languageserver handshake in LSP log | FAIL -- languageserver not installed |
| R hover / completion | Docs on functions | FAIL -- no LSP |
| R diagnostics | lintr warnings surfaced | FAIL -- lintr not installed |
| R format-on-save | styler reformats buffer | FAIL -- styler not installed |
| Python LSP (pyright) | Starts on `.py` open | Unknown -- verify via Zed settings |
| Python diagnostics | ruff warnings inline | Unknown |
| Python format-on-save | ruff format runs | Unknown |
| Integrated terminal | `Rscript` and `python3` resolve | OK (verified) |
| Quarto preview | `.qmd` renders via extension | FAIL -- quarto missing |
| Cross-language CSV handoff | Python writes, R reads, no encoding issues | OK (verified; UTF-8 default) |

## Recommended Zed `settings.json` Additions

(Do not apply automatically -- recorded for user review.)

```jsonc
{
  "languages": {
    "R": {
      "language_servers": ["r-languageserver"],
      "format_on_save": "on",
      "formatter": { "external": { "command": "Rscript",
        "arguments": ["-e", "styler::style_file(commandArgs(TRUE))", "{buffer_path}"] } }
    },
    "Python": {
      "language_servers": ["pyright", "ruff"],
      "format_on_save": "on",
      "formatter": { "language_server": { "name": "ruff" } }
    }
  },
  "lsp": {
    "r-languageserver": {
      "binary": { "path": "Rscript", "arguments": ["-e", "languageserver::run()"] }
    }
  }
}
```

## Prioritized Remediation Checklist

1. [HIGH] Install R `survival` (blocks Cox models) and `tidyverse` (blocks ~all modern R code)
2. [HIGH] Install `rPackages.languageserver` so Zed has an R LSP at all
3. [HIGH] Install Python `scipy` and `statsmodels` for proper distributions and regression
4. [MED] Install `quarto` (and rmarkdown + jupyter) for report rendering
5. [MED] Install R `styler` + `lintr`, configure Zed R LSP entry in settings.json
6. [LOW] Add project `flake.nix` for per-project reproducibility
7. [LOW] Consider `renv` (requires `renv` package first) and `uv` for lockfiles
