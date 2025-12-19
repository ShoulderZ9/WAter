#!/usr/bin/env python3
"""
统计 workload 中每个 SQL 的执行时间，实时记录到 JSON 文件。
超过 10 秒的 SQL 会被终止，执行时间记录为 10。

Usage:
    python benchmark_sql.py <sql_folder> [--output <output.json>] [--timeout <seconds>]

Example:
    python benchmark_sql.py workload/job1000_sqlstorm
    python benchmark_sql.py workload/job1000_sqlstorm --output result.json --timeout 10
"""

import argparse
import os
import sys
import time
import json
from configparser import ConfigParser
import psycopg2


def get_db_connection(config_path, timeout_sec):
    """从配置文件读取数据库连接信息并建立连接"""
    config = ConfigParser()
    config.read(config_path)
    
    conn = psycopg2.connect(
        user=config['DATABASE']['user'],
        password=config['DATABASE']['password'],
        database=config['DATABASE']['db'],
        host='localhost',
        options=f'-c statement_timeout={timeout_sec * 1000}'  # 毫秒
    )
    conn.autocommit = True
    return conn


def execute_sql_with_timeout(conn, sql, timeout_sec):
    """
    执行 SQL 并返回执行时间。
    如果超时，返回 timeout_sec。
    返回 (exec_time, is_timeout, error)
    """
    try:
        cursor = conn.cursor()
        start_time = time.time()
        cursor.execute(sql)
        # 确保结果被获取（对于 SELECT 语句）
        try:
            cursor.fetchall()
        except:
            pass
        exec_time = time.time() - start_time
        cursor.close()
        return exec_time, False, None
    except psycopg2.errors.QueryCanceled:
        # 超时被取消
        return timeout_sec, True, "timeout"
    except Exception as e:
        return 0, False, str(e)


def save_results(output_path, results):
    """实时保存结果到 JSON 文件"""
    with open(output_path, 'w') as f:
        json.dump(results, f, indent=4)


def main():
    parser = argparse.ArgumentParser(description='统计 SQL 执行时间')
    parser.add_argument('sql_folder', help='包含 SQL 文件的文件夹路径')
    parser.add_argument('--config', default='./configs/postgres.ini', 
                        help='数据库配置文件路径 (默认: ./configs/postgres.ini)')
    parser.add_argument('--output', default='sql_benchmark.json',
                        help='输出 JSON 文件路径 (默认: sql_benchmark.json)')
    parser.add_argument('--timeout', type=float, default=20.0,
                        help='单个 SQL 超时时间(秒) (默认: 10)')
    args = parser.parse_args()
    
    sql_folder = args.sql_folder
    config_path = args.config
    output_path = args.output
    timeout_sec = args.timeout
    
    if not os.path.isdir(sql_folder):
        print(f"错误: 文件夹不存在: {sql_folder}")
        sys.exit(1)
    
    if not os.path.isfile(config_path):
        print(f"错误: 配置文件不存在: {config_path}")
        sys.exit(1)
    
    # 连接数据库
    print(f"连接数据库: {config_path}")
    print(f"超时设置: {timeout_sec} 秒")
    try:
        conn = get_db_connection(config_path, timeout_sec)
    except Exception as e:
        print(f"数据库连接失败: {e}")
        sys.exit(1)
    
    # 获取所有 SQL 文件
    sql_files = sorted([f for f in os.listdir(sql_folder) if f.endswith('.sql')])
    total = len(sql_files)
    
    if total == 0:
        print(f"警告: 文件夹中没有 .sql 文件: {sql_folder}")
        sys.exit(0)
    
    # 检查是否存在已有结果，支持断点续传
    existing_time_dict = {}
    if os.path.isfile(output_path):
        try:
            with open(output_path, 'r') as f:
                existing_results = json.load(f)
            existing_time_dict = existing_results.get("time_dict", {})
            print(f"发现已有结果文件，已评估 {len(existing_time_dict)} 个 SQL，将跳过这些继续评估...")
        except Exception as e:
            print(f"读取已有结果文件失败: {e}，将重新开始...")
    
    # 筛选出需要评估的 SQL
    pending_sql_files = [f for f in sql_files if f.replace('.sql', '') not in existing_time_dict]
    pending_count = len(pending_sql_files)
    
    if pending_count == 0:
        print(f"所有 {total} 个 SQL 已经评估完成！")
        sys.exit(0)
    
    print(f"总计 {total} 个 SQL，待评估 {pending_count} 个...\n")
    
    results = {
        "config": {
            "sql_folder": sql_folder,
            "timeout_sec": timeout_sec,
            "total_files": total
        },
        "time_dict": existing_time_dict.copy(),
        "summary": {
            "completed": len(existing_time_dict),
            "timeout_count": sum(1 for t in existing_time_dict.values() if t >= timeout_sec),
            "error_count": sum(1 for t in existing_time_dict.values() if t == 0),
            "total_time": 0
        }
    }
    
    # 初始化保存
    save_results(output_path, results)
    
    start_total = time.time()
    # 从已有结果中提取有效时间（不含超时和错误）
    valid_times = [t for t in existing_time_dict.values() if 0 < t < timeout_sec]
    
    for i, sql_file in enumerate(pending_sql_files, 1):
        sql_name = sql_file.replace('.sql', '')
        sql_path = os.path.join(sql_folder, sql_file)
        
        with open(sql_path, 'r') as f:
            sql_content = f.read().strip()
        
        exec_time, is_timeout, error = execute_sql_with_timeout(conn, sql_content, timeout_sec)
        completed_total = len(existing_time_dict) + i
        
        # 记录结果
        results["time_dict"][sql_name] = exec_time
        results["summary"]["completed"] = completed_total
        results["summary"]["total_time"] = time.time() - start_total
        
        if is_timeout:
            results["summary"]["timeout_count"] += 1
            status = "⏱ TIMEOUT"
        elif error:
            results["summary"]["error_count"] += 1
            status = f"✗ ERROR: {error[:50]}"
        else:
            status = "✓"
            valid_times.append(exec_time)  # 只记录成功执行的时间
        
        # 计算当前平均执行时间
        if valid_times:
            avg_time = sum(valid_times) / len(valid_times)
            avg_str = f"| avg: {avg_time:.3f}s ({len(valid_times)} valid)"
        else:
            avg_str = "| avg: N/A"
        
        print(f"[{completed_total}/{total}] {sql_name}: {exec_time:.3f}s {status} {avg_str}")
        
        # 实时保存
        save_results(output_path, results)
    
    conn.close()
    
    # 打印汇总
    print("\n" + "=" * 60)
    print(f"执行完成！结果已保存到: {output_path}")
    print(f"总计: {total} 个 SQL")
    print(f"超时: {results['summary']['timeout_count']} 个")
    print(f"错误: {results['summary']['error_count']} 个")
    print(f"总耗时: {results['summary']['total_time']:.2f} 秒")
    
    # 计算平均时间（排除错误的）
    valid_times = [t for t in results["time_dict"].values() if t > 0]
    if valid_times:
        avg_time = sum(valid_times) / len(valid_times)
        print(f"平均执行时间: {avg_time:.3f} 秒")


if __name__ == '__main__':
    main()
