# Modified 6/10/2024
# This script is intended for smartboard laptops
# Name/Workgroup: BT_XXXX_SB
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

function Is-Numeric ($Value) {
    return $Value -match "^[\d\.]+$"
}

# Get custom name from input.
$inputString = read-host "Enter new laptop name. Leave blank if unchanged."
$name = $inputString

# Get custom workgroup from input.
$inputString = read-host "Enter new workgroup name. Leave blank if unchanged."
$workgroup = $inputString

# Remove test account
$job = Start-Job { Remove-LocalUser -Name 'test' }
Wait-Job $job
Receive-Job $job

# Remove test folder
mkdir empty
robocopy empty "C:\Users\test" /mir
rmdir empty
rmdir "C:\Users\test"

# Renaming
if ($name) {
    (Get-WmiObject -Class Win32_ComputerSystem).Rename($name)
    Write-Host "Renamed computer to: " $name
}
else {
    Write-Host "Computer name unchanged."
}
# Assigning workgroup
if ($workgroup) {
    Add-Computer -WorkgroupName $workgroup
    Write-Host "Renamed workgroup to: " $name
}
else {
    Write-Host "Workgroup name unchanged."
}

# Restart-Computer -Force