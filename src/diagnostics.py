import json
import os
import time


def timestamp():
    return time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())


def read_proc_status():
    status = {}
    try:
        with open("/proc/self/status", "r") as f:
            for line in f:
                if ":" not in line:
                    continue
                key, value = line.split(":", 1)
                status[key.strip()] = value.strip()
    except OSError:
        pass
    return status


def read_meminfo():
    meminfo = {}
    try:
        with open("/proc/meminfo", "r") as f:
            for line in f:
                if ":" not in line:
                    continue
                key, value = line.split(":", 1)
                meminfo[key.strip()] = value.strip()
    except OSError:
        pass
    return meminfo


def memory_snapshot():
    status = read_proc_status()
    meminfo = read_meminfo()
    fields = {
        "pid": os.getpid(),
        "rss": status.get("VmRSS", "unknown"),
        "hwm": status.get("VmHWM", "unknown"),
        "vm_size": status.get("VmSize", "unknown"),
        "mem_available": meminfo.get("MemAvailable", "unknown"),
        "swap_free": meminfo.get("SwapFree", "unknown"),
    }
    return ", ".join(f"{key}={value}" for key, value in fields.items())


def log_event(message):
    print(f"[diag {timestamp()}] {message}", flush=True)


def compact_config(configs, limit=60):
    if not configs:
        return "{}"
    ordered = {key: configs[key] for key in sorted(configs)}
    text = json.dumps(ordered, ensure_ascii=False, sort_keys=True)
    if len(ordered) > limit:
        return text
    return text
