# Teammate B Findings: Alternative Patterns and Prior Art

**Task**: 34 — Improve Slidev review pipeline
**Focus**: Alternative verification approaches, template scaffolding patterns, pre-flight validation

---

## Key Findings

### 1. Template Scaffolding — Prior Art Already Exists

The `playwright-verify.mjs` template in `.claude/context/project/present/talk/templates/` demonstrates the established pattern for providing starter files:

- A ready-to-copy file lives in the context library
- The pitfalls doc (`slidev-pitfalls.md`) tells the implementation agent to copy it during the verification phase
- The plan template says explicitly: "Copy `talk/templates/playwright-verify.mjs` to `scripts/verify-slides.mjs`"

**This exact pattern should be extended to project scaffolding files** (`package.json`, `.npmrc`, `vite.config.ts`, `lz-string-esm.js`). The real files already exist in `examples/epi-slides/` and can serve directly as templates.

The precedent from the talk library (content templates in `talk/contents/`, patterns in `talk/patterns/`, one template script in `talk/templates/`) suggests a natural home: `talk/templates/scaffold/` for the four project files.

### 2. Alternative to Playwright — Vite/Slidev Build-Time Checks

Playwright is a heavyweight, browser-level check that catches render-time errors. Lighter alternatives exist:

**`slidev build` as first-pass validator**: The build command (`npx @slidev/cli build`) runs Vite compilation and will surface CJS/ESM errors, missing components, and syntax failures without launching a browser. It's faster and catches the majority of the six issue classes:

| Issue | `slidev build` catches? | Playwright needed? |
|-------|------------------------|--------------------|
| lz-string CJS/ESM crash | Yes (Vite bundling error) | No |
| CLI version mismatch | Partially (if build also uses wrong version) | No |
| Shiki inline code dark backgrounds | No (visual only) | Yes (screenshot) |
| Vue component in pipe tables | Partially (Vue compile errors) | Yes (silent failures) |
| `<br/>` in mermaid consumed | No (silently broken) | Yes |
| `npx slidev` wrong package name | Yes (command fails) | No |

**Recommendation**: Add a `pnpm run build` step before the Playwright phase. It catches the crashers cheaply, so Playwright focuses on visual/silent failures.

**Vite plugin hooks**: Vite plugins (`vite.config.ts`) can add custom `transform` hooks that inspect markdown content at build time. However, writing a custom Vite plugin adds complexity beyond the task scope; this is a future option, not a current recommendation.

**Slidev `doctor` command**: As of Slidev v0.49–v52, there is no official `slidev doctor` or `slidev check` subcommand. The build command is the closest equivalent.

### 3. Pre-flight Validation — Lightweight, No Browser Required

A shell-based pre-flight script can check several issues before `pnpm install` even runs:

```bash
# Check 1: .npmrc has shamefully-hoist
grep -q "shamefully-hoist=true" .npmrc || echo "MISSING: .npmrc shamefully-hoist"

# Check 2: lz-string-esm.js exists
[ -f lz-string-esm.js ] || echo "MISSING: lz-string-esm.js ESM shim"

# Check 3: vite.config.ts aliases lz-string
grep -q "lz-string" vite.config.ts || echo "MISSING: vite.config.ts lz-string alias"

# Check 4: package.json uses @slidev/cli not slidev
grep -q '"@slidev/cli"' package.json || echo "WARNING: package.json should use @slidev/cli"

# Check 5: scripts in package.json use npx @slidev/cli not npx slidev
grep -q '"npx slidev"' package.json && echo "BUG: use 'npx @slidev/cli' not 'npx slidev'"

# Check 6: mermaid slides - check for <br/> in mermaid blocks
python3 -c "
import re, sys
txt = open('slides.md').read()
mermaid_blocks = re.findall(r'\`\`\`mermaid(.*?)\`\`\`', txt, re.DOTALL)
for b in mermaid_blocks:
    if '<br' in b:
        print('BUG: <br/> found in mermaid block -- use \\\\n instead')
        sys.exit(1)
"
```

This pre-flight runs in milliseconds and catches 4 of the 6 issue classes before any browser launch. It belongs either in the implementation plan as a checklist item or as a standalone `scripts/preflight.sh` that can be run early.

### 4. lz-string ESM Alternative

The current approach (copy source + replace UMD footer) works but is fragile. Alternatives:

- **`lz-string` npm package v1.5.0**: The package has no official ESM export. The shim approach is currently the only viable option for this version.
- **`fflate`**: A modern compression library with full ESM support. Slidev uses `lz-string` internally (in `@slidev/parser`), so swapping would require patching Slidev internals — not feasible.
- **`@slidev/cli` v0.50+**: Slidev has been actively updating its ESM handling. Version pinning in `package.json` to a known-good version (e.g., `52.14.2` as in epi-slides) is the practical mitigation. The shim remains necessary until Slidev ships a native ESM export of lz-string or replaces it.

**Conclusion**: The ESM shim (`lz-string-esm.js` + `vite.config.ts` alias) is currently the right approach. It should be a template file, not authored per-project.

### 5. Error Classification by Detection Layer

Organizing the six issues by detection layer clarifies what each phase catches:

| Layer | Timing | Issues Caught |
|-------|--------|---------------|
| Pre-flight (shell script) | Before `pnpm install` | .npmrc missing, lz-string-esm.js missing, wrong npx command |
| `pnpm install` + `slidev build` | Before any Playwright | lz-string ESM crash, CLI version mismatch, major Vue compile errors |
| Playwright visual check | After build | Shiki inline code dark backgrounds, `<br/>` in mermaid, silent Vue/table failures |

This three-layer model improves feedback speed: most errors are caught in the first two layers without needing a browser.

### 6. How Other Extensions Handle Templates

Looking at the epi extension (R analysis) and the present extension:
- The epi extension provides no project templates (it operates on existing R projects)
- The present extension provides one template: `playwright-verify.mjs`
- Content templates (`talk/contents/`) are reference patterns, not copy-to-project files

The pattern for copy-to-project files is: store in `talk/templates/`, reference the path explicitly in `slidev-pitfalls.md` and the plan phase template. The implementation agent follows the instruction to copy them.

**The slides agent (`slides-agent.md`) does not currently include any scaffolding step** — it is a research/synthesis agent. The scaffolding responsibility falls to the implementation phase, which is guided by the plan. The plan template (in `slidev-pitfalls.md`) is where copy-file instructions live.

---

## Recommended Approach

**A two-pronged addition, not a replacement of Playwright**:

1. **Add a project scaffold template directory** at `.claude/context/project/present/talk/templates/scaffold/` containing the four files (`package.json`, `.npmrc`, `vite.config.ts`, `lz-string-esm.js`). Reference these in `slidev-pitfalls.md` under "Project Setup". The implementation plan template should instruct the agent to copy all four files at the start of Phase 1.

2. **Add a `slidev build` step before Playwright** in the verification phase template. Update `playwright-verify.mjs` to also check `console.error` calls (not just `pageerror` events), since silent Vue component failures surface in console errors rather than throwing page errors.

The pre-flight shell checks are valuable but may be overkill as a separate script — they can instead become a preflight checklist in the plan phase template (human-readable, verified by the agent running the build).

---

## Evidence / Examples

- Template pattern precedent: `/home/benjamin/.config/zed/.claude/context/project/present/talk/templates/playwright-verify.mjs` (lines 1-123)
- Existing working scaffold: `/home/benjamin/.config/zed/examples/epi-slides/` (`.npmrc`, `vite.config.ts`, `lz-string-esm.js`, `package.json`)
- Plan phase template with copy instruction: `/home/benjamin/.config/zed/.claude/context/project/present/talk/patterns/slidev-pitfalls.md` (lines 62-93)
- `slidev build` as cheap first check: The `package.json` in epi-slides has a `"build": "slidev build"` script that can be run with `pnpm run build`
- Playwright script current gaps: `playwright-verify.mjs` line 67 uses `page.on('pageerror', ...)` which catches thrown JS errors but not `console.error` calls from silent Vue component failures

---

## Confidence Level

**High** for:
- Template scaffolding approach (direct extension of existing pattern)
- Adding `slidev build` before Playwright (already in package.json, no new tooling)
- Updating `playwright-verify.mjs` to capture `console.error` (minor script change)

**Medium** for:
- The three-layer error classification model (practical but somewhat arbitrary)
- lz-string shim permanence (depends on Slidev upstream changes)

**Low** for:
- Vite plugin hooks as a future validation approach (not investigated in depth)
