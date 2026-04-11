# Research Report: Task #15

**Task**: 15 - Improve installation docs for beginner-friendly terminal walkthrough
**Started**: 2026-04-11T00:15:00Z
**Completed**: 2026-04-11T00:20:00Z
**Effort**: small
**Dependencies**: None (task 14 may touch the file but changes are orthogonal)
**Sources/Inputs**: Codebase analysis of docs/general/*.md
**Artifacts**: specs/015_improve_installation_docs_beginner_friendly/reports/01_beginner-friendly-install.md
**Standards**: report-format.md

## Executive Summary

- The current installation.md is technically complete and well-structured, but assumes the reader already knows what a terminal is, how to paste commands, and what output to expect
- The biggest beginner barriers are: no explanation of how to open a terminal, no context for *why* each tool is needed, cryptic detection commands, and no guidance on what to do when something goes wrong
- Recommended approach: add a brief "Opening a terminal" preamble, add one-sentence motivations to each section, simplify detection commands or reframe them as optional, and add "What you should see" callouts after key commands
- The tone should match keybindings.md: conversational, question-oriented headings, direct without being condescending

## Context & Scope

The target audience is someone who has never opened a terminal before but needs to set up Zed + Claude Code for work (likely an epidemiology or medical research collaborator). The goal is to make installation.md approachable without bloating it -- brief motivating context for each step, not a terminal tutorial.

## Findings

### Current State Analysis

**What works well:**
1. Clear dependency ordering (Xcode CLT -> Homebrew -> Node -> Zed -> Claude Code -> claude-acp -> MCP tools)
2. Consistent three-step pattern per section (Check -> Install -> Verify)
3. Summary block at top for experienced users who want the quick path
4. Cross-links to related docs at the bottom
5. Prerequisites section sets expectations (time, account needed)

**What confuses beginners:**

#### 1. No terminal introduction
The doc jumps straight into `xcode-select --install` with no mention of how to open a terminal. A beginner literally cannot start.

**Recommendation**: Add a brief section (3-4 sentences) before Prerequisites or as part of it, explaining: open Terminal from Applications > Utilities (or Spotlight: Cmd+Space, type "Terminal"), that you type/paste commands after the `$` or `%` prompt and press Enter, and that the examples in this guide show only the command (not the prompt character).

#### 2. Detection commands are intimidating
Lines like:
```
xcode-select -p >/dev/null 2>&1 && git --version
command -v brew >/dev/null 2>&1 && brew --version
ls /Applications/Zed.app >/dev/null 2>&1 || command -v zed >/dev/null 2>&1
```
These use shell idioms (`>/dev/null 2>&1`, `&&`, `||`, `command -v`) that a beginner cannot parse. They will either skip them (fine) or try to understand them and feel lost.

**Recommendation**: Replace compound detection commands with the simplest possible check. For example, replace `xcode-select -p >/dev/null 2>&1 && git --version` with just `git --version`. If it prints a version, you already have it. The `>/dev/null` silencing is unnecessary for a human reading terminal output. Where a compound check is truly needed (Zed), explain it in words instead: "If Zed is already in your Applications folder, skip ahead."

#### 3. No "why" context for most tools
Sections have terse one-liners like "macOS package manager used for everything else below" (Homebrew) or "Provides `npx`, required by the SuperDoc and openpyxl MCP tools" (Node.js). These are accurate but don't help a beginner understand *why they should care*.

**Recommendation**: Add one sentence of motivation per section. Examples:
- **Xcode CLT**: "These provide basic developer tools (like `git`) that other installers depend on. You will not interact with them directly after this step."
- **Homebrew**: "Homebrew is a tool that lets you install software from the terminal with a single command, similar to an app store but for developer tools."
- **Node.js**: "Node.js is a programming runtime. You will not write any Node code, but two of Claude's helper tools need it to run."
- **Zed**: "Zed is the code editor you will use day-to-day. Think of it as a modern alternative to apps like TextEdit, but built for programming."
- **Claude Code CLI**: "This is the AI assistant that runs inside Zed. Installing it here means both your terminal and your editor can use it."

#### 4. Homebrew PATH instruction is unclear
Line 77: "it prints a `eval "$(/opt/homebrew/bin/brew shellenv)"` line; run that in your current shell (or close and reopen the terminal) so `brew` is on your `PATH`."

A beginner does not know what PATH is, what "run that in your current shell" means, or how to identify the relevant output line from the Homebrew installer.

**Recommendation**: Rewrite to: "When the installer finishes, it tells you to run one more command to make `brew` available. Copy the line it shows you, paste it into the terminal, and press Enter. If you are unsure which line to copy, closing and reopening the terminal works too."

#### 5. No "what you should see" after install commands
Verify sections say things like "Expected output: a line like `git version 2.xx.x`" but install commands (the ones that take time and produce lots of output) have no guidance on what success looks like or how long to wait.

**Recommendation**: After each install command, add a brief note:
- `xcode-select --install`: "A dialog box appears. Click 'Install' and wait a few minutes. When the dialog says 'Done', you can close it."
- `brew install node`: "Homebrew downloads and installs Node. This takes a minute or two. When you see your terminal prompt again (the `$` or `%`), it is finished."
- `brew install --cask zed`: "Homebrew downloads and installs Zed into your Applications folder. You will see progress output; wait for the prompt to return."

#### 6. MCP section is expert-level
The MCP tools section (lines 226-278) uses terms like "MCP server", `npx`, `--scope user`, `grep -q`, and pipe syntax that will lose beginners entirely.

**Recommendation**: Simplify the detection commands (just `claude mcp list` and tell them to look for the name in the output). Add a one-sentence framing: "These tools run behind the scenes -- you install them once and then forget about them." Keep the install commands as-is (they are copy-paste) but remove the pipe-based detection.

#### 7. The `claude-acp` section assumes Zed settings knowledge
"Open `~/.config/zed/settings.json` (or Cmd+, inside Zed)" -- a beginner does not know what `~/.config/zed/settings.json` means.

**Recommendation**: Lead with the Zed shortcut: "In Zed, press Cmd+, (comma) to open your settings file. Scroll to the bottom and paste the following block before the closing `}`." Drop the file path or make it parenthetical.

#### 8. Final verification checklist uses unchecked boxes
The verify checklist uses `- [ ]` markdown checkboxes. These render as interactive checkboxes on GitHub but are static in most other renderers. More importantly, a beginner may not know they are supposed to run each command.

**Recommendation**: Reframe as a numbered list with explicit instructions: "Run each command below. If every one prints a version or success message, you are done."

### Style Guidelines (from sibling docs)

Analyzing keybindings.md and README.md for tone:

| Pattern | Example | Source |
|---------|---------|--------|
| Question headings | "How do I open a file?" | keybindings.md |
| Bold for key terms | "**Cmd+P**", "**From the file explorer**" | keybindings.md |
| Parenthetical alternatives | "(or the default macOS Terminal)" | installation.md |
| Direct second person | "You do not need to type the full name" | keybindings.md |
| Short paragraphs | 1-3 sentences per block | all docs |
| No jargon without explanation | "the project panel on the left" | keybindings.md |

**Tone target**: Friendly, direct, second-person ("you"), short sentences. Explain jargon inline on first use. Never condescending ("simply", "just", "obviously"). Never apologetic ("don't worry").

### Recommended Phrasing Patterns

For beginner-friendly documentation, use these patterns:

1. **Motivation before action**: "Homebrew lets you install software from the terminal. To install it, paste this command:"
2. **What-you-should-see after action**: "After a minute or two, the command finishes. You should see your terminal prompt (`$` or `%`) again."
3. **Simple detection reframes**: Instead of compound shell commands, use: "To check whether you already have it, run: `git --version`. If it prints a version number, skip to the next section."
4. **Escape hatches**: "If something goes wrong, close the terminal, reopen it, and try the command again."
5. **Linking forward**: "You will use this tool in the [Configure claude-acp](#configure-claude-acp) section."

### Structural Recommendations

1. **Add a "Before you begin" or "Opening a terminal" section** (4-5 lines) before Prerequisites
2. **Simplify all detection commands** to their minimal form
3. **Add one motivation sentence** to the start of each dependency section
4. **Add "What you should see"** notes after install commands (not just verify commands)
5. **Simplify the Homebrew PATH paragraph** to practical instructions
6. **Rewrite MCP detection** to use plain `claude mcp list` output reading
7. **Lead the claude-acp section** with Cmd+, instead of file paths
8. **Convert the final checklist** from checkboxes to a numbered run-through
9. **Keep the summary block** at the top unchanged (it serves experienced users well)

### What NOT to change

- The dependency ordering is correct; do not reorder sections
- The three-step pattern (Check/Install/Verify) is good structure; keep it but soften the Check step
- The summary block at top is valuable for returning users
- The cross-links at the bottom are useful
- The actual install commands are correct; do not change command syntax
- Do not add screenshots or images (they go stale and add maintenance burden)

## Decisions

- Target a reader who has never opened a terminal, but do not write a terminal tutorial -- just enough to get them started
- Add motivation/context as single sentences, not paragraphs, to avoid bloating the doc
- Simplify detection commands rather than explaining the shell syntax
- Match keybindings.md tone (conversational, direct, question headings where natural)

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Changes conflict with task 14 (docs standardization) | Task 14 focuses on README files and cross-linking, not installation.md content; overlap is minimal |
| Over-explaining makes the doc too long | Strict rule: one motivation sentence per section, one "what you should see" line per install command |
| Condescending tone | Avoid "simply", "just", "easy", "obviously"; assume the reader is intelligent but unfamiliar with terminals |
| Detection command simplification hides edge cases | The simplified commands cover 95%+ of cases; rare edge cases can be handled by the troubleshooting link at the bottom |

## Context Extension Recommendations

None. The installation doc is project-specific and does not warrant a context file entry.

## Appendix

### Files examined
- `docs/general/installation.md` (302 lines) -- primary target
- `docs/general/keybindings.md` -- tone/style reference
- `docs/general/settings.md` -- tone/style reference
- `docs/general/README.md` -- navigation and framing reference

### Section-by-section change summary

| Section | Lines | Change type | Priority |
|---------|-------|-------------|----------|
| (new) Before you begin | -- | Add terminal opening guide | High |
| Prerequisites | 24-27 | Minor: mention terminal | Low |
| Xcode CLT | 29-56 | Simplify detection, add motivation | High |
| Homebrew | 58-86 | Simplify detection, rewrite PATH paragraph | High |
| Node.js | 88-113 | Simplify detection, add motivation | Medium |
| Zed | 115-148 | Simplify detection, add motivation | Medium |
| Claude Code CLI | 149-191 | Simplify detection, add motivation | Medium |
| Configure claude-acp | 193-209 | Lead with Cmd+, not file path | High |
| Authenticate in Zed | 211-223 | Minor rewording | Low |
| MCP Tools | 225-278 | Simplify detection, add framing | High |
| Final Verify | 280-294 | Convert checkboxes to numbered list | Medium |
