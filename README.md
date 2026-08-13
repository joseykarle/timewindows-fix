# TimeWindows Fix

Scripts and configurations to keep the system clock synchronized, useful when the CMOS battery is failing.

## Why this fix exists

`w32time` (the Windows Time service) syncs exclusively over **NTP/UDP port 123**, using port 123 as its source port.
Many routers and ISPs (common in Latin America) silently drop NTP replies addressed to source port 123,
so `w32tm /resync` reports *"The computer did not resync because no time data was available"* and the clock
stays on the local CMOS clock. There is no way to make w32time use another port.

**Solution:** synchronize over HTTPS, reading the `Date` header from several reliable web servers
(microsoft.com, cloudflare.com, google.com, bing.com), taking the median, and adjusting the local clock.
HTTPS (port 443) is never blocked the way UDP 123 is.

## Features

- `scripts/TimeSync.ps1` – main sync engine: tries `w32tm` first, falls back to HTTPS time sources,
  corrects the clock if it drifts more than 5 seconds.
- `scripts/TimeWatchdog.ps1` – checks the last sync age and w32time source, triggers `TimeSync.ps1` when needed.
- `setup.ps1` – configures w32time as a fallback (with unlimited phase correction for big jumps after
  a dead battery), registers a single **TimeSync** scheduled task running as SYSTEM at:
  - logon,
  - network connect (EventID 10000),
  - every 15 minutes.
  It also removes any old/duplicate time-sync tasks (`TimeWatchdog`, `Sincronizar hora automáticamente`,
  `Sincronizar hora cada hora`).

## Usage

1. Run `setup.ps1` as administrator (right-click → Run with PowerShell, or from an elevated terminal).
2. The clock is corrected immediately and then kept accurate every 15 minutes as long as there is internet connectivity.
3. Logs are written next to the scripts: `TimeSync.log` and `TimeWatchdog.log`.

## Troubleshooting

- If the clock is not corrected, check `scripts\TimeSync.log` for the error.
- `TimeSync.ps1` requires an internet connection; it works under the SYSTEM account (scheduled task) and from an
  elevated PowerShell session.
- Replacing the CMOS battery is still recommended so the clock does not reset when the PC is powered off.
