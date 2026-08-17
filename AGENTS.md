# AGENTS.md — TimeWindows Fix

> Universal installation guide for AI agents. Reading this file is enough to work correctly in this repository.

## What this repository is

TimeWindows Fix: PowerShell scripts and scheduled-task configuration that keep the Windows clock synchronized over HTTPS when NTP/UDP 123 is blocked by the router or ISP. **This repo contains no application code** — it is a scripts + documentation project. There is no build or test suite (scripts are PowerShell).

## Golden rules (mandatory for every agent)

1. **Read before touching**: any change requires reading the script/README it affects first. Rewriting "from memory" is forbidden.
2. **Keep PowerShell compatibility 5.1+**: scripts run on Windows PowerShell 5.1 (no PowerShell 7-only syntax).
3. **No secrets**: scripts only read public HTTPS `Date` headers; never add credentials.
4. **Task registration is idempotent**: `setup.ps1` must be safe to re-run (it already removes old/duplicate time-sync tasks).
5. **Conventions**: content in English; file names in kebab-case; no emojis except ✅/❌/⚠️; one `#` per document.
6. **No unnecessary content**: less is more. Each file ≤ 200 lines unless justified.

## Project structure

```text
timewindows-fix/
├── setup.ps1                  # One-time setup: w32time fallback + TimeSync scheduled task
├── scripts/
│   ├── TimeSync.ps1           # Main sync engine (w32tm → HTTPS fallback)
│   └── TimeWatchdog.ps1       # Sync age watchdog
├── docs/USER_GUIDE.md         # Operation manual
└── AGENTS.md                  # This file
```

## Daily work (agent in this repo)

- To edit a script: read the script and its usage header first; keep the documented interface (flags, log files) unchanged.
- To edit documentation: read the script it describes, then update the README/USER_GUIDE references if needed.
- To complete a TODO: do not change ROADMAP/CHANGELOG during implementation; ROADMAP updates at iteration close, CHANGELOG at release.
- Bugs and improvements: open an issue with the project's GitHub template, or a PR with the PR template. Never push to `main` directly.

## Quality of changes (verification)

```bash
# Markdown lint — mandatory, 0 errors
npx markdownlint-cli2 "*.md" "docs/**/*.md" ".github/**/*.md"

# Manual verification:
# - internal links valid (each referenced file exists)
# - PowerShell syntax check: $null = [System.Management.Automation.Language.Parser]::ParseFile((Resolve-Path 'scripts\TimeSync.ps1'), [ref]$null, [ref]$null)
```

## Contact

Project status and pending improvements: `ROADMAP.md`. Contribution questions: `CONTRIBUTING.md`.
