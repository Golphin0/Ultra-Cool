# Script Copier

$scripts = @(
    @{
        Name = "Numbered"
        Description = "A Simple Script to Rename Files by Number"
        Script = 'if(Test-Path "Numbered"){Remove-Item "Numbered" -Recurse -Force -ErrorAction SilentlyContinue;Write-Host "Existing ''Numbered'' directory removed."};$children=Get-ChildItem -Recurse $PWD|Sort-Object Name;Write-Host "Getting child items...";New-Item -Force -ItemType Directory -Name "Numbered"|Out-Null;Write-Host "Got items. Creating numbered files...";For($i=0;$i -lt $children.Count;$i++){Write-Host "`r" -NoNewline;$item=$children[$i];if(-not $item.PSIsContainer){$relativePath=$item.FullName.Substring($PWD.Path.Length).TrimStart(''\'');$relativePath=Split-Path $relativePath;$destDir=Join-Path "Numbered" $relativePath;New-Item -Force -ItemType Directory -Path $destDir|Out-Null;Copy-Item -Force -Path $item.FullName -Destination (Join-Path $destDir "$($i+1)$($item.Extension)");Write-Host $i -NoNewline}}'
    }
    @{
        Name = "Types"
        Description = "A Simple Script to Organize Files by Type"
        Script = 'if (Test-Path "Types") { Remove-Item "Types" -Recurse -Force -ErrorAction SilentlyContinue; Write-Host "Existing ''Types'' directory removed." }; $children = Get-ChildItem -Recurse $PWD | Sort-Object Name; Write-Host "Getting child items..."; New-Item -Force -ItemType Directory -Name "Types" | Out-Null; Write-Host "Got items. Creating type files..."; For ($i = 0; $i -lt $children.Count; $i++) { Write-Host "`r" -NoNewline; $item = $children[$i]; if (-not $item.PSIsContainer) { $destDir = Join-Path "Types" $item.Extension.Trim(''.''); $destDir = Join-Path $destDir $item.Name; New-Item -Force -ItemType Directory -Path "Types\$($item.Extension.Trim(''.''))" | Out-Null; Copy-Item -Force -Path $item.FullName -Destination $destDir; Write-Host $i -NoNewline } }'
    }
    @{
        Name = "TerrariaCE"
        Description = "A Simple Script to Manage Terraria Collector's Edition"
        Script = '$equals="="*26 -join "";$n="`r`n";$string="$equals$n     Terraria CE Tool$n$equals$n$n[1] Enable Collector''s Edition$n[Z] Exit$n${n}Enter your choice: ";$path="Registry::HKEY_CURRENT_USER\Software\Terraria";$ErrorActionPreference="Stop";while($true){Clear-Host;Write-Host $string -NoNewline;$option=Read-Host;switch($option.ToUpper()){"1"{try{Write-Host "Enabling Collector''s Edition...";New-Item -Path $path -Force|Out-Null;New-ItemProperty -Path $path -Name "Bunny" -Value "1" -PropertyType String -Force|Out-Null;Write-Host "Collector''s Edition enabled." -ForegroundColor Green}catch{Write-Host "Error occurred while enabling Collector''s Edition:" -ForegroundColor Red;Write-Host $_.Exception.Message -ForegroundColor Red}}"2"{try{Write-Host "Disabling Collector''s Edition...";Remove-ItemProperty -Path $path -Name "Bunny" -Force;Write-Host "Collector''s Edition disabled." -ForegroundColor Green}catch{Write-Host "Error occurred while disabling Collector''s Edition:" -ForegroundColor Red;Write-Host $_.Exception.Message -ForegroundColor Red}}"Z"{exit}default{Write-Host "Unknown option."}};pause}'
    }
)

function Copy-ScriptFromTable {
    Clear-Host
    Write-Host "=== Script Copier ==="
    Write-Host "`nAvailable Scripts:"
    
    for ($i = 0; $i -lt $scripts.Count; $i++) {
        Write-Host "$($i+1): $($scripts[$i].Name)"
        Write-Host "    $($scripts[$i].Description)"
    }

    $choice = Read-Host "Select script"

    if ($choice -match '^\d+$' -and $choice -le $scripts.Count) {
        $script = $scripts[$choice-1]
        Set-Clipboard $script.Script
        Write-Host "Script copied to clipboard." -ForegroundColor Green
    } else {
        Write-Host "Invalid selection." -ForegroundColor Red
    }
}

function Run-ScriptFromTable {
    Clear-Host
    Write-Host "=== Script Runner ==="
    Write-Host "`nAvailable Scripts:"
    
    for ($i = 0; $i -lt $scripts.Count; $i++) {
        Write-Host "$($i+1): $($scripts[$i].Name)"
        Write-Host "    $($scripts[$i].Description)"
    }

    $choice = Read-Host "Select script"

    if ($choice -match '^\d+$' -and $choice -le $scripts.Count) {
        $script = $scripts[$choice-1]
        Write-Host "Running script: $($script.Name)"
        Start-Sleep -Seconds 1
        Invoke-Expression $script.Script
    } else {
        Write-Host "Invalid selection." -ForegroundColor Red
    }
}

while ($true) {
    Clear-Host

    Write-Host "=== Script Copier ==="
    Write-Host ""
    Write-Host "1: Copy from script library"
    Write-Host "2: Run from script library"
    Write-Host "Z: Exit"
    Write-Host ""

    $option = Read-Host "Option"

    switch ($option.ToUpper()) {
        "1" {
            Copy-ScriptFromTable
        }

        "2" {
            Run-ScriptFromTable
        }

        "Z" {
            exit
        }

        default {
            Write-Host "Unknown option."
        }
    }

    pause
}