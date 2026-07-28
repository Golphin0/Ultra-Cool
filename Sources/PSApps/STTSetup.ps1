$Tools = @(
    @{
        Name = "ToolSubmenuPaths"
        Paths = @(
            "Directory"
            "*"
            "Drive"
        )
    }
    @{
        Name = "SubmenuGroup"
        Paths = @(
            "Directory"
            "*"
        )
        Tools = @(
            @{
                Name = "Symlink"
                DisplayName = "New Symlink"
                Command = "pwsh.exe -File `"[[SCRIPTPATH]]\Symlink.ps1`" `"%1`""
                IconFile = "[[RESOURCES]]\imageplus1.icl"
                IconIndex = 34
                AppliesTo = ""
            }
            @{
                Name = "Subst"
                DisplayName = "Mount as Drive"
                Command = "pwsh.exe -File `"[[SCRIPTPATH]]\Subst.ps1`" `"%1`""
                IconFile = "[[RESOURCES]]\imageplus1.icl"
                IconIndex = 16
                AppliesTo = "Directory"
            }
            @{
                Name = "Base64"
                DisplayName = "Copy as Base64"
                Command = "pwsh.exe -File `"[[SCRIPTPATH]]\Base64.ps1`" `"%1`""
                IconFile = "[[RESOURCES]]\imageplus2.icl"
                IconIndex = 33
                AppliesTo = "System.ItemType:<>Directory"
            }
            @{
                Name = "DataUrl"
                DisplayName = "Copy as Data URL"
                Command = "pwsh.exe -File `"[[SCRIPTPATH]]\DataURL.ps1`" `"%1`""
                IconFile = "[[RESOURCES]]\imageplus2.icl"
                IconIndex = 172
                AppliesTo = "System.ItemType:<>Directory"
            }
            @{
                Name = "ADS"
                DisplayName = "Edit Data Streams"
                Command = "pwsh.exe -File `"[[SCRIPTPATH]]\ADSManager.ps1`" `"%1`""
                IconFile = "[[RESOURCES]]\imageplus2.icl"
                IconIndex = 265
                AppliesTo = "System.ItemType:<>Directory"
            }
        )
    }
    @{
        Name = "SubmenuGroup"
        Paths = @("Drive")
        Tools = @(
            @{
                Name = "Substrm"
                DisplayName = "Remove Mounted Drive"
                Command = "pwsh.exe -File `"[[SCRIPTPATH]]\Substrm.ps1`" `"%1`""
                IconFile = "[[RESOURCES]]\imageplus1.icl"
                IconIndex = 16
                AppliesTo = "NOT System.ParsingPath:=`"C:\`""
            }
        )
    }
    @{
        Name = "Metadata"
        Metadata = @{
            IconFile = "[[RESOURCES]]\imageplus2.icl"
            IconIndex = 55
        }
    }
)

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

            $cmdStore = "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell"

            function Set-Receiver {
                $Good = $true
                $ReceiverPath = Read-Host "Enter the path where you want to place the script, With or without quotes (Enter nothing for default location `"C:\STTReceiver\STT.ps1`")"
                if ($ReceiverPath -eq "") {
                    $ReceiverPath = "C:\STTReceiver"
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

            $existing = $false

            foreach ($path in ($Tools | Where-Object { $_.Name -eq "ToolSubmenuPaths" }).Paths) {
                if (Test-Path "Registry::HKEY_CLASSES_ROOT\$path") {
                    $existing = $true
                    break
                }
            }

            if ($existing) {
                Write-Host -NoNewline "Already exists. Do you want to override it? (Y/N): " -ForegroundColor Yellow
                $Override = (Read-Host).ToLower() -eq "n"

                if ($Override) {
                    Write-Host "Shortcut not created." -ForegroundColor Red
                    pause
                    break
                }
            }

            $SetupReciever = (Read-Host "Do you want to have the sendto recieve from a special location? (Y/N)`r`nIf you choose Y, the script will be placed at a special location, less likely to be deleted, and the shortcut will point to that location.`r`nIf you choose N, the script will be placed in the same folder as this script and the shortcut will point to that location.`r`nBy Default, entering nothing will choose Y.`r`nEnter Y or N").ToLower() -ne "n"
            $ScriptPath = if ($SetupReciever) { Set-Receiver } else { (Join-Path $PSScriptRoot "STT") }
            if (-not $ScriptPath) {
                Write-Styled "No valid script path provided. Exiting."
                Start-Sleep -Seconds 2
                break
            }

            $AddIcons = (Read-Host "Do you want to add icons to the shortcuts? (Y/N)`r`nBy Default, entering nothing will choose Y.`r`nEnter Y or N").ToUpper() -ne "N"

            function New-Tool {
                param(
                    [string]$Name,
                    [string]$DisplayName,
                    [string]$Command,
                    [String]$IconFile,
                    [Int]$IconIndex,
                    [string]$AppliesTo

                )

                $Path = "$cmdStore\$Name"

                New-Item $Path -Force | Out-Null
                Set-ItemProperty $Path -Name "(default)" -Value $DisplayName

                New-Item "$Path\command" -Force | Out-Null
                Set-ItemProperty "$Path\command" -Name "(default)" -Value $Command

                if ($AddIcons) {
                    New-ItemProperty $Path -Name "Icon" -Value "`"$IconFile`",$IconIndex" -PropertyType String -Force | Out-Null
                }

                if (($AppliesTo) -and ($AppliesTo -ne "") ) {
                    New-ItemProperty $Path -Name "AppliesTo" -Value $AppliesTo -PropertyType String -Force | Out-Null
                }
            }

            # Create Scripts from Base64

            $ScriptZip = Join-Path $PSScriptRoot "Scripts.zip"
            if ($AddIcons -eq $true) {
                if (Test-Path "$(Split-Path $PSScriptRoot)\Resources") {
                    $resourcesPath = "$(Split-Path $PSScriptRoot)\Resources"
                } elseif (Test-Path "C:\UltraCoolResources") {
                    $resourcesPath = "C:\UltraCoolResources"
                } else {
                    Write-Host "Resources directory not found. Continuing without icons." -ForegroundColor Yellow
                    pause
                }
            }

            foreach ($tool in ($Tools | Where-Object Name -eq "SubmenuGroup").Tools) {
                # $new = $string -replace "old", "new"
                $tool.IconFile = $tool.IconFile -replace "\[\[RESOURCES\]\]", $resourcesPath
                $tool.Command = $tool.Command -replace "\[\[SCRIPTPATH\]\]", $ScriptPath
            }
            ($Tools | Where-Object Name -eq "Metadata").Metadata.IconFile = (
                ($Tools | Where-Object Name -eq "Metadata").Metadata.IconFile -replace "\[\[RESOURCES\]\]", $resourcesPath
            )

            [IO.File]::WriteAllBytes($ScriptZip, [Convert]::FromBase64String($ScriptsBase64))
            Expand-Archive -LiteralPath $ScriptZip -DestinationPath $ScriptPath -Force
            Remove-Item $ScriptZip -Force


            foreach ($path in ($Tools | Where-Object Name -eq "ToolSubmenuPaths").Paths) {
                $SubmenuTools = @()
                New-Item "Registry::HKEY_CLASSES_ROOT\$path\shell\Tools" -Force | Out-Null
                New-ItemProperty -LiteralPath "Registry::HKEY_CLASSES_ROOT\$path\shell\Tools" -Name "MUIVerb" -Value "SendTo Tools" -PropertyType String -Force | Out-Null
                foreach ($tool in (($Tools | Where-Object { 
                    $_.Name -eq "SubmenuGroup" -and $_.Paths -contains (Split-Path $path -Leaf)
                }).Tools)) {

                    Write-Host "Creating tool: $($tool.Name) of type $($path)"
                    New-Tool -Name $tool.Name `
                            -DisplayName $tool.DisplayName `
                            -Command $tool.Command `
                            -IconFile $tool.IconFile `
                            -IconIndex $tool.IconIndex `
                            -AppliesTo $tool.AppliesTo
                    $SubmenuTools += $tool.Name
                    
                }
                New-ItemProperty -LiteralPath "Registry::HKEY_CLASSES_ROOT\$path\shell\Tools" -Name "SubCommands" -Value ($SubmenuTools -join ";") -PropertyType String -Force | Out-Null
                New-ItemProperty -LiteralPath "Registry::HKEY_CLASSES_ROOT\$path\shell\Tools" -Name "Icon" -Value "`"$(($Tools | Where-Object Name -eq "Metadata").Metadata.IconFile)`",$(($Tools | Where-Object Name -eq "Metadata").Metadata.IconIndex)" -PropertyType String -Force | Out-Null
            }

            pause
        }

        "2" {
            Remove-Item "C:\STTReceiver\STT.ps1" -ErrorAction SilentlyContinue
            Remove-Item "Registry::HKEY_CLASSES_ROOT\Directory\shell\Tools" -Recurse -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath "Registry::HKEY_CLASSES_ROOT\*\shell\Tools" -Recurse -ErrorAction SilentlyContinue
            foreach ($tool in (($Tools | Where-Object { $_.Name -eq "SubmenuGroup" }).Tools)) {
                Remove-Item (Join-Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CommandStore\shell" $tool.Name) -Force -Recurse -ErrorAction SilentlyContinue
            }
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