# agentmemory

Self-host template for [**agentmemory**](https://github.com/rohitg00/agentmemory) — Docker stack, Viewer UI, MCP for Cursor / Claude Code / Claude Desktop.

| URL | Service |
|-----|---------|
| http://localhost:3111 | REST API |
| http://localhost:3113 | Viewer UI |

> 🇻🇳 [Tiếng Việt](README.vi.md)

---

## Requirements

| Component | Required |
|-----------|----------|
| Docker Engine + Compose v2 | ✅ |
| Node.js ≥ 20 (for MCP client `npx`) | ✅ dev machine |
| RAM ≥ 2 GB | ✅ server machine |

---

## Local deployment (first time)

### Step 1 — Clone the repo

```bash
git clone https://github.com/focela/agentmemory agentmemory
cd agentmemory
```

### Step 2 — Configure the server

`make up` auto-creates `docker/.env.server` from the template. Open the file and fill in your API keys:

```bash
cp config/server.env.example docker/.env.server
# Open docker/.env.server and fill in:
```

agentmemory uses **2 independent AI providers**:

| Provider | Role | Env var |
|----------|------|---------|
| OpenAI | Embeddings (vector search) — required | `OPENAI_API_KEY` |
| OpenRouter / Anthropic / Gemini | LLM compression (memory synthesis) | `OPENROUTER_API_KEY` or `ANTHROPIC_API_KEY` or `GEMINI_API_KEY` |

Default provider for LLM compression — OpenRouter with `anthropic/claude-3.5-haiku`:

```bash
OPENAI_API_KEY=sk-...                         # embeddings
OPENROUTER_API_KEY=sk-or-v1-...              # LLM compression
OPENROUTER_MODEL=anthropic/claude-3.5-haiku  # model (default if omitted)
AGENTMEMORY_TOOLS=all
AGENTMEMORY_INJECT_CONTEXT=true
AGENTMEMORY_AUTO_COMPRESS=true               # auto-compress observations after each tool use
CONSOLIDATION_ENABLED=true                   # auto-promote observations → Memories after each session ends
```

> See all options in [`config/server.env.example`](config/server.env.example)

### Step 3 — Start the server

```bash
make up
```

The script builds the image, waits for health check, and prints `AGENTMEMORY_SECRET` when ready.

### Step 4 — Save the secret

```bash
make secret
# AGENTMEMORY_SECRET=<hex-64-chars>
```

Save this value in a password manager. Used to configure MCP clients in the next step.

### Step 5 — Verify

```bash
curl -fsS http://localhost:3111/agentmemory/livez
# {"status":"ok"}
```

---

## Connect MCP clients

Get the secret first: `make secret` → `AGENTMEMORY_SECRET=<value>`

All MCP configs are **gitignored** — create from template then fill in the secret. Works on all OS (Windows / macOS / Linux).

### Claude Code

**MCP** — connect agentmemory tools to Claude Code:

```bash
cp .mcp.json.example .mcp.json
# Open .mcp.json, replace REPLACE_ME with the secret from make secret
```

> Template: [`.mcp.json.example`](.mcp.json.example)

**Hooks** — automatically capture memory after each tool use (install once, works for all projects):

```bash
# Step 1 — Install hook package globally
npm install -g @agentmemory/agentmemory

# Step 2 — Find your global node_modules path
npm root -g
```

Common paths by OS:

| OS | Typical path |
|----|-------------|
| macOS (Homebrew) | `/opt/homebrew/lib/node_modules` |
| macOS (nvm) | `~/.nvm/versions/node/<version>/lib/node_modules` |
| Linux | `/usr/local/lib/node_modules` |
| Windows | `C:\Users\<user>\AppData\Roaming\npm\node_modules` |

Add to `~/.claude/settings.json` — replace `<npm-root-g>` with output of `npm root -g`, replace `<secret>` with output of `make secret`:

```json
{
  "hooks": {
    "SessionStart":      [{"hooks": [{"type": "command", "command": "AGENTMEMORY_URL=http://localhost:3111 AGENTMEMORY_SECRET=<secret> AGENTMEMORY_INJECT_CONTEXT=true node <npm-root-g>/@agentmemory/agentmemory/dist/hooks/session-start.mjs"}]}],
    "UserPromptSubmit":  [{"hooks": [{"type": "command", "command": "AGENTMEMORY_URL=http://localhost:3111 AGENTMEMORY_SECRET=<secret> node <npm-root-g>/@agentmemory/agentmemory/dist/hooks/prompt-submit.mjs"}]}],
    "PreToolUse":        [{"hooks": [{"type": "command", "command": "AGENTMEMORY_URL=http://localhost:3111 AGENTMEMORY_SECRET=<secret> AGENTMEMORY_INJECT_CONTEXT=true node <npm-root-g>/@agentmemory/agentmemory/dist/hooks/pre-tool-use.mjs"}]}],
    "PostToolUse":       [{"hooks": [{"type": "command", "command": "AGENTMEMORY_URL=http://localhost:3111 AGENTMEMORY_SECRET=<secret> node <npm-root-g>/@agentmemory/agentmemory/dist/hooks/post-tool-use.mjs"}]}],
    "PostToolUseFailure":[{"hooks": [{"type": "command", "command": "AGENTMEMORY_URL=http://localhost:3111 AGENTMEMORY_SECRET=<secret> node <npm-root-g>/@agentmemory/agentmemory/dist/hooks/post-tool-failure.mjs"}]}],
    "Stop":              [{"hooks": [{"type": "command", "command": "AGENTMEMORY_URL=http://localhost:3111 AGENTMEMORY_SECRET=<secret> node <npm-root-g>/@agentmemory/agentmemory/dist/hooks/stop.mjs"}]}],
    "SubagentStop":      [{"hooks": [{"type": "command", "command": "AGENTMEMORY_URL=http://localhost:3111 AGENTMEMORY_SECRET=<secret> node <npm-root-g>/@agentmemory/agentmemory/dist/hooks/subagent-stop.mjs"}]}],
    "PreCompact":        [{"hooks": [{"type": "command", "command": "AGENTMEMORY_URL=http://localhost:3111 AGENTMEMORY_SECRET=<secret> node <npm-root-g>/@agentmemory/agentmemory/dist/hooks/pre-compact.mjs"}]}],
    "Notification":      [{"hooks": [{"type": "command", "command": "AGENTMEMORY_URL=http://localhost:3111 AGENTMEMORY_SECRET=<secret> node <npm-root-g>/@agentmemory/agentmemory/dist/hooks/notification.mjs"}]}]
  }
}
```

> **⚠️ After volume reset** (`docker volume rm`), the server generates a new secret. Update the secret in both `.mcp.json` and `~/.claude/settings.json`.

### Cursor

```bash
mkdir -p .cursor
cp .mcp.json.example .cursor/mcp.json
# Open .cursor/mcp.json, replace REPLACE_ME with the secret from make secret
```

Restart Cursor. Check **Settings → MCP**: `agentmemory` shows ~8 tools (or ~51 if `AGENTMEMORY_TOOLS=all`).

### Claude Desktop

Add to `claude_desktop_config.json`:
- macOS: `~/Library/Application Support/Claude/claude_desktop_config.json`
- Windows: `%APPDATA%\Claude\claude_desktop_config.json`

```json
{
  "mcpServers": {
    "agentmemory": {
      "command": "npx",
      "args": ["-y", "@agentmemory/mcp"],
      "env": {
        "AGENTMEMORY_URL": "http://localhost:3111",
        "AGENTMEMORY_SECRET": "<secret-from-make-secret>"
      }
    }
  }
}
```

Quit Claude Desktop completely → reopen.

### Multiple projects, one server

Each repo uses the **same URL + secret** — agentmemory automatically separates memory by workspace path. No need for a separate server per project.

---

## VPS / remote server deployment

### Step 1 — Install Docker on VPS

```bash
curl -fsSL https://get.docker.com | sh
```

### Step 2 — Clone and start

```bash
git clone https://github.com/focela/agentmemory agentmemory && cd agentmemory
cp config/server.env.example docker/.env.server
# Edit docker/.env.server:
#   OPENAI_API_KEY=sk-...
#   OPENROUTER_API_KEY=sk-or-v1-...
#   OPENROUTER_MODEL=anthropic/claude-3.5-haiku
#   AGENTMEMORY_AUTO_COMPRESS=true
#   AGENTMEMORY_CORS_ORIGINS=https://memory.example.com
make up
make secret   # save the secret
```

### Step 3 — Reverse proxy + HTTPS

Two options:

**Option A — Nginx Proxy Manager** (recommended, UI-based):

NPM and agentmemory can run on the **same server** or **separate servers**.

*If NPM is on a separate server* — open agentmemory ports to the network and restrict access to the NPM server only:

```bash
# On the agentmemory VPS — allow only NPM server IP on ports 3111 and 3113
ufw allow from <NPM-SERVER-IP> to any port 3111
ufw allow from <NPM-SERVER-IP> to any port 3113
```

Then edit `docker/compose.yaml`, change port binding from `127.0.0.1` to `0.0.0.0`:

```yaml
ports:
  - "3111:3111"
  - "3113:13113"
```

Then run `make down && make up`.

*If NPM is on the same server* — keep `127.0.0.1`, use `host.docker.internal` as the forward hostname below.

Configure NPM:

1. Go to UI → **Proxy Hosts → Add Proxy Host**:
   - Domain: `memory.example.com`
   - Forward Hostname: IP of agentmemory VPS (or `host.docker.internal` if same machine)
   - Forward Port: `3111`
   - Enable **SSL → Request a new SSL Certificate** (Let's Encrypt automatic)
2. Update `AGENTMEMORY_CORS_ORIGINS` in `docker/.env.server`:
   ```bash
   AGENTMEMORY_CORS_ORIGINS=https://memory.example.com
   ```
3. Restart: `make down && make up`

**Option B — Manual Nginx:**

See template: [`config/nginx.conf.example`](config/nginx.conf.example)

```bash
apt install certbot python3-certbot-nginx
certbot --nginx -d memory.example.com
cp config/nginx.conf.example /etc/nginx/sites-available/agentmemory
# Edit server_name to your actual domain
ln -s /etc/nginx/sites-available/agentmemory /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

### Step 4 — Connect from dev machine

Use the public URL and saved secret in MCP config:

```json
"AGENTMEMORY_URL": "https://memory.example.com",
"AGENTMEMORY_SECRET": "<secret>"
```

> **Multiple projects, one server:** each repo uses the same URL + secret, agentmemory separates memory by workspace path.

---

## Environment configuration

| Template | Runtime (gitignored) | Purpose |
|----------|---------------------|---------|
| [`.env.example`](.env.example) | `docker/.env` | `COMPOSE_PROJECT_NAME` |
| [`config/server.env.example`](config/server.env.example) | `docker/.env.server` | API keys, CORS, tools |

After editing `docker/.env.server`: `make down && make up`.

---

## Commands

| Command | Description |
|---------|-------------|
| `make up` | Build & start server, auto-write logs to `logs/agentmemory.log` |
| `make down` | Stop server |
| `make logs` | Follow container logs (live in terminal) |
| `make secret` | Print `AGENTMEMORY_SECRET` |

---

## License

[LICENSE](LICENSE)
