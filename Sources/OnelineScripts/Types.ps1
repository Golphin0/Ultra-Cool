if (Test-Path "Types") { Remove-Item "Types" -Recurse -Force -ErrorAction SilentlyContinue; Write-Host "Existing 'Types' directory removed." }
$children = Get-ChildItem -Recurse $PWD | Sort-Object Name
Write-Host "Getting child items..."
New-Item -Force -ItemType Directory -Name "Types" | Out-Null
Write-Host "Got items. Creating type files..."
For ($i = 0; $i -lt $children.Count; $i++) {
    Write-Host "`r" -NoNewline
    $item = $children[$i]
    if (-not $item.PSIsContainer) {
        $destDir = Join-Path "Types" $item.Extension.Trim('.')
        $destDir = Join-Path $destDir $item.Name
        New-Item -Force -ItemType Directory -Path "Types\$($item.Extension.Trim('.'))" | Out-Null
        Copy-Item -Force -Path $item.FullName -Destination $destDir
        Write-Host $i -NoNewline
    }

}