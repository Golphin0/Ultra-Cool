$baseFile = "base.ps1"
$b64File = "base64.txt"
$outFile = "UltraCool.ps1"

if (!(Test-Path $baseFile)) {
    Write-Host "$baseFile not found." -ForegroundColor Red
    pause
    exit 1
}

if (!(Test-Path $b64File)) {
    Write-Host "$b64File not found." -ForegroundColor Red
    pause
    exit 1
}

$base = Get-Content $baseFile -Raw
$lines = Get-Content $b64File

if ($lines.Count % 2 -ne 0) {
    Write-Host "base64.txt must contain an even number of lines (name, value, name, value...)." -ForegroundColor Red
    pause
    exit 1
}

$out = ""
$out += "# Base64 Strings`r`n"

for ($i = 0; $i -lt $lines.Count; $i += 2) {
    $name = $lines[$i].Trim()
    $value = $lines[$i + 1]
    $out += "`$$name = `"$value`"`r`n"
}

$out += "`r`n"
$out += $base.TrimStart()

Set-Content $outFile -Value $out -Encoding UTF8

Write-Host "Created $outFile"
Start-Sleep 1

