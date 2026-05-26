# Changelog

All notable changes to this project are documented in this file.

This project follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and uses [Conventional Commits](https://www.conventionalcommits.org).

## Unreleased

### Added

- Docker Compose deployment stack with `agentmemory` and `viewer-proxy`
  services, first-boot HMAC secret generation, and daily log rotation
  ([#1](https://github.com/focela/agentmemory/pull/1)).
- Makefile entry points for `up`, `down`, `logs`, and `secret`, backed by
  lifecycle scripts with health checks and log rotation
  ([#3](https://github.com/focela/agentmemory/pull/3)).
- MCP server configuration template in `.mcp.json.example`
  ([#5](https://github.com/focela/agentmemory/pull/5)).
- English and Vietnamese README files for Docker Compose setup, MCP client
  configuration, and port references
  ([#7](https://github.com/focela/agentmemory/pull/7)).
- Community files: `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, and
  `SECURITY.md` ([#7](https://github.com/focela/agentmemory/pull/7)).
- GitHub issue templates, pull request template, and CODEOWNERS
  ([#13](https://github.com/focela/agentmemory/pull/13)).
- Architecture and troubleshooting guides
  ([#15](https://github.com/focela/agentmemory/pull/15)).
- CI checks for ShellCheck, Hadolint, Docker Compose validation, and Docker
  image builds ([#9](https://github.com/focela/agentmemory/pull/9)).
- Docker image publish workflow with multi-architecture builds, GHCR publish,
  and provenance attestation
  ([#11](https://github.com/focela/agentmemory/pull/11)).

### Changed

- Expanded `.gitignore` for local MCP config, Docker env files, Claude Code
  workspace files, logs, and agentmemory runtime data
  ([#5](https://github.com/focela/agentmemory/pull/5)).
