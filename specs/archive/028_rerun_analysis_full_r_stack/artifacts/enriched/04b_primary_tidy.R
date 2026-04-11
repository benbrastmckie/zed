#!/usr/bin/env Rscript
# 04b_primary_tidy.R -- enriched tidyverse/gtsummary/broom primary analysis
# Part of task 28 Branch B. Reads frozen analytic.csv, writes additive table.
# DOES NOT modify frozen scripts/ or committed baseline outputs.

stopifnot(requireNamespace("readr", quietly = TRUE))
stopifnot(requireNamespace("dplyr", quietly = TRUE))
stopifnot(requireNamespace("broom", quietly = TRUE))
stopifnot(requireNamespace("gtsummary", quietly = TRUE))

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(broom)
  library(gtsummary)
})

study_root <- "/home/benjamin/.config/zed/examples/epi-study"
analytic_path <- file.path(study_root, "data/derived/analytic.csv")
out_path <- file.path(study_root, "reports/tables/primary_results_tidy.txt")

dat <- read_csv(analytic_path, show_col_types = FALSE) |>
  mutate(
    arm = factor(arm, levels = c("TAU", "KAT")),
    severity_stratum = factor(severity_stratum, levels = c("Low", "Mid", "High")),
    sex = factor(sex)
  )

cc <- dat |> filter(!is.na(abstinent_12wk))

cat("04b primary_tidy: n =", nrow(cc), "complete cases\n")

fit <- glm(
  abstinent_12wk ~ arm + severity_stratum + age + sex + baseline_asi,
  family = binomial(),
  data = cc
)

tidy_or <- broom::tidy(fit, exponentiate = TRUE, conf.int = TRUE)

# Baseline Table 1 via gtsummary
tbl1 <- cc |>
  select(arm, age, sex, severity_stratum, baseline_asi, prior_treatment) |>
  tbl_summary(by = arm, missing = "no") |>
  add_p()

# Regression table via gtsummary (requires broom.helpers; fallback to broom::tidy)
has_bh <- requireNamespace("broom.helpers", quietly = TRUE)
tbl_reg <- if (has_bh) {
  tbl_regression(fit, exponentiate = TRUE)
} else {
  NULL
}

sink(out_path)
cat("==================================================================\n")
cat(" 04b Primary (tidyverse / gtsummary / broom)                      \n")
cat(" Task 28 Branch B -- enriched re-run, additive output              \n")
cat("==================================================================\n\n")
cat("broom::tidy(exponentiate=TRUE, conf.int=TRUE):\n")
print(as.data.frame(tidy_or), row.names = FALSE)
cat("\n---- gtsummary::tbl_summary (by arm) ----\n")
print(tbl1)
cat("\n---- gtsummary::tbl_regression (exponentiated) ----\n")
if (!is.null(tbl_reg)) {
  print(tbl_reg)
} else {
  cat("  (skipped: broom.helpers not installed; broom::tidy output shown above)\n")
}
cat("\n---- Headline KAT effect ----\n")
kat <- tidy_or |> filter(term == "armKAT")
cat(sprintf("  OR = %.4f   95%% CI = [%.4f, %.4f]   p = %.5f\n",
            kat$estimate, kat$conf.low, kat$conf.high, kat$p.value))
sink()

cat("Wrote", out_path, "\n")
