# Teammate B: Documentation Gaps & Prior Art

**Task**: 30 - Audit .claude/ for assumed external dependencies and find what's missing from installation docs
**Started**: 2026-04-10T00:00:00Z
**Completed**: 2026-04-10T01:00:00Z
**Effort**: 1 hour
**Sources/Inputs**: Codebase (extensions.json, extension READMEs, manifest.json files, docs/)
**Artifacts**: This report

---

## Key Findings

1. **The main install doc (`docs/general/installation.md`) covers exactly two MCP tools** (SuperDoc, openpyxl) — the minimum required for the default active extensions. But four other active extensions carry undocumented external dependencies: the **epidemiology** extension requires R + an optional `rmcp` pip package; the **memory** extension requires Obsidian + Node.js/npx; the **present** extension produces Slidev-format output requiring Node.js; the **latex** and **typst** extensions assume `pdflatex`/`latexmk`/`typst` CLI tools available on PATH.

2. **All 14 extension source directories** (in `nvim/.claude/extensions/`) have both a `manifest.json` and a `README.md`. The `manifest.json` schema includes a `dependencies` field, but **every extension sets it to an empty array `[]`**. This field is documented as "Other extensions that must be loaded first" — it tracks inter-extension dependencies only, not external tool dependencies.

3. **The manifest.json schema has no field for external tool prerequisites** (e.g., CLI tools, pip packages, API keys, MCP servers). MCP server declarations do exist in `manifest.json` under `mcp_servers`, but only list the server config — not the runtime prerequisites needed to make the server work.

4. **Only the filetypes extension** has a dedicated `tools/dependency-guide.md` with multi-platform install instructions (NixOS, Ubuntu/Debian, macOS). No other active extension provides equivalent depth.

5. **The check-extension-docs.sh script** validates README presence, EXTENSION.md presence, manifest.json presence, manifest entry file existence, and command mentions in README — but does **not** validate that external dependencies are documented. This gap means dependency documentation drift is invisible to CI.

6. **The extension source directory is in the nvim config**, not in the zed config. The zed config tracks loaded extensions via `extensions.json` (flat file) and copies files from the nvim source. This means: READMEs and dependency docs live in `nvim/.claude/extensions/*/`, but users of the zed config follow `docs/general/installation.md` in the zed config — creating a documentation split.

---

## Existing Install Documentation

| File | Summary |
|------|---------|
| `/home/benjamin/.config/zed/README.md` | Top-level repo README; lists Homebrew + Zed + Claude Code as prerequisites; references installation.md for details; mentions MCP tools for Office editing |
| `/home/benjamin/.config/zed/docs/general/installation.md` | Primary install guide; covers Xcode CLT, Homebrew, Node.js, Zed, Claude Code CLI, claude-acp bridge, SuperDoc MCP, openpyxl MCP; verify checklist at end |
| `/home/benjamin/.config/zed/docs/general/python.md` | Python interpreter, uv, ruff setup via Homebrew; Zed auto-installs Python/Ruff extensions |
| `/home/benjamin/.config/zed/docs/general/R.md` | R via Homebrew; languageserver, lintr, styler via `install.packages()` in R console |
| `/home/benjamin/.config/zed/docs/general/README.md` | Index of general docs; reading order for new users |
| `/home/benjamin/.config/zed/docs/general/settings.md` | Settings.json / keymap.json / tasks.json walkthrough; includes agent_servers reference |
| `/home/benjamin/.config/zed/docs/general/keybindings.md` | Keyboard shortcut reference |
| `/home/benjamin/.config/zed/docs/agent-system/README.md` | Orientation to the two AI systems; extensions overview; notes "no manual loading step" |
| `/home/benjamin/.config/zed/docs/agent-system/commands.md` | Full command catalog; notes Office commands require MCP tools; links installation.md |
| `/home/benjamin/.config/zed/docs/workflows/README.md` | Workflow index; notes epidemiology requires `epidemiology` extension, memory requires `memory` extension |
| `/home/benjamin/.config/zed/docs/workflows/memory-and-learning.md` | `/learn` and `--remember` usage; notes `memory` extension required; **no MCP/Obsidian setup instructions** |
| `/home/benjamin/.config/zed/docs/workflows/grant-development.md` | Grant/budget/timeline/funds/slides workflows; **no tool dependency mentions** |
| `/home/benjamin/.config/zed/docs/workflows/epidemiology-analysis.md` | `/epi` workflow; mentions R but **no install instructions beyond what R.md covers** |
| `/home/benjamin/.config/zed/docs/workflows/edit-word-documents.md` | DOCX editing; links to installation.md#install-mcp-tools |
| `/home/benjamin/.config/zed/docs/workflows/edit-spreadsheets.md` | XLSX editing; links to installation.md#install-mcp-tools |
| `/home/benjamin/.config/zed/docs/workflows/convert-documents.md` | Document conversion; mentions markitdown, pandoc, python-pptx implicitly through workflows |
| `/home/benjamin/.config/zed/.claude/README.md` | Framework architecture hub; Extension table (13 extensions listed); links user-installation.md |
| `/home/benjamin/.config/zed/.claude/docs/guides/user-installation.md` | Framework quick-start guide; covers Claude Code install + authentication; Neovim-oriented (references nvim config) |
| `/home/benjamin/.config/zed/.claude/docs/guides/creating-extensions.md` | Extension authoring guide; manifest.json template shows `"dependencies": []` |
| `/home/benjamin/.config/zed/.claude/docs/architecture/extension-system.md` | Extension loader/merger architecture; documents `dependencies` field as "Other extensions that must be loaded first"; `mcp_servers` field as "MCP server configurations to merge into settings" |

**Setup scripts found**:
- `.claude/scripts/setup-lean-mcp.sh` — Automates lean-lsp MCP setup in `~/.claude.json`
- `.claude/scripts/install-aliases.sh` — Installs shell aliases for claude-refresh / claude-cleanup

---

## Coverage Matrix

This matrix covers the **7 active extensions** (per `extensions.json`) plus the **7 inactive extensions** available in the nvim source.

### Active Extensions

| Extension | Source README? | Source README lists deps? | Covered by main install doc? | Notes |
|-----------|---------------|--------------------------|------------------------------|-------|
| `epidemiology` | Yes | Partial (mentions rmcp as optional; no R install) | No (R.md covers R but not epi R packages) | Assumes R and optional pip/rmcp |
| `filetypes` | Yes | Yes (full multi-platform guide) | Yes (SuperDoc + openpyxl in installation.md) | Best-documented; has `tools/dependency-guide.md` |
| `latex` | Yes | Minimal ("pdflatex, latexmk" mentioned in routing table) | No | Assumes LaTeX distribution installed |
| `memory` | Yes | Partial (Obsidian + Node.js mentioned) | No | Obsidian setup not in any zed-config doc |
| `present` | Yes | None (no external tool deps mentioned) | No | Slidev output requires Node.js; XLSX output uses openpyxl |
| `python` | Yes | None (no external tool deps) | Partial (python.md covers Python/uv/ruff) | python.md doesn't reference the extension |
| `typst` | Yes | Minimal ("typst compile" in routing table) | No | Assumes typst CLI installed |

### Inactive Extensions (available in nvim source, not loaded here)

| Extension | Source README? | Source README lists deps? | Notes |
|-----------|---------------|--------------------------|-------|
| `formal` | Yes | None | No external deps; research-only |
| `founder` | Yes | Yes (Firecrawl API key, SEC EDGAR free) | External API key needed |
| `lean` | Yes | Yes (elan, npx lean-lsp-mcp) + Tool Dependencies table | Best-documented MCP setup |
| `memory` | Yes | Yes (Obsidian + Node.js) | Same as active above |
| `nix` | Yes | Yes (uv for uvx mcp-nixos) | `uv` prerequisite documented |
| `nvim` | Yes | Minimal (Neovim loading instructions) | No external CLI deps |
| `web` | Yes | None | Assumes pnpm/TypeScript environment |
| `z3` | Yes | None | Assumes Python + z3 pip package |

---

## Gaps Identified

### Gap 1: Epidemiology extension — R packages not documented in user-facing docs

The `epidemiology` extension implicitly requires R (documented in `R.md`) but also assumes epidemiology-specific R packages (survival, tidyverse, renv, targets, Stan/rstan, etc., listed in `r-packages.md`). The `docs/workflows/epidemiology-analysis.md` does not tell users they need to install these packages before the extension will work meaningfully. The optional `rmcp` pip install is also undocumented in the user-facing docs.

**Severity**: High. A user following the install guide and then running `/epi` will hit missing package errors during analysis.

### Gap 2: Memory extension — Obsidian setup not documented

The `memory` extension's MCP search requires Obsidian desktop + an Obsidian plugin (obsidian-claude-code-mcp) or Local REST API plugin. The `docs/workflows/memory-and-learning.md` says only "Requires the `memory` extension" — no mention of Obsidian. The memory-setup.md lives in `.claude/context/project/memory/memory-setup.md` (agent context, not user docs). Users who install the extension and run `/learn` will find grep-based fallback silently active, with no indication of how to get full MCP functionality.

**Severity**: Medium. The fallback works; users lose search capability but may not notice.

### Gap 3: Present extension — Slidev not documented

The `/slides` command produces Slidev-based presentations. Slidev requires Node.js (`npm create slidev@latest`). No user-facing doc mentions Slidev as a prerequisite. The `docs/workflows/grant-development.md` describes the output format but gives no installation guidance. Node.js is already required (and documented) for MCP tools, but Slidev itself needs a separate install step.

**Severity**: Medium. The agent generates Slidev markdown; if the user doesn't have Slidev installed, they can't render the output.

### Gap 4: LaTeX and Typst extensions — compiler not documented

The `latex` extension's implementation agent calls `pdflatex` and `latexmk`. The `typst` extension calls `typst compile`. Neither tool is mentioned in `docs/general/installation.md`. The `CLAUDE.md` mentions `pdflatex, latexmk` in a routing table entry and VimTeX integration, which is Neovim-specific and irrelevant to the Zed config.

**Severity**: Medium for LaTeX (large install); Low for Typst (`brew install typst` is trivial).

### Gap 5: Filetypes extension — `markitdown`, `pandoc`, `python-pptx` not in main install doc

`installation.md` covers SuperDoc and openpyxl (the MCP tools), but `convert-documents.md` workflows silently require `markitdown` (Python), `pandoc`, and `python-pptx`. The `tools/dependency-guide.md` in the filetypes extension context covers these, but it's in agent context (`.claude/context/project/filetypes/`) — agents see it, but users following `docs/general/installation.md` do not.

**Severity**: Medium. Users who run `/convert` will get errors about missing tools.

### Gap 6: `manifest.json` `dependencies` field is unused for external deps

Every extension's manifest sets `"dependencies": []`. The schema only supports inter-extension dependencies, not external tool prerequisites. There is no machine-readable way for an install script to auto-extract what a user needs to install before an extension will work. The `mcp_servers` field captures MCP config but not the human-readable install command.

**Severity**: Low (documentation design gap, not a user-facing failure by itself).

### Gap 7: `check-extension-docs.sh` does not validate dependency documentation

The doc-lint script checks README presence and manifest wiring, but has no rule requiring a dependency section or install instructions for extensions that declare MCP servers. This means underdocumented extensions pass CI.

**Severity**: Low. Structural quality gate gap.

---

## Prior Art / Patterns

### Pattern 1: Lean extension (best practice in this repo)

`nvim/.claude/extensions/lean/README.md` has a dedicated "## Tool Dependencies" table:

```markdown
| Tool | Purpose | Install |
|------|---------|---------|
| Lean 4 toolchain | Lean compiler and language server | `curl https://elan.lean-lang.org/elan-init.sh -sSf | sh` |
| lake | Lean build tool | Bundled with Lean toolchain |
| lean-lsp-mcp | MCP server for Lean LSP access | `npx -y lean-lsp-mcp@latest` |
```

Plus a separate "## MCP Tool Setup" section with an `npx` install command. This is the clearest pattern in the repo.

### Pattern 2: Filetypes extension (most thorough)

`nvim/.claude/extensions/filetypes/README.md` has "## Installation" and "## MCP Tool Setup" sections with `npx` commands for each MCP server, and a note about user-scope vs project-scope MCP.

The extension also provides a dedicated `tools/dependency-guide.md` with NixOS / Ubuntu / macOS install tables for every CLI tool the extension touches. This is the gold standard for cross-platform coverage.

### Pattern 3: Nix extension (runtime prerequisite)

`nvim/.claude/extensions/nix/README.md` notes that `uv` must be installed for `uvx mcp-nixos` to work, with a one-line install command: `curl -LsSf https://astral.sh/uv/install.sh | sh`. This is a good example of documenting a prerequisite-to-a-prerequisite (uv → uvx → mcp-nixos).

### Pattern 4: docs/general/installation.md (user-facing pattern)

The zed-config's `installation.md` uses a three-step pattern per dependency: **Check if already installed** (run detection command), **Install** (single command), **Verify** (rerun detection). This pattern is consistent across all tools and accessible to non-developer users.

### Pattern 5: manifest.json `mcp_servers` field

The manifest declares MCP server configs that get merged into `settings.json`. This provides machine-readable MCP configuration, but no install command. A natural extension would be an `external_tools` or `prerequisites` array in the manifest schema, each entry with: `name`, `check_command`, `install_command_macos`, `install_command_linux`, `install_command_nix`, `type` (cli/pip/npm/brew/cask).

---

## Recommended Approach

### Short term: Update user-facing docs (no schema changes)

1. **`docs/general/installation.md`**: Add an "Optional Extensions" section after the MCP Tools section. For each active extension that has external deps, add a collapsible or clearly-marked subsection:
   - Epidemiology: R packages (renv, tidyverse, survival) + optional rmcp
   - Memory: Obsidian + obsidian-claude-code-mcp plugin
   - Present: Slidev (npx) for rendering output
   - LaTeX: MacTeX or BasicTeX
   - Typst: `brew install typst`
   - Filetypes (classical tools): markitdown, pandoc, python-pptx

2. **`docs/workflows/*.md`**: Each workflow doc for an extension should include a "Prerequisites" or "Before you begin" block that states the external tools needed (mirroring the pattern in `python.md` and `R.md`).

### Medium term: Standardize extension READMEs

Add a required "## External Dependencies" section to all extension READMEs in the nvim source. The section should use the lean/filetypes pattern:

```markdown
## External Dependencies

| Tool | Purpose | Install |
|------|---------|---------|
| tool-name | what it does | install command |

No external dependencies (pure agent config).
```

Even extensions with no deps should include the table with the "None" row — this makes it explicit that the extension was considered for deps, not just forgotten.

### Long term: Extend manifest.json schema

Add an `external_prerequisites` array to the manifest schema:

```json
"external_prerequisites": [
  {
    "name": "pandoc",
    "check": "pandoc --version",
    "install_macos": "brew install pandoc",
    "install_linux_apt": "apt install pandoc",
    "install_nix": "nixpkgs#pandoc",
    "optional": false,
    "purpose": "Document format conversion"
  }
]
```

This enables the extension loader to output a pre-flight checklist and enables CI to verify documentation completeness via `check-extension-docs.sh`.

---

## Confidence Level

**High** for the documentation gap inventory (direct file reading). **High** for the coverage matrix (cross-referenced extensions.json active list vs README content). **Medium** for severity ratings (based on how likely a user is to hit each gap, which involves some judgment). **Low** for the manifest schema recommendation (depends on Neovim loader implementation details not examined in this research).
