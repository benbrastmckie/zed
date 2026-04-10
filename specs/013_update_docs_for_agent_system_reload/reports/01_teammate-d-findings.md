# Teammate D Findings: Long-Term Alignment and Strategic Direction

**Task 13**: Update docs/ documentation to reflect reloaded .claude/ agent system changes
**Focus**: Strategic documentation alignment and long-term maintainability

---

## Key Findings

### 1. The docs/ directory is architecturally sound and well-structured

The `docs/` layout — `general/`, `agent-system/`, `workflows/` — cleanly separates concerns and mirrors real user mental models (how it works, what commands exist, how to use them). The `.claude/docs/` pattern (guides, examples, templates, architecture, reference) is a developer-facing system documentation layer, while `docs/` is a user-facing Zed-specific guide. These serve different audiences and should **not** be merged. The current two-layer structure is the right design.

### 2. The c190e44 "finished zed config" commit updated docs/ correctly for structural changes

Three docs files were modified in c190e44:
- `docs/agent-system/architecture.md` — improved ASCII diagram (box-drawing vs. arrow chain)
- `docs/agent-system/zed-agent-panel.md` — major rewrite to reflect terminal task as primary path (SDK isolation constraints documented)
- `docs/general/keybindings.md` — updated to match keymap.json changes

These are already merged into HEAD. The `docs/` directory at HEAD reflects the current system state for these three files.

### 3. Several content gaps remain between the agent system changes and docs/

The c190e44 commit made sweeping changes to `.claude/` (60 files, ~6600 insertions, ~7100 deletions) but only touched 3 docs files. The following doc files may need content review based on what changed:

**High-priority gaps identified**:

a) **`/talk` -> `/slides` rename**: The `.claude/` layer removed `commands/talk.md` and consolidated its functionality into `commands/slides.md` (which was rewritten from ~40 lines to ~660 lines). In `docs/`, `docs/workflows/grant-development.md` still uses the correct `/slides` command name and the `docs/agent-system/commands.md` correctly reflects `/slides`. However, `docs/agent-system/README.md` still describes a "two AI systems" framing with a reference to `Cmd+Shift+?` keybinding (old), while the panel page now documents `Ctrl+?` and `Ctrl+Shift+A`. The README navigation links to the right files but its in-body keybinding references are stale.

b) **Agent frontmatter standard changed**: Agents now use minimal frontmatter (`model: opus` only, no `mode`, `temperature`, `tools` fields). `docs/agent-system/architecture.md` correctly says "agents execute, create artifacts, return metadata" without detailing frontmatter, so this is already OK. But `docs/agent-system/commands.md` references `.claude/agents/*.md` paths, which is still accurate.

c) **`check-extension-docs.sh` utility script**: The `.claude/CLAUDE.md` now documents a new utility script. `docs/agent-system/commands.md` does not cover utility scripts, but `docs/agent-system/architecture.md` lists `.claude/scripts/` in the config tree. This is a minor gap — the utility scripts don't warrant a new doc section but could be mentioned as a footnote.

d) **`/convert` PPTX-to-slides expansion**: `commands/convert.md` was massively expanded to include PPTX -> Beamer/Polylux/Touying conversion (previously handled by `/slides deck.pptx` syntax). `docs/workflows/convert-documents.md` describes this workflow; it should be checked to ensure it matches the new `/convert --format beamer` API.

e) **`plan-format-enforcement.md` rule added**: A new auto-applied rule was added to `.claude/`. This is internal agent behavior — no user-facing doc change needed.

f) **`ROAD_MAP.md` -> `ROADMAP.md` typo fix**: Multiple `.claude/` files corrected this. `docs/` never referenced `ROAD_MAP.md` by name, so no docs update needed.

g) **`docs/agent-system/README.md` keybinding staleness**: The README "Quick start: your first task" section still says "Cmd+Shift+?" to open the Agent Panel. The actual keybinding (documented in `zed-agent-panel.md` and `keybindings.md`) is now `Ctrl+?` for panel and `Ctrl+Shift+A` for terminal task. This is the most user-visible discrepancy.

### 4. The grant-development.md workflow guide still says "requires `<leader>ac`"

`docs/workflows/grant-development.md` line 5 says:

```
> **Requires the `present` extension.** Load it via `<leader>ac` before using these commands.
```

`<leader>ac` is a Neovim keybinding. `docs/agent-system/architecture.md` explicitly notes this does not apply in the Zed workspace — all extensions are pre-merged. This note is incorrect for this workspace and should be removed or replaced with a Zed-specific note.

### 5. docs/ has no equivalent to .claude/docs/ developer guides — and does not need one

`.claude/docs/` contains guides for creating commands, skills, agents, and extensions. This is developer documentation for modifying the agent system itself. `docs/` correctly does not replicate this — it points users to `.claude/docs/` via cross-links where appropriate. The maintenance-and-meta.md workflow correctly describes `/meta` as the entry point for agent system changes and links to the relevant guides. This architecture should be maintained.

### 6. No ROADMAP.md exists — an opportunity for task 13

`specs/ROADMAP.md` does not exist. The `skill-todo` SKILL.md now creates it on first `/todo` run with a default template. Since this doc update task will complete and be archived via `/todo`, that run will auto-create ROADMAP.md. No action needed here, but it is worth noting for the implementation plan.

---

## Recommended Approach

### Immediate fixes (all in docs/)

1. **`docs/agent-system/README.md`**: Update "Cmd+Shift+?" to `Ctrl+?` (panel) / `Ctrl+Shift+A` (terminal task) in the quick start and body text. The README currently cross-links to `zed-agent-panel.md` which is up to date, but the README body itself has stale references.

2. **`docs/workflows/grant-development.md`**: Remove or replace the `<leader>ac` note. Replace with: "All extensions are pre-loaded in this Zed workspace — no additional loading step is required."

3. **`docs/workflows/convert-documents.md`**: Review against the new `/convert --format beamer|polylux|touying` API. The workflow guide may need to document the PPTX-to-slides capability that moved from `/slides` to `/convert`.

### Consider for long-term maintainability

4. **Add a "Zed adaptations" note to docs/workflows/grant-development.md** (and possibly `memory-and-learning.md`) that mirrors the note in `docs/agent-system/README.md#zed-adaptations`. Any workflow doc that mentions extension loading, Neovim keybindings, or `<leader>ac` needs this treatment.

5. **Treat docs/agent-system/README.md as the canonical Zed-specific adaptation document**. It already has a "Zed adaptations" section. Other docs should defer to it rather than re-stating adaptations.

6. **Consider a short "Zed vs Neovim adaptations" callout** at the top of any workflow doc that was originally written for the neovim config. Right now `grant-development.md` and `memory-and-learning.md` have extension-loading notes that are Neovim-specific. A standardized callout block would make these easy to scan and maintain.

---

## Evidence/Examples

### Structural comparison: docs/ vs .claude/docs/

```
docs/                          .claude/docs/
├── README.md                  ├── README.md
├── agent-system/              ├── architecture/
│   ├── README.md              │   ├── system-overview.md
│   ├── architecture.md        │   └── extension-system.md
│   ├── commands.md            ├── guides/
│   ├── context-and-memory.md  │   ├── user-guide.md
│   └── zed-agent-panel.md     │   ├── creating-commands.md
├── general/                   │   ├── creating-skills.md
│   ├── installation.md        │   ├── creating-agents.md
│   ├── keybindings.md         │   └── ...
│   └── settings.md            ├── examples/
└── workflows/                 ├── templates/
    ├── agent-lifecycle.md     └── reference/
    ├── grant-development.md       └── standards/
    ├── ...
```

`docs/` = user guide for this Zed configuration
`.claude/docs/` = developer reference for the agent system internals

These serve distinct purposes and the two-layer approach is correct.

### Stale keybinding in docs/agent-system/README.md (line 2)

Current: "Cmd+Shift+?" to open the panel
Correct: "Ctrl+?" for panel, "Ctrl+Shift+A" for terminal task (full CLI)

This is consistent with `zed-agent-panel.md` and `keybindings.md` which were updated in c190e44, but the README itself was not updated.

### Neovim-specific note in grant-development.md (line 5)

Current:
```markdown
> **Requires the `present` extension.** Load it via `<leader>ac` before using these commands.
```

Should be:
```markdown
> All extensions are pre-loaded in this Zed workspace — no extension loading step is required.
```

### /convert PPTX support moved from /slides to /convert

Before c190e44, `.claude/CLAUDE.md` listed:
```
| `/slides` | `/slides deck.pptx` | Convert presentations to Beamer/Polylux/Touying |
```

After c190e44, this became:
```
| `/convert` | `/convert file.pdf` | Convert between document formats; `/convert deck.pptx --format beamer` for slide output |
```

`docs/workflows/convert-documents.md` likely already covers this (based on the workflows README table of contents listing "Convert a PowerPoint deck into Beamer/Polylux/Touying -> convert-documents.md"), but the file should be verified against the new API surface.

---

## Confidence Level

**High** — for the structural analysis (docs/ architecture is correct, two-layer separation is right, no restructuring needed).

**High** — for the specific stale references identified (keybindings in README, `<leader>ac` note in grant-development.md).

**Medium** — for the `/convert` PPTX workflow gap (depends on whether `convert-documents.md` was already updated in c190e44 to match the new API — the git diff showed `docs/general/keybindings.md` was updated but `docs/workflows/convert-documents.md` was not listed among changed files in c190e44, making it likely stale).

**Low** — for any other undiscovered gaps (the diff was large; some minor stale references in body text of workflow files may exist that were not surfaced by this analysis).
