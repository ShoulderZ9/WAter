#!/usr/bin/env python3
"""Merge the cost timeline of two single.json files.

Example:
    python3 scripts/merge_single_cost.py \
        /path/to/253_single.json \
        /path/to/819_single_s.json

This writes /path/to/253_single_m.json by default.
"""

import argparse
import copy
import json
from pathlib import Path


DEFAULT_SINGLE_DIR = Path("/Users/bihan/Documents/workload_compress/single")


def _record_time(record):
    try:
        return float(record["time"])
    except (KeyError, TypeError, ValueError) as exc:
        raise ValueError(f"Invalid cost record without numeric time: {record}") from exc


def _default_output_path(a_path):
    path = Path(a_path)
    if path.name.endswith("_single.json"):
        return path.with_name(path.name.replace("_single.json", "_single_m.json"))
    if path.name.endswith(".json"):
        return path.with_name(f"{path.stem}_m.json")
    return path.with_name(f"{path.name}_m")


def _resolve_single_path(path):
    path = Path(path)
    if path.is_absolute() or path.parent != Path("."):
        return path
    return DEFAULT_SINGLE_DIR / path


def load_single(path):
    with open(path, "r") as f:
        data = json.load(f)
    if "cost" not in data or not isinstance(data["cost"], list):
        raise ValueError(f"{path} does not contain a list field named 'cost'.")
    return data


def merge_single_cost(a_single, b_single):
    """Return a copy of A whose cost timeline is continued by B.

    Let k be the time of A's last cost record. The merged cost is:
      1. all A cost records with time <= k
      2. all B cost records with time > k

    Other top-level fields are copied from A unchanged.
    """
    if not a_single["cost"]:
        raise ValueError("A single has an empty cost list; cannot infer cutoff time k.")

    cutoff_time = _record_time(a_single["cost"][-1])
    a_cost = [record for record in a_single["cost"] if _record_time(record) <= cutoff_time]
    b_cost = [record for record in b_single["cost"] if _record_time(record) > cutoff_time]

    merged = copy.deepcopy(a_single)
    merged["cost"] = copy.deepcopy(a_cost + b_cost)
    return merged, cutoff_time, len(a_cost), len(b_cost)


def write_single(path, data):
    with open(path, "w") as f:
        json.dump(data, f, indent=4)
        f.write("\n")


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Merge A_single.json and B_single_s.json into A_single_m.json by "
            "keeping A cost records up to A's last time k, then appending B cost records after k."
        )
    )
    parser.add_argument("a_single", help="Base single file, e.g. 253_single.json with a 20000s budget.")
    parser.add_argument("b_single", help="Longer single file, e.g. 819_single_s.json with a 50000s budget.")
    parser.add_argument(
        "-o",
        "--output",
        default=None,
        help="Output path. Defaults to A's name with _single.json replaced by _single_m.json.",
    )
    args = parser.parse_args()

    a_path = _resolve_single_path(args.a_single)
    b_path = _resolve_single_path(args.b_single)
    a_data = load_single(a_path)
    b_data = load_single(b_path)
    merged, cutoff_time, a_count, b_count = merge_single_cost(a_data, b_data)

    output_path = Path(args.output) if args.output else _default_output_path(a_path)
    write_single(output_path, merged)

    print(f"A single: {a_path}")
    print(f"B single: {b_path}")
    print(f"A cutoff k: {cutoff_time}")
    print(f"Kept A cost records: {a_count}")
    print(f"Appended B cost records: {b_count}")
    print(f"Merged cost records: {len(merged['cost'])}")
    print(f"Wrote: {output_path}")


if __name__ == "__main__":
    main()
