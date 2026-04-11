# 02_generate_outcomes.R -- Generate synthetic outcomes conditional on treatment
# Task 20: Zed R/Python toolchain verification (base R fallback only)
#
# Reads data/raw/participants.csv
# Writes data/raw/outcomes.csv and data/raw/adverse_events.csv
#
# NOTE: This script uses only base R because tidyverse and survival are not
# installed in the current Nix R library. See logs/config_gaps.md.

set.seed(20260410)

# ---- 1. Load baseline ----
in_path <- "data/raw/participants.csv"
stopifnot(file.exists(in_path))
base <- read.csv(in_path, stringsAsFactors = FALSE)
cat("Loaded", nrow(base), "baseline rows with", ncol(base), "cols\n")

# ---- 2. Generate primary outcome: abstinent_12wk ----
# Logistic data-generating process:
#   logit(p) = b0 + b_arm * I(KAT) + b_severity * asi + b_age * age_centered
#              + b_prior * prior_treatment
#
# Target marginal: ~40% KAT abstinence, ~25% TAU
age_c <- base$age - mean(base$age)
asi_c <- base$baseline_asi - mean(base$baseline_asi)
arm_kat <- as.integer(base$arm == "KAT")

lin <- -1.10 + 0.95 * arm_kat - 1.50 * asi_c - 0.02 * age_c - 0.30 * base$prior_treatment
p_abstinent <- 1 / (1 + exp(-lin))
abstinent_12wk <- rbinom(nrow(base), 1, p_abstinent)

cat(sprintf(
  "Marginal abstinence -- KAT: %.1f%%, TAU: %.1f%%\n",
  100 * mean(abstinent_12wk[arm_kat == 1]),
  100 * mean(abstinent_12wk[arm_kat == 0])
))

# ---- 3. Generate time-to-relapse (days_to_use, Weibull via base rweibull) ----
# Scale depends on arm: KAT has longer time-to-relapse on average
shape_param <- 1.3
scale_kat <- 55
scale_tau <- 35
scales <- ifelse(arm_kat == 1, scale_kat, scale_tau)
# Adjust for severity (higher ASI -> shorter time)
scales <- scales * exp(-0.5 * asi_c)

time_raw <- rweibull(nrow(base), shape = shape_param, scale = scales)
# Administrative censoring at 84 days (12 weeks)
admin_cens <- 84
event <- as.integer(time_raw <= admin_cens)
days_to_use <- pmin(time_raw, admin_cens)
days_to_use <- round(days_to_use, 1)

cat(sprintf(
  "Time-to-use -- median KAT: %.1f, TAU: %.1f; event rate: %.1f%%\n",
  median(days_to_use[arm_kat == 1]),
  median(days_to_use[arm_kat == 0]),
  100 * mean(event)
))

# ---- 4. Generate continuous secondary: asi_12wk ----
# Mean shift: KAT reduces ASI more than TAU
asi_mean_shift <- ifelse(arm_kat == 1, -0.18, -0.08)
asi_12wk <- base$baseline_asi + asi_mean_shift + rnorm(nrow(base), 0, 0.10)
asi_12wk <- round(pmin(pmax(asi_12wk, 0), 1), 3)

# ---- 5. Sessions attended (compliance) ----
# KAT average 5.2/6, TAU 4.3/6
lambda_sess <- ifelse(arm_kat == 1, 5.2, 4.3)
sessions_attended <- pmin(rpois(nrow(base), lambda_sess), 6)

# ---- 6. Introduce ~15% MCAR missingness on 12-week outcomes ----
mcar_rate <- 0.15
n <- nrow(base)
miss_idx <- sample.int(n, size = round(mcar_rate * n))
completed_study <- rep(1L, n)
completed_study[miss_idx] <- 0L
abstinent_12wk_obs <- abstinent_12wk
abstinent_12wk_obs[miss_idx] <- NA
asi_12wk_obs <- asi_12wk
asi_12wk_obs[miss_idx] <- NA

cat(sprintf(
  "Completed study: %d/%d (%.0f%%)\n",
  sum(completed_study), n, 100 * mean(completed_study)
))

# ---- 7. Assemble outcomes dataframe ----
outcomes <- data.frame(
  participant_id = base$participant_id,
  abstinent_12wk = abstinent_12wk_obs,
  asi_12wk = asi_12wk_obs,
  days_to_use = days_to_use,
  event = event,
  sessions_attended = sessions_attended,
  completed_study = completed_study,
  stringsAsFactors = FALSE
)

out_path <- "data/raw/outcomes.csv"
write.csv(outcomes, out_path, row.names = FALSE, na = "")
cat("Wrote", out_path, "with", nrow(outcomes), "rows\n")

# ---- 8. Adverse events log (~50 rows) ----
n_ae <- 50
ae_pids <- sample(base$participant_id, n_ae, replace = TRUE)
ae_types <- sample(
  c("Dissociation", "Nausea", "Headache", "Anxiety", "Sedation", "Dizziness"),
  n_ae, replace = TRUE,
  prob = c(0.25, 0.20, 0.20, 0.15, 0.10, 0.10)
)
ae_severity <- sample(c("Mild", "Moderate", "Severe"), n_ae, replace = TRUE,
                      prob = c(0.65, 0.30, 0.05))
ae_day <- sample(1:84, n_ae, replace = TRUE)
ae <- data.frame(
  participant_id = ae_pids,
  event_type = ae_types,
  severity = ae_severity,
  study_day = ae_day,
  stringsAsFactors = FALSE
)
ae <- ae[order(ae$participant_id, ae$study_day), ]

ae_path <- "data/raw/adverse_events.csv"
write.csv(ae, ae_path, row.names = FALSE)
cat("Wrote", ae_path, "with", nrow(ae), "rows\n")

cat("\n==== Phase 3 Complete ====\n")
