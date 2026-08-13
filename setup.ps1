# 1. Establecer zona horaria a Caracas, Venezuela
tzutil /s "Venezuela Standard Time"

# 2. Configurar el servicio de hora de Windows (w32time)
Start-Service w32time -ErrorAction SilentlyContinue
w32tm /config /syncfromflags:manual /manualpeerlist:"time.windows.com,0x9 time.nist.gov,0x9"
w32tm /config /reliable:NO /update
w32tm /resync

# 3. Estructura XML de la Tarea Programada
$TaskXml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Description>Sincroniza la hora al iniciar sesión y al conectarse a una red.</Description>
  </RegistrationInfo>
  <Triggers>
    <!-- Desencadenador 1: Al iniciar sesión -->
    <LogonTrigger>
      <Enabled>true</Enabled>
    </LogonTrigger>
    <!-- Desencadenador 2: Evento de red ID 10000 -->
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>&lt;QueryList&gt;&lt;Query Id="0" Path="Microsoft-Windows-NetworkProfile/Operational"&gt;&lt;Select Path="Microsoft-Windows-NetworkProfile/Operational"&gt;*[System[Provider[@Name='Microsoft-Windows-NetworkProfile'] and (EventID=10000)]]&lt;/Select&gt;&lt;/Query&gt;&lt;/QueryList&gt;</Subscription>
      <Delay>PT1M</Delay>
      <Repetition>
        <Interval>PT5M</Interval>
        <Duration>P1D</Duration>
        <StopAtDurationEnd>false</StopAtDurationEnd>
      </Repetition>
    </EventTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId> <!-- NT AUTHORITY\SYSTEM -->
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
    <ExecutionTimeLimit>PT72H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>w32tm.exe</Command>
      <Arguments>/resync</Arguments>
    </Exec>
  </Actions>
</Task>
"@

# 4. Guardar archivo XML temporal y registrar la tarea
$TempXmlPath = "$env:TEMP\TimeSyncTask.xml"
$TaskXml | Out-File -FilePath $TempXmlPath -Encoding unicode

Register-ScheduledTask -Xml (Get-Content $TempXmlPath -Raw) -TaskName "TimeSync" -Force | Out-Null
Remove-Item $TempXmlPath -Force

Write-Host "¡Tarea programada 'TimeSync' creada exitosamente con ambos desencadenadores!" -ForegroundColor Green
