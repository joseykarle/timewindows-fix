# Security Policy

## Reporting a Vulnerability

**Do not open public issues for vulnerabilities.** Report privately:

- **GitHub**: use the repository's *private vulnerability reporting* feature.
- **Email**: `joseykarle@github.com` (reply within ≤ 48 business hours).

Include: description, affected version, reproduction steps (no real secrets) and estimated impact.

## Security posture

- **No secrets**: the scripts read only public HTTPS `Date` headers and adjust the local clock. No credentials, tokens or keys anywhere.
- **Least privilege**: the scheduled task runs as SYSTEM but executes only the two bundled scripts (`TimeSync.ps1`, `TimeWatchdog.ps1`); setup removes legacy third-party tasks.
- **No external binaries**: only PowerShell built-ins and the OS time services are used.
- **Supply chain**: the repo contains no dependencies — nothing to audit beyond the scripts themselves.
