# Ketamine-Assisted Therapy for Methamphetamine Use Disorder (Synthetic RCT)

**Zed R/Python Toolchain Verification -- Task 20**
Generated: 2026-04-10
Source: `reports/05_consort_report.qmd` (Quarto unavailable; Markdown fallback
with pre-computed numbers from Phase 5/6 outputs)

---

## Background

Verification exercise for Zed's R and Python toolchains on NixOS. We analyze
a synthetic 1:1 randomized controlled trial of Ketamine-Assisted Therapy
(KAT) vs Therapy-As-Usual (TAU) for methamphetamine use disorder,
N=200 participants stratified by baseline severity.

> **Note**: All data are synthetic. No real participants or clinical inference.

## Methods

- **Design**: 1:1 stratified RCT, 12-week follow-up
- **Randomization**: Stratified by baseline ASI tertile (Low/Mid/High)
- **Primary outcome**: Abstinence from methamphetamine at 12 weeks (binary)
- **Secondary outcomes**:
  - Time to first use (continuous, administratively censored at 84 days)
  - Addiction Severity Index (ASI) at 12 weeks
- **Primary analysis**: Logistic regression adjusting for severity stratum,
  age, sex, and baseline ASI
- **Reporting guideline**: CONSORT

## CONSORT Flow Diagram

```
                        Enrolled: 200
                             |
                   Randomized (stratified 1:1)
                        /            \
                KAT: 100              TAU: 100
                   |                    |
        Completed 12wk: 85      Completed 12wk: 85
         Lost to FU:   15        Lost to FU:   15
```

## Table 1: Baseline Characteristics (complete-case n=170)

| Characteristic | KAT (n=85) | TAU (n=85) |
|---|---|---|
| Age, mean | ~35 | ~35 |
| Baseline ASI, mean | ~0.51 | ~0.51 |
| Sex (M/F) | ~54/31 | ~56/29 |
| Prior treatment | ~45 | ~50 |

(Full Table 1 in `reports/tables/primary_results.txt`. `gtsummary` unavailable;
base R aggregation used.)

## Primary Results

Observed abstinence at 12 weeks (complete case):

- **KAT**: 42.4% (36/85)
- **TAU**: 22.4% (19/85)

**Adjusted logistic regression** (abstinent_12wk ~ arm + severity_stratum +
age + sex + baseline_asi):

| Term | OR | 95% CI | p |
|---|---|---|---|
| **arm KAT (vs TAU)** | **3.29** | **1.57 - 6.89** | **0.002** |
| Severity Mid vs Low | 1.42 | 0.33 - 6.01 | 0.638 |
| Severity High vs Low | 10.71 | 0.76 - 151.85 | 0.080 |
| Age (per year) | 0.96 | 0.91 - 1.00 | 0.062 |
| Male vs Female | 0.46 | 0.22 - 0.96 | 0.040 |
| Baseline ASI | 0.0014 | ~0 - 0.12 | 0.004 |

Direction and magnitude are consistent with the simulated effect (KAT > TAU).

## Secondary Results

**Time to relapse (Cox fallback)**: Because `survival` is unavailable, a base-R
log-rank test plus an exponential GLM were used as a Cox surrogate. The
exponential GLM arm coefficient indicates KAT extends time-to-relapse relative
to TAU; log-rank p-value recorded in `reports/tables/primary_results.txt`.

**ASI at 12 weeks (linear regression)**: arm coefficient beta = -0.100
(p = 1.2e-10), indicating a 0.10 unit ASI reduction in the KAT arm beyond TAU
after adjustment.

## Sensitivity Analyses (KAT odds ratio)

| Analysis | OR | 95% CI | p |
|---|---|---|---|
| Complete case (primary) | 3.29 | 1.57 - 6.89 | 0.002 |
| Per-protocol (>=4/6 sessions) | 2.52 | 1.04 - 6.13 | 0.041 |
| Single-imputation (mode) | 3.13 | 1.55 - 6.33 | 0.002 |
| Worst-case for KAT | 1.29 | 0.69 - 2.42 | 0.425 |
| Best-case for KAT | 5.88 | 2.90 - 11.91 | < 0.001 |

**Interpretation**: Primary result is robust under per-protocol and
single-imputation sensitivity. The worst-case tipping-point analysis pushes
OR toward 1.3 (not statistically significant), indicating the primary result
is sensitive to extreme informative dropout. For real analyses, multiple
imputation with `mice` is recommended once the package is installed.

## Limitations

1. **Synthetic data**: Effect sizes are pre-specified (data-generating process);
   not a real clinical finding.
2. **Cox regression unavailable**: `survival` package missing. Log-rank +
   exponential GLM used as surrogate.
3. **Multiple imputation unavailable**: `mice` missing; mean/mode
   single-imputation used instead.
4. **Quarto unavailable**: Report is plain Markdown with pre-computed numbers.
5. **No R LSP**: languageserver not installed, so Zed editor integration for R
   is limited to syntax highlighting.

## Configuration Gaps

See [`../logs/config_gaps.md`](../logs/config_gaps.md) for the complete
prioritized remediation list.
