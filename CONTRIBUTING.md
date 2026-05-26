# Contributing

Thank you for your interest in contributing to agentmemory. This document
describes the development workflow, commit conventions, and review process.

## Development setup

1. Install Docker Engine and Docker Compose v2 (≥ 2.24)
2. Clone the repository and copy the example env files:
   ```bash
   git clone https://github.com/focela/agentmemory.git
   cd agentmemory
   cp .env.example docker/.env
   cp config/server.env.example docker/.env.server
   ```
3. Start the stack:
   ```bash
   make up
   ```

## Branch naming

| Pattern | Use case |
|---------|----------|
| `feature/AGM-N` | New feature targeting `main` |
| `feature/AGM-N_M` | Cherry-pick of `feature/AGM-N` targeting `develop` (M = test cycle) |
| `fix/AGM-N` | Bug fix targeting `main` |
| `chore/AGM-N` | Maintenance task targeting `main` |

`N` is the Jira ticket number. `M` increments per QA test cycle on `develop`.

## Commit message convention

This project follows [Conventional Commits](https://www.conventionalcommits.org).

```
<type>(<scope>): <description>

<body>

<footer>
```

Rules:
- Title is lowercase
- Maximum 50 characters in title (including type, scope, colon, spaces)
- Body wrapped at 72 characters
- AI-assisted commits include `Co-Authored-By: Claude <model> <email>` trailer

Allowed types: `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `chore`, `build`, `ci`.

## Pull request process

1. Branch from latest `main` (`git fetch origin && git reset --hard origin/main`)
2. Push to remote and open a PR targeting `main`
3. Cherry-pick the commit onto a new `feature/AGM-N_1` branch from `develop`
   and open a second PR targeting `develop` for QA testing
4. Address Codex review comments; iterate until no major issues remain
5. Request review from a maintainer
6. After approval, the PR is squash-merged

### PR title format

```
AGM-N [TARGET] Imperative description
```

Examples:
- `AGM-12 [MAIN] Add OpenTelemetry tracing`
- `AGM-12 [DEV] Add OpenTelemetry tracing`

### PR body

Each PR must include these sections:
- `## Description` — one-paragraph summary
- `## Changes` — bulleted list of code-level changes
- `## Testing` — checklist of manual verification steps
- `## Notes` — implementation notes, compatibility considerations
- `## Related PRs` — cross-references to main and develop PRs
- `## Jira` — link to the ticket

## Code review

- All PRs require at least one approval from a maintainer
- Codex automated review runs on every push
- All review threads must be resolved before merge
- Squash merge is the default; merge commits are allowed on `develop` only

## Reporting issues

For bugs and feature requests, open an issue using the appropriate template.
For security vulnerabilities, see [SECURITY.md](SECURITY.md) instead.
