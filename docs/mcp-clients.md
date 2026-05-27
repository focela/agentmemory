# MCP Clients

Use the same `AGENTMEMORY_URL` and `AGENTMEMORY_SECRET` for all MCP clients.

Get the secret from the running server:

```bash
make secret
```

Local MCP config files are gitignored. Create them from templates, then replace
`REPLACE_ME` with the secret.

## Claude Code

### MCP Tools

Create the local MCP config:

```bash
cp .mcp.json.example .mcp.json
```

Edit `.mcp.json` and replace `REPLACE_ME` with the value from `make secret`.

Template: [`.mcp.json.example`](../.mcp.json.example)

### Hooks

Claude Code hooks can capture memory after each tool use.

Install the hook package globally:

```bash
npm install -g @agentmemory/agentmemory
```

Find the global `node_modules` path:

```bash
npm root -g
```

Common paths:

| OS | Typical path |
|----|--------------|
| macOS with Homebrew | `/opt/homebrew/lib/node_modules` |
| macOS with nvm | `~/.nvm/versions/node/<version>/lib/node_modules` |
| Linux | `/usr/local/lib/node_modules` |
| Windows | `C:\Users\<user>\AppData\Roaming\npm\node_modules` |

Add hooks to `~/.claude/settings.json`.

Replace `<npm-root-g>` with the output of `npm root -g`.
Replace `<secret>` with the output of `make secret`.

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "AGENTMEMORY_URL=http://localhost:3111 AGENTMEMORY_SECRET=<secret> AGENTMEMORY_INJECT_CONTEXT=true node <npm-root-g>/@agentmemory/agentmemory/dist/hooks/session-start.mjs"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "AGENTMEMORY_URL=http://localhost:3111 AGENTMEMORY_SECRET=<secret> node <npm-root-g>/@agentmemory/agentmemory/dist/hooks/prompt-submit.mjs"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "AGENTMEMORY_URL=http://localhost:3111 AGENTMEMORY_SECRET=<secret> AGENTMEMORY_INJECT_CONTEXT=true node <npm-root-g>/@agentmemory/agentmemory/dist/hooks/pre-tool-use.mjs"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "AGENTMEMORY_URL=http://localhost:3111 AGENTMEMORY_SECRET=<secret> node <npm-root-g>/@agentmemory/agentmemory/dist/hooks/post-tool-use.mjs"
          }
        ]
      }
    ],
    "PostToolUseFailure": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "AGENTMEMORY_URL=http://localhost:3111 AGENTMEMORY_SECRET=<secret> node <npm-root-g>/@agentmemory/agentmemory/dist/hooks/post-tool-failure.mjs"
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "AGENTMEMORY_URL=http://localhost:3111 AGENTMEMORY_SECRET=<secret> node <npm-root-g>/@agentmemory/agentmemory/dist/hooks/stop.mjs"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "AGENTMEMORY_URL=http://localhost:3111 AGENTMEMORY_SECRET=<secret> node <npm-root-g>/@agentmemory/agentmemory/dist/hooks/subagent-stop.mjs"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "AGENTMEMORY_URL=http://localhost:3111 AGENTMEMORY_SECRET=<secret> node <npm-root-g>/@agentmemory/agentmemory/dist/hooks/pre-compact.mjs"
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "AGENTMEMORY_URL=http://localhost:3111 AGENTMEMORY_SECRET=<secret> node <npm-root-g>/@agentmemory/agentmemory/dist/hooks/notification.mjs"
          }
        ]
      }
    ]
  }
}
```

If the data directory is cleared on the host, the server generates a new
secret. Update it in `.mcp.json` and `~/.claude/settings.json`.

## Cursor

Create the Cursor MCP config:

```bash
mkdir -p .cursor
cp .mcp.json.example .cursor/mcp.json
```

Edit `.cursor/mcp.json` and replace `REPLACE_ME` with the value from
`make secret`.

Restart Cursor. Check `Settings > MCP`; `agentmemory` should appear in the MCP
server list.

## Claude Desktop

Add the MCP server to `claude_desktop_config.json`.

| OS | Config path |
|----|-------------|
| macOS | `~/Library/Application Support/Claude/claude_desktop_config.json` |
| Windows | `%APPDATA%\Claude\claude_desktop_config.json` |

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

Quit Claude Desktop completely, then open it again.

## Multiple Projects

Each repository can use the same URL and secret. agentmemory separates memory
by workspace path.
