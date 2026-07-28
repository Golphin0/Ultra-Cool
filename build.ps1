Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

$defaultSources = Join-Path $PSScriptRoot "Sources"
$defaultOutput = $PSScriptRoot

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="UltraCool Builder"
        Width="850"
        Height="500"
        MinWidth="700"
        MinHeight="400"
        WindowStartupLocation="CenterScreen"
        FontFamily="Segoe UI"
        FontSize="13">

    <Border Padding="20">

        <Grid>

            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>

            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="90"/>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="90"/>
            </Grid.ColumnDefinitions>

            <Border Grid.Row="0"
                    Grid.ColumnSpan="3"
                    Background="#0078D7"
                    CornerRadius="16"
                    Padding="15"
                    Margin="0,0,0,20">

                <Grid>

                    <TextBlock Text="UltraCool Builder"
                            FontSize="28"
                            FontWeight="SemiBold"
                            HorizontalAlignment="Left"
                            Foreground="White"/>

                    <TextBlock Text="Ultra Cool &amp; Builder&#10; By Judah Brawn"
                            FontSize="12"
                            FontWeight="SemiBold"
                            HorizontalAlignment="Right"
                            VerticalAlignment="Center"
                            TextAlignment="Center"
                            Foreground="White"/>

                </Grid>

            </Border>

            <!-- Sources -->
            <Label Grid.Row="1"
                   Grid.Column="0"
                   VerticalAlignment="Center">
                Sources:
            </Label>

            <TextBox Name="SourcesFolder"
                     Grid.Row="1"
                     Grid.Column="1"
                     Margin="5"/>

            <Button Name="BrowseSources"
                    Grid.Row="1"
                    Grid.Column="2"
                    Margin="5">
                Browse...
            </Button>

            <!-- Output -->
            <Label Grid.Row="2"
                   Grid.Column="0"
                   VerticalAlignment="Center">
                Output:
            </Label>

            <TextBox Name="OutputFile"
                     Grid.Row="2"
                     Grid.Column="1"
                     Margin="5"/>

            <Button Name="BrowseOutput"
                    Grid.Row="2"
                    Grid.Column="2"
                    Margin="5">
                Browse...
            </Button>

            <StackPanel Grid.Row="4"
                    Grid.ColumnSpan="3"
                    Orientation="Horizontal"
                    HorizontalAlignment="Right"
                    VerticalAlignment="Bottom"
                    Margin="0,25,0,0">

            <Button Name="ResetButton"
                    Width="100"
                    Height="32"
                    Margin="5"
                    HorizontalContentAlignment="Center"
                    VerticalContentAlignment="Center">
                Reset Paths
            </Button>

            <Button Name="CreateButton"
                    Width="100"
                    Height="32"
                    Margin="5">
                Create
            </Button>

            <Button Name="CancelButton"
                    Width="100"
                    Height="32"
                    Margin="5">
                Cancel
            </Button>

        </StackPanel>

        </Grid>

    </Border>

</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader ([xml]$xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$SourcesFolder   = $window.FindName("SourcesFolder")
$OutputFile   = $window.FindName("OutputFile")

$BrowseSources = $window.FindName("BrowseSources")
$BrowseOutput = $window.FindName("BrowseOutput")

$ResetButton = $window.FindName("ResetButton")
$CreateButton = $window.FindName("CreateButton")
$CancelButton = $window.FindName("CancelButton")

$SourcesFolder.Text = $defaultSources
$OutputFile.Text = $defaultOutput


$BrowseSources.Add_Click({
    $d = New-Object System.Windows.Forms.FolderBrowserDialog
    $d.SelectedPath = $SourcesFolder.Text

    if ($d.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $SourcesFolder.Text = $d.SelectedPath
    }
})

$BrowseOutput.Add_Click({
    $d = New-Object System.Windows.Forms.FolderBrowserDialog
    $d.SelectedPath = $OutputFile.Text

    if ($d.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $OutputFile.Text = $d.SelectedPath
    }
})

$ResetButton.Add_Click({
    $SourcesFolder.Text = $defaultSources
    $OutputFile.Text = $defaultOutput
})

$CreateButton.Add_Click({
    $script:SourcesFolder    = $SourcesFolder.Text
    $script:outFile    = $OutputFile.Text
    $window.DialogResult = $true
})

$CancelButton.Add_Click({
    $window.DialogResult = $false
})

if(-not $window.ShowDialog()){
    return
}

Write-Verbose "Sources Folder : $SourcesFolder" -Verbose
Write-Verbose "Output File : $outFile" -Verbose


if (-not (Test-Path $SourcesFolder)) {
    Write-Verbose "Sources Folder Not Found." -Verbose
    Write-Host "$SourcesFolder not found." -ForegroundColor Red
    pause
    exit 1
}

Write-Verbose "Reading input files..." -Verbose

if (-not (Test-Path (Join-Path $SourcesFolder "manifest.json"))) {
    Write-Host "$SourcesFolder/manifest.json not found." -ForegroundColor Red
    pause
    exit 1
}

$lines = Get-Content (Join-Path $SourcesFolder "manifest.json")


New-Item -Force -ItemType Directory -Path (Join-Path $env:TEMP "UCBuildTemp")
Write-Verbose "Processing variables..." -Verbose

$json = $lines | ConvertFrom-Json
$basefiles = @()

foreach ($item in $json) {
    $name = $item.name
    if ($name -eq "basefiles") {
        foreach ($file in $item.files) {
            $basefiles += $file
        }
    } elseif ($name -eq "sources") {
        foreach ($file in $item.files) {
            Write-Verbose "Processing $($file.name)..." -Verbose
            $format = $file.format
            $archive = $file.archive
            $source = $file.source
            $target = $file.target -replace '\[\[CURRENTBUILDS\]\]', (Join-Path $env:TEMP "UCBuildTemp")
            $fromSources = $false
            if ($target -like "@*") {
                $target = $target.TrimStart('@')
                $fromSources = $true
            }
            if ($fromSources -eq $true) {
                $target = $($basefiles | Where-Object name -eq $target | Select-Object -First 1).path
                Write-Verbose "Target file: $target" -Verbose
                Write-Verbose "UHUH" -Verbose
            }
            $varname = $file.varname
            $source = $source -replace '\[\[CURRENTBUILDS\]\]', (Join-Path $env:TEMP "UCBuildTemp")
            $tempplace = Join-Path $env:TEMP (Join-Path "UCBuildTemp" $file.tempplace)
            $out = ""
            Set-Location $SourcesFolder

            if ($format -eq "base64") {
                switch ($archive) {
                    $true {
                        Write-Verbose "$source" -Verbose
                        Write-Verbose "$(Join-Path $source "*")" -Verbose
                        $tempZip = "$(Join-Path $env:TEMP (Join-Path "UCBuildTemp" ("tempzip$(Get-Random -Min 1000 -Max 10000)" + ".zip")))"
                        Write-Verbose "$tempZip" -Verbose
                        Compress-Archive -Path (Join-Path $source "*") -DestinationPath $tempZip
                        $rawData = [IO.File]::ReadAllBytes($tempZip)
                        Remove-Item $tempZip
                    }
                    $false {
                        $rawData = [IO.File]::ReadAllBytes($source)
                    }
                }
                $base64Data = [Convert]::ToBase64String($rawData)
                $out += "`$$varname = `"$base64Data`""
            } elseif ($format -eq "directTable") {
                $source = Join-Path $PSScriptRoot (Join-Path $SourcesFolder $source)
                $rawData = Get-Content $source -Raw
                $out += "`$$varname = $rawData"
            } elseif ($format -eq "carbonCopy") {
                $out = ""
            }
            # $type = ($basefiles | Where-Object name -eq $target | Select-Object -First 1).addtype

            Write-Verbose "Processing target file: $(Test-Path $target)" -Verbose
            $baseData = Get-Content $target -Raw
            if ($format -ne "carbonCopy") {$out += "`r`n"}
            $out += $baseData
            
            New-Item -ItemType File -Path $tempplace -Force
            Set-Content $tempplace -Value $out
            Write-Verbose "$(Test-Path $tempplace)" -Verbose
        }

        
        Write-Verbose "$tempplace" -Verbose
    }
}


Write-Verbose "Writing output..." -Verbose

foreach ($file in $json) {
    $name = $file.name
    if ($name -eq "outputs") {
        foreach ($output in $file.files) {
            $source = $output.source -replace '\[\[CURRENTBUILDS\]\]', (Join-Path $env:TEMP "UCBuildTemp")
            $path = Join-Path $outFile $output.path
            $data = Get-Content $source -Raw
            New-Item -ItemType File -Path $path -Force
            Set-Content $path -Value $data
        }
    }
}

Write-Verbose "Done." -Verbose
Write-Host "Created $outFile" -ForegroundColor Green

Start-Sleep 1