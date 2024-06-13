# Modified 6/12/2024
# This script will run all the required scripts intended for laptop carts
# Name/Workgroup: BT_CXX_XX
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

function Is-Numeric ($Value) {
    return $Value -match "^[\d\.]+$"
}

start $PSScriptRoot/1-wifi.bat -Wait -NoNewWindow
& $PSScriptRoot/2-delete-icons.ps1
& $PSScriptRoot/3-windows-11-driver.ps1
& $PSScriptRoot/4-name-workgroup-test-custom.ps1
start $PSScriptRoot/time/time_command.bat -Wait -NoNewWindow

Write-Host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")