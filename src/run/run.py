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
        # water+smac gsum/random
        #"PYTHONPATH=src python3 src/run/WAter/run_smac.py -seed=741 | tee log741.txt",
        #"PYTHONPATH=src python3 src/run/WAter/run_smac.py -seed=733 | tee log733.txt",
        #"PYTHONPATH=src python3 src/run/WAter/run_smac.py -seed=729 | tee log729.txt",

        # water+gptuner gsum/random
        #"PYTHONPATH=src python3 src/run/WAter/run_gptuner.py -seed=707 | tee log 707",
        #"PYTHONPATH=src python3 src/run/WAter/run_gptuner.py -seed=708 | tee log 708",

        # water+gptuner 完全体
        "PYTHONPATH=src python3 src/run/WAter/run_gptuner.py -seed=770 | tee log770.txt",

        # water+smac 完全体
        #"PYTHONPATH=src python3 src/run/WAter/run_smac.py -seed=712 | tee log712.txt",

        # ∞
        #"PYTHONPATH=src python3 src/run/WAter/run_gptuner.py -seed=768 | tee log768.txt",

    ]

    # PYTHONPATH=src python3 src/run/run.py
    
    print(f"准备执行 {len(commands)} 个命令:")
    for i, cmd in enumerate(commands, 1):
        print(f"  {i}. {cmd}")
    
    run_commands(commands)
    print("\n执行完成")


if __name__ == "__main__":
    main()