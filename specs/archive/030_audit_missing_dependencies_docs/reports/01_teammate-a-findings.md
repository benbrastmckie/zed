# Teammate A: Primary Inventory

**Task**: 30 - Audit .claude/ for assumed external dependencies
**Started**: 2026-04-10T00:00:00Z
**Completed**: 2026-04-10T01:00:00Z
**Effort**: ~60 min (systematic grep + file reads across all .claude/ subdirectories)
**Scope**: `/home/benjamin/.config/zed/.claude/` — skills, agents, commands, rules, scripts, hooks, context, settings

---

## Key Findings

- **~55 distinct external dependencies** are assumed across the .claude/ system, spread over 8 extension domains.
- **Language toolchains** (LaTeX, Typst, R, Python, Lean/Lake) are the most deeply embedded — invoked directly in agent `Bash` steps and whitelisted in `settings.json`.
- **CLI utilities** (jq, pandoc, markitdown, pdfannots, xlsx2csv, wezterm, piper) are assumed present but most have NO installation docs in core setup guides.
- **MCP servers** (lean-lsp, rmcp, SuperDoc/superdoc-dev, obsidian-memory, markitdown-mcp, mcp-pandoc) vary widely: lean-lsp has a dedicated setup script; most others have only in-context documentation.
- **Python packages** (pymupdf, pypdf, pikepdf, python-pptx, python-docx, markitdown, pandas, openpyxl, xlsx2csv) are used as fallback tools by filetypes agents — install hints appear in agent error messages only.
- **R packages** (~45+ packages) are assumed available for epi tasks; r-packages.md documents them but no installation script exists.
- **The only consolidated dependency installation guide** is `context/project/filetypes/tools/dependency-guide.md` (filetypes extension only). No equivalent exists for LaTeX, Typst, Python toolchain, R, Lean, or hooks infrastructure.
- **settings.json** explicitly whitelists `Bash(lake *)`, `Bash(pdflatex *)`, `Bash(latexmk *)`, `Bash(bibtex *)`, `Bash(biber *)` — confirming these are operationally required, not just documented.

---

## Dependency Inventory

### Language Toolchains

| Tool | Used by (extension/skill) | Key Reference (file:line) | Purpose |
|------|--------------------------|--------------------------|---------|
| `typst` | typst extension, filetypes, present | `agents/typst-implementation-agent.md:31`, `settings.json` (not whitelisted — missing!) | Compile .typ to PDF |
| `pdflatex` | latex extension, filetypes | `agents/latex-implementation-agent.md:31`, `settings.json:6` | LaTeX PDF compilation |
| `latexmk` | latex extension | `agents/latex-implementation-agent.md:32`, `settings.json:7` | Automated LaTeX build |
| `bibtex` | latex extension | `agents/latex-implementation-agent.md:33`, `settings.json:8` | Bibliography processing |
| `biber` | latex extension | `agents/latex-implementation-agent.md:33`, `settings.json:9` | BibLaTeX bibliography backend |
| `python3` / `python` | python extension, filetypes, epi | `agents/python-implementation-agent.md:32`, `agents/scrape-agent.md:102` | Python runtime for scripts and packages |
| `Rscript` / `R` | epi extension | `agents/epi-implement-agent.md:32`, `agents/epi-research-agent.md:191` | Execute R scripts |
| `lake` | lean extension (referenced, not present) | `settings.json:5`, `context/standards/git-safety.md:192` | Lean 4 build system |
| `quarto` | epi extension | `context/project/epidemiology/domain/r-workflow.md:145` | Reproducible document rendering |

**Gap**: `typst` is not whitelisted in `settings.json` (unlike pdflatex/latexmk/lake), meaning agent Bash calls to `typst compile` require interactive permission approval each time.

---

### CLI Utilities

| Tool | Used by | Key Reference (file:line) | Purpose |
|------|---------|--------------------------|---------|
| `jq` | hooks, scripts, all agents | `hooks/tts-notify.sh:38`, `scripts/validate-index.sh:41`, `settings.json` hook cmds | JSON parsing in shell scripts (required by all hooks) |
| `pandoc` | filetypes extension | `agents/document-agent.md:95`, `agents/presentation-agent.md:94` | Document format conversion (primary: DOCX→Markdown, Markdown→PDF/Beamer) |
| `markitdown` | filetypes extension | `agents/document-agent.md:110`, `commands/convert.md:363` | Office/PDF to Markdown (Python CLI tool via pip) |
| `pdfannots` | filetypes extension (scrape) | `agents/scrape-agent.md:108`, `commands/scrape.md:276` | PDF annotation extraction CLI fallback |
| `xlsx2csv` | filetypes extension | `agents/spreadsheet-agent.md:98` | XLSX to CSV fallback for spreadsheet conversion |
| `piper` | hooks (TTS) | `hooks/tts-notify.sh:163`, `docs/guides/tts-stt-integration.md:30` | Neural TTS for hook notifications |
| `aplay` / `paplay` | hooks (TTS) | `hooks/tts-notify.sh:164,160` | ALSA/PulseAudio audio playback for TTS |
| `wezterm` | hooks | `hooks/wezterm-notify.sh:40`, `hooks/tts-notify.sh:104` | Terminal tab detection for status display |
| `git` | git-workflow skill, all commands | `rules/git-workflow.md` | Version control (assumed present everywhere) |
| `gh` | merge command | `commands/merge.md` | GitHub CLI for PR creation |
| `uvx` | MCP setup, filetypes | `context/project/filetypes/tools/mcp-integration.md:24`, `scripts/setup-lean-mcp.sh:86` | Run Python-backed MCP servers (part of `uv`) |
| `make` | latex context | `context/project/latex/tools/compilation-guide.md:238` | Optional Makefile-based build |

---

### MCP Servers

| Server | Used by | Reference (file:line) | How Invoked | Setup Doc? |
|--------|---------|----------------------|-------------|-----------|
| `lean-lsp` | lean extension | `settings.json:27` (`mcp__lean-lsp__*`), `scripts/setup-lean-mcp.sh` | `uvx lean-lsp-mcp` via stdio | YES — `scripts/setup-lean-mcp.sh` + `scripts/verify-lean-mcp.sh` |
| `rmcp` | epi extension | `agents/epi-implement-agent.md:35`, `context/project/epidemiology/tools/mcp-guide.md:20` | `rmcp` command (pip install) | Partial — `mcp-guide.md` has config snippets |
| `superdoc` (`@superdoc-dev/mcp`) | filetypes extension (docx-edit) | `agents/docx-edit-agent.md:93`, `context/project/filetypes/tools/mcp-integration.md:91` | `npx -y @superdoc-dev/mcp` | Partial — `superdoc-integration.md` has tool inventory, no install guide |
| `obsidian-memory` (two options) | memory extension | `context/project/memory/memory-setup.md:74,141` | `npx @anthropic-ai/obsidian-claude-code-mcp@latest` OR `npx @dsebastien/obsidian-cli-rest-mcp@latest` | YES — `memory-setup.md` is comprehensive |
| `markitdown-mcp` | filetypes extension (optional) | `context/project/filetypes/tools/mcp-integration.md:24` | `uvx markitdown-mcp` | Partial — config snippet only in mcp-integration.md |
| `mcp-pandoc` | filetypes extension (optional) | `context/project/filetypes/tools/mcp-integration.md:60` | `uvx mcp-pandoc` | Partial — config snippet only |
| `neovim-lsp` | neovim extension (referenced) | `context/standards/task-management.md:100` | `uvx neovim-lsp-mcp` | None found in this repo |

---

### Library / Package Dependencies

#### Python Packages

| Package | Used by | Reference (file:line) | Install |
|---------|---------|----------------------|---------|
| `markitdown` | filetypes (document-agent) | `agents/document-agent.md:110` | `pip install markitdown` |
| `pymupdf` (`fitz`) | filetypes (scrape-agent) | `agents/scrape-agent.md:102` | `pip install pymupdf` |
| `pypdf` | filetypes (scrape-agent) | `agents/scrape-agent.md:105` | `pip install pypdf` |
| `pikepdf` | filetypes (scrape-agent) | `agents/scrape-agent.md:111` | `pip install pikepdf` |
| `pdfannots` | filetypes (scrape-agent) | `agents/scrape-agent.md:108` | `pip install pdfannots` |
| `python-pptx` | filetypes (presentation-agent) | `agents/presentation-agent.md:96` | `pip install python-pptx` |
| `python-docx` | filetypes (docx-edit-agent) | `agents/docx-edit-agent.md:97` | `pip install python-docx` |
| `pandas` | filetypes (spreadsheet-agent), present (budget/funds) | `agents/spreadsheet-agent.md:94` | `pip install pandas` |
| `openpyxl` | filetypes (spreadsheet-agent), present (budget/funds) | `agents/spreadsheet-agent.md:94`, `agents/budget-agent.md:237` | `pip install openpyxl` |
| `xlsx2csv` | filetypes (spreadsheet-agent) | `agents/spreadsheet-agent.md:98` | `pip install xlsx2csv` |
| `rmcp` | epi extension | `context/project/epidemiology/tools/mcp-guide.md:13` | `pip install rmcp` |
| `vosk` | TTS/STT integration (NixOS) | `docs/guides/tts-stt-integration.md:36` | NixOS/pip |
| `pytest` | python extension | `agents/python-implementation-agent.md:32` | `pip install pytest` |
| `mypy` | python extension | `agents/python-implementation-agent.md:34` | `pip install mypy` |
| `ruff` | python extension | `agents/python-implementation-agent.md:35` | `pip install ruff` |

#### R Packages (Epidemiology Extension)

| Category | Packages | Reference |
|----------|----------|-----------|
| Data management | `readr`, `dplyr`, `tidyr`, `janitor`, `labelled`, `skimr`, `here`, `lubridate`, `sjlabelled`, `REDCapR` | `domain/data-management.md` |
| Reproducibility | `targets`, `tarchetypes`, `renv` | `domain/r-workflow.md` |
| Survival | `survival`, `survminer`, `cmprsk`, `tidycmprsk` | `domain/study-designs.md`, `tools/r-packages.md` |
| Mixed models | `lme4`, `clubSandwich`, `fixest` | `domain/study-designs.md` |
| Survey | `survey` | `domain/study-designs.md` |
| Missing data | `mice`, `naniar`, `VIM` | `domain/missing-data.md`, `tools/r-packages.md` |
| Matching / weighting | `MatchIt`, `WeightIt`, `cobalt` | `domain/causal-inference.md`, `tools/r-packages.md` |
| Causal inference / DAGs | `dagitty`, `ggdag`, `mediation`, `marginaleffects` | `domain/causal-inference.md`, `tools/r-packages.md` |
| Sensitivity analysis | `episensr`, `EValue` | `tools/r-packages.md` |
| Bayesian | `brms`, `rstanarm`, `bayesplot` | `tools/r-packages.md` |
| Basic epi | `epitools`, `epiR`, `Epi`, `EpiEstim`, `EpiNow2`, `EpiModel`, `epidemia`, `epiparameter`, `surveillance` | `tools/r-packages.md`, `domain/study-designs.md` |
| Reporting / tables | `gtsummary`, `modelsummary`, `gt`, `flextable` | `tools/r-packages.md` |
| Visualization | `forestploter`, `patchwork` | `tools/r-packages.md` |
| Regression/validation | `rms`, `pROC`, `interactionR`, `ivreg`, `rdrobust` | `tools/r-packages.md`, `domain/study-designs.md` |
| Meta-analysis | `meta` | `domain/study-designs.md` |
| MCP integration | `mcptools` | `tools/mcp-guide.md` |

#### Lean 4 / Mathlib (Lean Extension — Not Present But Referenced)

| Dependency | Reference | Notes |
|------------|-----------|-------|
| Lean 4 toolchain (via `elan`) | `context/routing.md:9`, `settings.json:5` | `lake` build tool requires Lean installation via `elan` |
| Mathlib4 | `skills/skill-git-workflow/SKILL.md:139` | Referenced as "Mathlib dependencies" in lake-manifest.json |
| `lean-lsp-mcp` | `scripts/setup-lean-mcp.sh:86` | Python package installed via `uvx` |

#### Typst Packages (Referenced in Context)

| Package | Used for | Reference |
|---------|----------|-----------|
| `fletcher` | Commutative diagrams | `context/project/typst/patterns/fletcher-diagrams.md`, `CLAUDE.md:583` |
| Touying / Polylux | Slide presentations | `context/project/filetypes/patterns/touying-pitch-deck-template.md` |
| `cetz` | Drawings | Typst packages context |
| Various `@preview/*` packages | Document formatting | `context/project/typst/typst-packages.md` |

---

## Evidence / Examples

### 1. pdflatex/latexmk directly invoked in agent (latex-implementation-agent.md:40-54)
```
pdflatex document.tex
pdflatex document.tex  # Second pass for cross-references
...
latexmk -pdf document.tex
```

### 2. typst compile directly invoked in agent (typst-implementation-agent.md:39)
```
typst compile document.typ
```

### 3. Rscript invoked in epi-implement-agent.md:32
```
- Bash - Execute R scripts via `Rscript`, run file operations, inspect outputs
```

### 4. lake explicitly whitelisted in settings.json:5
```json
"Bash(lake *)"
```

### 5. jq required in all hook scripts (hooks/tts-notify.sh:38-39)
```bash
if [[ -n "$STDIN_JSON" ]] && command -v jq &>/dev/null; then
    HOOK_EVENT_NAME=$(echo "$STDIN_JSON" | jq -r '.hook_event_name // empty' 2>/dev/null || echo "")
```

### 6. pymupdf/pypdf/pikepdf Python import detection (scrape-agent.md:102-111)
```bash
python3 -c "import fitz" 2>/dev/null && echo "pymupdf"
python3 -c "import pypdf" 2>/dev/null && echo "pypdf"
python3 -c "import pikepdf" 2>/dev/null && echo "pikepdf"
```

### 7. pandoc fallback in document-agent.md:112-113
```bash
# Fallback: pandoc (if markitdown unavailable)
pandoc -f docx -t markdown -o "$output_path" "$source_path"
```

### 8. MCP server config for lean-lsp (setup-lean-mcp.sh:82-92)
```json
{
  "type": "stdio",
  "command": "uvx",
  "args": ["lean-lsp-mcp"],
  "env": {
    "LEAN_PROJECT_PATH": "$PROJECT_PATH"
  }
}
```

### 9. rmcp installed via pip (mcp-guide.md:13)
```bash
pip install rmcp
```

### 10. superdoc MCP via npx (mcp-integration.md:89-94)
```json
{
  "mcpServers": {
    "superdoc": {
      "command": "npx",
      "args": ["-y", "@superdoc-dev/mcp"]
    }
  }
}
```

---

## Documentation Coverage Assessment

| Extension / Domain | Dependency Docs | Gap Severity |
|-------------------|----------------|--------------|
| filetypes | `dependency-guide.md` — good coverage for NixOS/Ubuntu/macOS | Low |
| memory | `memory-setup.md` — comprehensive Obsidian setup | Low |
| lean | `setup-lean-mcp.sh` + `verify-lean-mcp.sh` scripts; no prose guide | Medium |
| latex | Compilation commands documented; no toolchain install guide | High |
| typst | Compilation commands documented; no install guide; `typst` not in settings.json | High |
| epi (R) | `r-packages.md` documents ~45 packages; no R installation or renv/Quarto setup | High |
| python | Extension commands documented; no toolchain or pip env setup guide | Medium |
| hooks (TTS/wezterm) | `tts-stt-integration.md` covers NixOS well; no guide for other distros | Medium |
| present (Slidev) | Slidev referenced in JSON themes but NO documentation found anywhere | Critical |
| lean (elan/mathlib) | No installation guide; lean extension listed in README but not present | High |

---

## Confidence Level

**High** — based on:
- Exhaustive grep across all `.claude/` subdirectories for 30+ tool/binary names
- Confirmed actual invocations in agent Bash steps (not just mentions)
- Cross-referenced against settings.json whitelist (authoritative for "operationally required" tools)
- Read full content of key agent files and context documents
- ~250 grep hits examined across skills, agents, commands, rules, hooks, scripts, context

Minor uncertainty: the lean extension files are only referenced (via routing.md, CLAUDE.md, scripts) but the extension directory itself does not exist at `.claude/extensions/lean/` — meaning lean4-research-agent, lean4-implementation-agent are referenced but not present. This is noted as a structural gap separate from the dependency gap.
