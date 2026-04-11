"""01_generate_data.py -- Synthetic baseline data for ketamine RCT.

Generates N=200 participants with baseline covariates and 1:1 stratified
randomization by severity stratum. Uses numpy only (no scipy dependency).

Task 20: Zed R/Python toolchain verification.
Run: python3 scripts/01_generate_data.py
"""

from __future__ import annotations

from pathlib import Path

import numpy as np
import pandas as pd

SEED = 20260410
N = 200
HERE = Path(__file__).resolve().parent.parent
OUT = HERE / "data" / "raw" / "participants.csv"

rng = np.random.default_rng(SEED)


def generate_baseline(n: int) -> pd.DataFrame:
    """Generate baseline covariates."""
    age = rng.normal(loc=35, scale=8, size=n).round(0).clip(18, 65).astype(int)
    sex = rng.choice(["Male", "Female"], size=n, p=[0.65, 0.35])
    race_ethnicity = rng.choice(
        ["White", "Hispanic", "Black", "Asian", "Other"],
        size=n,
        p=[0.50, 0.25, 0.15, 0.05, 0.05],
    )
    years_use = rng.gamma(shape=2.0, scale=3.0, size=n).round(1).clip(0.5, 25)
    prior_treatment = rng.binomial(1, 0.45, size=n)

    # Baseline Addiction Severity Index (0-1 scale, higher = worse)
    baseline_asi = rng.beta(2, 2, size=n).round(3)

    # Severity stratum from ASI tertiles
    # Low: ASI < 0.33, Mid: 0.33-0.66, High: >=0.66
    severity_stratum = pd.cut(
        baseline_asi,
        bins=[-0.001, 0.33, 0.66, 1.01],
        labels=["Low", "Mid", "High"],
    ).astype(str)

    df = pd.DataFrame(
        {
            "participant_id": [f"P{i:04d}" for i in range(1, n + 1)],
            "age": age,
            "sex": sex,
            "race_ethnicity": race_ethnicity,
            "years_use": years_use,
            "prior_treatment": prior_treatment,
            "baseline_asi": baseline_asi,
            "severity_stratum": severity_stratum,
        }
    )
    return df


def stratified_randomize(df: pd.DataFrame) -> pd.DataFrame:
    """Assign 1:1 arm within each severity stratum."""
    df = df.copy()
    df["arm"] = ""
    for stratum in df["severity_stratum"].unique():
        mask = df["severity_stratum"] == stratum
        idx = df.index[mask].to_list()
        rng.shuffle(idx)
        half = len(idx) // 2
        # first half KAT, rest TAU; alternate odd to keep balanced
        arms = ["KAT"] * half + ["TAU"] * (len(idx) - half)
        # If odd count, flip coin for leftover
        if len(idx) % 2 == 1:
            arms[-1] = rng.choice(["KAT", "TAU"])
        for i, j in enumerate(idx):
            df.at[j, "arm"] = arms[i]
    return df


def add_session_schedule(df: pd.DataFrame) -> pd.DataFrame:
    """Add planned sessions (always 6) and enrollment date."""
    df = df.copy()
    df["planned_sessions"] = 6
    base_date = pd.Timestamp("2026-01-15")
    df["enrollment_date"] = base_date + pd.to_timedelta(
        rng.integers(0, 60, size=len(df)), unit="D"
    )
    df["enrollment_date"] = df["enrollment_date"].dt.strftime("%Y-%m-%d")
    return df


def main() -> None:
    print(f"Seed: {SEED}")
    print(f"N: {N}")
    df = generate_baseline(N)
    df = stratified_randomize(df)
    df = add_session_schedule(df)

    # Verification
    assert len(df) == N, f"Expected {N} rows, got {len(df)}"
    assert df["participant_id"].is_unique, "Duplicate participant IDs"
    assert df.isna().sum().sum() == 0, "NAs in baseline"

    print("\nArm balance by stratum:")
    print(pd.crosstab(df["severity_stratum"], df["arm"]))

    print("\nBaseline summary:")
    print(df[["age", "years_use", "baseline_asi"]].describe().round(2))

    OUT.parent.mkdir(parents=True, exist_ok=True)
    df.to_csv(OUT, index=False, encoding="utf-8")
    print(f"\nWrote {OUT} ({len(df)} rows, {df.shape[1]} columns)")


if __name__ == "__main__":
    main()
