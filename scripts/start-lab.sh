#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PG_BIN="${PG_BIN:-/usr/lib/postgresql/16/bin}"
LAB_DIR="${SCMS_LAB_DIR:-$HOME/.local/share/scms-grade-pg-lab}"
SOCKET_DIR="$LAB_DIR/socket"
PORT="${SCMS_PG_PORT:-55442}"
DB="scms_reference"

for command in initdb pg_ctl createdb dropdb pg_isready; do
    [[ -x "$PG_BIN/$command" ]] || { echo "Missing $PG_BIN/$command. Install PostgreSQL 16 tools first." >&2; exit 1; }
done

mkdir -p "$LAB_DIR"
if [[ ! -f "$LAB_DIR/PG_VERSION" ]]; then
    echo "Creating private SCMS lab cluster at $LAB_DIR"
    "$PG_BIN/initdb" -D "$LAB_DIR" -U "$USER" --auth=trust >/dev/null
fi
mkdir -p "$SOCKET_DIR"

if ! "$PG_BIN/pg_ctl" -D "$LAB_DIR" status >/dev/null 2>&1; then
    "$PG_BIN/pg_ctl" -D "$LAB_DIR" -o "-p $PORT -k $SOCKET_DIR" -l "$LAB_DIR/server.log" start >/dev/null
fi
until "$PG_BIN/pg_isready" -h "$SOCKET_DIR" -p "$PORT" >/dev/null 2>&1; do sleep 1; done

if ! "$PG_BIN/createdb" -h "$SOCKET_DIR" -p "$PORT" -U "$USER" "$DB" 2>/dev/null; then
    echo "SCMS lab already exists; preserving its data."
    echo "Use ./scripts/reset-lab.sh only when you want a fresh dataset."
    exit 0
fi
PSQL=(psql -h "$SOCKET_DIR" -p "$PORT" -U "$USER" -d "$DB" -v ON_ERROR_STOP=1)
"${PSQL[@]}" -f "$ROOT/sql/reference/01_schema.sql"
"${PSQL[@]}" -f "$ROOT/sql/reference/02_seed.sql"
"${PSQL[@]}" -f "$ROOT/sql/reference/03_reports.sql"
"${PSQL[@]}" -f "$ROOT/sql/reference/04_security.sql"

echo "SCMS lab ready with fictional sample data."
echo "Connect: psql -h '$SOCKET_DIR' -p $PORT -U '$USER' -d $DB"
echo "Tests:   $ROOT/scripts/run-tests.sh"
echo "Stop:    $ROOT/scripts/stop-lab.sh"
