# Teammate D: Horizons

## Key Findings (strategic)

### 1. The Zed repo is a thin consumer, not a clone — and the docs should reflect that

The `.claude/` system in this Zed repo is a verbatim copy of the upstream neovim system (same commands, same skills, same agents, same docs hierarchy at `.claude/docs/`). The user-facing `docs/` directory in the Zed repo is the only layer that is *Zed-specific*: it addresses macOS Homebrew installation, Zed-specific keybindings, Office workflows, and MCP tool setup. The `.claude/docs/` subtree should be treated as a *linked library* — read it, link to it, but do not duplicate it.

This has a concrete implication: the new `docs/` expansion should contain *thin wrappers with strong links*, not hand-copied prose. If `docs/commands.md` describes `/research`, it should introduce the command in Zed-context terms and then point to `.claude/docs/guides/user-guide.md` for the full reference, rather than duplicating the 100-line command spec.

### 2. `claude-acp` is absent from all existing documentation

The current `docs/agent-system.md` says "start it by running `claude`", but the task description explicitly notes that the user runs `claude-acp`, not `claude`. This is the single biggest accuracy gap: the product the user actually launches is undocumented. `installation.md` is the natural home for this correction, but it also needs to appear in the first-run section of any overview doc.

### 3. Progressive disclosure is the right audience structure — one doc per topic, not beginner-vs-advanced splits

The 378-line `agent-system.md` already attempts to layer information (overview → main workflow → command catalog → memory system → architecture → MCP setup). The problem is not the layering model; it is that every topic competes for attention in one file. Splitting by topic (one file per natural grouping) while keeping the layering model *within* each file is the right approach. A new user reads the lead paragraph and the first example; a returning user skips to the flag table. This is progressive disclosure inside a topic-coherent file — not a separate `beginner/` and `advanced/` tree.

### 4. The docs set has a discoverable entry point but weak internal navigation

`README.md` links to `docs/agent-system.md`. `docs/agent-system.md` links into `.claude/docs/`. But the reverse path — from `.claude/CLAUDE.md` or the terminal command prompt — back to the user-facing docs — is absent. A new user who opens `claude` and types `/help` has no path to `docs/`. This is a discoverability gap that a `docs/README.md` (index file with one-line descriptions) and a back-reference from `.claude/CLAUDE.md` would close.

### 5. Extensions keep growing; the docs model must accommodate that without hand-editing

At the time of writing the Zed repo has 13+ extensions visible in `.claude/extensions.json` and confirmed active through the CLAUDE.md system prompt (epidemiology, filetypes, latex, typst, present, memory). Each extension adds commands. The current `docs/agent-system.md` already lists grant/research/talk/budget/timeline/funds commands inline. As extensions accumulate, a flat command list becomes unmanageable.

The right long-term model: `docs/commands/` contains one file per command group (core lifecycle, task management, document conversion, research presentation, memory), and extension commands live in that group's file with a visible note like "provided by the present extension". This way a new extension adds one paragraph to one file, not a new section in a monolithic file.

### 6. Auto-generation from command frontmatter is appealing but not yet the right investment

Every `.claude/commands/*.md` file has a YAML frontmatter `description:` and `argument-hint:` field. In principle, a script could generate a command reference table automatically. In practice, the frontmatter descriptions are agent-oriented (terse, technical) rather than user-oriented (explanatory, contextual). Generating user docs from agent metadata would produce low-quality prose without a human-written layer on top. The better long-term investment is: (a) keep frontmatter as the machine-readable spec, (b) keep `docs/` as the human-edited layer, and (c) add a link-check script that verifies every command mentioned in `docs/` exists in `.claude/commands/`. This catches drift without generating bad prose.

---

## Recommended Approach (long-term)

### Immediate (task 6 scope): split by topic, add installation.md

Proposed `docs/` structure:

```
docs/
├── README.md                # Index: one-line descriptions + links (NEW)
├── installation.md          # macOS Homebrew + claude-acp setup (NEW, extracted)
├── quick-start.md           # 5-minute orientation for a new user (NEW)
├── commands/
│   ├── README.md            # Commands overview and grouping rationale
│   ├── lifecycle.md         # /task /research /plan /revise /implement
│   ├── maintenance.md       # /todo /review /errors /refresh /fix-it
│   ├── memory.md            # /learn and the two-layer memory model
│   ├── system.md            # /meta /merge /tag /spawn
│   └── documents.md         # /convert /edit /table /slides /scrape
│   └── research-grants.md   # /grant /budget /timeline /funds /talk
├── keybindings.md           # (existing — no change needed)
├── settings.md              # (existing — no change needed)
└── office-workflows.md      # (existing — no change needed)
```

The existing `agent-system.md` becomes `docs/commands/lifecycle.md` plus the other split files, with `docs/README.md` serving as the new hub. The current `README.md` at the repo root already links to `docs/agent-system.md`; that link becomes `docs/README.md`.

### Near-term (task 7+): link validation and back-references

Add `.claude/scripts/check-doc-links.sh` that greps every `docs/**/*.md` for command names (`/task`, `/research`, etc.) and verifies a matching file exists in `.claude/commands/`. Run this as a pre-commit hook or as part of `/review`. This costs ~50 lines of bash and prevents the most common drift: a command is renamed upstream but the user-facing doc still uses the old name.

Add a one-line back-reference in `.claude/CLAUDE.md` under the Quick Reference section: `# For a user-friendly walkthrough, see [docs/README.md](../docs/README.md)`. This closes the terminal-to-docs discoverability gap.

### Medium-term (task 8+): platform sibling for Linux/Windows

`installation.md` should be macOS-specific now but structured to allow a sibling. The recommended structure:

```
docs/
└── installation/
    ├── README.md            # Platform picker
    ├── macos.md             # Homebrew + claude-acp (current content)
    └── linux.md             # (stub for future)
```

Alternatively, if a multi-platform installation doc is not anticipated soon, use a `## Platform Notes` section at the bottom of `installation.md` with placeholders. This is a lower-maintenance version of the same intent.

### Long-term (task 10+): extension docs as first-class citizens

When extensions stabilize, add `docs/extensions/` with one file per major extension group (document-tools, research-grants, knowledge-management). Each file describes what the extension adds, which commands it enables, and links to the canonical extension docs in `.claude/extensions/*/`. This follows the "thin wrapper + strong link" principle established above.

---

## Adjacent Opportunities

### Collaborator onboarding

The user note says "Zed shared with collaborator; use standard keybindings, not vim." `docs/quick-start.md` is a natural onboarding doc for that collaborator: here is what Zed is, here is how to open the AI panel, here is how to run Claude Code, here are the three commands you will use 80% of the time. This is essentially free to write alongside the `docs/` expansion.

### `docs/README.md` as CLAUDE.md supplement

The `.claude/CLAUDE.md` system prompt is loaded every session but is dense and agent-oriented. `docs/README.md` can be a lighter, human-readable complement: one sentence per doc file, no jargon. A user who opens the Zed config repo for the first time and reads `README.md → docs/README.md` should understand what Claude Code does for them in under two minutes.

### link-check as `/review` integration

The code-reviewer-agent already runs `/review`. Adding a docs link-check pass (verify that all paths in `docs/**/*.md` resolve, verify that all commands mentioned exist in `.claude/commands/`) as a postflight step in `/review` would catch drift automatically. The review command already supports `--create-tasks` to file repair tasks.

### `installation.md` as a template for future repos

If other config repos are created (e.g., a WezTerm config, a fish/zsh config), `installation.md` structured around a "prerequisites → Homebrew → repo clone → claude-acp" pattern becomes a reusable template. The macOS-specific content is in one file that can be lifted directly.

---

## Evidence/Examples

**Upstream relationship**: `/home/benjamin/.config/zed/.claude/docs/guides/` and `/home/benjamin/.config/nvim/.claude/docs/guides/` contain identical file lists (`user-guide.md`, `user-installation.md`, `creating-commands.md`, etc.). The Zed `.claude/docs/` is a copy, not a customization. User-facing `docs/` is the only Zed-specific documentation layer.

**claude-acp gap**: The current `docs/agent-system.md` line 47 says "Start it by opening the terminal (Cmd+`) and running `claude`." The task description for task 6 explicitly calls out that `claude-acp` is what the user actually runs. This is a factual error in the current doc that must be corrected in `installation.md`.

**Extension growth**: The CLAUDE.md system prompt includes active entries for epidemiology, filetypes, latex, typst, present, and memory extensions. The present extension alone adds 5 commands (grant, budget, timeline, funds, talk). Future extensions will add more. Flat command lists will not scale.

**Command frontmatter is machine-readable**: `task.md` frontmatter: `description: Create, recover, divide, sync, or abandon tasks`, `argument-hint: "description" | --recover N | --expand N | --sync | --abandon N | --review N`. These fields are present and consistent. They support auto-generation of a reference table but not user-oriented prose.

**Progressive disclosure within topics**: The existing `agent-system.md` already structures each command as: one-sentence summary → usage example → flag table → links to deeper docs. This pattern is correct. The problem is scale (24 commands in one file), not the pattern itself.

---

## Confidence Level: high

The upstream relationship, extension growth trajectory, and claude-acp documentation gap are directly observable from the repo. The progressive-disclosure-within-topic recommendation is grounded in the existing doc structure working well at smaller scale. The link-check opportunity is a concrete, low-cost addition. The collaborator onboarding opportunity is grounded in the auto-memory note about the shared collaborator. The main uncertainty is the exact topic groupings for the `commands/` split — those should be validated against the task 6 planner's grouping decisions.
