#!/usr/bin/env bash
# Wrapper for slidev export on NixOS.
#
# Playwright's bundled Chromium is dynamically linked against system
# libraries that NixOS does not provide at standard paths. This script
# resolves a nix-built Chromium from playwright-driver.browsers and
# passes it via --executable-path so the export succeeds without
# patching or nix-ld.
#
# Usage: slidev-export.sh <slides.md> [extra slidev export flags...]

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: slidev-export.sh <slides.md> [extra slidev export flags...]" >&2
  exit 1
fi

entry="$1"
shift

# Resolve the nix playwright browsers path (cached after first build).
BROWSERS_PATH="$(nix build nixpkgs#playwright-driver.browsers --no-link --print-out-paths 2>/dev/null)"

if [ -z "$BROWSERS_PATH" ]; then
  echo "error: could not resolve playwright-driver.browsers from nixpkgs" >&2
  echo "hint:  ensure nixpkgs is available (nix-channel or flake)" >&2
  exit 1
fi

# Find the chromium binary. Match any revision directory.
CHROME="$(find "$BROWSERS_PATH"/chromium-*/chrome-linux64 -name chrome -type f 2>/dev/null | head -1)"

if [ -z "$CHROME" ] || [ ! -x "$CHROME" ]; then
  echo "error: chromium binary not found in $BROWSERS_PATH" >&2
  exit 1
fi

exec slidev export "$entry" --executable-path "$CHROME" "$@"
