# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| Latest release | ✅ |
| Previous release | ✅ (critical only) |
| Older versions | ❌ |

## Reporting a Vulnerability

If you discover a security vulnerability in homebrew-tap (the Uteke Homebrew tap), please report it responsibly.

**Do NOT** open a public issue for security vulnerabilities.

### How to Report

Use [GitHub Private Vulnerability Reporting](https://github.com/codecoradev/homebrew-tap/security/advisories/new) — this ensures the report is confidential and only visible to maintainers.

Include as much detail as possible:

- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

### What to Expect

- **Acknowledgment** within 48 hours
- **Initial assessment** within 5 business days
- **Fix timeline** depends on severity:
  - Critical: 7 days
  - High: 14 days
  - Medium: 30 days
  - Low: next minor release

### Security in the Development Process

This repository runs automated security checks on every PR:

- **Trivy FS Scan** — filesystem security scanning
- **GitGuardian** — secret leak detection

These are enforced via CI and block merge on findings.
