# Agentmemory Changelog

## Unreleased

### Features

- feat(docker): add Docker Compose deploy stack with agentmemory and viewer-proxy services, HMAC secret generation on first boot, daily log rotation ([#1](https://github.com/focela/agentmemory/pull/1))
- feat(scripts): add Makefile entry points (`up`, `down`, `logs`, `secret`) and lifecycle scripts with health check and log rotation via wrapper bash process ([#3](https://github.com/focela/agentmemory/pull/3))

### Build process updates / CI

- ci(github): add lint and build checks — shellcheck, hadolint, compose validate, docker build ([#9](https://github.com/focela/agentmemory/pull/9))
- ci(github): add docker image publish workflow with multi-arch build (linux/amd64, linux/arm64) to ghcr.io and SLSA build provenance attestation ([#11](https://github.com/focela/agentmemory/pull/11))

### Documentation updates

- docs(community): add English and Vietnamese README documenting Docker Compose setup, MCP client configuration, and port reference ([#7](https://github.com/focela/agentmemory/pull/7))
- docs(community): add CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md community files ([#7](https://github.com/focela/agentmemory/pull/7))
- docs(github): add issue templates, PR template, and CODEOWNERS ([#13](https://github.com/focela/agentmemory/pull/13))
- docs(guides): add ARCHITECTURE.md and TROUBLESHOOTING.md ([#15](https://github.com/focela/agentmemory/pull/15))

### Maintenance

- chore(config): add `.mcp.json.example` template for MCP server configuration ([#5](https://github.com/focela/agentmemory/pull/5))
- chore(config): update `.gitignore` — ignore `.claude/`, `.mcp.json`, `.cursor/mcp.json`, `docker/.env*`, `.agentmemory/`, `logs/*`; reorder env section so `.env.example` stays tracked ([#5](https://github.com/focela/agentmemory/pull/5))
