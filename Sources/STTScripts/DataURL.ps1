param(
    [string]$Path
)

if (-not $Path) {
    $Path = Read-Host "Enter file path"
}

Function Write-Styled($message) {
    # Write a message to the console
    Clear-Host
    $ui = $Host.UI.RawUI
    $width = $ui.WindowSize.Width
    $height = $ui.WindowSize.Height

    $left = [math]::Max(0, ($width - $message.Length) / 2)
    $top = [math]::Max(0, ($height / 2) - 1)

    $size = $Host.UI.RawUI.WindowSize
    $line = " " * $size.Width

    $ui.BackgroundColor = 'Blue'
    $ui.ForegroundColor = 'Black'

    1..$size.Height | ForEach-Object {
        Write-Host $line
    }

    $ui.CursorPosition = New-Object Management.Automation.Host.Coordinates($left, $top)

    Write-Host $message -NoNewline
}
Function Read-Styled($message) {
    # Read a value from the console
    Clear-Host
    $ui = $Host.UI.RawUI
    $width = $ui.WindowSize.Width
    $height = $ui.WindowSize.Height

    $left = [math]::Max(0, ($width - $message.Length) / 2)
    $top = [math]::Max(0, ($height / 2) - 1)

    $size = $Host.UI.RawUI.WindowSize
    $line = " " * $size.Width

    $ui.BackgroundColor = 'Blue'
    $ui.ForegroundColor = 'Black'

    1..$size.Height | ForEach-Object {
        Write-Host $line
    }

    $ui.CursorPosition = New-Object Management.Automation.Host.Coordinates($left, $top)

    Write-Host $message -NoNewline
    $trueCenter = [math]::Max(0, ($width / 2) - 1)
    $trueCenVert = [math]::Max(0, $height / 2)
    $ui.CursorPosition = New-Object Management.Automation.Host.Coordinates($trueCenter, $trueCenVert)
    $in = Read-Host
    return $in
}

Function Center-Host($message, $newLine) {
    $ui = $Host.UI.RawUI
    $width = $ui.WindowSize.Width
    $height = $ui.WindowSize.Height
    $left = [math]::Max(0, ($width - $message.Length) / 2)

    if ($newLine) { Write-Host }

    $ui.CursorPosition = New-Object Management.Automation.Host.Coordinates($left, $ui.CursorPosition.Y)
}

$Path = $Path.Trim('"')

if (-not (Test-Path $Path)) {
    Write-Styled "File not found."
    Start-Sleep -Seconds 2
    exit
}

$Path = (Resolve-Path $Path).Path

if ((Get-Item $Path).Length -gt 2KB) {
    Write-Styled "File may be too big to work properly."
    Center-Host "Continue? (y/n)" $true
    Write-Host "Continue? (y/n)" -NoNewline
    Center-Host " " $true
    $answer = (Read-Host).ToLower() -ne "n"
    if (-not $answer) {
        Write-Styled "Cancelled."
        Start-Sleep -Seconds 1
        exit
    }
}

Add-Type -AssemblyName System.Web

$ext = [IO.Path]::GetExtension($Path)
$mime = (Get-ItemProperty "Registry::HKEY_CLASSES_ROOT\$ext" -ErrorAction SilentlyContinue).'Content Type'

$bytes = [IO.File]::ReadAllBytes($Path)
$b64 = [Convert]::ToBase64String($bytes)

$dataUrl = "data:$mime;base64,$b64"

Set-Clipboard $dataUrl

Write-Styled "Copied data URL to clipboard."
Center-Host " " $true
Start-Sleep -Seconds 1
exit