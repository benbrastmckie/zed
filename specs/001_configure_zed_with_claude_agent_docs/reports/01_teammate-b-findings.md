# Teammate B Findings: Alternative Patterns and Prior Art

**Date**: 2026-04-09
**Focus**: Documentation patterns, alternative approaches, existing system reuse

---

## Key Findings

### 1. Documentation Scale: This Config Is Fundamentally Simpler Than nvim

The nvim config has ~20 docs files because it manages hundreds of Lua modules, dozens of plugins, complex LSP configuration, and treesitter. The Zed config has 2 JSON files (settings.json and keymap.json). The config-report.md itself says: "Zed is intentionally simpler to configure than Neovim. Most functionality works out of the box."

**Implication**: A full docs/ folder replicating the nvim structure would be over-engineered for Zed. The correct scale is:
- README.md (primary user-facing doc, single file)
- docs/ folder with 2-3 focused files (not 15+)

### 2. Nvim README Pattern: Navigation Hub with Curated Sections

The nvim/README.md establishes a proven pattern for this user:
- Feature-oriented section headers (not file-oriented)
- Quick-access tables (dashboard keys, feature overview)
- Cross-links to docs/ for depth
- Installation/setup section up front
- "Documentation Structure" section that maps the docs/ folder

This pattern works for a beginner because it answers "what can this do?" before "how do I use it?".

### 3. Nvim Documentation Standards: Present-State Focus

From nvim/docs/DOCUMENTATION_STANDARDS.md, the explicit standard is:
- Present tense, active voice
- No historical markers ("new", "previously", "now supports")
- Clean-break philosophy: document what exists, not how it got there
- Timeless writing

This applies directly here: the Zed docs should not explain "missing settings.json" or "what was installed" - only the current configured state.

### 4. .claude/README.md: Navigation Hub Pattern

The .claude/README.md uses a "navigation hub" structure:
- Version + date header
- Quick Reference table (commands at a glance)
- Architecture diagram (ASCII art)
- Section per major component with links to detail pages
- Explicit "Related Files" table at the end

This pattern is effective because agents and users get orientation quickly without reading everything. The Zed README.md should adopt this pattern at a smaller scale.

### 5. .memory/README.md: Concise Reference Pattern

The .memory/README.md is the right reference for a small system:
- Purpose statement in first paragraph
- Directory structure tree
- Usage examples with commands
- Naming conventions table
- Best practices bullet list

Total: ~100 lines. This is the right scale for documenting a support system (like .memory/ or .claude/ from Zed's perspective). The Zed README.md and agent system integration doc should be similarly concise.

### 6. Single README vs docs/ Folder: When Each Is Appropriate

**Single README.md only** (appropriate when):
- Config is 1-3 files
- All essential info fits in ~150 lines
- Audience is one person (personal config)
- Nothing requires step-by-step installation guides

**README.md + docs/ folder** (appropriate when):
- Multiple distinct topic areas (setup, keybindings, AI, agent system)
- Reference material would make README unwieldy (>300 lines)
- Different audiences (beginner vs advanced)
- Cross-linking between topics adds value

**Verdict for Zed**: README.md + docs/ with 2-3 files is the right choice. The agent system integration alone warrants a dedicated doc because it's a non-obvious advanced feature.

### 7. Recommended docs/ Structure for Zed (Minimal)

Based on actual content needs (not nvim-level complexity):
```
zed/
├── README.md              # Overview, quick start, navigation hub
└── docs/
    ├── settings.md        # settings.json reference with all configured options
    ├── keybindings.md     # keymap.json reference, key Zed shortcuts
    └── agent-system.md    # How .claude/ and .memory/ integrate with Zed
```

Three docs files cover distinct topic areas without over-engineering. A fourth file (e.g., office-workflows.md) could document the SuperDoc/openpyxl workflows but may be redundant given the existing zed-claude-office-guide.md.

### 8. tasks.json: Useful for Common Operations

Zed's tasks.json supports custom commands runnable from the editor. For this config, relevant tasks could include:
- `claude` - Open Claude Code in terminal
- `zeditor` - Reopen Zed (for config reloading workflows)
- Common build/run tasks per language

Tasks live in `~/.config/zed/tasks.json` (global) or `.zed/tasks.json` (project-level). This is worth documenting but not creating by default unless the user has specific workflows.

### 9. Config Management: User-Level is Correct for Personal Config

The config-report.md correctly identifies the choice between:
- Home Manager symlinks (like nvim/ is managed)
- Direct git tracking of ~/.config/zed/

For the agent system (.claude/) and memory (.memory/), direct git tracking makes more sense than symlinks because these directories are actively modified by agents during task execution. Symlinking them would require the symlink target to also be a git repo, creating complexity.

**Recommendation**: Document the git-tracking approach in README.md; note Home Manager as an option for the static JSON files only.

### 10. Agent System Integration Doc: Key Content

The .claude/ agent system documentation already exists at `/home/benjamin/.config/zed/.claude/README.md` and `.claude/CLAUDE.md`. The Zed-level agent-system.md doc should NOT duplicate this. Instead it should:
- Explain that Zed is the editor host for running Claude Code
- Explain that .claude/ manages tasks/agents (link to .claude/README.md)
- Explain that .memory/ is a shared knowledge vault (link to .memory/README.md)
- Show the keyboard shortcut to open the Agent Panel in Zed
- Note the NixOS-specific binary name (zeditor not zed)

### 11. Cross-Linking Strategy

Given the small doc set, cross-links should be relative and structured:
- README.md links to each docs/ file
- Each docs/ file links back to README.md
- agent-system.md links to .claude/README.md and .memory/README.md
- All docs reference official Zed docs (zed.dev/docs) for Zed-specific details

This avoids duplicating upstream docs while maintaining local orientation.

### 12. Zed Agent Panel: Key Facts for Documentation

From official Zed docs:
- Open via Command Palette: "agent: new thread" or ✨ status bar icon
- Keyboard shortcut: `ctrl-shift-j` (Linux, not cmd) for recent threads
- Supports `@` mentions for files/dirs/symbols
- Supports "Write", "Ask", "Minimal" profiles
- Has checkpoint/restore for code changes
- Token tracking built in

The Claude Code extension adds additional capabilities on top of the built-in Agent Panel. The distinction (built-in Agent Panel vs Claude Code extension) is worth clarifying for a beginner.

---

## Recommended Approach

### Documentation Structure

Create a minimal, well-organized 4-file doc set:

```
zed/
├── README.md                  # Navigation hub (150-200 lines)
└── docs/
    ├── settings.md            # Configuration reference (settings.json + keymap.json)
    ├── keybindings.md         # Key shortcuts for Zed features
    └── agent-system.md        # .claude/ and .memory/ integration (points to existing docs)
```

**README.md** should follow the nvim README pattern:
1. One-line description + platform note (NixOS, binary=zeditor)
2. Quick start (open Zed, open Agent Panel)
3. Features overview table (brief)
4. Configuration Files section (what's in settings.json/keymap.json)
5. AI + Agent System section (link to docs/agent-system.md)
6. Documentation Structure section

**docs/settings.md** should document all configured options with their purpose - not just list keys but explain why each is set. This is the "settings reference" for future-self.

**docs/keybindings.md** should cover:
- Custom bindings in keymap.json
- Essential built-in Zed shortcuts (not the full list, just the ones used daily)
- Agent Panel shortcuts specifically

**docs/agent-system.md** should be a thin bridge document that:
- Explains the relationship between Zed and the .claude/ system
- Pointers to .claude/README.md and .memory/README.md for depth
- Shows how to run Claude Code within Zed

### Writing Style

Follow the nvim documentation standards:
- Present tense, active voice
- No temporal language or historical notes
- Assume the config is fully set up (not documenting "before" state)
- Beginner-friendly: define terms on first use, but don't over-explain

### What NOT to Create

- A tasks.json (nothing urgent to automate yet; document the option in README.md)
- A CLAUDE.md for Zed-specific coding standards (already handled by .claude/CLAUDE.md)
- Duplicate content from .claude/README.md or .memory/README.md
- A docs/installation.md (the config-report.md covers this; one-time setup is done)

---

## Evidence/Examples

### From nvim README.md (lines 1-14)
The pattern: brief intro paragraph + installation section + file structure + features overview. The structure is feature-driven, not file-driven. Works for a beginner because they can find what they need from the top-level categories.

### From .claude/README.md (version header approach)
The navigation hub pattern with Quick Reference table first works because it serves both human skimming and agent context loading efficiently.

### From .memory/README.md (concise reference)
~100 lines is enough for a complete reference doc for a focused system. The Zed docs should aim for similar density.

### From nvim/docs/DOCUMENTATION_STANDARDS.md
Core principle: "Documentation must describe the current implementation only." This means the Zed docs should start from the final configured state, not document the setup process.

### From config-report.md (comparison table)
The Neovim vs Zed comparison table (lines 156-165) demonstrates the key insight: Zed is simpler by design. The docs should reflect this - 3 focused files beats 15 comprehensive files.

### From Zed official docs (tasks.json)
Tasks use variables like `$ZED_FILE`, `$ZED_WORKTREE_ROOT` - useful for future workflow automation but not needed for initial setup documentation.

### From Zed Agent Panel docs
The Agent Panel supports profiles ("Write", "Ask", "Minimal") and checkpoint/restore - these are non-obvious features a beginner should know about. Worth a section in agent-system.md.

---

## Confidence Level

**High** for:
- Recommended doc structure (3 files + README) - well-supported by existing nvim patterns
- Writing style guidelines - directly from nvim DOCUMENTATION_STANDARDS.md
- Cross-linking strategy - consistent with .claude/README.md patterns
- Scale judgment (not duplicating nvim doc complexity) - clear from config-report.md comparison

**Medium** for:
- Specific content of each doc file (depends on what Teammate A finds for settings.json values)
- tasks.json recommendation (depends on user's actual workflows)
- Whether to include the office-workflows content or reference existing guide

**Low** for:
- Specific Zed Agent Panel shortcuts on Linux (official docs use cmd/macOS notation; Linux ctrl equivalents need verification)
