#!/usr/bin/env bash
# install-r.sh - R toolchain (macOS)
#
# Core:       R, languageserver, lintr, styler
# renv:       install.packages("renv")
# Quarto:     brew cask
# Epi bundle: broader list of R packages for the epidemiology extension
#
# All install.packages() calls force the cloud CRAN mirror to skip interactive
# mirror-selection prompts.
#
# Flags: --dry-run --check --help
# Idempotent: every install guarded by presence check.

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

CRAN_REPO="https://cloud.r-project.org"

print_help() {
  cat >&2 <<'EOF'
install-r.sh - R toolchain (macOS)

Installs:
  Core:
    - R (Homebrew)
    - languageserver, lintr, styler (install.packages via Rscript)
  Optional sub-groups (prompted):
    - renv    (project-local package manager)
    - Quarto  (brew cask)
    - Epi bundle (broader R packages for the epidemiology extension)
EOF
  print_common_help_footer
}

r_install_pkg() {
  # r_install_pkg <package>
  local pkg="$1"
  if r_package_installed "$pkg"; then
    log_ok "R package already installed: $pkg"
    return 0
  fi
  if [ "$DRY_RUN" = "1" ]; then
    log_dry "Rscript -e \"install.packages('$pkg', repos='$CRAN_REPO')\""
    return 0
  fi
  Rscript -e "install.packages('$pkg', repos='$CRAN_REPO')"
}

cleanup_r_locks() {
  # Remove stale 00LOCK-* directories left by previously interrupted installs.
  # R refuses to install into a locked directory, producing cryptic errors.
  if ! check_command Rscript; then return 0; fi
  local lib_dir
  lib_dir="$(Rscript --vanilla -e 'cat(.libPaths()[1])' 2>/dev/null || true)"
  [ -z "$lib_dir" ] && return 0
  local lock found=0
  for lock in "$lib_dir"/00LOCK-*; do
    [ -d "$lock" ] || continue
    log_warn "removing stale R package lock: $lock"
    rm -rf "$lock" && found=1 || log_warn "could not remove $lock (try: sudo rm -rf $lock)"
  done
  [ "$found" = "1" ] && log_info "stale locks cleared"
  return 0
}

do_core() {
  # Install R
  if ! check_command R; then
    brew_install_formula r
  else
    log_ok "R already installed: $(R --version 2>&1 | head -1)"
  fi
  if ! check_command Rscript; then
    log_warn "Rscript missing after R install; aborting R package installs"
    return 0
  fi

  cleanup_r_locks
  r_install_pkg languageserver
  r_install_pkg lintr
  r_install_pkg styler
}

do_renv() {
  if ! check_command Rscript; then return 0; fi
  if ! prompt_yn "Install renv (R project-local package manager)?"; then
    log_info "skipping renv"
    return 0
  fi
  r_install_pkg renv
}

do_quarto() {
  if check_command quarto; then
    log_ok "quarto already installed: $(quarto --version 2>&1)"
    return 0
  fi
  if ! prompt_yn "Install Quarto?"; then
    log_info "skipping Quarto"
    return 0
  fi
  brew_install_pkg_cask quarto \
    "brew install --cask quarto" \
    "Quarto: render .qmd/.Rmd notebooks to HTML/PDF/Word; required by the epidemiology (/epi) and reporting workflows"
}

# Epi bundle: survival, Bayesian, causal inference, missing data, plotting.
EPI_PKGS="survival survminer broom broom.mixed emmeans sandwich lmtest
  marginaleffects tidyverse data.table lubridate janitor here
  gtsummary ggeffects mice missRanger naniar
  epitools epiR Epi
  brms rstanarm tidybayes posterior bayesplot
  targets tarchetypes quarto knitr rmarkdown"

do_epi_bundle() {
  if ! check_command Rscript; then return 0; fi

  if ! prompt_yn "Install epidemiology R package bundle (~30 packages, may be slow)?" default_n; then
    log_info "skipping epi bundle"
    return 0
  fi

  # Count packages for progress logging.
  local total=0 count=0
  local pkg
  for pkg in $EPI_PKGS; do
    total=$((total + 1))
  done

  for pkg in $EPI_PKGS; do
    count=$((count + 1))
    log_info "Installing $count/$total: $pkg"
    r_install_pkg "$pkg" || log_warn "failed to install $pkg; continuing with remaining packages"
  done
}

run_check_mode() {
  local missing=0
  check_command R       && log_ok "R"       || { log_warn "[missing] R"; missing=1; }
  check_command Rscript && log_ok "Rscript" || { log_warn "[missing] Rscript"; missing=1; }
  r_package_installed languageserver && log_ok "languageserver" \
    || { log_warn "[missing] languageserver"; missing=1; }
  r_package_installed lintr  && log_ok "lintr"  || { log_warn "[missing] lintr"; missing=1; }
  r_package_installed styler && log_ok "styler" || { log_warn "[missing] styler"; missing=1; }
  r_package_installed renv   && log_ok "renv"   || log_warn "[optional-missing] renv"
  check_command quarto       && log_ok "quarto" || log_warn "[optional-missing] quarto"
  return "$missing"
}

main() {
  parse_common_flags "$@"
  if [ "$SHOW_HELP" = "1" ]; then print_help; exit 0; fi
  assert_supported_os
  print_section "install-r: R + languageserver/lintr/styler + optional extras ($DETECTED_OS)"

  if [ "$CHECK_MODE" = "1" ]; then
    run_check_mode
    exit $?
  fi

  require_pkg_manager

  do_core
  do_renv
  do_quarto
  do_epi_bundle

  print_deferred_hints
  log_info "install-r finished."
}

main "$@"
