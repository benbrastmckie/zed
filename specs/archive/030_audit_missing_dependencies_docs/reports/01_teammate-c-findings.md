# Teammate C: Critic Analysis

**Task**: 30 — Audit .claude/ for assumed external dependencies
**Role**: Critic — challenging framing, not inventorying tools
**Started**: 2026-04-11T00:25:00Z
**Completed**: 2026-04-11T00:35:00Z

---

## Key Findings (gaps in audit framing)

- The audit as scoped risks producing a flat tool list that is technically complete but practically useless, because it collapses five radically different dependency profiles (core harness, epi/R, typst/latex, filetypes/conversion, memory/Obsidian) into one undifferentiated inventory.
- The deepest dependencies — system libraries beneath R/Python packages, fonts for typst/latex, audio subsystem for TTS hooks, and Lean toolchain — are invisible to grep-based discovery because they are not mentioned in any .claude/ file; they only surface at runtime failure.
- The audit's implicit audience is undefined. A "fresh clone" scenario, a "new contributor" scenario, and a "CI image build" scenario each require a different dependency surface and a different level of version specificity.
- The question "what external tools does this system use?" is subtly wrong. The more useful question is "what must be true about the environment for each capability to work, and what degrades gracefully when something is absent?"

---

## Hidden Dependency Surfaces

These are surfaces Teammate A is unlikely to find by grepping .claude/ files for tool names, because they are implicit, environmental, or sub-process.

### 1. System Libraries Beneath Python/R Packages

The epi extension prescribes `brms`, `EpiNow2`, and `epidemia`, which compile Stan models at first use. Stan compilation requires:

- A working C++ toolchain (`gcc`/`clang`, `make`)
- `libssl` (for CmdStan download on first use)
- On NixOS: these are not ambient; they must be in scope via `pkgs.stdenv` or a dev shell

The filetypes extension uses `markitdown`, which may invoke OCR backends (`tesseract`, `libmagic`, `libjpeg`, `libpng`) depending on the input file type. None of these are mentioned in `dependency-guide.md`.

`python-pptx` may depend on `Pillow` for image handling; `Pillow` in turn needs `libjpeg`, `libpng`, `zlib`, and `libwebp` as shared libraries that must be present at wheel install time or at runtime.

### 2. Fonts

Typst's `compilation-standards.md` says "Typst embeds fonts automatically" and "Use system fonts or include font files" — but it does not say which system fonts the project's own templates actually require. The `fletcher` package for diagrams relies on math fonts. The `academic-clean` and `clinical-teal` themes in the present extension (Slidev) have font assumptions not stated anywhere in .claude/.

LaTeX compilation (`pdflatex`, `latexmk`) uses fonts from the texlive distribution, but the choice of scheme (basic vs. recommended vs. full) determines which fonts are available. The dependency guide recommends `scheme-basic`, which omits Latin Modern Math and many other fonts academic documents commonly assume.

### 3. Audio Subsystem (TTS Hooks)

`tts-notify.sh` requires:
- `piper` (TTS engine, not in any standard package manager, installed to `~/.local/share/piper/`)
- A voice model file (`en_US-lessac-medium.onnx`) at a specific hardcoded path
- Either `paplay` (PulseAudio) or `aplay` (ALSA) — meaning either PipeWire-with-PulseAudio-compat or bare ALSA must be present
- `wezterm` CLI and `WEZTERM_PANE` environment variable set

This hook fails silently (exits 0 and logs to a tmp file), which is good, but the requirements are completely undocumented outside the hook script itself. A collaborator on a headless server or macOS will get no notification that TTS silently does nothing.

### 4. WezTerm as a Hard Assumption

Three hooks (`wezterm-notify.sh`, `wezterm-clear-status.sh`, `wezterm-task-number.sh`, `wezterm-clear-task-number.sh`) depend on WezTerm specifically — not just "a terminal emulator." They use `wezterm cli list --format=json`, OSC 1337 escape sequences, and `WEZTERM_PANE` env var. On any other terminal (iTerm2, Alacritty, Ghostty, tmux, Zed's built-in terminal) these hooks silently no-op but the intended UX (tab coloring, TTS with tab number) is entirely absent.

`settings.json` also references `~/.config/nvim/scripts/claude-ready-signal.sh` in a SessionStart hook — a cross-repo hardcoded absolute path. This will silently fail for anyone without the nvim config at exactly that path.

### 5. Locale and Encoding

The R workflow documents assume UTF-8 throughout (Quarto, gtsummary table output, Markdown manuscripts). R on non-UTF-8 locales (common in minimal Docker images) produces garbled output or errors in string operations. The audit will not surface this because no .claude/ file says "requires `en_US.UTF-8`."

### 6. Network Access at Runtime

The following operations require outbound network access that is never stated as a precondition:

- `typst compile` fetches packages from `packages.typst.app` on first use (cached in `~/.cache/typst/`)
- `renv::restore()` fetches from CRAN (or configured mirror)
- Stan/CmdStan downloads itself on first `brms`/`EpiNow2` use
- `uvx rmcp` (epidemiology extension MCP config) fetches from PyPI via uv
- `npx -y @anthropic-ai/obsidian-claude-code-mcp@latest` (memory extension) fetches from npm registry
- The Lean MCP (`setup-lean-msp.sh`) downloads the Lean toolchain components via `lake`

A CI image or air-gapped environment will fail at these steps with confusing errors, not dependency-installation errors.

### 7. Lean Toolchain

The `lean-lsp` MCP server is configured in `settings.json` (`mcp__lean-lsp__*` permissions). The `setup-lean-mcp.sh` script exists and references a Lean project path. But Lean requires:

- `elan` (Lean version manager)
- A working internet connection on first project build (downloads Lean + Mathlib toolchain)
- Potentially gigabytes of Mathlib cache (`~/.elan/`, `~/.cache/mathlib/`)

None of this is documented in .claude/.

### 8. Claude Code Harness Features as Hard Dependencies

Several features are not "external tools" but are Claude Code platform features that may not be available in all environments:

- `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` — required for `--team` flag; silently degrades but the CLAUDE.md says "gracefully degrades to single-agent if unavailable" without explaining what that means in practice
- MCP tool availability — the entire memory, filetypes (SuperDoc), epidemiology (rmcp), and lean-lsp stacks depend on MCP servers being configured and running; fallback behavior is inconsistently documented
- Subagent spawning (Task tool) — required for team mode and multi-task operations; may not be available in all Claude Code deployment contexts
- Hook system — the PostToolUse/PreToolUse/SubagentStop hooks are a Claude Code-specific feature; no documentation says what version of Claude Code is required for these hooks to work

### 9. uv / uvx as an Implicit Runtime

Both the rmcp (epidemiology) and markitdown-mcp/mcp-pandoc (filetypes) MCP configurations use `uvx` as the runner. This means `uv` must be installed, which is not a standard system package on NixOS, Ubuntu, or macOS without explicit installation. The `dependency-guide.md` has a troubleshooting entry for "uvx: command not found" but does not list `uv` as a required dependency in the install table.

### 10. npx / Node.js for MCP Servers

The memory extension's primary MCP option uses `npx -y @anthropic-ai/obsidian-claude-code-mcp@latest`. This requires Node.js (implicitly npm/npx). Node.js version compatibility with the MCP package is not stated.

---

## Documentation Pitfalls

### "List every dependency" is the wrong framing

A flat inventory list will have these problems:
- It does not tell the reader which dependencies are required vs. optional vs. fallback-graceful
- It does not tell the reader which dependencies belong to which use case
- It will be immediately stale for any dynamically-fetched component (npx with `@latest`, uvx packages)
- It cannot express the tree structure: e.g., "brms requires CmdStan which requires gcc which requires..."

A better framing: **capability matrix**. Rows = features/commands. Columns = what must be present. Each cell = required / optional / graceful-fallback / not applicable.

### The install profile question

The current documentation implies one global install. But there are at least four meaningfully different profiles:

| Profile | What it covers |
|---------|----------------|
| Core | Claude Code harness, git, jq, bash — needed for all task management |
| +epi | R >= 4.3, Stan toolchain, renv, system libs for compiled packages |
| +typst | typst >= 0.11, fonts, optionally uv for MCP |
| +filetypes | pandoc, markitdown/uv, python venv with openpyxl/pandas/pptx, optionally Node.js |
| +present | Node.js (Slidev), typst (for timeline template), optionally LaTeX |
| +memory | Obsidian desktop app (non-headless), npx/Node.js, specific plugin installed |
| +hooks | WezTerm, piper TTS, aplay/paplay, the nvim config at the expected path |

The +hooks profile is particularly personal — it is tightly coupled to the author's personal environment and should be documented as "personal UX layer, not required for functionality."

### Doc rot risk

Several dependencies are fetched with `@latest` (npx) or `uvx` (which resolves at invocation time). A static install doc cannot keep up with these. The risk: the doc says "install version X" but the system actually runs whatever `@latest` resolves to at invocation time. These should either be pinned or the doc should explicitly say "version is dynamically resolved."

### Automated detection vs. static docs

A `check-deps.sh` script that tests each capability and reports what is/isn't available would be more durable than a written doc. Partial precedent exists: `dependency-guide.md` already has a verification section. But it only covers the filetypes extension. A generalized health-check script would:
- Be runnable before attempting any task type
- Surface graceful-degradation paths (e.g., "rmcp unavailable, will use Rscript fallback")
- Serve as living documentation that cannot go stale

---

## Unstated Assumptions

1. **Platform**: The system is clearly authored for Linux (NixOS specifically). The `settings.json` cross-reference to `~/.config/nvim/` and the hook TTS using `aplay`/`paplay` are Linux-specific. The dependency guide does cover macOS as a secondary target, but the hooks layer does not degrade gracefully on macOS (no `paplay`, WezTerm behaves differently).

2. **Shell**: Hooks use `bash`. The `session_id` generation in git-workflow.md uses `od -An -N3 -tx1 /dev/urandom`. This assumes bash and standard Linux coreutils. macOS `od` has different flag syntax.

3. **Path assumptions**: `~/.config/nvim/scripts/claude-ready-signal.sh` is hardcoded in SessionStart hooks. Any collaborator without that file (or without the nvim config at `~/.config/nvim/`) will have a silently broken hook.

4. **Obsidian as a desktop application**: The memory extension requires Obsidian running as a GUI desktop application with a specific community plugin installed. This is incompatible with headless/server/CI environments. The setup guide acknowledges graceful degradation via grep fallback but does not prominently warn that the memory extension provides degraded functionality without a running desktop app.

5. **Extensions sourced from nvim config**: Every extension in `extensions.json` has `source_dir` pointing to `/home/benjamin/.config/nvim/.claude/extensions/`. This is a personal machine path. On any other machine this path does not exist and extensions cannot be installed or updated.

6. **R already installed**: The epi extension documents R packages extensively but does not say which R version is required or where R itself comes from. The r-workflow.md assumes `renv` and `targets` will work, but on NixOS installing CRAN packages into a user-owned library requires specific nix configuration.

---

## Questions That Should Be Asked

1. **For whom is the install documentation being written?** Fresh clone on a new machine? New collaborator joining the project? CI/CD pipeline configuration? These have substantially different requirements and the answer changes what the doc should contain.

2. **What is the minimum viable environment** for the core harness (task management, research, planning, implementation) to work without any extension? Can a collaborator run `/task`, `/research`, `/plan`, `/implement` on a bare Ubuntu system with only Claude Code installed?

3. **Which dependencies are personal vs. shared?** The WezTerm hooks, TTS system, nvim cross-reference, and piper voice model are personal UX features. Should the install doc separate "project dependencies" from "author's personal environment"?

4. **Is there a versioning policy?** Should the audit establish minimum versions (python >= 3.10, R >= 4.3, typst >= 0.11, pandoc >= 3.0)? Or is "latest stable" acceptable for all components?

5. **What breaks vs. what degrades gracefully?** For each missing dependency, is the failure a hard error (task cannot run at all) or a soft degradation (feature unavailable, fallback used)? This is more useful than a plain dependency list.

6. **Is the Lean extension actually active in this repository?** `setup-lean-mcp.sh` exists and `mcp__lean-lsp__*` is in the permissions allowlist and the Lean MCP is in the context, but `extensions.json` does not list a Lean extension. Is the Lean toolchain a live dependency or a dormant one? The audit should clarify.

7. **What happens on a headless server?** Hooks that require WezTerm, paplay, Obsidian, and `~/.config/nvim/` all fail silently. If someone tries to use this system in a server context (remote dev, CI), which capabilities survive?

8. **Should `uvx` and `npx` invocations be pinned?** `uvx rmcp`, `npx -y @anthropic-ai/obsidian-claude-code-mcp@latest`, and `npx -y @superdoc-dev/mcp` fetch from the network at runtime without version pins. This is a reproducibility risk and a potential breakage vector if packages publish breaking changes.

9. **How does one verify the environment is ready before running a task?** Is there (or should there be) a pre-flight check command that tests whether the required tools for a given task type are available before dispatching to an agent?

---

## Recommendations to Sharpen Scope

1. **Scope to "capabilities not tools."** The deliverable should not be a tool list. It should be a capability-by-capability matrix stating: what the capability is, what must be present, what degrades gracefully, and what fails hard.

2. **Separate the personal environment layer explicitly.** WezTerm, piper TTS, `~/.config/nvim/`, and the audio subsystem are author-personal. They should be documented in a separate "personal UX layer" section, clearly marked as not required for project functionality and not applicable to other users.

3. **Add a `check-deps.sh` script as a primary deliverable**, not documentation as a primary deliverable. The script is the living truth; the written doc is a human-readable summary of what the script checks.

4. **Establish install profiles.** The docs update should define (at minimum) a core profile and named extension profiles, so a user can say "I need the epi profile" and get a bounded list of requirements rather than scanning the entire document.

5. **Flag the network-access-at-runtime dependencies explicitly.** These are easy to miss in a grep-based audit and are the most likely to cause confusing failures in restricted environments.

6. **Do not over-specify.** The audit should stop at first-order dependencies (what the .claude/ system directly invokes). The C++ toolchain required by Stan is a second-order dependency; it matters, but documenting the full transitive closure is scope creep that will never be maintained.

7. **Treat the Lean MCP situation as a specific question to resolve**, not something to enumerate. Is it active or dormant? If active, what does it require? If dormant, should the permissions entry be removed?

---

## Confidence Level

High for the hidden dependency surfaces identified (hooks, fonts, system libs, network-at-runtime, uv/npx). These are grounded in direct reading of hook scripts, settings.json, extension configs, and MCP guides.

Medium for the framing critiques (capability matrix vs. tool list, install profiles). These are architectural recommendations based on the observed complexity of the system.

Low for claims about specific version requirements (e.g., "python >= 3.10") — these were not verified against actual code constraints and should be confirmed by Teammate A's inventory before being included in any deliverable.
