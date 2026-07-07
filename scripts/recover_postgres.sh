#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
RESTART_SCRIPT="${SCRIPT_DIR}/restart_postgres.sh"

PGDATA_DIR="${PGDATA:-/var/lib/postgresql/17/main}"
POSTGRES_AUTO_CONF="${POSTGRES_AUTO_CONF:-${PGDATA_DIR}/postgresql.auto.conf}"

if [ -f "${POSTGRES_AUTO_CONF}" ]; then
    rm -f "${POSTGRES_AUTO_CONF}"
fi

sleep 2
sh "${RESTART_SCRIPT}"
