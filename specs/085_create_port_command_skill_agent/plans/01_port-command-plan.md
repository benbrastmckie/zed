# Implementation Plan: Task #85

- **Task**: 85 - Create /port command, skill-port, and port-agent
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None (tasks 86, 87 depend on this task)
- **Research Inputs**: specs/085_create_port_command_skill_agent/reports/01_port-command-research.md
- **Artifacts**: plans/01_port-command-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Create the three-layer architecture for website porting within the web extension: (1) a /port command with interactive forcing questions that creates web-typed tasks, (2) a skill-port thin wrapper that validates input and delegates to the port-agent via the Task tool, and (3) a port-agent execution agent that analyzes source websites and produces structured site analysis reports. All three components follow well-established patterns extracted from /epi, /slides, /grant commands (forcing questions), skill-web-research (thin wrapper), and web-research-agent (execution agent).

### Research Integration

The research report identified the following key patterns integrated into this plan:
- **Forcing questions pattern**: 6 questions covering source, content scope, design approach, target pages, features, and additional context -- following /epi (10 questions), /slides (4), /grant (4), /budget (3) precedents
- **Thin wrapper skill pattern**: Single-workflow skill with preflight/postflight, Task tool delegation, and artifact linking via "| not" jq pattern
- **Agent template pattern**: Stage 0 early metadata, delegation context parsing, structured report output, and metadata file return
- **Architecture decision**: /port creates `task_type: "web"` tasks (not a new compound type), reusing existing web routing for downstream /research, /plan, /implement
- **Port-agent role**: Site analysis agent producing structured reports (page inventory, design extraction, content inventory, Astro migration notes, Tailwind theme mapping)

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items to align with (roadmap is placeholder).

## Goals & Non-Goals

**Goals**:
- Create a fully functional /port command that walks users through 6 forcing questions and creates a web-typed task with forcing_data
- Create a skill-port thin wrapper that follows the established delegation pattern (preflight, Task tool delegation, postflight)
- Create a port-agent that can analyze source websites (via URL or local path) and produce structured site analysis reports
- Ensure all three components integrate correctly with the web extension architecture

**Non-Goals**:
- Updating the web extension manifest.json (task 87)
- Creating workflow documentation (task 86)
- Implementing the actual website porting/conversion (handled by standard /plan and /implement via web agents)
- Adding a new `web:port` compound task type (research recommends simple `web` type)
- Creating context index entries (task 87)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Command frontmatter incompatible with Zed's command execution | H | L | Follow exact frontmatter pattern from /epi and /slides commands |
| port-agent WebFetch unable to parse JavaScript-rendered sites | M | M | Document limitation in agent; recommend local path input for SPA sites |
| Skill postflight pattern diverges from existing skills | M | L | Use skill-web-research as direct template; verify jq patterns match |
| Forcing questions too many or too few for effective scoping | L | L | Research validated 6 questions as optimal; allow "skip" for optional questions |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3 | -- |
| 2 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Create /port command with forcing questions [COMPLETED]

**Goal**: Create the /port command definition file with the forcing-questions interactive flow, input type detection, task creation logic, and research delegation routing.

**Tasks**:
- [ ] Create `.claude/extensions/web/commands/port.md` with frontmatter (description, allowed-tools including AskUserQuestion, argument-hint, model)
- [ ] Implement Stage 0: Pre-task forcing questions (6 questions via AskUserQuestion)
  - Question 0.1: Source site (URL or local path)
  - Question 0.2: Content scope (ALL, SELECTED, STRUCTURE_ONLY, LANDING)
  - Question 0.3: Design approach (FAITHFUL, INSPIRED, REBRAND, MINIMAL)
  - Question 0.4: Target pages (description or "auto")
  - Question 0.5: Features and interactivity (free text or "skip")
  - Question 0.6: Additional context (free text or "skip")
- [ ] Implement forcing_data assembly with gathered_at timestamp
- [ ] Implement Checkpoint 1: Gate In (session ID generation, input type detection for URL/path/task_number/description)
- [ ] Implement Stage 1: Task creation (read next_project_number, create slug, update state.json with forcing_data, update TODO.md, git commit)
- [ ] Implement Stage 2: Research delegation (validate task exists with web type, delegate to skill-port)
- [ ] Add URL detection to input type routing (`^https?://` pattern)

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `.claude/extensions/web/commands/port.md` - Create new file (entire /port command definition)

**Verification**:
- File exists at the correct extension path
- Frontmatter includes all required fields (description, allowed-tools with AskUserQuestion, argument-hint, model)
- All 6 forcing questions are present with correct field names
- Input type detection covers URL, file path, task number, and description
- Task creation uses `task_type: "web"` and includes forcing_data
- Gate In generates session_id correctly
- Research delegation routes to skill-port

---

### Phase 2: Create skill-port thin wrapper [COMPLETED]

**Goal**: Create the skill-port thin wrapper skill that handles preflight status updates, delegation context preparation, Task tool invocation of port-agent, and postflight status updates with artifact linking.

**Tasks**:
- [ ] Create `.claude/extensions/web/skills/skill-port/SKILL.md` with frontmatter (name, description, allowed-tools including Task)
- [ ] Implement input validation (lookup task in state.json, validate task_type is "web")
- [ ] Implement preflight status update (set status to "researching" in state.json and TODO.md)
- [ ] Implement postflight marker creation (.postflight-pending file)
- [ ] Implement delegation context preparation (JSON with task_context, session_id, forcing_data, metadata_file_path)
- [ ] Implement Task tool invocation with port-agent delegation
- [ ] Implement self-execution fallback (write .return-meta.json if Task tool not used)
- [ ] Implement postflight sequence:
  - Read .return-meta.json
  - Update task status to "researched" in state.json and TODO.md
  - Link artifacts using two-step jq pattern with "| not" safety
  - Git commit
  - Cleanup (.postflight-pending, .return-meta.json)
  - Return brief text summary

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `.claude/extensions/web/skills/skill-port/SKILL.md` - Create new file (entire skill definition)

**Verification**:
- File exists at the correct extension path with SKILL.md naming
- Frontmatter includes Task in allowed-tools
- Preflight updates both state.json and TODO.md
- Delegation context includes forcing_data from the task
- Postflight reads .return-meta.json and links artifacts correctly
- Uses "| not" jq pattern (not `!=`) for artifact linking
- Returns text summary, not JSON

---

### Phase 3: Create port-agent execution agent [COMPLETED]

**Goal**: Create the port-agent that handles source website analysis -- fetching HTML via WebFetch (for URLs) or reading files directly (for local paths), extracting structure and design, and producing a structured site analysis report.

**Tasks**:
- [ ] Create `.claude/extensions/web/agents/port-agent.md` with frontmatter (name, description, model)
- [ ] Define agent overview, metadata, and invocation pattern
- [ ] Define allowed tools list (WebFetch, WebSearch, Read, Write, Edit, Glob, Grep, Bash)
- [ ] Add context references (@-references to web domain context, Astro framework, Tailwind v4)
- [ ] Implement Stage 0: Initialize early metadata (CRITICAL -- write in_progress to .return-meta.json)
- [ ] Implement Stage 1: Parse delegation context (extract forcing_data, source URL/path, session_id)
- [ ] Implement Stage 2: Source site analysis
  - URL input: WebFetch to retrieve HTML, parse structure
  - Local path input: Read files directly, parse directory structure
  - Extract page inventory (pages, sections, content summary)
  - Extract design analysis (colors, typography, layout patterns)
  - Identify technology stack (framework, CMS, JS dependencies)
- [ ] Implement Stage 3: Astro migration notes
  - Map source components to Astro components
  - Identify layouts needed
  - Identify islands (interactive elements) with recommended client: directives
  - Note content collections if applicable
  - List static assets to port
- [ ] Implement Stage 4: Generate Tailwind v4 theme mapping (proposed @theme block from extracted design)
- [ ] Implement Stage 5: Create site analysis report at `specs/{NNN}_{SLUG}/reports/{NN}_site-analysis.md`
- [ ] Implement Stage 6: Write final metadata (.return-meta.json with status "researched", artifact path, summary)
- [ ] Implement Stage 7: Return brief text summary
- [ ] Add error handling (URL fetch failure, empty site, large site pagination)
- [ ] Add critical requirements (MUST DO / MUST NOT lists)

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `.claude/extensions/web/agents/port-agent.md` - Create new file (entire agent definition)

**Verification**:
- File exists at the correct extension path
- Frontmatter includes name, description, and model fields
- Stage 0 early metadata creation is present and marked CRITICAL
- Both URL and local path input modes are handled
- Report template includes all sections (page inventory, design analysis, content extraction, Astro migration notes, Tailwind theme mapping, risks)
- Metadata file uses correct status values (never "completed")
- Returns text summary, not JSON
- Error handling covers WebFetch failures and large sites

---

### Phase 4: Verification and cross-validation [COMPLETED]

**Goal**: Verify all three components are internally consistent, follow established patterns correctly, and integrate properly with each other and the web extension architecture.

**Tasks**:
- [ ] Verify /port command routes to skill-port correctly (skill name matches)
- [ ] Verify skill-port delegates to port-agent correctly (agent name matches)
- [ ] Verify port-agent writes reports to the correct artifact path pattern
- [ ] Verify skill-port postflight can read port-agent's .return-meta.json format
- [ ] Verify forcing_data field names are consistent across command (assembly), skill (delegation context), and agent (parsing)
- [ ] Cross-check all file paths against web extension directory structure:
  - `.claude/extensions/web/commands/port.md`
  - `.claude/extensions/web/skills/skill-port/SKILL.md`
  - `.claude/extensions/web/agents/port-agent.md`
- [ ] Verify command frontmatter matches pattern from existing commands (/epi, /slides, /grant)
- [ ] Verify skill frontmatter and structure matches existing skills (skill-web-research)
- [ ] Verify agent frontmatter and structure matches existing agents (web-research-agent)
- [ ] Run grep to confirm no `!=` in jq commands (use "| not" pattern)
- [ ] Verify all status values use correct terms (never "completed" in agent metadata)
- [ ] Verify task_type is "web" throughout (not "port" or "web:port")

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3

**Files to modify**:
- (no new files -- read-only verification of created files)
- Minor corrections to any of the three files if inconsistencies found

**Verification**:
- All cross-references between the three files resolve correctly
- Pattern compliance confirmed against existing commands, skills, and agents
- No jq `!=` patterns present
- Forcing_data field names are consistent end-to-end

## Testing & Validation

- [ ] /port command file parses correctly (valid markdown with proper frontmatter)
- [ ] skill-port SKILL.md follows thin-wrapper template exactly
- [ ] port-agent.md follows agent template exactly
- [ ] All three files use consistent naming for the delegation chain (port -> skill-port -> port-agent)
- [ ] Forcing questions cover all scoping dimensions identified in research (source, content, design, pages, features, context)
- [ ] Port-agent report template includes all sections from research recommendation
- [ ] No hardcoded task numbers or paths (all use variable placeholders)
- [ ] jq commands use safe "| not" pattern throughout

## Artifacts & Outputs

- `.claude/extensions/web/commands/port.md` - /port command with 6 forcing questions
- `.claude/extensions/web/skills/skill-port/SKILL.md` - Thin wrapper skill for port-agent delegation
- `.claude/extensions/web/agents/port-agent.md` - Site analysis execution agent
- `specs/085_create_port_command_skill_agent/plans/01_port-command-plan.md` - This plan file

## Rollback/Contingency

All three files are new additions with no existing file modifications. Rollback requires only deleting the three created files:
```bash
rm .claude/extensions/web/commands/port.md
rm -rf .claude/extensions/web/skills/skill-port/
rm .claude/extensions/web/agents/port-agent.md
```

No existing functionality is modified by this task. Downstream tasks (86, 87) that depend on this task have not yet started.
