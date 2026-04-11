# Slidev

[Slidev](https://sli.dev) is a markdown-based presentation framework. It is used by the `present` extension for building research talks from markdown source files.

## Slidev CLI

### Check

```
command -v slidev && slidev --version
```

If this prints a version (e.g. `52.14.2`), skip to [Playwright](#playwright).

### Install

```
npm install -g @slidev/cli
```

Requires Node.js — see [docs/general/installation.md#install-nodejs](../general/installation.md#install-nodejs).

### Verify

```
slidev --version
```

## Playwright

Slidev PDF export (`slidev export`) uses [Playwright](https://playwright.dev) to launch a headless Chromium browser. On first export, Playwright automatically downloads Chromium — no manual install needed.

### Check

```
npx playwright install --dry-run chromium 2>&1
```

If Chromium is already cached, this completes instantly. If not, the first `slidev export` will download it (~150 MB).

### Install

Playwright manages its own browser downloads. If you want to pre-download:

```
npx playwright install chromium
```

### Verify

```
slidev export examples/epi-slides/slides.md
ls examples/epi-slides/slides-export.pdf
```

## Zed integration

Two Zed tasks (in `.zed/tasks.json`) expose Slidev from the editor:

| Task | Keybinding | What it does |
|------|------------|--------------|
| Slidev Preview | Alt+Shift+P | `slidev --open $ZED_FILE` — dev server + browser |
| Slidev Export PDF | Alt+Shift+E | `slidev export $ZED_FILE` — headless PDF export |

Both are bound in the Editor context in `keymap.json`.

## See also

- [extensions.md#present](extensions.md#present) — present extension prerequisites
- [docs/general/keybindings.md](../general/keybindings.md) — keybinding reference
- [sli.dev/guide/exporting](https://sli.dev/guide/exporting) — upstream Slidev export docs
