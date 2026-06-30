#!/usr/bin/env python3
"""Merge two GPTuner/SMAC history folders for plotting.

The default layout matches:
  /Users/bihan/Documents/workload_compress/WC_data/aliyun_tpcds/gptuner/direct_optimize/<seed>

Example:
    python3 scripts/merge_gptuner_history.py 191 829 --overwrite

This creates:
  .../direct_optimize/191_m
"""

import argparse
import copy
import json
import shutil
from pathlib import Path


DEFAULT_DIRECT_OPTIMIZE_DIR = Path(
    "/Users/bihan/Documents/workload_compress/WC_data/aliyun_tpcds/gptuner/direct_optimize"
)
DEFAULT_CONFIG_ID = 16
COARSE_TRIALS = 30


def resolve_history_dir(value):
    path = Path(value)
    if path.is_absolute() or path.parent != Path("."):
        return path
    return DEFAULT_DIRECT_OPTIMIZE_DIR / value


def seed_name(history_dir):
    return history_dir.name


def stage_dir(history_dir, stage):
    stage_root = history_dir / stage
    candidates = [p for p in sorted(stage_root.iterdir()) if p.is_dir()]
    if not candidates:
        raise FileNotFoundError(f"No stage subdirectory found under {stage_root}")
    return candidates[0]


def load_json(path):
    with open(path, "r") as f:
        return json.load(f)


def write_json(path, data):
    with open(path, "w") as f:
        json.dump(data, f, indent=4)
        f.write("\n")


def entry_to_dict(entry):
    if isinstance(entry, list):
        return {
            "config_id": entry[0],
            "instance": entry[1],
            "seed": entry[2],
            "budget": entry[3],
            "cost": entry[4],
            "time": entry[5],
            "status": entry[6],
            "starttime": entry[7],
            "endtime": entry[8],
            "additional_info": entry[9] if len(entry) > 9 else {},
        }
    return {
        "config_id": entry["config_id"],
        "instance": entry.get("instance"),
        "seed": entry.get("seed"),
        "budget": entry.get("budget"),
        "cost": entry["cost"],
        "time": entry.get("time", 0.0),
        "status": entry.get("status", 1),
        "starttime": entry.get("starttime", 0.0),
        "endtime": entry.get("endtime", 0.0),
        "additional_info": entry.get("additional_info", {}),
    }


def dict_to_old_entry(entry):
    return [
        entry["config_id"],
        entry.get("instance"),
        entry.get("seed"),
        entry.get("budget"),
        entry["cost"],
        entry.get("time", 0.0),
        entry.get("status", 1),
        entry.get("starttime", 0.0),
        entry.get("endtime", 0.0),
        entry.get("additional_info", {}),
    ]


def runhistory_entries(runhistory):
    return [entry_to_dict(entry) for entry in runhistory["data"]]


def entry_by_config_id(entries, config_id):
    for entry in entries:
        if int(entry["config_id"]) == int(config_id):
            return entry
    raise KeyError(f"config_id={config_id} not found")


def draw_times(coarse_entries, fine_entries):
    per_trial_times = []
    for idx, fine_entry in enumerate(fine_entries):
        if idx < COARSE_TRIALS and idx < len(coarse_entries):
            per_trial_times.append(abs(float(coarse_entries[idx].get("time", 0.0))))
        else:
            per_trial_times.append(abs(float(fine_entry.get("time", 0.0))))

    cumulative = []
    total = 0.0
    for duration in per_trial_times:
        total += duration
        cumulative.append(total)
    return cumulative


def scale_entry_cost(entry, ratio):
    entry = copy.deepcopy(entry)
    entry["cost"] = float(entry["cost"]) * ratio
    return entry


def recompute_trajectory(fine_entries):
    trajectory = []
    incumbent_id = None
    incumbent_cost = None
    walltime = 0.0

    for trial, entry in enumerate(fine_entries, start=1):
        if trial > COARSE_TRIALS:
            walltime += abs(float(entry.get("time", 0.0)))
        cost = float(entry["cost"])
        if incumbent_cost is None or cost < incumbent_cost:
            incumbent_cost = cost
            incumbent_id = entry["config_id"]
            trajectory.append(
                {
                    "config_ids": [incumbent_id],
                    "costs": [incumbent_cost],
                    "trial": min(trial, COARSE_TRIALS),
                    "walltime": walltime,
                }
            )

    rejected = [
        entry["config_id"]
        for entry in fine_entries
        if entry["config_id"] != incumbent_id
    ]
    return incumbent_id, rejected, trajectory


def merge_gptuner_history(a_dir, b_dir, output_dir=None, overwrite=False):
    a_dir = resolve_history_dir(a_dir)
    b_dir = resolve_history_dir(b_dir)
    output_dir = Path(output_dir) if output_dir else a_dir.with_name(f"{a_dir.name}_m")

    a_coarse_dir = stage_dir(a_dir, "coarse")
    a_fine_dir = stage_dir(a_dir, "fine")
    b_coarse_dir = stage_dir(b_dir, "coarse")
    b_fine_dir = stage_dir(b_dir, "fine")

    a_coarse = load_json(a_coarse_dir / "runhistory.json")
    a_fine = load_json(a_fine_dir / "runhistory.json")
    b_coarse = load_json(b_coarse_dir / "runhistory.json")
    b_fine = load_json(b_fine_dir / "runhistory.json")

    a_coarse_entries = runhistory_entries(a_coarse)
    a_fine_entries = runhistory_entries(a_fine)
    b_coarse_entries = runhistory_entries(b_coarse)
    b_fine_entries = runhistory_entries(b_fine)

    a_default_cost = float(entry_by_config_id(a_coarse_entries, DEFAULT_CONFIG_ID)["cost"])
    b_default_cost = float(entry_by_config_id(b_coarse_entries, DEFAULT_CONFIG_ID)["cost"])
    if b_default_cost == 0:
        raise ValueError("B default configuration cost is 0; cannot compute scale ratio.")
    ratio = a_default_cost / b_default_cost

    cutoff_time = draw_times(a_coarse_entries, a_fine_entries)[-1]
    b_cumulative_times = draw_times(b_coarse_entries, b_fine_entries)
    b_entries_to_append = [
        (entry, b_time)
        for entry, b_time in zip(b_fine_entries, b_cumulative_times)
        if b_time > cutoff_time
    ]

    merged_fine = copy.deepcopy(a_fine)
    merged_entries = copy.deepcopy(a_fine_entries)
    merged_configs = copy.deepcopy(a_fine.get("configs", {}))
    merged_origins = copy.deepcopy(a_fine.get("config_origins", {}))

    next_config_id = max(int(entry["config_id"]) for entry in merged_entries) + 1
    next_starttime = max(float(entry.get("endtime", 0.0)) for entry in merged_entries)

    b_configs = b_fine.get("configs", {})
    b_origins = b_fine.get("config_origins", {})
    appended_count = 0
    for b_entry, _ in b_entries_to_append:
        old_config_id = str(b_entry["config_id"])
        new_config_id = next_config_id
        next_config_id += 1

        new_entry = scale_entry_cost(b_entry, ratio)
        duration = abs(float(new_entry.get("time", 0.0)))
        new_entry["config_id"] = new_config_id
        new_entry["seed"] = int(a_dir.name) if a_dir.name.isdigit() else new_entry.get("seed")
        new_entry["starttime"] = next_starttime
        new_entry["endtime"] = next_starttime + duration
        next_starttime = new_entry["endtime"]
        merged_entries.append(new_entry)

        if old_config_id in b_configs:
            merged_configs[str(new_config_id)] = copy.deepcopy(b_configs[old_config_id])
        if old_config_id in b_origins:
            merged_origins[str(new_config_id)] = copy.deepcopy(b_origins[old_config_id])
        appended_count += 1

    merged_fine["data"] = [dict_to_old_entry(entry) for entry in merged_entries]
    merged_fine["configs"] = merged_configs
    merged_fine["config_origins"] = merged_origins
    merged_fine["stats"] = {
        "submitted": len(merged_entries),
        "finished": len(merged_entries),
        "running": 0,
    }

    if output_dir.exists():
        if not overwrite:
            raise FileExistsError(f"{output_dir} already exists. Use --overwrite to replace it.")
        shutil.rmtree(output_dir)
    shutil.copytree(a_dir, output_dir, ignore=shutil.ignore_patterns(".DS_Store"))

    output_fine_dir = stage_dir(output_dir, "fine")
    write_json(output_fine_dir / "runhistory.json", merged_fine)

    fine_optimization_path = output_fine_dir / "optimization.json"
    if fine_optimization_path.exists():
        fine_optimization = load_json(fine_optimization_path)
        merged_time = draw_times(a_coarse_entries, merged_entries)[-1]
        fine_optimization["used_walltime"] = merged_time - sum(
            abs(float(entry.get("time", 0.0))) for entry in a_coarse_entries[:COARSE_TRIALS]
        )
        fine_optimization["used_target_function_walltime"] = sum(
            abs(float(entry.get("time", 0.0))) for entry in merged_entries[COARSE_TRIALS:]
        )
        fine_optimization["finished"] = True
        write_json(fine_optimization_path, fine_optimization)

    fine_scenario_path = output_fine_dir / "scenario.json"
    if fine_scenario_path.exists():
        fine_scenario = load_json(fine_scenario_path)
        fine_scenario["n_trials"] = len(merged_entries)
        write_json(fine_scenario_path, fine_scenario)

    fine_intensifier_path = output_fine_dir / "intensifier.json"
    if fine_intensifier_path.exists():
        fine_intensifier = load_json(fine_intensifier_path)
        incumbent_id, rejected, trajectory = recompute_trajectory(merged_entries)
        fine_intensifier["incumbent_ids"] = [incumbent_id]
        fine_intensifier["rejected_config_ids"] = rejected
        fine_intensifier["incumbents_changed"] = len(trajectory)
        fine_intensifier["trajectory"] = trajectory
        write_json(fine_intensifier_path, fine_intensifier)

    return {
        "a_dir": str(a_dir),
        "b_dir": str(b_dir),
        "output_dir": str(output_dir),
        "a_default_cost": a_default_cost,
        "b_default_cost": b_default_cost,
        "ratio": ratio,
        "cutoff_time": cutoff_time,
        "a_fine_records": len(a_fine_entries),
        "appended_b_records": appended_count,
        "merged_fine_records": len(merged_entries),
    }


def main():
    parser = argparse.ArgumentParser(
        description=(
            "Merge a 20000s GPTuner history A with the post-cutoff portion of a "
            "50000s GPTuner history B, scaling B costs by default-cost ratio first."
        )
    )
    parser.add_argument("a_history", help="A history folder or seed name, e.g. 191.")
    parser.add_argument("b_history", help="B history folder or seed name, e.g. 829.")
    parser.add_argument(
        "-o",
        "--output",
        default=None,
        help="Output folder. Defaults to A with suffix _m, e.g. 191_m.",
    )
    parser.add_argument("--overwrite", action="store_true", help="Replace output folder if it exists.")
    args = parser.parse_args()

    summary = merge_gptuner_history(
        args.a_history,
        args.b_history,
        output_dir=args.output,
        overwrite=args.overwrite,
    )
    for key, value in summary.items():
        print(f"{key}: {value}")


if __name__ == "__main__":
    main()
