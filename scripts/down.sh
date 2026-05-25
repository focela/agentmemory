#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

# Stop log watcher before stopping the container
PID_FILE="$ROOT/logs/.log.pid"
if [ -f "$PID_FILE" ]; then
  OLD_PID="$(cat "$PID_FILE")"
  kill "$OLD_PID" 2>/dev/null || true
  rm -f "$PID_FILE"
fi

compose down
ok "agentmemory stopped"
