"""00_check_env.py -- Verify Python toolchain and module availability.

Task 20: Zed R/Python toolchain verification
Run: python3 scripts/00_check_env.py
"""

from __future__ import annotations

import importlib
import sys

print("==== Python Environment Check ====")
print(f"Python version:  {sys.version}")
print(f"Executable:      {sys.executable}")
print(f"Platform:        {sys.platform}")
print()

print("==== Module Availability ====")
modules = [
    "numpy",
    "pandas",
    "scipy",
    "matplotlib",
    "seaborn",
    "statsmodels",
    "sklearn",
    "pyarrow",
]

results: dict[str, bool] = {}
for mod in modules:
    try:
        importlib.import_module(mod)
        results[mod] = True
        print(f"  {mod:<15} OK")
    except ImportError:
        results[mod] = False
        print(f"  {mod:<15} MISSING")

print()
print("==== Summary ====")
present = sum(results.values())
total = len(results)
print(f"Available: {present} / {total}")
missing = [m for m, ok in results.items() if not ok]
if missing:
    print(f"Missing:   {', '.join(missing)}")
