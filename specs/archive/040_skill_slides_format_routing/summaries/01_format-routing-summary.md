# Implementation Summary: Task #40

- **Task**: 40 - Update skill-slides for format-specific assembly routing
- **Status**: [COMPLETED]
- **Started**: 2026-04-12
- **Completed**: 2026-04-12
- **Artifacts**: summaries/01_format-routing-summary.md (this file)

## Overview

Added format-aware routing to skill-slides so the assemble workflow checks `forcing_data.output_format` and produces format-specific commit messages and return summaries. Updated the present extension manifest to add the `:assemble` routing suffix for slides implementation, matching the existing grant pattern.

## What Changed

### `.claude/skills/skill-slides/SKILL.md`
- **Stage 2**: Added `output_format` extraction from `forcing_data` with `"slidev"` default for backward compatibility
- **Stage 4**: Documented `output_format` field in the delegation context JSON, showing it passes through to the slides-agent
- **Stage 9**: Commit message now branches on `output_format` -- produces "assemble PPTX presentation" or "assemble Slidev presentation"
- **Stage 11**: Return summary now has two variants: Slidev lists `slides.md, style.css, README.md`; PPTX lists `{slug}.pptx, generate_deck.py`

### `/home/benjamin/.config/nvim/.claude/extensions/present/manifest.json`
- Changed `routing.implement["present:slides"]` from `"skill-slides"` to `"skill-slides:assemble"`, matching the grant pattern

## Decisions

- **No CLAUDE.md routing table update**: The user-facing routing table shows skill names without internal suffixes (`:assemble`). This is consistent with how grant is documented.
- **No extensions.json update**: The merged extensions.json stores installed file paths, not routing. Routing is resolved from the manifest at load time.
- **Default to Slidev**: When `output_format` is absent from forcing_data, the skill defaults to `"slidev"` for full backward compatibility.

## Impacts

- Existing slides tasks without `output_format` in forcing_data continue to work unchanged (Slidev default)
- New tasks created with `/slides` (task 37 forcing questions) will have `output_format` set in forcing_data
- The slides-agent (task 39) already branches on `output_format` at Stage 1c -- this change completes the routing chain from skill to agent

## Follow-ups

- Implement the actual Slidev assembly workflow in slides-agent (future task)
- End-to-end testing with a real slides task using PPTX output format

## References

- Research report: `specs/040_skill_slides_format_routing/reports/01_format-routing.md`
- Implementation plan: `specs/040_skill_slides_format_routing/plans/01_format-routing.md`
- Related tasks: 37 (forcing questions), 38 (slides-agent PPTX research), 39 (slides-agent PPTX assembly)
