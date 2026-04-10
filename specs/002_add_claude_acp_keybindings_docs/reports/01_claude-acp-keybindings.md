# Research Report: Task #2

**Task**: 2 - Add Claude ACP keybindings docs
**Started**: 2026-04-10T00:00:00Z
**Completed**: 2026-04-10T00:30:00Z
**Effort**: Small (research only)
**Dependencies**: None
**Sources/Inputs**:
- Codebase: `keymap.json`, `docs/keybindings.md`, `docs/agent-system.md`, `settings.json`
- Web: Zed official docs (agent-panel, inline-assistant, external-agents, edit-prediction, all-actions, agent-settings)
- Web: GitHub issues (zed-industries/zed#49574, #8714)
**Artifacts**:
- `specs/002_add_claude_acp_keybindings_docs/reports/01_claude-acp-keybindings.md`
**Standards**: report-format.md, artifact-management.md

## Executive Summary

- Zed has extensive agent panel keybindings across four categories: panel management, thread navigation, message editing, and model/profile management.
- The existing `docs/keybindings.md` covers only 4 agent shortcuts (Ctrl+?, Ctrl+N, Ctrl+Enter, Ctrl+;). The full set includes 20+ keybindings.
- The existing `docs/agent-system.md` has minimal shortcut coverage (4 shortcuts in the "How to use it" section).
- This repo uses `base_keymap: "VSCode"` on Linux, so all shortcuts documented below use the Linux/VSCode variants.
- Claude ACP (external agent) can be bound to a custom shortcut via `agent::NewExternalAgentThread` but has no default keybinding.
- Edit predictions (AI-powered code completion) have their own set of keybindings that should also be documented.

## Context & Scope

Research scope: identify ALL keybindings for AI/agent features in Zed editor on Linux with VSCode base keymap, focusing on the agent panel (Claude ACP provider), inline assist, edit predictions, and external agents. The goal is to provide a complete reference for updating `docs/keybindings.md` and/or `docs/agent-system.md`.

**Important context**: This repo's `keymap.json` overrides `ctrl-?` from `agent::ToggleFocus` to `workspace::ToggleRightDock`. Since the agent panel lives in the right dock, this still opens/closes the agent panel, but the action is different (it toggles the entire right dock, not agent focus specifically).

## Findings

### Category 1: Agent Panel -- Opening and Focus

| Shortcut (Linux) | Action | Notes |
|-------------------|--------|-------|
| `Ctrl+?` | Toggle right dock (custom) / Toggle agent focus (default) | Custom override in this repo; default is `agent::ToggleFocus` |
| `Ctrl+Shift+A` | Open agent panel | Alternative way to open (undocumented in this repo) |
| Command Palette: `agent: new thread` | Create and open new thread | No default keybinding |
| Sparkle icon in status bar | Open agent panel | GUI-only |

### Category 2: Agent Panel -- Thread Management

| Shortcut (Linux) | Action | Notes |
|-------------------|--------|-------|
| `Shift+Alt+J` | Recent threads menu | Jump to recent conversations |
| `Ctrl+Shift+H` | View all thread history | Full history browser |
| `Ctrl+Shift+R` | Review changes | Opens diff view of agent changes |
| `Double-Enter` | Send queued message immediately | Interrupts current generation |

### Category 3: Agent Panel -- Message Editor

| Shortcut (Linux) | Action | Notes |
|-------------------|--------|-------|
| `Enter` | Send message | Default; `Ctrl+Enter` if `use_modifier_to_send` is enabled |
| `Shift+Alt+Escape` | Expand message editor | Full-size editor for longer prompts |
| `Ctrl+>` | Add selection to thread | Select text in buffer first, then use this to add as context |
| `Ctrl+Shift+V` | Paste raw text | Pastes without formatting |

### Category 4: Agent Panel -- Thread Navigation (when thread pane focused)

| Shortcut (Linux) | Action | Notes |
|-------------------|--------|-------|
| Arrow keys | Scroll thread | Basic navigation |
| `Page Up` / `Page Down` | Scroll by page | |
| `Home` / `End` | Jump to top/bottom | |
| `Shift+Page Up` / `Shift+Page Down` | Jump between messages | |

### Category 5: Agent Panel -- Thread Navigation (when message editor focused)

| Shortcut (Linux) | Action | Notes |
|-------------------|--------|-------|
| `Ctrl+Alt+Home` | Navigate to thread top | |
| `Ctrl+Alt+End` | Navigate to thread bottom | |
| `Ctrl+Alt+Page Up` | Jump to previous message | |
| `Ctrl+Alt+Page Down` | Jump to next message | |
| `Ctrl+Alt+Shift+Page Up` | Jump to previous prompt | |
| `Ctrl+Alt+Shift+Page Down` | Jump to next prompt | |
| `Ctrl+Alt+Up` | Scroll thread up | |
| `Ctrl+Alt+Down` | Scroll thread down | |

### Category 6: Agent Panel -- Model and Profile Management

| Shortcut (Linux) | Action | Notes |
|-------------------|--------|-------|
| `Ctrl+Alt+/` | Toggle model selector | Switch between language models |
| `Alt+L` | Cycle favorite models | Quick-cycle without opening selector |
| `Ctrl+Alt+P` | Manage profiles | Open profile management |
| `Shift+Tab` | Cycle profiles | Quick-cycle through profiles |

### Category 7: Inline Assist

| Shortcut (Linux) | Action | Notes |
|-------------------|--------|-------|
| `Ctrl+Enter` | Open inline assistant | Select text first, then trigger; works in editors, terminal, rules library |
| Custom binding possible | Inline assist with prefilled prompt | e.g., `"ctrl-shift-enter": ["assistant::InlineAssist", {"prompt": "..."}]` |

### Category 8: Edit Predictions (AI Code Completion)

| Shortcut (Linux) | Action | Notes |
|-------------------|--------|-------|
| `Tab` | Accept edit prediction | Default when no conflict (no completions menu, correct indentation) |
| `Alt+L` | Accept edit prediction | Used when Tab conflicts (completions menu visible, indentation context); Linux default since `Alt+Tab` is window manager shortcut |
| `Alt+]` | Next edit prediction | Cycle through alternatives |
| `Alt+[` | Previous edit prediction | Cycle through alternatives |

### Category 9: External Agents (Claude ACP)

| Shortcut (Linux) | Action | Notes |
|-------------------|--------|-------|
| No default binding | Open new Claude ACP thread | Must be custom-bound |
| Suggested: `Ctrl+Alt+C` | `agent::NewExternalAgentThread` with `claude-acp` | Example from Zed docs |
| Command Palette: `dev: open acp logs` | Debug ACP communication | For troubleshooting |

### Existing Documentation Gaps

**`docs/keybindings.md`** currently documents:
- `Ctrl+?` -- toggle right sidebar (agent panel) -- correct
- `Ctrl+N` -- new conversation (in agent panel) -- **potentially outdated**: Zed docs no longer mention `Ctrl+N` as the default for new threads; the action is `agent::NewThread` but may not have a default binding in current Zed versions
- `Ctrl+Enter` -- send message -- correct, but note this is also the inline assist trigger
- `Ctrl+;` -- inline assist -- **potentially outdated**: current Zed docs show `Ctrl+Enter` for inline assist, not `Ctrl+;`

**`docs/agent-system.md`** currently documents:
- `Ctrl+?` to open -- correct
- `Ctrl+N` for new conversation -- see note above
- `Ctrl+Enter` to send -- correct
- `Ctrl+;` for inline assist -- see note above

### Key Discrepancy: Ctrl+; vs Ctrl+Enter for Inline Assist

The existing docs in this repo reference `Ctrl+;` for inline assist. However, current Zed documentation consistently shows `Ctrl+Enter` as the inline assist trigger. This may indicate:
1. `Ctrl+;` was a previous default that changed in a Zed update
2. `Ctrl+;` is a custom binding that was never added to `keymap.json`
3. The binding varies by base keymap

**Recommendation**: Verify by testing in the editor or checking the keymap editor (`Ctrl+K Ctrl+S`). Update docs to match actual behavior.

### Key Discrepancy: Ctrl+N for New Thread

Similarly, `Ctrl+N` for "new conversation" is documented in this repo but not confirmed in current Zed official docs. In global context, `Ctrl+N` creates a new file. It may work when the agent panel is focused (context-dependent binding), but this should be verified.

## Decisions

- Document Linux/VSCode keybindings only (matches this repo's configuration)
- Group keybindings by functional category for clarity
- Flag `Ctrl+;` and `Ctrl+N` discrepancies for verification before updating docs
- Include edit prediction shortcuts since they are AI-powered features
- Include external agent (Claude ACP) custom binding instructions

## Recommendations

1. **Update `docs/keybindings.md`**: Expand the "How do I use the AI agent?" section with all categories identified above. Add subsections for thread navigation, model management, and edit predictions.

2. **Update `docs/agent-system.md`**: Add a "Keybindings Quick Reference" section or expand the existing shortcut list to include thread management, model switching, and profile cycling.

3. **Verify before implementing**: Test `Ctrl+;` and `Ctrl+N` in the actual editor to confirm current behavior. Update or remove stale bindings.

4. **Consider adding Claude ACP custom binding**: Add `Ctrl+Alt+C` for `agent::NewExternalAgentThread` with `claude-acp` to `keymap.json` for quick access to Claude-specific threads.

5. **Document `use_modifier_to_send` setting**: Note in docs that `Ctrl+Enter` behavior for sending messages depends on the `agent.use_modifier_to_send` setting (currently not set in `settings.json`, so `Enter` sends by default).

## Risks & Mitigations

- **Stale keybindings**: Zed updates frequently and keybindings may change. Mitigation: date-stamp the keybindings section and note that users should check `Ctrl+K Ctrl+S` for current bindings.
- **Context-dependent bindings**: Some shortcuts only work when specific panels are focused. Mitigation: clearly note the context requirement for each binding.
- **Platform differences**: macOS uses Cmd where Linux uses Ctrl. Mitigation: document Linux-only since this is a Linux setup.

## Context Extension Recommendations

- **Topic**: Zed agent panel keybindings
- **Gap**: No context file documenting Zed-specific keybindings or agent panel interactions
- **Recommendation**: After implementation, the updated `docs/keybindings.md` will serve as the authoritative reference; no separate context file needed.

## Appendix

### Search Queries Used
- "Zed editor agent panel keybindings shortcuts 2026"
- "Zed editor inline assist keybindings ctrl+semicolon agent shortcuts 2026"
- "Zed editor ctrl+n new thread agent panel ctrl+enter send message keybindings"
- "Zed editor agent::ToggleFocus default keybinding Linux"
- "Zed editor edit predictions keybindings tab accept shortcut"

### References
- [Zed Agent Panel Documentation](https://zed.dev/docs/ai/agent-panel)
- [Zed Inline Assistant Documentation](https://zed.dev/docs/ai/inline-assistant)
- [Zed External Agents Documentation](https://zed.dev/docs/ai/external-agents)
- [Zed Edit Prediction Documentation](https://zed.dev/docs/ai/edit-prediction)
- [Zed All Actions Reference](https://zed.dev/docs/all-actions)
- [Zed Agent Settings](https://zed.dev/docs/ai/agent-settings)
- [Zed Key Bindings Documentation](https://zed.dev/docs/key-bindings)
- [GitHub Issue #49574 - Agent panel shortcut confusion](https://github.com/zed-industries/zed/issues/49574)
- [GitHub Issue #8714 - Change default binding for assistant::ToggleFocus](https://github.com/zed-industries/zed/issues/8714)
