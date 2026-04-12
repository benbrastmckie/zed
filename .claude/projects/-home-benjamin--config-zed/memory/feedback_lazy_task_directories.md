---
name: Lazy task directory creation
description: Task directories should only be created when artifacts are generated, not at task creation time
type: feedback
---

Do not create task directories (specs/{NNN}_{SLUG}/) at task creation time. Directories should be created lazily — only when an artifact (research report, plan, summary) actually needs to be written.

**Why:** Creating empty directories is premature. The /meta command should only update TODO.md and state.json when creating tasks, not pre-create filesystem structure.

**How to apply:** During /meta task creation, skip `mkdir` for task directories. Only create them during /research, /plan, or /implement when writing actual files.
