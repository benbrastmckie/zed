# Extensions

The agent system uses domain-specific extensions to provide specialized research, planning, and implementation capabilities. Both Claude Code and OpenCode share the same 10 extensions, sourced from a common upstream. Extensions are pre-merged into each system's active configuration -- there is no manual loading step.

## Extension Feature Matrix

| Extension | Version | What It Provides | Task Types |
|-----------|---------|------------------|------------|
| **core** | 2.0.0 (CC) / 1.0.0 (OC) | Base commands, agents, skills, rules, hooks, scripts, context, templates | `general`, `meta`, `markdown` |
| **epidemiology** | 2.0.0 (CC) / 1.0.0 (OC) | Study design, causal inference, missing data, statistical modeling, STROBE reporting | `epi`, `epi:study`, `epidemiology` |
| **filetypes** | 2.2.0 | Document conversion (PDF/DOCX/Markdown), spreadsheet handling, presentation extraction, PDF scraping, DOCX editing, XLSX analysis | (routing by format) |
| **latex** | 1.0.0 | LaTeX document research and implementation, pdflatex/latexmk build support | `latex` |
| **memory** | 1.0.0 | Knowledge capture and retrieval, vault management, distillation, MCP integration | (utility) |
| **present** | 1.0.0 | Grant proposals, budgets, timelines, funding analysis, academic talks, slide planning and critique | `present`, `present:grant`, `present:budget`, `present:timeline`, `present:funds`, `present:slides` |
| **python** | 1.0.0 | Python development with pytest, mypy, ruff; code style and testing patterns | `python` |
| **slidev** | 1.0.0 | Shared Slidev animation patterns, CSS presets, config templates (dependency of `present`) | (no routing -- utility) |
| **typst** | 1.0.0 | Typst document research and implementation, fletcher diagrams, single-pass compilation | `typst` |

**Version note**: "CC" = Claude Code, "OC" = OpenCode. Most extensions share the same version across both systems; `core` and `epidemiology` have different version numbers due to independent release cycles.

## Naming Differences Between Systems

While extensions are structurally identical, there are intentional skill and agent naming divergences:

| Capability | Claude Code | OpenCode |
|-----------|-------------|----------|
| Epi skills | `skill-epi-research`, `skill-epi-implement` | `skill-epidemiology-research`, `skill-epidemiology-implementation` |
| Spreadsheet skill | `skill-filetypes-spreadsheet` | `skill-spreadsheet` |
| Agent directory | `.claude/agents/` | `.opencode/agent/` |
| Skill directory | `.claude/skills/` | `.opencode/skills/` |

## Per-System Exclusive Capabilities

Some capabilities exist in only one system:

| Capability | Claude Code | OpenCode | Notes |
|-----------|:-----------:|:--------:|-------|
| DOCX editing (`/edit`) | Yes | -- | Requires SuperDoc MCP |
| PDF scraping (`/scrape`) | Yes | -- | Uses pdfannots/pymupdf |
| Memory distillation (`/distill`) | Yes | -- | Vault health scoring and maintenance |
| Epidemiology command (`/epi`) | Yes | -- | Stage 0 interactive routing |
| Deck creation (`/deck`) | -- | Yes | Presentation deck generation |
| Project overview (`/project-overview`) | -- | Yes | Repository documentation generation |

## Shared State

Both systems share these resources:

- **`specs/`** -- Task management (TODO.md, state.json, task directories)
- **`.memory/`** -- Memory vault with validate-on-read index
- **`scripts/install/`** -- Installation wizard
- **`docs/`** -- User-facing documentation

Task directories use prefixes to identify their origin:
- Claude Code tasks: `specs/{NNN}_{SLUG}/` (no prefix)
- OpenCode tasks: `specs/OC_{NNN}_{SLUG}/` (OC_ prefix)

## Extension Architecture

Each extension lives in a directory under `.claude/extensions/` (or `.opencode/extensions/`). The structure is:

```
extensions/{name}/
├── manifest.json           # Extension metadata and capabilities
├── context/                # Domain knowledge files
│   └── project/{domain}/   # Domain-specific context
├── merge-sources/          # Files merged into parent system
│   ├── claudemd.md         # CLAUDE.md section
│   └── ...
└── README.md               # Extension documentation
```

Extensions can declare dependencies on other extensions via the `dependencies` array in `manifest.json`. Dependencies are auto-loaded when the parent extension is loaded.

## See also

- [commands.md](commands.md) -- Full command catalog with per-system availability
- [opencode.md](opencode.md) -- OpenCode setup and configuration
- [architecture.md](architecture.md) -- Three-layer execution pipeline
- [`.claude/CLAUDE.md`](../../.claude/CLAUDE.md) -- Claude Code quick reference with routing tables
