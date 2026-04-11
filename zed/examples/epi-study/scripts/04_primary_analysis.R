# 04_primary_analysis.R -- Primary and secondary analyses
# Task 20: Zed R/Python toolchain verification
#
# NOTE: survival package is not installed in this Nix R environment.
# Cox model is replaced with a log-rank-style comparison plus a parametric
# (exponential/Weibull via glm with quasilikelihood or simple Mantel-Haenszel)
# fallback. See logs/config_gaps.md.

set.seed(20260410)

dat <- read.csv("data/derived/analytic.csv", stringsAsFactors = FALSE)
cat("Loaded analytic dataset:", nrow(dat), "rows,", ncol(dat), "cols\n")

dat$arm <- factor(dat$arm, levels = c("TAU", "KAT"))
dat$severity_stratum <- factor(dat$severity_stratum, levels = c("Low", "Mid", "High"))
dat$sex <- factor(dat$sex)

# Complete-case subset for primary outcome
cc <- dat[!is.na(dat$abstinent_12wk), ]
cat("Complete-case n (abstinent):", nrow(cc), "\n")

sink("reports/tables/primary_results.txt")
on.exit(sink(), add = TRUE)

cat("==================================================================\n")
cat(" Primary and Secondary Analyses -- Ketamine-Assisted Therapy RCT \n")
cat(" Task 20 / synthetic data / base R only                           \n")
cat("==================================================================\n\n")

# ---- Table 1 (base R fallback) ----
cat("---- Table 1: Baseline Characteristics by Arm ----\n")
tab_n <- table(cc$arm)
cat("\nArm sizes (complete case):\n")
print(tab_n)

cat("\nAge (mean [SD]) by arm:\n")
print(aggregate(age ~ arm, data = cc, FUN = function(x) c(mean = mean(x), sd = sd(x))))

cat("\nBaseline ASI (mean [SD]) by arm:\n")
print(aggregate(baseline_asi ~ arm, data = cc, FUN = function(x) c(mean = mean(x), sd = sd(x))))

cat("\nSex x Arm:\n")
print(table(cc$sex, cc$arm))

cat("\nSeverity stratum x Arm:\n")
print(table(cc$severity_stratum, cc$arm))

cat("\nPrior treatment x Arm:\n")
print(table(cc$prior_treatment, cc$arm))

# ---- Primary: Logistic regression ----
cat("\n\n---- Primary Model: Logistic Regression ----\n")
cat("abstinent_12wk ~ arm + severity_stratum + age + sex + baseline_asi\n\n")

m_primary <- glm(
  abstinent_12wk ~ arm + severity_stratum + age + sex + baseline_asi,
  data = cc, family = binomial()
)
print(summary(m_primary))

cat("\nOdds ratios and 95% CI:\n")
co <- summary(m_primary)$coefficients
ci <- confint.default(m_primary)
or_tab <- data.frame(
  term = rownames(co),
  estimate = exp(co[, 1]),
  ci_lower = exp(ci[, 1]),
  ci_upper = exp(ci[, 2]),
  p_value = co[, 4]
)
print(or_tab, row.names = FALSE, digits = 3)

saveRDS(m_primary, "data/derived/models/primary_logistic.rds")

# ---- Secondary: "Cox-like" analysis via log-rank test + Weibull regression ----
cat("\n\n---- Secondary Model: Time-to-Relapse (Cox fallback) ----\n")
cat("NOTE: 'survival' package unavailable; using log-rank via base R stats\n")
cat("and a parametric exponential model via glm(family=Gamma).\n\n")

# Simple log-rank test (Mantel-Cox) implemented in base R
log_rank_test <- function(time, event, group) {
  ord <- order(time)
  time <- time[ord]
  event <- event[ord]
  group <- group[ord]
  unique_times <- sort(unique(time[event == 1]))
  n_total <- length(time)
  groups <- unique(group)
  stopifnot(length(groups) == 2)

  O1 <- 0; E1 <- 0; V <- 0
  at_risk <- rep(TRUE, n_total)
  for (t in unique_times) {
    d <- sum(time == t & event == 1)
    n <- sum(at_risk & time >= t)
    n1 <- sum(at_risk & time >= t & group == groups[1])
    d1 <- sum(time == t & event == 1 & group == groups[1])
    if (n >= 2) {
      e1 <- d * n1 / n
      v1 <- (d * n1 * (n - n1) * (n - d)) / (n^2 * (n - 1))
      O1 <- O1 + d1
      E1 <- E1 + e1
      V <- V + v1
    }
  }
  chi <- (O1 - E1)^2 / V
  list(O1 = O1, E1 = E1, chisq = chi,
       p_value = 1 - pchisq(chi, df = 1))
}

lr <- log_rank_test(dat$days_to_use, dat$event, as.character(dat$arm))
cat("Log-rank test (KAT vs TAU):\n")
cat(sprintf("  O1=%.1f, E1=%.1f, chisq=%.3f, p=%.4f\n",
            lr$O1, lr$E1, lr$chisq, lr$p_value))

# Parametric alternative: exponential regression via glm(Gamma, log link) on time
# Not exactly a Cox model but gives a hazard ratio interpretation.
cat("\nExponential regression (glm Gamma log link) on days_to_use:\n")
m_exp <- glm(days_to_use ~ arm + severity_stratum + age + sex + baseline_asi,
             data = dat, family = Gamma(link = "log"))
print(summary(m_exp))
cat("\nHR-like estimates (exp(-beta) for time model):\n")
beta_arm <- coef(m_exp)["armKAT"]
cat(sprintf("  Approx HR (KAT vs TAU) = exp(-beta_arm) = %.3f\n", exp(-beta_arm)))

saveRDS(m_exp, "data/derived/models/secondary_exponential.rds")

# ---- Secondary: Linear regression on continuous ASI ----
cat("\n\n---- Secondary Model: Linear Regression on 12-week ASI ----\n")
cat("asi_12wk ~ arm + severity_stratum + age + sex + baseline_asi\n\n")
m_linear <- lm(
  asi_12wk ~ arm + severity_stratum + age + sex + baseline_asi,
  data = dat
)
print(summary(m_linear))
cat("\n95% CI for coefficients:\n")
print(confint(m_linear))

saveRDS(m_linear, "data/derived/models/secondary_linear.rds")

cat("\n==================================================================\n")
cat(" Primary analysis complete. Models saved to data/derived/models/.   \n")
cat("==================================================================\n")
