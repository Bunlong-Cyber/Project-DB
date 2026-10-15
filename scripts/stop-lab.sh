#!/usr/bin/env bash
set -euo pipefail
PG_BIN="${PG_BIN:-/usr/lib/postgresql/16/bin}"
LAB_DIR="${SCMS_LAB_DIR:-$HOME/.local/share/scms-grade-pg-lab}"
if [[ -x "$PG_BIN/pg_ctl" ]] && "$PG_BIN/pg_ctl" -D "$LAB_DIR" status >/dev/null 2>&1; then
    "$PG_BIN/pg_ctl" -D "$LAB_DIR" stop -m fast
else
    echo "SCMS lab is not running."
fi
