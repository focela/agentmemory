# Security Policy

## Supported Versions

This project is in pre-release development. Security fixes are applied only to
the `main` branch. After the first stable release, the most recent minor
version line will receive security updates.

## Reporting a Vulnerability

Do **not** report security vulnerabilities through public GitHub issues.

Instead, report them privately via one of:

- GitHub Security Advisories: <https://github.com/focela/agentmemory/security/advisories/new>
- Email: <security@focela.com.vn>

Include the following information:

- Affected component and version (commit SHA if reporting against `main`)
- Description of the vulnerability and potential impact
- Steps to reproduce
- Suggested fix, if available

You will receive an acknowledgement within 3 business days. We aim to provide
a status update within 7 days and a fix or mitigation within 30 days,
depending on severity.

## Sensitive Data

Do not commit secrets, local environment files, or runtime logs.

Examples include:

- `.env`, `.env.*`, `docker/.env`, and `docker/.env.server`
- `.mcp.json` and `.cursor/mcp.json`
- HMAC secrets from `/data/.hmac` or `make secret`
- Files under `logs/`, except `logs/.gitkeep`

If sensitive data is committed, rotate the affected secret and report the
incident through the private vulnerability reporting process above.

## Disclosure Policy

We follow coordinated disclosure:

1. Reporter submits the vulnerability privately
2. We acknowledge receipt and begin investigation
3. We work with the reporter to validate the issue and develop a fix
4. We publish the fix and a security advisory
5. Public disclosure occurs 30 days after the fix is released, or sooner if
   agreed with the reporter

## Scope

The following are considered security issues:

- HMAC secret exposure or weakening
- Authentication or authorization bypass
- Remote code execution in the container or host
- Data exfiltration from the persistent volume
- Vulnerabilities in container build or supply chain

The following are out of scope:

- Vulnerabilities requiring physical access to the host
- Issues in third-party dependencies that are already disclosed and pending
  upstream patch
- Issues only reproducible against unsupported configurations
