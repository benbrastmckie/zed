#!/usr/bin/env bash
# install-base.sh - Base developer environment (macOS)
#
# Installs core build tools and the editor:
#   Xcode Command Line Tools, Homebrew, Node.js, Zed (cask)
#
# Note: Claude Code CLI and MCP servers have moved to install-agent-systems.sh.
#
# Flags: --dry-run --check --help
#
# Idempotent: every action is guarded by a presence check.

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

print_help() {
  cat >&2 <<'EOF'
install-base.sh - Install base developer tools (macOS)

Installs:
  - Xcode Command Line Tools
  - Homebrew
  - Node.js
  - Zed editor

Note: Claude Code CLI and MCP servers are now in install-agent-systems.sh.
EOF
  print_common_help_footer
}

# ----- macOS-specific helpers -----------------------------------------------

check_xcode_clt() {
  xcode-select -p >/dev/null 2>&1 && check_command git
}

install_xcode_clt() {
  if check_xcode_clt; then
    log_ok "Xcode Command Line Tools already installed"
    return 0
  fi
  log_warn "Xcode Command Line Tools missing — a GUI dialog will appear."
  log_warn "Click 'Install' in the dialog and wait for it to complete."
  if [ "$DRY_RUN" = "1" ]; then
    log_dry "xcode-select --install"
    return 0
  fi
  xcode-select --install 2>/dev/null || true
  printf 'Press Enter once the Xcode CLT install dialog has completed... ' >&2
  if ! read -r _ </dev/tty 2>/dev/null; then read -r _ || true; fi
  if ! check_xcode_clt; then
    log_error "Xcode CLT still not detected; see docs/general/installation.md"
    return 4
  fi
}

install_homebrew() {
  if check_command brew; then
    log_ok "Homebrew already installed"
    return 0
  fi
  log_info "installing Homebrew via its official bootstrap script"
  if [ "$DRY_RUN" = "1" ]; then
    log_dry '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    return 0
  fi
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if ! check_command brew; then
    # Common post-install PATH additions for Apple Silicon / Intel.
    if [ -x /opt/homebrew/bin/brew ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  fi
  if ! check_command brew; then
    log_error "brew not found after install — restart your terminal and re-run"
    return 4
  fi
}

# ----- install functions ----------------------------------------------------

install_build_tools() {
  install_xcode_clt
}

install_pkg_manager() {
  install_homebrew
}

install_node() {
  if check_command node; then
    log_ok "node already installed: $(node --version)"
    return 0
  fi
  brew_install_formula node
}

install_zed() {
  if check_app_bundle "Zed.app" || check_brew_cask zed; then
    log_ok "Zed already installed"
    return 0
  fi
  brew_install_cask zed
}

run_check_mode() {
  local missing=0
  check_xcode_clt && log_ok "xcode-clt" || { log_warn "[missing] xcode-clt"; missing=1; }
  check_command brew && log_ok "brew" || { log_warn "[missing] brew"; missing=1; }
  check_command node   && log_ok "node"   || { log_warn "[missing] node"; missing=1; }
  check_command zed    && log_ok "zed"    || { check_app_bundle "Zed.app" && log_ok "zed" || { log_warn "[missing] zed"; missing=1; }; }
  return "$missing"
}

main() {
  parse_common_flags "$@"
  if [ "$SHOW_HELP" = "1" ]; then print_help; exit 0; fi
  assert_supported_os
  print_section "install-base: base developer environment ($DETECTED_OS)"

  if [ "$CHECK_MODE" = "1" ]; then
    run_check_mode
    exit $?
  fi

  install_build_tools
  install_pkg_manager
  install_node
  install_zed

  log_info "install-base finished. Run install-agent-systems.sh next to set up Claude Code and/or OpenCode."
}

main "$@"
