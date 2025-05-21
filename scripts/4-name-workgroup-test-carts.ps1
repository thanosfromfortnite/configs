# Modified 8/9/2024
# This script is intended for laptop carts
# Name/Workgroup: BT_CXX_XX
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

function Is-Numeric ($Value) {
    return $Value -match "^[\d\.]+$"
}

# Get cart/laptop number from input. CART_CODE
do {
  $inputString = read-host "Enter cart number"
  $cart = $inputString
  $ok = Is-Numeric $inputString
  if (-not $ok) { write-host "You must enter a numeric value" }
}
until ( $ok )

do {
  $inputString = read-host "Enter laptop number"
  $number = $inputString
  $ok = Is-Numeric $inputString
  if (-not $ok) { write-host "You must enter a numeric value" }
}
until ( $ok )


# Remove test account
$job = Start-Job { Remove-LocalUser -Name 'test' }
Wait-Job $job
Receive-Job $job

# Remove test folder
mkdir empty
robocopy empty "C:\Users\test" /mir
rmdir empty
rmdir "C:\Users\test"

# Renaming for carts. CART_CODE
$name = ("BT_C" + $cart + "_" + $number)
$workgroup = "CART$cart"
Write-host "Renamed computer to: " $name

(Get-WmiObject -Class Win32_ComputerSystem).Rename($name)
Add-Computer -WorkgroupName $workgroup
Write-Host "Changed workgroup name to: " $workgroup

# Restart-Computer -Force