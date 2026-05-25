#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"

if ! command -v docker >/dev/null 2>&1; then
  error "Docker not found — install: https://docs.docker.com/get-docker/"
  exit 1
fi

if [ ! -f "$DOCKER_DIR/.env" ]; then
  cp "$ROOT/.env.example" "$DOCKER_DIR/.env"
  ok "Created docker/.env from .env.example"
fi
if [ ! -f "$DOCKER_DIR/.env.server" ]; then
  cp "$ROOT/config/server.env.example" "$DOCKER_DIR/.env.server"
  ok "Created docker/.env.server from config/server.env.example"
fi

info "Building and starting agentmemory..."
compose up -d --build

info "Waiting for health check..."
for _ in $(seq 1 30); do
  curl -fsS http://127.0.0.1:3111/agentmemory/livez >/dev/null 2>&1 && break
  sleep 2
done

if curl -fsS http://127.0.0.1:3111/agentmemory/livez >/dev/null 2>&1; then
  ok "Server ready — Viewer: http://localhost:3113"
else
  error "server not ready — run: make logs"
  exit 1
fi

echo ""
SECRET="$(read_agentmemory_secret)"
if [ -n "$SECRET" ]; then
  echo "AGENTMEMORY_SECRET=$SECRET"
else
  info "secret not yet available — run: make secret"
fi

# Daily log rotation — one file per day, retained for 14 days
LOG_DIR="$ROOT/logs"
PID_FILE="$LOG_DIR/.log.pid"
mkdir -p "$LOG_DIR"

# Remove log files older than 14 days
find "$LOG_DIR" -name 'agentmemory-*.log' -mtime +14 -delete 2>/dev/null || true

# Stop previous log watcher if still running
if [ -f "$PID_FILE" ]; then
  OLD_PID="$(cat "$PID_FILE")"
  if ps -p "$OLD_PID" -o args= 2>/dev/null | grep -qF "$LOG_DIR"; then
    pkill -P "$OLD_PID" 2>/dev/null || true
    kill "$OLD_PID" 2>/dev/null || true
  fi
  rm -f "$PID_FILE"
fi

# Wrapper restarts docker logs at midnight to write to the correct day's file
nohup bash -c "
  while true; do
    TODAY=\$(date '+%Y-%m-%d')
    LOG_FILE='$LOG_DIR'/agentmemory-\${TODAY}.log
    ln -sf agentmemory-\${TODAY}.log '$LOG_DIR/agentmemory.log'
    docker compose -f '$COMPOSE_FILE' logs -f --no-color --timestamps --no-log-prefix --tail 0 agentmemory \
      >> \"\$LOG_FILE\" 2>&1 &
    INNER=\$!
    while [ \"\$(date '+%Y-%m-%d')\" = \"\$TODAY\" ]; do sleep 30; done
    kill \"\$INNER\" 2>/dev/null || true
  done
" &
echo $! > "$PID_FILE"
info "Log file: $LOG_DIR/agentmemory-$(date '+%Y-%m-%d').log"
