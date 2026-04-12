---
name: No RESEARCHED status without research artifacts
description: Tasks should not be marked RESEARCHED unless actual research report files exist and are linked
type: feedback
---

Do not set task status to [RESEARCHED] unless actual research report files have been created and linked in TODO.md. The /meta interview context does not count as a research artifact.

**Why:** RESEARCHED status implies research reports exist in the task directory. Setting this status without artifacts creates an inconsistency — the status promises artifacts that don't exist.

**How to apply:** Tasks created via /meta should start at [NOT STARTED]. They follow the normal /research -> /plan -> /implement lifecycle.
