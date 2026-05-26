# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Docker Compose deploy stack with `agentmemory` and `viewer-proxy` services,
  HMAC secret generation on first boot, daily log rotation (#1)
- Makefile entry points (`up`, `down`, `logs`, `secret`) and lifecycle scripts
  with health check and log rotation via wrapper bash process (#3)
- `.mcp.json.example` template for MCP server configuration (#5)
- English and Vietnamese README documenting Docker Compose setup, MCP client
  configuration, and port reference (#7)
- `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `SECURITY.md` community files (#7)

### Changed

- `.gitignore`: ignore `.claude/`, `.mcp.json`, `.cursor/mcp.json`,
  `docker/.env*`, `.agentmemory/`, `logs/*`; reorder env section so
  `.env.example` stays tracked (#5)

[Unreleased]: https://github.com/focela/agentmemory/commits/main
