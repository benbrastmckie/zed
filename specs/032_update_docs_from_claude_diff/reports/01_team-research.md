# Team Research: Documentation Updates for .claude/ Configuration Changes

**Task 32** | Team research synthesis | Session: sess_1775881003_5f2e6a

---

## Summary

Research identified **7 files** requiring edits, all stemming from a single root cause: removal of the Python extension from `.claude/`. The talk→slides rename and epidemiology routing changes were already correctly applied; no stale references for those categories exist anywhere in `.claude/`.

---

## Findings

### Root Cause: Python Extension Removal

The Python extension (`skill-python-research`, `skill-python-implementation`, `python-research-agent`, `python-implementation-agent`, and all `context/project/python/` files) was deleted. Seven documentation files still reference these deleted components — primarily as illustrative examples in guides.

### Files Requiring Edits

| File | Issue | Edit Type |
|------|-------|-----------|
| `context/routing.md` | Active `python` routing row points to deleted skills | Delete row |
| `README.md` | Extensions table lists Python as available | Delete row |
| `docs/guides/creating-extensions.md` | `python` listed in simple-extensions example | Remove word |
| `context/architecture/component-checklist.md` | Pattern 2 example uses Python paths | Replace with Rust |
| `docs/architecture/system-overview.md` | "Adding New Language" example uses Python paths | Replace with Rust |
| `docs/guides/component-selection.md` | Three locations use Python as skill/agent example | Replace with Rust (×3) |
| `docs/guides/creating-skills.md` | Complete Example section uses Python throughout | Replace with Rust (×4) |

### Confirmed Clean (No Changes Needed)

- `talk-agent` / `skill-talk` / `present:talk` — no instances found; already cleaned up
- `Zed` references — no stale instances in `.claude/` docs
- `epidemiology` in agent files, context files, `index.json` — all refer to valid existing extension paths, not stale routing keys
- `epi, epi:study` routing in `context/routing.md` — already correct

---

## Detailed Edit Specifications

### 1. `context/routing.md` — Delete python row

Remove line 12:
```
| python | skill-python-research | skill-python-implementation |
```

### 2. `README.md` — Delete python extensions table row

Remove line 123:
```
| python | Python development | Python patterns, tools |
```

### 3. `docs/guides/creating-extensions.md` — Remove `python,` from simple extensions list (line 139)

**From**:
```
distinguishes simple extensions (latex, python, typst, z3) from complex extensions
```
**To**:
```
distinguishes simple extensions (latex, typst, z3) from complex extensions
```

### 4. `context/architecture/component-checklist.md` — Replace Python example in Pattern 2 (lines 188–192)

**From**:
```
When: Adding support for a new language (e.g., Python)

**Creates**:
1. Skill: `.claude/skills/skill-python-research/SKILL.md`
2. Agent: `.claude/agents/python-research-agent.md`
```
**To**:
```
When: Adding support for a new language (e.g., Rust)

**Creates**:
1. Skill: `.claude/skills/skill-rust-research/SKILL.md`
2. Agent: `.claude/agents/rust-research-agent.md`
```

### 5. `docs/architecture/system-overview.md` — Replace Python example (lines 252–255)

**From**:
```
To add support for a new language (e.g., Python):

1. Create skill: `.claude/skills/skill-python-research/SKILL.md`
2. Create agent: `.claude/agents/python-research-agent.md`
3. Update routing in existing commands
```
**To**:
```
To add support for a new language (e.g., Rust):

1. Create skill: `.claude/skills/skill-rust-research/SKILL.md`
2. Create agent: `.claude/agents/rust-research-agent.md`
3. Update routing in existing commands
```

### 6. `docs/guides/component-selection.md` — Three replacements

**6a** (line 105): `skill-python-research` → `skill-rust-research`

**6b** (lines 167–170, Pattern 2 flow diagram):
```
skill-python-research (new)
    |
    v
python-research-agent (new)
```
→
```
skill-rust-research (new)
    |
    v
rust-research-agent (new)
```

**6c** (lines 309–315, Example 1):
- Title: `Adding Python Support` → `Adding Rust Support`
- Goal line: `Support Python tasks` → `Support Rust tasks`
- Skill path: `skill-python-research/SKILL.md` → `skill-rust-research/SKILL.md`
- Agent path: `python-research-agent.md` → `rust-research-agent.md`
- Notes line: `Routes Python tasks to Python agent` → `Routes Rust tasks to Rust agent`
- Tools line: `Uses Python-specific tools` → `Uses Rust-specific tools`

### 7. `docs/guides/creating-skills.md` — Four replacements in Complete Example section

**7a** (lines 308–325, YAML frontmatter + header):
- `skill-python-research` → `skill-rust-research`
- `Research Python packages and APIs` → `Research Rust crates and APIs`
- `python-research-agent` → `rust-research-agent`
- `.claude/context/project/python/tools.md` → `.claude/context/project/rust/tools.md`
- `# Python Research Skill` → `# Rust Research Skill`
- `delegates Python research to \`python-research-agent\`` → `delegates Rust research to \`rust-research-agent\``

**7b** (line ~364, delegation_path JSON):
`"skill-python-research"` → `"skill-rust-research"`

**7c** (line ~378):
`Invoke \`python-research-agent\` via Task tool` → `Invoke \`rust-research-agent\` via Task tool`

**7d** (lines ~420–424, metadata JSON):
`"agent_type": "python-research-agent"` → `"agent_type": "rust-research-agent"`
`"python-research-agent"` in delegation_path → `"rust-research-agent"`

---

## Confidence

**HIGH** for all findings. Every stale reference was verified by direct grep against the live files. The replacement language (Rust) was chosen as a realistic hypothetical that does not conflict with any existing `.claude/` extension.
