# Modified 6/10/2024
# This script is intended for smartboard laptops
# Name/Workgroup: BT_XXXX_SB
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

function Is-Numeric ($Value) {
    return $Value -match "^[\d\.]+$"
}

# Get SB room from input. SB_CODE
$inputString = read-host "Enter room number. Example: 7N07"
$room = $inputString

# Remove test account
$job = Start-Job { Remove-LocalUser -Name 'test' }
Wait-Job $job
Receive-Job $job

# Remove test folder
mkdir empty
robocopy empty "C:\Users\test" /mir
rmdir empty
rmdir "C:\Users\test"

# Renaming for smartboards. SB_CODE
$name = ("BT_" + $room + "_SB")
$workgroup = "SMARTBOARD"

(Get-WmiObject -Class Win32_ComputerSystem).Rename($name)
Add-Computer -WorkgroupName $workgroup

Write-Host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Restart-Computer -Force