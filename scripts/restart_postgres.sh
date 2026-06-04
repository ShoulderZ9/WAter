#!/bin/sh
set -eu

PGDATA_DIR="${PGDATA:-/var/lib/postgresql/14/main}"
POSTGRES_SERVICE_NAME="${POSTGRES_SERVICE_NAME:-postgresql}"
POSTGRES_RESTART_CMD="${POSTGRES_RESTART_CMD:-}"
PG_CTL_TIMEOUT="${PG_CTL_TIMEOUT:-60}"
PG_CLUSTER_VERSION="${PG_CLUSTER_VERSION:-14}"
PG_CLUSTER_NAME="${PG_CLUSTER_NAME:-main}"
POSTGRES_RESTART_LOCK="${POSTGRES_RESTART_LOCK:-/tmp/water_postgres_restart.lock}"

if command -v flock >/dev/null 2>&1 && [ -z "${WATER_POSTGRES_RESTART_LOCKED:-}" ]; then
    exec env WATER_POSTGRES_RESTART_LOCKED=1 flock -w "${PG_CTL_TIMEOUT}" "${POSTGRES_RESTART_LOCK}" "$0" "$@"
fi

restart_with_custom_cmd() {
    if [ -n "${POSTGRES_RESTART_CMD}" ]; then
        sh -lc "${POSTGRES_RESTART_CMD}"
        return 0
    fi
    return 1
}

cluster_is_running() {
    pg_ctlcluster "${PG_CLUSTER_VERSION}" "${PG_CLUSTER_NAME}" status >/dev/null 2>&1
}

restart_with_pg_ctlcluster() {
    if command -v pg_ctlcluster >/dev/null 2>&1; then
        if cluster_is_running; then
            pg_ctlcluster "${PG_CLUSTER_VERSION}" "${PG_CLUSTER_NAME}" restart && return 0
            echo "pg_ctlcluster restart failed; trying forced stop/start recovery." >&2
            pg_ctlcluster "${PG_CLUSTER_VERSION}" "${PG_CLUSTER_NAME}" stop --force >/dev/null 2>&1 || true
            sleep 2
        fi

        if pg_ctlcluster "${PG_CLUSTER_VERSION}" "${PG_CLUSTER_NAME}" start; then
            return 0
        fi

        if cluster_is_running; then
            echo "PostgreSQL cluster is already running; treating it as healthy." >&2
            return 0
        fi

        return 1
    fi
    return 1
}

restart_with_pg_ctl() {
    if command -v pg_ctl >/dev/null 2>&1 && [ -d "${PGDATA_DIR}" ]; then
        if pg_ctl -D "${PGDATA_DIR}" status >/dev/null 2>&1; then
            pg_ctl -D "${PGDATA_DIR}" -m fast -t "${PG_CTL_TIMEOUT}" restart
        else
            pg_ctl -D "${PGDATA_DIR}" -w -t "${PG_CTL_TIMEOUT}" start
        fi
        return 0
    fi
    return 1
}

restart_with_service_manager() {
    if command -v service >/dev/null 2>&1; then
        service "${POSTGRES_SERVICE_NAME}" restart
        return 0
    fi

    if command -v systemctl >/dev/null 2>&1; then
        systemctl restart "${POSTGRES_SERVICE_NAME}"
        return 0
    fi

    return 1
}

if restart_with_custom_cmd; then
    exit 0
fi

if restart_with_pg_ctlcluster; then
    exit 0
fi

if restart_with_pg_ctl; then
    exit 0
fi

if restart_with_service_manager; then
    exit 0
fi

echo "Unable to restart PostgreSQL automatically." >&2
echo "Set PGDATA/POSTGRES_RESTART_CMD or install pg_ctl, pg_ctlcluster, service, or systemctl." >&2
exit 1
