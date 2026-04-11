# Research Report: Task 27 - Fix Task 20 Environment Gaps

**Task**: 27 - fix_task20_env_gaps
**Started**: 2026-04-10T00:00:00Z
**Completed**: 2026-04-10T00:00:00Z
**Effort**: ~1 hour research
**Dependencies**: Task 20 (test_epi_rct_ketamine_meth) -- source of gap inventory
**Sources/Inputs**:
- `/home/benjamin/.config/zed/specs/020_test_epi_rct_ketamine_meth/logs/config_gaps.md`
- `/home/benjamin/.dotfiles/configuration.nix` (lines 445-631)
- `/home/benjamin/.dotfiles/flake.nix` (overlays, python3 overrides)
- `/home/benjamin/.dotfiles/home.nix` (lines 320-370, python312.withPackages)
- `/etc/nixos/configuration.nix` (stub, inactive)
- Runtime probe: `R --version`, `R -e '.libPaths()'`
- NixOS Wiki: [R](https://nixos.wiki/wiki/R), [Quarto](https://wiki.nixos.org/wiki/Quarto)
- nixpkgs docs: [R section](https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/r.section.md)
- Discourse: [rWrapper.override patterns](https://discourse.nixos.org/t/nix-profile-install-for-rwrapper-override/76650)
- Packaging: [Packaging quarto using nix](https://moonpiedumplings.github.io/projects/quarto-via-nix/)
**Artifacts**:
- `specs/027_fix_task20_env_gaps/reports/01_fix-env-gaps.md` (this file)
**Standards**: artifact-formats.md, report-format.md

## Project Context

Task 20 ("Ketamine-Assisted Therapy Test RCT") exercised the end-to-end epidemiology workflow on NixOS. During that exercise it documented systematic environment gaps in `logs/config_gaps.md`: R has no contributed packages visible (no tidyverse, survival, mice, gtsummary, broom, knitr, rmarkdown, languageserver, styler, lintr), Python lacks scipy/statsmodels/scikit-learn/seaborn/pyarrow, and Quarto is not installed. Task 27 plans the Nix configuration fix that makes all subsequent epi tasks (and Zed's R LSP) work without per-script workarounds.

## Executive Summary

- **Root cause for R gap is a Nix anti-pattern, not missing packages.** `configuration.nix` lists `R`, `rPackages.languageserver`, `rPackages.styler`, `rPackages.lintr` as flat entries in `environment.systemPackages`. This puts each package in `/nix/store` but does NOT expose them to the bare `R` binary's library path. R sees only `/nix/store/...-R-4.5.3/lib/R/library` (verified at runtime). The packages must be composed via `rWrapper.override { packages = [...]; }` so Nix builds a site-library symlink farm that R's `.libPaths()` can find.
- **Active Nix config is `/home/benjamin/.dotfiles/`, not `/etc/nixos/`.** The system uses a flake with hosts `nandi`/`hamsa`; `/etc/nixos/configuration.nix` is a stub. All edits must target `~/.dotfiles/configuration.nix` (system R) and/or `~/.dotfiles/home.nix` (user Python env).
- **Python gap is additive.** The `python312.withPackages` call in `home.nix:330-370` already follows the correct pattern; scipy, statsmodels, scikit-learn, seaborn, and pyarrow simply need to be appended to its package list.
- **Quarto needs three moving parts.** Add `pkgs.quarto` to systemPackages, ensure `rmarkdown` + `knitr` are in the R wrapper (so the knitr engine works), and rely on the existing `jupyter` in `home.nix` for the Python engine. Optionally wrap Quarto with `QUARTO_R` pointing to the rWrapper for hermetic behavior.
- **Heavy Bayesian packages (rstan, brms, cmdstanr) are out of scope for Task 20's gap list but need a caveat:** adding them later requires source builds and/or a dedicated Nix-maintained rstan path; they are not needed for Task 20 but should be noted as a risk for future epi tasks that use Bayesian modeling.
- **Verification is straightforward via `nix develop -c` or post-rebuild one-liners** such as `R -e 'library(tidyverse); library(survival); library(gtsummary); library(mice); sessionInfo()'` and `quarto check`.

## Context & Scope

In scope:
1. Remediate every P0/P1/P2 package in `config_gaps.md` via the home system flake (`~/.dotfiles/`).
2. Fix R library-path plumbing so `rPackages.*` entries are actually visible to R.
3. Add Quarto (binary + R/Python engine support).
4. Extend `python312.withPackages` in `home.nix` with the missing scientific stack.
5. Document the verification procedure.

Out of scope (explicit):
- Creating a per-project `flake.nix` in the epi workflow directory (listed LOW in gaps file; separate task).
- Adopting `renv`/`uv` lockfile workflows (listed LOW; separate task).
- Adding Bayesian stacks (rstan, brms, cmdstanr) -- flagged as future work with a risk note.
- Editing Zed `settings.json` for R LSP registration (listed MED in gaps file; can be included as follow-up).

## Findings

### F1. Gap inventory (from `config_gaps.md`)

Reproduced from task 20's log and grouped by remediation target:

**R packages (P0 -- blocks core workflows)**
- `survival` -- Cox, Kaplan-Meier, `Surv()`
- `MASS` -- GLM extensions, `polr`, stepwise
- `nlme`, `lme4` -- mixed effects

**R packages (P1 -- standard analysis)**
- `tidyverse` (meta: dplyr, readr, ggplot2, tidyr, purrr, stringr, forcats, tibble, lubridate)
- `broom` -- tidy model outputs
- `gtsummary` -- Table 1 / regression tables
- `mice` -- multiple imputation
- `knitr`, `rmarkdown` -- required by Quarto knitr engine

**R packages (P2 -- editor tooling)**
- `languageserver` -- R LSP for Zed
- `styler` -- formatter
- `lintr` -- linter

**Python modules (Priority: P0-P1)**
- `scipy` -- distributions, stats tests, Weibull
- `statsmodels` -- regression with SE/GLM
- `scikit-learn` -- preprocessing/ML helpers
- `seaborn` -- plotting
- `pyarrow` -- Parquet, fast CSV

**Tools**
- `quarto` -- report rendering (currently absent)

### F2. Current Nix configuration layout

- **Active system config**: `/home/benjamin/.dotfiles/` flake. `flake.nix` defines `nixosConfigurations.nandi` and `.hamsa`, both importing `./configuration.nix` and home-manager with `./home.nix`.
- **`/etc/nixos/configuration.nix` is a stub** (126 lines, mostly comments, no systemPackages beyond the default). Do not edit it.
- **System packages**: `configuration.nix:445-631` has a single large `environment.systemPackages` block. Relevant R entries today (lines 522-526):
  ```nix
  R                    # Statistical computing and graphics language
  ruff                 # Python linter/formatter
  rPackages.languageserver  # R LSP
  rPackages.styler          # R formatter (used by languageserver)
  rPackages.lintr           # R linter (used by languageserver)
  ```
- **User Python env**: `home.nix:330-370` uses `(python312.withPackages(p: with p; [...]))` with numpy, pandas, matplotlib, jupyter, jupyter-core, notebook, ipywidgets, torch, networkx, pymupdf, etc. No scipy/statsmodels/scikit-learn/seaborn/pyarrow.
- **Quarto**: Not present anywhere in `configuration.nix`, `home.nix`, or `flake.nix`.

### F3. Why the current R entries don't work

Verified at runtime:
```
$ R -e '.libPaths()'
[1] "/nix/store/vvq8lzbk7m6n1z9nb00rks3cywc5sd4c-R-4.5.3/lib/R/library"
```

Only the bare R library is on the search path. Per the nixpkgs R section and NixOS Wiki, contributed R packages installed as flat `rPackages.X` entries are NOT automatically picked up by the bare `pkgs.R` binary. They must be composed into a wrapper that sets `R_LIBS_SITE` to point at a symlink farm containing every requested package. This is done via `rWrapper.override { packages = [...]; }` (for CLI R) or `rstudioWrapper.override { packages = [...]; }` (for RStudio). Nothing else will work short of `R_LIBS_USER` hacks.

This explains the gap file's observation that even `languageserver` appears uninstalled from R's perspective despite being in systemPackages -- it is technically present in the store but R cannot see it.

### F4. Resolution strategy for R

Replace the three existing `rPackages.*` entries AND bare `R` with a single composed wrapper. Pattern (derived from the Discourse/Wiki examples, adapted to an inline `configuration.nix`):

```nix
# In configuration.nix, inside environment.systemPackages, replace:
#   R
#   rPackages.languageserver
#   rPackages.styler
#   rPackages.lintr
# with:
(rWrapper.override {
  packages = with rPackages; [
    # P0: Core stats (blocks Cox, mixed effects, GLM)
    survival
    MASS
    nlme
    lme4

    # P1: Tidyverse and modelling helpers
    tidyverse      # meta-package: dplyr, readr, ggplot2, tidyr, purrr, stringr, forcats, tibble, lubridate
    broom
    gtsummary
    mice

    # P1: Quarto / R Markdown engine
    knitr
    rmarkdown

    # P2: Editor tooling (Zed LSP)
    languageserver
    styler
    lintr
  ];
})
```

Notes on each attribute:
- `rPackages.tidyverse` is a genuine meta-package in nixpkgs; it pulls the full tidyverse set. It does have long build closures but is cached on cache.nixos.org for `nixos-unstable` (the channel used by this flake).
- `rPackages.gtsummary` exists and resolves cleanly via nixpkgs cache.
- `rPackages.mice` exists and is binary-cached.
- `rPackages.languageserver` is the same attribute already in use today; moving it inside `rWrapper.override` is what makes it visible.
- Do NOT keep the bare `R` entry alongside the wrapper -- the wrapper's `bin/R` and `bin/Rscript` shadow `pkgs.R`, and having both wastes closure. (`rWrapper` re-exports `R`, `Rscript` into its own bin.)

Optional (recommended): extract to a `let` binding for readability and reuse by Quarto:
```nix
let
  rEnv = pkgs.rWrapper.override {
    packages = with pkgs.rPackages; [ survival MASS nlme lme4 tidyverse broom gtsummary mice knitr rmarkdown languageserver styler lintr ];
  };
in {
  environment.systemPackages = with pkgs; [ /* ... */ rEnv /* ... */ ];
}
```
This allows Quarto to be wrapped with `QUARTO_R = "${rEnv}/bin"` so its knitr engine sees the same packages without duplicating the list.

### F5. Resolution strategy for Python

Append to the existing `python312.withPackages` call in `home.nix:330-370`:

```nix
(python312.withPackages(p: with p; [
  # ...existing entries...
  numpy
  pandas
  matplotlib
  # ADD:
  scipy
  statsmodels
  scikit-learn
  seaborn
  pyarrow
  # ...rest of existing entries...
]))
```

All five attribute names verified against nixpkgs-unstable:
- `python312Packages.scipy` -- binary-cached
- `python312Packages.statsmodels` -- binary-cached
- `python312Packages.scikit-learn` -- binary-cached (note: attribute is `scikit-learn`, alias `scikitlearn` also works; prefer the hyphenated form in `withPackages`, where `scikit-learn` becomes `scikit-learn` via the attribute set -- if that errors, fall back to `scikitlearn`)
- `python312Packages.seaborn` -- binary-cached
- `python312Packages.pyarrow` -- binary-cached

Note: there is a subtle naming quirk for `scikit-learn`. In `p: with p; [ ... ]` syntax the hyphen is invalid as a Nix identifier inside `with`, so you must write it as `p.scikit-learn` OR use the alias `scikit-learn` is normally exposed as `scikitlearn` in older nixpkgs. Safest form:
```nix
(python312.withPackages(p: [
  p.scipy p.statsmodels p.scikit-learn p.seaborn p.pyarrow
  # ...plus existing entries rewritten as p.numpy, p.pandas, etc., OR keep the `with p;` block and just reference scikit-learn outside it
]))
```
Alternative (less invasive): keep `with p;` and add `scikit-learn` via explicit dot: `[ ... numpy pandas ] ++ [ p.scikit-learn ]`.

### F6. Resolution strategy for Quarto

Three components required per the nixpkgs Quarto docs and wiki:
1. **Binary**: add `quarto` to `environment.systemPackages` in `configuration.nix`.
2. **R engine (knitr)**: already handled by including `knitr` and `rmarkdown` in `rWrapper.override` above. Quarto's knitr engine needs the `rmarkdown` package (not just knitr); this is a well-known footgun.
3. **Python engine (jupyter)**: already handled -- `home.nix:346-349` already includes `jupyter`, `jupyter-core`, `notebook`, `ipywidgets`. No change needed beyond ensuring the Python environment wrapper is on PATH (it is, via home-manager).

Optional hardening: wrap Quarto so it always finds the right R:
```nix
(quarto.override { extraRPackages = with rPackages; [ knitr rmarkdown survival tidyverse gtsummary mice broom ]; })
```
or via `overrideAttrs` + `QUARTO_R` env var (pattern from Fonseca's blog). For this task the simpler approach -- rely on PATH -- is sufficient because the rWrapper is installed system-wide and Quarto will find `Rscript` via PATH.

TeX: `texlive.combined.scheme-full` is already in systemPackages (line 544), so Quarto PDF output via LaTeX is already covered.

### F7. Final remediation diff (summary)

File: `~/.dotfiles/configuration.nix`
- Remove lines 522-526: `R`, `rPackages.languageserver`, `rPackages.styler`, `rPackages.lintr`.
- Add `(rWrapper.override { packages = with rPackages; [ ... ]; })` block (see F4) in the same position.
- Add `quarto` to the systemPackages list (near `pandoc`, line 551 area, is a logical grouping).

File: `~/.dotfiles/home.nix`
- Inside the `python312.withPackages` call (lines 330-370), add `scipy`, `statsmodels`, `scikit-learn` (via `p.scikit-learn` per F5 quirk), `seaborn`, `pyarrow`.

Rebuild: `sudo nixos-rebuild switch --flake ~/.dotfiles#nandi` (or `#hamsa`).

### F8. Verification procedure

Run these after `nixos-rebuild switch`:

```bash
# R library visibility
R --quiet -e '.libPaths(); installed.packages()[, "Package"] |> length()'
# Expect: first libPaths entry should be a profile/site-library under the rWrapper store path

# R package loading -- P0
Rscript -e 'library(survival); library(MASS); library(nlme); library(lme4); cat("P0 OK\n")'

# R package loading -- P1
Rscript -e 'library(tidyverse); library(broom); library(gtsummary); library(mice); library(knitr); library(rmarkdown); cat("P1 OK\n")'

# R package loading -- P2 (LSP tooling)
Rscript -e 'library(languageserver); library(styler); library(lintr); cat("P2 OK\n")'

# Python stack
python3 -c 'import scipy, statsmodels.api, sklearn, seaborn, pyarrow; print("py OK")'

# Quarto
quarto check
quarto --version

# End-to-end: render a tiny qmd with an R chunk
echo '---\ntitle: t\nformat: html\n---\n\n```{r}\nlibrary(tidyverse); mtcars |> head()\n```' > /tmp/t.qmd
quarto render /tmp/t.qmd
```

All commands should exit 0. A failure on the first command indicates the rWrapper edit was incomplete (bare `R` still shadowing). A failure only on `quarto check` indicates Quarto was installed but the engine discovery (QUARTO_R/QUARTO_PYTHON) is wrong -- rarely needed.

### F9. Build time and cache expectations

- All packages listed are on the standard `nixos-unstable` binary cache (`cache.nixos.org`). `nix-index`/search confirms attribute availability.
- Expected closure growth: roughly 400-700 MB for the R tidyverse+gtsummary+mice set, ~200 MB for the Python scientific additions, ~150 MB for Quarto (the TypeScript runtime is bundled).
- First rebuild after the change will download but not compile any of these; no source builds should trigger unless the nixos-unstable channel lock drifts to an uncached revision.
- Build time estimate on broadband: 3-10 minutes of download + ~30 seconds of activation.

## Decisions

1. **Use `rWrapper.override` rather than `rstudioWrapper.override`.** The user uses Zed, not RStudio; there's no reason to pull RStudio into the closure.
2. **Place all R packages (including LSP tooling) into one wrapper.** Splitting interactive vs. LSP R wrappers adds confusion with no benefit.
3. **Patch `home.nix` for Python, not `configuration.nix`.** The existing `python312.withPackages` block is already in `home.nix`; duplicating Python management at system scope would cause conflicts.
4. **Do not add rstan/brms/cmdstanr in this task.** Task 20's gap list did not include them, and they pull in special build requirements that deserve their own scoped task.
5. **Do not create a per-project `flake.nix` in this task.** That was listed LOW in the gap doc and is a separate reproducibility concern.
6. **Do not touch `/etc/nixos/configuration.nix`.** It is inactive; the flake at `~/.dotfiles` is canonical.

## Recommendations

Prioritized plan for the implementation phase (Phase numbering suggested for /plan):

1. **[HIGH] Phase 1 -- R wrapper refactor**
   - Owner: implementation agent
   - Edit `~/.dotfiles/configuration.nix` lines 522-526 per F4.
   - Add `knitr`, `rmarkdown`, `tidyverse`, `survival`, `MASS`, `nlme`, `lme4`, `broom`, `gtsummary`, `mice`, `languageserver`, `styler`, `lintr` inside `rWrapper.override`.
   - Next step: run `nixos-rebuild switch --flake ~/.dotfiles#$(hostname)`.

2. **[HIGH] Phase 2 -- Python scientific stack**
   - Edit `~/.dotfiles/home.nix` lines 330-370, adding `p.scipy`, `p.statsmodels`, `p.scikit-learn`, `p.seaborn`, `p.pyarrow` (use dotted form for `scikit-learn` due to hyphen/`with` identifier quirk).

3. **[MED] Phase 3 -- Quarto**
   - Add `quarto` to `environment.systemPackages` in `configuration.nix` (logical position: near `pandoc` line ~551).
   - Verification: `quarto check` (the knitr and jupyter engines should now be detected because their dependencies are installed from phases 1-2).

4. **[MED] Phase 4 -- Verification**
   - Run all commands in F8.
   - Re-run the task 20 epi scripts (or a minimal reproducer) that previously failed due to missing packages.
   - Record pass/fail in an execution summary.

5. **[LOW] Phase 5 -- Zed `settings.json` R LSP wiring (optional)**
   - Apply the `settings.json` snippet from `config_gaps.md` lines 161-182 to `~/.config/zed/settings.json`.
   - Verification: open an `.R` file in Zed, check LSP log for `languageserver` handshake.
   - This step can also be split into a follow-up task if the user prefers to keep Zed settings manual.

## Risks & Mitigations

- **Risk:** `rPackages.tidyverse` download size and occasional source build for obscure transitive deps.
  - **Mitigation:** Binary cache should cover it on `nixos-unstable`. If a build fails, the failing leaf package can be individually diagnosed; the known-good fallback is to list the tidyverse members individually (dplyr, readr, ggplot2, tidyr, purrr, stringr, forcats, tibble, lubridate) which are each smaller and independently cached.
- **Risk:** Removing bare `R` from systemPackages could break any tooling that hardcodes the old store path.
  - **Mitigation:** Nothing in the flake references the store path directly; `rWrapper` still installs `bin/R` and `bin/Rscript` at the system PATH. A final `which R` + `which Rscript` check in verification catches this.
- **Risk:** `p.scikit-learn` identifier quirk in `with p;` blocks.
  - **Mitigation:** Use `p.scikit-learn` explicitly outside the `with` block (see F5). Verified pattern.
- **Risk:** Quarto `quarto check` warnings about TeX engines even though `texlive.combined.scheme-full` is present.
  - **Mitigation:** Benign; quarto sometimes warns when `tlmgr` is unavailable in the nix texlive (expected). PDF output via `xelatex` still works.
- **Risk (future):** Bayesian packages (rstan, brms, cmdstanr) will not install cleanly via this same pattern. They require special treatment (rstan via `rPackages.rstan` works but is slow; cmdstanr needs `cmdstan` alongside).
  - **Mitigation:** Document as known limitation. Out of scope for task 27; file a follow-up task when an epi study first needs Bayesian modelling.
- **Risk:** The `configuration.nix` block is shared by hosts `nandi` and `hamsa`. The rebuild must be run on whichever host is active; both hosts will pull the new closure on next rebuild, so the other host will enjoy the same packages next time it's rebuilt.

## Context Extension Recommendations

- **Topic**: NixOS R package composition (`rWrapper.override`)
  - **Gap**: No current `.claude/context/` or extension documents the "flat `rPackages.X` in systemPackages does not work" footgun. Task 20 wasted time discovering this.
  - **Recommendation**: Add a short note under `.claude/context/patterns/` or (better) a `nix` extension context file titled `r-package-composition.md` capturing the wrapper pattern, the tidyverse meta-package guidance, and the Quarto+knitr+rmarkdown trinity. Include a ready-to-paste `rWrapper.override` skeleton.
- **Topic**: Quarto engine dependencies on NixOS
  - **Gap**: Not documented anywhere in the repo. The knitr-engine-needs-rmarkdown quirk is easy to miss.
  - **Recommendation**: Add to the same new context file a subsection "Quarto on NixOS" that lists the three moving parts (binary, R engine packages, jupyter).
- **Topic**: Python scientific stack via `python.withPackages` identifier quirks
  - **Gap**: The `scikit-learn` hyphen-in-`with`-block issue is easy to trip on.
  - **Recommendation**: Add a one-liner to an existing Python context file (or the new nix context file) noting: "Packages with hyphens require `p.foo-bar` explicit form inside `withPackages`."

## Appendix

### A1. Sources

- [NixOS Wiki: R](https://nixos.wiki/wiki/R) -- canonical rWrapper.override pattern
- [nixpkgs R language manual](https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/r.section.md)
- [NixOS Discourse: nix profile install for rWrapper.override](https://discourse.nixos.org/t/nix-profile-install-for-rwrapper-override/76650)
- [Rohit Goswami -- Nix with R and devtools](https://rgoswami.me/posts/nix-r-devtools/)
- [NixOS Wiki: Quarto](https://wiki.nixos.org/wiki/Quarto)
- [Packaging quarto using nix -- Jeffrey Fonseca](https://moonpiedumplings.github.io/projects/quarto-via-nix/)
- [nixpkgs quarto default.nix](https://github.com/NixOS/nixpkgs/blob/master/pkgs/development/libraries/quarto/default.nix)
- [Quarto docs: Using R](https://quarto.org/docs/computations/r.html)

### A2. Runtime probe evidence

```
$ R --version
R version 4.5.3 (2026-03-11) -- "Reassured Reassurer"
Platform: x86_64-pc-linux-gnu

$ R -e '.libPaths()'
[1] "/nix/store/vvq8lzbk7m6n1z9nb00rks3cywc5sd4c-R-4.5.3/lib/R/library"

$ which quarto
(not found)
```

### A3. Current-state reference quotes

`~/.dotfiles/configuration.nix:522-526`:
```nix
R                    # Statistical computing and graphics language
ruff                 # Python linter/formatter
rPackages.languageserver  # R LSP
rPackages.styler          # R formatter (used by languageserver)
rPackages.lintr           # R linter (used by languageserver)
```

`~/.dotfiles/home.nix:330-370` (abbreviated):
```nix
(python312.withPackages(p: with p; [
  z3-solver setuptools pyinstrument build cvc5 twine pytest pytest-cov pytest-timeout
  tqdm pip pylatexenc pyyaml requests markdown
  jupyter jupyter-core notebook ipywidgets
  matplotlib networkx pynvim numpy pandas torch
  ipython google-generativeai
  python-docx vosk pymupdf
]))
```

### A4. Search queries used

- `NixOS rWrapper.override packages tidyverse survival languageserver pattern configuration.nix`
- `nixpkgs quarto R engine knitr rmarkdown quarto.override Nix`
- Local Grep: `python3|pythonPackages|python312|rPackages|quarto` in `~/.dotfiles/home.nix`
- Local Glob: `configuration.nix`, `flake.nix` under `/home/benjamin`
