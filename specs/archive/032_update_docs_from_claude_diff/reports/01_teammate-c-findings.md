# Teammate C (Critic) — Critical Findings Report
## Task 32: Update Documentation from .claude/ Config Changes

---

## Key Findings

### Finding 1: BROKEN — Task 29 Has Orphaned Task Type `present:talk`

**Severity: High / Blocking for Task 29**

Task 29 (`talk_epi_study_walkthrough`) is an active task in `specs/state.json` with `"task_type": "present:talk"`. This task type no longer exists in any routing table. The rename from `talk-agent`/`skill-talk` to `slides-agent`/`skill-slides` introduced a new task type `slides` (under language `present`), but the old compound key `present:talk` was not migrated.

Evidence:
- `specs/state.json`: Task 29 has `"task_type": "present:talk"`, status `"partial"`
- `context/routing.md`: No row for `present` or `present:talk`; only `epi, epi:study`
- `CLAUDE.md` Present Extension routing table: uses `present` + `slides` sub-type (not `present:talk`)
- `skills/skill-slides/SKILL.md`: Trigger says `task_type: "slides"` — will NOT match `present:talk`
- `commands/slides.md` line 154, 264, 308: Validates `language="present"` and `task_type="slides"`

**Impact**: Running `/implement 29` or `/slides 29` will fail with a routing mismatch. Task 29 is currently `[PARTIAL]` and cannot be completed without migrating its task type to `slides` (with `language: present`).

---

### Finding 2: `context/routing.md` Still Lists Deleted Python Extension

**Severity: Medium**

`context/routing.md` line 12 still has:
```
| python | skill-python-research | skill-python-implementation |
```
The skills `skill-python-research` and `skill-python-implementation` have been deleted (confirmed in git status). Any agent consulting `routing.md` to determine how to route a `python` task type will get stale routing that points to non-existent skills.

---

### Finding 3: `CLAUDE.md` "Extension Task Types" List Still Includes `python`

**Severity: Medium**

`CLAUDE.md` line 75:
> Extensions provide additional task type support (neovim, lean4, latex, typst, **python**, nix, web, z3, epi, formal, founder, present, etc.)

Python was removed as an extension (agents, skills, context all deleted), yet it is still advertised as a supported extension task type in the primary agent reference file. This could cause agents or users to attempt Python task creation that would then fail.

---

### Finding 4: Root-Level `docs/` Directory Has Multiple Python Extension References

**Severity: Medium — These docs are OUTSIDE `.claude/`**

The repository has a `docs/` directory at the repo root (`/home/benjamin/.config/zed/docs/`) that is separate from `.claude/docs/`. These files were not part of the diff summary but contain stale python references:

1. **`docs/toolchain/extensions.md`** (lines 121, 132, 73-90): Lists the python extension as active and pre-merged. States "Every extension entry in `.claude/CLAUDE.md` (epidemiology, filetypes, latex, memory, present, **python**, typst) is pre-merged..." and has a full `## python` section describing installation requirements.

2. **`docs/agent-system/architecture.md`** (line 121, 132): Same claim about python being pre-merged, plus routing table entry `| python | skill-python-research | skill-python-implementation |`.

These are user-facing docs that will mislead users about what is available.

---

### Finding 5: `project-overview.md` Describes Neovim — This IS a Zed Config Directory

**Severity: High / Potential Fundamental Error**

The working directory is `/home/benjamin/.config/zed/`. The `context/repo/project-overview.md` was completely rewritten to describe a Neovim configuration project:
- References `nvim/`, `init.lua`, `lazy.nvim`, `nvim-lspconfig`, `mason.nvim`, `nvim-treesitter`
- Lists `Neovim 0.9+` as the version
- The project structure tree shows `nvim/` as root

The actual contents of `/home/benjamin/.config/zed/` are: `docs/`, `examples/`, `keymap.json`, `README.md`, `scripts/`, `settings.json`, `specs/`, `tasks.json`, `themes/`

There is no `nvim/` directory here. This is a Zed editor configuration, not a Neovim configuration.

**Possible explanation**: The `.claude/` agent system is shared/syndicated from `~/.config/nvim/.claude/` (confirmed by `extensions.json` `source_dir` fields pointing to `/home/benjamin/.config/nvim/.claude/extensions/`). The project-overview.md may have been overwritten with the nvim project's version by mistake during a sync operation.

**Consequence**: Every agent that loads `project-overview.md` will believe it is working in a Neovim Lua codebase when it is actually in a Zed editor configuration project.

---

### Finding 6: Memory File `project_python_extension_loaded.md` is Now Stale

**Severity: Low**

The auto-memory file at `~/.claude/projects/-home-benjamin--config-zed/memory/project_python_extension_loaded.md` states:
> "Python extension loaded via `<leader>ac` in Neovim on 2026-04-10. Adds skill-python-research, skill-python-implementation, two agents, and domain context files... Documentation in docs/ should reflect Python as a supported language."

This memory persists across sessions and will mislead future agents into thinking Python support is active and that docs should reference Python. This is the opposite of what the current change intends.

---

### Finding 7: `<leader>ac` is a Neovim Keybinding Referenced in a Zed Config

**Severity: Medium**

`CLAUDE.md` lines 73, 293 reference extensions being loaded via `<leader>ac`. This is a Neovim leader key binding. In a Zed config project, this keybinding is meaningless (Zed doesn't use vim leader keys by default, and the project memory confirms "No vim mode in Zed").

This suggests the CLAUDE.md content for this Zed project was copied verbatim from the nvim project configuration without adapting extension-loading instructions for the Zed context.

---

### Finding 8: `creating-skills.md` and `system-overview.md` Use Python as Primary Examples

**Severity: Low (Documentation Quality)**

These `.claude/docs/` files use python skill/agent creation as their primary worked example:
- `docs/guides/creating-skills.md` lines 105, 167-424: Full python skill/agent example
- `docs/architecture/system-overview.md` lines 254-255: Python skill/agent creation example
- `context/architecture/component-checklist.md` lines 191-192: Python example

While these are tutorial documents (not operational routing), using a deleted extension as the primary example is confusing and should be replaced with an active extension example (e.g., typst or latex).

---

### Finding 9: `creating-extensions.md` Lists Python as Example Simple Extension

**Severity: Low**

`docs/guides/creating-extensions.md` line 139 groups `python` alongside `latex`, `typst`, `z3` as examples of "simple extensions." Since python is deleted, this example set should be updated.

---

## Recommended Approach

**Highest priority fixes** (functional breakage):

1. **Fix Task 29 task_type** in `specs/state.json` and `specs/TODO.md`: Migrate `"task_type": "present:talk"` to `"task_type": "slides"` (with `"language": "present"`). This is a data migration, not just doc update.

2. **Fix `project-overview.md`**: Rewrite to accurately describe the Zed editor configuration project structure. The current content is Neovim-specific and completely wrong for this repo.

3. **Remove python from `context/routing.md`**: Delete the python row or replace with a note that python extension is not currently installed.

**Medium priority** (misleading docs):

4. **Update `docs/toolchain/extensions.md`** (root docs): Remove the `## python` section and update the "Every extension entry" list.

5. **Update `docs/agent-system/architecture.md`** (root docs): Remove python from the extension list and routing table.

6. **Update `CLAUDE.md` extension task types list**: Remove `python` from the enumeration at line 75.

7. **Update the stale memory file**: The `project_python_extension_loaded.md` memory file should be deleted or its content corrected to note the extension was subsequently removed.

**Low priority** (example hygiene):

8. Update `creating-skills.md`, `system-overview.md`, `component-checklist.md`, and `creating-extensions.md` to replace python examples with an active extension (typst or latex recommended).

9. Clarify `<leader>ac` extension loading instructions for the Zed context.

---

## Evidence / Examples

### Broken routing chain for Task 29

```
/slides 29
  -> commands/slides.md: validates language="present", task_type="slides"
  -> Task 29: language="present", task_type="present:talk"  ← MISMATCH
  -> Error: "Task is not a talk task (language=present, task_type=present:talk)"
```

### Orphaned routing.md entry

```
# context/routing.md line 12 (stale):
| python | skill-python-research | skill-python-implementation |

# But these files are deleted (git status):
D .claude/skills/skill-python-research/SKILL.md
D .claude/skills/skill-python-implementation/SKILL.md
D .claude/agents/python-research-agent.md
D .claude/agents/python-implementation-agent.md
```

### project-overview.md identity mismatch

```
# Context: Working directory = /home/benjamin/.config/zed/
# Actual contents: keymap.json, settings.json, themes/, docs/, examples/

# project-overview.md says:
"This is a Neovim configuration project using Lua and lazy.nvim..."
"Technology Stack: Lua, lazy.nvim, nvim-lspconfig, mason.nvim..."
"Project Structure: nvim/ init.lua, lua/config/..."
```

### Root docs claiming python is active

```
# docs/toolchain/extensions.md line 121:
"Every extension entry in `.claude/CLAUDE.md` (epidemiology, filetypes,
latex, memory, present, python, typst) is pre-merged into the active
configuration in this workspace."

# docs/toolchain/extensions.md line 132:
| python | skill-python-research | skill-python-implementation |
```

---

## Confidence Level

| Finding | Confidence | Notes |
|---------|-----------|-------|
| Task 29 routing broken | Very High | Direct code trace confirms mismatch |
| routing.md python row stale | Very High | Files deleted, row remains |
| CLAUDE.md python in task types | High | Line 75 is clear |
| project-overview.md wrong project | High | Directory contents vs description obvious mismatch |
| Root docs/ python references | High | Files directly read and verified |
| Memory file stale | High | Content directly contradicts deletion |
| `<leader>ac` wrong for Zed | Medium | Functional for neovim users of same system; context-dependent |
| Guide examples using python | Medium | Low impact, documentation quality only |

**Overall assessment**: The change set is functionally sound for NEW work (python extension is correctly removed from skills/agents/context and slides correctly replaces talk), but leaves several orphaned references in docs and context files, one actively broken task (Task 29), and a fundamentally wrong project-overview.md that will misdirect agent reasoning for every session in this Zed repo.
