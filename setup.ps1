# Set timezone to Caracas, Venezuela
tzutil /s "Venezuela Standard Time"

# Configure Windows Time service
net stop w32time
w32tm /config /syncfromflags:manual /manualpeerlist:"time.windows.com,0x9 time.nist.gov,0x9"
w32tm /config /reliable:NO /update
net start w32time
w32tm /resync

# Create scheduled task to resync at logon (highest privileges)
schtasks /Create /SC ONLOGON /TN "TimeSync" /TR "w32tm /resync" /RL HIGHEST /F
