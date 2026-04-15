# Typesetting Toolchain

## Quick install (script)

```
bash scripts/install/install-typesetting.sh              # interactive
bash scripts/install/install-typesetting.sh --dry-run    # preview only
bash scripts/install/install-typesetting.sh --check      # presence report
```

Prompts for LaTeX (BasicTeX by default, MacTeX on opt-in), Typst, Pandoc, `markitdown` (via `uv tool install`), and the Latin Modern / Computer Modern / Noto font family. `.claude/settings.json`'s `Bash(typst *)` allowlist is a separate concern and is **not** managed by this script. Every action is guarded by a presence check and is safe to re-run. See [`scripts/install/install-typesetting.sh`](../../scripts/install/install-typesetting.sh) for the exact invocations. The manual walkthrough below is the source of truth for what the script automates.

## Manual installation (advanced)

This guide installs the typesetting tools used by the `latex`, `typst`, `filetypes`, and `present` extensions. These tools are grouped here because they are usually installed together for document output: LaTeX and Typst as the two PDF-producing engines, Pandoc as the universal format bridge, markitdown for "anything to Markdown" extraction, and a minimal set of fonts that LaTeX and Typst expect to find on disk.

If you are only using one of these (e.g. just Typst), you can install just that tool — the sections are independent.

## Before you begin

Homebrew is required. If you do not have it set up, follow [docs/general/installation.md](../general/installation.md) first.

Some tools (notably `markitdown`) are installed with `uv tool install`, which requires `uv`. See [python.md](python.md#install-uv) for the install.

## LaTeX (MacTeX or BasicTeX)

The `latex` extension, LaTeX compilation workflows, and Beamer slide output all assume a working LaTeX distribution with `pdflatex`, `latexmk`, `bibtex`, and `biber`.

**macOS** has two Homebrew-friendly LaTeX distributions:

- **BasicTeX** -- small (~100 MB), minimal, install extra packages later via `tlmgr`. Recommended unless you know you need the full MacTeX.
- **MacTeX** -- full (~5 GB), installs everything. Use if you are processing third-party LaTeX documents with unknown package requirements.

### Check

```
pdflatex --version
latexmk --version
```

If both print version numbers, skip to [Typst](#typst).

### Install

**macOS -- BasicTeX** (recommended):

```
brew install --cask basictex
```

After install, add the TeX binaries to your PATH for the current shell session:

```
eval "$(/usr/libexec/path_helper)"
```

Open a new terminal to pick up the change persistently.

Then install the extra packages that Beamer / LaTeX workflows expect:

```
sudo tlmgr update --self
sudo tlmgr install latexmk collection-fontsrecommended collection-latexextra biber
```

**macOS -- Full MacTeX** (alternative):

```
brew install --cask mactex
```

### Verify

```
pdflatex --version
latexmk --version
bibtex --version
biber --version
```

All four should print version numbers.

## Typst

Typst is the modern single-pass typesetting alternative to LaTeX. The `typst` extension, `present` talk output, and `filetypes` slide conversion all use it.

### Check

```
typst --version
```

If this prints a version (e.g. `typst 0.12.0`), skip to [Pandoc](#pandoc).

### Install

```
brew install typst
```

### Verify

```
typst --version
```

Smoke-test a compile:

```
echo '= Hello' > /tmp/hello.typ && typst compile /tmp/hello.typ /tmp/hello.pdf && ls -l /tmp/hello.pdf
```

You should see a non-empty `hello.pdf`.

> **Network at runtime**: Typst fetches packages from `packages.typst.app` on first compile of a file that `#import`s a new package (e.g. `fletcher`, `cetz`, Touying, Polylux). Compile each new document once while online to populate the package cache.
>
> **Settings.json allowlist**: `Bash(typst *)` must be present in `.claude/settings.json`'s `permissions.allow` array so agent `typst compile` calls do not prompt for interactive approval. This is configured in this repo; if you cloned it fresh, check `jq -r '.permissions.allow[]' .claude/settings.json | grep typst`.

## Pandoc

Pandoc is the universal document converter — it backs `/convert` in the `filetypes` extension and several `mcp-pandoc` code paths.

### Check

```
pandoc --version
```

### Install

```
brew install pandoc
```

### Verify

```
pandoc --version
```

## markitdown

Microsoft's "anything to Markdown" converter, used by the `filetypes` extension for PDF/DOCX/XLSX/PPTX extraction and by the `markitdown-mcp` MCP server.

### Check

```
markitdown --help
```

### Install

Install as a user tool via `uv`:

```
uv tool install markitdown
```

Or as a Python package in a venv:

```
pip3 install markitdown
```

### Verify

```
markitdown --help
```

A smoke-test on a file:

```
echo '# test' > /tmp/test.md && markitdown /tmp/test.md
```

## Fonts

Both LaTeX and Typst expect a small set of fonts to be present on disk. Without them, compilation either falls back silently or errors out with font-substitution warnings.

Commonly required fonts:

- **Latin Modern Math** — default math font for LaTeX, referenced by Typst math environments.
- **Computer Modern Unicode (CMU)** — traditional LaTeX text font, referenced by some Typst templates.
- **Noto** — broad Unicode coverage (CJK, symbols); several Slidev and Typst presentation themes reference it.

### Check

Does the font show up in `fc-list`?

```
fc-list | grep -i "latin modern"
fc-list | grep -i "cmu"
fc-list | grep -i "noto"
```

(Install `fontconfig` via `brew install fontconfig` if `fc-list` is missing.)

### Install

**macOS** -- Homebrew provides these fonts via casks (now in core, no separate tap needed):

```
brew install --cask font-latin-modern font-latin-modern-math
brew install --cask font-computer-modern
brew install --cask font-noto-sans font-noto-serif font-noto-sans-mono
```

If a cask name is not found, use `brew search font-<name>` to locate the current formula name.

### Verify

```
fc-list | grep -i "latin modern math"
```

A non-empty line confirms the font is installed and visible to typesetting tools.

## Extension cross-references

- The `latex` extension's implementation agent assumes `pdflatex` and `latexmk` are on PATH — see [extensions.md](extensions.md#latex).
- The `typst` extension assumes `typst` is on PATH and whitelisted in `settings.json` — see [extensions.md](extensions.md#typst).
- The `filetypes` extension uses Pandoc and markitdown for its conversion pipeline — see [extensions.md](extensions.md#filetypes) and [`.claude/context/project/filetypes/tools/dependency-guide.md`](../../.claude/context/project/filetypes/tools/dependency-guide.md).
- The `present` extension uses Typst for talks (Touying) and optionally Slidev; see [extensions.md](extensions.md#present).

## See also

- [docs/general/installation.md](../general/installation.md) — base Homebrew / Node.js / Zed install
- [python.md](python.md#install-uv) — `uv` install (required for `uv tool install markitdown`)
- [mcp-servers.md](mcp-servers.md) — `markitdown-mcp` and `mcp-pandoc` MCP servers that wrap these tools
- [extensions.md](extensions.md) — which extensions use which tools
- [docs/toolchain/README.md](README.md) — toolchain directory index
