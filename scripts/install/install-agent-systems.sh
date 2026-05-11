#!/usr/bin/env bash
# install-agent-systems.sh - Agent system selection and install (macOS)
#
# Handles Claude Code CLI installation (via Homebrew) and OpenCode binary
# verification. Registers MCP servers for Claude Code (SuperDoc, openpyxl).
#
# This group was factored out of install-base.sh so that users can choose
# which agent system(s) to set up.
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
install-agent-systems.sh - Install and configure AI agent systems

Agent systems available:
  Claude Code   Install via Homebrew (brew install --cask claude-code)
                Registers SuperDoc + openpyxl MCP servers
  OpenCode      Verify binary is available on PATH
                Document manual setup for NixOS/Nix users

EOF
  print_common_help_footer
}

# ----- Claude Code ---------------------------------------------------------

install_claude_cli() {
  if check_command claude; then
    log_ok "claude CLI already installed"
    return 0
  fi
  if ! check_command brew; then
    log_warn "Homebrew not available; cannot install Claude Code CLI."
    log_warn "Install manually: https://code.claude.com/docs/en/setup"
    return 0
  fi
  brew_install_cask claude-code
}

install_mcp_superdoc() {
  if ! check_command claude; then
    log_warn "claude CLI not installed; skipping superdoc MCP"
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
    log_warn "claude CLI not installed; skipping openpyxl MCP"
    return 0
  fi
  if claude_mcp_has openpyxl; then
    log_ok "openpyxl MCP already registered"
    return 0
  fi
  run_or_dry claude mcp add --scope user openpyxl -- npx @jonemo/openpyxl-mcp
}

# ----- OpenCode ------------------------------------------------------------

check_opencode_binary() {
  # Check common locations for OpenCode binary.
  check_command opencode
}

verify_opencode() {
  if check_opencode_binary; then
    log_ok "opencode binary found: $(command -v opencode)"
    return 0
  fi
  log_info "OpenCode binary not found on PATH."
  log_info "On NixOS, OpenCode is typically available via your system configuration"
  log_info "or Nix profile. Check: /run/current-system/sw/bin/opencode"
  log_info "See docs/agent-system/opencode.md for setup details."
  return 0
}

# ----- check mode ----------------------------------------------------------

run_check_mode() {
  local missing=0

  print_section "Claude Code"
  check_command claude && log_ok "claude" || { log_warn "[missing] claude"; missing=1; }
  claude_mcp_has superdoc && log_ok "mcp:superdoc" || { log_warn "[missing] mcp:superdoc"; missing=1; }
  claude_mcp_has openpyxl && log_ok "mcp:openpyxl" || { log_warn "[missing] mcp:openpyxl"; missing=1; }

  print_section "OpenCode"
  if check_opencode_binary; then
    log_ok "opencode"
  else
    log_info "[not found] opencode (optional -- NixOS/Nix users install separately)"
  fi

  return "$missing"
}

# ----- main ----------------------------------------------------------------

main() {
  parse_common_flags "$@"
  if [ "$SHOW_HELP" = "1" ]; then print_help; exit 0; fi
  assert_supported_os
  print_section "install-agent-systems: AI agent system setup ($DETECTED_OS)"

  if [ "$CHECK_MODE" = "1" ]; then
    run_check_mode
    exit $?
  fi

  # Claude Code
  log_info "--- Claude Code ---"
  install_claude_cli
  install_mcp_superdoc
  install_mcp_openpyxl

  # OpenCode
  log_info "--- OpenCode ---"
  verify_opencode

  log_info "install-agent-systems finished."
  log_info "Run 'claude' to authenticate Claude Code, or 'opencode' for OpenCode."
}

main "$@"
