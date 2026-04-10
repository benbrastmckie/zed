# Implementation Plan: Revise docs/installation.md for macOS

- **Task**: 7 - revise_installation_md_macos
- **Date**: 2026-04-10
- **Session**: sess_1775852110_007a62
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Dependencies**: None
- **Research Inputs**: [specs/007_revise_installation_md_macos/reports/01_installation-macos-research.md](../reports/01_installation-macos-research.md)
- **Artifacts**: plans/01_revise-installation-macos.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Rewrite `docs/installation.md` as a strictly macOS-only guide that walks a user with only WezTerm (or Terminal) installed through every dependency in order, using a uniform detect/install/verify pattern per section. Delete the NixOS Platform Notes block, fix the outdated Claude Code brew command and auth step, add a missing Node.js section, and repair the one broken inbound link from `docs/agent-system/zed-agent-panel.md`. The finished document must let any reader skip past anything already installed and resume cleanly at the next section.

### Research Integration

The research report (`reports/01_installation-macos-research.md`) supplies: a line-level NixOS reference inventory (`docs/installation.md:3`, `:137-154`), the correct modern Homebrew cask (`brew install --cask claude-code`), the corrected first-run auth step (run `claude`, not `claude auth login`), the full eight-dependency list with detection/install/verify commands, the recommended section order (Xcode CLT -> Homebrew -> Node -> Zed -> Claude Code CLI -> agent_servers config -> Zed /login -> MCP tools -> Verify), and a proposed section template. The plan applies these verbatim. The one cross-file fix required is at `docs/agent-system/zed-agent-panel.md:58`, which links to the soon-to-be-deleted `#platform-notes` anchor.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

ROAD_MAP.md not consulted for this task (single-file documentation edit; no roadmap items tracked for docs/ content).

## Goals & Non-Goals

**Goals**:
- Remove every NixOS reference from `docs/installation.md`.
- Add install sections for Xcode Command Line Tools, Homebrew, Node.js, Zed, Claude Code CLI, `agent_servers` config, Zed `/login`, SuperDoc MCP, and openpyxl MCP, in dependency order.
- Apply a uniform "Check if already installed -> Install -> Verify" template to every dependency section so users can skip any step they already have.
- Correct the Claude Code install command to `brew install --cask claude-code` and the first-run auth to `claude`.
- Add Node.js as an explicit prerequisite for the MCP tool sections.
- Repair the broken inbound link at `docs/agent-system/zed-agent-panel.md:58` so no dangling `#platform-notes` anchor remains in the tree.
- Keep the four-command Summary quickstart at the top (updated with correct commands).

**Non-Goals**:
- Stripping NixOS content from `docs/settings.md` (out of scope; noted as follow-up in research).
- Changing the live `settings.json` at the repo root (intentionally uses a NixOS path for the author's dev machine).
- Rewriting `docs/agent-system/zed-agent-panel.md` beyond the one broken link.
- Adding screenshots, GIFs, or non-textual assets.
- Documenting Windows or Linux installation paths.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Broken anchors from renamed sections (e.g., `#install-mcp-tools`) break inbound links in `docs/README.md`, `docs/office-workflows.md` | M | M | Phase 6 does a repo-wide grep for `installation.md#` anchors and verifies each resolves after the rewrite. |
| Numbered section headings (e.g., `## 5. Node.js`) generate anchor slugs like `#5-nodejs` that diverge from existing unnumbered links | M | M | Use unnumbered headings (`## Node.js`) with position implied by order; numbering lives only in the prose "Step N" framing. Keeps anchors stable and simple. |
| Claude Code auth step changes upstream between drafting and reader execution | L | L | Point prose at https://code.claude.com/docs/en/setup as the authoritative source and describe behavior (runs browser) rather than CLI subcommand names. |
| Detection commands behave differently across shells (zsh vs bash) | L | L | Use POSIX-portable commands (`command -v`, `>/dev/null 2>&1`) validated in the research report. |
| Accidentally introducing a link to the deleted Platform Notes anchor from within installation.md itself | L | L | Phase 5 greps the new file for `platform-notes` before considering it done. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases are strictly sequential because they all edit the same file in layered passes; parallelism offers no benefit and risks edit conflicts.

---

### Phase 1: Strip NixOS content and fix outdated commands [COMPLETED]

**Goal**: Produce a clean, NixOS-free baseline of `docs/installation.md` with the two command bugs corrected, before restructuring.

**Tasks**:
- [ ] Delete the trailing clause `; see [Platform Notes](#platform-notes) at the bottom for NixOS adjustments` at `docs/installation.md:3`.
- [ ] Delete the entire `## Platform Notes` section and its `### NixOS` subsection (`docs/installation.md:137-154`).
- [ ] Replace `brew install anthropics/claude/claude-code` with `brew install --cask claude-code` in the Summary block (`docs/installation.md:12`) and in the Install the Claude Code CLI section (`docs/installation.md:56`).
- [ ] Replace `claude auth login` with `claude` in the Summary block (`docs/installation.md:13`) and rewrite the accompanying prose in the Claude Code CLI section (`docs/installation.md:57-60`) to say: "Run `claude` in any directory; it opens a browser to sign into your Anthropic Pro/Max/Team/Enterprise/Console account."
- [ ] Grep the file for any remaining `nix`, `NixOS`, `nix-profile` tokens; remove any stragglers.

**Timing**: 15m

**Depends on**: none

**Files to modify**:
- `docs/installation.md` - delete Platform Notes section, fix brew/auth commands, remove intro clause.

**Verification**:
- `grep -in 'nix' docs/installation.md` returns no matches.
- `grep -n 'anthropics/claude/claude-code' docs/installation.md` returns no matches.
- `grep -n 'claude auth login' docs/installation.md` returns no matches.
- File still renders (no broken markdown tables, headings, or code fences).

---

### Phase 2: Insert Xcode Command Line Tools and Node.js sections [COMPLETED]

**Goal**: Add the two missing dependency sections in their correct positions so the document lists every dependency a user needs.

**Tasks**:
- [ ] Insert a new `## Install Xcode Command Line Tools` section immediately after `## Prerequisites`, before `## Install Homebrew`. Contents: purpose sentence ("Provides `git` and the compiler toolchain Homebrew needs."), detection command `xcode-select -p >/dev/null 2>&1 && git --version`, install command `xcode-select --install` with note about GUI installer, verification `git --version`.
- [ ] Insert a new `## Install Node.js` section immediately after `## Install Homebrew`, before `## Install Zed`. Contents: purpose sentence ("Provides `npx`, required by the SuperDoc and openpyxl MCP tools installed later in this guide."), detection `command -v node >/dev/null && node --version && command -v npx >/dev/null`, install `brew install node`, note that Node 18+ is required and Homebrew's default LTS satisfies this, verification `node --version && npx --version`.
- [ ] Use unnumbered headings (stable anchors) and the "Check if already installed -> Install -> Verify" template established by the research report.

**Timing**: 20m

**Depends on**: 1

**Files to modify**:
- `docs/installation.md` - add two new sections.

**Verification**:
- `grep -n '^## Install Xcode Command Line Tools$' docs/installation.md` returns one line.
- `grep -n '^## Install Node.js$' docs/installation.md` returns one line.
- Sections appear in correct order: Prerequisites -> Xcode CLT -> Homebrew -> Node.js -> Zed.

---

### Phase 3: Apply detect/install/verify template to existing sections [COMPLETED]

**Goal**: Normalize every existing dependency section so it has the same three-step structure as the new ones, letting users skip anything already installed.

**Tasks**:
- [ ] Rewrite `## Install Homebrew` with a `### Check if already installed` block (`command -v brew >/dev/null 2>&1 && brew --version`), keep the existing install command, and keep the existing verify. Add a one-sentence skip instruction pointing at the next section.
- [ ] Rewrite `## Install Zed` with detection (`ls /Applications/Zed.app >/dev/null 2>&1 || command -v zed >/dev/null 2>&1`), keep `brew install --cask zed` as install, keep the existing preview-channel note, add verify instruction ("launch from Applications or run `zed --version` if the CLI helper is installed").
- [ ] Rewrite `## Install the Claude Code CLI` with detection (`command -v claude >/dev/null 2>&1 && claude --version`), the already-corrected install command from Phase 1, and a verify block pointing at `claude --version` and the optional `claude doctor` health check. Keep the paragraph distinguishing CLI auth from Zed `/login`.
- [ ] Rewrite the `## Install MCP Tools` group: move the shared verification up so each subsection (`### SuperDoc`, `### openpyxl`) follows the same detect/install/verify shape, using `claude mcp list 2>/dev/null | grep -q '^superdoc'` and the analogous openpyxl check for detection.
- [ ] Leave `## Configure claude-acp` and `## Authenticate in Zed` structurally intact (they are configuration steps, not installs) but add a one-line "Already configured?" tip at the top of each that tells users how to recognize an existing working setup (presence of `agent_servers.claude-acp` block, or an existing Claude Code thread option in the Agent Panel).

**Timing**: 35m

**Depends on**: 2

**Files to modify**:
- `docs/installation.md` - restructure five existing sections.

**Verification**:
- Every `## Install *` section contains a `### Check if already installed` subheading.
- Every install section contains a `### Verify` subheading or inline verification code block.
- `grep -c '^### Check if already installed$' docs/installation.md` equals 5 (Xcode CLT, Homebrew, Node, Zed, Claude Code) or 7 if the MCP subsections also got individual detection blocks.

---

### Phase 4: Update Summary quickstart and Verify checklist [COMPLETED]

**Goal**: Bring the top-of-file quickstart and the bottom-of-file verification checklist in line with the new content so users arriving at either end see correct, complete commands.

**Tasks**:
- [ ] Update the `## Summary` four-line quickstart to reflect the new dependency order and corrected commands. Target sequence (comments optional): `xcode-select --install` (or skip), Homebrew install one-liner, `brew install node`, `brew install --cask zed`, `brew install --cask claude-code`, `claude` (first-run auth). Note in prose that experienced users can skip any step whose detection command already passes.
- [ ] Update the `## Verify` end-to-end checklist to include: `git --version`, `brew --version`, `node --version && npx --version`, `zed --version` (or launch), `claude --version`, `claude mcp list` shows both tools, Zed Agent Panel offers Claude Code thread, `/login` completes, `/task "test"` creates an entry. Keep the existing troubleshooting pointer at the end but verify the `agent-system/zed-agent-panel.md#troubleshooting` anchor still resolves.
- [ ] Ensure the `## See also` section still links only to files and anchors that exist after the rewrite.

**Timing**: 15m

**Depends on**: 3

**Files to modify**:
- `docs/installation.md` - update Summary and Verify sections.

**Verification**:
- Summary block contains exactly the corrected commands, no `anthropics/claude/claude-code` and no `claude auth login`.
- Verify checklist has one line per installed dependency.
- `## See also` links resolve (manual check via reading each target file).

---

### Phase 5: Fix broken inbound link in zed-agent-panel.md [IN PROGRESS]

**Goal**: Repair the one dangling inbound link the research report flagged, so no file in the repo references the deleted `#platform-notes` anchor.

**Tasks**:
- [ ] Open `docs/agent-system/zed-agent-panel.md:58` and read the sentence containing `../installation.md#platform-notes`.
- [ ] Replace the link. Preferred: drop the NixOS sentence entirely (cleanest outcome now that installation.md is macOS-only). Acceptable fallback: repoint the link to the upstream `https://github.com/zed-industries/claude-code-acp` README for non-standard setups.
- [ ] Re-read the surrounding paragraph to ensure the edit leaves grammatical, coherent prose.

**Timing**: 10m

**Depends on**: 4

**Files to modify**:
- `docs/agent-system/zed-agent-panel.md` - remove or repoint the `#platform-notes` link.

**Verification**:
- `grep -rn 'installation.md#platform-notes' docs/` returns no matches.
- `grep -rn 'platform-notes' docs/installation.md` returns no matches.
- `docs/agent-system/zed-agent-panel.md` still parses and reads naturally around the edited line.

---

### Phase 6: Repo-wide link and anchor sweep [NOT STARTED]

**Goal**: Confirm the rewrite did not silently break any other inbound links from sibling docs.

**Tasks**:
- [ ] Run `grep -rn 'installation.md' docs/ README.md .claude/docs/ 2>/dev/null` and list every inbound reference.
- [ ] For each reference that includes a `#anchor`, verify the anchor still exists in the rewritten `docs/installation.md`. Known references from the research report: `docs/README.md:7`, `docs/office-workflows.md:186` (`#install-mcp-tools`, Homebrew troubleshooting), repo-root `README.md:9-14`.
- [ ] If any referenced anchor no longer exists, either (a) restore the heading text to regenerate the expected slug, or (b) update the inbound link to the new anchor. Prefer (a) to minimize blast radius.
- [ ] Do a final read-through of `docs/installation.md` from top to bottom to confirm the flow is linear, skippable, and complete.

**Timing**: 15m

**Depends on**: 5

**Files to modify**:
- `docs/installation.md` (only if an anchor needs restoring)
- Sibling docs (only if an inbound link must be updated; unlikely)

**Verification**:
- Every `installation.md#<anchor>` reference in the repo resolves to a heading that exists in the rewritten file.
- `docs/installation.md` reads as a coherent, linear, macOS-only guide from Prerequisites through Verify.
- No `nix`, `NixOS`, or `platform-notes` tokens anywhere in the rewritten file.

---

## Testing & Validation

- [ ] `grep -in 'nix' docs/installation.md` returns no matches.
- [ ] `grep -rn 'installation.md#platform-notes' docs/ README.md` returns no matches.
- [ ] Every `## Install *` section contains a detection block, install block, and verify block.
- [ ] Summary quickstart reflects the corrected brew cask and `claude` first-run commands.
- [ ] Verify checklist at bottom covers all nine dependency checks (git, brew, node, zed, claude, MCP list, agent panel, /login, /task).
- [ ] Markdown renders cleanly (no unterminated fences, no broken tables, headings sequential).
- [ ] Every inbound link from sibling docs to `installation.md` still resolves.

## Artifacts & Outputs

- Rewritten `docs/installation.md` (macOS-only, detect/install/verify per section).
- Minor edit to `docs/agent-system/zed-agent-panel.md` (broken link fix).
- Possibly minor anchor-preserving edits to other sibling docs if Phase 6 surfaces broken references (expected: none).

## Rollback/Contingency

- All changes are confined to files tracked by git. If any phase produces a regression, `git checkout -- docs/installation.md docs/agent-system/zed-agent-panel.md` reverts the working tree to the pre-plan state.
- Phases are sequential and each ends with a verification step; if Phase N fails, stop there and revert only phase N's changes, leaving earlier phases intact.
- If the rewrite accidentally breaks an anchor used by an external (non-repo) link, that can be fixed in a follow-up commit without reverting.
