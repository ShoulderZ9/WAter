import time, random, json
import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler, OneHotEncoder
from sklearn.compose import ColumnTransformer
from sklearn.ensemble import RandomForestRegressor
from diagnostics import compact_config, log_event, memory_snapshot

class ConfigVerifier:
    def __init__(self, runner):
        self.runner = runner
        self.rf = RandomForestRegressor(n_estimators=200)
        self.missing_config_value_log = set()
    
    ########################################################################
    ##### 1. Code related to select promising configurations to verify #####
    ########################################################################

    def select_round_to_run(self):
        self.runner.update_single_dict()
        with open(self.runner.cur_tuner.runhistory_path, 'r') as f:
            runhistory = json.load(f)

        scoring_mode = getattr(self.runner, "scoring_mode", "hybrid")
        print(f"scoring_mode: {scoring_mode}")

        if scoring_mode == "subset-only":
            whole_score = self.subset_only_score(runhistory)
        elif scoring_mode == "exploitation-only":
            whole_score = self.exploitation_score(runhistory)
        elif scoring_mode == "exploration-only":
            whole_score = self.exploration_score(runhistory)
        elif scoring_mode == "hybrid":
            whole_score = self.hybrid_score(runhistory)
        else:
            raise ValueError(f"Unsupported scoring_mode: {scoring_mode}")

        self.runner.exec_whole_last = sorted(whole_score, key=whole_score.get)[:min(int(self.runner.success_per_stage * self.runner.verify_ratio), len(whole_score))]
        print(f"exec_whole_last: {self.runner.exec_whole_last}")
        self.runner.exec_whole_idx.extend(self.runner.exec_whole_last)

    def hybrid_score(self, runhistory):
        epsilon = 0.5
        if random.random() <= epsilon:
            print("Hybrid scoring route: exploitation")
            return self.exploitation_score(runhistory)
        print("Hybrid scoring route: exploration")
        return self.exploration_score(runhistory)

    def subset_only_score(self, runhistory):
        threshold = self.runner.subset_default_score * 1.0 * 1000
        whole_score = {}
        for i in self.runner.success_run_last:
            subset_cost = runhistory["data"][int(i)-1]["cost"]
            if subset_cost > threshold:
                print(f"Subset-only route eliminate round {i}")
                continue
            whole_score[i] = subset_cost

        print(f"whole_score:{whole_score}")
        return whole_score

    def exploitation_score(self, runhistory):
        threshold = self.runner.subset_default_score * 1.0 * 1000
        self.rf_update()
        X, _ = self.get_rf_predict_data()
        rf_score = self.rf.predict(X)

        whole_score = {idx:score*(1 - self.runner.comp_ratio) for idx, score in zip(self.runner.success_run_last, rf_score)}
        for i in self.runner.success_run_last:
            subset_cost = runhistory["data"][int(i)-1]["cost"]
            whole_score[i] += subset_cost * self.runner.comp_ratio
            if subset_cost > threshold:
                print(f"Exploitation route eliminate round {i}")
                del whole_score[i]

        print(f"whole_score:{whole_score}")
        return whole_score

    def exploration_score(self, runhistory):
        threshold = self.runner.subset_default_score * 1.2 * 1000
        X_known, X_unknown = self.get_raw_X()
        sim_scores = self.set_similarity(X_known, X_unknown)

        self.rf_update()
        X, _ = self.get_rf_predict_data()
        uncertainty_scores = self.uncertainty_scores(X)

        r = len(X_unknown)/(len(X_known) + len(X_unknown))
        whole_score = {idx:r*(1 - sim_score)+(1-r)*uncertainty_score for idx, sim_score, uncertainty_score in zip(self.runner.success_run_last, sim_scores, uncertainty_scores)}
        whole_score = {k:-v for k, v in whole_score.items()}
        for i in self.runner.success_run_last:
            if runhistory["data"][int(i)-1]["cost"] > threshold:
                print(f"Exploration route eliminate round {i}")
                whole_score.pop(i, None)
        print(f"whole_score:{whole_score}")
        return whole_score

    def rf_update(self):
        X, Y = self.get_rf_train_data()
        self.rf.fit(X, Y["cost"])

    def get_config_value(self, config_id, knob):
        configs = self.runner.single_dict["configs"]
        config = configs.get(str(config_id), configs.get(config_id, {}))

        control_key = f"control_{knob}"
        special_key = f"special_{knob}"
        control_para = config.get(control_key)
        if control_para == "1" and special_key in config:
            return config[special_key]
        if knob in config:
            return config[knob]
        if special_key in config:
            return config[special_key]

        default_value = self.get_default_knob_value(knob)
        missing_key = (str(config_id), knob)
        if missing_key not in self.missing_config_value_log:
            self.missing_config_value_log.add(missing_key)
            print(f"Config {config_id} misses knob {knob}; use default value {default_value}")
        return default_value

    def get_default_knob_value(self, knob):
        info = self.runner.dbms.knob_info.get(knob, {})
        for key in ("reset_val", "setting", "boot_val", "min_val"):
            value = info.get(key)
            if value is not None:
                return value
        return 0

    def append_config_values(self, X, config_id):
        for knob in self.runner.target_knobs:
            X[knob].append(self.get_config_value(config_id, knob))

    def normalize_feature_frame(self, X):
        X = X.copy()
        for knob in self.runner.num_knobs:
            X[knob] = pd.to_numeric(X[knob], errors="coerce")
            if X[knob].isna().any():
                default_value = pd.to_numeric(self.get_default_knob_value(knob), errors="coerce")
                if pd.isna(default_value):
                    default_value = 0
                X[knob] = X[knob].fillna(default_value)
        for knob in self.runner.cat_knobs:
            X[knob] = X[knob].astype(str)
        return X

    def get_rf_train_data(self):
        self.runner.update_single_dict()

        X = {knob:[] for knob in self.runner.target_knobs}
        Y = {"cost":[]}

        for i in self.runner.exec_whole_idx:
            self.append_config_values(X, i)
            Y["cost"].append(sum(list(self.runner.single_dict["data"][str(i)].values())))
        X = self.normalize_feature_frame(pd.DataFrame(X))
        Y = pd.DataFrame(Y)
        self.get_preprocessor()
        X = self.preprocessor.transform(X)
        X = X.astype(np.float32)
        X = np.clip(X, np.finfo(np.float32).min, np.finfo(np.float32).max)
        
        return X, Y

    def get_rf_predict_data(self):
        self.runner.update_single_dict()

        X = {knob:[] for knob in self.runner.target_knobs}
        Y = {"cost":[]}

        for i in self.runner.success_run_last:
            self.append_config_values(X, i)
            Y["cost"].append(sum(list(self.runner.single_dict["data"][str(i)].values())))
        X = self.normalize_feature_frame(pd.DataFrame(X))
        Y = pd.DataFrame(Y)
        self.get_preprocessor()
        X = self.preprocessor.transform(X)
        X = X.astype(np.float32)
        X = np.clip(X, np.finfo(np.float32).min, np.finfo(np.float32).max)
        
        return X, Y
    
    def get_preprocessor(self):
        x_known, x_unknown = self.get_raw_X()
        X = pd.concat([x_known, x_unknown], axis=0)
        self.preprocessor = ColumnTransformer(
            transformers=[
                ('num', StandardScaler(), self.runner.num_knobs),
                ('cat', OneHotEncoder(), self.runner.cat_knobs)
            ])
        self.preprocessor.fit(X)

    def get_raw_X(self):
        self.runner.update_single_dict()

        X_known = {knob:[] for knob in self.runner.target_knobs}
        X_unknown = {knob:[] for knob in self.runner.target_knobs}
        Y = {"cost":[]}

        for i in self.runner.exec_whole_idx:
            self.append_config_values(X_known, i)
            Y["cost"].append(sum(list(self.runner.single_dict["data"][str(i)].values())))
        X_known = self.normalize_feature_frame(pd.DataFrame(X_known))

        for i in self.runner.success_run_last:
            self.append_config_values(X_unknown, i)
            Y["cost"].append(sum(list(self.runner.single_dict["data"][str(i)].values())))    
        X_unknown = self.normalize_feature_frame(pd.DataFrame(X_unknown))

        return X_known, X_unknown

    def set_similarity(self, X_known, X_unknown):
        if X_known.empty:
            return [0.0 for _ in range(X_unknown.shape[0])]

        min_values = X_known[self.runner.num_knobs].min()
        max_values = X_known[self.runner.num_knobs].max()
        sims = []
        for i in range(X_unknown.shape[0]):
            biggest_sim = 0.0
            for j in range(X_known.shape[0]):
                sim = self.similarity_func(X_unknown.iloc[i], X_known.iloc[j], min_values, max_values)
                biggest_sim = max(sim, biggest_sim)
            sims.append(biggest_sim)

        return sims
    
    def similarity_func(self, x1, x2, min_values, max_values):
        n_features = len(self.runner.target_knobs)
        sum_dist = 0.0

        for knob in self.runner.target_knobs:
            value_1 = x1[knob]
            value_2 = x2[knob]
            if knob in self.runner.num_knobs:
                value_range = max_values[knob] - min_values[knob]
                if value_range != 0:
                    sum_dist += abs(value_1 - value_2) / value_range
            else:  # Categorical variable
                sum_dist += 0 if value_1 == value_2 else 1

        return  n_features / (sum_dist + n_features)
    
    def uncertainty_scores(self, X):
        all_predictions = np.zeros((X.shape[0], len(self.rf.estimators_)))
        for i, estimator in enumerate(self.rf.estimators_):
            all_predictions[:, i] = estimator.predict(X)
        uncertainty = np.std(all_predictions, axis=1)
        return uncertainty

    ################################################################################
    ##### 2. Code related to execute whole workload on selected configurations #####
    ################################################################################
    def exec_whole(self):
        whole_to_remove = []

        for i in self.runner.exec_whole_last:
            dbms = self.runner.dbms
            configs = self.runner.single_dict["configs"][str(i)]
            existing_queries = list(self.runner.single_dict["data"].get(str(i), {}).keys())
            log_event(
                f"verify config={i} start, existing_queries={existing_queries}, "
                f"config={compact_config(configs)}, {memory_snapshot()}"
            )
            dbms.set_config(configs)
            log_event(f"verify config={i} dbms config applied, {memory_snapshot()}")
            for name, sql in self.runner.whole_workload_queries.items():
                if name not in self.runner.single_dict["data"][str(i)]:
                    print(f"Test {name} on configuration {i}", flush=True)
                    timeout_seconds = self.runner.timeout - sum(list(self.runner.single_dict["data"][str(i)].values()))/1e3
                    timeout_seconds = max(0, timeout_seconds)
                    current_cost = sum(list(self.runner.single_dict["data"][str(i)].values()))
                    print(f"Remaining time for current configuration: {timeout_seconds}", flush=True)
                    log_event(
                        f"verify config={i} query={name} start, "
                        f"current_cost_ms={current_cost:.3f}, timeout_seconds={timeout_seconds:.3f}, {memory_snapshot()}"
                    )
                    t = self.runner.get_sql_time_with_timeout(
                        sql,
                        timeout_seconds,
                        query_name=name,
                        config_id=i,
                    )
                    log_event(
                        f"verify config={i} query={name} result_ms={t:.3f}, "
                        f"timeout_ms={self.runner.timeout * 1000:.3f}, {memory_snapshot()}"
                    )
                    if t == self.runner.timeout*1000:
                        if str(i) in self.runner.single_dict["data"]:
                            del self.runner.single_dict["data"][str(i)]
                        whole_to_remove.append(i)
                        print(f"Configuration {i} is timeout and will be deleted from single.json", flush=True)
                        log_event(f"verify config={i} query={name} timeout/delete, {memory_snapshot()}")
                        break
                    else:
                        self.runner.single_dict["data"][str(i)][name] = t
                        log_event(
                            f"verify config={i} query={name} saved, "
                            f"new_total_ms={sum(list(self.runner.single_dict['data'][str(i)].values())):.3f}, {memory_snapshot()}"
                        )
            
            if "cost" not in self.runner.single_dict:
                self.runner.single_dict["cost"] = []
            if str(i) in self.runner.single_dict["data"]:
                self.runner.single_dict["cost"].append({"round":str(i), "time": time.time()- self.runner.start_time, "cost":sum(list(self.runner.single_dict["data"][str(i)].values()))})
                log_event(
                    f"verify config={i} finish, whole_cost_ms={sum(list(self.runner.single_dict['data'][str(i)].values())):.3f}, "
                    f"{memory_snapshot()}"
                )
        
        for i in whole_to_remove:
            self.runner.exec_whole_last.remove(i)
            self.runner.exec_whole_idx.remove(i)
            
        self.runner.dump_single_dict()
