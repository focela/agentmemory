#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/lib.sh"
compose logs -f --timestamps agentmemory
