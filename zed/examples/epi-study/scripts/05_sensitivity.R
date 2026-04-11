# 05_sensitivity.R -- Sensitivity analyses for ketamine RCT
# Task 20: Zed R/Python toolchain verification
#
# NOTE: mice package is unavailable -- multiple imputation replaced with a
# simple mean/mode single-imputation sensitivity plus a worst-case/best-case
# bounding analysis.

set.seed(20260410)

dat <- read.csv("data/derived/analytic.csv", stringsAsFactors = FALSE)
dat$arm <- factor(dat$arm, levels = c("TAU", "KAT"))
dat$severity_stratum <- factor(dat$severity_stratum, levels = c("Low", "Mid", "High"))
dat$sex <- factor(dat$sex)

sink("reports/tables/sensitivity_results.txt")
on.exit(sink(), add = TRUE)

cat("==================================================================\n")
cat(" Sensitivity Analyses -- Ketamine-Assisted Therapy RCT             \n")
cat(" Task 20 / synthetic data / base R only                            \n")
cat("==================================================================\n\n")

fit_logit <- function(data, label) {
  cat("---- ", label, " (n = ", nrow(data), ") ----\n", sep = "")
  m <- glm(abstinent_12wk ~ arm + severity_stratum + age + sex + baseline_asi,
           data = data, family = binomial())
  co <- summary(m)$coefficients
  ci <- confint.default(m)
  arm_row <- which(rownames(co) == "armKAT")
  or <- exp(co[arm_row, 1])
  lo <- exp(ci[arm_row, 1])
  hi <- exp(ci[arm_row, 2])
  p <- co[arm_row, 4]
  cat(sprintf("  OR (KAT vs TAU) = %.2f (95%% CI %.2f-%.2f), p = %.4f\n\n",
              or, lo, hi, p))
  invisible(list(or = or, lo = lo, hi = hi, p = p))
}

# ---- 1. Complete case (primary) ----
cc <- dat[!is.na(dat$abstinent_12wk), ]
res_cc <- fit_logit(cc, "Complete-case analysis (primary)")

# ---- 2. Per-protocol ----
pp <- dat[!is.na(dat$abstinent_12wk) & dat$per_protocol == 1, ]
res_pp <- fit_logit(pp, "Per-protocol (>= 4/6 sessions)")

# ---- 3. Treatment x severity interaction test ----
cat("---- Treatment x severity interaction (LRT) ----\n")
m_main <- glm(abstinent_12wk ~ arm + severity_stratum + age + sex + baseline_asi,
              data = cc, family = binomial())
m_int <- glm(abstinent_12wk ~ arm * severity_stratum + age + sex + baseline_asi,
             data = cc, family = binomial())
lrt <- anova(m_main, m_int, test = "Chisq")
print(lrt)
cat(sprintf("\n  LRT p-value for arm*severity interaction: %.4f\n\n",
            lrt[["Pr(>Chi)"]][2]))

# ---- 4. Single-imputation sensitivity (mean/mode) ----
cat("---- Single-imputation sensitivity ----\n")
cat("  (mice unavailable; using simple mean/mode imputation)\n\n")
imp <- dat
# Mode imputation for binary abstinent
mode_val <- as.integer(names(sort(table(imp$abstinent_12wk), decreasing = TRUE))[1])
imp$abstinent_12wk[is.na(imp$abstinent_12wk)] <- mode_val
# Mean imputation for asi_12wk
imp$asi_12wk[is.na(imp$asi_12wk)] <- mean(imp$asi_12wk, na.rm = TRUE)
res_imp <- fit_logit(imp, "Single-imputation (mode for abstinent)")

# ---- 5. Worst-case / best-case bounds ----
cat("---- Tipping-point (worst-case / best-case) ----\n\n")
wc <- dat
wc$abstinent_12wk[is.na(wc$abstinent_12wk) & wc$arm == "KAT"] <- 0
wc$abstinent_12wk[is.na(wc$abstinent_12wk) & wc$arm == "TAU"] <- 1
res_wc <- fit_logit(wc, "Worst-case for KAT (missing KAT=failure, TAU=success)")

bc <- dat
bc$abstinent_12wk[is.na(bc$abstinent_12wk) & bc$arm == "KAT"] <- 1
bc$abstinent_12wk[is.na(bc$abstinent_12wk) & bc$arm == "TAU"] <- 0
res_bc <- fit_logit(bc, "Best-case for KAT (missing KAT=success, TAU=failure)")

# ---- 6. Summary ----
cat("==================================================================\n")
cat(" Summary of KAT odds ratio across analyses                        \n")
cat("==================================================================\n")
summary_tbl <- data.frame(
  analysis = c("Complete case", "Per-protocol", "Single-imp (mode)",
               "Worst-case KAT", "Best-case KAT"),
  OR = c(res_cc$or, res_pp$or, res_imp$or, res_wc$or, res_bc$or),
  lower = c(res_cc$lo, res_pp$lo, res_imp$lo, res_wc$lo, res_bc$lo),
  upper = c(res_cc$hi, res_pp$hi, res_imp$hi, res_wc$hi, res_bc$hi),
  p = c(res_cc$p, res_pp$p, res_imp$p, res_wc$p, res_bc$p)
)
print(summary_tbl, row.names = FALSE, digits = 3)

cat("\nSensitivity analysis complete.\n")
