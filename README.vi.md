# agentmemory

Self-host template cho [**agentmemory**](https://github.com/rohitg00/agentmemory) — Docker stack, Viewer UI, MCP cho Cursor / Claude Code / Claude Desktop.

| URL | Service |
|-----|---------|
| http://localhost:3111 | REST API |
| http://localhost:3113 | Viewer UI |

---

## Yêu cầu

| Thành phần | Bắt buộc |
|------------|---------|
| Docker Engine + Compose v2 | ✅ |
| Node.js ≥ 20 (cho MCP client `npx`) | ✅ máy dev |
| RAM ≥ 2 GB | ✅ máy chạy server |

---

## Triển khai local (lần đầu)

### Bước 1 — Clone repo

```bash
git clone https://github.com/focela/agentmemory agentmemory
cd agentmemory
```

### Bước 2 — Cấu hình server

`make up` tự tạo `docker/.env.server` từ template. Mở file và điền API keys:

```bash
cp config/server.env.example docker/.env.server
# Mở docker/.env.server và điền:
```

agentmemory dùng **2 loại AI provider độc lập**:

| Provider | Vai trò | Env var |
|----------|---------|---------|
| OpenAI | Embeddings (vector search) — bắt buộc | `OPENAI_API_KEY` |
| OpenRouter / Anthropic / Gemini | LLM compression (tổng hợp memory) | `OPENROUTER_API_KEY` hoặc `ANTHROPIC_API_KEY` hoặc `GEMINI_API_KEY` |

Provider mặc định cho LLM compression — OpenRouter với `anthropic/claude-3.5-haiku`:

```bash
OPENAI_API_KEY=sk-...                         # embeddings
OPENROUTER_API_KEY=sk-or-v1-...              # LLM compression
OPENROUTER_MODEL=anthropic/claude-3.5-haiku  # model (mặc định nếu bỏ trống)
AGENTMEMORY_TOOLS=all
AGENTMEMORY_INJECT_CONTEXT=true
AGENTMEMORY_AUTO_COMPRESS=true               # tự động compress observations sau mỗi tool use
CONSOLIDATION_ENABLED=true                   # tự động promote observations → Memories sau mỗi session kết thúc
```

> Xem đầy đủ các tùy chọn tại [`config/server.env.example`](config/server.env.example)

### Bước 3 — Khởi động server

```bash
make up
```

Script tự build image, chờ health check, in `AGENTMEMORY_SECRET` khi ready.

### Bước 4 — Lưu secret

```bash
make secret
# AGENTMEMORY_SECRET=<hex-64-chars>
```

Lưu giá trị này vào password manager. Dùng để cấu hình MCP client ở bước tiếp theo.

### Bước 5 — Xác minh

```bash
curl -fsS http://localhost:3111/agentmemory/livez
# {"status":"ok"}
```

---

## Kết nối MCP client

Lấy secret trước: `make secret` → `AGENTMEMORY_SECRET=<value>`

Tất cả MCP config đều **gitignored** — tạo từ template rồi điền secret. Cách này hoạt động trên mọi OS (Windows / macOS / Linux).

### Claude Code

**MCP** — kết nối tools agentmemory vào Claude Code:

```bash
cp .mcp.json.example .mcp.json
# Mở .mcp.json, thay REPLACE_ME bằng secret từ make secret
```

> Template: [`.mcp.json.example`](.mcp.json.example)

**Hooks** — tự động ghi memory sau mỗi tool use (cài 1 lần, dùng cho mọi dự án):

```bash
# Bước 1 — Cài package hook toàn cục
npm install -g @agentmemory/agentmemory

# Bước 2 — Lấy đường dẫn node_modules toàn cục trên máy của bạn
npm root -g
```

Đường dẫn thường gặp theo OS:

| OS | Đường dẫn điển hình |
|----|---------------------|
| macOS (Homebrew) | `/opt/homebrew/lib/node_modules` |
| macOS (nvm) | `~/.nvm/versions/node/<version>/lib/node_modules` |
| Linux | `/usr/local/lib/node_modules` |
| Windows | `C:\Users\<user>\AppData\Roaming\npm\node_modules` |

Thêm vào `~/.claude/settings.json` — thay `<npm-root-g>` bằng output của `npm root -g`, thay `<secret>` bằng output của `make secret`:

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

> **⚠️ Khi reset volume** (`docker volume rm`), server sinh secret mới. Phải cập nhật lại secret trong cả `.mcp.json` lẫn `~/.claude/settings.json`.

### Cursor

```bash
mkdir -p .cursor
cp .mcp.json.example .cursor/mcp.json
# Mở .cursor/mcp.json, thay REPLACE_ME bằng secret từ make secret
```

Restart Cursor. Kiểm tra **Settings → MCP**: `agentmemory` hiển thị ~8 tools (hoặc ~51 nếu `AGENTMEMORY_TOOLS=all`).

### Claude Desktop

Thêm vào `claude_desktop_config.json`:
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
        "AGENTMEMORY_SECRET": "<secret-từ-make-secret>"
      }
    }
  }
}
```

Quit Claude Desktop hoàn toàn → mở lại.

### Nhiều dự án, một server

Mỗi repo dùng **cùng URL + secret** — agentmemory tự tách memory theo workspace path. Không cần server riêng cho từng dự án.

---

## Triển khai VPS / server từ xa

### Bước 1 — Cài Docker trên VPS

```bash
curl -fsSL https://get.docker.com | sh
```

### Bước 2 — Clone và start

```bash
git clone https://github.com/focela/agentmemory agentmemory && cd agentmemory
cp config/server.env.example docker/.env.server
# Chỉnh docker/.env.server:
#   OPENAI_API_KEY=sk-...
#   OPENROUTER_API_KEY=sk-or-v1-...
#   OPENROUTER_MODEL=anthropic/claude-3.5-haiku
#   AGENTMEMORY_AUTO_COMPRESS=true
#   AGENTMEMORY_CORS_ORIGINS=https://memory.example.com
make up
make secret   # lưu lại secret
```

### Bước 3 — Reverse proxy + HTTPS

Có 2 cách:

**Cách A — Nginx Proxy Manager** (khuyến nghị, có UI):

NPM và agentmemory có thể chạy trên **cùng server** hoặc **server riêng**.

*Nếu NPM trên server riêng* — cần mở port agentmemory ra network và dùng firewall giới hạn chỉ NPM server truy cập:

```bash
# Trên agentmemory VPS — chỉ cho NPM server IP kết nối vào port 3111 và 3113
ufw allow from <NPM-SERVER-IP> to any port 3111
ufw allow from <NPM-SERVER-IP> to any port 3113
```

Rồi sửa `docker/compose.yaml`, đổi port binding từ `127.0.0.1` thành `0.0.0.0`:

```yaml
ports:
  - "3111:3111"
  - "3113:13113"
```

Sau đó `make down && make up`.

*Nếu NPM cùng server* — giữ nguyên `127.0.0.1`, dùng `host.docker.internal` ở bước dưới.

Cấu hình NPM:

1. Vào UI → **Proxy Hosts → Add Proxy Host**:
   - Domain: `memory.example.com`
   - Forward Hostname: IP của agentmemory VPS (hoặc `host.docker.internal` nếu cùng máy)
   - Forward Port: `3111`
   - Bật **SSL → Request a new SSL Certificate** (Let's Encrypt tự động)
2. Cập nhật `AGENTMEMORY_CORS_ORIGINS` trong `docker/.env.server`:
   ```bash
   AGENTMEMORY_CORS_ORIGINS=https://memory.example.com
   ```
3. Chạy lại: `make down && make up`

**Cách B — Nginx thủ công:**

Xem template: [`config/nginx.conf.example`](config/nginx.conf.example)

```bash
apt install certbot python3-certbot-nginx
certbot --nginx -d memory.example.com
cp config/nginx.conf.example /etc/nginx/sites-available/agentmemory
# Sửa server_name thành domain thực
ln -s /etc/nginx/sites-available/agentmemory /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx
```

### Bước 4 — Kết nối từ máy dev

Dùng URL public và secret vừa lưu trong MCP config:

```json
"AGENTMEMORY_URL": "https://memory.example.com",
"AGENTMEMORY_SECRET": "<secret>"
```

> **Nhiều dự án, một server:** mỗi repo dùng cùng URL + secret, agentmemory tự tách memory theo workspace path.

---

## Cấu hình môi trường

| Template | Runtime (gitignored) | Mục đích |
|----------|---------------------|---------|
| [`.env.example`](.env.example) | `docker/.env` | `COMPOSE_PROJECT_NAME` |
| [`config/server.env.example`](config/server.env.example) | `docker/.env.server` | API keys, CORS, tools |

Sau khi sửa `docker/.env.server`: `make down && make up`.

---

## Commands

| Command | Mô tả |
|---------|-------|
| `make up` | Build & start server, tự ghi log vào `logs/agentmemory.log` |
| `make down` | Stop server |
| `make logs` | Follow container logs (live trên terminal) |
| `make secret` | In `AGENTMEMORY_SECRET` |

---

## License

[LICENSE](LICENSE)
