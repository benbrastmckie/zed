#!/usr/bin/env bash
# install-python.sh - Python toolchain (cross-platform)
#
# Core:       python3, uv, ruff
# Tools:      pytest, mypy, ipython (uv tool install)
# Filetypes:  pandas openpyxl python-pptx python-docx markitdown xlsx2csv
#             pymupdf pdfannots
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
  Core:
    - python3 (platform package manager)
    - uv (brew on macOS, curl installer on Linux)
    - ruff (brew on macOS, uv/pipx on Linux)
  Optional sub-groups (prompted):
    - uv tools: pytest, mypy, ipython
    - filetypes packages (pip3): pandas openpyxl python-pptx python-docx
                                 markitdown xlsx2csv pymupdf pdfannots
EOF
  print_common_help_footer
}

do_core() {
  # Python
  if ! check_command python3; then
    case "$DETECTED_OS" in
      macos)
        brew_install_formula python
        ;;
      debian)
        pkg_install python3
        if [ "$DRY_RUN" = "1" ]; then
          log_dry "sudo apt-get install -y python3-pip python3-venv"
        else
          sudo apt-get install -y python3-pip python3-venv 2>/dev/null || true
        fi
        ;;
      arch)
        pkg_install python3
        ;;
      *)
        log_warn "install python3 manually"
        ;;
    esac
  else
    log_ok "python3 already installed: $(python3 --version 2>&1)"
  fi

  # uv
  if ! check_command uv; then
    case "$DETECTED_OS" in
      macos)
        brew_install_formula uv
        ;;
      *)
        # Use the official curl installer on Linux.
        if [ "$DRY_RUN" = "1" ]; then
          log_dry "curl -LsSf https://astral.sh/uv/install.sh | sh"
        else
          curl -LsSf https://astral.sh/uv/install.sh | sh || \
            log_warn "uv installer failed; install manually: https://docs.astral.sh/uv/"
          # Ensure uv is on PATH for the rest of the script.
          if [ -f "$HOME/.local/bin/uv" ]; then
            export PATH="$HOME/.local/bin:$PATH"
          fi
        fi
        ;;
    esac
  else
    log_ok "uv already installed: $(uv --version 2>&1)"
  fi

  # ruff
  if ! check_command ruff; then
    case "$DETECTED_OS" in
      macos)
        brew_install_formula ruff
        ;;
      *)
        # On Linux, install ruff via uv tool or pipx.
        if check_command uv; then
          run_or_dry uv tool install ruff
        elif check_command pipx; then
          run_or_dry pipx install ruff
        else
          log_warn "install ruff manually: pip3 install ruff or uv tool install ruff"
        fi
        ;;
    esac
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
  assert_supported_os
  print_section "install-python: python, uv, ruff + optional tools ($DETECTED_OS)"

  if [ "$CHECK_MODE" = "1" ]; then
    run_check_mode
    exit $?
  fi

  require_pkg_manager

  do_core
  do_uv_tools
  do_filetypes_packages

  log_info "install-python finished."
}

main "$@"
