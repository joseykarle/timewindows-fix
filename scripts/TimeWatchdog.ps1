# -------------------------------------------------
# TimeWatchdog.ps1  –  vigila y corrige la hora del sistema
# -------------------------------------------------
$maxAgeMinutes = 30
$logSource    = "TimeWatchdog"

if (-not [System.Diagnostics.EventLog]::SourceExists($logSource)) {
    New-EventLog -LogName Application -Source $logSource
}

function Write-Log {
    param([string]$Message, [string]$Level = "Information")
    $entryType = switch ($Level) {
        "Error"   { [System.Diagnostics.EventLogEntryType]::Error }
        "Warning" { [System.Diagnostics.EventLogEntryType]::Warning }
        default   { [System.Diagnostics.EventLogEntryType]::Information }
    }
    Write-EventLog -LogName Application -Source $logSource -EntryType $entryType -EventId 1000 -Message $Message
}

$status = w32tm /query /status 2>$null
if (-not $status) {
    Write-Log "No se pudo obtener el estado de w32time." "Error"
    exit 1
}
$lastSyncLine   = $status | Where-Object { $_ -like "*Última sincronización*" }
$sourceLine     = $status | Where-Object { $_ -like "*Origen:*" }
$lastSync = $null
if ($lastSyncLine -match ': \d{1,2}/\d{1,2}/\d{4} \d{1,2}:\d{2}:\d{2}') {
    $dtStr = $matches[0].Trim()
    try { $lastSync = Get-Date $dtStr } catch {}
}
$isLocalCmos = $sourceLine -match "Local CMOS Clock"
$ageMinutes = if ($lastSync) { (Get-Date) - $lastSync ).TotalMinutes } else { [double]::MaxValue }

$needResync = $false
$reason = ""
if ($isLocalCmos) { $needResync = $true; $reason = "El origen del tiempo sigue siendo el reloj CMOS local." }
elseif ($ageMinutes -gt $maxAgeMinutes) { $needResync = $true; $reason = "Última sincronización hace $([int]$ageMinutes) min (máx permitido $maxAgeMinutes min)." }

if ($needResync) {
    Write-Log "Watchdog: $reason Forzando resincronización..." "Information"
    $out = w32tm /resync 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Log "Resincronización completada exitosamente." "Information"
    } else {
        Write-Log "Error al intentar resincronizar: $out" "Error"
    }
} else {
    Write-Log "Watchdog: hora OK (origen: $($sourceLine.Split(':')[1].Trim()), antigüedad: $([int]$ageMinutes) min)." "Information"
}
