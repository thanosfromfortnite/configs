if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }

$script_directory = $PSScriptRoot + "\scripts\"

function Is-Numeric ($Value) {
    return $Value -match "^[\d\.]+$"
}

function Is-TimeFormat() {
    param (
        [string]$givenTime,
        [string]$format = "HH:mm"
    )
    try {
        [datetime]::ParseExact($givenTime, $format, $null) | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Name and Workgroup
function Rename-Computer-Workgroup {
    do {
        Write-Host "How do you want this computer to be renamed?"
        Write-Host "1: Cart Laptop - BT_CXX_YY / CARTXX"
        Write-Host "2: Smartboard Laptop - BT_ROOM_SB / SMARTBOARD"
        Write-Host "3: Teacher Station - BT_ROOM_TS / TEACHSTATION"
        Write-Host "4: Domain Computer - BT_ROOM_XX / unchanged"
        Write-Host ""
        Write-Host "9: Custom Name / Workgroup"
        Write-Host ""
        Write-Host "q: Quit"

        $input = Read-Host “Please make a selection”
        switch ($input) {
            # 1: Cart Laptop - BT_CXX_YY / CARTXX
            '1' {
                Write-Host ""
                do {
                    $inputString = read-host "Enter cart number"
                    $cart = $inputString

                    $ok = Is-Numeric $inputString
            
                    if (-not $ok) {
                      write-host "You must enter a numeric value"
                    }
                }
                until ($ok)

                do {
                    $inputString = Read-Host "Enter computer number"
                    $number = $inputString
                    $ok = Is-Numeric $inputString

                    if (-not $ok) {
                        Write-Host "You must enter a numeric value"
                    }
                }
                until ($ok)

                $name = ("BT_C" + $cart + "_" + $number)
                $workgroup = "CART$cart"
                Write-host "Renamed computer to: " $name

                (Get-WmiObject -Class Win32_ComputerSystem).Rename($name)
                Add-Computer -WorkgroupName $workgroup
                Write-Host "Changed workgroup name to: " $workgroup
                Write-Host "Restart the computer to finalize this change."
                $quit = $true
                pause
            }

            # 2: Smartboard Laptop - BT_ROOM_SB / SMARTBOARD
            '2' {
                Write-Host ""
                $inputString = Read-Host "Enter room"
                $room = $inputString.ToUpper()

                $name = ("BT_" + $room + "_SB")
                $workgroup = "SMARTBOARD"
                Write-host "Renamed computer to: " $name

                (Get-WmiObject -Class Win32_ComputerSystem).Rename($name)
                Add-Computer -WorkgroupName $workgroup
                Write-Host "Changed workgroup name to: " $workgroup
                Write-Host "Restart the computer to finalize this change."
                $quit = $true
                pause
            }

            # 3: Teacher Station - BT_ROOM_TS / TEACHSTATION
            '3' {
                Write-Host ""
                $inputString = Read-Host "Enter room"
                $room = $inputString.ToUpper()

                $name = ("BT_" + $room + "_TS")
                $workgroup = "TEACHSTATION"
                Write-host "Renamed computer to: " $name

                (Get-WmiObject -Class Win32_ComputerSystem).Rename($name)
                Add-Computer -WorkgroupName $workgroup
                Write-Host "Changed workgroup name to: " $workgroup
                Write-Host "Restart the computer to finalize this change."
                $quit = $true
                pause
            }

            # 4: Domain Computer - BT_ROOM_XX / unchanged
            '4' {
                Write-Host ""
                $inputString = read-host "Enter room number"
                $room = $inputString.ToUpper()

                do {
                    $inputString = Read-Host "Enter computer number"
                    $number = $inputString
                    $ok = Is-Numeric $inputString

                    if (-not $ok) {
                        Write-Host "You must enter a numeric value"
                    }
                }
                until ($ok)

                $name = ("BT_" + $room + "_" + $number)
                Write-host "Renamed computer to: " $name

                (Get-WmiObject -Class Win32_ComputerSystem).Rename($name)

                Write-Host "Workgroup unchanged."
                Write-Host "Restart the computer to finalize this change."
                $quit = $true
                pause
            }

            # 9: Custom Name / Workgroup
            '9' {
                Write-Host ""
                $name = Read-Host "Enter new computer name. Leave blank if unchanged"
                $workgroup = Read-Host "Enter new workgroup. Leave blank if unchanged"

                if ($name) {
                    (Get-WmiObject -Class Win32_ComputerSystem).Rename($name)
                    Write-Host "Changed name to " + $name
                }
                else {
                    Write-Host "Name unchanged."
                }

                if ($workgroup) {
                    Add-Computer -WorkgroupName $workgroup
                    Write-Host "Changed workgroup to" + $workgroup
                }
                else {
                    Write-Host "Workgroup unchanged."
                }
                $quit = $true
                pause
            }

            # Quit
            'q' {
                $quit = $true
            }
            default {
            
            }
        }
    }
    until ($quit)
}

# Wifi
function Add-ncpsp {
    $location = $script_directory + "wifi.bat"
    Write-Host "Removing all Wi-Fi Profiles and adding ncpsp. Please ensure that you're running it when prompted."
    Write-Host "If this device is not whitelisted it will not be able to connect to the service."
    Start-Process -FilePath $location -Wait
    pause
}

# Time
function Change-Time {
    do {
        cls
        Write-Host "1: Resync Time"
        Write-Host "2: Set Time Manually"
        Write-Host "3: Set Date Manually"
        Write-Host "q: Exit"

        $input = Read-Host "Please make a selection"
        switch ($input) {
            '1' {
                W32tm /resync /force
                $quit = $true
                pause
            }
            '2' {
                $currentTime = Get-Date -Format "HH:mm"
                Write-Host "The computer time is " $currentTime
                do {
                    $newTime = Read-Host "Please type a new time in HH:mm, 24-hour format"
                    $ok = Is-TimeFormat -givenTime $newTime -format "HH:mm"
                }
                until ($ok)
                Set-Date -Date $newTime
                pause
            }
            '3' {
                $currentDate = Get-Date -Format "MM/dd/yyyy"
                Write-Host "The computer date is " $currentDate
                do {
                    $newDate = Read-Host "Please type a new date in MM/DD/YYYY format, including leading zeros"
                    $ok = Is-TimeFormat -givenTime $newDate -format "MM/dd/yyyy"
                }
                until ($ok)
                $currentTime = Get-Date -Format "HH:mm:ss"
                Set-Date -Date ($newDate + " " + $currentTime)
                pause
            }
            'q' {
                $quit = $true
            }
            default {

            }
        }
    }
    until ($quit)
}

# Remake Student
function Remake-Student {
    # Remove student account
    $job = Start-Job { Remove-LocalUser -Name 'student' }
    Wait-Job $job
    Receive-Job $job

    # Remove student folder
    &cmd.exe /c rmdir /s /q "C:\Users\student"

    # Make new student account
    New-LocalUser -Name "student" -AccountNeverExpires -NoPassword -UserMayNotChangePassword
    Set-LocalUser -Name "student" -PasswordNeverExpires:$true
    Add-LocalGroupMember -Group "Power Users" -Member "student"
}

# Delete test
function Delete-Test {
    # Remove student account
    $job = Start-Job { Remove-LocalUser -Name 'test' }
    Wait-Job $job
    Receive-Job $job

    # Remove student folder
    &cmd.exe /c rmdir /s /q "C:\Users\test"
}

# Delete Other User
function Delete-Other-User {
    $user = Read-Host "Enter username to delete"

    do {
        $confirmation = Read-Host "This will delete the entire user folder and account. Continue? (y/n)"
        if ($confirmation -eq 'y') {
            Write-Host "Deleting the user folder might take a while..."

            $userFolder = "C:\Users\" + $user
            &cmd.exe /c rmdir /s /q $userFolder

            $job = Start-Job { Remove-LocalUser -Name $user }
            Wait-Job $job
            Receive-Job $job
        }
    }
    until ($confirmation -eq 'y' -or $confirmation -eq 'n')

}

# Disconnect work or school account
function Disconnect-AAD {
    Get-ItemProperty -Path "C:\Users*\AppData\Local\Packages" | ForEach-Object {
        Remove-Item -Path "$_\Microsoft.AAD.BrokerPlugin*" -Recurse -Force | Out-Null
    }
}

do {
    cls
    Write-Host "Welcome to the Configuration Menu."
    Write-Host "1: Rename and join workgroup"
    Write-Host "2: Remove all other Wi-Fi profiles and add ncpsp"
    Write-Host "3: Change or Sync Time"
    Write-Host "4: Recreate student account"
    Write-Host "5: Delete test folder and account"
    Write-Host "6: Delete other user"
    Write-Host "7: Disconnect from work or school account"
    Write-Host ""
    Write-Host "q: Exit the program"
    Write-Host ""

    $input = Read-Host “Please make a selection”
    switch ($input) {
        ‘1’ {
            cls
            Rename-Computer-Workgroup
        }
        ‘2’ {
            cls
            Add-ncpsp
        }
        ‘3’ {
            cls
            Change-Time
        }
        ‘4’ {
            cls
            do {
                Write-Host "Please ensure that the student account is logged out."
                $confirmation = Read-Host "This will delete the entire student user folder and account. Continue? (y/n)"
                if ($confirmation -eq 'y') {
                    Write-Host "Deleting the user folder might take a while..."
                    Remake-Student
                }
            }
            until ($confirmation -eq 'y' -or $confirmation -eq 'n')
            pause
        }
        ‘5’ {
            cls
            Write-Host "Please ensure that the test account is logged out."
            pause
            Delete-Test
            pause
        }
        ‘6’ {
            $users = Get-ChildItem -Path "C:\Users" -Name
            Write-Host "List of user folders:" $users
            Delete-Other-User
            pause
        }
        '7' {
            Write-Host "Disconnecting any connected accounts..."
            Disconnect-AAD
            Write-Host "Remember to restart the computer for changes to take effect."
            pause
        }
        ‘q’ {
            return
        }
        default {
            
        }
    }
}
until ($input -eq ‘q’)