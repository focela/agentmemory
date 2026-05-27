# agentmemory

[![CI](https://github.com/focela/agentmemory/actions/workflows/ci.yml/badge.svg)](https://github.com/focela/agentmemory/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

Template Docker tự host cho
[agentmemory](https://github.com/rohitg00/agentmemory). Repo này chạy REST
API và Viewer UI, kèm template MCP client cho Cursor, Claude Code, Claude
Desktop.

> English documentation: [README.md](README.md)

## Tính năng

- Docker Compose stack cho agentmemory.
- Bind mount trên filesystem host để lưu state và dữ liệu memory.
- Viewer UI qua local proxy.
- MCP client template cho Cursor, Claude Code, và Claude Desktop.
- Claude Code hooks tùy chọn để tự động ghi memory.
- Mặc định chạy local, có hướng dẫn triển khai VPS riêng.

## Bắt đầu nhanh

### Yêu cầu

| Thành phần | Yêu cầu |
|------------|---------|
| Docker Engine + Docker Compose v2 | Bắt buộc |
| Node.js 20 hoặc mới hơn | Cần cho MCP client dùng `npx` |
| RAM | Tối thiểu 2 GB trên máy chạy server |

### Chạy local

```bash
git clone https://github.com/focela/agentmemory agentmemory
cd agentmemory
cp config/server.env.example docker/.env.server
```

Sửa `docker/.env.server` và điền API keys bắt buộc:

```bash
OPENAI_API_KEY=sk-...
OPENROUTER_API_KEY=sk-or-v1-...
```

Khởi động stack:

```bash
make up
```

Lấy HMAC secret:

```bash
make secret
```

Kiểm tra server:

```bash
curl -fsS http://localhost:3111/agentmemory/livez
```

Kết quả mong đợi:

```json
{"status":"ok"}
```

## Dịch vụ

| URL | Dịch vụ |
|-----|---------|
| `http://localhost:3111` | REST API |
| `http://localhost:3113` | Viewer UI |

## Cấu hình

agentmemory dùng provider riêng cho embeddings và memory compression.

| Provider | Vai trò | Biến môi trường |
|----------|---------|-----------------|
| OpenAI | Embeddings và vector search | `OPENAI_API_KEY` |
| OpenRouter, Anthropic, hoặc Gemini | LLM compression | Xem danh sách bên dưới |

Provider mặc định cho LLM compression là OpenRouter với
`anthropic/claude-3.5-haiku`.

Các biến môi trường được hỗ trợ:

- `OPENROUTER_API_KEY`
- `ANTHROPIC_API_KEY`
- `GEMINI_API_KEY`

| Template | File runtime | Mục đích |
|----------|--------------|----------|
| [`.env.example`](.env.example) | `docker/.env` | Tên Docker Compose project |
| [`config/server.env.example`](config/server.env.example) | `docker/.env.server` | API keys, CORS, và tool settings |

Sau khi sửa `docker/.env.server`, restart stack:

```bash
make down && make up
```

## MCP Clients

Dùng `AGENTMEMORY_SECRET` khi cấu hình MCP client.

| Client | Hướng dẫn |
|--------|-----------|
| Claude Code | [docs/mcp-clients.md](docs/mcp-clients.md) |
| Cursor | [docs/mcp-clients.md](docs/mcp-clients.md) |
| Claude Desktop | [docs/mcp-clients.md](docs/mcp-clients.md) |

Nhiều repository có thể dùng cùng một server. agentmemory tách memory theo
workspace path.

## Triển khai

| Mục tiêu | Hướng dẫn |
|----------|-----------|
| Máy local | [docs/deployment.md](docs/deployment.md) |
| VPS hoặc remote server | [docs/deployment.md](docs/deployment.md) |
| Nginx reverse proxy | [config/nginx.conf.example](config/nginx.conf.example) |

## Lệnh

| Lệnh | Mô tả |
|------|-------|
| `make up` | Build và khởi động stack |
| `make down` | Dừng stack |
| `make logs` | Theo dõi container logs |
| `make secret` | In `AGENTMEMORY_SECRET` |

## Tài liệu

- [Architecture](docs/architecture.md)
- [Deployment](docs/deployment.md)
- [MCP clients](docs/mcp-clients.md)
- [Troubleshooting](docs/troubleshooting.md)
- [Security policy](SECURITY.md)
- [Contributing](CONTRIBUTING.md)
- [Changelog](CHANGELOG.md)

## License

Apache-2.0. Xem [LICENSE](LICENSE).
