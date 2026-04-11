# Python Setup

This guide walks through installing Python and its development tools on macOS for use with Zed. By the end, you will have a working Python environment with linting, formatting, and intelligent code completion.

## Before you begin

You need Homebrew and Xcode Command Line Tools installed. If you followed [Installation](installation.md), you already have these. If not, complete the prerequisites sections there first, then come back here.

## Install Python

Python is the programming language itself. Homebrew installs the latest Python 3.x release.

### Check if already installed

```
python3 --version
```

If this prints a version number (e.g. `Python 3.12.8`), skip to [Install uv](#install-uv).

### Install

```
brew install python
```

Homebrew downloads Python and its dependencies. When you see your terminal prompt again, it is finished.

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

## See also

- [Installation](installation.md) -- Prerequisites and base tool setup
- [R Setup](R.md) -- R language setup for macOS
