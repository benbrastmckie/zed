#!/usr/bin/env bash
# install-mcp-servers.sh - Extension MCP servers (rmcp, markitdown-mcp, mcp-pandoc)
#
# ============================================================================
# HARD INVARIANT — LEAN MCP RESURRECTION GUARD
# ============================================================================
# This script NEVER reads, parses, or scrapes any markdown file at runtime.
# Every MCP server entry below is hard-coded in bash. This is intentional.
#
# Lean MCP (`lean-lsp-mcp`, `mcp__lean-lsp__*`) is INTENTIONALLY ABSENT from
# this script. It was pruned from the repository in task 30 because this
# `.config/zed/` configuration is a macOS Zed IDE for R and Python, not a
# theorem-prover toolchain. See docs/toolchain/mcp-servers.md 'Lean MCP —
# pruned (decision record)' for the rationale and restore instructions.
#
# DO NOT re-add Lean MCP here without explicit user request. A script that
# scrapes markdown and mass-registers every server it finds would silently
# resurrect Lean MCP and undo the pruning decision.
# ============================================================================
#
# Mirrors docs/toolchain/mcp-servers.md (excluding obsidian-memory which is a
# print-and-skip per the plan: it requires an Obsidian desktop app install and
# manual plugin configuration that cannot be automated sensibly here):
#   - rmcp           (epidemiology R statistical modeling; uvx)
#   - markitdown-mcp (document extraction; uvx)
#   - mcp-pandoc     (universal conversion; uvx)
#
# install-base.sh already registers superdoc and openpyxl.
#
# Flags: --dry-run --yes --check --help
# Idempotent: every install guarded by presence check.

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

print_help() {
  cat >&2 <<'EOF'
install-mcp-servers.sh - Extension MCP servers

Registers (via 'claude mcp add --scope user'):
  - rmcp           (R statistical modeling for the epidemiology extension)
  - markitdown-mcp (document extraction)
  - mcp-pandoc     (universal conversion)

Pointer-only (no auto-install):
  - obsidian-memory (requires Obsidian desktop app + plugin;
                     see docs/toolchain/mcp-servers.md#obsidian-memory)

Lean MCP is INTENTIONALLY ABSENT. See the comment header in this script.
EOF
  print_common_help_footer
}

add_uvx_server() {
  # add_uvx_server <server-name> <uvx-tool-name>
  local name="$1"
  local tool="$2"
  if claude_mcp_has "$name"; then
    log_ok "MCP server already registered: $name"
    return 0
  fi
  if ! prompt_yn "Register MCP server '$name' (uvx $tool)?"; then
    log_info "skipping $name"
    return 0
  fi
  run_or_dry claude mcp add --scope user "$name" -- uvx "$tool"
}

do_rmcp() {
  if ! check_command Rscript; then
    log_warn "R not installed; rmcp requires R at runtime. Run install-r.sh first."
  fi
  if ! check_command uvx; then
    log_warn "uvx not installed; rmcp requires uvx. Run install-python.sh first."
    return 0
  fi
  add_uvx_server rmcp rmcp
}

do_markitdown_mcp() {
  if ! check_command uvx; then
    log_warn "uvx not installed; skipping markitdown-mcp"
    return 0
  fi
  add_uvx_server markitdown markitdown-mcp
}

do_mcp_pandoc() {
  if ! check_command uvx; then
    log_warn "uvx not installed; skipping mcp-pandoc"
    return 0
  fi
  add_uvx_server pandoc mcp-pandoc
}

do_obsidian_pointer() {
  if claude_mcp_has obsidian-claude-code-mcp \
     || claude_mcp_has obsidian-cli-rest-mcp; then
    log_ok "obsidian-memory MCP already registered"
    return 0
  fi
  log_info "obsidian-memory is not auto-installed."
  log_info "Setup docs: .claude/context/project/memory/memory-setup.md"
  if [ "$DRY_RUN" = "0" ] && [ "$ASSUME_YES" = "0" ] \
     && prompt_yn "Open the obsidian-memory setup guide in your default app?" default_n; then
    open .claude/context/project/memory/memory-setup.md 2>/dev/null || \
      log_warn "could not 'open' the setup doc; navigate manually"
  fi
}

run_check_mode() {
  local missing=0
  if ! check_command claude; then
    log_warn "[missing] claude CLI (cannot query MCP servers)"
    return 1
  fi
  claude_mcp_has rmcp       && log_ok "mcp:rmcp"       || { log_warn "[missing] mcp:rmcp"; missing=1; }
  claude_mcp_has markitdown && log_ok "mcp:markitdown" || { log_warn "[missing] mcp:markitdown"; missing=1; }
  claude_mcp_has pandoc     && log_ok "mcp:pandoc"     || { log_warn "[missing] mcp:pandoc"; missing=1; }
  if claude_mcp_has obsidian-claude-code-mcp || claude_mcp_has obsidian-cli-rest-mcp; then
    log_ok "mcp:obsidian-memory"
  else
    log_warn "[optional-missing] mcp:obsidian-memory (manual setup)"
  fi
  return "$missing"
}

main() {
  parse_common_flags "$@"
  if [ "$SHOW_HELP" = "1" ]; then print_help; exit 0; fi
  assert_macos
  print_section "install-mcp-servers: rmcp, markitdown, pandoc (+ obsidian pointer)"

  if [ "$CHECK_MODE" = "1" ]; then
    run_check_mode
    exit $?
  fi

  if ! check_command claude; then
    log_error "claude CLI not installed; run install-base.sh first"
    exit 3
  fi

  do_rmcp
  do_markitdown_mcp
  do_mcp_pandoc
  do_obsidian_pointer

  log_info "install-mcp-servers finished."
}

main "$@"
