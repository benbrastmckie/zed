# R Setup

## Quick install (script)

```
bash scripts/install/install-r.sh              # interactive
bash scripts/install/install-r.sh --dry-run    # preview only
bash scripts/install/install-r.sh --check      # presence report
```

Installs R via Homebrew and the editor packages `languageserver`, `lintr`, and `styler` (forcing `repos="https://cloud.r-project.org"` so CRAN does not prompt for a mirror). Optional sub-groups cover `renv`, Quarto, and the epidemiology R package bundle. Every action is guarded by a presence check and is safe to re-run. See [`scripts/install/install-r.sh`](../../scripts/install/install-r.sh) for the exact invocations. The manual walkthrough below is the source of truth for what the script automates.

## Manual installation (advanced)

This guide walks through installing R and its development tools for use with Zed. By the end, you will have a working R environment with linting, formatting, and intelligent code completion.

## Before you begin

You need Xcode Command Line Tools (compilers for R package installation) and Homebrew.

If you followed [Installation](../general/installation.md), you already have these. If not, complete the prerequisites sections there before continuing.

## Install R

R is the language interpreter that runs your R code. Homebrew installs the full R framework, including the interactive console and package manager.

### Check if already installed

```
R --version
```

If this prints a version number (e.g. `R version 4.4.1`), skip to [Install R packages](#install-r-packages).

### Install

```
brew install r
```

The package manager downloads and installs R. This takes a few minutes because R includes many built-in components. When you see your terminal prompt again, it is finished.

### Verify

```
R --version
```

You should see a line starting with `R version 4.x.x`. The exact number does not matter.

## Install R packages

Unlike Python tools, R development packages are installed from _within R itself_ rather than through Homebrew. You need three packages that work together to give you a full editing experience in Zed.

### Open the R console

```
R
```

This starts an interactive R session. You will see a welcome message and a prompt that looks like `>`. Type each of the commands below at that prompt.

### Install the packages

```r
install.packages("languageserver")
install.packages("lintr")
install.packages("styler")
```

Each command downloads and installs one package. You will see a lot of output as R compiles the code -- this is normal.

> **CRAN mirror prompt**: The first time you install packages, R may ask you to choose a CRAN mirror (a download server). Pick one geographically close to you, or just press Enter to use the default.

When all three are installed, exit R:

```r
q()
```

When asked "Save workspace image?", type `n` and press Enter. There is nothing to save.

### What each package does

- **languageserver** -- Provides code intelligence (autocomplete, go-to-definition, diagnostics) to Zed. This is the bridge between R and the editor.
- **lintr** -- Checks your R code for common issues and style problems. The language server uses lintr to show warnings and errors as you type.
- **styler** -- Formats your R code consistently. The language server uses styler to reformat your code when you save a file.

### Verify

Open a new R session and confirm each package loads without error:

```
R
```

```r
library(languageserver)
library(lintr)
library(styler)
q()
```

Type `n` when asked to save the workspace. If all three `library()` calls complete without an error message, the packages are installed correctly.

## Zed configuration

Zed automatically installs the R extension the first time you open an `.R` file -- you do not need to install it manually. The settings below are already included in your Zed configuration. They are shown here for reference so you understand what each piece does.

### R language settings

These tell Zed which language server to use for R files, enable format-on-save, and set the conventional 2-space indentation:

```jsonc
"R": {
  "tab_size": 2,
  "language_servers": ["r-language-server"],
  "format_on_save": "on",
  "formatter": {
    "language_server": {
      "name": "r-language-server"
    }
  }
}
```

### R language server settings

These enable diagnostic messages (the squiggly underlines on problems) and rich documentation in hover tooltips:

```jsonc
"r-language-server": {
  "settings": {
    "r": {
      "lsp": {
        "diagnostics": true,
        "rich_documentation": true
      }
    }
  }
}
```

### Auto-install extension

This tells Zed to install the R extension automatically:

```jsonc
"auto_install_extensions": {
  "r": true
}
```

## Troubleshooting

### Custom `.Rprofile` breaks the language server

If you have a `.Rprofile` file (in your home directory or project directory) that prints messages on startup (e.g. `cat("Welcome!\n")`), it can interfere with the R language server. The language server communicates with Zed over a protocol that expects clean output -- any extra text can break the connection.

**Fix**: Wrap startup messages in a check for interactive sessions:

```r
if (interactive()) {
  cat("Welcome!\n")
}
```

The language server runs in a non-interactive session, so this prevents it from seeing the extra output.

## Verify in Zed

Open any `.R` file in Zed, or create a quick test file:

```r
# test.R
x <- c(1, 2, 3)
mean(x)
```

Confirm these three things are working:

1. **Diagnostics** -- If you introduce a style issue (e.g. `x<-1` without spaces), a warning appears. This means lintr is running through the language server.
2. **Format on save** -- Save the file (**Cmd+S**) and watch the code reformat (e.g. spacing around `<-` is corrected). This means styler is running through the language server.
3. **Autocomplete** -- Start typing a function name (e.g. `mea`) and a suggestions popup appears. This means the language server is providing completions.

If all three work, your R environment is ready.

## Additional R tooling for extensions

The base R + `languageserver` + `lintr` + `styler` install above is enough for Zed's editor experience. The sections below cover extra tools needed by specific agent workflows (the `epidemiology` extension, rmcp MCP server, and Quarto-based reporting). Install these only if you plan to use those workflows.

### renv (project-local R package environments)

`renv` is R's project-local package manager (analogous to `uv` for Python). The epidemiology extension's `targets`/`renv` workflow expects each analysis project to have its own `renv.lock`.

#### Check

```
Rscript -e 'packageVersion("renv")'
```

If this prints a version (e.g. `1.0.7`), skip to [Quarto](#quarto).

#### Install

From an R console:

```r
install.packages("renv")
```

#### Verify

```
Rscript -e 'packageVersion("renv")'
```

You should see a version number. In a project directory, `Rscript -e 'renv::init()'` creates a new project-local library.

> **Network at runtime**: `renv::restore()` hits CRAN every time it runs. In a restricted environment, preflight the package cache.

### Quarto

Quarto is the document-rendering system used by the epidemiology extension for analysis reports. It bundles pandoc but still expects R (and optionally TeX) to render certain output types.

#### Check

```
quarto --version
```

#### Install

```
brew install --cask quarto
```

#### Verify

```
quarto --version
quarto check
```

`quarto check` runs a self-diagnostic and reports which rendering backends are available.

### rmcp MCP server prerequisite

The epidemiology extension optionally integrates the `rmcp` MCP server (R statistical modeling over MCP). `rmcp` itself is installed with `uvx` (see [python.md](python.md#install-uv)), but it requires a working R install at runtime, so the check belongs here:

```
Rscript -e 'R.version.string'
uvx rmcp --help 2>/dev/null || echo "not installed yet; see mcp-servers.md"
```

Full install and config instructions are in [mcp-servers.md](mcp-servers.md#rmcp-r-statistical-modeling-epidemiology).

### Epidemiology R packages

The epidemiology extension assumes a broad set of R packages (survival analysis, Bayesian modeling, causal inference, missing data, etc.). These are documented with purpose and example usage in [`.claude/context/project/epidemiology/tools/r-packages.md`](../../.claude/context/project/epidemiology/tools/r-packages.md); see [extensions.md](extensions.md#epidemiology) for the install snippet.

> **Stan / C++ toolchain**: packages that use Stan under the hood (`brms`, `EpiNow2`, `epidemia`) require a C++ compiler, provided by the Xcode Command Line Tools. If you followed [docs/general/installation.md](../general/installation.md), you already have these.

## See also

- [docs/general/installation.md](../general/installation.md) -- Prerequisites (build tools, package manager) and Zed setup
- [python.md](python.md) -- Python development environment guide
- [typesetting.md](typesetting.md) -- LaTeX, Typst, Pandoc for rendering R/Quarto output
- [mcp-servers.md](mcp-servers.md) -- rmcp MCP server install
- [extensions.md](extensions.md#epidemiology) -- Epidemiology extension prerequisite summary
- [docs/toolchain/README.md](README.md) -- Toolchain directory index
- [Main README](../../README.md) -- Repository overview and quick start
