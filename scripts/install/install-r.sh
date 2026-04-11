#!/usr/bin/env bash
# install-r.sh - R toolchain
#
# Mirrors docs/toolchain/r.md:
#   Core:       R (brew), languageserver, lintr, styler (install.packages)
#   renv:       install.packages("renv")
#   Quarto:     brew install --cask quarto
#   Epi bundle: broader list of R packages for the epidemiology extension
#
# All install.packages() calls force the cloud CRAN mirror to skip interactive
# mirror-selection prompts.
#
# Flags: --dry-run --yes --check --help
# Idempotent: every install guarded by presence check.

set -eu

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib.sh
. "$SCRIPT_DIR/lib.sh"

CRAN_REPO="https://cloud.r-project.org"

print_help() {
  cat >&2 <<'EOF'
install-r.sh - R toolchain

Installs:
  Core:
    - R (brew install r)
    - languageserver, lintr, styler (install.packages via Rscript)
  Optional sub-groups (prompted):
    - renv    (project-local package manager)
    - Quarto  (brew install --cask quarto)
    - Epi bundle (broader R packages for the epidemiology extension)

All install.packages() calls pin repos=https://cloud.r-project.org to skip
the CRAN mirror prompt.
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
  run_or_dry Rscript -e "install.packages('$pkg', repos='$CRAN_REPO')"
}

do_core() {
  if ! check_command R; then
    brew_install_formula r
  else
    log_ok "R already installed: $(R --version 2>&1 | head -1)"
  fi
  if ! check_command Rscript; then
    log_warn "Rscript missing after R install; aborting R package installs"
    return 0
  fi
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
  if ! prompt_yn "Install Quarto (brew --cask quarto)?"; then
    log_info "skipping Quarto"
    return 0
  fi
  brew_install_cask quarto
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
  if ! prompt_yn "Install epidemiology R package bundle (~30 packages, slow)?" default_n; then
    log_info "skipping epi bundle"
    return 0
  fi
  local pkg
  for pkg in $EPI_PKGS; do
    r_install_pkg "$pkg"
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
  assert_macos
  print_section "install-r: R + languageserver/lintr/styler + optional extras"

  if [ "$CHECK_MODE" = "1" ]; then
    run_check_mode
    exit $?
  fi

  require_brew

  do_core
  do_renv
  do_quarto
  do_epi_bundle

  log_info "install-r finished."
}

main "$@"
