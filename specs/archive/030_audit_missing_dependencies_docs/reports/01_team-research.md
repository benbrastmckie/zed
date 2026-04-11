# Research Report: Task #30 — Audit .claude/ for Missing Installation Dependencies

**Task**: Audit `.claude/` to identify all assumed external dependencies (typst, R, python, lean, latex, etc.) and plan updates to installation/setup documentation.
**Date**: 2026-04-10
**Mode**: Team Research (4 teammates: Primary, Alternatives, Critic, Horizons)
**Session**: sess_1744336200_audit30

---

## Summary

The `.claude/` system assumes **~55 distinct external dependencies** across 6 active extensions (`present`, `latex`, `python`, `typst`, `epidemiology`, `filetypes`), but the main user-facing install guide (`docs/general/installation.md`) only documents two of them (SuperDoc + openpyxl, both macOS/Homebrew). The "forgotten typst" is representative of a much larger gap: **four of six active extensions have undocumented external toolchain prerequisites**, and one (`typst`) is not even whitelisted in `settings.json`, meaning every `typst compile` call requires interactive permission approval.

The right framing is **not** "list every dependency" (flat inventory goes stale and is ambiguous about required vs optional), but **"which capabilities require which toolchains, with graceful-degradation status noted."** The immediate fix is to update `docs/general/installation.md` with per-extension prerequisite sections using `docs/general/installation.md`'s three-step (Check / Install / Verify) pattern, mirroring the existing `.claude/context/project/filetypes/tools/dependency-guide.md` as the gold standard. A follow-on `/doctor` runtime-check command would durably solve the underlying "did I forget anything?" question.

---

## Key Findings

### 1. The dependency surface is large and mostly undocumented (from Teammate A)

~55 distinct external dependencies are assumed across 8 domains. Breakdown:

**Language toolchains actually invoked**:
| Tool | Used by | Whitelisted? | Documented? |
|------|---------|--------------|-------------|
| `typst` | typst ext, filetypes, present | **NO** (gap) | NO |
| `pdflatex`, `latexmk`, `bibtex`, `biber` | latex ext | YES | Partial (compile cmds only) |
| `python3`/`python` | python, filetypes, epi | N/A (implicit) | Partial (`docs/general/python.md`) |
| `Rscript`/`R` | epi ext | N/A (implicit) | Partial (`docs/general/R.md`) |
| `lake` | lean ext (referenced) | YES | Scripts only |
| `quarto` | epi ext | N/A | NO |

**`typst` is not in `settings.json` Bash allowlist** — this is an immediate operational gap separate from documentation.

**CLI utilities invoked from agents/hooks/scripts**:
`jq`, `pandoc`, `markitdown`, `pdfannots`, `xlsx2csv`, `piper`, `aplay`/`paplay`, `wezterm`, `git`, `gh`, `uvx`, `make` — most assumed-present with no documented install path outside the filetypes extension.

**MCP servers** (vary in setup-doc coverage):
- `lean-lsp` — has `setup-lean-mcp.sh` + verify script (best)
- `obsidian-memory` — has comprehensive `memory-setup.md`
- `superdoc` (`@superdoc-dev/mcp`) — partial (config snippets only)
- `rmcp` (epi) — partial
- `markitdown-mcp`, `mcp-pandoc` — config snippets only
- `neovim-lsp` — referenced, no docs

**Python packages** (~15): `pymupdf`, `pypdf`, `pikepdf`, `python-pptx`, `python-docx`, `markitdown`, `pandas`, `openpyxl`, `xlsx2csv`, `pdfannots`, `rmcp`, `vosk`, `pytest`, `mypy`, `ruff`. Install hints only appear in agent error messages.

**R packages** (~45+): Documented in `.claude/context/project/epidemiology/tools/r-packages.md` as a reference guide, but no R/renv/Quarto install guide exists; no step saying "install these packages before running /epi."

**Typst packages**: `fletcher`, `cetz`, Touying/Polylux, `@preview/*` — referenced in context, no install path (fetched from `packages.typst.app` at first compile — requires network at runtime).

### 2. Documentation coverage matrix (from Teammate B)

| Active Extension | Main install doc coverage | Source README lists deps? | Gap severity |
|------------------|---------------------------|---------------------------|--------------|
| `filetypes` | Partial (SuperDoc+openpyxl only) | YES (full guide) | Low |
| `epidemiology` | None (R.md is separate, doesn't list epi packages) | Partial (rmcp mentioned) | **High** |
| `latex` | None | Minimal | **High** |
| `typst` | None | Minimal | **High** |
| `memory` (if active) | None (no Obsidian docs) | Partial | Medium |
| `present` | None (no Slidev docs) | None | Medium |
| `python` | Partial (`python.md` covers Python/uv/ruff, not extension deps) | None | Medium |

**Structural findings**:
- **`manifest.json.dependencies` is used only for inter-extension dependencies**, not external tool prerequisites. All 14 extension manifests set `"dependencies": []`. The schema has no `external_prerequisites` field.
- **`check-extension-docs.sh` does not require dependency documentation** — underdocumented extensions pass CI silently.
- **Extension source lives in `~/.config/nvim/.claude/extensions/`** — cross-repo coordination is needed for any manifest schema changes; docs in this repo can mirror but not own the source of truth.
- **`.claude/docs/guides/user-installation.md`** is stale Neovim-oriented legacy content referencing `~/.config/nvim` — needs substantial rewrite or deletion.

**Prior art / best patterns in repo** (reusable):
1. **Lean extension's "Tool Dependencies" table** in its README — table with Tool / Purpose / Install columns
2. **Filetypes `dependency-guide.md`** — multi-platform (NixOS / Ubuntu / macOS) install tables with verification commands (gold standard)
3. **`docs/general/installation.md` three-step pattern** — Check / Install / Verify per dependency, user-accessible
4. **Nix extension's prerequisite-of-prerequisite documentation** — `uv` as prereq for `uvx mcp-nixos`

### 3. Hidden / invisible dependency surfaces (from Teammate C)

Things that will NOT show up in a grep-based audit but will break at runtime:

- **System libraries beneath packages**: Stan (`brms`, `EpiNow2`) needs C++ toolchain + `libssl`; `markitdown`/OCR may need `tesseract`, `libmagic`, `libjpeg`; `Pillow` (via `python-pptx`) needs `libjpeg`/`libpng`/`zlib`
- **Fonts**: Typst, LaTeX, Slidev themes assume system fonts (Latin Modern Math, CMU, Noto); `texlive` scheme choice (basic vs full) determines what's available
- **Audio subsystem**: TTS hooks need `piper` binary + voice model file at hardcoded path + `paplay` OR `aplay`; silently no-op elsewhere
- **Terminal coupling**: Four hooks hard-depend on **WezTerm** (not "a terminal") via `WEZTERM_PANE`, `wezterm cli`, OSC 1337; no graceful fallback on Alacritty/iTerm2/Ghostty
- **Cross-repo absolute path**: `settings.json` SessionStart hook references `~/.config/nvim/scripts/claude-ready-signal.sh` — hardcoded, fails silently without nvim config at that path
- **Locale**: R workflow assumes UTF-8; minimal Docker images often break
- **Network access at runtime** (not declared as install-time dep): `typst compile` fetches from `packages.typst.app`; `renv::restore()` hits CRAN; Stan downloads CmdStan; `uvx rmcp` / `npx -y @...@latest` fetch on every invocation (also a reproducibility risk — unpinned)
- **Lean toolchain**: `mcp__lean-lsp__*` is permitted in `settings.json` and `setup-lean-mcp.sh` exists, but **no `lean` extension is in `extensions.json`** → Is Lean active or dormant? Must be resolved.
- **Claude Code harness features**: `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`, MCP server runtime, subagent Task tool, hook system — platform features, not external tools, but are still environmental prerequisites
- **`uv` / `uvx`** is an implicit runtime for several MCP servers (rmcp, markitdown-mcp, mcp-pandoc) — not listed as a required dependency despite being required
- **`Node.js`/`npx`** is required by obsidian-memory MCP, SuperDoc MCP, and Slidev — partially documented

### 4. Strategic context and long-term options (from Teammate D)

- **No `ROADMAP.md` exists** in this repo; direction inferred from recent task trajectory (tasks 20-30 show a "build-capability → discover-friction → remediate" pattern; this audit is reactive to concrete forgotten `typst`).
- **Task 21 intentionally reframed the repo from "epidemiology/NixOS" to "macOS Zed IDE for R and Python"** — documentation should reinforce that framing, not regress to NixOS-centric instructions.
- **The filetypes `dependency-guide.md` is the model** to follow (but belongs in agent context, not user docs — so it must be mirrored into `docs/general/`).
- **Four long-term options weighed**:
  1. **Static install docs** (Option 1) — fast, necessary, but rot-prone
  2. **Declarative manifests + auto-gen docs** (Option 2) — right long-term architecture but needs cross-repo coordination with nvim repo
  3. **Nix flake / devshell** (Option 3) — rejected: contradicts macOS reframing, belongs in `~/.dotfiles`
  4. **Runtime `/doctor` command** (Option 4) — best durable answer to "did I forget anything?"; highest long-term value
- **Recommended hybrid**: Option 1 now (this task), Option 4 as a follow-on meta task.

---

## Synthesis

### Conflicts Resolved

**Conflict 1: Scope framing — flat inventory vs capability matrix.**
- Teammate A produced a flat inventory of ~55 tools.
- Teammate C argued "list every dependency" is the wrong framing and proposed a capability matrix (rows = features/commands, cols = required/optional/graceful-fallback/N.A.).
- Teammate B's coverage matrix (extension × has-README × has-deps × covered-by-install-doc) is a middle ground.
- **Resolution**: Use a **hybrid**. The inventory (A) is the raw data. The synthesized deliverable is a **capability/extension matrix** (B+C) plus per-extension install sections in `docs/general/installation.md`. The flat list is an appendix for reference, not the primary deliverable.

**Conflict 2: Platform scope — multi-platform (NixOS/Ubuntu/macOS) vs macOS-only.**
- Teammate A noted the filetypes guide covers three platforms.
- Teammate D emphasized the task-21 reframing to macOS/Homebrew-first and the shared-with-collaborator memory constraint.
- Teammate C noted hooks are Linux-specific and several paths are hardcoded to `~/.config/nvim/`.
- **Resolution**: `docs/general/installation.md` stays **macOS/Homebrew-only** (consistent with task-21 framing and existing doc). NixOS-specific content lives in the dotfiles repo. Hook/TTS/WezTerm infrastructure is flagged explicitly as a **"personal UX layer, not required for project functionality"** in a separate section so collaborators know to ignore it.

**Conflict 3: Where to put dependency info — user docs vs extension READMEs vs manifests.**
- Teammate B advocated for extension README standardization ("## External Dependencies" section).
- Teammate D advocated for a consolidated section in `docs/general/installation.md`.
- Teammate C advocated for a runtime check script.
- **Resolution**: Not mutually exclusive. **Short term: update `docs/general/installation.md`** (user-facing, single entry point, controlled by this repo). **Medium term: follow-on task to standardize extension READMEs in the nvim repo**. **Long term: `/doctor` command** (follow-on meta task in this repo).

**Conflict 4: Lean toolchain — include or exclude?**
- Teammate A listed Lean toolchain and lean-lsp as referenced but noted no `lean` extension directory exists in `.claude/extensions/`.
- Teammate C flagged this as an open question: "Is the Lean MCP active or dormant?"
- **Resolution**: Explicitly **resolve this as a planning decision** — check whether `extensions.json` includes lean, whether `setup-lean-mcp.sh` is referenced from any active workflow, and whether the `mcp__lean-lsp__*` allowlist should be pruned if dormant. Include this as a bounded action item in the plan, not open-ended scope.

### Gaps Identified

- No teammate verified **which specific R packages the user actually has installed** in their current environment. The task-27 external fix in dotfiles may have resolved most gaps; re-verification is needed before writing install commands.
- No teammate checked whether **Slidev is actually used** by the present extension's talk workflow on this specific repo (vs. just being a themed output option). If talks are actually built with typst Touying instead, Slidev is moot.
- No teammate checked **minimum version requirements** for any tool. Version pinning is deferred to implementation.
- **`settings.json` Bash allowlist** — full audit needed of which `Bash(X *)` entries match actual usage vs historical/stale entries. The `typst` omission is the visible tip.

### Recommendations

1. **Immediate (this task's plan)**: Update `docs/general/installation.md` with an "Extension Prerequisites" section organized per active extension. Use the existing three-step Check/Install/Verify pattern. Scope strictly to macOS/Homebrew.

2. **Immediate (as part of this task)**: Add `typst` (and any other missing verified binaries) to the `Bash(X *)` allowlist in `settings.json`.

3. **Immediate**: Rewrite or delete `.claude/docs/guides/user-installation.md` — it is Neovim-oriented legacy content and actively misleading.

4. **Immediate**: Flag the "personal UX layer" (WezTerm hooks, piper TTS, cross-repo nvim path) as optional and non-essential in documentation. Do not attempt to document install paths for these — they are intentionally author-personal.

5. **Follow-on meta task**: Implement `/doctor` command that reads a deps map (initially hardcoded, later driven by manifests) and checks `command -v` for each binary with Homebrew install commands on failure. This is the durable answer to "did I forget anything?"

6. **Follow-on meta task (nvim repo)**: Extend `manifest.json` schema with `external_prerequisites` array; update `check-extension-docs.sh` to require declaration; generate doc fragments from manifests.

7. **Follow-on**: Create `docs/general/epi-packages.md` (or extend `R.md`) with the exact set of R packages needed for `/epi` workflows, cross-referenced to `r-packages.md`. This prevents a third recurrence of the task-20 config-gap failure.

8. **Resolve Lean question**: Prune `mcp__lean-lsp__*` from `settings.json` allowlist + remove `setup-lean-mcp.sh` OR add lean to `extensions.json` and document it. Dormant references are worse than either state.

9. **Resolve network-at-runtime dependencies**: Explicitly state in docs that `typst compile`, `renv::restore()`, `uvx`, and `npx -y @...@latest` invocations require network access on first use. This prevents confusing failures in restricted environments.

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Artifact |
|----------|-------|--------|------------|----------|
| A | Primary Inventory (~55 deps across 8 domains) | completed | High | `01_teammate-a-findings.md` |
| B | Documentation gaps, prior art, coverage matrix | completed | High | `01_teammate-b-findings.md` |
| C | Hidden surfaces, framing critique | completed | High / Medium | `01_teammate-c-findings.md` |
| D | Strategic horizons, long-term options | completed | High / Medium | `01_teammate-d-findings.md` |

---

## References

Primary sources consulted across teammates:
- `docs/general/installation.md`, `docs/general/R.md`, `docs/general/python.md`, `docs/general/README.md`
- `.claude/README.md`, `.claude/CLAUDE.md`, `.claude/settings.json`
- `.claude/docs/guides/user-installation.md` (stale)
- `.claude/context/project/filetypes/tools/dependency-guide.md` (gold standard)
- `.claude/context/project/epidemiology/tools/r-packages.md`
- `.claude/context/project/epidemiology/tools/mcp-guide.md`
- `.claude/context/project/filetypes/tools/mcp-integration.md`
- `.claude/context/project/memory/memory-setup.md`
- `.claude/scripts/setup-lean-mcp.sh`, `.claude/scripts/check-extension-docs.sh`
- `.claude/hooks/tts-notify.sh`, `.claude/hooks/wezterm-*.sh`
- `.claude/agents/{latex,typst,python,epi,scrape,document,presentation,spreadsheet,docx-edit,budget,funds,talk,timeline}-*-agent.md`
- `nvim/.claude/extensions/*/manifest.json` and `*/README.md` (14 extensions)
- `specs/TODO.md`, recent task artifacts (tasks 20-29)
