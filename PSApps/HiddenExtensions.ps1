$LastMessage = ""
$Failed = @()

$Extensions = @(
    '.lnk'
    '.url'
    '.website'
    '.library-ms'
    '.scf'
    '.search-ms'
    '.appref-ms'
    '.appcontent-ms'
    '.pif'
    '.searchConnector-ms'
    '.settingcontent-ms'
    '.accountpicture-ms'
    '.mydocs'
    '.desklink'
    '.mapimail'
    '.zfsendtotarget'
)

while ($true) {

    Clear-Host
    
    Write-Host "=== NeverShowExt Toggle ===`n"
    $AdminStatus = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $AdminStatus) {
        Write-Host "WARNING: Not running as administrator, some operations may fail.`n" -ForegroundColor Yellow
	} else {
        Write-Host "Running as Administrator.`n" -ForegroundColor Green
    }

    $Menu = @()
    $i = 0

    foreach ($Ext in $Extensions) {

        $Key = if ($i -lt 9) { [string]($i + 1) } else { [char](65 + $i - 9) }

        $ProgID = (Get-ItemProperty "Registry::HKEY_CLASSES_ROOT\$Ext" -ErrorAction SilentlyContinue).'(default)'

        if (-not $ProgID) {
            $State = "No ProgID"
        }
        else {
            $Hidden = $null -ne (Get-ItemProperty `
                -Path "Registry::HKEY_CLASSES_ROOT\$ProgID" `
                -Name NeverShowExt `
                -ErrorAction SilentlyContinue)

            $State = if ($Hidden) { "Hidden" } else { "Shown" }
        }

        $Menu += [pscustomobject]@{
            Key    = $Key
            Ext    = $Ext
            ProgID = $ProgID
        }

        if ($Failed -contains $Ext) {
            Write-Host ("[{0}] {1,-22} {2}" -f $Key, $Ext, $State) -ForegroundColor DarkYellow
        }
        else {
            Write-Host ("[{0}] {1,-22} {2}" -f $Key, $Ext, $State)
        }

        $i++
    }

    if ($LastMessage) {
        Write-Host
        Write-Host $LastMessage -ForegroundColor Green
    }

    Write-Host
    if (-not $AdminStatus) {
       Write-Host "[X]  Run as Administrator"
    }
    Write-Host "[Z]  Quit"
    Write-Host
    Write-Host "Press 1-9 or A-G..."

    do {
        $Choice = ([Console]::ReadKey($true).KeyChar).ToString().ToUpper()
    } until ($Choice -eq 'Z' -or $Choice -eq 'X' -or $Menu.Key -contains $Choice)

    if ($Choice -eq 'Z') {
        break
    }
    if ($Choice -eq 'X' -and -not $AdminStatus) {
        try {
            Start-Process pwsh.exe -Verb RunAs -ArgumentList "-File `"$PSCommandPath`""
        } catch {
            try {
                Start-Process powershell.exe -Verb RunAs -ArgumentList "-File `"$PSCommandPath`""
            } catch {
                Write-Host "Failed to restart as administrator: $($_.Exception.Message)" -ForegroundColor Red
            }
            Write-Host "Failed to restart as administrator: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        break
    }

    $Item = $Menu | Where-Object Key -eq $Choice

    $Path = "Registry::HKEY_CLASSES_ROOT\$($Item.ProgID)"

    try {

        $Existing = Get-ItemProperty `
            -Path $Path `
            -Name NeverShowExt `
            -ErrorAction Stop

        Remove-ItemProperty `
            -Path $Path `
            -Name NeverShowExt `
            -ErrorAction Stop

        $LastMessage = "$($Item.Ext) is now shown."

    }
    catch {

        try {

            New-ItemProperty `
                -Path $Path `
                -Name NeverShowExt `
                -PropertyType String `
                -Value "" `
                -Force `
                -ErrorAction Stop | Out-Null

            $LastMessage = "$($Item.Ext) is now hidden."

        }
        catch {

            if ($Failed -notcontains $Item.Ext) {
                $Failed += $Item.Ext
            }

            $LastMessage = "$($Item.Ext) failed: $($_.Exception.Message)"

        }
    }
}