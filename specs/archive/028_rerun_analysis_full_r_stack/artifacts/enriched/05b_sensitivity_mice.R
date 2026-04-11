#!/usr/bin/env Rscript
# 05b_sensitivity_mice.R -- multiple imputation sensitivity via mice::pool().
# Part of task 28 Branch B. Additive output; does not modify frozen tables.

stopifnot(requireNamespace("readr", quietly = TRUE))
stopifnot(requireNamespace("dplyr", quietly = TRUE))
stopifnot(requireNamespace("mice", quietly = TRUE))

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(mice)
})

study_root <- "/home/benjamin/.config/zed/examples/epi-study"
analytic_path <- file.path(study_root, "data/derived/analytic.csv")
out_path <- file.path(study_root, "reports/tables/sensitivity_mice.txt")

dat <- read_csv(analytic_path, show_col_types = FALSE) |>
  mutate(
    arm = factor(arm, levels = c("TAU", "KAT")),
    severity_stratum = factor(severity_stratum, levels = c("Low", "Mid", "High")),
    sex = factor(sex),
    abstinent_12wk = as.integer(abstinent_12wk)
  ) |>
  select(abstinent_12wk, arm, severity_stratum, age, sex, baseline_asi,
         asi_12wk, days_to_use, event)

cat("05b mice: n =", nrow(dat), "rows, missing abstinent =", sum(is.na(dat$abstinent_12wk)), "\n")

set.seed(20260410)
imp <- mice(dat, m = 20, seed = 20260410, printFlag = FALSE)

fit_imp <- with(imp, glm(
  abstinent_12wk ~ arm + severity_stratum + age + sex + baseline_asi,
  family = binomial()
))

pooled <- pool(fit_imp)
psum <- summary(pooled, conf.int = TRUE, exponentiate = TRUE)

sink(out_path)
cat("==================================================================\n")
cat(" 05b Multiple Imputation (mice m=20) -- task 28 Branch B          \n")
cat("==================================================================\n\n")
print(as.data.frame(psum), row.names = FALSE)
cat("\n---- Headline pooled KAT OR ----\n")
kat <- psum[psum$term == "armKAT", ]
if (nrow(kat) == 1) {
  or_k <- kat$estimate
  lo_k <- kat$`2.5 %`
  hi_k <- kat$`97.5 %`
  pv_k <- kat$p.value
  cc_or <- 3.28721
  pct_dev <- abs(or_k - cc_or) / cc_or * 100
  cat(sprintf("  pooled OR = %.4f   95%% CI = [%.4f, %.4f]   p = %.5f\n",
              or_k, lo_k, hi_k, pv_k))
  cat(sprintf("  complete-case OR = %.4f   deviation = %.2f%%\n", cc_or, pct_dev))
  cat(sprintf("  within-20%% assertion: %s\n",
              if (pct_dev <= 20) "PASS" else "FAIL"))
}
sink()

cat("Wrote", out_path, "\n")
