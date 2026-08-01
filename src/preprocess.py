"""Preprocess step: raw/hour.csv -> the featured frame.

SageMaker mounts the input channel and uploads whatever lands in the
output directory; nothing here talks to S3 directly.
"""

import argparse
from pathlib import Path

import pandas as pd

TARGET = "cnt"

DROP = ["instant", "dteday", "casual", "registered", TARGET]


def parse_args():
    p = argparse.ArgumentParser()
    p.add_argument("--input-dir", default="/opt/ml/processing/input")
    p.add_argument("--output-dir", default="/opt/ml/processing/output")
    p.add_argument("--input-file", default="hour.csv")
    return p.parse_args()


def main():
    args = parse_args()

    source = Path(args.input_dir) / args.input_file
    if not source.exists():
        available = sorted(p.name for p in Path(args.input_dir).glob("*.csv"))
        raise FileNotFoundError(f"{args.input_file} not in {args.input_dir}; found {available}")

    df = pd.read_csv(source)
    print(f"loaded {len(df)} rows from {source}", flush=True)

    # Guard the shape, not just the filename.
    assert "hr" in df.columns, f"{args.input_file} has no hr column -- is this the daily file?"

    leak = (df.casual + df.registered != df[TARGET]).sum()
    assert leak == 0, f"{leak} rows where casual + registered != cnt"

    features = [c for c in df.columns if c not in DROP]

    # yr stays in features and doubles as the train/test split key.
    featured = df[features + [TARGET]]

    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    out = out_dir / "hour.parquet"
    featured.to_parquet(out, index=False)

    print(f"{featured.shape[0]} rows x {featured.shape[1]} cols", flush=True)
    print(f"{len(features)} features: {features}", flush=True)
    print(f"written to {out}", flush=True)


if __name__ == "__main__":
    main()
