$Scriptsbase64 = "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"
$SendTo = [Environment]::GetFolderPath("SendTo")
$ShortcutName = "Create Junction.lnk"
$ShortcutPath = Join-Path $SendTo $ShortcutName

while ($true) {

    Clear-Host
    Write-Host "=== Send To Tools Manager ===`n"
    $Admin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ( -not $Admin) {
        Write-Host "WARNING: This script may require administrator privileges.`n" -ForegroundColor Yellow
    }

    Write-Host "[1] Add Create Junction to Send To"
    Write-Host "[2] Remove Create Junction from Send To"
    if (-not $Admin) { Write-Host "[X] Run as Administrator" }
    Write-Host "[Z] Exit"
    Write-Host

    $Choice = Read-Host "Choose"

    switch ($Choice) {

        "1" {
            function Set-Receiver {
                $Good = $true
                $ReceiverPath = Read-Host "Enter the path where you want to place the script, With or without quotes (Enter nothing for default location `"C:\SymlinkReceiver\Symlink.ps1`")"
                if ($ReceiverPath -eq "") {
                    $ReceiverPath = "C:\SymlinkReceiver"
                }
                else {
                    $ReceiverPath = $ReceiverPath.Trim('"')
                    if (-not (Test-Path $ReceiverPath)) {
                        Write-Host -NoNewline "Path does not exist. Would you like to create it?: " -ForegroundColor Yellow
                        $CreatePath = (Read-Host).ToLower() -eq "y"
                        if ($CreatePath) {
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
                $Override = (Read-Host).ToLower() -eq "n"

                if ($Override) {
                    Write-Host "Shortcut not created." -ForegroundColor Red
                    pause
                    break
                }
            }

            $SetupReciever = (Read-Host "Do you want to have the sendto recieve from a special location? (Y/N)`r`nIf you choose Y, the script will be placed at a special location, less likely to be deleted, and the shortcut will point to that location.`r`nIf you choose N, the script will be placed in the same folder as this script and the shortcut will point to that location.`r`nBy Default, entering nothing will choose Y.`r`nEnter Y or N").ToLower() -eq "n"
            $ScriptPath = if (-not $SetupReciever) { Set-Receiver } else { (Join-Path $PSScriptRoot "Symlink.ps1") }
            if (-not $ScriptPath) {
                Write-Host "No valid script path provided. Exiting." -ForegroundColor Red
                pause
                break
            }

            $AddIcons = (Read-Host "Do you want to add icons to the shortcuts? (Y/N)`r`nBy Default, entering nothing will choose Y.`r`nEnter Y or N").ToUpper() -ne "N"

            function New-Tool {
                param(
                    [string]$Name,
                    [string]$DisplayName,
                    [string]$Command,
                    [String]$IconFile,
                    [Int]$IconIndex

                )

                $Path = "$cmdStore\$Name"

                New-Item $Path -Force | Out-Null
                Set-ItemProperty $Path -Name "(default)" -Value $DisplayName

                New-Item "$Path\command" -Force | Out-Null
                Set-ItemProperty "$Path\command" -Name "(default)" -Value $Command

                if ($AddIcons) {
                    New-ItemProperty $Path -Name "Icon" -Value "`"$IconFile`",$IconIndex" -PropertyType String -Force | Out-Null
                }
            }

            # Create Scripts from Base64

            $Tools = @(
                    @{
                        Name = "Symlink"
                        DisplayName = "New Symlink"
                        Command = "pwsh.exe -File `"$ScriptPath\Symlink.ps1`" `"%1`""
                        IconFile = "[[RESOURCES]]\imageplus1.icl"
                        IconIndex = 34
                    }
                    @{
                        Name = "Base64"
                        DisplayName = "Copy as Base64"
                        Command = "pwsh.exe -File `"$ScriptPath\Base64.ps1`" `"%1`""
                        IconFile = "[[RESOURCES]]\imageplus2.icl"
                        IconIndex = 33
                    }
            )

            $ScriptZip = Join-Path $PSScriptRoot "Scripts.zip"
            if ($AddIcons -eq $true) {
                if (Test-Path "$(Split-Path $PSScriptRoot)\Resources") {
                    $resourcesPath = "$(Split-Path $PSScriptRoot)\Resources"
                } elseif (Test-Path "C:\UltraCoolResources") {
                    $resourcesPath = "C:\UltraCoolResources"
                } else {
                    Write-Host "$AddIcons"
                    Write-Host "Resources directory not found. Continuing without icons." -ForegroundColor Yellow
                    pause
                }
            }

            foreach ($tool in $Tools) {
                # $new = $string -replace "old", "new"
                $tool.IconFile = $tool.IconFile -replace "\[\[RESOURCES\]\]", $resourcesPath
            }
            
            [IO.File]::WriteAllBytes($ScriptZip, [Convert]::FromBase64String($ScriptsBase64))
            Expand-Archive -LiteralPath $ScriptZip -DestinationPath $ScriptPath -Force
            Remove-Item $ScriptZip -Force

            $cmdStore = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell"
            $submenu1 = "Registry::HKEY_CLASSES_ROOT\Directory\shell\Tools"
            $submenu2 = "Registry::HKEY_CLASSES_ROOT\*\shell\Tools"

            # Create submenu
            $SubTools = ""
            $SubToolsT = ""
            foreach ($tool in $Tools) {
                $SubToolsT += "$($tool.Name);"
            }

            $SubToolsT = $SubToolsT.TrimEnd(";")

            Write-Host "SubToolsT: $SubToolsT"

            $SubTools = $SubToolsT -join ";"
            New-Item $submenu1 -Force | Out-Null
            New-ItemProperty $submenu1 -Name "MUIVerb" -Value "SendTo Tools" -PropertyType String -Force | Out-Null
            New-ItemProperty $submenu1 -Name "SubCommands" -Value $SubTools -PropertyType String -Force | Out-Null
            New-Item $submenu2 -Force | Out-Null
            New-ItemProperty -LiteralPath $submenu2 -Name "MUIVerb" -Value "SendTo Tools" -PropertyType String -Force | Out-Null
            New-ItemProperty -LiteralPath $submenu2 -Name "SubCommands" -Value $SubTools -PropertyType String -Force | Out-Null

            foreach ($tool in $Tools) {
                Write-Host "Creating tool: $($tool.Name)"
                New-Tool -Name $tool.Name -DisplayName $tool.DisplayName -Command $tool.Command -IconFile $tool.IconFile -IconIndex $tool.IconIndex
            }

            pause
        }

        "2" {
            Remove-Item $ShortcutPath -ErrorAction SilentlyContinue
            Remove-Item "C:\SymlinkReceiver\Symlink.ps1" -ErrorAction SilentlyContinue
            Remove-Item (Join-Path $PSScriptRoot "Symlink.ps1") -ErrorAction SilentlyContinue
            Remove-Item "Registry::HKEY_CLASSES_ROOT\Directory\shell\Tools" -Recurse -ErrorAction SilentlyContinue
            Remove-Item "Registry::HKEY_CLASSES_ROOT\*\shell\Tools" -Recurse -ErrorAction SilentlyContinue
            Write-Host "Removed Send To shortcut.`r`nNote: The script file will not be deleted if you specified a custom location besides the default." -ForegroundColor Green

            pause
        }

        "Z" {
            exit
        }

        "X" {
            if (-not $Admin) {
                try {
                    Start-Process pwsh.exe -Verb RunAs -ArgumentList "-File `"$PSCommandPath`""
                } catch {
                    try {
                        Start-Process powershell.exe -Verb RunAs -ArgumentList "-File `"$PSCommandPath`""
                    } catch {
                        Write-Host "Failed to restart as administrator: $($_.Exception.Message)" -ForegroundColor Red
                    }
                }
                exit
            }
         }

    default {
         Write-Host "Invalid choice." -ForegroundColor Red
         pause
     }
}

}