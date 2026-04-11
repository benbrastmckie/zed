"""03_merge_data.py -- Merge baseline and outcomes into analytic dataset.

Task 20: Zed R/Python toolchain verification.
Run: python3 scripts/03_merge_data.py
"""

from __future__ import annotations

from pathlib import Path

import pandas as pd

HERE = Path(__file__).resolve().parent.parent
PARTICIPANTS = HERE / "data" / "raw" / "participants.csv"
OUTCOMES = HERE / "data" / "raw" / "outcomes.csv"
OUT = HERE / "data" / "derived" / "analytic.csv"


def main() -> None:
    base = pd.read_csv(PARTICIPANTS)
    out = pd.read_csv(OUTCOMES)

    print(f"Baseline:  {base.shape}")
    print(f"Outcomes:  {out.shape}")

    analytic = base.merge(out, on="participant_id", how="left", validate="one_to_one")
    print(f"Merged:    {analytic.shape}")

    assert len(analytic) == 200, "Expected 200 rows after merge"
    assert analytic["participant_id"].is_unique, "Duplicate IDs"
    assert analytic["age"].notna().all(), "NAs in baseline age"

    # Derived variables
    analytic["arm_label"] = analytic["arm"].map(
        {"KAT": "Ketamine-Assisted Therapy", "TAU": "Therapy As Usual"}
    )
    analytic["compliance"] = analytic["sessions_attended"] / analytic["planned_sessions"]
    analytic["per_protocol"] = (analytic["compliance"] >= 4 / 6).astype(int)
    analytic["age_group"] = pd.cut(
        analytic["age"],
        bins=[17, 25, 35, 45, 65],
        labels=["18-25", "26-35", "36-45", "46-65"],
    ).astype(str)

    # Summary
    print("\nArm x completed_study:")
    print(pd.crosstab(analytic["arm"], analytic["completed_study"]))

    print("\nAbstinence (observed only):")
    obs = analytic.dropna(subset=["abstinent_12wk"])
    print(obs.groupby("arm")["abstinent_12wk"].agg(["count", "mean"]).round(3))

    OUT.parent.mkdir(parents=True, exist_ok=True)
    analytic.to_csv(OUT, index=False, encoding="utf-8")
    print(f"\nWrote {OUT}")
    print(f"Shape: {analytic.shape}, columns: {list(analytic.columns)}")


if __name__ == "__main__":
    main()
