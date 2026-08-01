"""Bike sharing demand training entry point for a SageMaker training job.

SageMaker mounts the S3 channel locally and expects the model written to
SM_MODEL_DIR; it tars that directory and uploads it. Nothing here talks to S3
directly.
"""

import argparse
import os
from pathlib import Path

import joblib
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score

TARGET = "cnt"

DROP = ["instant", "dteday", "casual", "registered", TARGET]


def parse_args():
    p = argparse.ArgumentParser()

    p.add_argument("--n-estimators", type=int, default=100)
    p.add_argument("--max-depth", type=int, default=None)
    p.add_argument("--min-samples-leaf", type=int, default=5)
    p.add_argument("--random-state", type=int, default=42)

    p.add_argument("--train", default=os.environ.get("SM_CHANNEL_TRAIN", "/opt/ml/input/data/train"))
    p.add_argument("--model-dir", default=os.environ.get("SM_MODEL_DIR", "/opt/ml/model"))

    return p.parse_args()


def load(channel_dir):
    """Read the training channel, whichever format it arrived in.

    A direct job points this at raw/ and gets CSV; the pipeline feeds it
    the preprocess step's parquet. Both callers stay working.
    """
    root = Path(channel_dir)

    for pattern, reader in (("*.parquet", pd.read_parquet), ("*.csv", pd.read_csv)):
        files = sorted(root.glob(pattern))
        if files:
            return reader(files[0])

    raise FileNotFoundError(f"no .parquet or .csv found in {channel_dir}")


def main():
    args = parse_args()

    df = load(args.train)
    print(f"loaded {len(df)} rows from {args.train}", flush=True)

    features = [c for c in df.columns if c not in DROP]

    train, test = df[df.yr == 0], df[df.yr == 1]
    print(f"train={len(train)} test={len(test)} features={len(features)}", flush=True)

    model = RandomForestRegressor(
        n_estimators=args.n_estimators,
        max_depth=args.max_depth,
        min_samples_leaf=args.min_samples_leaf,
        random_state=args.random_state,
        n_jobs=-1,
    )
    model.fit(train[features], train[TARGET])

    pred = model.predict(test[features])
    rmse = np.sqrt(mean_squared_error(test[TARGET], pred))

    print(f"rmse={rmse:.4f}", flush=True)
    print(f"mae={mean_absolute_error(test[TARGET], pred):.4f}", flush=True)
    print(f"r2={r2_score(test[TARGET], pred):.4f}", flush=True)

    out = Path(args.model_dir) / "model.joblib"
    joblib.dump(model, out)

    # Saved alongside the model so inference reconstructs the column order.
    joblib.dump(features, Path(args.model_dir) / "features.joblib")

    print(f"model written to {out}", flush=True)


if __name__ == "__main__":
    main()
