#!/usr/bin/env bash
# Common variables and functions. Usage: source "$(dirname "$0")/lib.sh"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMPOSE_FILE="$ROOT/docker/compose.yaml"
DOCKER_DIR="$ROOT/docker"
export ROOT COMPOSE_FILE DOCKER_DIR

info()  { echo "  --> $*"; }
ok()    { echo "   ok: $*"; }
error() { echo "error: $*" >&2; }

compose() {
  docker compose -f "$COMPOSE_FILE" "$@"
}

# Strip docker exec line endings from the HMAC secret.
read_agentmemory_secret() {
  compose exec -T agentmemory cat /data/.hmac 2>/dev/null | tr -d '\n\r' || true
}
