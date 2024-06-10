Disable-ScheduledTask "UCPD velocity" "\Microsoft\Windows\AppxDeploymentClient\"
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\UCPD" -Name "Start" -Value 4 -Type DWord -Force