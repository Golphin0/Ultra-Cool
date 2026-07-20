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

if ($args.Count -gt 0) {
    $Target = $args[0]
}
else {
    $Target = Read-Host "Enter target folder path"
}

$Target = $Target.Trim('"')

if (-not (Test-Path $Target)) {
    Write-Host "Item not found: $Target" -ForegroundColor Red
    pause
    exit
}

$Type = (Get-Item $Target).PSIsContainer

$Junction = "$Target-2"

if ($Type) {
    $Type = (Read-Styled "Enter link type, 1 for Junction, 2 for SymbolicLink.")
    if ($Type -eq 1) {
        $Type = "Junction"
    } else {
        $Type = "SymbolicLink"
    }
} else {
    $Type = "SymbolicLink"
}

New-Item -ItemType $Type -Path $Junction -Target $Target | Out-Null
Write-Styled "Created symbolic link from"
Center-Host "'$Target' to '$Junction'." $true
Write-Host "'$Target' to '$Junction'."
Center-Host " " $true
Start-Sleep -Seconds 2