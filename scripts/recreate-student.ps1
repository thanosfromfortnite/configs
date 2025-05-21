# Modified 5/21/2025
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

# Remove student account
$job = Start-Job { Remove-LocalUser -Name 'student' }
Wait-Job $job
Receive-Job $job

# Remove student folder
mkdir empty
robocopy empty "C:\Users\student" /mir
rmdir empty
rmdir "C:\Users\student"

# Make new student account
New-LocalUser -Name "student" -AccountNeverExpires -NoPassword -UserMayNotChangePassword
Set-LocalUser -Name "student" -PasswordNeverExpires:$true
Add-LocalGroupMember -Group "Power Users" -Member "student"

# Restart-Computer -Force