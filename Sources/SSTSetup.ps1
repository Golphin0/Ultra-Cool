$Scriptbase64 = "aWYgKCRhcmdzLkNvdW50IC1ndCAwKSB7DQogICAgJFRhcmdldCA9ICRhcmdzWzBdDQp9DQplbHNlIHsNCiAgICAkVGFyZ2V0ID0gUmVhZC1Ib3N0ICJFbnRlciB0YXJnZXQgZm9sZGVyIHBhdGgiDQp9DQoNCiRUYXJnZXQgPSAkVGFyZ2V0LlRyaW0oJyInKQ0KDQppZiAoLW5vdCAoVGVzdC1QYXRoICRUYXJnZXQpKSB7DQogICAgV3JpdGUtSG9zdCAiSXRlbSBub3QgZm91bmQ6ICRUYXJnZXQiIC1Gb3JlZ3JvdW5kQ29sb3IgUmVkDQogICAgcGF1c2UNCiAgICBleGl0DQp9DQoNCmlmICgtbm90IChUZXN0LVBhdGggJFRhcmdldCAtUGF0aFR5cGUgQ29udGFpbmVyKSkgew0KICAgIFdyaXRlLUhvc3QgIkl0ZW0gZXhpc3RzLCBidXQgaXQgaXMgbm90IGEgZm9sZGVyOiAkVGFyZ2V0IiAtRm9yZWdyb3VuZENvbG9yIFJlZA0KICAgIHBhdXNlDQogICAgZXhpdA0KfQ0KDQokSnVuY3Rpb24gPSAiJFRhcmdldC0yIg0KDQpOZXctSXRlbSAtSXRlbVR5cGUgSnVuY3Rpb24gLVBhdGggJEp1bmN0aW9uIC1UYXJnZXQgJFRhcmdldA0KcGF1c2U="
$SendTo = [Environment]::GetFolderPath("SendTo")
$ShortcutName = "Create Junction.lnk"
$ShortcutPath = Join-Path $SendTo $ShortcutName

while ($true) {

    Clear-Host
    Write-Host "=== Symlink Send To Manager ===`n"

    Write-Host "[1] Add Create Junction to Send To"
    Write-Host "[2] Remove Create Junction from Send To"
    Write-Host "[3] Exit"
    Write-Host

    $Choice = Read-Host "Choose"

    switch ($Choice) {

        "1" {
            function Set-Receiver {
                $Good = $true
                $ReceiverPath = Read-Host "Enter the path where you want to place the script, With or without quotes (Enter nothing for default location `"C:\SymlinkReceiver\Symlink.ps1`")"
                if ($ReceiverPath -eq "") {
                    $ReceiverPath = "C:\SymlinkReceiver\Symlink.ps1"
                }
                else {
                    $ReceiverPath = $ReceiverPath.Trim('"')
                    if (-not (Test-Path $ReceiverPath)) {
                        Write-Host -NoNewline "Path does not exist. Would you like to create it?: " -ForegroundColor Yellow
                        $CreatePath = (Read-Host) -eq "Y"
                        if ($CreatePath) {
                            $ReceiverPath = Join-Path $ReceiverPath "Symlink.ps1"
                            Write-Host "Path will be created." -ForegroundColor Green
                        } else {
                            Write-Host "Path not created." -ForegroundColor Red
                            $Good = $false
                        }
                    } else {
                        if (-not (Test-Path $ReceiverPath -PathType Container)) {
                            Write-Host "The path exists but is not a directory. Please provide a valid directory path." -ForegroundColor Red
                            $Good = $false
                        } else {
                            Write-Host "Path exists and is a directory." -ForegroundColor Green
                            $ReceiverPath = Join-Path $ReceiverPath "Symlink.ps1"
                        }
                    }
                }
                if ($Good) {
                    return $ReceiverPath
                } else {
                    return $null
                }
            }
            
            if (Test-Path $ShortcutPath) {
                Write-Host -NoNewline "Already exists. Do you want to override it? (Y/N): " -ForegroundColor Yellow
                $Override = (Read-Host) -eq "N"

                if ($Override) {
                    Write-Host "Shortcut not created." -ForegroundColor Red
                    pause
                    break
                }
            }

            $SetupReciever = (Read-Host "Do you want to have the sendto recieve from a special location? (Y/N)`r`nIf you choose Y, the script will be placed at a special location, less likely to be deleted, and the shortcut will point to that location.`r`nIf you choose N, the script will be placed in the same folder as this script and the shortcut will point to that location.`r`nBy Default, entering nothing will choose N.`r`nEnter Y or N") -eq "N"
            $ScriptPath = if (-not $SetupReciever) { Set-Receiver } else { (Join-Path $PSScriptRoot "Symlink.ps1") }
            if (-not $ScriptPath) {
                Write-Host "No valid script path provided. Exiting." -ForegroundColor Red
                pause
                break
            }

            $ScriptContent = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($Scriptbase64))
            New-Item -ItemType Directory -Path (Split-Path $ScriptPath) -Force | Out-Null
            Set-Content -Path $ScriptPath -Value $ScriptContent -Force -Encoding ASCII

            $WshShell = New-Object -ComObject WScript.Shell
            $Shortcut = $WshShell.CreateShortcut($ShortcutPath)

            $Shortcut.TargetPath = "powershell.exe"
            $Shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$ScriptPath`""
            $Shortcut.WorkingDirectory = $PSScriptRoot
            $Shortcut.IconLocation = "shell32.dll,46"

            $Shortcut.Save()

            Write-Host "Added Send To shortcut." -ForegroundColor Green

            pause
        }

        "2" {
            if (Test-Path $ShortcutPath) {
                Remove-Item $ShortcutPath
                Remove-Item "C:\SymlinkReceiver\Symlink.ps1" -ErrorAction SilentlyContinue
                Remove-Item (Join-Path $PSScriptRoot "Symlink.ps1") -ErrorAction SilentlyContinue
                Write-Host "Removed Send To shortcut.`r`nNote: The script file will not be deleted if you specified a custom location besides the default." -ForegroundColor Green

            }
            else {
                Write-Host "Shortcut not found." -ForegroundColor Yellow
            }

            pause
        }

        "3" {
            exit
        }

        default {
            Write-Host "Invalid choice." -ForegroundColor Red
            pause
        }
    }
}