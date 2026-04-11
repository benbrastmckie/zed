# Implementation Plan: Beginner-Friendly Installation Docs

- **Task**: 15 - Improve installation docs for beginner-friendly terminal walkthrough
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Dependencies**: None (task 14 touches different files)
- **Research Inputs**: specs/015_improve_installation_docs_beginner_friendly/reports/01_beginner-friendly-install.md
- **Artifacts**: plans/01_beginner-friendly-install.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: true

## Overview

The current `docs/general/installation.md` is technically complete but assumes prior terminal experience. Research identified 8 beginner barriers: no terminal introduction, intimidating detection commands, missing "why" context, unclear PATH instructions, no "what you should see" guidance, expert-level MCP section, assumed Zed settings knowledge, and a checkbox-based final checklist. This plan rewrites the file in three phases that group logically by file region, preserving the existing dependency ordering and install commands. Done when a reader with zero terminal experience can follow the doc end-to-end without hitting unexplained jargon or opaque shell idioms.

### Research Integration

All 8 findings from the research report are addressed. The tone target (conversational, direct, second-person, matching keybindings.md) guides every edit. The "one motivation sentence, one what-you-should-see line" constraint prevents bloat.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Add a "Before you begin" terminal introduction (3-4 sentences)
- Add one motivation sentence per dependency section
- Simplify all detection commands to their minimal form
- Add "What you should see" notes after install commands
- Rewrite the Homebrew PATH paragraph in plain language
- Lead the claude-acp section with Cmd+, instead of file path
- Simplify MCP detection to plain `claude mcp list` reading
- Convert final verification from checkboxes to numbered list

**Non-Goals**:
- Adding screenshots or images (go stale, add maintenance burden)
- Writing a full terminal tutorial
- Changing the dependency ordering or actual install commands
- Modifying the summary block at top or cross-links at bottom
- Rewriting sections that are already clear (e.g., Authenticate in Zed needs only minor rewording)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Condescending tone | M | M | Avoid "simply", "just", "easy"; assume intelligent but unfamiliar reader |
| Doc becomes too long | M | L | Strict one-sentence motivation, one-line "what you should see" per section |
| Conflict with task 14 changes | L | L | Task 14 focuses on README and cross-linking, not installation.md content |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

### Phase 1: Terminal Introduction and First Three Sections [COMPLETED]

**Goal**: Add the "Before you begin" preamble and rewrite the top half of the doc (Prerequisites through Homebrew), addressing research findings 1-5 for those sections.

**Tasks**:
- [ ] Add a "Before you begin" section (3-4 sentences) before Prerequisites explaining how to open Terminal, what a prompt looks like, and how to paste/run commands
- [ ] Update Prerequisites to mention opening a terminal
- [ ] Xcode CLT section: replace compound detection command (`xcode-select -p >/dev/null 2>&1 && git --version`) with simple `git --version`; add one motivation sentence; add "what you should see" after install command
- [ ] Homebrew section: replace compound detection command with simple `brew --version`; add motivation sentence; rewrite PATH paragraph in plain language ("copy the line the installer shows you, paste it, press Enter; or close and reopen the terminal")
- [ ] Add "what you should see" note after the Homebrew install command

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `docs/general/installation.md` - Lines 1-86 (top half through Homebrew)

**Verification**:
- "Before you begin" section exists and explains how to open Terminal
- No compound shell idioms (`>/dev/null 2>&1`, `command -v`, `&&`) in detection commands for Xcode CLT or Homebrew
- Each section has a motivation sentence
- PATH paragraph uses plain language

---

### Phase 2: Middle Sections (Node through MCP Tools) [COMPLETED]

**Goal**: Rewrite detection commands and add motivation/guidance for Node.js, Zed, Claude Code CLI, claude-acp, Authenticate in Zed, and MCP Tools sections.

**Tasks**:
- [ ] Node.js section: replace compound detection with simple `node --version`; add motivation sentence ("Node.js is a programming runtime -- you will not write Node code, but two helper tools need it"); add "what you should see" after install
- [ ] Zed section: replace `ls /Applications/Zed.app >/dev/null 2>&1 || command -v zed` with plain-language check ("If Zed is already in your Applications folder, skip ahead"); add motivation sentence
- [ ] Claude Code CLI section: replace compound detection with simple `claude --version`; add motivation sentence; add "what you should see" after install
- [ ] Configure claude-acp section: lead with "In Zed, press Cmd+, to open your settings file" instead of file path; make `~/.config/zed/settings.json` parenthetical
- [ ] Authenticate in Zed section: minor rewording for consistency with new tone
- [ ] MCP Tools section: add framing sentence ("These tools run behind the scenes -- you install them once and forget about them"); replace pipe-based detection (`claude mcp list 2>/dev/null | grep -q`) with plain `claude mcp list` and tell reader to look for the name in the output

**Timing**: 40 minutes

**Depends on**: 1

**Files to modify**:
- `docs/general/installation.md` - Lines 87-278 (Node.js through MCP Tools)

**Verification**:
- No compound shell idioms remain in any detection command
- claude-acp section leads with Cmd+, shortcut
- MCP detection uses plain `claude mcp list` without pipes
- Each section has a motivation sentence

---

### Phase 3: Final Verification Section and Full-Doc Review [COMPLETED]

**Goal**: Convert the final checklist from checkboxes to a numbered list with explicit instructions, then review the full document for tone consistency and missed jargon.

**Tasks**:
- [ ] Convert the Verify section from `- [ ]` checkbox format to a numbered list with "Run each command below" framing
- [ ] Full-doc review pass: check for any remaining unexplained jargon, inconsistent tone, or missing "what you should see" guidance
- [ ] Verify the summary block at top and cross-links at bottom are unchanged
- [ ] Verify dependency ordering is preserved (Xcode CLT -> Homebrew -> Node -> Zed -> Claude Code -> claude-acp -> MCP)

**Timing**: 20 minutes

**Depends on**: 2

**Files to modify**:
- `docs/general/installation.md` - Lines 280-302 (Verify section) plus full-doc review

**Verification**:
- Final checklist uses numbered list format, not checkboxes
- No `- [ ]` markers remain in the Verify section
- Summary block and cross-links are unchanged from original
- Full doc reads naturally for someone with no terminal experience

## Testing & Validation

- [ ] Read through the entire document as if you have never opened a terminal -- every step should be followable
- [ ] Confirm no compound shell idioms remain in detection commands
- [ ] Confirm each dependency section has exactly one motivation sentence
- [ ] Confirm summary block (lines 1-18) is unchanged in substance
- [ ] Confirm cross-links at bottom are unchanged
- [ ] Confirm all actual install commands are unchanged
- [ ] Confirm dependency ordering is preserved

## Artifacts & Outputs

- `plans/01_beginner-friendly-install.md` (this file)
- `docs/general/installation.md` (modified in place)
- `summaries/01_beginner-friendly-install-summary.md` (post-implementation)

## Rollback/Contingency

The file is tracked in git. If changes are unsatisfactory, revert with `git checkout docs/general/installation.md`. Since this is a single-file edit with no structural changes, rollback is trivial.
