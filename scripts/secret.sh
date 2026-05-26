#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
SECRET="$(read_agentmemory_secret)"
if [ -z "$SECRET" ]; then
  error "secret not available. Run: make up"
  exit 1
fi
echo "AGENTMEMORY_SECRET=$SECRET"
