Start-Process PowerShell -ArgumentList "Set-ExecutionPolicy Restricted -Force" -Verb RunAs
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

$script_directory = $PSScriptRoot + ".\scripts\"

function Is-Numeric ($Value) {
    return $Value -match "^[\d\.]+$"
}

function Rename-Computer-Workgroup {
    Write-Host "How do you want this computer to be renamed?"
    Write-Host "1: Cart Laptop - BT_CXX_YY / CARTXX"
    Write-Host "2: Smartboard Laptop - BT_ROOM_SB / SMARTBOARD"
    Write-Host "3: Teacher Station - BT_ROOM_TS / TEACHSTATION"
    Write-Host "4: Domain Computer - BT_ROOM_XX / unchanged"
    Write-Host ""
    Write-Host "9: Custom Name / Workgroup"

    $input = Read-Host “Please make a selection”
    switch ($input) {
        '1' {
            Write-Host ""
            do {
              $inputString = read-host "Enter cart number, or enter 'q' to skip"
              $cart = $inputString

              $ok = Is-Numeric $inputString
              $skipNaming = $inputString -eq 'q'
              
              if ((-not $ok) -and (-not $skipNaming)) {
                write-host "You must enter a numeric value"
              }
            }
            until ($ok -or $skipNaming)


        }
        default {
            
        }
    }
}

do {
    cls
    Write-Host "=========================="
    Write-Host "Welcome to the Configuration Menu."
    Write-Host "1: Rename and join workgroup"
    Write-Host "2: Remove all other Wi-Fi profiles and add ncpsp"
    Write-Host "3: Sync Time"
    Write-Host "4: Recreate student account"
    Write-Host "5: Delete test folder and account"
    Write-Host "6: Delete other user folder"
    Write-Host "7: Disconnect from work or school account"
    Write-Host ""
    Write-Host "q: Exit the program"
    Write-Host ""

    $input = Read-Host “Please make a selection”
    switch ($input) {
        ‘1’ {
            cls
            Rename-Computer-Workgroup
            pause
        }
        ‘2’ {
            cls
            $location = $script_directory + "wifi.bat"
            Write-Host "Removing all Wi-Fi Profiles and adding ncpsp. This may take a few seconds."
            Write-Host "If this device is not whitelisted it will not be able to connect to the service."
            Start-Process -FilePath $location -Wait
            pause
        }
        ‘3’ {
            Write-Host "You chose option #2"
        }
        ‘4’ {
            Write-Host "You chose option #2"
        }
        ‘5’ {
            Write-Host "You chose option #2"
        }
        ‘6’ {
            Write-Host "You chose option #2"
        }
        ‘q’ {
            return
        }
        default {
            
        }
    }
}
until ($input -eq ‘q’)