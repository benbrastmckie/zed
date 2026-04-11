# R Setup

This guide walks through installing R and its development tools on macOS for use with Zed. By the end, you will have a working R environment with linting, formatting, and intelligent code completion.

## Before you begin

You need two tools that are covered in the main [Installation](installation.md) guide:

- **Xcode Command Line Tools** -- provides the compilers that some R packages need during installation
- **Homebrew** -- the package manager used to install R itself

If you followed [Installation](installation.md), you already have these. If not, complete the "Install Xcode Command Line Tools" and "Install Homebrew" sections there before continuing.

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

Homebrew downloads and installs R. This takes a few minutes because R includes many built-in components. When you see your terminal prompt again, it is finished.

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

## See also

- [Installation](installation.md) -- Prerequisites (Homebrew, Xcode CLT) and Zed setup
- [Python Setup](python.md) -- Python development environment guide
