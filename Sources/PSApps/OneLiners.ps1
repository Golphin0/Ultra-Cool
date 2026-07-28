# Script Copier

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