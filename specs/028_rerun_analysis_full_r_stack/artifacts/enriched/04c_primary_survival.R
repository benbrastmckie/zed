#!/usr/bin/env Rscript
# 04c_primary_survival.R -- proper Cox PH analysis using survival package.
# Part of task 28 Branch B. Additive output; does not modify frozen tables.

stopifnot(requireNamespace("readr", quietly = TRUE))
stopifnot(requireNamespace("dplyr", quietly = TRUE))
stopifnot(requireNamespace("survival", quietly = TRUE))

suppressPackageStartupMessages({
  library(readr)
  library(dplyr)
  library(survival)
})

study_root <- "/home/benjamin/.config/zed/examples/epi-study"
analytic_path <- file.path(study_root, "data/derived/analytic.csv")
out_path <- file.path(study_root, "reports/tables/cox_results.txt")

dat <- read_csv(analytic_path, show_col_types = FALSE) |>
  mutate(
    arm = factor(arm, levels = c("TAU", "KAT")),
    severity_stratum = factor(severity_stratum, levels = c("Low", "Mid", "High")),
    sex = factor(sex)
  )

cat("04c survival: n =", nrow(dat), "rows; events =", sum(dat$event), "\n")

cox_fit <- coxph(
  Surv(days_to_use, event) ~ arm + severity_stratum + age + sex + baseline_asi,
  data = dat
)

kap <- survfit(Surv(days_to_use, event) ~ arm, data = dat)

sink(out_path)
cat("==================================================================\n")
cat(" 04c Cox Proportional Hazards -- task 28 Branch B                 \n")
cat("==================================================================\n\n")
print(summary(cox_fit))
cat("\n---- Proportional-hazards test (cox.zph) ----\n")
print(cox.zph(cox_fit))
cat("\n---- Kaplan-Meier by arm ----\n")
print(kap)
cat("\n---- Headline KAT hazard ratio ----\n")
s <- summary(cox_fit)
kat_idx <- which(rownames(s$coefficients) == "armKAT")
if (length(kat_idx) == 1) {
  hr <- s$conf.int[kat_idx, "exp(coef)"]
  lo <- s$conf.int[kat_idx, "lower .95"]
  hi <- s$conf.int[kat_idx, "upper .95"]
  pv <- s$coefficients[kat_idx, "Pr(>|z|)"]
  cat(sprintf("  HR = %.4f   95%% CI = [%.4f, %.4f]   p = %.5f\n", hr, lo, hi, pv))
  cat(sprintf("  HR < 1 assertion: %s\n", if (hr < 1) "PASS" else "FAIL"))
}
sink()

cat("Wrote", out_path, "\n")
