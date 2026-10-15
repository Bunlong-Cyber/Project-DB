#!/usr/bin/env bash
set -euo pipefail
PG_BIN="${PG_BIN:-/usr/lib/postgresql/16/bin}"
LAB_DIR="${SCMS_LAB_DIR:-$HOME/.local/share/scms-grade-pg-lab}"
SOCKET_DIR="$LAB_DIR/socket"
PORT="${SCMS_PG_PORT:-55442}"
DB="scms_reference"
if [[ -x "$PG_BIN/dropdb" ]] && "$PG_BIN/pg_isready" -h "$SOCKET_DIR" -p "$PORT" >/dev/null 2>&1; then
    "$PG_BIN/dropdb" -h "$SOCKET_DIR" -p "$PORT" -U "$USER" --if-exists "$DB"
fi
"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/start-lab.sh"
