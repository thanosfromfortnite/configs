# Created 6/13/2024
# Intended for cart laptops. Deletes the following icons from the Desktop on student:

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

$Path = $env:TEMP;
$Installer = "chrome_installer.exe";
Invoke-WebRequest "http://dl.google.com/chrome/install/latest/chrome_installer.exe" -OutFile $Path\$Installer;
Start-Process -FilePath $Path\$Installer -Args "/silent /install" -Verb RunAs -Wait;
Remove-Item $Path\$Installer