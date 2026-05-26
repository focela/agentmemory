# Contributing

Thank you for your interest in contributing to agentmemory. This guide covers
the public development workflow, commit format, and pull request expectations.

## Development Setup

1. Install Docker Engine and Docker Compose v2.
2. Clone the repository:
   ```bash
   git clone https://github.com/focela/agentmemory.git
   cd agentmemory
   ```
3. Create local environment files:
   ```bash
   cp .env.example docker/.env
   cp config/server.env.example docker/.env.server
   ```
4. Start the stack:
   ```bash
   make up
   ```

## Before You Start

- Search existing issues and pull requests before opening a new one.
- Keep changes focused on one problem or feature.
- Include documentation updates when behavior or configuration changes.
- Use small pull requests when possible.

## Branches

Use short-lived branches from the latest `main` branch.

Branch naming follows the Jira ticket number (`AGM-N`):

| Pattern | Use case |
|---------|----------|
| `feature/AGM-N` | New feature targeting `main` |
| `feature/AGM-N_M` | Cherry-pick of `feature/AGM-N` targeting `develop` (M = test cycle) |
| `fix/AGM-N` | Bug fix targeting `main` |
| `chore/AGM-N` | Maintenance task targeting `main` |

`N` is the Jira ticket number. `M` increments per QA test cycle on `develop`.

## Commit Messages

This project follows [Conventional Commits](https://www.conventionalcommits.org).

```text
<type>(<scope>): <description>
```

Examples:

```text
feat(docker): add health check
fix(scripts): handle missing secret file
docs(readme): add deployment guide link
```

Allowed types:

- `build`
- `chore`
- `ci`
- `docs`
- `feat`
- `fix`
- `perf`
- `refactor`
- `test`

## Pull Requests

Each feature is delivered through two pull requests:

1. `feature/AGM-N` to `main` (production target).
2. `feature/AGM-N_M` to `develop` (cherry-picked from the first PR for QA).

If QA finds a bug, fix on `feature/AGM-N`, then create
`feature/AGM-N_{M+1}` and cherry-pick the fix to `develop` again.

Before opening a pull request:

1. Rebase the latest target branch (`main` or `develop`).
2. Run the relevant local checks.
3. Verify the stack still starts when deployment files change.
4. Update documentation for user-facing changes.

PR title format:

```text
AGM-N [TARGET] Imperative description
```

Examples:

- `AGM-12 [MAIN] Add OpenTelemetry tracing`
- `AGM-12 [DEV] Add OpenTelemetry tracing`

Each pull request should include:

- A short description of the change.
- A list of notable implementation details.
- Manual or automated test results.
- A cross-reference to the matching main or develop PR.
- A link to the Jira ticket.

## Code Review

- At least one maintainer approval is required before merge.
- Address review comments or explain why a change is not needed.
- Keep follow-up work explicit in the pull request notes.
- Squash merge is the default.

## Reporting Issues

Use GitHub issues for bugs and feature requests. Include enough detail to
reproduce the problem when reporting a bug.

For security vulnerabilities, follow [SECURITY.md](SECURITY.md).
