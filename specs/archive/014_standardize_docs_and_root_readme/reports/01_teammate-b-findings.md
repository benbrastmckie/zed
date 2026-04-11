# Teammate B Findings: Best Practices for Docs Structure and Root README

## Key Findings

### 1. Critical Platform Mismatch

The most significant issue in the current documentation is a systematic platform mismatch. Every file in `docs/` describes a **macOS** configuration, but the actual running system is **NixOS Linux**. Evidence:

- `settings.json` line 3: `// Platform: NixOS Linux (binary: zeditor)`
- `settings.json` lines 148-157: `claude-acp` configured as `"type": "custom"` pointing to `/home/benjamin/.nix-profile/bin/npx` with `HOME: /home/benjamin`
- `tasks.json`: Uses `libreoffice` (not Word/Excel), confirming Linux
- `keymap.json`: Uses `ctrl-?` to toggle the right dock (not `Cmd+Shift+?` as the README states)
- OS verification: `uname -a` returns `Linux hamsa 6.19.10 #1-NixOS`

The README.md states "Platform: macOS 11 (Big Sur) or newer" and all shortcuts use `Cmd`. The real shortcuts use `Ctrl`. This is the highest-priority fix.

**Root cause**: The documentation appears to have been written for a macOS setup and not updated when the config was ported to NixOS. The `docs/general/settings.md` file actually contains the correct NixOS guidance (lines 94, 107), but the framing everywhere else is still macOS-first.

### 2. Unique Value Proposition of This Repository

This is not a generic Zed config. It is a **research workstation configuration** with three interlocking layers:

1. **Zed editor settings** optimized for research workflows: R language support, Fira Code font, markdownlint, codebook extension, NixOS-specific agent server config
2. **Claude Code agent system** (`.claude/`) with full research task lifecycle: `/task` -> `/research` -> `/plan` -> `/implement` with structured artifact output
3. **Domain extensions** specifically for medical/epi research: epidemiology (`/epi`), grant development (`/grant`, `/budget`, `/timeline`, `/funds`, `/slides`), document conversion (`/convert`, `/edit`, `/table`, `/scrape`), memory vault (`/learn`)

The repo also provides a **shared memory vault** (`.memory/`) that is Obsidian-compatible and shared between Claude Code and OpenCode AI systems, making it unusually well-suited for long-term research work.

**The repo's identity**: A reproducible NixOS Zed workstation for epidemiology and medical research, with AI-assisted study design, grant writing, and document workflows built in.

### 3. Structural Strengths Worth Preserving

The docs structure is actually well-designed:

- `docs/general/` -- editor setup concerns (install, keys, settings)
- `docs/agent-system/` -- AI system concerns (panel, commands, architecture, memory)
- `docs/workflows/` -- task-oriented narratives grouped by domain (epi, grant, office, agent lifecycle)

This three-layer separation (setup / system / workflows) maps cleanly to different reader intents and should not be changed.

The README files in each subdirectory are consistent in their current pattern: a brief description paragraph, a navigation table or list, and a "See also" section with cross-links. This is a good pattern.

### 4. Cross-Link Inconsistencies

The `docs/agent-system/README.md` references `agent-lifecycle.md` as `../workflows/agent-lifecycle.md` (correct path), but lists it under "Files in this directory" -- this is misleading. The file lives in `docs/workflows/`, not `docs/agent-system/`.

The root `README.md` references `Cmd+Shift+?` to toggle the AI agent panel, but `keymap.json` binds `ctrl-?` to `workspace::ToggleRightDock`. This is a broken shortcut reference.

### 5. Missing Links in Root README

The root README does not link to:
- `.memory/README.md` (the memory vault)
- `.claude/README.md` (the agent system architecture hub)
- The epidemiology and grant workflow docs directly (they are buried three levels deep)

---

## Recommended Approach

### Root README.md -- Proposed Structure

The root README should lead with the actual platform and actual purpose. Proposed structure:

```
# Zed Configuration

[1-sentence identity: NixOS Zed workstation for epidemiology and medical research]
[2-sentence value prop: what makes this different from a standard Zed config]

Platform: NixOS Linux (binary: `zeditor`)

## Quick Start
[Install steps for NixOS -- nix/nixpkgs path, not Homebrew]
[3-5 essential shortcuts using Ctrl, not Cmd]

## What This Config Provides
[Short grouped list: editor, AI agent system, domain extensions]
-- Editor: theme, font, R support, markdownlint
-- Agent system: /task /research /plan /implement lifecycle
-- Domain extensions: epidemiology, grants, document conversion, memory

## Documentation
[Table: General | Agent System | Workflows | Agent System Config]

## Directory Layout
[Accurate tree]

## Custom Keybindings
[Actual bindings from keymap.json]

## AI Integration
[Both Zed Agent Panel and Claude Code, accurate shortcuts]

## Platform Notes
[NixOS-specific: binary name zeditor, nix-profile paths, LibreOffice not Word]

## Related
[.claude/README.md, .memory/README.md, specs/TODO.md]
```

Key changes from current README:
- Remove "macOS 11 (Big Sur)" platform declaration; replace with NixOS Linux
- Fix all `Cmd+` shortcut references to `Ctrl+` (or remove them; shortcut list in General docs)
- Add `.memory/README.md` link
- Add `.claude/README.md` link
- Add brief mention of epidemiology and grant development capabilities (currently invisible)
- Fix installation quick start to reflect NixOS reality
- Remove Homebrew references from quick start

### docs/ README Files -- Consistent Template

Each `docs/{section}/README.md` should follow this template:

```markdown
# {Section Name}

{One paragraph: what this section covers, who should read it, where it fits in the overall docs.}

## Navigation

Files in this directory (`docs/{section}/`):

- **[filename.md](filename.md)** -- {One sentence: what the file covers, what problem it solves}
[... more files ...]

## {Optional: Quick Start or Decision Guide}
[If the section has a natural entry-point ordering or a decision tree, include it here]

## See also

- [{Path}]({relative-path}) -- {One line description}
[Cross-links to sibling README files and root README]
```

**Consistency rules**:
- Use `--` (double dash) as separator in navigation lists (currently mixed: some use `--`, some use `—`)
- Bold the filename in navigation lists: `**[filename.md](filename.md)**`
- "See also" section always present, always last
- Section title is plain (no "Documentation" or "Docs" suffix -- just the domain name)

### docs/README.md -- Index File

The top-level `docs/README.md` is currently very thin (9 lines). It should serve as a cross-section index with:
- Brief description of each section (1 sentence each)
- Quick navigation table
- Link back to root README
- Note about the platform (NixOS)

---

## Evidence / Examples

### Evidence that platform fix is the top priority

`settings.json` is authoritative -- it is the actual config file Zed reads. It unambiguously says NixOS:

```json
// Platform: NixOS Linux (binary: zeditor)
...
"command": "/home/benjamin/.nix-profile/bin/npx",
```

`tasks.json` uses `libreoffice`, not `open` or a macOS path. The `tips-and-troubleshooting.md` workflow file is entirely about macOS Word/OneDrive automation, which does not apply to this system.

### Evidence that the repo is research-focused

Active extensions: epidemiology (v2.0.0), present/grants (v1.0.0), filetypes, memory, typst, latex. The `R` language is configured in `settings.json` with tab_size. The `.memory/` vault is set up for cross-session knowledge retention. These are not general development tools -- they are research workflow tools.

### Evidence of the unique three-layer value

No standard Zed config repository has:
1. A structured `/task` -> `/research` -> `/plan` -> `/implement` lifecycle with committed artifacts
2. `/epi` forcing-questions command for epidemiology study design
3. A shared Obsidian-compatible memory vault persisting across AI sessions

This combination is the repo's identity and the README should state it in the first paragraph.

---

## Confidence Level

- **Platform mismatch (NixOS vs macOS)**: High confidence. Settings.json, tasks.json, keymap.json, and OS verification all agree. The docs are wrong.
- **Repo identity as research workstation**: High confidence. Extensions, R config, memory vault, and active extension set all confirm research use case.
- **Recommended README structure**: High confidence. The proposed structure follows standard README best practices (identity first, quick start second, navigation table, platform notes).
- **docs/ template format**: Medium-high confidence. The current READMEs are close to the proposed template; the main changes are consistency of separator style and ensuring all files have "See also" sections.
- **Cross-link gaps**: High confidence. The root README visibly omits `.memory/README.md` and `.claude/README.md`.
