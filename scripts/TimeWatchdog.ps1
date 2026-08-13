# ============================================================
# TimeWatchdog.ps1 - vigila la desviacion del reloj y corrige
# (version corregida: parseo independiente del idioma, sin
# errores de sintaxis; delega en TimeSync.ps1 para sincronizar)
# ============================================================
$ErrorActionPreference = "SilentlyContinue"

$scriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$logFile     = Join-Path $scriptDir "TimeWatchdog.log"
$maxAgeMin   = 30
$syncScript  = Join-Path $scriptDir "TimeSync.ps1"

function Write-Log {
    param([string]$Message)
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $Message"
}

# Origen de tiempo actual (el valor es independiente del idioma del SO)
$source = (w32tm /query /source 2>$null | Out-String).Trim()
if (-not $source) { $source = "desconocido" }

# Ultima sincronizacion: buscar una fecha en el estado de w32time
$lastSync = $null
$status = w32tm /query /status 2>$null
if ($status) {
    $dateMatch = $status | ForEach-Object { [regex]::Match($_, "\d{1,2}/\d{1,2}/\d{4} \d{1,2}:\d{2}:\d{2}") } |
                 Where-Object { $_.Success } | Select-Object -First 1
    if ($dateMatch) {
        try { $lastSync = [datetime]::Parse($dateMatch.Value) } catch { $lastSync = $null }
    }
}

# Diagnostico
$needSync = $false
$reason   = ""
if ($source -match "CMOS") {
    $needSync = $true
    $reason   = "el origen del tiempo sigue siendo el reloj CMOS local"
} elseif (-not $lastSync) {
    $needSync = $true
    $reason   = "w32time nunca ha sincronizado"
} else {
    $ageMinutes = ((Get-Date) - $lastSync).TotalMinutes
    if ($ageMinutes -gt $maxAgeMin) {
        $needSync = $true
        $reason   = "ultima sincronizacion hace $([int]$ageMinutes) min (max: $maxAgeMin)"
    } else {
        Write-Log "OK: origen=$source, antiguedad=$([int]$ageMinutes) min."
    }
}

if ($needSync) {
    Write-Log "Desviado: $reason -> ejecutando TimeSync.ps1..."
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $syncScript
}