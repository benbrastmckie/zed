# 00_check_env.R -- Verify R toolchain and package availability
# Task 20: Zed R/Python toolchain verification
# Run: Rscript scripts/00_check_env.R

cat("==== R Environment Check ====\n")
cat("R version:        ", R.version$version.string, "\n")
cat("Platform:         ", R.version$platform, "\n")
cat("Running under:    ", R.version$os, "\n\n")

cat("==== Library Paths ====\n")
for (p in .libPaths()) cat("  ", p, "\n")
cat("\n")

cat("==== Package Availability ====\n")
pkgs <- c(
  "tidyverse", "dplyr", "readr", "ggplot2",
  "survival", "gtsummary", "broom",
  "mice", "knitr", "rmarkdown",
  "languageserver", "styler", "lintr"
)

results <- data.frame(package = pkgs, installed = NA, loads = NA,
                      stringsAsFactors = FALSE)
for (i in seq_along(pkgs)) {
  pkg <- pkgs[i]
  results$installed[i] <- requireNamespace(pkg, quietly = TRUE)
  if (results$installed[i]) {
    ok <- tryCatch({
      suppressPackageStartupMessages(library(pkg, character.only = TRUE))
      TRUE
    }, error = function(e) FALSE)
    results$loads[i] <- ok
  } else {
    results$loads[i] <- FALSE
  }
  status <- if (results$loads[i]) "OK" else "MISSING"
  cat(sprintf("  %-20s %s\n", pkg, status))
}

cat("\n==== Summary ====\n")
cat("Available:", sum(results$loads), "/", nrow(results), "\n")
cat("Missing:  ", paste(results$package[!results$loads], collapse = ", "), "\n")
