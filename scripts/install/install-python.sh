#!/usr/bin/env bash
# install-python.sh - Python toolchain
#
# Mirrors docs/toolchain/python.md:
#   Core:    python (brew), uv (brew), ruff (brew)
#   Tools:   pytest, mypy, ipython (uv tool install)
#   Filetypes packages (pip3): pandas openpyxl python-pptx python-docx
#                              markitdown xlsx2csv pymupdf pdfannots
#
# Flags: --dry-run --yes --check --help
# Idempotent: every install guarded by presence check.

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

print_help() {
  cat >&2 <<'EOF'
install-python.sh - Python toolchain

Installs:
  Core (Homebrew):
    - python (python3)
    - uv (package manager; provides uvx)
    - ruff (linter/formatter)
  Optional sub-groups (prompted):
    - uv tools: pytest, mypy, ipython
    - filetypes packages (pip3): pandas openpyxl python-pptx python-docx
                                 markitdown xlsx2csv pymupdf pdfannots
EOF
  print_common_help_footer
}

do_core() {
  if ! check_command python3; then
    brew_install_formula python
  else
    log_ok "python3 already installed: $(python3 --version 2>&1)"
  fi
  if ! check_command uv; then
    brew_install_formula uv
  else
    log_ok "uv already installed: $(uv --version 2>&1)"
  fi
  if ! check_command ruff; then
    brew_install_formula ruff
  else
    log_ok "ruff already installed: $(ruff --version 2>&1)"
  fi
}

do_uv_tools() {
  if ! check_command uv; then
    log_warn "uv missing; skipping uv tool installs"
    return 0
  fi
  if ! prompt_yn "Install uv tools (pytest, mypy, ipython)?"; then
    log_info "skipping uv tool installs"
    return 0
  fi
  local tool
  for tool in pytest mypy ipython; do
    if uv_tool_installed "$tool"; then
      log_ok "uv tool already installed: $tool"
    else
      run_or_dry uv tool install "$tool"
    fi
  done
}

FILETYPES_PKGS="pandas openpyxl python-pptx python-docx markitdown xlsx2csv pymupdf pdfannots"

do_filetypes_packages() {
  if ! check_command python3; then
    log_warn "python3 missing; skipping filetypes packages"
    return 0
  fi
  if python3 -c "import pandas, openpyxl, pptx, docx, markitdown, fitz, pdfannots" \
       >/dev/null 2>&1; then
    log_ok "filetypes python packages already importable"
    return 0
  fi
  if ! prompt_yn "Install filetypes Python packages (pandas, pptx, markitdown, ...)?"; then
    log_info "skipping filetypes packages"
    return 0
  fi
  # shellcheck disable=SC2086
  run_or_dry pip3 install $FILETYPES_PKGS
}

run_check_mode() {
  local missing=0
  check_command python3 && log_ok "python3" || { log_warn "[missing] python3"; missing=1; }
  check_command uv      && log_ok "uv"      || { log_warn "[missing] uv"; missing=1; }
  check_command uvx     && log_ok "uvx"     || { log_warn "[missing] uvx"; missing=1; }
  check_command ruff    && log_ok "ruff"    || { log_warn "[missing] ruff"; missing=1; }
  if check_command python3 && python3 -c "import pandas, openpyxl, pptx, docx, markitdown, fitz" \
       >/dev/null 2>&1; then
    log_ok "filetypes-packages"
  else
    log_warn "[missing] filetypes-packages (pandas, openpyxl, ...)"
    missing=1
  fi
  return "$missing"
}

main() {
  parse_common_flags "$@"
  if [ "$SHOW_HELP" = "1" ]; then print_help; exit 0; fi
  assert_macos
  print_section "install-python: python, uv, ruff + optional tools"

  if [ "$CHECK_MODE" = "1" ]; then
    run_check_mode
    exit $?
  fi

  require_brew

  do_core
  do_uv_tools
  do_filetypes_packages

  log_info "install-python finished."
}

main "$@"
