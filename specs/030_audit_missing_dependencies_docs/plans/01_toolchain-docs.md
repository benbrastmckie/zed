# Implementation Plan: Task #30 — Toolchain Documentation

- **Task**: 30 - audit_missing_dependencies_docs
- **Status**: [IN PROGRESS]
- **Effort**: 7 hours
- **Dependencies**: None
- **Research Inputs**: specs/030_audit_missing_dependencies_docs/reports/01_team-research.md
- **Artifacts**: plans/01_toolchain-docs.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/state-management.md
  - .claude/rules/git-workflow.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create a new `docs/toolchain/` directory documenting all external dependencies assumed by the active `.claude/` extensions (`present`, `latex`, `python`, `typst`, `epidemiology`, `filetypes`), with topically grouped files providing macOS/Homebrew Check / Install / Verify instructions. Move the existing `docs/general/R.md` and `docs/general/python.md` into the new directory (expanded and retitled), add new docs for typesetting, MCP servers, and extension-specific prerequisites, fix the `typst` allowlist gap in `settings.json`, and update cross-references from `docs/general/installation.md` and `docs/general/README.md`. Scope is strictly macOS; NixOS/Ubuntu content is explicitly out of scope.

### Research Integration

The research report (`reports/01_team-research.md`) identifies ~55 distinct external deps across 6 active extensions with only SuperDoc + openpyxl currently documented. Key inputs integrated into this plan:
- Capability-matrix framing (Teammate B/C synthesis) drives the topical grouping strategy rather than a flat list.
- `typst` is missing from the `settings.json` Bash allowlist — promoted to an in-scope fix in Phase 6.
- `.claude/context/project/filetypes/tools/dependency-guide.md` is the gold-standard Check/Install/Verify template and is explicitly mirrored in Phase 1's template.
- macOS/Homebrew-only framing (task-21 reframing) locked in as hard non-goal against multi-platform content.
- Lean MCP ambiguity resolved via explicit bounded decision step in Phase 4.
- Personal UX layer (WezTerm, piper TTS, cross-repo nvim path) flagged as optional, not a project requirement.
- Follow-on items (`/doctor`, manifest schema changes) explicitly excluded.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `specs/ROADMAP.md` found at plan-time (research noted its absence). This task advances the implicit "build-capability → discover-friction → remediate" trajectory identified in recent tasks 20-30 and reinforces the task-21 macOS-first repo framing.

## Goals & Non-Goals

**Goals**:
- Create `docs/toolchain/` directory with topically grouped per-area docs (language runtimes, typesetting, MCP servers, extension prereqs, shell utilities).
- Move `docs/general/R.md` and `docs/general/python.md` into `docs/toolchain/` via `git mv`, expanded to cover extension-specific needs.
- Every toolchain doc has explicit **Check**, **Install** (Homebrew), and **Verify** sections following the filetypes `dependency-guide.md` model.
- Fix the `typst` Bash allowlist gap in `.claude/settings.json`.
- Update `docs/general/installation.md` and `docs/general/README.md` cross-references to point at the new toolchain directory; no broken links remain.
- Resolve the Lean MCP ambiguity with a recorded decision (document-and-keep vs prune-and-remove).
- Make the docs discoverable from the main install entry point.

**Non-Goals**:
- NOT implementing a `/doctor` runtime-check command (follow-on meta task).
- NOT modifying extension `manifest.json` schemas (belongs in the nvim repo, follow-on).
- NOT documenting NixOS or Ubuntu install paths — macOS/Homebrew only.
- NOT documenting install for the personal UX layer (WezTerm hooks, piper TTS, `~/.config/nvim/` cross-repo paths) beyond an "optional, author-personal" note.
- NOT rewriting `.claude/docs/guides/user-installation.md` — if found trivially stale, flag for a follow-on cleanup task rather than rewriting in scope.
- NOT pinning minimum versions for every tool (deferred to follow-on `/doctor` or as-encountered updates).
- NOT auditing every line of the `settings.json` Bash allowlist — only `typst` and any other binaries discovered-missing during Phase 6.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Doc rot — toolchain docs become stale | M | H | Enforce Check/Install/Verify pattern so staleness is self-evident; cross-link from `installation.md` as single entry point; file a follow-on `/doctor` task to durably solve it. |
| Broken cross-references when `R.md`/`python.md` move | H | M | Phase 2 starts with a grep sweep for both paths across the whole repo (including `.claude/`, `specs/`, other docs); update all hits before/as part of `git mv`. |
| Lean MCP ambiguity — prune vs document | L | M | Phase 4 includes an explicit decision step: check `extensions.json`, grep for active workflow references, then either document in `mcp-servers.md` or prune `mcp__lean-lsp__*` from allowlist and remove `setup-lean-mcp.sh`. Record the decision in the doc. |
| Scope creep into personal UX layer | M | M | Explicit non-goal; include a single short "Optional author-personal tooling" note in `docs/toolchain/README.md` pointing readers elsewhere. |
| Platform drift — macOS-only framing slips | M | L | Lint convention: every `Install` block uses `brew install` only; Phase 7 verification greps for `apt`, `nix`, `pacman` and rejects hits. |
| Homebrew formula name inaccuracy | M | M | Phase 7 manual verification: each `brew install X` command gets checked against `brew info X` or Homebrew formula search. |
| `check-extension-docs.sh` regression | L | L | Phase 7 runs the script explicitly; docs live in `docs/`, not `.claude/`, so interference is unlikely but verified. |
| Homebrew absent on target machine | L | L | `docs/toolchain/README.md` opens with a Homebrew prerequisite pointer. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 5 | 2, 3, 4 |
| 4 | 6 | 5 |
| 5 | 7 | 6 |

Phases within the same wave can execute in parallel.

### Phase 1: Scaffold docs/toolchain/ and establish template [COMPLETED]

**Goal**: Create the `docs/toolchain/` directory with a README/index and lock in the Check/Install/Verify file template that all subsequent phases follow.

**Tasks**:
- [ ] Create `docs/toolchain/` directory.
- [ ] Read `.claude/context/project/filetypes/tools/dependency-guide.md` and extract the Check/Install/Verify skeleton.
- [ ] Write `docs/toolchain/README.md` as index: brief intro, macOS/Homebrew prerequisite note, links to each topical doc (as stubs initially), a short "Optional author-personal tooling" paragraph pointing at the dotfiles/nvim repos for WezTerm/TTS hook infrastructure.
- [ ] Document the file-naming convention and the three-section template (Check / Install / Verify) inside `docs/toolchain/README.md` so later phases have a canonical reference.
- [ ] Decide final file set and record in README index (proposed: `r.md`, `python.md`, `typesetting.md`, `mcp-servers.md`, `extensions.md`, `shell-tools.md`).

**Timing**: 0.75 hours

**Depends on**: none

**Files to modify**:
- `docs/toolchain/README.md` (new)

**Verification**:
- Directory exists at `/home/benjamin/.config/zed/docs/toolchain/`.
- README renders cleanly and enumerates the planned files.
- Template section is reusable as a copy-paste skeleton.

---

### Phase 2: Language runtimes (R and Python) [COMPLETED]

**Goal**: Move and expand `docs/general/R.md` and `docs/general/python.md` into `docs/toolchain/`, updating all cross-references and adding the Check/Install/Verify structure.

**Tasks**:
- [ ] Grep-sweep for all references to `docs/general/R.md` and `docs/general/python.md` across repo (`.claude/`, `docs/`, `specs/`, root). Record the hit list.
- [ ] `git mv docs/general/R.md docs/toolchain/r.md`.
- [ ] `git mv docs/general/python.md docs/toolchain/python.md`.
- [ ] Expand `docs/toolchain/r.md` to add: renv setup, Quarto install, a reference link to `.claude/context/project/epidemiology/tools/r-packages.md`, rmcp MCP server prereq note, a "network-at-runtime" caveat for `renv::restore()` and CRAN.
- [ ] Expand `docs/toolchain/python.md` to add: `uv`/`uvx` prereq note (required by several MCP servers), `pytest`/`mypy`/`ruff` tooling, extension-specific Python packages referenced from the filetypes `dependency-guide.md`, Node.js/`npx` note if not already covered elsewhere.
- [ ] Reformat both files so each tool appears under **Check**, **Install**, **Verify** sub-headings matching the Phase 1 template.
- [ ] Update every reference found in the grep sweep to point to the new path.

**Timing**: 1.25 hours

**Depends on**: 1

**Files to modify**:
- `docs/toolchain/r.md` (moved + expanded)
- `docs/toolchain/python.md` (moved + expanded)
- Any files containing old-path references (to be discovered)

**Verification**:
- `git mv` preserves history (check with `git log --follow`).
- No hits for `docs/general/R.md` or `docs/general/python.md` outside git history.
- Both files conform to the Check/Install/Verify template.

---

### Phase 3: Typesetting toolchain doc [COMPLETED]

**Goal**: Create `docs/toolchain/typesetting.md` covering LaTeX, Typst, Pandoc, markitdown, and required fonts — grouped because these tools are commonly installed together for document output.

**Tasks**:
- [ ] Create `docs/toolchain/typesetting.md` with sections for:
  - **LaTeX (MacTeX / BasicTeX)**: `brew install --cask mactex` (or `basictex`), PATH note, `pdflatex`/`latexmk`/`bibtex`/`biber` verification.
  - **Typst**: `brew install typst`, verify compile, note on package auto-fetch from `packages.typst.app` at first compile (network dependency).
  - **Pandoc**: `brew install pandoc`, verify.
  - **markitdown**: install via `uv tool install markitdown` (cross-reference python.md for `uv` prereq).
  - **Fonts**: Latin Modern Math, CMU, Noto install notes (`brew install --cask font-...`).
- [ ] Each tool gets Check / Install / Verify sub-sections.
- [ ] Add "network-at-runtime" note for Typst package fetching.
- [ ] Cross-reference: LaTeX extension, Typst extension, filetypes extension.

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `docs/toolchain/typesetting.md` (new)

**Verification**:
- All five sub-tools present with Check/Install/Verify.
- Every `brew install` / `brew install --cask` command spot-checked via `brew info`.
- Extension cross-references link to correct extension docs.

---

### Phase 4: MCP servers doc (with Lean decision) [NOT STARTED]

**Goal**: Create `docs/toolchain/mcp-servers.md` consolidating install and verify steps for all MCP servers used by active extensions; resolve the Lean MCP ambiguity with a recorded decision.

**Tasks**:
- [ ] Create `docs/toolchain/mcp-servers.md` with sections for:
  - **SuperDoc (`@superdoc-dev/mcp`)**: Node.js prereq, install via `npx`, config snippet.
  - **obsidian-memory**: mirror content from `.claude/context/project/memory/memory-setup.md`.
  - **rmcp (epidemiology)**: prereq R + `uv`/`uvx`, install via `uvx rmcp`, verify.
  - **markitdown-mcp** / **mcp-pandoc**: install via `uvx`, verify.
- [ ] **Lean MCP decision step**:
  - Read `.claude/extensions.json` to check whether a `lean` extension is listed.
  - Grep for active workflow references to `mcp__lean-lsp__*` and `setup-lean-mcp.sh` outside of `settings.json`.
  - If Lean is unused: mark decision "prune" — record the decision in `mcp-servers.md` as "Lean MCP was pruned on {date} because no active extension references it. To restore, re-add the allowlist entries and re-run `setup-lean-mcp.sh`." Defer the actual pruning to Phase 6.
  - If Lean is used: document install in `mcp-servers.md` with reference to `setup-lean-mcp.sh`.
- [ ] Add a "network-at-runtime" note for `uvx` and `npx -y @...@latest` invocations.
- [ ] Cross-reference python.md for `uv`/`uvx` prereq and `r.md` for R prereq.

**Timing**: 1.25 hours

**Depends on**: 1

**Files to modify**:
- `docs/toolchain/mcp-servers.md` (new)

**Verification**:
- All active MCP servers documented.
- Lean decision explicit and recorded.
- Every install command verified against the source documentation (memory-setup.md, filetypes mcp-integration.md, epi mcp-guide.md).

---

### Phase 5: Extension prereqs and shell tools [NOT STARTED]

**Goal**: Create the remaining topical docs: extension-specific prerequisites not yet covered and shell utilities.

**Tasks**:
- [ ] Create `docs/toolchain/extensions.md` — one sub-section per active extension (`present`, `latex`, `python`, `typst`, `epidemiology`, `filetypes`) that points to the relevant toolchain files (r.md, python.md, typesetting.md, mcp-servers.md) and lists any extension-specific extras not covered elsewhere. Specifically:
  - **epidemiology**: the exact R package set from `.claude/context/project/epidemiology/tools/r-packages.md` with a one-line install-via-renv or `install.packages()` snippet; Stan/C++ toolchain note for `brms`/`EpiNow2`.
  - **present**: Slidev decision — check whether talks are actually built via Slidev or Typst Touying; if Slidev, document `npm install -g @slidev/cli`; if not, mark as optional.
  - **filetypes**: refer back to `docs/general/installation.md`'s existing SuperDoc+openpyxl section; add any missing binaries (`pdfannots`, `xlsx2csv`, `pymupdf` via pip).
- [ ] Create `docs/toolchain/shell-tools.md` covering `jq`, `gh`, `git`, `make`, and any other shell utilities the audit surfaces. Each with Check/Install/Verify.
- [ ] Both files conform to the Phase 1 template.

**Timing**: 1.25 hours

**Depends on**: 2, 3, 4

**Files to modify**:
- `docs/toolchain/extensions.md` (new)
- `docs/toolchain/shell-tools.md` (new)

**Verification**:
- Each active extension has a sub-section.
- Slidev decision is explicit.
- Epi package list matches `r-packages.md`.

---

### Phase 6: settings.json fix and cross-references [NOT STARTED]

**Goal**: Fix the `typst` allowlist gap in `.claude/settings.json`, apply the Lean decision from Phase 4, and update cross-references in `docs/general/installation.md` and `docs/general/README.md`.

**Tasks**:
- [ ] Add `Bash(typst *)` to the `.claude/settings.json` Bash allowlist (adjacent to existing typesetting entries like `pdflatex`/`latexmk`).
- [ ] Apply the Lean decision from Phase 4:
  - If "prune": remove `mcp__lean-lsp__*` entries from `settings.json` allowlist; delete or archive `.claude/scripts/setup-lean-mcp.sh`.
  - If "keep": no action here.
- [ ] Update `docs/general/installation.md`: add a short "Toolchain" section or callout pointing at `docs/toolchain/README.md` as the authoritative dependency reference; preserve existing SuperDoc/openpyxl content.
- [ ] Update `docs/general/README.md`: remove the `R.md` and `python.md` index entries (now moved); add a pointer to `docs/toolchain/`.
- [ ] Grep-sweep one more time for any lingering references to the old paths and fix them.

**Timing**: 0.75 hours

**Depends on**: 5

**Files to modify**:
- `.claude/settings.json`
- `docs/general/installation.md`
- `docs/general/README.md`
- Possibly `.claude/scripts/setup-lean-mcp.sh` (delete if pruning)

**Verification**:
- `jq '.permissions.allow[] | select(test("typst"))' .claude/settings.json` returns a match.
- `installation.md` links to `docs/toolchain/README.md`.
- `docs/general/README.md` no longer references `R.md` or `python.md`.
- Lean decision fully applied.

---

### Phase 7: Verification and link audit [NOT STARTED]

**Goal**: Verify that every toolchain doc is reachable, every cross-reference resolves, no old paths linger, and the doc-lint passes.

**Tasks**:
- [ ] `grep -rn "docs/general/R.md\|docs/general/python.md" docs/ .claude/ specs/` — expect zero hits (outside git history).
- [ ] Run `.claude/scripts/check-extension-docs.sh` — expect pass.
- [ ] For each file in `docs/toolchain/`: verify it has a Check, Install, and Verify section (grep for the three headings).
- [ ] Grep for `apt`, `apt-get`, `nix-env`, `pacman`, `dnf` inside `docs/toolchain/` — expect zero hits (macOS-only invariant).
- [ ] Manually spot-check 3-5 `brew install` commands by comparing against `brew info <formula>` or the Homebrew formula page.
- [ ] Verify `docs/general/installation.md` -> `docs/toolchain/README.md` link resolves.
- [ ] Verify `docs/toolchain/README.md` links to each of the topical files and each file loads.
- [ ] Smoke-test: run `typst --version` and confirm `.claude/settings.json` would allow it (no interactive-approval needed after restart).

**Timing**: 0.75 hours

**Depends on**: 6

**Files to modify**: none (verification only)

**Verification**:
- All greps return expected results.
- `check-extension-docs.sh` exits 0.
- No broken links.
- macOS-only invariant holds.

---

## Testing & Validation

- [ ] `grep -rn "docs/general/R.md\|docs/general/python.md" docs/ .claude/ specs/` returns zero hits.
- [ ] `.claude/scripts/check-extension-docs.sh` passes.
- [ ] Every file in `docs/toolchain/` contains "Check", "Install", and "Verify" headings.
- [ ] `grep -rn "apt\|nix-env\|pacman" docs/toolchain/` returns zero hits.
- [ ] `.claude/settings.json` Bash allowlist contains an entry matching `typst`.
- [ ] `docs/general/installation.md` contains a link to `docs/toolchain/README.md`.
- [ ] `docs/general/README.md` no longer indexes `R.md` or `python.md`.
- [ ] `git log --follow docs/toolchain/r.md` shows history from the old `docs/general/R.md` path.
- [ ] Manual: spot-check 3-5 `brew install` commands against `brew info`.
- [ ] Lean decision (prune or keep) is explicitly recorded in `docs/toolchain/mcp-servers.md`.

## Artifacts & Outputs

**New files**:
- `docs/toolchain/README.md` — index and template reference
- `docs/toolchain/r.md` — moved from `docs/general/R.md`, expanded
- `docs/toolchain/python.md` — moved from `docs/general/python.md`, expanded
- `docs/toolchain/typesetting.md` — LaTeX, Typst, Pandoc, markitdown, fonts
- `docs/toolchain/mcp-servers.md` — SuperDoc, obsidian-memory, rmcp, markitdown-mcp, mcp-pandoc, Lean decision
- `docs/toolchain/extensions.md` — per-extension prereqs (epi R packages, Slidev decision, filetypes extras)
- `docs/toolchain/shell-tools.md` — jq, gh, git, make, etc.

**Modified files**:
- `.claude/settings.json` — add `Bash(typst *)` to allowlist; maybe prune Lean entries
- `docs/general/installation.md` — cross-reference callout to `docs/toolchain/`
- `docs/general/README.md` — remove `R.md`/`python.md` index entries, add `docs/toolchain/` link
- (conditional) `.claude/scripts/setup-lean-mcp.sh` — delete if Lean is pruned

**Deleted files**:
- `docs/general/R.md` (moved via `git mv`)
- `docs/general/python.md` (moved via `git mv`)

## Rollback/Contingency

This task is docs-only plus a minor `settings.json` edit; rollback is trivial:

1. `git status` to see the changeset.
2. `git restore .` to drop unstaged changes, or `git reset --hard HEAD` if committed per phase and a phase must be reverted.
3. If a phase is already committed and needs reverting: `git revert <commit-sha>` creates a new commit undoing it.
4. The `git mv` operations preserve history; a revert will restore `docs/general/R.md` and `docs/general/python.md` to their original locations.
5. The `settings.json` change is a single-line addition; easy to revert manually if `git revert` is not appropriate.

If the Lean decision proves wrong after the fact: the decision is recorded in `mcp-servers.md` with restoration instructions, so reversing it is a documented operation.
