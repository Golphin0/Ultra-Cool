$equals = "=" * 26 -join ""
$n = "`r`n"
$string = "$equals$n     Terraria CE Tool$n$equals$n$n[1] Enable Collector's Edition$n[Z] Exit$n${n}Enter your choice: "
$path = "Registry::HKEY_CURRENT_USER\Software\Terraria"
$ErrorActionPreference = "Stop"


while ($true) {
    
    Clear-Host
    Write-Host $string -NoNewline
    $option = Read-Host

    switch ($option.ToUpper()) {
            "1" {
                try {
                    Write-Host "Enabling Collector's Edition..."
                    New-Item -Path $path -Force | Out-Null
                    New-ItemProperty -Path $path -Name "Bunny" -Value "1" -PropertyType String -Force | Out-Null
                    Write-Host "Collector's Edition enabled." -ForegroundColor Green
                } catch {
                    Write-Host "Error occurred while enabling Collector's Edition:" -ForegroundColor Red
                    Write-Host $_.Exception.Message -ForegroundColor Red
                }
            }

            "2" {
                try {
                    Write-Host "Disabling Collector's Edition..."
                    Remove-ItemProperty -Path $path -Name "Bunny" -Force
                    Write-Host "Collector's Edition disabled." -ForegroundColor Green
                } catch {
                    Write-Host "Error occurred while disabling Collector's Edition:" -ForegroundColor Red
                    Write-Host $_.Exception.Message -ForegroundColor Red
                }
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