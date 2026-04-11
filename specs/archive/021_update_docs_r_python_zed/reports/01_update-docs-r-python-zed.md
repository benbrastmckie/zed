---
task_number: 21
task_name: update_docs_r_python_zed
date: 2026-04-10
status: researched
session_id: sess_1775869065_6b00e6
---

# Research Report: Update Docs to Reflect R/Python + Claude Code in Zed

## Executive Summary

- The repository's user-facing documentation (README.md, docs/README.md, and most files under docs/) still frames this configuration as a **macOS** setup for **epidemiology and grant/medical research**. The actual configuration has shifted: settings.json is explicitly a **NixOS Linux** config, and first-class **R** and **Python** language support (pyright, ruff, r-language-server, languageserver, lintr, styler) is the core concern.
- Language setup guides already exist at `docs/general/R.md` and `docs/general/python.md`, but they are not referenced from README.md or docs/README.md, and both guides themselves still say "on macOS" and instruct users to `brew install`.
- The recommended reframing is: **"Zed IDE configuration for working in R and Python with Claude Code"**, with epidemiology/grant workflows demoted from the headline pitch to "domain extensions available through Claude Code".
- Concrete edits below cover 6 files. `.claude/`, `specs/`, and the deeper workflow narratives stay untouched; only user-facing top-level and `docs/general/` and `docs/workflows/README.md` + `docs/agent-system/README.md` need reframing cross-links and intro paragraphs.

## Current State

### /home/benjamin/.config/zed/README.md
- **Title**: "Zed + Claude Code for Epidemiology and Medical Research".
- **Platform line**: "Platform: macOS 11 (Big Sur) or newer."
- **Quick start**: `brew install --cask zed`, Cmd+Space, Applications.
- **Research commands table**: Leads with `/epi`, `/grant`, `/budget`, `/funds`, `/timeline`, `/slides`. No mention of Python or R workflows.
- **Directory layout**: Correct structurally.
- **Keybindings**: Uses Cmd shortcuts.
- **AI integration**: Correctly describes Claude Code + Zed Agent Panel.
- **Platform notes**: Entirely macOS-specific (Homebrew, Cmd vs Option).
- **No links** to `docs/general/R.md` or `docs/general/python.md`.

### /home/benjamin/.config/zed/docs/README.md
- Framed as "documentation for this Zed configuration on macOS".
- Three sections: General, Agent System, Workflows. No mention of R or Python.
- General section description mentions "Homebrew, Node.js, Zed, the Claude Code CLI, the `claude-acp` bridge, and MCP tool installation" — but omits R.md and python.md which actually live under `docs/general/`.

### /home/benjamin/.config/zed/docs/general/README.md
- Says "Core reference documentation for this Zed configuration on macOS".
- Navigation lists only installation.md, keybindings.md, settings.md — **does not list R.md or python.md**, which both exist in the same directory.
- Quick start reading order excludes R.md and python.md.

### /home/benjamin/.config/zed/docs/general/R.md
- **Exists** (183 lines). Good content: languageserver + lintr + styler, Zed LSP config, `.Rprofile` gotcha, verification steps.
- **Framing is macOS/Homebrew**: "installing R and its development tools on macOS", `brew install r`, Cmd+S in verification. This is inconsistent with the actual NixOS Linux settings.json.

### /home/benjamin/.config/zed/docs/general/python.md
- **Exists** (191 lines). Covers Python + uv + ruff, Zed auto-install extensions, pyright/ruff LSP configuration, pytest/ipython optional tools.
- **Framing is macOS/Homebrew**: "on macOS", `brew install python`, `brew install uv`, `brew install ruff`, Cmd+S in verification.
- Cross-link to R.md present at the end (correct).

### /home/benjamin/.config/zed/docs/agent-system/README.md
- Mentions the Python extension in the "Extensions" list (line 39), but frames the agent system around epidemiology, grants, memory, filetypes, LaTeX/Typst, Python. No R mention.
- Otherwise reasonable; no hard macOS-only claims here.

### /home/benjamin/.config/zed/docs/workflows/README.md
- Intro says "End-to-end usage narratives for working with this Zed configuration on macOS".
- Lists workflows grouped by agent-system / epidemiology / grant / memory / office. No R-dev or Python-dev workflow section.
- Many references to macOS (Cmd+`, macOS permissions for Word).

### settings.json
- **Platform comment**: "Platform: NixOS Linux (binary: zeditor)". This contradicts every doc file saying macOS.
- **Python LSP**: `pyright` + `ruff` as language servers, basic type checking, format on save with ruff.
- **R LSP**: `r-language-server` with diagnostics and rich documentation, format on save with r-language-server, 2-space indent.
- **Auto-install extensions**: `python`, `ruff`, `r` all set to `true` (plus markdown, csv, nix, toml, git-firefly, codebook).
- **Agent server**: `claude-acp` bridge configured as `custom` type at `/home/benjamin/.nix-profile/bin/npx @agentclientprotocol/claude-agent-acp --serve`, pointing at `/home/benjamin/.nix-profile/bin/claude` — this is the Claude Code integration inside the Zed IDE.

### Other docs directly under docs/
- `docs/agent-system/` (architecture.md, commands.md, context-and-memory.md, zed-agent-panel.md) — agent-facing; low priority for reframing, except the README.
- `docs/workflows/` — narrative guides; only the README needs updating for top-level framing. Individual workflow files (epidemiology-analysis.md, grant-development.md, etc.) can retain their domain-specific framing as **extension-provided workflows**.

## Gaps Identified

1. **Core purpose mis-framed**: Top-level README and docs/README present epidemiology/grants as the reason for the config. The actual core is "R + Python development inside Zed, with Claude Code as the AI copilot". Epi/grants are extension-provided workflows layered on top.
2. **Platform mismatch**: All user docs say macOS; settings.json is NixOS Linux. Installation instructions in R.md, python.md, and installation.md use Homebrew. At minimum, docs should acknowledge the current runtime is NixOS Linux, or should be platform-neutral.
3. **R.md and python.md orphaned**: Neither is linked from README.md, docs/README.md, or docs/general/README.md. A user reading the top-level docs has no way to discover them.
4. **No R/Python workflow entry point**: docs/workflows/README.md has sections for agent-system, epidemiology, grants, memory, office — none for "writing R" or "writing Python" as day-to-day development workflows.
5. **Keybinding/shortcut confusion**: Docs teach Cmd+S etc.; on NixOS Linux Zed uses Ctrl. This is a deeper fix but should at least be flagged in the top-level README.
6. **Claude Code integration not named as a development partner for R/Python**: The README describes Claude Code for `/epi`, `/grant`, etc., but not for "Claude Code helps you write and debug R and Python code in this Zed configuration" — which is the actual headline value proposition of this repo.

## Recommended Changes

### 1. `/home/benjamin/.config/zed/README.md`
- **Retitle**: "Zed + Claude Code for R and Python" (or "Zed IDE Configuration for R and Python with Claude Code").
- **Rewrite intro paragraph**: Frame the repo as a Zed editor configuration optimized for working in R and Python with Claude Code as the integrated AI assistant. Mention that it also ships with extensions for epidemiology, grant development, memory, and Office documents — but demote those from the headline.
- **Platform line**: Replace "Platform: macOS 11 (Big Sur) or newer" with either "Platform: NixOS Linux (primary); macOS and other Linux distributions supported with minor setup changes" or platform-neutral wording. Either way, stop claiming macOS-only.
- **Quick Start**: Replace Homebrew/Cmd+Space instructions with platform-aware language. For NixOS, reference `zeditor` binary; for macOS keep `brew install --cask zed`. Also add: "For language setup, see [docs/general/python.md](docs/general/python.md) and [docs/general/R.md](docs/general/R.md)".
- **Essential shortcuts table**: Use Ctrl (or note Cmd on macOS / Ctrl on Linux). Add a line noting base_keymap is VSCode.
- **Add a "Languages" section** before "Research Commands": briefly describe R (r-language-server + lintr/styler) and Python (pyright + ruff + uv) support, with cross-links to `docs/general/R.md` and `docs/general/python.md`.
- **Research Commands table**: Keep `/epi`, `/grant`, etc., but prepend `/research`, `/plan`, `/implement` as primary commands and call out that they also work for general R/Python development tasks.
- **AI integration**: Mention Claude Code's role for writing, testing, and refactoring R and Python code, not only the epi/grant workflows.
- **Directory layout**: No change needed.
- **Platform Notes**: Replace macOS bullets with a Linux + macOS section, or remove the platform-specific block entirely and defer to `docs/general/installation.md`.

### 2. `/home/benjamin/.config/zed/docs/README.md`
- **Intro paragraph**: Reframe as "documentation for this Zed configuration, which focuses on working in R and Python with Claude Code". Drop the "on macOS" qualifier.
- **General section description**: Update to mention R.md and python.md as the language-setup guides alongside installation/keybindings/settings.
- **Optional**: Add a brief "For R/Python development" callout linking directly to `general/R.md` and `general/python.md`.

### 3. `/home/benjamin/.config/zed/docs/general/README.md`
- **Intro paragraph**: Drop "on macOS" and reframe for R/Python focus.
- **Navigation list**: Add entries for `R.md` and `python.md`.
- **Quick start**: Add step 4 "Set up Python ([python.md](python.md))" and step 5 "Set up R ([R.md](R.md))".
- **See also**: No change needed.

### 4. `/home/benjamin/.config/zed/docs/general/R.md`
- **Intro**: Replace "on macOS" with "in Zed". Add a short note: "Installation commands below assume NixOS or macOS with Homebrew; adapt to your platform's package manager (e.g., `nix-env -iA nixpkgs.R` on NixOS, `apt install r-base` on Debian/Ubuntu)."
- **Install R / packages**: Keep the R-console-level package install instructions (languageserver/lintr/styler are the same everywhere). Add a short NixOS tip near the brew command.
- **Verify-in-Zed section**: Change "Cmd+S" to "Save the file (**Ctrl+S** on Linux, **Cmd+S** on macOS)".
- **See also**: Add a link back to `../../README.md` and `../README.md`.

### 5. `/home/benjamin/.config/zed/docs/general/python.md`
- **Intro**: Same treatment as R.md — drop "on macOS", add platform-neutral install guidance (NixOS: `nix-env -iA nixpkgs.python312`, `nix-env -iA nixpkgs.uv`, `nix-env -iA nixpkgs.ruff`; macOS: `brew install python uv ruff`).
- **Verify-in-Zed**: "Cmd+S" -> "Save (**Ctrl+S** on Linux, **Cmd+S** on macOS)".
- **See also**: No change needed (already links to R.md).

### 6. `/home/benjamin/.config/zed/docs/workflows/README.md`
- **Intro**: Drop "on macOS". Reframe around "working in R and Python with Claude Code".
- **Optional**: Add a short "Languages" section linking back to `../general/R.md` and `../general/python.md`, noting that the generic task lifecycle (`agent-lifecycle.md`) is the primary workflow for R/Python development tasks.
- Do **not** rewrite epidemiology/grant/Office narratives; they remain valid as extension-provided workflows.

### 7. `/home/benjamin/.config/zed/docs/agent-system/README.md` (minor)
- **Extensions list**: Add an "R / Epidemiology" note alongside "Python" so R-via-languageserver is visible, OR clarify that the Python bullet covers general Python development and the Epidemiology bullet covers R-specific research workflows.
- Low priority — this file is otherwise accurate.

## Out of Scope

- `/home/benjamin/.config/zed/.claude/**` — Claude Code framework system docs. Untouched.
- `/home/benjamin/.config/zed/specs/**` — Task management artifacts.
- `/home/benjamin/.config/zed/docs/workflows/epidemiology-analysis.md`, `grant-development.md`, `edit-word-documents.md`, `edit-spreadsheets.md`, `convert-documents.md`, `tips-and-troubleshooting.md`, `memory-and-learning.md`, `agent-lifecycle.md`, `maintenance-and-meta.md` — individual workflow narratives keep their domain focus.
- `/home/benjamin/.config/zed/docs/agent-system/architecture.md`, `commands.md`, `context-and-memory.md`, `zed-agent-panel.md` — agent system internals, not top-level framing.
- `/home/benjamin/.config/zed/docs/general/installation.md`, `keybindings.md`, `settings.md` — these have heavy macOS framing and many Cmd references; a full rewrite is not required by this task, though a follow-up task should normalize platform language. For this task, README.md and general/README.md can simply link to them with a "primarily macOS-flavored; adapt for Linux" note.
- `settings.json`, `keymap.json`, `tasks.json` — configuration files, not documentation. No changes.
- Deep rewrite of keybinding references Cmd->Ctrl across the whole docs tree — scope this to a separate task if desired.

## Open Questions

1. **Platform scope**: Should the docs be reframed as (a) NixOS Linux primary (matching settings.json), (b) Linux + macOS dual-platform, or (c) platform-neutral? Recommendation: (b) — dual-platform with Linux notes added alongside the existing macOS content. This minimizes churn to installation.md and keybindings.md while fixing the most visible inconsistencies.
2. **Title wording**: "Zed + Claude Code for R and Python" vs. "Zed IDE Configuration for R and Python with Claude Code" vs. "R and Python in Zed, Powered by Claude Code". Choose one before implementation.
3. **Epi/grants demotion depth**: Should `/epi`, `/grant`, `/budget`, etc., be removed from the top-level README command table and moved behind a "Domain extensions" section, or left in the main table but re-ordered after `/research`, `/plan`, `/implement`? Recommendation: keep them in the README but after the general commands, under an "Also available (domain extensions)" sub-heading.
4. **Should docs/general/installation.md be updated in this task?** It is the single longest-running source of macOS framing. Recommendation: out of scope; create a follow-up task to add a NixOS install section.
5. **Keybinding normalization**: Should we do a global Cmd->Ctrl pass in this task, or just note the mapping once in README and general/README? Recommendation: note once; leave deep normalization to a separate task.

## Appendix

### Files inspected
- `/home/benjamin/.config/zed/README.md`
- `/home/benjamin/.config/zed/docs/README.md`
- `/home/benjamin/.config/zed/docs/general/README.md`
- `/home/benjamin/.config/zed/docs/general/R.md`
- `/home/benjamin/.config/zed/docs/general/python.md`
- `/home/benjamin/.config/zed/docs/agent-system/README.md`
- `/home/benjamin/.config/zed/docs/workflows/README.md`
- `/home/benjamin/.config/zed/settings.json`

### Search evidence
- Grep for `epidemiology|medical research|macOS|Homebrew|Cmd\+|grant` across `docs/`: 189 total occurrences in 20 files, confirming the pervasive macOS + epi/grant framing.
- settings.json header comment: "Platform: NixOS Linux (binary: zeditor)" — authoritative platform truth.
- settings.json lsp block confirms pyright, ruff, r-language-server are configured.
- settings.json auto_install_extensions confirms `python: true`, `ruff: true`, `r: true`.
