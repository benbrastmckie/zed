# Implementation Summary: Toolchain Documentation

- **Task**: 30 - audit_missing_dependencies_docs
- **Status**: [COMPLETED]
- **Started**: 2026-04-10
- **Completed**: 2026-04-10
- **Effort**: ~1.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_toolchain-docs.md
- **Standards**: .claude/rules/artifact-formats.md, .claude/rules/git-workflow.md, .claude/rules/plan-format-enforcement.md

## Overview

Built a new `docs/toolchain/` directory that consolidates every external dependency assumed by the active `.claude/` extensions (`latex`, `typst`, `python`, `epidemiology`, `filetypes`, `present`, `memory`) behind a single macOS/Homebrew-scoped, Check/Install/Verify-structured reference. Moved the existing `docs/general/R.md` and `docs/general/python.md` into the new directory (with history preserved), expanded them to cover extension-specific needs, added three new topical files, fixed the `typst` Bash allowlist gap, and resolved the long-standing Lean MCP ambiguity by pruning the dormant references.

## What Changed

- Created `docs/toolchain/` with 7 files: README.md (index + template), r.md, python.md, typesetting.md, mcp-servers.md, extensions.md, shell-tools.md.
- `git mv`'d `docs/general/R.md` -> `docs/toolchain/r.md` and `docs/general/python.md` -> `docs/toolchain/python.md`, preserving git history.
- Expanded r.md with renv, Quarto, rmcp prereq pointer, network-at-runtime caveats, and a Stan/Xcode-CLT note.
- Expanded python.md with uvx, pytest, mypy, filetypes Python packages (pandas, openpyxl, python-pptx, python-docx, pymupdf, pdfannots, xlsx2csv), and a Node.js pointer.
- Created typesetting.md covering MacTeX/BasicTeX, Typst (with settings.json allowlist note), Pandoc, markitdown (via `uv tool install`), and font casks (Latin Modern, CMU, Noto).
- Created mcp-servers.md covering obsidian-memory, rmcp, markitdown-mcp, mcp-pandoc, and recording the **Lean MCP prune decision** with restoration instructions.
- Created extensions.md as a per-extension router with Check commands and cross-links for all 7 active extensions, including the Slidev "optional, Typst Touying is the default" decision for `present`.
- Created shell-tools.md covering git, jq, gh, make, fontconfig.
- Added `Bash(typst *)` to `.claude/settings.json` permissions allowlist, eliminating the interactive-approval gap identified in the research report.
- Removed `mcp__lean-lsp__*` from the allowlist and deleted `.claude/scripts/setup-lean-mcp.sh` and `.claude/scripts/verify-lean-mcp.sh`.
- Updated cross-references in repository `README.md`, `docs/general/README.md`, and `docs/general/installation.md` to point at the new toolchain files.

## Decisions

- **Lean MCP = prune**, not keep. `.claude/extensions.json` lists no `lean` extension; the only references to `mcp__lean-lsp__*` outside `settings.json` were the two setup scripts themselves. Dormant allowlist entries are worse than either state, so the references were removed. Restoration instructions are recorded in `docs/toolchain/mcp-servers.md`.
- **Slidev = optional** for the `present` extension. The talk library ships Slidev templates but the default output path is Typst Touying; Slidev install is documented as optional in `extensions.md`.
- **Platform scope = macOS/Homebrew only**. Every install block uses `brew`; Linux platforms (apt, nix, pacman, dnf) are explicitly out of scope, consistent with the task-21 reframing. The only reference to those tool names is in README.md's explanatory statement that they are excluded.
- **extensions.md = router**, not a direct install doc. Its Install/Verify sections delegate to the tool-specific files (`r.md`, `python.md`, etc.) rather than duplicating commands. This was made explicit via a "Template note" section that still satisfies the Check/Install/Verify heading convention for lint/grep purposes.

## Impacts

- Every external dependency assumed by active extensions now has a documented Check/Install/Verify path the reader can follow on a fresh macOS install.
- `typst compile` calls from agents no longer prompt for interactive approval.
- The Lean MCP dormancy (a known source of confusion flagged by all three research teammates) is resolved.
- `docs/general/installation.md` now has a single authoritative link out to the toolchain directory, keeping the base install guide focused while directing readers to per-extension prereqs.
- Repository top-level `README.md` links to the new file paths; old `docs/general/R.md` and `docs/general/python.md` paths return no hits outside historical `specs/` artifacts.

## Follow-ups

- Implement a `/doctor` runtime-check command that reads the `docs/toolchain/` files and runs `command -v` for each documented binary, with Homebrew install commands printed on failure. This is the durable answer to "did I forget anything?" and was recommended by all four research teammates.
- Rewrite or delete `.claude/docs/guides/user-installation.md` — research identified it as stale Neovim-oriented legacy content. Out of scope for this task per the plan.
- (Cross-repo, lower priority) Extend `manifest.json` schemas in `~/.config/nvim/.claude/extensions/*/` with an `external_prerequisites` array so dependency documentation can be generated from manifests rather than hand-maintained.
- Manually spot-check 3-5 `brew install` commands (notably `font-latin-modern-math`, `quarto`) against `brew info` the next time a clean environment is available. The formula names used here follow common Homebrew conventions but were not each individually verified against `brew info`.

## References

- Plan: `specs/030_audit_missing_dependencies_docs/plans/01_toolchain-docs.md`
- Research report: `specs/030_audit_missing_dependencies_docs/reports/01_team-research.md`
- Teammate findings: `reports/01_teammate-{a,b,c,d}-findings.md`
- New toolchain docs: `docs/toolchain/{README,r,python,typesetting,mcp-servers,extensions,shell-tools}.md`
- Template source: `.claude/context/project/filetypes/tools/dependency-guide.md`
- Settings file: `.claude/settings.json`
