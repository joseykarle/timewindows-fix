# PLAN — TimeWindows Fix implementation plan

> Executive summary. The project is small and mostly complete; this plan tracks the remaining polish and maintenance tasks.

## Definition of "done" (global)

- [ ] Clock stays accurate (drift < 5 s) while internet is available.
- [ ] Single scheduled task registered (no duplicates), setup idempotent.
- [ ] Logs readable and actionable in `scripts/TimeSync.log` / `TimeWatchdog.log`.
- [ ] Markdownlint 0 errors; no secrets in the repo (gitleaks in CI).

## Status

| Task | State |
|---|---|
| HTTPS time sync engine (`TimeSync.ps1`) | ✅ Done |
| Watchdog (`TimeWatchdog.ps1`) | ✅ Done |
| Idempotent setup + scheduled task (`setup.ps1`) | ✅ Done |
| Repository profesionalización (GitListo v1.1.0) | ✅ Done |
| Long-running validation on a real failing battery | ⬜ Pending |

## Next iteration

1. Long-running field test (30 days) on a machine with a failing CMOS battery.
2. Optionally add a `-Verbose` mode to `TimeSync.ps1` for diagnostics.
3. Keep the watchdog threshold (sync age) configurable via parameter instead of constant.
