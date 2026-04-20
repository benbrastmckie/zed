# Python Setup

## Quick install (script)

```
bash scripts/install/install-python.sh              # interactive
bash scripts/install/install-python.sh --dry-run    # preview only
bash scripts/install/install-python.sh --check      # presence report
```

Installs `python3`, `uv` (with `uvx`), and `ruff` via Homebrew, then prompts for optional uv tools (`pytest`, `mypy`, `ipython`) and the filetypes packages (`pandas`, `openpyxl`, `python-pptx`, `python-docx`, `markitdown`, `xlsx2csv`, `pymupdf`, `pdfannots`). Every action is guarded by a presence check and is safe to re-run. See [`scripts/install/install-python.sh`](../../scripts/install/install-python.sh) for the exact invocations. The manual walkthrough below is the source of truth for what the script automates.

## Manual installation (advanced)

This guide walks through installing Python and its development tools for use with Zed. By the end, you will have a working Python environment with linting, formatting, and intelligent code completion.

## Before you begin

You need Homebrew and Xcode Command Line Tools installed. If you followed [Installation](../general/installation.md), you already have these. If not, complete the prerequisites sections there first, then come back here.

## Install Python

Python is the programming language itself. Your package manager installs the latest Python 3.x release.

### Check if already installed

```
python3 --version
```

If this prints a version number (e.g. `Python 3.12.8`), skip to [Install uv](#install-uv).

### Install

```
brew install python
```

The package manager downloads Python and its dependencies. When you see your terminal prompt again, it is finished.

### Verify

```
python3 --version
```

You should see a line like `Python 3.12.8`. The exact number does not matter as long as it is 3.10 or newer.

## Install uv

uv is a fast, modern package manager for Python. You will use it to install Python packages and manage project dependencies. It replaces the older `pip` tool that ships with Python.

### Check if already installed

```
uv --version
```

If this prints a version number (e.g. `uv 0.5.14`), skip to [Install ruff](#install-ruff).

### Install

```
brew install uv
```

### Verify

```
uv --version
```

You should see a version number like `uv 0.5.14`. The exact number does not matter.

## Install ruff

ruff is an all-in-one linter and formatter for Python. It checks your code for common mistakes (linting) and automatically applies consistent style (formatting). It replaces several older tools -- black, isort, flake8, and pylint -- with a single, much faster program.

### Check if already installed

```
ruff --version
```

If this prints a version number (e.g. `ruff 0.9.3`), skip to [Zed configuration](#zed-configuration).

### Install

```
brew install ruff
```

### Verify

```
ruff --version
```

You should see a version number like `ruff 0.9.3`. The exact number does not matter.

## Zed configuration

Zed handles most Python setup automatically. You do not need to install any extensions or configure anything manually -- the settings are already in place. This section explains what is happening behind the scenes so you understand each piece.

### Extensions

Zed auto-installs the **Python** and **Ruff** extensions the first time you open a `.py` file. You do not need to do anything. The relevant setting looks like this:

```jsonc
"auto_install_extensions": {
  "python": true,
  "ruff": true
}
```

### Type checking

Zed bundles **basedpyright**, a fork of pyright that provides type checking and intelligent code completion. There is nothing to install separately. The configuration tells pyright to use basic type checking and only analyze files you have open:

```jsonc
"pyright": {
  "settings": {
    "python.analysis": {
      "typeCheckingMode": "basic",
      "diagnosticMode": "openFilesOnly"
    }
  }
}
```

### Language settings

The Python language settings configure ruff as the formatter and enable format-on-save:

```jsonc
"Python": {
  "language_servers": ["pyright", "ruff"],
  "format_on_save": "on",
  "formatter": [
    {
      "language_server": {
        "name": "ruff"
      }
    }
  ],
  "tab_size": 4
}
```

These settings are already included in your Zed configuration. They are shown here for reference so you understand what each piece does.

## Optional tools

These tools are not required but are useful for Python development. You can install them globally or per-project.

### pytest (test runner)

pytest is the most popular testing framework for Python. Install it globally so it is available in any project:

```
uv tool install pytest
```

Or install it as a development dependency in a specific project:

```
uv add --dev pytest
```

### ipython (interactive REPL)

ipython is an enhanced Python shell with syntax highlighting and tab completion. It is useful for experimenting with code:

```
uv tool install ipython
```

## Verify in Zed

Open any `.py` file in Zed, or create a quick test file to confirm everything works:

1. **Create a test file**: Open Zed and create a new file called `test_setup.py` with some intentionally messy code:

   ```python
   import os
   import   sys
   x:int=1
   print( x)
   ```

2. **Check ruff diagnostics**: You should see yellow or red squiggles on lines with style issues (extra spaces, missing whitespace around operators).

3. **Check format on save**: Save the file (**Cmd+S**). Ruff should automatically fix the formatting -- extra spaces are removed, spacing around `=` and `:` is normalized.

4. **Check pyright type checking**: Hover over the variable `x`. You should see its type (`int`) displayed in a tooltip.

If all three checks pass, your Python environment is ready.

## Additional Python tooling for extensions

The base Python + `uv` + `ruff` install above covers Zed's editor experience. The sections below are needed by specific agent workflows — MCP servers, filetypes conversions, and testing/typechecking used by the `python` extension's quality gates. Install only what your workflows need.

### uvx (ephemeral tool runner)

`uvx` ships with `uv` (you installed it above). It runs a tool in an ephemeral venv, fetching the package on first invocation and caching it locally. Several MCP servers in this repo are launched via `uvx`:

- `rmcp` (epidemiology) — `uvx rmcp`
- `markitdown-mcp` — `uvx markitdown-mcp`
- `mcp-pandoc` — `uvx mcp-pandoc`

#### Check

```
uvx --version
```

If this prints a version, `uvx` is available.

#### Install

`uvx` is part of `uv` — no separate install. If `uvx --version` fails after `brew install uv`, reinstall `uv`.

#### Verify

```
uvx --help
```

> **Network at runtime**: `uvx <tool>` fetches the tool and its dependencies on first invocation. In a restricted environment, pre-cache by running each `uvx` command once while online.

### pytest (test runner)

Required by the `python` extension's test loop and by some agent workflows.

#### Check

```
pytest --version
```

#### Install

```
uv tool install pytest
```

Or per-project: `uv add --dev pytest`.

#### Verify

```
pytest --version
```

### mypy (type checker)

Used by the `python` extension's lint gate alongside `ruff`.

#### Check

```
mypy --version
```

#### Install

```
uv tool install mypy
```

#### Verify

```
mypy --version
```

### Python packages for filetypes conversions

The `filetypes` extension assumes several Python packages are importable (they back `/convert`, `/table`, `/scrape`, and related commands):

| Package | Purpose |
|---------|---------|
| `pandas` | Spreadsheet reading, `DataFrame.to_latex()` |
| `openpyxl` | XLSX read/write (required by pandas for .xlsx) |
| `python-pptx` | Slide extraction from .pptx |
| `python-docx` | DOCX reading |
| `markitdown` | Universal "X to Markdown" converter |
| `xlsx2csv` | Fallback XLSX extractor |
| `pymupdf` | PDF text/image extraction |
| `pdfannots` | PDF annotation extraction (`/scrape`) |

See [`.claude/context/project/filetypes/tools/dependency-guide.md`](../../.claude/context/project/filetypes/tools/dependency-guide.md) for the authoritative list.

#### Check

```
python3 -c "import pandas, openpyxl, pptx, markitdown; print('OK')"
```

#### Install

```
pip3 install pandas openpyxl python-pptx python-docx markitdown xlsx2csv pymupdf pdfannots
```

Or, using a venv (recommended if you do not want to pollute system Python):

```
python3 -m venv ~/.venvs/claude-filetypes
source ~/.venvs/claude-filetypes/bin/activate
pip install pandas openpyxl python-pptx python-docx markitdown xlsx2csv pymupdf pdfannots
```

#### Verify

```
python3 -c "import pandas, openpyxl, pptx, docx, markitdown, fitz; print('OK')"
```

Note: `pymupdf` imports as `fitz`; `python-pptx` imports as `pptx`; `python-docx` imports as `docx`.

### Node.js / npx (not Python, but referenced here)

A few MCP servers are installed via `npm`/`npx` rather than Python. Node.js is covered in [docs/general/installation.md](../general/installation.md#install-nodejs); mentioned here so the reader knows it is a hard prerequisite for `obsidian-memory`, `@superdoc-dev/mcp`, and Slidev if you use it. Verify with:

```
node --version
npx --version
```

## See also

- [docs/general/installation.md](../general/installation.md) -- Prerequisites and base tool setup
- [r.md](r.md) -- R language setup
- [typesetting.md](typesetting.md) -- LaTeX, Typst, Pandoc install
- [mcp-servers.md](mcp-servers.md) -- MCP servers launched via uvx
- [docs/toolchain/README.md](README.md) -- Toolchain directory index
- [Main README](../../README.md) -- Repository overview and quick start
