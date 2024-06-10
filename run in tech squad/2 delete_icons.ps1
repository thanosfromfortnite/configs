# Created 6/10/2024
# Intended for cart laptops. Deletes the following icons from the Desktop on student:
# Google Chrome.lnk
# Microsoft Edge.lnk
# Microsoft Teams.lnk

if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

function Remove-If-Exists {
    #filePath = path + file + ext = "C:\test\file.txt"
    $filePath = $args[0] + $args[1] + $args[2]
    if (Test-Path $filePath) {
        Write-Output "$filePath removed."
        Remove-Item $filePath
    }
    else {
        Write-Output "$filePath cannot be found."
    }
}

$path = "C:\Users\student\Desktop\"
$path2 = "C:\Users\Public\Desktop\"
$path3 = "C:\Users\teacher\Desktop\"
$ext = ".lnk"

$files = @(
    "Microsoft Edge",
    "Google Chrome",
    "VLC Media Player",
    "Microsoft Teams"
)

foreach ($file in $files) {
    Remove-If-Exists $path $file $ext
    Remove-If-Exists $path2 $file $ext
    Remove-If-Exists $path3 $file $ext
}



Write-Host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")