from abc import ABC, abstractmethod
import time, os, json, re, multiprocessing
from WAter.workload_compression import WorkloadCompressor
from WAter.config_verification import ConfigVerifier
from WAter.history_reuse import HistoryReuser
import configparser
from diagnostics import log_event, memory_snapshot

TIME_ACCOUNTING_KEYS = [
    "missing_history_query_execution_s",
    "subset_tuning_execution_s",
    "full_workload_verification_s",
    "tuner_overhead_s",
    "db_restart_deployment_overhead_s",
]


class RunnerTemplate(ABC):
    def __init__(self, tuner, dbms, timeout, target_knobs_path, seed, whole_workload_queries, workload_name):
        self.dbms = dbms
        self.seed = seed
        self.whole_workload_queries = {key: whole_workload_queries[key] for key in sorted(whole_workload_queries, key=lambda x: x[0])}
        self.time_dict_path = f"./{workload_name}_time_dict.json"
        self.record_single_path = ""
        self.ini_file_path = "./configs/water_params.ini"
        self.cur_stage = 0 # current time_slice
        self.round = 0 # number of finished round
        self.tuner = tuner
        self.cur_tuner = self.tuner[0]  # The tuner of coarse_stage is tuner[0] and the tuner of fine_stage is tuner[1]
        self.single_dict = {}
        self.exec_whole_idx = []
        self.exec_whole_last = []
        self.whole_time_lst = []
        self.time_accounting = {key: 0.0 for key in TIME_ACCOUNTING_KEYS}
        self.time_accounting_counts = {
            "missing_history_queries": 0,
            "subset_tuning_configs": 0,
            "full_workload_verification_queries": 0,
            "db_deployments": 0,
        }
        self.time_accounting_query_ms = {
            "missing_history_query_execution_ms": 0.0,
            "subset_tuning_execution_ms": 0.0,
            "full_workload_verification_ms": 0.0,
        }
        self.cur_incumbent_cost, self.last_incumbent_cost = timeout*1000, timeout*1000
        self.target_knobs = self.cur_tuner.knob_select()
        self.num_knobs, self.cat_knobs = self.get_knob_type()
        self.timeout = timeout
        print(f"timeout: {self.timeout}")
        with open(self.time_dict_path, 'r') as f:
            self.time_dict = json.load(f)
        if set(self.time_dict.keys()) != set(self.whole_workload_queries.keys()):
            raise ValueError(
                f"time_dict keys in {self.time_dict_path} do not match workload {workload_name}. "
                "Please regenerate the workload-specific time_dict."
            )

        self.get_init_params()

        # initialize WorkloadCompressor
        self.compressor = WorkloadCompressor(self)
        self.cur_workload_queries = self.compressor.get_init_sql(
            self.init_subset_method,
            workload_name,
            self.comp_ratio,
            self.seed,
        )
        print(f"cur_workload_queries: {self.cur_workload_queries.keys()}")

        # initialize HistoryReuser
        self.history_reuser = HistoryReuser(self)

        # initialize ConfigVerifier
        self.verifier = ConfigVerifier(self)

        for tuner in self.tuner:
            tuner.time_accounting_runner = self

    def get_init_params(self):
        config = configparser.ConfigParser()
        config.read(self.ini_file_path)

        self.tuning_budget_s = config.getint('WATER', 'tuning_budget_s')
        self.comp_ratio = config.getfloat('WATER', 'comp_ratio')
        self.init_subset_method = config.get('WATER', 'init_subset_method', fallback='gsum').strip().lower()
        self.verify_ratio = config.getfloat('WATER', 'verify_ratio')
        self.success_per_stage = config.getint('WATER', 'success_per_stage')
        self.update_threshold = config.getint('WATER', 'update_threshold')
        self.comp_ratio_add_unit = config.getfloat('WATER', 'comp_ratio_add_unit')

        print("--- WAter's hyperparameters have been initialized successfully ---")
        print(f"{'Parameter':<20}{'Value':<10}")
        print(f"{'-'*30}")
        print(f"{'tuning_budget_s':<20}{self.tuning_budget_s:<10}")
        print(f"{'comp_ratio':<20}{self.comp_ratio:<10}")
        print(f"{'init_subset_method':<20}{self.init_subset_method:<10}")
        print(f"{'verify_ratio':<20}{self.verify_ratio:<10}")
        print(f"{'success_per_stage':<20}{self.success_per_stage:<10}")
        print(f"{'update_threshold':<20}{self.update_threshold:<10}")
        print(f"{'comp_ratio_add_unit':<20}{self.comp_ratio_add_unit:<10}")
        print("------------------------------------------------------------------")

    def update_single_dict(self):
        with open(self.record_single_path, 'r') as f:
            self.single_dict = json.load(f)
            
    def dump_single_dict(self):
        self._attach_time_accounting(self.single_dict)
        with open(self.record_single_path, 'w') as f:
            json.dump(self.single_dict, f, indent=4)

    def account_time(self, key, seconds, count_key=None, query_ms_key=None, query_ms=0.0):
        if key not in self.time_accounting:
            self.time_accounting[key] = 0.0
        self.time_accounting[key] += max(float(seconds), 0.0)

        if count_key:
            self.time_accounting_counts[count_key] = self.time_accounting_counts.get(count_key, 0) + 1
        if query_ms_key:
            self.time_accounting_query_ms[query_ms_key] = (
                self.time_accounting_query_ms.get(query_ms_key, 0.0) + max(float(query_ms), 0.0)
            )

    def _build_time_accounting(self):
        total_accounted_s = sum(self.time_accounting.values())
        elapsed_s = None
        if hasattr(self, "start_time"):
            elapsed_s = max(time.time() - self.start_time, 0.0)

        accounting = {
            **self.time_accounting,
            "total_accounted_s": total_accounted_s,
            "counts": self.time_accounting_counts,
            "query_execution_ms": self.time_accounting_query_ms,
        }
        if elapsed_s is not None:
            accounting["elapsed_wall_time_s"] = elapsed_s
            accounting["unaccounted_wall_time_s"] = max(elapsed_s - total_accounted_s, 0.0)
        return accounting

    def total_accounted_time(self):
        return sum(self.time_accounting.values())

    def account_unclassified_block_as_tuner_overhead(self, block_start_time, accounted_before):
        block_elapsed = time.time() - block_start_time
        accounted_delta = self.total_accounted_time() - accounted_before
        overhead = block_elapsed - accounted_delta
        if overhead > 0:
            self.account_time("tuner_overhead_s", overhead)

    def _attach_time_accounting(self, single_dict):
        single_dict["time_accounting"] = self._build_time_accounting()

    def flush_time_accounting(self):
        if not self.record_single_path or not os.path.exists(self.record_single_path):
            return
        with open(self.record_single_path, 'r') as f:
            data = json.load(f)
        self._attach_time_accounting(data)
        with open(self.record_single_path, 'w') as f:
            json.dump(data, f, indent=4)
        self.single_dict = data

    def get_knob_type(self):
        num_knobs = []
        cat_knobs = []
        for knob in self.target_knobs:
            info = self.dbms.knob_info[knob]
            if info is None:
                self.target_knobs.remove(knob)   # this knob is not by the DBMS under specific version
                continue
            
            knob_type = info["vartype"]
            if knob_type in ["enum", "bool"]:
                cat_knobs.append(knob)
            elif knob_type in ["integer", "real"]:
                num_knobs.append(knob)
        print(f"num_knobs: {num_knobs}")
        print(len(num_knobs))
        print(f"cat_knobs: {cat_knobs}")
        print(len(cat_knobs))
        # quit()
        return num_knobs, cat_knobs

    def get_sql_time_with_timeout(self, sql, timeout_seconds, query_name=None, config_id=None):
        result_queue = multiprocessing.Queue()
        label = f"config={config_id}, query={query_name}"

        def task_wrapper(sql):
            try:
                log_event(f"verify child start {label}, {memory_snapshot()}")
                result = self.get_sql_time(sql, query_name=query_name, config_id=config_id)
                print(f"RESULT:{result}", flush=True)
                log_event(f"verify child finish {label}, result={result}, {memory_snapshot()}")
                result_queue.put(result)
            except BaseException as e:
                log_event(f"verify child exception {label}: {repr(e)}, {memory_snapshot()}")
                result_queue.put(self.timeout * 1000.0)

        p = multiprocessing.Process(target=task_wrapper, args=(sql,))
        log_event(f"start verify process {label}, timeout_seconds={timeout_seconds}, {memory_snapshot()}")
        p.start()
        log_event(f"verify process pid={p.pid} started {label}")
        p.join(timeout_seconds)
        if p.is_alive():
            log_event(f"verify process timeout {label}, pid={p.pid}, terminate, {memory_snapshot()}")
            p.terminate()
            p.join() 
            return self.timeout * 1000.0
        else:
            if result_queue.empty():
                log_event(
                    f"verify process ended without result {label}, "
                    f"pid={p.pid}, exitcode={p.exitcode}, treat as timeout, {memory_snapshot()}"
                )
                return self.timeout * 1000.0
            return result_queue.get()

    def get_sql_time(self, sql, query_name=None, config_id=None):
        dbms = self.dbms
        label = f"config={config_id}, query={query_name}"
        log_event(f"exec verify sql start {label}, {memory_snapshot()}")
        start_ms = time.time() * 1000.0
        flag = dbms.exec_queries(sql)
        end_ms = time.time() * 1000.0
        execution_time = end_ms - start_ms
        if flag: 
            log_event(f"exec verify sql done {label}, execution_ms={execution_time:.3f}, {memory_snapshot()}")
            return execution_time
        else:
            log_event(f"exec verify sql failed {label}, return timeout, {memory_snapshot()}")
            return self.timeout * 1000.0

    @abstractmethod
    def optimize(self):
        pass
