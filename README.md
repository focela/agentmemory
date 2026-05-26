# agentmemory

[![CI](https://github.com/focela/agentmemory/actions/workflows/ci.yml/badge.svg)](https://github.com/focela/agentmemory/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

Self-hosted Docker deployment template for
[agentmemory](https://github.com/rohitg00/agentmemory). It runs the REST API
and Viewer UI, with MCP client templates for Cursor, Claude Code, and Claude
Desktop.

> Vietnamese documentation: [README.vi.md](README.vi.md)

## Features

- Docker Compose stack for agentmemory.
- Persistent data volume for server state and memory data.
- Viewer UI exposed through a local proxy.
- MCP client templates for Cursor, Claude Code, and Claude Desktop.
- Optional Claude Code hooks for automatic memory capture.
- Local-first defaults with a documented VPS deployment path.

## Quick Start

### Requirements

| Component | Requirement |
|-----------|-------------|
| Docker Engine + Docker Compose v2 | Required |
| Node.js 20 or newer | Required for MCP clients that use `npx` |
| RAM | 2 GB or more on the server machine |

### Start Locally

```bash
git clone https://github.com/focela/agentmemory agentmemory
cd agentmemory
cp config/server.env.example docker/.env.server
```

Edit `docker/.env.server` and set the required API keys:

```bash
OPENAI_API_KEY=sk-...
OPENROUTER_API_KEY=sk-or-v1-...
```

Start the stack:

```bash
make up
```

Get the generated HMAC secret:

```bash
make secret
```

Verify the server:

```bash
curl -fsS http://localhost:3111/agentmemory/livez
```

Expected response:

```json
{"status":"ok"}
```

## Services

| URL | Service |
|-----|---------|
| `http://localhost:3111` | REST API |
| `http://localhost:3113` | Viewer UI |

## Configuration

agentmemory uses separate providers for embeddings and memory compression.

| Provider | Role | Environment variable |
|----------|------|----------------------|
| OpenAI | Embeddings and vector search | `OPENAI_API_KEY` |
| OpenRouter, Anthropic, or Gemini | LLM compression | See provider keys below |

The default LLM compression provider is OpenRouter with
`anthropic/claude-3.5-haiku`.

Supported provider keys:

- `OPENROUTER_API_KEY`
- `ANTHROPIC_API_KEY`
- `GEMINI_API_KEY`

| Template | Runtime file | Purpose |
|----------|--------------|---------|
| [`.env.example`](.env.example) | `docker/.env` | Docker Compose project name |
| [`config/server.env.example`](config/server.env.example) | `docker/.env.server` | API keys, CORS, and tool settings |

After editing `docker/.env.server`, restart the stack:

```bash
make down && make up
```

## MCP Clients

Use the generated `AGENTMEMORY_SECRET` when configuring MCP clients.

| Client | Guide |
|--------|-------|
| Claude Code | [docs/mcp-clients.md](docs/mcp-clients.md) |
| Cursor | [docs/mcp-clients.md](docs/mcp-clients.md) |
| Claude Desktop | [docs/mcp-clients.md](docs/mcp-clients.md) |

Multiple repositories can use the same server. agentmemory separates memory by
workspace path.

## Deployment

| Target | Guide |
|--------|-------|
| Local machine | [docs/deployment.md](docs/deployment.md) |
| VPS or remote server | [docs/deployment.md](docs/deployment.md) |
| Nginx reverse proxy | [config/nginx.conf.example](config/nginx.conf.example) |

## Commands

| Command | Description |
|---------|-------------|
| `make up` | Build and start the stack |
| `make down` | Stop the stack |
| `make logs` | Follow container logs |
| `make secret` | Print `AGENTMEMORY_SECRET` |

## Documentation

- [Architecture](docs/architecture.md)
- [Deployment](docs/deployment.md)
- [MCP clients](docs/mcp-clients.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Security policy](SECURITY.md)
- [Contributing](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)

## License

Apache-2.0. See [LICENSE](LICENSE).
