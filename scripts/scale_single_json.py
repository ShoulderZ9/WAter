#!/usr/bin/env python3
import argparse
import json
from pathlib import Path


def scale_single_json(input_path, target_cost_seconds, output_path=None, reference_round="16"):
    input_path = Path(input_path)
    if output_path is None:
        output_path = input_path.with_name(f"{input_path.stem}_s{input_path.suffix}")
    else:
        output_path = Path(output_path)

    with input_path.open("r", encoding="utf-8") as f:
        payload = json.load(f)

    round_data = payload.get("data", {})
    if reference_round not in round_data:
        raise ValueError(f"Round {reference_round} not found in {input_path}.")

    current_cost_ms = sum(round_data[reference_round].values())
    if current_cost_ms <= 0:
        raise ValueError(f"Round {reference_round} cost must be positive, got {current_cost_ms}.")

    target_cost_ms = float(target_cost_seconds) * 1000.0
    scale_ratio = target_cost_ms / current_cost_ms

    for query_times in round_data.values():
        for query_name, query_time in query_times.items():
            query_times[query_name] = query_time * scale_ratio

    for cost_item in payload.get("cost", []):
        if "cost" in cost_item:
            cost_item["cost"] = cost_item["cost"] * scale_ratio

    with output_path.open("w", encoding="utf-8") as f:
        json.dump(payload, f, indent=4)

    return {
        "input_path": str(input_path),
        "output_path": str(output_path),
        "reference_round": reference_round,
        "current_cost_seconds": current_cost_ms / 1000.0,
        "target_cost_seconds": target_cost_seconds,
        "scale_ratio": scale_ratio,
    }


def main():
    parser = argparse.ArgumentParser(
        description="Scale all costs in a single.json file using a target total cost for one reference round."
    )
    parser.add_argument("input_path", help="Path to the source single.json file")
    parser.add_argument("target_cost_seconds", type=float, help="Target total cost for the reference round, in seconds")
    parser.add_argument(
        "--output",
        dest="output_path",
        help="Optional output path. Defaults to '<input>_s.json' next to the source file.",
    )
    parser.add_argument(
        "--round",
        dest="reference_round",
        default="16",
        help="Reference round used to compute the scale ratio. Defaults to 16.",
    )
    args = parser.parse_args()

    summary = scale_single_json(
        input_path=args.input_path,
        target_cost_seconds=args.target_cost_seconds,
        output_path=args.output_path,
        reference_round=args.reference_round,
    )
    print(json.dumps(summary, indent=2))


if __name__ == "__main__":
    main()
