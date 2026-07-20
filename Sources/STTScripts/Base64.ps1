param(
    [Parameter(Position = 0)]
    [string]$FilePath
)

if (-not $FilePath) {
    $FilePath = Read-Host "Enter file path"
}

if (-not (Test-Path -LiteralPath $FilePath -PathType Leaf)) {
    Write-Error "File not found: $FilePath"
    exit 1
}

$FilePath = $FilePath.Trim('"')
$base64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($FilePath))
Set-Clipboard -Value $base64


# Write a message to the console
Clear-Host
$message = "Copied Base64 of '$FilePath' to the clipboard."
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
Start-Sleep 1