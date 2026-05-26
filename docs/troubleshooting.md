# Troubleshooting

Resolution steps for common deployment and runtime issues.

## Container Fails to Start

**Symptom:** `make up` exits with non-zero status or the container restarts.

**Diagnose:**

```bash
make logs
docker compose -f docker/compose.yaml ps
```

**Common causes:**

- Port `3111` or `3113` is already in use.
  Run `lsof -i :3111` or `lsof -i :3113`, then stop the process or change the
  host port in `docker/compose.yaml`.
- Docker is not running.
  Start Docker Desktop or run `systemctl start docker`.
- Required environment variables are missing.
  Check `docker/.env.server` for `OPENAI_API_KEY` and one LLM provider key.
- The Docker volume has invalid permissions.
  Recreate it with `docker volume rm agentmemory-data`. This deletes stored
  memory data.

## Health Check Times Out

**Symptom:** `make up` reports `server not ready` after 120 seconds.

**Diagnose:**

```bash
curl -fsS http://127.0.0.1:3111/agentmemory/livez
docker compose -f docker/compose.yaml logs agentmemory | tail -50
```

**Common causes:**

- First image build is still running.
  Run `make up` again. Later boots use cached image layers.
- LLM provider key is invalid.
  Check logs for `401` or `403`, then update `docker/.env.server`.
- The host does not have enough free memory.
  Use a machine with at least 2 GB of available RAM.

## MCP Client Cannot Connect

**Symptom:** Claude Code, Cursor, or Claude Desktop cannot reach agentmemory.

**Diagnose:**

```bash
make secret
curl -fsS http://localhost:3111/agentmemory/livez
cat .mcp.json | jq '.mcpServers.agentmemory'
```

**Common causes:**

- `REPLACE_ME` is still present in the MCP config.
  Replace it with the value from `make secret`.
- The secret changed after a volume reset.
  Run `make secret` again and update every MCP client config.
- The MCP client was not restarted.
  Quit and reopen the client.
- The URL is wrong for a remote deployment.
  Use the public HTTPS URL when connecting to a VPS.

## Secret Not Available

**Symptom:** `make secret` prints `secret not available. Run: make up`.

**Diagnose:**

```bash
docker compose -f docker/compose.yaml ps
docker compose -f docker/compose.yaml exec agentmemory cat /data/.hmac
```

**Common causes:**

- The container is not running.
  Run `make up` first.
- The container is still starting.
  Wait for the health check to pass, then retry.
- `/data` is empty after a volume reset.
  Restart the container so it can generate a new secret.

## LLM Provider Returns an Error

**Symptom:** Memory operations fail and logs contain `429`, `401`, or `403`.

**Resolutions:**

- `401` or `403`: verify the API key in `docker/.env.server`.
- `429`: reduce request volume or upgrade the provider tier.
- Provider outage: check the provider status page.

## Logs Grow Large

**Symptom:** Disk usage from the `logs/` directory increases over time.

Daily rotation removes files older than 14 days. To clear historical logs:

```bash
make down
rm -rf logs/*.log
make up
```

To change retention, edit the `find -mtime +14` value in `scripts/up.sh`.

## Reverse Proxy Returns 502

**Symptom:** Nginx or Nginx Proxy Manager returns `502 Bad Gateway`.

**Diagnose:**

```bash
curl -fsS http://127.0.0.1:3111/agentmemory/livez
ufw status
```

**Common causes:**

- The container is bound to `127.0.0.1`, but the proxy runs on another host.
  Bind the port to `0.0.0.0` and restrict access with a firewall.
- The proxy forward hostname is wrong.
  Use `host.docker.internal` on the same host, or the container host IP.
- `AGENTMEMORY_CORS_ORIGINS` does not include the public origin.
  Add the public origin to `docker/.env.server`, then restart the stack.
