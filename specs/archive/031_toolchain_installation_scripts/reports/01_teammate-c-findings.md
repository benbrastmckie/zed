# Research Report: Task 31 — Teammate C (Critic)

**Task**: 31 — Create installation scripts for toolchain docs and a master installation wizard
**Started**: 2026-04-10
**Completed**: 2026-04-10
**Effort**: 1 hour (research only)
**Dependencies**: Task 30 (toolchain docs baseline)
**Sources/Inputs**:
- `/home/benjamin/.config/zed/docs/general/installation.md`
- `/home/benjamin/.config/zed/docs/toolchain/README.md`
- `/home/benjamin/.config/zed/docs/toolchain/r.md`
- `/home/benjamin/.config/zed/docs/toolchain/python.md`
- `/home/benjamin/.config/zed/docs/toolchain/mcp-servers.md`
- `/home/benjamin/.config/zed/docs/toolchain/typesetting.md`
- `/home/benjamin/.config/zed/docs/toolchain/shell-tools.md`
- `/home/benjamin/.config/zed/docs/toolchain/extensions.md`
- `/home/benjamin/.config/zed/specs/TODO.md` (task 31 entry)
- `/home/benjamin/.config/zed/.claude/scripts/` (script conventions inventory)

**Artifacts**:
- `/home/benjamin/.config/zed/specs/031_toolchain_installation_scripts/reports/01_teammate-c-findings.md`

**Standards**: report-format.md, subagent-return.md

**Angle**: Critic — this report surfaces blind spots, scope ambiguities, and unvalidated assumptions in the task specification. It does NOT propose implementation approaches; each finding is a question the user should answer (or an assumption the planner should name) before Stage 3 planning.

---

## Executive Summary

- The spec assumes a clean one-script-per-toolchain-file mapping, but several documented dependencies live in **multiple files** or in **no file** (e.g., Xcode CLT straddles installation.md and shell-tools.md; fonts sit inside typesetting.md rather than their own group). Double-install and coverage gaps are both real risks that the spec does not address.
- The "accept/skip/cancel per collection" UX model is **too coarse** for the content of `extensions.md`, where a single "collection" bundles R, Stan-backed packages taking 15-20 minutes to compile, Quarto, rmcp, renv, and optional extras. There is no articulated granularity policy.
- The spec is **silent on five important concerns**: idempotency on re-run, sudo/interactive prompts (tlmgr, cask admin, CRAN mirror selection, R install prompts), Ctrl-C / partial-state recovery, ordering/dependency between toolchain scripts, and whether Verify steps are run automatically.
- The task 30 decision record in `mcp-servers.md` (Lean MCP pruned) creates a **bit-rot risk**: if the master script auto-discovers or reinstalls everything in `docs/toolchain/`, it must not resurrect Lean MCP, which was explicitly removed from the allowlist.
- The "beginner-friendly" framing collides with the need to `git clone` before running anything: the master script can only be invoked AFTER the repo is local, but a true beginner does not yet have `git` (that is step 1 of installation.md). The chicken-and-egg ordering is unaddressed.
- The rewrite directive ("every file in `docs/toolchain/` should begin by explaining how to run the corresponding script before the manual instructions") risks **diluting the Check/Install/Verify template** that task 30 spent six phases installing. The Critic's view is that the planner must explicitly decide whether the script leads as a replacement path or a fast-forward shortcut.

## Context & Scope

This report investigates the research quality and completeness of task 31's specification. Task 31 asks for: (a) per-file install scripts under `docs/toolchain/`, (b) a master wizard that installs `installation.md` content then runs each toolchain script, (c) accept/skip/cancel gating per collection, and (d) doc rewrites so that each file leads with "run the script." The Critic's job is to surface what the spec DOES NOT say, and to list questions that must be answered before planning.

The Critic did NOT investigate implementation choices (shell vs. other language, dry-run mechanism, prompt library, etc.). Those are out of scope; implementation trade-offs are for other teammates.

## Findings

### 1. Scope ambiguity: overlap and coverage between installation.md and docs/toolchain/

**Finding 1.1 — Xcode CLT is claimed by two documents.**
`installation.md` lines 37-63 install Xcode Command Line Tools as the first base step. `shell-tools.md` lines 9-38 treat `git` as its own section and lines 92-117 treat `make` as its own section, but both say "provided by Xcode Command Line Tools... if you ran `xcode-select --install` from docs/general/installation.md, you already have it." If the master script runs installation.md content AND `shell-tools.md`'s script, it will re-trigger Xcode CLT detection logic twice. This is not a bug per se (the check command is idempotent) but the spec has not articulated a **detection-dedup policy**. Is the master script expected to track "already installed this session" or rely on every sub-script being independently idempotent?

**Finding 1.2 — Fonts are buried inside typesetting.md, not their own group.**
`typesetting.md` lines 166-205 treat fonts as a sub-section of the typesetting file, not a separate installable group. If the user selects "skip LaTeX" at the wizard prompt but wants Typst (which also uses fonts), the coarse accept/skip choice on the typesetting script could either (a) install fonts they did not realize they were getting, or (b) skip fonts they needed. The spec does not say which collection owns fonts. Evidence: `extensions.md` line 40 says `latex` needs fonts; line 59 says `typst` needs fonts; line 172 says `present` needs fonts. All three extensions depend on a sub-section of one file.

**Finding 1.3 — Shell tools split across installation.md and shell-tools.md.**
`git` appears in installation.md (as part of Xcode CLT) AND in shell-tools.md (as its own section). `make` is the same story. `jq`, `gh`, `fontconfig` are only in shell-tools.md. Where does the master script install these: as part of "installation.md software" (git, make) or as part of "shell-tools.md group" (jq, gh)? The user's spec says "installs all software mentioned in installation.md AS WELL AS running the other scripts" — which implies duplication is explicit. Planner must decide whether shell-tools.md's script re-tries git/make or skips them.

**Finding 1.4 — Node.js is in installation.md but MCP servers depend on it.**
Node.js is installed in `installation.md` lines 97-123. Several MCP servers in `mcp-servers.md` use `npx` (obsidian-memory). Several in `python.md` line 310-317 are flagged as "not Python but referenced here." If the master script runs installation.md content first and mcp-servers.md's script second, the ordering is correct — but the spec has NOT stated an ordering requirement. The planner must make this implicit dependency explicit.

**Finding 1.5 — uvx / uv is needed for mcp-servers.md but lives in python.md.**
`mcp-servers.md` lines 7-9 explicitly say "Most of the MCP servers below are launched via `uvx` ... those prerequisites are covered in python.md." This is a cross-file dependency: mcp-servers.md's script CANNOT run before python.md's script. The spec's "each of the other scripts afterwards" phrasing does not acknowledge this topological ordering constraint.

**Finding 1.6 — R is needed for rmcp but rmcp is in mcp-servers.md.**
Same pattern: `rmcp` requires R (per `r.md` lines 239-247 and `mcp-servers.md` lines 43-79). Another implicit topological edge: r.md -> mcp-servers.md.

**Finding 1.7 — Not every "thing the agents assume" is in a per-file script.**
`extensions.md` is structurally different from the other files — it's a router/summary, not a tool-install file. The spec says "one script per file" in `docs/toolchain/`. Does `extensions.md` get a script? If yes, what does it install (it has its own epidemiology R-package block at lines 108-129 that duplicates nothing else)? If no, then the epidemiology R-package block is **unreachable** from the master wizard. This is a live gap.

### 2. Idempotency, safety, and interactive-prompt blind spots

**Finding 2.1 — Partial-success re-run is unspecified.**
Each toolchain doc uses a Check / Install / Verify template (README.md lines 24-52). The Check command detects whether the tool is installed. A script that faithfully implements this template would be idempotent per-tool. But the spec does not REQUIRE idempotency, and it does not say how to handle "tool X is installed but its sub-package Y failed." Example: `r.md` installs R via brew, then installs `languageserver`/`lintr`/`styler` from within R. What if brew succeeded but the in-R install crashed? On re-run, the Check for R passes and the in-R install is never retried. This is a silent failure mode the spec does not acknowledge.

**Finding 2.2 — Homebrew is a hard prerequisite for every toolchain script, including the master.**
`toolchain/README.md` line 11: "Homebrew itself is a prerequisite for every install step below." The master script per the spec "installs all software mentioned in installation.md" — which INCLUDES Homebrew itself at lines 65-95. So the master script must bootstrap Homebrew. But what about the per-file toolchain scripts: do they also bootstrap Homebrew (for users who run them directly, without the master), or do they assume the master has already installed it? The spec does not say. Running `brew install ...` without brew present produces a confusing error.

**Finding 2.3 — tlmgr needs sudo, and runs non-interactively at the user's mercy.**
`typesetting.md` lines 50-52:
```
sudo tlmgr update --self
sudo tlmgr install latexmk collection-fontsrecommended collection-latexextra biber
```
Any script invoking this will block on an interactive sudo prompt. The spec says nothing about sudo handling — the master wizard cannot "accept/skip/cancel per collection" smoothly if the shell is blocked on a password prompt buried inside one of them. This is a UX trap for beginners.

**Finding 2.4 — Cask installs can pop a macOS admin password dialog.**
`brew install --cask basictex`, `brew install --cask mactex`, `brew install --cask quarto`, `brew install --cask zed`, `brew install --cask claude-code` all may trigger a native GUI password prompt. There is no way for the wizard to pre-answer these. This is not a blocker but it IS a beginner-facing surprise that the spec does not warn about.

**Finding 2.5 — CRAN mirror selection is interactive on first run.**
`r.md` lines 63-64 explicitly document "The first time you install packages, R may ask you to choose a CRAN mirror." A script calling `R -e 'install.packages(...)'` without setting `repos=` will either hang waiting for input or crash. The spec does not address non-interactive CRAN usage.

**Finding 2.6 — Ctrl-C handling and partial state are not specified.**
The spec says "accept/skip/cancel each collection" — but what does "cancel" mean mid-install? If the user hits Ctrl-C during `brew install --cask mactex` (~5 GB download, can take 30+ minutes), does the master script trap SIGINT, roll back, continue to the next collection, or exit entirely? Unanswered.

**Finding 2.7 — Brew taps for casks.**
Historically, font casks lived under `homebrew/cask-fonts`. `typesetting.md` line 189 says "now core in newer Homebrew" and suggests `brew search font-<name>` as a fallback. A real script cannot "search" — it must know. If the user's brew is older than the core-font migration, these installs fail silently.

**Finding 2.8 — Verification is not declared mandatory.**
Each toolchain doc ends with a Verify section. The spec does not say whether the scripts should RUN Verify after Install, and if Verify fails whether the script should abort or continue. This is a policy decision the planner must make explicit.

### 3. Doc rewrite implications

**Finding 3.1 — Check/Install/Verify template vs "script-first" lead.**
Task 30 spent six phases standardizing the Check / Install / Verify three-section pattern across every file in `docs/toolchain/` (see `toolchain/README.md` lines 24-52). The task 31 spec says "every file in `docs/toolchain/` should begin by explaining how to run the corresponding script before the manual installation instructions." This inserts a new top-level section ABOVE the first tool's Check. Questions:
- Does the script section count as Install for the whole file (making the individual Check/Install/Verify blocks into "alternative manual mode")?
- Or is the script section a "fast path" that does not replace the per-tool structure?
- How does a reader who runs the script THEN hits a problem know which per-tool Verify to re-run?

**Finding 3.2 — Bit-rot risk: script as source of truth vs doc as source of truth.**
If the script leads every file, there are now TWO authoritative lists of install commands: the shell inside the script and the fenced code blocks in the markdown. Task 30's template assumes the markdown code blocks are the source of truth (explicitly copy-pasteable, verbatim). If the planner has the script import commands from the markdown (e.g., parse fenced blocks), that's one policy. If the planner duplicates them, drift is inevitable. The spec does not say which is authoritative.

**Finding 3.3 — installation.md rewrite collides with the "quick-start command list" at lines 5-14.**
Line 5-14 already provide a "for experienced users" fast path listing `xcode-select --install`, brew, node, zed, claude-code. The task 31 spec wants the master wizard to LEAD installation.md. Does the existing quick-start command list get deleted, moved below the manual section, or become the basis of the wizard? The spec is silent.

### 4. Master wizard UX trap — granularity

**Finding 4.1 — "Accept/skip/cancel per collection" has no sub-choice mechanism.**
The `epidemiology` block inside `extensions.md` lines 108-129 is a single collection of ~25 R packages, including Stan-backed ones that take 15-20 minutes to compile (line 131). A user who wants `survival` but not `brms` has no granular knob. The spec explicitly rules out finer granularity by saying "each collection of packages." Is the user aware this is a hard simplification?

**Finding 4.2 — Some "collections" are genuinely heterogeneous.**
`typesetting.md` is one file but contains: LaTeX (~100MB BasicTeX to ~5GB MacTeX), Typst (~50MB), Pandoc, markitdown, and fonts. A single accept/skip for this entire file forces users who only want Typst to accept-or-skip everything. Likewise `mcp-servers.md` contains rmcp (R-dependent), markitdown-mcp, mcp-pandoc, and obsidian-memory (which is NOT a simple install — per line 14-41 it requires the Obsidian desktop app and plugin setup by hand). The spec does not flag that "one toolchain file" is not a natural install unit.

**Finding 4.3 — obsidian-memory is not a script-installable target.**
`mcp-servers.md` lines 14-41 explicitly route to `.claude/context/project/memory/memory-setup.md` for multi-step GUI-driven setup. A script cannot perform those steps. The planner must decide whether to: (a) skip obsidian-memory in the mcp-servers script entirely with a "see docs" message, (b) print instructions and pause, or (c) pretend it does not exist. The spec does not address GUI-driven dependencies.

### 5. Missing verification step

**Finding 5.1 — No verify policy.**
Per Finding 2.8, the spec does not say whether scripts verify after install. The task 30 template has a Verify section for every tool. A defensible policy is "run Verify, abort on failure" but nothing in the user's spec mandates this.

**Finding 5.2 — No post-install summary.**
Even if each script verifies internally, the master wizard could produce a final summary of "what was installed, what was skipped, what failed." The spec does not require this, but its absence leaves the user with no audit trail after a long install session.

### 6. Testing

**Finding 6.1 — No dry-run mode is specified.**
The spec does not mention `--dry-run`. Without one, the scripts can only be tested by actually installing, which is slow and destructive on the tester's machine. The planner has to decide: add a dry-run that prints what WOULD be run, or ship without one and accept that testing requires a throwaway VM.

**Finding 6.2 — No CI story.**
The `.claude/scripts/` directory has `check-extension-docs.sh` and `validate-*` scripts that run in normal CI. A new install-wizard has no natural CI harness because it mutates system state. The spec does not acknowledge this testing gap.

**Finding 6.3 — Manual test plan is unarticulated.**
The only realistic test is "spin up a fresh macOS VM, clone the repo, run the wizard, check everything works." The spec does not mention this as an acceptance criterion, and there is no obvious way to hit the "fresh install on a Mac" path short of actual hardware.

### 7. Interaction with task 30 decisions

**Finding 7.1 — Lean MCP pruning must NOT be undone.**
`mcp-servers.md` lines 153-186 document the deliberate removal of Lean MCP from this repo, along with restoration instructions. Any master script that naïvely walks `docs/toolchain/*.md` and generates install actions from fenced code blocks will scrape the "To restore" JSON snippet at lines 171-182 and potentially re-install Lean MCP. The Critic's view: the planner must establish an **explicit allowlist** of which sections in each file are live install steps vs. decision records / restoration notes / troubleshooting, and only the live ones should be in scope for the script.

**Finding 7.2 — The typst allowlist entry in settings.json is NOT a Homebrew install.**
`extensions.md` line 60 requires `Bash(typst *)` to be present in `.claude/settings.json`'s `permissions.allow`. Task 30 fixed this. The master wizard is not responsible for editing `settings.json` — but a naïve "install everything the typst extension needs" script would miss that the allowlist is part of the dependency, not just the binary. Another ambiguity: is the script's scope "install software" or "make the extension actually work end-to-end"? If the latter, the script has to edit `.claude/settings.json` too, which is substantially more invasive.

### 8. What the user did not ask about

**Finding 8.1 — Uninstall.** No mention.
**Finding 8.2 — Update / upgrade.** No mention. Does re-running the wizard upgrade tools or only install-if-missing?
**Finding 8.3 — Version pinning.** No mention. `brew install r` picks whatever Homebrew has today. Is this fine?
**Finding 8.4 — Logging.** No mention. On failure, is there a log file the user can attach to a bug report?
**Finding 8.5 — Non-interactive mode.** No mention. CI or reproducibility users may want `--yes-to-all` or a config-file-driven mode. Not in spec.

### 9. Relative vs absolute paths; working directory

**Finding 9.1 — The scripts' CWD is unstated.**
Does the master script assume it is run from the repo root (`cd /path/to/zed && ./scripts/install.sh`)? From anywhere (with path discovery via `$(dirname "$0")`)? The spec does not say. If the beginner pastes a raw command into Terminal, CWD is `$HOME`, not the repo.

**Finding 9.2 — Where do the scripts live in the repo?**
`.claude/scripts/` hosts agent-system scripts. `scripts/` at repo root does not exist yet in this layout. `docs/toolchain/` is docs. The spec does not say WHERE the new scripts live. (e.g. `scripts/install/`, `docs/toolchain/scripts/`, `.claude/scripts/install/`, or alongside the doc: `docs/toolchain/r.sh`?) Each choice has visible trade-offs the planner must surface.

**Finding 9.3 — The beginner has to clone first.**
Per the spec: "explaining to a beginner how to clone the repo and run the script." But a beginner's fresh Mac has no `git`. `git` comes from Xcode CLT (installation.md line 37). Therefore:
- The beginner must run `xcode-select --install` manually before they can `git clone`.
- They must also download a zip from GitHub or be walked through installing git via another path.
- The master wizard CANNOT bootstrap git, because the wizard lives inside the repo.

This chicken-and-egg is not addressed. The planner must either: (a) provide a one-liner `curl | bash` that runs a remote bootstrap script hosted on GitHub, (b) tell the user "install Xcode CLT and git first, then clone, then run this," or (c) some hybrid. The spec makes no choice.

### 10. Beginner-friendliness reality check

**Finding 10.1 — "Beginner" is not defined.**
Does "beginner" mean: (a) never used a terminal, (b) used a terminal a bit, (c) used a terminal but not a package manager, or (d) used a package manager but not brew? The answer shapes which sections of installation.md the wizard replaces vs. which it leaves as fallback manual instructions.

**Finding 10.2 — Spotlight / Terminal / paste flow is already documented.**
installation.md lines 20-26 walk the user through opening Terminal for the first time. If the wizard replaces the lead of installation.md, does it still include this onboarding text? Or does it assume the reader has ALREADY opened Terminal and pasted the one-liner? Different answers, different docs.

**Finding 10.3 — Color, Unicode, macOS Terminal compatibility.**
macOS ships zsh by default (not bash). Scripts must declare shell compatibility. The spec does not mention `#!/usr/bin/env bash` vs `#!/bin/zsh` vs POSIX sh. For beginner-proof output (progress, color, yes/no prompts), the choice matters — and affects whether the scripts work on a truly fresh Mac where `bash` is still the prehistoric 3.2 version.

## Unresolved Questions (for the user to answer before planning)

1. **Granularity**: Is it acceptable that "accept/skip" operates at file-level only, with no sub-choices within epidemiology packages or typesetting tools?
2. **Script location**: Where do the scripts live — `.claude/scripts/install/`, `scripts/install/`, `docs/toolchain/scripts/`, or co-located with the doc (`docs/toolchain/r.sh`)?
3. **Shell**: bash, zsh, or POSIX sh? Which macOS versions must the script support?
4. **Bootstrap**: How does a beginner get from "fresh Mac" to "inside the cloned repo"? Is there a `curl | bash` one-liner stage, or a manual "install git first" preamble?
5. **Idempotency guarantees**: Must scripts be re-runnable after partial failure? If yes, what detection level (per tool, per package, per file)?
6. **Verification**: Should each script auto-run its Verify commands? Abort on Verify failure?
7. **Dry-run**: Is a `--dry-run` mode required, or explicitly deferred?
8. **Logging**: Is a log file required? Where does it live?
9. **Interactive prompts inside tools**: How are `sudo tlmgr`, cask admin password, CRAN mirror selection, and R "save workspace?" prompts handled? Pre-answer where possible, document where not?
10. **Ordering**: What is the topological order of toolchain scripts? (shell-tools -> python -> r -> mcp-servers -> typesetting -> extensions? Or something else?) Must the master script enforce this, or can user interleave?
11. **Fonts**: Which collection owns fonts — typesetting (current doc home), a separate group, or bundled into each dependent extension script?
12. **extensions.md**: Does this file get a script at all? If yes, does it install the epidemiology R-package block, or is that block orphaned?
13. **obsidian-memory**: How is this multi-step GUI-driven dependency handled in a script that expects Accept/Skip/Cancel semantics?
14. **Lean MCP resurrection guard**: How do scripts distinguish "live install step" vs "decision record JSON snippet" in the markdown?
15. **settings.json mutations**: Are scripts allowed to edit `.claude/settings.json` (e.g., typst allowlist) or only install binaries?
16. **Cancel semantics**: Ctrl-C vs wizard "Cancel" button — what does each do? Per-collection rollback?
17. **Upgrade mode**: On re-run, does the wizard upgrade already-installed tools or only detect-and-skip?
18. **Double-install dedup**: When installation.md content and shell-tools.md both cover git/make, does the master track state to avoid repeated Check commands, or is redundancy acceptable?
19. **Test harness**: Is there any CI / automated test for these scripts, or is the acceptance criterion "manually tested on one fresh Mac"?
20. **Success definition**: What does "the wizard worked" mean? Every Verify passed? Every extension's Check one-liner passes? User can open Zed and start a Claude Code thread?

## Evidence / Examples

- **installation.md:5-14** — Existing "experienced user" quick-start block conflicts with the "wizard-first" rewrite directive.
- **installation.md:37-95** — Xcode CLT, Homebrew install sequence; Homebrew bootstrap is itself interactive (password prompt, PATH setup).
- **installation.md:197-214** — `claude-acp` config requires editing `settings.json`; not a brew install. Does the wizard handle this?
- **installation.md:218-226** — Authenticate in Zed is a Zed GUI flow. Cannot be scripted.
- **toolchain/README.md:11** — "Homebrew itself is a prerequisite for every install step below" — the per-file scripts cannot bootstrap brew if they are meant to run standalone.
- **toolchain/README.md:24-52** — Check / Install / Verify template — the task 30 invariant that task 31's doc-rewrite will pressure.
- **toolchain/r.md:56-70** — `install.packages(...)` inside interactive R — script must use `Rscript -e` with `repos=` set.
- **toolchain/r.md:63-65** — "CRAN mirror prompt" — explicit first-run interactive dependency.
- **toolchain/r.md:72** — `q()` exit, "Save workspace image? n" — interactive on first session exit.
- **toolchain/typesetting.md:50-52** — `sudo tlmgr update --self` — sudo-required, non-trivial to pre-authorize.
- **toolchain/typesetting.md:166-205** — Fonts block inside typesetting file, not its own file.
- **toolchain/typesetting.md:189** — "If a cask name is not found, use `brew search font-<name>`" — unbounded human step embedded in instructions.
- **toolchain/mcp-servers.md:14-41** — obsidian-memory requires desktop GUI steps.
- **toolchain/mcp-servers.md:153-186** — Lean MCP pruning decision record with a "To restore" JSON snippet that a naive parser would treat as an install step.
- **toolchain/extensions.md:108-129** — Epidemiology R-package block inside the router file, not in r.md. Orphaned if extensions.md does not get a script.
- **toolchain/extensions.md:60, 68** — Typst `settings.json` allowlist requirement; not a binary install.
- **toolchain/extensions.md:131** — "first `install.packages("brms")` can take 15-20 minutes" — long-running inside a single "collection" prompt.
- **toolchain/shell-tools.md:19, 101** — `git` and `make` both claimed as "provided by Xcode CLT from installation.md."

## Decisions (made during research)

- Scope this report strictly to gaps and unresolved questions. Do not propose implementation solutions.
- Treat the Check/Install/Verify template from task 30 as a hard invariant: any planner proposal that weakens it should be flagged as a regression, not an improvement.
- Treat the Lean MCP pruning decision as a hard invariant: any planner proposal that resurrects Lean MCP is a task-30 regression.

## Risks and Mitigations

Implementation-risk analysis is explicitly out of scope for the Critic role. Risks listed here are ONLY about research/spec quality, not implementation.

- **Research risk: fabricated coverage.** If the planner proceeds without the user answering the unresolved questions, the plan will embed the planner's assumptions about granularity, scope, idempotency, and ordering — and the user will not realize those decisions were made until after review. Mitigation: the /plan step should start with "we need to answer these questions first" rather than proceeding to phase design.
- **Research risk: task-30 regression.** The Lean MCP pruning and the typst allowlist fix are both at risk of being undone by a too-ambitious script scope. Mitigation: explicit allowlist of what each script touches, reviewed against task-30 phase-6 artifacts.
- **Research risk: doc bit-rot.** The "script leads the doc" rewrite could create a drift vector between scripts and the Check/Install/Verify blocks. Mitigation: planner must pick a single source of truth and document it.

## Context Extension Recommendations

none — this task is meta and the gaps identified are task-specific, not reusable patterns for future research.

## Appendix — Research approach

- Read the TODO.md entry for task 31 to confirm the task description and scope.
- Read all files in `docs/toolchain/` and `docs/general/installation.md` verbatim.
- Cross-referenced task 30's pruning decisions in `mcp-servers.md`.
- Inventoried existing `.claude/scripts/` to understand current script conventions (no existing installer).
- Did NOT run WebSearch — the Critic angle is about internal consistency and specification gaps, not external best practices.

## Confidence Level

| Concern | Confidence | Notes |
|---|---|---|
| Lean MCP resurrection risk | **high** | mcp-servers.md:171-182 is literal JSON any parser would grab |
| Chicken-and-egg git bootstrap | **high** | Beginner has no git; wizard lives inside repo |
| File-level granularity too coarse | **high** | Epidemiology/typesetting blocks are demonstrably heterogeneous |
| Interactive prompts (sudo, CRAN, cask admin) | **high** | Documented verbatim in source files |
| Topological ordering (python->mcp, r->rmcp) | **high** | Cross-references in source files are explicit |
| Fonts ownership ambiguity | **high** | Three extensions depend on one sub-section |
| extensions.md script scope | **high** | Structurally different from other files; orphan risk real |
| Check/Install/Verify template dilution | **medium** | Depends on planner's rewrite approach |
| Double-install dedup | **medium** | Affects efficiency and messaging, not correctness |
| Script location / CWD | **medium** | Design question, not a spec gap per se |
| Dry-run / CI testability | **medium** | Common concern; user may or may not care |
| Uninstall / upgrade / logging gaps | **low** | User likely has an implicit "not in scope" for these |
| Shell / macOS compatibility (bash 3.2 vs zsh) | **low** | Standard scripting concern; planner will decide |
