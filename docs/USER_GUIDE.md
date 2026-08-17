# USER_GUIDE — TimeWindows Fix operation manual

How the fix works and how to operate it.

## The problem in one paragraph

`w32time` syncs over **NTP/UDP 123** and cannot use another port. Many routers/ISPs in Latin America silently drop NTP replies, so the clock stays wrong. This project syncs over **HTTPS** (port 443, never blocked) reading the `Date` header from several servers and correcting the clock.

## Installation

1. Open PowerShell **as administrator**.
2. Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\setup.ps1
```

1. The clock is corrected immediately; a **TimeSync** scheduled task keeps it accurate every 15 minutes (and at logon / network connect).

## What setup.ps1 does

- Configures `w32time` as fallback with unlimited phase correction (for big jumps after a dead battery).
- Registers a single `TimeSync` scheduled task running as SYSTEM.
- Removes old/duplicate tasks (`TimeWatchdog`, `Sincronizar hora automáticamente`, `Sincronizar hora cada hora`).
- Safe to re-run (idempotent).

## Daily operation

| Moment | Action |
|---|---|
| Check logs | `Get-Content .\scripts\TimeSync.log` / `TimeWatchdog.log` |
| Force a sync | `.\scripts\TimeSync.ps1` |
| Check the task | `Get-ScheduledTask -TaskName TimeSync` |
| Uninstall | `Unregister-ScheduledTask -TaskName TimeSync -Confirm:$false` |

## Troubleshooting

| Symptom | Solution |
|---|---|
| Clock not corrected | Read `scripts\TimeSync.log`; check internet connectivity |
| "No time data was available" from w32tm | Expected — the HTTPS fallback handles it; verify the task ran |
| Task missing after reboot | Re-run `setup.ps1`; check `Get-ScheduledTask -TaskName TimeSync` |
| Logs empty | The task runs as SYSTEM — logs live next to the scripts, verify permissions |

## Notes

- Replacing the CMOS battery is still recommended: the fix keeps the clock accurate but the battery should be replaced so the clock does not reset when the PC is powered off.
- Works on Windows PowerShell 5.1+ (no PowerShell 7 requirement).
