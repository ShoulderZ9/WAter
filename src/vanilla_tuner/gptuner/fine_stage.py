from abc import ABC, abstractmethod
from space_optimizer.default_space import DefaultSpace
from dbms.postgres import PgDBMS
from space_optimizer.gptuner_space.fine_space import FineSpace
import json
from smac import HyperparameterOptimizationFacade, Scenario, initial_design, intensifier
from ConfigSpace import (
    UniformIntegerHyperparameter,
    UniformFloatHyperparameter,
    CategoricalHyperparameter,
    Configuration,
)

class FineStage(FineSpace):

    def __init__(self, dbms, timeout, target_knobs_path, seed, workload_queries):
        super().__init__(dbms, timeout, target_knobs_path, seed, workload_queries)
        self.runhistory_path = f"./optimization_results/{self.dbms.name}/fine/{self.seed}/runhistory.json"

    def optimize(self, name, trials_number):
        scenario = Scenario(
            configspace=self.search_space,
            name = name,
            deterministic=True,
            n_trials=trials_number,
            seed=self.seed,
        )
        init_design = initial_design.DefaultInitialDesign(
            scenario,
        )
        
        try:
            with open(self.fine_path, 'r') as f:
                his_configs = json.load(f)["configs"]
        except:
            with open(self.coarse_path, 'r') as f:
                his_configs = json.load(f)["configs"]

        # Calculate costs based on mode
        if hasattr(self, 'subset_default_score') and self.subset_default_score is not None:
            # WAter mode: read from single_dict and calculate costs for current subset
            with open(self.record_single_path, "r") as json_file:
                single_data = json.load(json_file)
            
            query_names = list(self.workload_queries.keys())
            # Invalid config cost: 2x default time for this subset (converted to ms)
            invalid_cost = self.subset_default_score * 2 * 1000
            costs = []
            for i in range(1, self.round + 1):
                config_key = str(i)
                if config_key in single_data["data"]:
                    config_data = single_data["data"][config_key]
                    # Check if all queries in subset exist and are not timeout
                    valid = True
                    cost = 0
                    for query_name in query_names:
                        if query_name not in config_data:
                            # Query missing - partial failure
                            valid = False
                            break
                        t = config_data[query_name]
                        if t >= self.timeout * 1000:
                            # Query timeout
                            valid = False
                            break
                        cost += t
                    
                    if valid:
                        costs.append(cost)
                    else:
                        costs.append(invalid_cost)
                else:
                    # Config not in single_dict (deleted due to timeout or illegal)
                    costs.append(invalid_cost)
        else:
            # Vanilla mode: read from coarse_path
            with open(self.coarse_path, "r") as json_file:
                coarse_data = json.load(json_file)
            # Build costs list from coarse runhistory, indexed by config_id
            costs = [None] * self.round
            for entry in coarse_data["data"]:
                config_id = entry["config_id"]
                if 1 <= config_id <= self.round:
                    costs[config_id - 1] = entry["cost"]

        configs, config_costs = [], []
        for index, value_cost in enumerate(costs):
        # for index, value in index_min_pairs:
            config_id = index + 1
            config_value_dict = his_configs[str(config_id)]
            # make type transformation from coarse to fine 
            transfer_config_value_dict = {}
            for key, value in config_value_dict.items():
                if key.startswith("control_") or key.startswith("special_"):
                    transfer_config_value_dict[key] = value
                    continue
                hp = self.search_space[key]
                if isinstance(hp, CategoricalHyperparameter):
                    transfer_config_value_dict[key] = str(value)
                elif isinstance(hp, UniformIntegerHyperparameter):
                    transfer_config_value_dict[key] = int(value) 
                elif isinstance(hp, UniformFloatHyperparameter):
                    transfer_config_value_dict[key] = float(value)
                else:
                    transfer_config_value_dict[key] = value
            config = Configuration(self.search_space, transfer_config_value_dict)
            configs.append(config)
            config_costs.append(value_cost)
            
        
        smac = HyperparameterOptimizationFacade(
            scenario=scenario,
            initial_design=init_design,
            target_function=self.set_and_replay,
            intensifier=intensifier.Intensifier(scenario, retries=trials_number),
            # acquisition_maximizer=optimizer,
            overwrite=True,
        )
        for config, config_cost in zip(configs, config_costs):
            smac.runhistory.add(config, config_cost, seed=self.seed)
        # smac.optimize()
        return smac
