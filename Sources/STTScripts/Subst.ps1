if ($args.Count -gt 0) {
    $Path = $args[0]
}
else {
    $Path = Read-Host "Enter folder path"
}

Function Write-Styled($message, $color) {
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
    if ($color) {
        $ui.ForegroundColor = $color
    } else {
        $ui.ForegroundColor = 'Black'
    }

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

if (-not (Test-Path $Path -PathType Container)) {
    Write-Styled "Folder not found." -ForegroundColor Red
    Start-Sleep 1
    exit
}

$Drive = Read-Styled "Enter drive letter (e.g. X)"
$Drive = $Drive.TrimEnd(":").ToUpper()

subst "$Drive`:" "$Path"

if ($LASTEXITCODE -eq 0) {
    Write-Styled "Created drive $Drive`:"
    Center-Host "->" $true
    Write-Host "->" -NoNewline
    Center-Host "$Path" $true
    Write-Host "$Path" -NoNewline
}
else {
    Write-Styled "Failed to create drive." "Red"
}

Start-Sleep 1