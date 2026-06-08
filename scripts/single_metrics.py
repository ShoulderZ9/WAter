#!/usr/bin/env python3
import argparse
import json
from pathlib import Path


def _round_key(round_id):
    return str(round_id)


def _round_cost(round_data):
    return sum(round_data.values())


def _infer_verified_entries(payload, default_round):
    data = payload.get("data", {})
    default_data = data.get(default_round)
    if default_data is None:
        raise ValueError(f"Default round {default_round} not found in single.json data.")

    default_queries = set(default_data)
    entries = []
    for round_id, query_times in data.items():
        if set(query_times) == default_queries:
            entries.append(
                {
                    "round": str(round_id),
                    "time": None,
                    "cost": _round_cost(query_times),
                }
            )

    entries.sort(key=lambda item: int(item["round"]))
    return entries


def _verified_entries(payload, default_round):
    cost_entries = payload.get("cost") or []
    if cost_entries:
        return [
            {
                "round": str(item["round"]),
                "time": item.get("time"),
                "cost": item["cost"],
            }
            for item in cost_entries
            if "round" in item and "cost" in item
        ], "cost"

    return _infer_verified_entries(payload, default_round), "inferred_from_full_workload_data"


def analyze_single_metrics(single_json_path, cutoff_seconds=15000, default_round="16", verbose=True):
    single_json_path = Path(single_json_path)
    with single_json_path.open("r", encoding="utf-8") as f:
        payload = json.load(f)

    data = payload.get("data", {})
    default_round = _round_key(default_round)
    if default_round not in data:
        raise ValueError(f"Default round {default_round} not found in {single_json_path}.")

    default_cost = _round_cost(data[default_round])
    verified_entries, verified_source = _verified_entries(payload, default_round)
    verified_entries = [entry for entry in verified_entries if str(entry["round"]) in data]

    worse_than_default = [
        entry for entry in verified_entries
        if entry["cost"] > default_cost
    ]
    wasted_ratio = (
        len(worse_than_default) / len(verified_entries)
        if verified_entries else 0.0
    )

    if verified_source == "cost":
        candidates_before_cutoff = [
            entry for entry in verified_entries
            if entry["time"] is not None and entry["time"] <= cutoff_seconds
        ]
    else:
        candidates_before_cutoff = verified_entries

    best_entry = (
        min(candidates_before_cutoff, key=lambda entry: entry["cost"])
        if candidates_before_cutoff else None
    )

    result = {
        "single_json_path": str(single_json_path),
        "cutoff_seconds": cutoff_seconds,
        "default_round": default_round,
        "default_cost_ms": default_cost,
        "default_cost_seconds": default_cost / 1000.0,
        "verified_source": verified_source,
        "verified_count": len(verified_entries),
        "worse_than_default_count": len(worse_than_default),
        "wasted_verification_ratio": wasted_ratio,
        "worse_than_default_rounds": [entry["round"] for entry in worse_than_default],
        "candidate_count_before_cutoff": len(candidates_before_cutoff),
        "final_full_workload_latency_ms": None if best_entry is None else best_entry["cost"],
        "final_full_workload_latency_seconds": None if best_entry is None else best_entry["cost"] / 1000.0,
        "best_round_before_cutoff": None if best_entry is None else best_entry["round"],
        "best_time_before_cutoff": None if best_entry is None else best_entry["time"],
    }

    if verbose:
        print(f"single_json: {single_json_path}")
        print(f"default_round: {default_round}")
        print(f"default_cost_ms: {default_cost:.3f}")
        print(f"default_cost_seconds: {default_cost / 1000.0:.3f}")
        print(f"verified_source: {verified_source}")
        if verified_source != "cost":
            print("warning: no cost list found; verified configs were inferred from full-workload data and cutoff time cannot be applied.")
        print(f"cutoff_seconds: {cutoff_seconds}")
        print(f"all_verified_configs: {len(verified_entries)}")
        print(f"configs_before_cutoff: {len(candidates_before_cutoff)}")
        print(f"verified_configs_worse_than_default: {len(worse_than_default)}")
        print(f"worse_than_default_rounds: {[entry['round'] for entry in worse_than_default]}")
        print(f"wasted_verification_ratio: {wasted_ratio:.6f}")
        if best_entry is None:
            print("final_full_workload_latency: None (no verified config before cutoff)")
        else:
            print(f"best_round_before_cutoff: {best_entry['round']}")
            print(f"best_time_before_cutoff: {best_entry['time']}")
            print(f"final_full_workload_latency_ms: {best_entry['cost']:.3f}")
            print(f"final_full_workload_latency_seconds: {best_entry['cost'] / 1000.0:.3f}")

    return result


def main():
    parser = argparse.ArgumentParser(
        description="Compute final full-workload latency and wasted verification ratio from a single.json file."
    )
    parser.add_argument("single_json_path", help="Path to a single.json file.")
    parser.add_argument(
        "--cutoff",
        type=float,
        default=15000,
        help="Cutoff time in seconds for final full-workload latency. Defaults to 15000.",
    )
    parser.add_argument(
        "--default-round",
        default="16",
        help="Round id used as the default full-workload config. Defaults to 16.",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Also print the returned metrics dictionary as JSON.",
    )
    args = parser.parse_args()

    result = analyze_single_metrics(
        args.single_json_path,
        cutoff_seconds=args.cutoff,
        default_round=args.default_round,
        verbose=True,
    )
    if args.json:
        print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
