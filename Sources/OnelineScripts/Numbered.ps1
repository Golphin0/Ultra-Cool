if (Test-Path "Numbered") { Remove-Item "Numbered" -Recurse -Force -ErrorAction SilentlyContinue; Write-Host "Existing 'Numbered' directory removed." }
$children = Get-ChildItem -Recurse $PWD | Sort-Object Name
Write-Host "Getting child items..."
New-Item -Force -ItemType Directory -Name "Numbered" | Out-Null
Write-Host "Got items. Creating numbered files..."
For ($i = 0; $i -lt $children.Count; $i++) {
    Write-Host "`r" -NoNewline
    $item = $children[$i]
    if (-not $item.PSIsContainer) {
        $relativePath = $item.FullName.Substring($PWD.Path.Length).TrimStart('\')
        $relativePath = Split-Path $relativePath
        $destDir = Join-Path "Numbered" $relativePath
        New-Item -Force -ItemType Directory -Path $destDir | Out-Null
        Copy-Item -Force -Path $item.FullName -Destination (Join-Path $destDir "$($i + 1)$($item.Extension)")
        Write-Host $i -NoNewline
    }

}