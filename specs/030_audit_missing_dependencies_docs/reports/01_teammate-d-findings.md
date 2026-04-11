# Teammate D: Strategic Horizons

**Task**: 30 - Audit .claude/ for assumed dependencies and update install docs
**Perspective**: Long-term strategic alignment
**Started**: 2026-04-10T00:00:00Z
**Completed**: 2026-04-10T01:00:00Z
**Effort**: ~1h
**Sources/Inputs**: ROADMAP.md (absent), README.md, CLAUDE.md, TODO.md, extensions.json, docs/general/installation.md, docs/general/R.md, .claude/context/project/filetypes/tools/dependency-guide.md

---

## Key Findings

1. **No ROADMAP.md exists** in this repository. There is no `specs/ROADMAP.md` and no `CHANGE_LOG.md`. The project has no formal long-term roadmap document at all.

2. **The active extension set is known and bounded**. `extensions.json` enumerates six loaded extensions: `present`, `latex`, `python`, `typst`, `epidemiology`, `filetypes`. All source from `/home/benjamin/.config/nvim/.claude/extensions/`. This is the complete dependency surface -- and it is already partially documented.

3. **The filetypes extension already has a thorough dependency guide**. `.claude/context/project/filetypes/tools/dependency-guide.md` covers pandoc, typst, pdflatex, markitdown, pandas, openpyxl, python-pptx, xlsx2csv with NixOS/Ubuntu/macOS install instructions and verification commands. This is the model other extensions lack.

4. **The main user-facing install doc (`docs/general/installation.md`) targets macOS with Homebrew exclusively** and mentions only: Xcode CLT, Homebrew, Node.js, Zed, Claude Code, superdoc, openpyxl. It does not mention R, Python, Typst, LaTeX, or the epidemiology/present/python/latex extension dependencies. It references R.md and python.md via "see also" but does not surface them structurally.

5. **The `.claude/docs/guides/user-installation.md`** (the agent-system guide, separate from the Zed config guide) is Neovim-oriented legacy content -- it references `~/.config/nvim` and still treats this as a Neovim config project. It has no mention of extension dependencies at all. This is the stale copy that needs the most fundamental rewrite.

6. **Task 21's completion note** describes reframing the repo from "epidemiology/NixOS" to "macOS Zed IDE for R and Python." This is recent intentional direction. Any dependency documentation should reinforce that framing, not regress to NixOS-centric instructions.

7. **Recent task trajectory** (tasks 20-30) shows: NixOS env gap remediation (27), full R stack verification (28), conference talk (29), and now this audit (30). The pattern reveals a user who moves between NixOS and macOS contexts and has hit real friction when dependencies are missing. The audit task is reactive, not speculative -- typst was concretely forgotten.

8. **The epidemiology extension's `r-packages.md`** is a reference guide for epi modeling packages, not an installation guide. There is no install guide for R packages needed by the epi extension (tidyverse, survival, etc.). The config gaps logged in task 20 were resolved externally in the dotfiles repo, not documented here.

---

## Roadmap Alignment

**ROADMAP.md is absent.** There is no formal roadmap to cite or align with. The project uses task-level planning via `specs/TODO.md` and task completion summaries rather than a living roadmap document.

Inferring direction from recent tasks:
- Tasks 20-22: Epi toolchain verification and demo creation
- Tasks 23-26: Code review cleanup (model IDs, keymap hygiene, git artifacts)
- Task 27: Environment gap remediation (completed externally via dotfiles)
- Tasks 28-29: Epi analysis rerun and conference talk
- Task 30 (current): Installation audit

The trajectory is: **build capability, discover friction, remediate**. This audit fits that pattern perfectly -- it is the documentation counterpart to the environment gap remediation done in task 27.

**Implication for long-term docs**: Without a ROADMAP.md, documentation work risks getting lost in individual task artifacts (reports/ and plans/) rather than being maintained as living user-facing guides. The `docs/general/` directory is the right canonical surface; it should be kept current as extensions are added or removed.

---

## Long-Term Options

### Option 1: Static install docs (status quo + completion)

**What it means**: Audit each active extension, write a "Prerequisites" section per extension, and add a consolidated checklist to `docs/general/installation.md`.

**Pros**:
- Fast to implement (hours, not days)
- Minimal system complexity
- Works on any platform without tooling
- Directly readable by users

**Cons**:
- Doc rot is real: every new extension load silently widens the undocumented gap
- Duplicates information already in `filetypes/tools/dependency-guide.md`
- Extensions are loaded from the nvim config (`source_dir` points to `nvim/.claude/extensions/`), so dependency information belongs there first; mirroring it here creates two sources of truth

**Assessment**: Necessary but not sufficient as a standalone strategy. Good for the immediate fix; poor for the long run unless paired with a forcing mechanism.

---

### Option 2: Declarative dependency manifests + auto-generated docs

**What it means**: Add a `dependencies` field to each extension's `manifest.json` (or a new `deps.json` per extension). Fields: `required_binaries`, `optional_binaries`, `required_python_packages`, `required_r_packages`. A script (or Claude agent) reads the manifests and generates/validates the install guide.

**Example manifest addition**:
```json
{
  "name": "typst",
  "version": "1.0.0",
  "dependencies": {
    "required_binaries": ["typst"],
    "optional_binaries": [],
    "notes": "typst compile is invoked directly by skill-typst-implementation"
  }
}
```

**Pros**:
- Single source of truth per extension
- Can be consumed by a `/doctor` check, CI, and doc generation
- Extension authors are forced to declare deps at authorship time (not retroactively)
- Scales cleanly as extensions are added/removed

**Cons**:
- Requires schema design and enforcement
- The extension source directories are in `nvim/.claude/extensions/` (a different repo), not in this config -- so manifest changes must happen upstream
- Extension manifests already have a schema (`manifest.json` exists per extension in the nvim repo); adding deps is additive but requires cross-repo coordination
- Python and R packages are environment-managed differently per platform

**Assessment**: The right long-term answer for the agent system architecture. Medium effort. Should be proposed as a follow-on meta task targeting the nvim repo, not this one.

---

### Option 3: Nix flake / devshell as source of truth

**What it means**: Create a `flake.nix` (or `shell.nix`) in this config repo that declares all dependencies. On NixOS/nix-darwin, `nix develop` gives a fully reproducible environment.

**Pros**:
- Fully reproducible on any Nix-capable platform (NixOS, macOS with nix-darwin, WSL2)
- Eliminates entire class of "forgot typst" failures
- User is already on NixOS (see task 27, dotfiles repo)
- The filetypes dependency guide already has NixOS flake examples

**Cons**:
- This repo's docs are intentionally macOS/Homebrew-first (task 21 reframing)
- Zed is a macOS-first app; the target audience uses Homebrew, not Nix
- A Nix flake here would contradict the macOS framing established in task 21
- NixOS config is managed in `~/.dotfiles` (separate repo, task 47); adding a second Nix surface here creates fragmentation
- Collaborators (per memory: Zed is shared, no vim mode) may not have Nix

**Assessment**: Wrong tool for this specific repo given the macOS reframing and shared-collaborator context. The Nix solution belongs in `~/.dotfiles`, which already manages the NixOS environment. This repo's install docs should stay Homebrew-centric.

---

### Option 4: Runtime `/doctor` or `/refresh --check-deps` command

**What it means**: Add a `/doctor` command (or extend `/refresh`) that checks for required binaries and packages at runtime, reports what's missing, and suggests installs.

**Example output**:
```
/doctor

Checking dependencies...
  claude     OK (1.2.3)
  typst      MISSING  -- brew install typst
  pdflatex   MISSING  -- brew install mactex-no-gui
  R          OK (4.4.1)
  python3    OK (3.12)
  pandoc     OK (3.1)

Extensions loaded: present, latex, python, typst, epidemiology, filetypes
2 dependencies missing. Run install commands above, then restart Claude Code.
```

**Pros**:
- Answers the user's actual question ("did I forget anything?") durably and on-demand
- Self-updating: as extensions change, the check reflects reality without doc edits
- Directly actionable: gives install commands, not just a list
- Could be triggered after `/meta` loads an extension (`/doctor` as postflight)
- Leverages existing `/refresh` infrastructure

**Cons**:
- Implementation cost: requires reading manifests (or a hardcoded deps list), checking `command -v`, and potentially checking Python/R packages
- Without declarative manifests (Option 2), it needs a hardcoded deps map that has its own rot problem
- Doesn't help users before their first Claude Code session

**Assessment**: High value as a runtime safety net, but depends on manifests or a maintained deps map. Best implemented as a future enhancement after Option 1 fixes the immediate documentation gap. A `/doctor` command would be the most durable long-term answer to the underlying need.

---

## Recommended Approach

**Hybrid: Option 1 now, Option 4 as a follow-on task.**

### Phase 1 (this task's output): Static doc update

1. **Audit all six active extensions** for their binary and package requirements (this is what Teammates A/B/C are doing in parallel)
2. **Add a "Extension Prerequisites" section to `docs/general/installation.md`** -- a consolidated table: extension name | required tools | install commands (macOS/Homebrew only, consistent with the current doc framing)
3. **Rewrite `.claude/docs/guides/user-installation.md`** to remove the Neovim-centric content and reflect the actual Zed config system (it currently tells users to `cd ~/.config/nvim`)
4. **Use `filetypes/tools/dependency-guide.md` as the model** for any per-extension dependency docs that need to be created (e.g., epidemiology R packages, latex/typst binaries)
5. **No NixOS content** in the user-facing `docs/general/installation.md` -- this belongs in the dotfiles repo

### Phase 2 (follow-on meta task): `/doctor` command

Spawn a meta task to implement `/doctor` as a command that:
- Reads a deps map (initially hardcoded, later driven by manifests)
- Checks `command -v` for each binary
- Reports missing deps with Homebrew install commands
- Can be run after any `/meta` load-extension operation

This directly addresses the user's underlying need without relying on docs being kept current.

---

## Adjacent Opportunities

### 1. Cross-repo manifest standardization

The extension source dirs are in `nvim/.claude/extensions/`. Adding a `deps` field to those manifests is a meta task for the **nvim config repo**, not this one. But it would power the `/doctor` command here. This is worth proposing as a paired task: one here (create `/doctor`), one in the nvim repo (add dep fields to manifests).

### 2. Rewrite `.claude/docs/guides/user-installation.md`

This file is currently vestigial (Neovim-centric, references `~/.config/nvim`). The Zed config repo has outgrown it. The task 30 audit is the natural moment to either delete this file or repurpose it as a Zed-specific "Claude Code setup for Zed users" guide -- distinct from the main `docs/general/installation.md`.

### 3. Extension lifecycle documentation

There is no guide explaining: how to load/unload extensions, what `extensions.json` contains, or what happens when an extension's `source_dir` moves. As the extension count grows (currently 6), this gap becomes a support burden. A short `docs/general/extensions.md` would prevent future confusion.

### 4. Dependency-aware extension loading

The extension loader (in the nvim repo) could check required binaries during `<leader>ac` load and warn if any are missing. This is a stronger form of the `/doctor` command -- proactive rather than reactive. Medium complexity, high value.

### 5. Epi-specific R package install guide

Task 20 produced `config_gaps.md` identifying missing R packages (tidyverse, survival, etc.). Task 27 fixed them externally in the dotfiles repo. The fix was never documented here. Creating `docs/general/epi-packages.md` (or extending `R.md`) with the standard set of R packages needed for epi tasks would prevent a third recurrence of this failure.

---

## Creative / Unconventional Angles

### "Install-on-first-use" interception

Rather than documenting all deps upfront, the relevant agent (e.g., `epi-implement-agent`) could check for required tools at session start and interrupt with install guidance before attempting to use a missing binary. This moves dep handling to the point of failure rather than the install doc -- dramatically better UX. Implementation: each agent's SKILL.md adds a preflight `command -v typst` check with a friendly error message.

### Dependency declaration as extension authorship constraint

The meta-system's `/meta` command (which creates tasks for `.claude/` changes) could require dep declaration as part of the "creating an extension" checklist. Currently, `docs/guides/creating-extensions.md` may not mention dependencies. Adding a mandatory "deps" section to the extension creation checklist is a process-level fix with zero ongoing maintenance cost.

### Versioned dependency snapshots

Given that extensions source from the nvim repo, which is versioned, the `extensions.json` already records `loaded_at` timestamps. A future enhancement could record the exact version of each dependency at load time, enabling `git blame`-style answers to "what changed when typst stopped working?"

---

## Confidence Level

**High** on:
- The filetypes extension dependency guide being the correct model for other extensions
- The macOS/Homebrew-only framing being the right scope for `docs/general/installation.md`
- The `.claude/docs/guides/user-installation.md` being stale and needing substantial revision
- A `/doctor` command being the most durable long-term answer to the underlying need

**Medium** on:
- Whether declarative manifests are worth the cross-repo coordination cost in the near term (depends on how frequently extensions are added)
- The exact scope of the Phase 1 doc update (depends on what Teammates A/B/C find in the actual extension audits)

**Low confidence / deferred**:
- Whether a Nix flake approach could be made compatible with the macOS framing -- I did not investigate nix-darwin compatibility deeply
- Whether the epidemiology extension's `r-packages.md` already covers all the packages that caused task 20's failures (I read only the first 60 lines)

---

*Report written by Teammate D (Horizons). Intended to be synthesized with Teammates A, B, and C findings by the orchestrator.*
