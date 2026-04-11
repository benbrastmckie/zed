# Extension Prerequisites

> **This page is a router, not an installer.** It maps each extension to the tools it needs, but the actual install commands live in the group-specific files ([shell-tools.md](shell-tools.md), [python.md](python.md), [r.md](r.md), [typesetting.md](typesetting.md), [mcp-servers.md](mcp-servers.md)) and in the wizard at [`scripts/install/install.sh`](../../scripts/install/). There is no `install-extensions.sh`; the extension-specific extras live in their natural-home scripts (for example, the epidemiology R bundle is under [`install-r.sh`](../../scripts/install/install-r.sh)).

This file is a per-extension quick reference: for each active extension in this repository, what external tools it assumes, and where in `docs/toolchain/` those tools are documented. Use it as an onboarding checklist when you first load an extension, and as a rollback reference when something is not working.

Active extensions (from `.claude/extensions.json`):

- [latex](#latex)
- [typst](#typst)
- [epidemiology](#epidemiology)
- [filetypes](#filetypes)
- [present](#present)
- [memory](#memory)

Each extension section lists: (1) what the extension does, (2) its hard prerequisites with cross-links to other toolchain docs, (3) any extension-specific extras not covered elsewhere, and (4) a one-line check command.

## Template note: Check / Install / Verify

Unlike the other files in `docs/toolchain/`, this file is a **per-extension router**: its Install and Verify steps delegate to the tool-specific docs (`r.md`, `python.md`, `typesetting.md`, `mcp-servers.md`) rather than repeating install commands. Each extension section below has:

### Check

A single command listing the binaries / Python modules / MCP servers the extension needs, runnable as-is.

### Install

Cross-links to the relevant toolchain files where the actual `brew install` / `pip install` commands live.

### Verify

Follow the Verify sections of the linked files, then re-run the Check command above. This keeps install instructions in one place (the tool doc) and per-extension summaries in this file.

## latex

The `latex` extension provides research + implementation support for LaTeX documents (VimTeX-equivalent compile/view/clean workflows, subfile management, bibliography handling).

**Prerequisites**:

- **LaTeX distribution** (`pdflatex`, `latexmk`, `bibtex`, `biber`) — see [typesetting.md#latex-mactex-or-basictex](typesetting.md#latex-mactex-or-basictex).
- **Fonts** (Latin Modern Math, CMU) for math/text rendering — see [typesetting.md#fonts](typesetting.md#fonts).

**Extension-specific extras**: none beyond the typesetting toolchain.

**Check**:

```
command -v pdflatex latexmk bibtex biber
```

All four should resolve.

## typst

The `typst` extension provides research + implementation support for Typst documents (fast compile, modern syntax, Fletcher diagrams).

**Prerequisites**:

- **Typst** (`typst` binary) — see [typesetting.md#typst](typesetting.md#typst).
- **Fonts** (Latin Modern Math, Noto) for math/text — see [typesetting.md#fonts](typesetting.md#fonts).
- **`Bash(typst *)` in `settings.json` allowlist** — required so agent `typst compile` calls do not prompt for approval. Checked by Phase 6 of task 30.

**Extension-specific extras**: none; Typst auto-fetches packages from `packages.typst.app` at first compile (requires network).

**Check**:

```
command -v typst
jq -r '.permissions.allow[]' .claude/settings.json | grep -q 'typst' && echo "allowlist: OK"
```

## epidemiology

The `epidemiology` extension provides research + implementation support for R-based epidemiology workflows (study design, statistical modeling, causal inference, Bayesian analysis).

**Prerequisites**:

- **R** (`R`, `Rscript`) + `languageserver`, `lintr`, `styler` — see [r.md](r.md).
- **`renv`** for project-local package environments — see [r.md#renv-project-local-r-package-environments](r.md#renv-project-local-r-package-environments).
- **Quarto** for analysis reports — see [r.md#quarto](r.md#quarto).
- **`uv` / `uvx`** for running the rmcp MCP server — see [python.md#uvx-ephemeral-tool-runner](python.md#uvx-ephemeral-tool-runner).
- **`rmcp` MCP server** (optional) — see [mcp-servers.md#rmcp-r-statistical-modeling-epidemiology](mcp-servers.md#rmcp-r-statistical-modeling-epidemiology).
- **C++ toolchain** (Xcode Command Line Tools) for Stan-backed packages — already required by the base install.

**Extension-specific extras**: a broad set of R packages for survival analysis, Bayesian modeling, causal inference, and missing data. The authoritative reference is [`.claude/context/project/epidemiology/tools/r-packages.md`](../../.claude/context/project/epidemiology/tools/r-packages.md).

Minimum install snippet (run inside R for a project using `renv`):

```r
renv::init()
install.packages(c(
  # Core modeling
  "survival", "survminer", "lme4", "glmnet", "mgcv",
  # Bayesian
  "brms", "rstanarm",
  # Causal inference
  "MatchIt", "WeightIt", "marginaleffects", "dagitty",
  # Missing data
  "mice", "VIM",
  # Epidemiology-specific
  "EpiModel", "EpiEstim", "EpiNow2", "epiparameter",
  "epitools", "Epi",
  # Reporting
  "gtsummary", "flextable", "kableExtra",
  # Tidyverse + data management
  "tidyverse", "here", "targets", "tarchetypes",
  # Language tooling (repeat from r.md, safe to re-run)
  "languageserver", "lintr", "styler"
))
```

> Stan-backed packages (`brms`, `EpiNow2`, `epidemia` if used) compile C++ on install. The first `install.packages("brms")` can take 15-20 minutes.

**Check**:

```
command -v R Rscript quarto
Rscript -e 'packageVersion("renv"); packageVersion("survival"); packageVersion("brms")'
```

## filetypes

The `filetypes` extension handles file-format conversion: `/convert`, `/table`, `/scrape`, `/edit`.

**Prerequisites** (base install covers SuperDoc + openpyxl MCP servers; the rest live here):

- **Node.js / npx** — see [docs/general/installation.md#install-nodejs](../general/installation.md#install-nodejs).
- **`@superdoc-dev/mcp`** (DOCX editing) — see [docs/general/installation.md#superdoc--word-document-editing](../general/installation.md#superdoc--word-document-editing).
- **`@jonemo/openpyxl-mcp`** (XLSX editing) — see [docs/general/installation.md#openpyxl--spreadsheet-editing](../general/installation.md#openpyxl--spreadsheet-editing).
- **Pandoc** — see [typesetting.md#pandoc](typesetting.md#pandoc).
- **markitdown** — see [typesetting.md#markitdown](typesetting.md#markitdown).
- **Python packages** (`pandas`, `openpyxl`, `python-pptx`, `python-docx`, `pymupdf`, `xlsx2csv`, `pdfannots`) — see [python.md#python-packages-for-filetypes-conversions](python.md#python-packages-for-filetypes-conversions).
- **Typst** (for slide output via Touying/Polylux) — see [typesetting.md#typst](typesetting.md#typst).
- **LaTeX / `pdflatex`** (for Beamer slide output) — see [typesetting.md#latex-mactex-or-basictex](typesetting.md#latex-mactex-or-basictex).

**Extension-specific extras**: the authoritative per-package reference is [`.claude/context/project/filetypes/tools/dependency-guide.md`](../../.claude/context/project/filetypes/tools/dependency-guide.md).

**Check**:

```
command -v pandoc markitdown typst pdflatex
python3 -c "import pandas, openpyxl, pptx, docx, fitz; print('OK')"
claude mcp list | grep -E "superdoc|openpyxl"
```

## present

The `present` extension produces grant proposals and research presentations in Typst (via Touying) and optionally Slidev (markdown-based slides).

**Prerequisites**:

- **Typst** — see [typesetting.md#typst](typesetting.md#typst). This is the primary slide-generation path for talks in this repo.
- **Fonts** (Noto family, Latin Modern) — see [typesetting.md#fonts](typesetting.md#fonts).
- **Pandoc** (occasionally used for source-material conversion) — see [typesetting.md#pandoc](typesetting.md#pandoc).

**Slidev decision**: The `present` extension's talk library (`.claude/context/project/present/talk/`) ships Slidev-compatible markdown templates and Vue components (`FigurePanel.vue`, `DataTable.vue`, etc.), but in this repo the default talk output path is **Typst Touying**, not Slidev. Slidev is therefore **optional** — install it only if you want to build slides from the Slidev templates. If you do:

```
npm install -g @slidev/cli
```

Verify with `slidev --version`. Most users can skip this.

**Grant templates** use Typst (e.g. `templates/typst/research-timeline.typ`), so the Typst install covers them.

**Check**:

```
command -v typst pandoc
# Slidev (only if you use it):
command -v slidev 2>/dev/null && echo "slidev: optional, installed" || echo "slidev: not installed (OK)"
```

## memory

The `memory` extension backs `/learn`, memory search, and the `/research --remember` flag with an Obsidian-backed vault.

**Prerequisites**:

- **Obsidian desktop app** — user-installed (not Homebrew-installable reliably; see [obsidian.md](https://obsidian.md)).
- **Node.js / npx** — see [docs/general/installation.md#install-nodejs](../general/installation.md#install-nodejs).
- **obsidian-memory MCP server** — see [mcp-servers.md#obsidian-memory-memory-vault](mcp-servers.md#obsidian-memory-memory-vault).
- **Obsidian plugin** ("Claude Code MCP" or "Local REST API") — installed from within Obsidian.

**Extension-specific extras**: the `.memory/` vault directory itself lives at the repo root; the extension creates it on first `/learn` if absent.

**Check**:

```
ls .memory/ 2>/dev/null && echo "vault: OK"
claude mcp list | grep -E "obsidian|memory"
```

## See also

- [docs/toolchain/README.md](README.md) — toolchain directory index
- [docs/general/installation.md](../general/installation.md) — base install (Homebrew, Node, Zed, Claude Code CLI, SuperDoc, openpyxl)
- [`.claude/extensions.json`](../../.claude/extensions.json) — authoritative list of currently-loaded extensions
