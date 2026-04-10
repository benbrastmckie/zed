# Implementation Summary: Revise docs/installation.md for macOS

**Task**: #7 - revise_installation_md_macos
**Date**: 2026-04-10
**Session**: sess_1775852640_0175a5
**Status**: [COMPLETED]
**Plan**: [01_revise-installation-macos.md](../plans/01_revise-installation-macos.md)

## Outcome

`docs/installation.md` is now a strictly macOS-only installation guide that walks a user with only WezTerm (or the default macOS Terminal) through every dependency in order: Xcode CLT, Homebrew, Node.js, Zed, Claude Code CLI, agent_servers config, Zed `/login`, and the SuperDoc and openpyxl MCP tools. Every dependency section follows a uniform **Check if already installed -> Install -> Verify** template so users can skip anything already present and resume cleanly at the next section. The outdated `brew install anthropics/claude/claude-code` tap path and the obsolete `claude auth login` auth step have been replaced with the current `brew install --cask claude-code` and first-run `claude` flow. The one dangling inbound link from `docs/agent-system/zed-agent-panel.md` to the deleted `#platform-notes` anchor has been repaired.

## Phases Executed

### Phase 1: Strip NixOS content and fix outdated commands [COMPLETED]
- Removed the "see Platform Notes" clause from the intro (`docs/installation.md:3`).
- Deleted the entire `## Platform Notes` -> `### NixOS` subsection, including the hard-coded `/home/benjamin/.nix-profile/bin/npx` custom `agent_servers` block.
- Replaced `brew install anthropics/claude/claude-code` with `brew install --cask claude-code` in both the Summary block and the Claude Code CLI section.
- Replaced `claude auth login` with `claude` (first-run) in Summary and rewrote the accompanying prose.
- Touched up the `#authenticate-in-zed` paragraph wording to match the new auth model.
- Commit: 203b982

### Phase 2: Insert Xcode Command Line Tools and Node.js sections [COMPLETED]
- Added `## Install Xcode Command Line Tools` between Prerequisites and Homebrew with detection (`xcode-select -p >/dev/null 2>&1 && git --version`), install (`xcode-select --install`), and verify (`git --version`).
- Added `## Install Node.js` between Homebrew and Zed with detection (`command -v node ...`), install (`brew install node`), and verify (`node --version && npx --version`).
- Added a one-paragraph explanation after Prerequisites introducing the universal detect/install/verify pattern.
- Commit: a02c796

### Phase 3: Apply detect/install/verify template to existing sections [COMPLETED]
- Rewrote `## Install Homebrew` with detection (`command -v brew ...`), kept install command, and added explicit Verify heading; added the Apple-Silicon `brew shellenv` activation note.
- Rewrote `## Install Zed` with detection (`/Applications/Zed.app` or `zed` on PATH), kept install, kept preview-channel note, added Verify block.
- Rewrote `## Install the Claude Code CLI` with detection, install, a dedicated First-run authentication subsection, and Verify including the optional `claude doctor` health check.
- Added an "Already configured?" tip to `## Configure claude-acp` and an "Already authenticated?" tip to `## Authenticate in Zed`.
- Restructured `## Install MCP Tools` so each sub-tool (SuperDoc, openpyxl) has its own detect/install/verify H4 blocks using `claude mcp list | grep -q '^superdoc|^openpyxl'` for detection.
- Commit: f00c3e2

### Phase 4: Update Summary quickstart and Verify checklist [COMPLETED]
- Rewrote the top-of-file Summary quickstart to reflect the new dependency order: `xcode-select --install`, Homebrew one-liner, `brew install node`, `brew install --cask zed`, `brew install --cask claude-code`, `claude`. Added skip-if-already-installed guidance.
- Expanded the bottom-of-file Verify checklist to cover every dependency: git, brew, node/npx, zed, claude, `claude doctor`, `claude mcp list`, Agent Panel, `/login`, `/task "test"`.
- Commit: 557e08a

### Phase 5: Fix broken inbound link in zed-agent-panel.md [COMPLETED]
- Replaced `../installation.md#platform-notes` at `docs/agent-system/zed-agent-panel.md:58` with a pointer to the upstream `zed-industries/claude-code-acp` README for non-standard setups, keeping the surrounding prose grammatical.
- Commit: 33ac741

### Phase 6: Repo-wide link and anchor sweep [COMPLETED]
- Grepped `docs/`, `README.md`, and `.claude/docs/` for `installation.md#` references. Found inbound anchors: `#install-mcp-tools` (README.md, docs/office-workflows.md x2, docs/agent-system/commands.md, docs/agent-system/zed-agent-panel.md), `#configure-claude-acp` (docs/settings.md, docs/agent-system/zed-agent-panel.md), and `#authenticate-in-zed` (docs/agent-system/zed-agent-panel.md).
- Verified all three anchors still exist as H2 headings in the rewritten file: `## Configure claude-acp`, `## Authenticate in Zed`, `## Install MCP Tools`.
- Confirmed zero residual `platform-notes` references anywhere under `docs/`.
- Read the rewritten file top to bottom for coherence; flow is linear and skippable.
- No additional files needed to change. Commit will roll up with phase 6 / final.

## Files Changed

| File | Change Type | Description |
|------|-------------|-------------|
| docs/installation.md | rewritten | NixOS stripped; Xcode CLT, Node.js added; every dependency section now uses detect/install/verify; Summary quickstart and Verify checklist updated; outdated brew/auth commands corrected. |
| docs/agent-system/zed-agent-panel.md | edited | Repointed dangling `#platform-notes` link (line 58) to the upstream `claude-code-acp` README. |
| specs/007_revise_installation_md_macos/plans/01_revise-installation-macos.md | status updated | All phases and plan status advanced through [IN PROGRESS] -> [COMPLETED]. |
| specs/007_revise_installation_md_macos/.return-meta.json | created | Early metadata, final metadata written at end of run. |
| specs/007_revise_installation_md_macos/summaries/01_revise-installation-macos-summary.md | created | This document. |

## Verification

- `grep -in 'nix' docs/installation.md` -> no matches.
- `grep -n 'anthropics/claude/claude-code' docs/installation.md` -> no matches.
- `grep -n 'claude auth login' docs/installation.md` -> no matches.
- `grep -rn 'platform-notes' docs/` -> no matches.
- Five `### Check if already installed` H3 blocks (Xcode CLT, Homebrew, Node.js, Zed, Claude Code CLI) plus two `#### Check if already installed` H4 blocks under MCP Tools (SuperDoc, openpyxl).
- Inbound anchors `#install-mcp-tools`, `#configure-claude-acp`, `#authenticate-in-zed` all resolve to existing H2 headings.
- Full top-to-bottom read-through confirms linear flow: Prerequisites -> Xcode CLT -> Homebrew -> Node.js -> Zed -> Claude Code CLI -> Configure claude-acp -> Authenticate in Zed -> Install MCP Tools -> Verify -> See also.

## Follow-ups

- `docs/settings.md:79,94-107` still contains NixOS content (the "Custom config (NixOS and other non-standard setups)" subsection). Intentionally out of scope for task #7 but worth a follow-up task so both files agree.
- `docs/agent-system/zed-agent-panel.md:56,68` still contains stale `claude auth login` wording in prose. Also out of scope here; the link target (`#authenticate-in-zed`) still resolves, so nothing is broken, only dated.
- The live `settings.json` at the repo root still uses a NixOS `"type": "custom"` path, which is intentional (development machine). No action needed.
