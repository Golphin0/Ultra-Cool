# Ultra Cool Creator

$running = $true
$VerboseMode = $true
$WaitAfterDone = $true

if (-not $iconsbase64) {
    if (-not (Test-Path (Join-Path $PSScriptRoot "base64.txt") ) ) {
        Write-Host "base64.txt not found. Please ensure it is in the same directory as this script."
        pause
        $running = $false
        exit
    }
    $Base64File = (Get-Content -Path (Join-Path $PSScriptRoot "base64.txt"))
    $iconsbase64 = $Base64File[1]
}

function New-FolderWithIcon {
    param(
        [string]$FolderPath,
        [string]$IconFile,
        [int]$IconIndex = 0
    )

    New-Item -ItemType Directory -Path $FolderPath -Force | Out-Null

    "[.ShellClassInfo]`r`nIconResource=$IconFile,$IconIndex" | Set-Content (Join-Path $FolderPath "desktop.ini") -Encoding ASCII

    attrib +h +s (Join-Path $FolderPath "desktop.ini")
    attrib +r $FolderPath
}

function Make-UltraCool {
    Clear-Host
    Write-Host "========================="
    Write-Host "   Ultra Cool Creator"
    Write-Host "========================="
    Write-Host ""
    $ResourcesInsideUltraCool = (Read-Host "Store resources inside the Ultra Cool folder? [y/n]") -eq "y"


    $path = Join-Path $PSScriptRoot "Ultra Cool"
    $resources = if ($ResourcesInsideUltraCool -eq $true) {Join-Path $path "Resources"} else {"C:\UltraCoolResources"}
    $existing = Test-Path $path
    if ($existing) {
    
    $deleteAllowed = (Read-Host "Old Ultra Cool will now be deleted. Would you like to attempt to directly overwrite? [y/n]") -eq "y"
    Clear-Host
    if (-not $deleteAllowed) {Remove-UltraCool $true}
    
    }

    if (-not $existing) {Clear-Host}
    
    Write-Host "Creating Ultra Cool..." -ForegroundColor Cyan

    if ($VerboseMode) { Write-Host "Folder: $resources" }

    New-FolderWithIcon -FolderPath $path -IconFile (Join-Path $resources "imageplus1.icl") -IconIndex 0 | Out-Null
    New-Item -ItemType Directory -Path $resources -Force | Out-Null

    $desktopIni = Join-Path $path "desktop.ini"

    if (Test-Path $desktopIni) {
        if ($VerboseMode) { Write-Host "Removing desktop.ini attributes..." }
        attrib -h -s -r $desktopIni
    }
    
    $desktopIni = Join-Path $path "Useful Links\desktop.ini"

    if (Test-Path $desktopIni) {
        if ($VerboseMode) { Write-Host "Removing links desktop.ini attributes..." }
        attrib -h -s -r $desktopIni
    }

    if ($VerboseMode) { Write-Host "Writing icons..." }

    
    [IO.File]::WriteAllBytes(
        (Join-Path $resources "Icons.zip"),
        [Convert]::FromBase64String($iconsbase64)
    )

    Expand-Archive -Path (Join-Path $resources "Icons.zip") -DestinationPath $resources
    Remove-Item (Join-Path $resources "Icons.zip")

    if ($VerboseMode) { Write-Host "Writing desktop.ini..." }

    New-FolderWithIcon -FolderPath (Join-Path $path "Useful Links") -IconFile (Join-Path $resources "imageplus2.icl") -IconIndex 79
    New-FolderWithIcon -FolderPath (Join-Path $path "Resources") -IconFile (Join-Path $resources "imageplus2.icl") -IconIndex 61

    if ($VerboseMode) { Write-Host "Creating shell links..." }

    $shell32icons = "$env:SystemRoot\System32\shell32.dll"


    $items = @{
        "God Mode" = @{
            Shell = "::{ED7BA470-8E54-465E-825C-99712043E01C}"
            Icon  = $shell32icons
            Index = 19
        }
        "Control Panel" = @{
            Shell = "::{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}"
            Icon  = $shell32icons
            Index = 21
        }
        "This PC" = @{
            Shell = "::{20D04FE0-3AEA-1069-A2D8-08002B30309D}"
            Icon  = $shell32icons
            Index = 15
        }
        "Network" = @{
            Shell = "::{F02C1A0D-BE21-4350-88B0-7367FC96EF3C}"
            Icon  = $shell32icons
            Index = 18
        }
        "Recycle Bin" = @{
            Shell = "::{645FF040-5081-101B-9F08-00AA002F954E}"
            Icon  = $shell32icons
            Index = 64
        }
        "Printers" = @{
            Shell = "::{2227A280-3AEA-1069-A2DE-08002B30309D}"
            Icon  = $shell32icons
            Index = 16
        }
        "Fonts" = @{
            Shell = "::{BD84B380-8CA2-1069-AB1D-08000948F534}"
            Icon  = $shell32icons
            Index = 38
        }
        "Programs" = @{
            Shell = "::{4234D49B-0245-4DF3-B780-3893943456E1}"
            Icon  = $shell32icons
            Index = 2
        }
        "Search" = @{
            Shell = "::{9343812E-1C37-4A49-A12E-4B2D810D956B}"
            Icon  = $shell32icons   
            Index = 22
        }
        "Run Commands" = @{
            Shell = "::{2559A1F3-21D7-11D4-BDAF-00C04F60B9F0}"
            Icon  = $shell32icons
            Index = 326
        }
    }

    

    $shell = New-Object -ComObject WScript.Shell
    $folder = Join-Path $path "Useful Links"

    foreach ($name in $items.Keys) {
        if ($VerboseMode) { Write-Host "Creating $name..." }

        $shortcut = Join-Path $folder "$name.lnk"

        $link = $shell.CreateShortcut($shortcut)
        $link.TargetPath = "explorer.exe"
        $link.Arguments = "shell:$($items[$name].Shell)"
        $link.IconLocation = "$($items[$name].Icon), $($items[$name].Index)"
        $link.Save()
    }

    if (-not $ResourcesInsideUltraCool) { 

    if ($VerboseMode) { Write-Host "Creating Resources Shortcut..." }

    $shortcut = Join-Path $folder "Resources For Ultra Cool.lnk"
    $link = $shell.CreateShortcut($shortcut)
    $link.TargetPath = $resources
    $link.IconLocation = "$(Join-Path $resources "imageplus2.icl"), 61"
    $link.Save()

    }


    Write-Host "`nDone!" -ForegroundColor Green

    if ($WaitAfterDone) {
        pause
    }
}

function Remove-UltraCool($embed) {
    Clear-Host
    Write-Host "Removing Ultra Cool..." -ForegroundColor Cyan

    $path = Join-Path $PSScriptRoot "Ultra Cool"
    $resources = "C:\UltraCoolResources"

    function Remove-Folder($folder) {
        if (!(Test-Path $folder)) { return }

        Get-ChildItem $folder -Force | ForEach-Object {
            attrib -h -s -r $_.FullName 2>$null

            if ($_.PSIsContainer) {
                Remove-Folder $_.FullName
            }
            else {
                Remove-Item $_.FullName -Force
            }
        }

        attrib -h -s -r $folder 2>$null
        Remove-Item $folder -Force
    }

    Remove-Folder $path
    Remove-Folder $resources

    Write-Host "`nUltra Cool has been removed!" -ForegroundColor Green

    if ($WaitAfterDone -and -not $embed) {pause}
    if ($embed) {Write-Host ""}
}

while ($running) {
    Clear-Host

    Write-Host "========================="
    Write-Host "   Ultra Cool Creator"
    Write-Host "========================="
    Write-Host ""
    Write-Host "1. Create Ultra Cool"
    Write-Host "2. Remove Ultra Cool"
    Write-Host "3. Toggle Verbose ($VerboseMode)"
    Write-Host "4. Toggle Wait After Done ($WaitAfterDone)"
    Write-Host "5. Quit"
    Write-Host ""

    $choice = Read-Host "Select"

    switch ($choice) {
        "1" { Make-UltraCool }
        "2" { Remove-UltraCool }
        "3" { $VerboseMode = -not $VerboseMode }
        "4" { $WaitAfterDone = -not $WaitAfterDone }
        "5" { $running = $false }
        default {
            Write-Host "Invalid option"
            Start-Sleep 1
        }
    }
}