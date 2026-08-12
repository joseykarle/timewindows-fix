# TimeWindows Fix

This repository contains scripts and configurations to keep the system clock synchronized via Internet time servers, useful when the CMOS battery is failing.

## Features

- Automatic time synchronization using Windows Time service (w32time) with NTP servers.
- Watchdog script that periodically checks and corrects the system clock.
- Scheduled tasks to ensure synchronization at logon and every 15 minutes.

## Usage

1. Run the provided PowerShell script as administrator to set up synchronization and watchdog.
2. The system will keep the clock accurate as long as there is internet connectivity.
