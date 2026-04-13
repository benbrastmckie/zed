# Teammate A Findings: Documentation Files Requiring Updates

## Key Findings

Five documentation files contain stale references that must be updated. The issues fall into two categories:

1. **Python extension references** - Four doc files still reference `skill-python-research`, `skill-python-implementation`, `python-research-agent`, and `python-implementation-agent` as illustrative examples. The Python extension has been removed from `.claude/`.
2. **Python row in routing table** - `context/routing.md` has an active routing entry for `python` pointing to now-deleted skills.

No stale `talk-agent`, `skill-talk`, or `present:talk` references were found (already cleaned up). No stale `Zed` references were found in `.claude/` docs. The `epidemiology` references in agent files, context files, and `context/index.json` are correct: they refer to the extension's own content paths (which still exist), not to routing keys. The routing key is already `epi, epi:study` in `context/routing.md` (line 15). The `epidemiology` row in the CLAUDE.md routing table (line 360) is a legacy alias row kept intentionally alongside `epi` and `epi:study` — this needs separate verification (see confidence note below).

---

## Files and Required Edits

### File 1: `context/routing.md`

**Path**: `/home/benjamin/.config/zed/.claude/context/routing.md`

**Issue**: Line 12 routes `python` to deleted skills.

**Current text** (line 12):
```
| python | skill-python-research | skill-python-implementation |
```

**Correct text**: Remove this row entirely. The `python` extension no longer exists in `.claude/`.

**Confidence**: HIGH — The skills referenced (`skill-python-research`, `skill-python-implementation`) were explicitly deleted per the changes summary.

---

### File 2: `docs/architecture/system-overview.md`

**Path**: `/home/benjamin/.config/zed/.claude/docs/architecture/system-overview.md`

**Issue**: Lines 252–255. The "Adding New Language Support" section uses Python as the example with specific paths that no longer exist.

**Current text** (lines 252–255):
```
To add support for a new language (e.g., Python):

1. Create skill: `.claude/skills/skill-python-research/SKILL.md`
2. Create agent: `.claude/agents/python-research-agent.md`
3. Update routing in existing commands
```

**Correct text**: Replace the Python-specific example with a generic or Neovim-based example that does not reference deleted files:
```
To add support for a new language (e.g., Rust):

1. Create skill: `.claude/skills/skill-rust-research/SKILL.md`
2. Create agent: `.claude/agents/rust-research-agent.md`
3. Update routing in existing commands
```

**Confidence**: HIGH — The Python paths were explicitly deleted; the example must use a non-deleted language.

---

### File 3: `docs/guides/component-selection.md`

**Path**: `/home/benjamin/.config/zed/.claude/docs/guides/component-selection.md`

Three stale references in this file:

**3a — Line 105** (under "Create a Skill When... / Good candidates"):
```
- New language support (e.g., `skill-python-research`)
```
Replace with:
```
- New language support (e.g., `skill-rust-research`)
```

**3b — Lines 167–170** (Pattern 2 flow diagram):
```
skill-python-research (new)
    |
    v
python-research-agent (new)
```
Replace with:
```
skill-rust-research (new)
    |
    v
rust-research-agent (new)
```

**3c — Lines 309–315** (Example 1: Adding Python Support):
```
### Example 1: Adding Python Support

**Goal**: Support Python tasks with task-type-specific tooling

**Components needed**:
1. `skill-python-research/SKILL.md` - Routes Python tasks to Python agent
2. `python-research-agent.md` - Uses Python-specific tools

**No command needed** - existing `/research` routes by language
```
Replace with a different language example:
```
### Example 1: Adding Rust Support

**Goal**: Support Rust tasks with task-type-specific tooling

**Components needed**:
1. `skill-rust-research/SKILL.md` - Routes Rust tasks to Rust agent
2. `rust-research-agent.md` - Uses Rust-specific tools

**No command needed** - existing `/research` routes by language
```

**Confidence**: HIGH — All three references use Python-specific paths that were deleted.

---

### File 4: `docs/guides/creating-skills.md`

**Path**: `/home/benjamin/.config/zed/.claude/docs/guides/creating-skills.md`

Four stale references in this file (all within the "Complete Example" section starting at line 308):

**4a — Lines 308–325** (YAML frontmatter block):
```yaml
---
name: skill-python-research
description: Research Python packages and APIs for implementation tasks. Invoke for Python-language research.
allowed-tools: Task
context: fork
agent: python-research-agent
# Original context (now loaded by subagent):
#   - .claude/context/project/python/tools.md
# Original tools (now used by subagent):
#   - Read, Write, Glob, Grep, WebSearch, WebFetch
---

# Python Research Skill

Thin wrapper that delegates Python research to `python-research-agent` subagent.
```
Replace with Rust equivalent:
```yaml
---
name: skill-rust-research
description: Research Rust crates and APIs for implementation tasks. Invoke for Rust-language research.
allowed-tools: Task
context: fork
agent: rust-research-agent
# Original context (now loaded by subagent):
#   - .claude/context/project/rust/tools.md
# Original tools (now used by subagent):
#   - Read, Write, Glob, Grep, WebSearch, WebFetch
---

# Rust Research Skill

Thin wrapper that delegates Rust research to `rust-research-agent` subagent.
```

**4b — Lines 362–374** (delegation_path JSON):
```json
  "delegation_path": ["orchestrator", "research", "skill-python-research"],
```
Replace with:
```json
  "delegation_path": ["orchestrator", "research", "skill-rust-research"],
```

**4c — Line 378**:
```
Invoke `python-research-agent` via Task tool with:
```
Replace with:
```
Invoke `rust-research-agent` via Task tool with:
```

**4d — Lines 420–424** (metadata JSON):
```json
    "agent_type": "python-research-agent",
```
and on the same line / adjacent:
```json
    "delegation_path": ["orchestrator", "research", "python-research-agent"]
```
Replace with:
```json
    "agent_type": "rust-research-agent",
```
and:
```json
    "delegation_path": ["orchestrator", "research", "rust-research-agent"]
```

**Confidence**: HIGH — All use the deleted `skill-python-research` / `python-research-agent` names; the context comment references deleted path `project/python/tools.md`.

---

### File 5: `context/architecture/component-checklist.md`

**Path**: `/home/benjamin/.config/zed/.claude/context/architecture/component-checklist.md`

**Issue**: Lines 188–192 (Pattern 2: New Language Support example uses Python).

**Current text**:
```
When: Adding support for a new language (e.g., Python)

**Creates**:
1. Skill: `.claude/skills/skill-python-research/SKILL.md`
2. Agent: `.claude/agents/python-research-agent.md`
```

**Correct text**:
```
When: Adding support for a new language (e.g., Rust)

**Creates**:
1. Skill: `.claude/skills/skill-rust-research/SKILL.md`
2. Agent: `.claude/agents/rust-research-agent.md`
```

**Confidence**: HIGH — Same pattern as above; uses deleted paths.

---

### File 6: `README.md`

**Path**: `/home/benjamin/.config/zed/.claude/README.md`

**Issue**: Line 123. The extensions table still lists Python as an available extension.

**Current text** (line 123):
```
| python | Python development | Python patterns, tools |
```

**Correct text**: Remove this row entirely, as the Python extension has been deleted from `.claude/`.

**Confidence**: HIGH — The Python extension files were all deleted per the changes summary.

---

### File 7: `docs/guides/creating-extensions.md`

**Path**: `/home/benjamin/.config/zed/.claude/docs/guides/creating-extensions.md`

**Issue**: Line 139. The section-applicability matrix example lists `python` as a simple extension.

**Current text**:
```
The template includes a **section-applicability matrix** that distinguishes simple extensions (latex, python, typst, z3) from complex extensions (filetypes, lean, formal, nvim, nix, web, epidemiology).
```

**Correct text**: Remove `python` from the simple extensions list:
```
The template includes a **section-applicability matrix** that distinguishes simple extensions (latex, typst, z3) from complex extensions (filetypes, lean, formal, nvim, nix, web, epidemiology).
```

**Confidence**: HIGH — Python extension was deleted; listing it as a "simple extension" example is misleading.

---

## Items That Do NOT Require Changes

The following were investigated and are correct as-is:

- **`context/routing.md` line 15**: `| epi, epi:study | skill-epi-research | skill-epi-implement |` — Correct, already updated.
- **`CLAUDE.md` epidemiology section (lines 349–397)**: The `epidemiology` key in the routing table (line 360) is a legacy alias alongside `epi` and `epi:study`. This is an intentional alias for backward compatibility, not a stale reference. The context file paths reference `project/epidemiology/...` which are actual existing files.
- **`talk-agent` / `skill-talk` / `present:talk`**: No instances found anywhere in `.claude/`. Already cleaned up.
- **`Zed` references**: No stale Zed references found in `.claude/` documentation.
- **Agent files (`epi-research-agent.md`, `epi-implement-agent.md`)**: All `epidemiology` references are valid paths within the epidemiology extension directory.
- **`context/index.json`**: All `epidemiology` subdomain references point to existing context files.
- **`extensions.json`**: `epidemiology` entries are correct extension configuration data, not routing keys.

---

## Recommended Approach

Apply edits in this order (lower risk first):

1. **`context/routing.md`** — Single row deletion (highest impact, lowest risk)
2. **`README.md`** — Single row deletion in extensions table
3. **`docs/guides/creating-extensions.md`** — Single word removal in one sentence
4. **`context/architecture/component-checklist.md`** — 4-line block replacement
5. **`docs/architecture/system-overview.md`** — 3-line block replacement
6. **`docs/guides/component-selection.md`** — Three separate replacements in one file
7. **`docs/guides/creating-skills.md`** — Most changes; complete example block replacements

All replacements use `Rust` as the replacement language for illustrative examples. Rust was chosen because it is a realistic extension target not currently present in `.claude/` (unlike Neovim, LaTeX, etc. which have real implementations that the examples would need to precisely match).

---

## Confidence Level

**Overall**: HIGH

All findings are based on direct grep results confirming the stale text exists in the listed files at the listed lines. The Python extension removal is explicitly documented in the changes summary. No talk/slides confusion was found; that rename was already applied. The `epidemiology` routing entries in CLAUDE.md are intentional aliases, not stale references — confirmed by the presence of `epidemiology` as a valid task_type key alongside `epi` and `epi:study`.
