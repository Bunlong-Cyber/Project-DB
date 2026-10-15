#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LAB_DIR="${SCMS_LAB_DIR:-$HOME/.local/share/scms-grade-pg-lab}"
SOCKET_DIR="$LAB_DIR/socket"
PORT="${SCMS_PG_PORT:-55442}"
DB="scms_reference"
psql -h "$SOCKET_DIR" -p "$PORT" -U "$USER" -d "$DB" -v ON_ERROR_STOP=1 -f "$ROOT/tests/01_integrity_checks.sql"
psql -h "$SOCKET_DIR" -p "$PORT" -U "$USER" -d "$DB" -v ON_ERROR_STOP=1 -f "$ROOT/tests/02_security_checks.sql"
