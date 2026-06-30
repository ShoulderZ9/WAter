import sys, os, json, re, time
from WAter_runner.runner_template import RunnerTemplate
from vanilla_tuner.gptuner.coarse_stage import CoarseStage
from vanilla_tuner.gptuner.fine_stage import FineStage
from smac.runhistory.dataclasses import TrialValue

class RunnerGPTuner(RunnerTemplate):
    def __init__(self, tuner, dbms, timeout, target_knobs_path, seed, whole_workload_queries, workload_name):
        super().__init__(tuner, dbms, timeout, target_knobs_path, seed, whole_workload_queries, workload_name)
        self.record_single_path = self.cur_tuner.record_single_path
        
    def optimize(self):
        self.start_time = time.time()

        ###########################
        ##### 1. Coarse Stage #####
        ###########################
        
        # GPTuner's coarse_stage is recarded as the first time slice 
        self.cur_stage += 1
        self.cur_tuner.workload_queries = self.cur_workload_queries
        print(f"self.cur_tuner.workload_queries：{self.cur_tuner.workload_queries.keys()}")

        # Get subset's performance on default configuration
        self.subset_default_score = 0
        for idx, value in self.time_dict.items():
            if idx in self.cur_tuner.workload_queries:
                self.subset_default_score += value
        print(f"self.subset_default_score：{self.subset_default_score}")
            
        tuner_start = time.time()
        smac = self.cur_tuner.optimize(
            name = f"../optimization_results/{self.dbms.name}/coarse/", 
            trials_number=30, 
            initial_config_number=15)
        self.account_time("tuner_overhead_s", time.time() - tuner_start)
        block_start = time.time()
        accounted_before = self.total_accounted_time()
        smac.optimize()
        self.account_unclassified_block_as_tuner_overhead(block_start, accounted_before)
        self.round = self.cur_tuner.round
        time.sleep(10)
        self.update_single_dict()

        # choose the top-k configurations that perform well on current subset to verify on the whole workload
        with open(self.cur_tuner.runhistory_path, 'r') as f:
            runhistory_data = json.load(f)["data"]
        self.success_run_last = [k for k, v in self.single_dict["data"].items() if self.timeout * 1000 not in v.values()]
        self.success_run_last = sorted(self.success_run_last, key=lambda k: runhistory_data[int(k)-1]["cost"])
        # configurations perform worse than the default configurations on the current subset are discarded
        self.exec_whole_last = [config for config in self.success_run_last[:min(int(30*self.verify_ratio), len(self.success_run_last))] if runhistory_data[int(config)-1]["cost"] <= self.subset_default_score * 1.0 * 1000]
        if str(16) not in self.exec_whole_last:
            self.exec_whole_last.append(str(16))
        print(f"self.exec_whole_last: {self.exec_whole_last}")
        self.exec_whole_idx.extend(self.exec_whole_last)
        block_start = time.time()
        accounted_before = self.total_accounted_time()
        self.verifier.exec_whole()
        self.account_unclassified_block_as_tuner_overhead(block_start, accounted_before)
        self.flush_time_accounting()

        #########################
        ##### 2. Fine Stage #####
        #########################
        stage_to_run = self.update_threshold
        self.cur_tuner = self.tuner[1]
        self.cur_tuner.round = self.round
        
        while True:
            ##############################
            ##### 2.1 Timeout or not #####
            ##############################
            if time.time() - self.start_time > self.tuning_budget_s:
                print("tuning budget reached")
                print(f"total time: {time.time() - self.start_time}")
                self.flush_time_accounting()
                return
            self.cur_stage += 1

            ##################################################
            ##### 2.2 Need to increase comp_ratio or not #####
            ##################################################
            # 运行 GSUM / random 固定子集时注释
            # self.whole_time_lst = [sum([v1 for k1, v1 in v.items()]) for k, v in self.single_dict["data"].items() if k in self.exec_whole_idx]
            # self.cur_incumbent_cost = min(self.whole_time_lst)
            # print(f"Incumbent:{self.last_incumbent_cost, self.cur_incumbent_cost}")
            #
            # if self.cur_incumbent_cost < self.last_incumbent_cost:
            #     stage_to_run = self.update_threshold
            #     self.last_incumbent_cost = self.cur_incumbent_cost
            # else:
            #     stage_to_run -= 1
            #
            # if stage_to_run == 0:
            #     stage_to_run = self.update_threshold
            #     self.comp_ratio += self.comp_ratio_add_unit
            #     print(f"Increase workload comp_ratio from {self.comp_ratio - self.comp_ratio_add_unit} to {self.comp_ratio}")

            ###############################################################
            ##### 2.3 Obtain a new subset and fill in missing history #####
            ###############################################################
            # 运行 GSUM / random 固定子集时注释第一行
            # tuner_start = time.time()
            # self.cur_workload_queries = self.compressor.select_queries()
            # self.account_time("tuner_overhead_s", time.time() - tuner_start)
            self.cur_tuner.workload_queries = self.cur_workload_queries
            block_start = time.time()
            accounted_before = self.total_accounted_time()
            self.history_reuser.exec_selected_on_history()
            self.account_unclassified_block_as_tuner_overhead(block_start, accounted_before)
            # Get subset's performance on default configuration
            self.subset_default_score = 0
            for idx, value in self.time_dict.items():
                if idx in self.cur_tuner.workload_queries:
                    self.subset_default_score += value
            print(f"self.subset_default_score：{self.subset_default_score}")

            ###################################
            ##### 2.4 Tune the new subset #####
            ###################################
            self.success_run_last = []
            stage_budget = self.success_per_stage
            # Set subset_default_score for WAter mode to initialize tuner with single data
            self.cur_tuner.subset_default_score = self.subset_default_score
            tuner_start = time.time()
            smac = self.cur_tuner.optimize(
                name = f"../optimization_results/{self.dbms.name}/fine/",
                trials_number=2000) # history trials + new tirals
            self.account_time("tuner_overhead_s", time.time() - tuner_start)
            while True:
                tuner_start = time.time()
                info = smac.ask()
                self.account_time("tuner_overhead_s", time.time() - tuner_start)
                st = time.time()
                cost = self.cur_tuner.set_and_replay(config=info.config, seed=info.seed)
                value = TrialValue(cost=cost, time=time.time()-st)
                tuner_start = time.time()
                smac.tell(info, value)
                self.account_time("tuner_overhead_s", time.time() - tuner_start)
                if cost != self.timeout * 1000:
                    stage_budget -= 1
                    self.success_run_last.append(str(self.cur_tuner.round))
                if stage_budget == 0:
                    break
            self.round = self.cur_tuner.round
            print(f"self.success_run_last:{self.success_run_last}")
            time.sleep(1)

            #####################################################################
            ##### 2.5 Verify promising configurations on the whole workload #####
            #####################################################################
            tuner_start = time.time()
            self.verifier.select_round_to_run()
            self.account_time("tuner_overhead_s", time.time() - tuner_start)
            block_start = time.time()
            accounted_before = self.total_accounted_time()
            self.verifier.exec_whole()
            self.account_unclassified_block_as_tuner_overhead(block_start, accounted_before)
            self.flush_time_accounting()
            
