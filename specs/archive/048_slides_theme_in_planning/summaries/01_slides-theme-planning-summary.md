# Implementation Summary: Move Theme Selection into Planning Phase

- **Task**: 48 - slides_theme_in_planning
- **Status**: [COMPLETED]
- **Started**: 2026-04-12T12:00:00Z
- **Completed**: 2026-04-12T12:45:00Z
- **Effort**: 45 minutes
- **Dependencies**: None
- **Artifacts**: plans/01_slides-theme-planning.md
- **Standards**: status-markers.md, artifact-management.md, tasks.md, summary-format.md

## Overview

Moved visual theme selection (D1 theme, D2 message ordering, D3 section emphasis) from a standalone `/slides N --design` invocation into the `/plan N` workflow for slides tasks. This eliminates an extra manual step by asking design questions interactively during planning, before delegating to the planner-agent.

## What Changed

- Added `plan` workflow type to skill-slides SKILL.md with full lifecycle: preflight ([PLANNING]), design questions (Stage 3.5), design_decisions storage in state.json, delegation to planner-agent, and postflight ([PLANNED])
- Installed present extension manifest to `.claude/extensions/present/manifest.json` with routing key `"slides": "skill-slides"` for plan workflow, enabling plan.md extension routing to find the correct skill
- Removed entire STAGE 3: DESIGN CONFIRMATION section from slides.md (126 lines), including `--design` flag detection, input type handling, design questions, and git commit logic
- Updated slides.md input type detection, Core Command Integration table, and output templates to reflect streamlined workflow
- Updated skill-slides description and subagent listing to include planner-agent

## Decisions

- Used manifest installation approach (copy manifest.json to `.claude/extensions/present/`) rather than modifying plan.md routing logic, keeping plan.md generic
- Added both `"slides"` and `"present:slides"` routing keys to cover both task_type formats
- Design questions (D1-D3) moved verbatim from slides.md STAGE 3 to skill-slides Stage 3.5, preserving exact question text and response schema
- Assembly agents left unchanged -- they already read design_decisions from state.json with the correct fallback chain

## Impacts

- `/plan N` for slides tasks now routes to skill-slides (plan workflow) instead of skill-planner
- Users no longer need to run `/slides N --design` as a separate step -- design questions are asked during `/plan N`
- Existing tasks with design_decisions in state.json are unaffected (Stage 3.5 detects existing decisions and offers reuse or reconfiguration)
- The workflow is now: `/slides "desc"` -> `/research N` -> `/plan N` (includes design) -> `/implement N`

## Follow-ups

- None identified. Assembly agents' fallback chain is intact and routing works end-to-end.

## References

- `specs/048_slides_theme_in_planning/plans/01_slides-theme-planning.md`
- `specs/048_slides_theme_in_planning/reports/01_slides-theme-planning.md`
- `.claude/skills/skill-slides/SKILL.md`
- `.claude/commands/slides.md`
- `.claude/extensions/present/manifest.json`
