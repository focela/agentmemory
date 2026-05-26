# Troubleshooting

Resolution steps for common deployment and runtime issues.

## Container fails to start

**Symptom:** `make up` exits with non-zero status or container restart loops.

**Diagnose:**

```bash
make logs
docker compose -f docker/compose.yaml ps
```

**Common causes and resolutions:**

| Cause | Resolution |
|-------|------------|
| Port 3111 or 3113 already bound | `lsof -i :3111` to identify the process; stop it or change the host port in `docker/compose.yaml` |
| Docker daemon not running | Start Docker Desktop or `systemctl start docker` |
| Missing required env vars | Verify `docker/.env.server` contains `OPENAI_API_KEY` and one LLM provider key |
| Volume permission denied | `docker volume rm agentmemory-data` (this destroys persistent memory) |

## Health check times out

**Symptom:** `make up` reports `server not ready` after 120 seconds.

**Diagnose:**

```bash
curl -fsS http://127.0.0.1:3111/agentmemory/livez
docker compose -f docker/compose.yaml logs agentmemory | tail -50
```

**Common causes and resolutions:**

| Cause | Resolution |
|-------|------------|
| Slow first-run image build | Re-run `make up`; subsequent boots use cached image layers |
| Invalid LLM provider key | Check logs for `401` or `403` from the provider; correct the key in `docker/.env.server` and restart |
| Insufficient RAM | Ensure host has ≥ 2 GB free; reduce other workloads |

## MCP client cannot connect

**Symptom:** Claude Code / Cursor / Claude Desktop reports the `agentmemory` server is unreachable.

**Diagnose:**

```bash
make secret                                              # confirm secret is available
curl -fsS http://localhost:3111/agentmemory/livez       # confirm server is reachable
cat .mcp.json | jq '.mcpServers.agentmemory'            # confirm client config
```

**Common causes and resolutions:**

| Cause | Resolution |
|-------|------------|
| `REPLACE_ME` still in MCP config | Replace with the value from `make secret` |
| Secret mismatch after volume reset | Re-fetch with `make secret` and update every MCP client config |
| MCP client not restarted | Quit and reopen Claude Desktop completely; Cursor restart is sufficient |
| Wrong URL on remote deployment | Use the public HTTPS URL, not `localhost`, when connecting to a VPS |

## Secret not available

**Symptom:** `make secret` prints `secret not available — run: make up`.

**Diagnose:**

```bash
docker compose -f docker/compose.yaml ps
docker compose -f docker/compose.yaml exec agentmemory cat /data/.hmac
```

**Common causes and resolutions:**

| Cause | Resolution |
|-------|------------|
| Container not running | Run `make up` first |
| Container starting | Wait for the health check to pass, then retry |
| `/data` mount empty after volume reset | The container will regenerate the secret on next boot |

## LLM provider returns error

**Symptom:** Memory operations fail; logs contain `429`, `401`, or `403` from OpenAI or OpenRouter.

**Resolutions:**

- `401` / `403` — verify the API key in `docker/.env.server` is current and has not been revoked
- `429` — rate limit; reduce request volume or upgrade provider tier
- Provider outage — check the provider's status page

## Logs grow large

**Symptom:** Disk usage from `logs/` directory increases over time.

**Resolution:**

Daily rotation removes files older than 14 days automatically. To clear all
historical logs:

```bash
make down
rm -rf logs/*.log
make up
```

To change retention, edit the `find -mtime +14` value in `scripts/up.sh`.

## Reverse proxy returns 502

**Symptom:** Nginx or Nginx Proxy Manager returns `502 Bad Gateway`.

**Diagnose:**

```bash
curl -fsS http://127.0.0.1:3111/agentmemory/livez       # confirm container is up
ufw status                                              # confirm firewall rule (if applicable)
```

**Common causes and resolutions:**

| Cause | Resolution |
|-------|------------|
| Container bound to `127.0.0.1` while proxy is on different host | Change port binding to `0.0.0.0` and restrict access via firewall |
| Wrong forward hostname in proxy config | Use `host.docker.internal` (same host) or the container host IP |
| `AGENTMEMORY_CORS_ORIGINS` not updated | Add the public origin to the env var and restart |
