import argparse
import json
import os
import re
import time
from configparser import ConfigParser

from dbms.postgres import PgDBMS
from vanilla_tuner.gptuner.coarse_stage import CoarseStage
from vanilla_tuner.gptuner.fine_stage import FineStage
from WAter_runner.runner_gptuner import RunnerGPTuner


def infer_seed(single_path):
    name = os.path.basename(single_path)
    match = re.match(r"(\d+)_single\.json$", name)
    if not match:
        raise ValueError(
            "Cannot infer seed from single filename. Use --seed explicitly."
        )
    return int(match.group(1))


def get_time_dict(dbms, time_dict_path, whole_workload_queries):
    dbms.reset_config()
    dbms.reconfigure()
    time_dict = {}
    for name, sql in whole_workload_queries.items():
        print(f"[time_dict] start {name}", flush=True)
        start_time = time.time()
        dbms.exec_queries(sql)
        time_dict[name] = time.time() - start_time
        print(f"[time_dict] finish {name}", flush=True)
    with open(time_dict_path, "w") as f:
        json.dump(time_dict, f, indent=4)
    return time_dict


def load_time_dict(dbms, time_dict_path, whole_workload_queries):
    try:
        with open(time_dict_path, "r") as f:
            time_dict = json.load(f)
        if set(time_dict.keys()) != set(whole_workload_queries.keys()):
            raise ValueError("time_dict keys do not match current workload")
    except Exception as e:
        print(f"Regenerating '{time_dict_path}' because it is missing or incompatible: {e}")
        time_dict = get_time_dict(dbms, time_dict_path, whole_workload_queries)
        print("get_time_dict() finishes.")
    return time_dict


def load_workload(workload_name):
    workload_queries = {}
    workload_path = os.path.join("workload", workload_name)
    for sql in os.listdir(workload_path):
        with open(os.path.join(workload_path, sql), "r") as f:
            workload_queries[sql.split(".")[0]] = f.read()
    return workload_queries


def main():
    parser = argparse.ArgumentParser(
        description="Resume WAter + GPTuner on tpcds_select from a single.json file."
    )
    parser.add_argument("--single", required=True, help="Path to the *_single.json file to resume.")
    parser.add_argument("--seed", type=int, default=None, help="Seed. Defaults to the prefix of *_single.json.")
    parser.add_argument("--target-budget-s", type=float, default=50000.0)
    parser.add_argument(
        "--used-budget-s",
        type=float,
        default=None,
        help="Override already-used wall-clock budget. Useful when the single cost.time is missing or not the 20000s baseline.",
    )
    parser.add_argument("--workload-name", default="tpcds_select")
    args = parser.parse_args()

    if args.workload_name != "tpcds_select":
        raise ValueError("This resume entry is intentionally limited to tpcds_select.")

    single_path = os.path.abspath(args.single)
    seed = args.seed if args.seed is not None else infer_seed(single_path)
    print(f"Input single: {single_path}")
    print(f"Seed: {seed}")

    config = ConfigParser()
    config.read("./configs/postgres.ini")
    dbms = PgDBMS.from_file(config)

    target_knobs_path = "./knowledge_collection/postgres/target_knobs.txt"
    workload_queries = load_workload(args.workload_name)

    time_dict_path = f"./{args.workload_name}_time_dict.json"
    time_dict = load_time_dict(dbms, time_dict_path, workload_queries)
    timeout = 2 * sum(time_dict.values())

    tuner = [
        CoarseStage(
            dbms=dbms,
            target_knobs_path=target_knobs_path,
            timeout=timeout,
            seed=seed,
            workload_queries=workload_queries,
        ),
        FineStage(
            dbms=dbms,
            target_knobs_path=target_knobs_path,
            timeout=timeout,
            seed=seed,
            workload_queries=workload_queries,
        ),
    ]

    runner = RunnerGPTuner(
        tuner,
        dbms,
        timeout,
        target_knobs_path,
        seed,
        workload_queries,
        args.workload_name,
    )
    runner.optimize_from_single(
        single_path=single_path,
        target_budget_s=args.target_budget_s,
        assumed_used_budget_s=args.used_budget_s,
    )


if __name__ == "__main__":
    main()

""" PYTHONPATH=src python3 src/run/WAter/resume_gptuner_from_single.py \
  --single optimization_results/postgres/single/253_single.json \
  --used-budget-s 20000 \
  --target-budget-s 50000 """