# Research Report: Task #19

**Task**: 19 - Create Python and R setup guides for macOS
**Started**: 2026-04-10T00:00:00Z
**Completed**: 2026-04-10T00:30:00Z
**Effort**: small
**Dependencies**: Task 15 (installation.md improvements)
**Sources/Inputs**:
- Codebase: `/home/benjamin/.dotfiles/configuration.nix`, `home.nix`, `flake.nix`
- Codebase: `/home/benjamin/.config/zed/settings.json`
- Codebase: `/home/benjamin/.config/zed/docs/general/installation.md`
- Web: Zed Python docs, Zed R docs, Ruff install docs, Pyright docs, R languageserver CRAN
**Artifacts**:
- `specs/019_python_and_r_setup_guides/reports/01_python-r-setup.md`
**Standards**: report-format.md, artifact-management.md

## Executive Summary

- The user's NixOS dotfiles install Python 3.12 with ruff (linter/formatter), R with languageserver/lintr/styler, and uv as a package manager
- Zed settings.json already has full Python (pyright + ruff) and R (r-language-server) configuration, plus auto-install entries for the `python`, `ruff`, and `r` extensions
- On macOS, all tools are available via Homebrew (`brew install python ruff uv r pyright`) plus R's `install.packages()` for languageserver/lintr/styler
- The new guides should mirror installation.md's structure: beginner-friendly, Check/Install/Verify pattern, and link back to the Zed settings already in place
- Zed now uses basedpyright by default (fork of pyright); either works with the existing settings

## Context and Scope

Task 19 asks for two new files (`docs/general/python.md` and `docs/general/R.md`) with complete macOS setup instructions for Python and R development environments. The guides should be linked from installation.md. Research focuses on identifying what the user actually uses (via NixOS configs) and mapping those tools to macOS equivalents.

## Findings

### Python Tools in NixOS Dotfiles

From `configuration.nix` (lines 496-523) and `home.nix` (lines 330-370):

| Tool | Nix Package | Purpose |
|------|-------------|---------|
| Python 3.12 | `python312.withPackages(...)` | Interpreter |
| uv | `uv` | Package installer/resolver |
| ruff | `ruff` | Linter and formatter (replaces black, isort, flake8) |
| pytest | `pytest` (pip) | Test runner |
| pytest-cov | `pytest-cov` (pip) | Coverage |
| ipython | `ipython` (pip) | Interactive REPL |
| numpy, pandas, matplotlib | pip packages | Data science |
| torch | pip package | Machine learning |

Note: pylint, black, and isort are commented out -- ruff replaces all three.

No pyright is installed at the NixOS level; Zed's Python extension bundles it automatically.

### R Tools in NixOS Dotfiles

From `configuration.nix` (lines 522-526):

| Tool | Nix Package | Purpose |
|------|-------------|---------|
| R | `R` | Interpreter |
| languageserver | `rPackages.languageserver` | R LSP for editor integration |
| styler | `rPackages.styler` | Code formatter (used by languageserver) |
| lintr | `rPackages.lintr` | Linter (used by languageserver) |

No tidyverse, devtools, rmarkdown, or other R packages are installed at the system level.

### Zed Configuration Already in Place

From `settings.json` (lines 78-158), the user already has:

**Python settings** (lines 123-132):
- Language servers: `["pyright", "ruff"]`
- Format on save: enabled
- Formatter: ruff (via language server)
- Tab size: 4

**Pyright LSP settings** (lines 78-85):
- Type checking mode: `basic`
- Diagnostic mode: `openFilesOnly`

**R settings** (lines 133-142):
- Language servers: `["r-language-server"]`
- Format on save: enabled
- Formatter: r-language-server
- Tab size: 2

**R LSP settings** (lines 86-95):
- Diagnostics: enabled
- Rich documentation: enabled

**Auto-install extensions** (lines 146-158):
- `python: true`
- `ruff: true`
- `r: true`

### macOS Installation Methods

**Python ecosystem:**

| Tool | macOS Install Command | Notes |
|------|----------------------|-------|
| Python 3.12+ | `brew install python` | Installs latest Python 3.x |
| uv | `brew install uv` | Or `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| ruff | `brew install ruff` | Standalone; also `uv tool install ruff` |
| pyright | Not needed separately | Zed's Python extension bundles pyright/basedpyright |
| pytest | `uv tool install pytest` or `pip install pytest` | Per-project via `uv add --dev pytest` preferred |
| ipython | `pip install ipython` or `uv tool install ipython` | Interactive REPL |

**R ecosystem:**

| Tool | macOS Install Command | Notes |
|------|----------------------|-------|
| R | `brew install r` | Installs R framework |
| languageserver | `install.packages("languageserver")` (in R console) | Required for Zed LSP |
| lintr | `install.packages("lintr")` (in R console) | Used by languageserver for diagnostics |
| styler | `install.packages("styler")` (in R console) | Used by languageserver for formatting |

### Zed Extension Details

**Python extension** (`python`):
- Provides tree-sitter grammar and language server integration
- Bundles basedpyright (fork of pyright) -- no separate install needed
- The existing `settings.json` key `"pyright"` works with basedpyright too

**Ruff extension** (`ruff`):
- Provides ruff language server integration within Zed
- Ruff must be installed separately on the system (`brew install ruff`)
- Handles both linting and formatting; replaces black/isort/flake8

**R extension** (`r`):
- Provides tree-sitter grammar and r-language-server integration
- Requires `languageserver` R package to be installed in R
- Optionally supports Air (Posit's newer R formatter) as alternative to styler

### Important Notes for Guide Authors

1. **Zed auto-installs extensions**: The `auto_install_extensions` block in settings.json means users do NOT need to manually install Python, Ruff, or R extensions -- they install automatically when Zed opens
2. **basedpyright vs pyright**: Zed now defaults to basedpyright. The existing settings key `"pyright"` is still recognized. No user action needed.
3. **ruff replaces multiple tools**: The guide should explain that ruff replaces black, isort, flake8, and pylint for most use cases
4. **uv vs pip**: uv is the modern replacement for pip/pipx. The guide should recommend uv but mention pip as fallback
5. **R packages must be installed from within R**: Unlike Python tools, R's languageserver/lintr/styler are installed via `install.packages()` in an R console, not via Homebrew
6. **Warning about .Rprofile**: Custom startup messages in `.Rprofile` can break the R language server in Zed

## Decisions

- Recommend `brew install python` for Python (not pyenv/asdf), consistent with installation.md's Homebrew-first approach
- Recommend `brew install uv` for uv, as it follows the Homebrew pattern already established
- Recommend `brew install ruff` for ruff (system-wide), not `uv tool install`
- Do NOT recommend separate pyright installation; Zed bundles it
- Recommend `brew install r` for R, then `install.packages()` for R packages
- Guide structure should match installation.md: Check/Install/Verify pattern, beginner-friendly tone

## Recommendations

### python.md Structure

1. **Introduction**: Brief explanation of what Python is and why these tools matter
2. **Install Python**: `brew install python` with Check/Install/Verify
3. **Install uv**: `brew install uv` with Check/Install/Verify -- explain it as a modern pip replacement
4. **Install ruff**: `brew install ruff` with Check/Install/Verify -- explain it replaces black/isort/flake8
5. **Zed configuration**: Note that extensions auto-install; show the settings.json Python block for reference; explain pyright provides type checking and ruff provides linting/formatting
6. **Optional tools**: pytest, ipython (install via uv or pip)
7. **Verify in Zed**: Open a .py file, check that diagnostics and formatting work

### R.md Structure

1. **Introduction**: Brief explanation of what R is
2. **Install R**: `brew install r` with Check/Install/Verify
3. **Install R packages**: Open R console, run `install.packages()` for languageserver, lintr, styler
4. **Zed configuration**: Note that R extension auto-installs; show the settings.json R block for reference
5. **Troubleshooting**: .Rprofile warning
6. **Verify in Zed**: Open a .R file, check that diagnostics and formatting work

### installation.md Changes

- Add a brief mention near the top (after the quick-start block) that language-specific guides exist
- Add links at the bottom in "See also" section: `[python.md](python.md)` and `[R.md](R.md)`

## Risks and Mitigations

- **Risk**: Homebrew Python version changes can break virtual environments
  - **Mitigation**: Recommend uv for project-specific Python version management; mention `uv python install 3.12` as pinning option
- **Risk**: R package compilation failures on macOS (some packages need Xcode CLT)
  - **Mitigation**: Installation.md already covers Xcode CLT install; reference that section
- **Risk**: basedpyright vs pyright naming confusion
  - **Mitigation**: Note in the guide that Zed uses basedpyright (a pyright fork) by default; existing `"pyright"` settings key works for both

## Appendix

### Search Queries Used
- `install pyright ruff python lsp macOS homebrew 2026`
- `install R languageserver lintr styler macOS homebrew 2026`
- `zed editor python extension pyright ruff setup 2026`
- `zed editor R language extension setup languageserver 2026`
- `brew install ruff pyright uv python macOS 2026`

### Key References
- [Zed Python language docs](https://zed.dev/docs/languages/python)
- [Zed R language docs](https://zed.dev/docs/languages/r)
- [Ruff installation docs](https://docs.astral.sh/ruff/installation/)
- [Pyright installation docs](https://github.com/microsoft/pyright/blob/main/docs/installation.md)
- [R languageserver on CRAN](https://cran.r-project.org/web/packages/languageserver/readme/README.html)
- [Zed R extension](https://zed.dev/extensions/r)
- [uv documentation](https://docs.astral.sh/uv/)
- [Air (Posit R formatter) Zed setup](https://posit-dev.github.io/air/editor-zed.html)

### NixOS Source Files Consulted
- `/home/benjamin/.dotfiles/configuration.nix` (lines 496-526)
- `/home/benjamin/.dotfiles/home.nix` (lines 330-370)
- `/home/benjamin/.dotfiles/flake.nix` (lines 103-131, 340-350)
- `/home/benjamin/.config/zed/settings.json` (lines 70-158)
