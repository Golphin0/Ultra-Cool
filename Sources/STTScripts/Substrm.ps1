if ($args.Count -gt 0) {
    $Drive = $args[0]
}
else {
    $Drive = Read-Host "Enter drive letter"
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

$Drive = ($Drive -replace "[^a-zA-Z0-9]", "").ToUpper() + ":"

$substList = subst

$match = $substList | Select-String "^$([regex]::Escape($Drive))\\"

if (-not $match) {
    Write-Styled "$Drive is not a SUBST drive."
    Start-Sleep -Seconds 1
    exit
}

Write-Styled "Found SUBST drive:"
Center-Host $Drive $true
Write-Host "$Drive" -NoNewline
Center-Host "Remove ${Drive}?" $true
Write-Host "Remove ${Drive}?" -NoNewline
Center-Host " " $true
$confirm = (Read-Host).ToUpper()

if ($confirm -eq "Y") {
    subst $Drive /D
    Write-Styled "Removed $Drive"
}
else {
    Write-Styled "Cancelled."
}

Start-Sleep -Seconds 1
exit