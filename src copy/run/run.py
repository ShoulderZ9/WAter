#!/usr/bin/env python3
"""
简单的按次序执行命令行脚本
"""

import subprocess
import sys


def run_commands(commands):
    """
    按顺序执行命令行列表
    
    Args:
        commands: 要执行的命令行列表
    """
    for i, cmd in enumerate(commands, 1):
        print(f"\n[{i}/{len(commands)}] 执行: {cmd}")
        print("-" * 50)
        
        try:
            # 执行命令
            result = subprocess.run(cmd, shell=True, check=True)
            print(f"✅ 命令执行成功")
        except subprocess.CalledProcessError as e:
            print(f"❌ 命令执行失败 (返回码: {e.returncode})")

        except Exception as e:
            print(f"💥 执行异常: {e}")
            break


def main():
    """主函数"""
    # 在这里定义要执行的命令列表
    commands = [
        # "python3 /home/wang7342/GSUM_rebuild/src/entry.py --sql_num 1000 --dirname job1000_sqlstorm --db imdb --config /home/wang7342/GSUM_rebuild/configs/postgres_imdb.ini",
        # "python3 /home/wang7342/GSUM_rebuild/src/entry.py --sql_num 880 --dirname tpcdsX10_select --db tpcds1g --config /home/wang7342/GSUM_rebuild/configs/postgres_tpcds.ini",

        # DSB+TPCDS gptuner
        # "python /home/wang7342/WAter/src/run/vanilla_tuner/run_gptuner.py -seed 1",
        # "python /home/wang7342/WAter/src/run/vanilla_tuner/run_gptuner.py -seed 2",
        # "python /home/wang7342/WAter/src/run/vanilla_tuner/run_gptuner.py -seed 3",

        # job1000_sqlstorm gptuner
        # "python /home/wang7342/WAter/src/run/vanilla_tuner/run_gptuner.py -seed 11",
        # "python /home/wang7342/WAter/src/run/vanilla_tuner/run_gptuner.py -seed 12",
        # "python /home/wang7342/WAter/src/run/vanilla_tuner/run_gptuner.py -seed 13",
        # "python /home/wang7342/WAter/src/run/vanilla_tuner/run_gptuner.py -seed 14",

        # DSB+TPCDS WAter+gptuner
        "PYTHONPATH=src python3 src/run/WAter/run_gptuner.py -seed=101 | tee log101.txt",
        "PYTHONPATH=src python3 src/run/WAter/run_gptuner.py -seed=102 | tee log102.txt",
        "PYTHONPATH=src python3 src/run/WAter/run_gptuner.py -seed=103 | tee log103.txt",


        

    ]
    
    print(f"准备执行 {len(commands)} 个命令:")
    for i, cmd in enumerate(commands, 1):
        print(f"  {i}. {cmd}")
    
    run_commands(commands)
    print("\n执行完成")


if __name__ == "__main__":
    main()

'''
PYTHONPATH=src python3  /home/wang7342/WAter/src/run/run.py
'''