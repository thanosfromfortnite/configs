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
    $username = Read-Host "Enter username to delete. Leave blank to cancel"
    if ($username) {
        do {
            $confirmation = Read-Host "This will delete the entire user folder and account. Continue? (y/n)"
            if ($confirmation -eq 'y') {
                Write-Host "Deleting the user folder might take a while..."

                $userFolder = "C:\Users\" + $username
                &cmd.exe /c rmdir /s /q $userFolder

                Remove-LocalUser -Name $username
            }
        }
        until ($confirmation -eq 'y' -or $confirmation -eq 'n')
    }

}

# Windows Update options
function Windows-Update-Stuff {
    do {
        cls
        Write-Host "Windows Update options"
        Write-Host "1: Run Updates"
        Write-Host "2: Pause Updates Indefinitely"
        Write-Host ""
        Write-Host "q: Exit"
        Write-Host ""

        $input = Read-Host "Please make a selection"

        switch ($input) {
            '1' {

            }
            '2' {

            }
            'q' {
                $quit = $true
            }
        }
    }
    until ($quit)
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
    Write-Host "7: Windows Update options"
    Write-Host "9: Restart computer"
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
                    pause
                }
            }
            until ($confirmation -eq 'y' -or $confirmation -eq 'n')
        }
        ‘5’ {
            cls
            Write-Host "Please ensure that the test account is logged out."
            pause
            Delete-Test
            Write-Host "Done. If a bunch of errors appeared then test may have not been logged out. Please run this again after you restart if this is the case."
            pause
        }
        ‘6’ {
            cls
            $users = Get-ChildItem -Path "C:\Users" -Name
            Write-Host "List of user folders:" $users
            Delete-Other-User
            Write-Host "Done. If a bunch of errors appeared then the account may not have been logged out. Please run this again after you restart if this is the case,"
            pause
        }
        '7' {
            cls
            # Windows-Update-Stuff
            pause
        }
        '9' {
            $restart = Read-Host "This will restart the computer. Type 'q' to cancel"
            if ($restart -eq 'q') {
                Write-Host "Restart aborted."
                pause
            }
            else {
                Restart-Computer -Force
            }
        }
        ‘q’ {
            return
        }
        default {
            
        }
    }
}
until ($input -eq ‘q’)