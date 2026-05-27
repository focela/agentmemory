# Deployment

This guide covers local and remote deployments for the Docker Compose stack.

## Local Deployment

### Clone the Repository

```bash
git clone https://github.com/focela/agentmemory agentmemory
cd agentmemory
```

### Configure the Server

Create the runtime environment file:

```bash
cp config/server.env.example docker/.env.server
```

Edit `docker/.env.server` and set the required API keys:

```bash
OPENAI_API_KEY=sk-...
OPENROUTER_API_KEY=sk-or-v1-...
OPENROUTER_MODEL=anthropic/claude-3.5-haiku
AGENTMEMORY_AUTO_COMPRESS=true
```

agentmemory uses separate providers for embeddings and memory compression.

| Provider | Role | Environment variable |
|----------|------|----------------------|
| OpenAI | Embeddings and vector search | `OPENAI_API_KEY` |
| OpenRouter, Anthropic, or Gemini | LLM compression | See provider keys below |

Supported provider keys:

- `OPENROUTER_API_KEY`
- `ANTHROPIC_API_KEY`
- `GEMINI_API_KEY`

See all options in [`config/server.env.example`](../config/server.env.example).

### Start the Server

```bash
make up
```

The script builds the image, starts the containers, waits for the health check,
and prints `AGENTMEMORY_SECRET` when ready.

### Save the Secret

```bash
make secret
```

Store the secret in a password manager. Use it when configuring MCP clients.

### Verify the Server

```bash
curl -fsS http://localhost:3111/agentmemory/livez
```

Expected response:

```json
{"status":"ok"}
```

## Remote Server Deployment

### Install Docker

Run this on the VPS:

```bash
curl -fsSL https://get.docker.com | sh
```

### Clone and Start

```bash
git clone https://github.com/focela/agentmemory agentmemory
cd agentmemory
cp config/server.env.example docker/.env.server
```

Edit `docker/.env.server`:

```bash
OPENAI_API_KEY=sk-...
OPENROUTER_API_KEY=sk-or-v1-...
OPENROUTER_MODEL=anthropic/claude-3.5-haiku
AGENTMEMORY_AUTO_COMPRESS=true
AGENTMEMORY_CORS_ORIGINS=https://memory.example.com
```

Start the stack and save the secret:

```bash
make up
make secret
```

### Configure Reverse Proxy and HTTPS

Use a reverse proxy to expose the server over HTTPS.

#### Option A: Nginx Proxy Manager

Nginx Proxy Manager and agentmemory can run on the same server or on separate
servers.

If Nginx Proxy Manager runs on a separate server, open the agentmemory ports
only to the proxy server:

```bash
ufw allow from <NPM-SERVER-IP> to any port 3111
ufw allow from <NPM-SERVER-IP> to any port 3113
```

Then edit `docker/compose.yaml` and change the port bindings from `127.0.0.1`
to `0.0.0.0`:

```yaml
ports:
  - "3111:3111"
  - "3113:13113"
```

Restart the stack:

```bash
make down && make up
```

If Nginx Proxy Manager runs on the same server, keep the `127.0.0.1` bindings
and use `host.docker.internal` as the forward hostname.

Configure the proxy host:

1. Open `Proxy Hosts > Add Proxy Host`.
2. Set the domain to `memory.example.com`.
3. Set the forward hostname to the agentmemory server IP, or
   `host.docker.internal` on the same machine.
4. Set the forward port to `3111`.
5. Enable SSL and request a Let's Encrypt certificate.

Update CORS in `docker/.env.server`:

```bash
AGENTMEMORY_CORS_ORIGINS=https://memory.example.com
```

Restart the stack:

```bash
make down && make up
```

#### Option B: Manual Nginx

Use the example config in [`config/nginx.conf.example`](../config/nginx.conf.example).

```bash
apt install certbot python3-certbot-nginx
certbot --nginx -d memory.example.com
cp config/nginx.conf.example /etc/nginx/sites-available/agentmemory
ln -s /etc/nginx/sites-available/agentmemory /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

Edit `server_name` and certificate paths before reloading Nginx.

### Connect from a Development Machine

Use the public URL and saved secret in MCP client config:

```json
{
  "AGENTMEMORY_URL": "https://memory.example.com",
  "AGENTMEMORY_SECRET": "<secret>"
}
```

See [mcp-clients.md](mcp-clients.md) for client-specific setup.

## Environment Files

| Template | Runtime file | Purpose |
|----------|--------------|---------|
| [`.env.example`](../.env.example) | `docker/.env` | Docker Compose project name, data directory path |
| [`config/server.env.example`](../config/server.env.example) | `docker/.env.server` | API keys and runtime settings |

After editing `docker/.env.server`, restart the stack:

```bash
make down && make up
```
