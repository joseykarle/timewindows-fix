# Changelog

All notable changes to TimeWindows Fix are documented here. Format based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/); semantic versioning ([SemVer](https://semver.org/)).

## [0.1.0] - 2026-08-17

### Added

- **HTTPS time sync engine** (`scripts/TimeSync.ps1`): tries `w32tm` first, falls back to HTTPS `Date` headers from multiple sources (median), corrects the clock when drift > 5 s.
- **Watchdog** (`scripts/TimeWatchdog.ps1`): monitors last sync age and triggers the sync engine.
- **Idempotent setup** (`setup.ps1`): w32time fallback with unlimited phase correction, single `TimeSync` scheduled task (logon + network connect + every 15 min), removes old duplicate tasks.
- **Profesionalización GitHub** (GitListo v1.1.0): README, AGENTS.md, CLAUDE.md, LICENSE (MIT), SECURITY.md, CONTRIBUTING.md, CODE_OF_CONDUCT.md, CHANGELOG.md, PLAN.md, ROADMAP.md, docs/USER_GUIDE.md, `.github/` (CI + issue/PR templates) and `.markdownlint.json`.
