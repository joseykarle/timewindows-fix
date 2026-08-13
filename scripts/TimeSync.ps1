# ============================================================
# TimeSync.ps1 - Sincroniza el reloj del sistema por HTTPS
# Motivo: el NTP por UDP 123 (w32time) es bloqueado por el
# router/ISP, y w32time no puede usar otro puerto fuente.
# Esta script obtiene la hora UTC de varios servidores web
# (cabecera HTTP "Date") y ajusta el reloj local.
# ============================================================
$ErrorActionPreference = "SilentlyContinue"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$logFile   = Join-Path $scriptDir "TimeSync.log"
$threshold = 5   # segundos de desviacion maxima tolerada

function Write-Log {
    param([string]$Message)
    Add-Content -Path $logFile -Value "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $Message"
}

# 1) Intentar primero NTP (funciona si la red lo permite)
w32tm /resync /nowait | Out-Null

# 2) Obtener hora UTC via cabecera HTTP "Date" de servidores fiables
$urls = @(
    "https://www.microsoft.com",
    "https://www.cloudflare.com",
    "https://www.google.com",
    "https://www.bing.com"
)
$samples = @()
foreach ($url in $urls) {
    try {
        $resp = Invoke-WebRequest -Uri $url -TimeoutSec 8 -UseBasicParsing
        $hdr  = $resp.Headers["Date"]
        if ($hdr) {
            $t = [datetime]::ParseExact($hdr, "ddd, dd MMM yyyy HH:mm:ss 'GMT'",
                 [System.Globalization.CultureInfo]::InvariantCulture,
                 [System.Globalization.DateTimeStyles]::AssumeUniversal)
            $samples += $t.ToUniversalTime()
        }
    } catch { }
}

if ($samples.Count -lt 2) {
    Write-Log "ERROR: no hay suficientes fuentes HTTPS disponibles ($($samples.Count))."
    exit 1
}

# 3) Mediana de las muestras
$samples = $samples | Sort-Object
$median  = $samples[[int]($samples.Count / 2)]
$offset  = ($median - [datetime]::UtcNow).TotalSeconds

if ([math]::Abs($offset) -le $threshold) {
    Write-Log "Hora OK: desviacion $([math]::Round($offset, 1)) s (fuentes: $($samples.Count))."
    exit 0
}

# 4) Ajustar el reloj local
$localTarget = [System.TimeZoneInfo]::ConvertTimeFromUtc($median, [System.TimeZoneInfo]::Local)
try {
    Set-Date -Date $localTarget | Out-Null
    Write-Log "Reloj corregido: $([math]::Round($offset, 1)) s de desviacion -> hora local ahora: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')."
    exit 0
} catch {
    Write-Log "ERROR al ajustar el reloj: $($_.Exception.Message)"
    exit 1
}
