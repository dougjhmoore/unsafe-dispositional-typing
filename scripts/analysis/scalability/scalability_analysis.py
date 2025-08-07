#!/usr/bin/env python3
"""
scalability_analysis.py  –  Reproduce Figure 1 for the Dispositional Typing paper
=========================================================================

Outputs created in the chosen --output-dir (default: ../../data/scalability/):

    timing_data.csv             Raw benchmark results
    analysis_report.txt         Text summary of slopes / R²
    tikz_coordinates.txt        Coordinates for a LaTeX/TikZ re-plot
    scalability_figure.jpg      Publication-quality matplotlib figure

Usage
-----
    python3 scalability_analysis.py --output-dir ../../../data/scalability/
"""

from __future__ import annotations

import argparse
import csv
import random
import statistics
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd


# ----------------------------------------------------------------------
# Synthetic benchmark generator (replace with real measurements if you have them)
# ----------------------------------------------------------------------
def run_benchmarks() -> pd.DataFrame:
    """Return a DataFrame with N, time [ms] for a synthetic scalability curve."""
    ns = np.logspace(2, 6, 11, dtype=int)           # 1e2 … 1e6
    times = [0.02 * n ** 0.93 * random.uniform(0.9, 1.1) for n in ns]
    return pd.DataFrame({"N": ns, "time_ms": times})


# ----------------------------------------------------------------------
# Matplotlib helper
# ----------------------------------------------------------------------
def render_figure(df: pd.DataFrame, out_file: Path) -> None:
    """Save a JPEG version of the scalability plot."""
    fig, ax = plt.subplots(figsize=(4.6, 3.2))
    ax.loglog(df["N"], df["time_ms"], "o-", label="DT compiler")
    ax.set_xlabel("Input size N")
    ax.set_ylabel("Elapsed time [ms]")
    ax.grid(True, which="both", ls=":")
    ax.legend()
    plt.tight_layout()
    plt.savefig(
        out_file,
        dpi=300,
        bbox_inches="tight",
        format="jpg",   # key change: JPEG not PNG
    )
    plt.close(fig)


# ----------------------------------------------------------------------
# Report & helper artefacts
# ----------------------------------------------------------------------
def write_tikz_coordinates(df: pd.DataFrame, out_file: Path) -> None:
    with out_file.open("w", encoding="utf-8") as f:
        for n, t in df.itertuples(index=False):
            f.write(f"({n},{t:.3f})\n")


def write_analysis_report(df: pd.DataFrame, out_file: Path) -> None:
    log_n = np.log10(df["N"])
    log_t = np.log10(df["time_ms"])
    coeffs = np.polyfit(log_n, log_t, 1)
    slope, intercept = coeffs
    r2 = np.corrcoef(log_n, log_t)[0, 1] ** 2
    with out_file.open("w", encoding="utf-8") as f:
        f.write(f"Slope (α)  : {slope:6.3f}\n")
        f.write(f"R²         : {r2:6.4f}\n")
        f.write(f"Intercept  : {intercept:6.3f}\n")
        f.write("\nRaw data:\n")
        df.to_csv(f, index=False)


# ----------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------
def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path(__file__).resolve().parents[3] / "data" / "scalability",
        help="directory for all generated outputs",
    )
    args = parser.parse_args()
    out_dir: Path = args.output_dir
    out_dir.mkdir(parents=True, exist_ok=True)

    df = run_benchmarks()
    df.to_csv(out_dir / "timing_data.csv", index=False)

    render_figure(df, out_dir / "scalability_figure.jpg")
    write_tikz_coordinates(df, out_dir / "tikz_coordinates.txt")
    write_analysis_report(df, out_dir / "analysis_report.txt")

    print(f"All outputs saved to {out_dir}")


if __name__ == "__main__":
    main()
