---
title: "Teammate D: Horizons - Strategic Alignment for Self-Learning Memory System"
created: 2026-04-15
role: Teammate D (Horizons)
focus: Long-term alignment and strategic direction
task: 68
---

# Teammate D Findings: Strategic Alignment

## Key Findings

### 1. The Project Is a Personal Power Tool, Not a Framework

The repository README is explicit: this is a Zed IDE configuration for **one person** (macOS, specific toolchain). The value proposition is **personal workflow amplification** -- R/Python research workflows, epidemiology analysis, grant writing, document conversion. There is no indication of a multi-user product or SaaS ambition. The `~/.config/zed/` location is fundamentally personal.

This constrains the memory system design in an important way: **the author's preferences and working patterns are the only signal that matters**. There is no need to generalize across codebases or users. The system should be tuned to one person's task patterns across a handful of domain types (epi, grants, slides, python, R, meta).

### 2. The Memory Vault Is Already Shared with OpenCode -- A Hard Constraint

The `.memory/` directory explicitly serves both Claude Code and OpenCode. The README states:

> "This vault is intentionally shared across AI systems: Both Claude Code and OpenCode can read all memories. Both systems can create and update memories."

Any automatic memory capture must be **write-safe** under concurrent use. The current vault uses filesystem-level operations (file writes, index.md regeneration). Automatic capture that runs at lifecycle checkpoints risks race conditions if OpenCode is running simultaneously. This is a real operational constraint, not hypothetical.

**Implication**: Automatic capture must either (a) use atomic writes with collision-resistant filenames (already partially done via timestamp slugs), or (b) be deferred to a non-critical path where conflicts are recoverable (e.g., capture suggestions in a queue that user processes later).

### 3. The Existing Memory Infrastructure Is Deliberately User-Gated

The current `skill-memory` SKILL.md has a strong **mandatory interactive requirement**:

> "STOP at Step 4 and call AskUserQuestion to show files. Write NOTHING to disk until user responds. Running autonomously without user input is a critical failure."

This gating is intentional. The `/learn` command is an explicit, opt-in operation. The `/todo` command suggests memory harvesting but does not automate it. The `/research N --remember` flag searches memories but does not write them.

The existing design reflects a deliberate philosophy: **the user decides what to remember**. Any self-learning system must decide whether to override this philosophy or work within it.

### 4. The Hook Infrastructure Already Exists for Lifecycle Events

The `settings.json` hook configuration shows four active hook points:
- `SessionStart` - fires when session begins
- `UserPromptSubmit` - fires on each user message
- `Stop` - fires when Claude finishes responding
- `SubagentStop` - fires when a subagent session ends

The `SubagentStop` hook already does meaningful work (postflight continuation detection). The `Stop` hook already handles TTS notification and WezTerm status. **The hook infrastructure is proven and production-ready**. Adding a memory-suggestion hook at `Stop` or `SubagentStop` is technically straightforward.

### 5. Context Discovery Already Supports Memory-Augmented Retrieval

The `--remember` flag on `/research` already demonstrates the intended retrieval pattern: search the vault before starting work, inject relevant memories into context. The `index.json` load_when system supports `task_types`, `agents`, and `commands` selectors.

The retrieval side is already partially built. The missing piece is the **capture side** -- automatically populating the vault as work happens.

### 6. The Memory Vault Is Small and Should Stay Curated

Current state: 8 memories, created on 2026-04-15 (today). After several months of use, the right target size is probably **50-200 memories** -- enough to cover reusable patterns across domains, not so many that relevance degrades. This is a curator's vault, not a log.

Evidence for this target: The existing 8 memories cover discrete, well-scoped knowledge (keybindings, settings, command catalog, architecture). Each is independently useful. A vault of 1000+ memories created by automatic capture would degrade signal quality and require its own indexing layer.

---

## Recommended Approach

### The Right Model: "Harvest on Archive, Preview on Demand"

Rather than modifying every lifecycle checkpoint or running hooks after every tool use, the highest-leverage, lowest-disruption design is:

**Primary Capture Point: `/todo` archive operation**

When `/todo` archives a completed task, it already scans artifacts and currently "suggests" memory harvesting. Upgrade this from a suggestion to an interactive review: present the completed task's research report and summary to the user, pre-classify segments automatically (using overlap scoring), and let the user approve/reject with one multiSelect interaction. This is already partially described in `knowledge-capture-usage.md`.

**Secondary Capture Point: `--remember` as a two-way flag**

The `/research N --remember` flag currently searches memories before researching. Extend it to also offer a memory creation step after research completes. User runs `/research 70 --remember` and at the end sees: "Research complete. 2 segments appear novel vs. existing memories. Create memories? [Y/n]". This requires no new commands, no new hooks, and no new infrastructure.

**Optional Tertiary Point: Stop hook for passive suggestion**

A lightweight `Stop` hook could check whether the just-completed operation was a `/research` or `/implement` and, if so, append a one-line message to the session log noting the artifacts available for `/learn`. This is passive (no writes, no interaction) and nudges the user toward manual harvesting.

### What to Avoid

**Do not do fully automatic background capture**. Reasons:
1. It conflicts with the existing mandatory-interactive philosophy of skill-memory
2. The shared vault (OpenCode) creates write-race risks
3. The quality of automatic memory is lower than curated memory -- the vault will fill with low-value fragments
4. Adding hooks to every lifecycle checkpoint adds fragility and maintenance burden to every future command

**Do not use "lazy learning" (capture after 2+ occurrences)**. This requires a pattern-matching layer that tracks when the same content appears across sessions. The vault has no deduplication index suited to this. The MCP/grep overlap scoring already serves this purpose at creation time.

### The Right Balance

After 6 months, a well-functioning system should have:
- **50-150 memories** organized across 5-8 topic areas (agent-system/, epi/, grant/, zed/, python/, r/, typst/, latex/)
- **Every research report with novel findings** converted to 1-3 memories via `/learn --task N` (currently manual but low-friction)
- **Retrieval influencing behavior 20-40% of research operations** via `--remember` flag
- **Zero low-quality automatic captures** -- every memory was reviewed before creation

The ideal is not "the agent remembers everything" but "the agent has a well-curated reference library that grows as the author's domain expertise grows."

---

## Evidence and Examples

### Evidence for "Harvest on Archive" as Primary Capture

The `/todo` skill already includes this language:
> "Suggests memory harvest from completed task artifacts"
> "suggests reviewing implementation for additional memories"

The infrastructure to do this exists. It just needs upgrading from a passive suggestion to an active interactive review.

### Evidence for Hook-Based Approach Feasibility

The `SubagentStop` hook demonstrates that meaningful work can be done at lifecycle checkpoints. The `Stop` hook demonstrates passive notification without blocking. A memory-suggestion hook at `Stop` would be:
- Non-blocking (echo only, no writes)
- Idempotent (same message regardless of how many times it fires)
- Reversible (easy to remove if unwanted)

### Evidence Against Automatic Background Capture

The `skill-memory` SKILL.md explicitly labels autonomous operation a "critical failure." This reflects experience: automatic memory systems without user review produce noisy, redundant, or misleading knowledge over time. The 8 existing memories are all high-quality precisely because they were manually curated.

### Evidence for the Right Vault Size

The current 8 memories represent a complete conceptual map of the system's core knowledge (settings, keybindings, architecture, commands, toolchain). Adding 50-150 domain-specific memories (epi study design patterns, grant writing structures, R analysis workflows) would complete the knowledge base without inflating it.

---

## Confidence Level

**Strategic direction (harvest-on-archive + search-augmented retrieval): High**
The existing system already points this direction. The missing piece is upgrading `/todo` to make memory harvesting interactive rather than merely suggested, and making `--remember` a two-way flag.

**Hook-based passive suggestion at Stop: Medium**
This is technically proven (hooks work) but the value is uncertain -- the user may find the suggestions useful or may find them noise. Worth trying as a low-cost addition.

**Automatic background capture (rejected): High confidence in rejection**
The shared vault constraint, the existing interactive-requirement philosophy, and the quality-over-quantity goal all argue strongly against fully automatic capture. This should not be built.

**Target vault size (50-150 memories after 6 months): Medium**
This is an informed estimate based on domain breadth (8 domains x 10-20 core patterns each). The actual number will depend on how frequently the author uses `/learn --task N` after completing tasks.
