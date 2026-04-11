#!/usr/bin/env bash
# install-base.sh - Base macOS developer environment
#
# Installs everything in docs/general/installation.md:
#   - Xcode Command Line Tools (git, make, compilers)
#   - Homebrew
#   - Node.js (required by SuperDoc / openpyxl MCP, Slidev)
#   - Zed (cask)
#   - Claude Code CLI (cask)
#   - SuperDoc + openpyxl MCP servers (claude mcp add --scope user)
#
# Flags: --dry-run --yes --check --help
#
# Idempotent: every action is guarded by a presence check.

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

print_help() {
  cat >&2 <<'EOF'
install-base.sh - Install base macOS developer tools

Installs:
  - Xcode Command Line Tools (prints GUI handoff prompt if missing)
  - Homebrew
  - Node.js (brew formula)
  - Zed (brew cask)
  - Claude Code CLI (brew cask)
  - SuperDoc MCP server (claude mcp add, user scope)
  - openpyxl MCP server (claude mcp add, user scope)
EOF
  print_common_help_footer
}

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
  if [ "$ASSUME_YES" = "0" ]; then
    printf 'Press Enter once the Xcode CLT install dialog has completed... ' >&2
    if ! read -r _ </dev/tty 2>/dev/null; then read -r _ || true; fi
  fi
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

install_claude_cli() {
  if check_command claude; then
    log_ok "claude CLI already installed"
    return 0
  fi
  brew_install_cask claude-code
}

install_mcp_superdoc() {
  if ! check_command claude; then
    log_warn "claude CLI not installed yet; skipping superdoc MCP"
    return 0
  fi
  if claude_mcp_has superdoc; then
    log_ok "superdoc MCP already registered"
    return 0
  fi
  run_or_dry claude mcp add --scope user superdoc -- npx @superdoc-dev/mcp
}

install_mcp_openpyxl() {
  if ! check_command claude; then
    log_warn "claude CLI not installed yet; skipping openpyxl MCP"
    return 0
  fi
  if claude_mcp_has openpyxl; then
    log_ok "openpyxl MCP already registered"
    return 0
  fi
  run_or_dry claude mcp add --scope user openpyxl -- npx @jonemo/openpyxl-mcp
}

run_check_mode() {
  local missing=0
  check_xcode_clt   && log_ok "xcode-clt"   || { log_warn "[missing] xcode-clt"; missing=1; }
  check_command brew   && log_ok "brew"     || { log_warn "[missing] brew"; missing=1; }
  check_command node   && log_ok "node"     || { log_warn "[missing] node"; missing=1; }
  { check_app_bundle "Zed.app" || check_brew_cask zed; } \
    && log_ok "zed" || { log_warn "[missing] zed"; missing=1; }
  check_command claude && log_ok "claude"   || { log_warn "[missing] claude"; missing=1; }
  claude_mcp_has superdoc && log_ok "mcp:superdoc" || { log_warn "[missing] mcp:superdoc"; missing=1; }
  claude_mcp_has openpyxl && log_ok "mcp:openpyxl" || { log_warn "[missing] mcp:openpyxl"; missing=1; }
  return "$missing"
}

main() {
  parse_common_flags "$@"
  if [ "$SHOW_HELP" = "1" ]; then print_help; exit 0; fi
  assert_macos
  print_section "install-base: macOS base developer environment"

  if [ "$CHECK_MODE" = "1" ]; then
    run_check_mode
    exit $?
  fi

  install_xcode_clt
  install_homebrew
  install_node
  install_zed
  install_claude_cli
  install_mcp_superdoc
  install_mcp_openpyxl

  log_info "install-base finished. Run 'claude' in your terminal to authenticate."
}

main "$@"
