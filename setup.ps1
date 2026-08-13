#Requires -RunAsAdministrator
# ============================================================
# setup.ps1 - TimeWindows Fix (corregido)
# Sincroniza el reloj del sistema mediante HTTPS (el NTP por
# UDP 123 suele estar bloqueado por ISP/router, y w32time
# no puede usar otro puerto).
# ============================================================
$ErrorActionPreference = "Stop"

$scriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$syncScript = Join-Path $scriptDir "scripts\TimeSync.ps1"

if (-not (Test-Path $syncScript)) { throw "No se encontro: $syncScript" }

Write-Host "== 1/4 Zona horaria ==" -ForegroundColor Cyan
tzutil /s "Venezuela Standard Time"
Write-Host "Zona horaria: $(tzutil /g)" -ForegroundColor Green

Write-Host "`n== 2/4 Configuracion de w32time (respaldo NTP) ==" -ForegroundColor Cyan
Set-Service w32time -StartupType Automatic
Start-Service w32time -ErrorAction SilentlyContinue
w32tm /config /syncfromflags:manual /manualpeerlist:"time.windows.com,0x9 time.nist.gov,0x9 pool.ntp.org,0x9" | Out-Null

# Permitir correcciones grandes (bateria CMOS agotada): sin limite de fase
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config" -Name "MaxPosPhaseCorrection" -Value ([uint32]::MaxValue) -Type DWord
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config" -Name "MaxNegPhaseCorrection" -Value ([uint32]::MaxValue) -Type DWord
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config" -Name "SpecialPollInterval" -Value 900 -Type DWord

w32tm /config /reliable:NO /update | Out-Null
Restart-Service w32time -Force
w32tm /resync /nowait | Out-Null
Write-Host "w32time configurado y reiniciado." -ForegroundColor Green

Write-Host "== 3/4 Tarea programada ==" -ForegroundColor Cyan

# Eliminar tareas antiguas/duplicadas de sincronizacion si existen
foreach ($old in @("TimeWatchdog", "Sincronizar hora automáticamente", "Sincronizar hora cada hora")) {
    Unregister-ScheduledTask -TaskName $old -Confirm:$false -ErrorAction SilentlyContinue
}
$TaskXml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Sincroniza la hora del sistema por HTTPS (reloj CMOS con bateria agotada).</Description>
  </RegistrationInfo>
  <Triggers>
    <LogonTrigger>
      <Enabled>true</Enabled>
    </LogonTrigger>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="Microsoft-Windows-NetworkProfile/Operational"&gt;&lt;Select Path="Microsoft-Windows-NetworkProfile/Operational"&gt;*[System[Provider[@Name='Microsoft-Windows-NetworkProfile'] and (EventID=10000)]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
      <Delay>PT1M</Delay>
    </EventTrigger>
    <TimeTrigger>
      <StartBoundary>2026-01-01T00:00:00</StartBoundary>
      <Repetition>
        <Interval>PT15M</Interval>
        <StopAtDurationEnd>false</StopAtDurationEnd>
      </Repetition>
      <Enabled>true</Enabled>
    </TimeTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>PT15M</ExecutionTimeLimit>
    <Priority>5</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>-NoProfile -ExecutionPolicy Bypass -File "$syncScript"</Arguments>
    </Exec>
  </Actions>
</Task>
"@

$TempXmlPath = Join-Path $env:TEMP "TimeSyncTask.xml"
$TaskXml | Out-File -FilePath $TempXmlPath -Encoding unicode
Register-ScheduledTask -Xml (Get-Content $TempXmlPath -Raw) -TaskName "TimeSync" -Force | Out-Null
Remove-Item $TempXmlPath -Force -ErrorAction SilentlyContinue
Write-Host "Tarea 'TimeSync' creada (inicio de sesion, red, y cada 15 min)." -ForegroundColor Green

Write-Host "`n== 4/4 Sincronizacion inmediata ==" -ForegroundColor Cyan
& powershell.exe -NoProfile -ExecutionPolicy Bypass -File $syncScript

Write-Host "`nListo. El reloj se corregira al iniciar sesion, al conectar red y cada 15 min." -ForegroundColor Green
