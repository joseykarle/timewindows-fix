# ROADMAP — Pending improvements for TimeWindows Fix

Consolidated TODO list. Updated at each iteration close. **Do not modify this file or the CHANGELOG during implementation.**

## Priority criteria

- **P1 — Critical**: affects the integrity of the clock sync.
- **P2 — Important**: closes known edge cases.
- **P3 — Nice to have**: quality of life.

---

## 1. Validation (P1)

| # | TODO | Origin | Status |
|---|---|---|---|
| 1.1 | Field test 30 days on a machine with failing CMOS battery | Quality | ⬜ |
| 1.2 | Test behind a router that drops UDP 123 (the target scenario) | Quality | ⬜ |
| 1.3 | Verify the scheduled task survives reboots and network changes | Quality | ⬜ |

## 2. Configuration (P2)

| # | TODO | Origin | Status |
|---|---|---|---|
| 2.1 | Make the drift threshold and sync-age constants parameters | Usability | ⬜ |
| 2.2 | Add `-Verbose` diagnostics mode to `TimeSync.ps1` | Usability | ⬜ |
| 2.3 | Document multi-source median logic in USER_GUIDE | Docs | ⬜ |

## 3. Ecosystem (P3)

| # | TODO | Origin | Status |
|---|---|---|---|
| 3.1 | Optional installer for the Linux/WSL counterpart | Ecosystem | ⬜ |
| 3.2 | Scheduled-task health check via email/Telegram on repeated failures | Ecosystem | ⬜ |

## Suggested priority for the next iteration

1. **1.1/1.2** — the fix is only proven if validated on the target scenario (UDP 123 blocked).
2. **2.1** — parameterize thresholds for non-standard clocks.
3. Rest by convenience.
