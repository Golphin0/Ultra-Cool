Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

$defaultBase   = Join-Path $PSScriptRoot "base.ps1"
$defaultB64    = Join-Path $PSScriptRoot "base64.txt"
$defaultOutput = Join-Path $PSScriptRoot "UltraCool.ps1"

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

            <!-- Base -->
            <Label Grid.Row="1"
                   Grid.Column="0"
                   VerticalAlignment="Center">
                Base:
            </Label>

            <TextBox Name="BaseFile"
                     Grid.Row="1"
                     Grid.Column="1"
                     Margin="5"/>

            <Button Name="BrowseBase"
                    Grid.Row="1"
                    Grid.Column="2"
                    Margin="5">
                Browse...
            </Button>

            <!-- Base64 -->
            <Label Grid.Row="2"
                   Grid.Column="0"
                   VerticalAlignment="Center">
                Base64:
            </Label>

            <TextBox Name="Base64File"
                     Grid.Row="2"
                     Grid.Column="1"
                     Margin="5"/>

            <Button Name="BrowseB64"
                    Grid.Row="2"
                    Grid.Column="2"
                    Margin="5">
                Browse...
            </Button>

            <!-- Output -->
            <Label Grid.Row="3"
                   Grid.Column="0"
                   VerticalAlignment="Center">
                Output:
            </Label>

            <TextBox Name="OutputFile"
                     Grid.Row="3"
                     Grid.Column="1"
                     Margin="5"/>

            <Button Name="BrowseOutput"
                    Grid.Row="3"
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

$BaseFile     = $window.FindName("BaseFile")
$Base64File   = $window.FindName("Base64File")
$OutputFile   = $window.FindName("OutputFile")

$BrowseBase   = $window.FindName("BrowseBase")
$BrowseB64    = $window.FindName("BrowseB64")
$BrowseOutput = $window.FindName("BrowseOutput")

$ResetButton = $window.FindName("ResetButton")
$CreateButton = $window.FindName("CreateButton")
$CancelButton = $window.FindName("CancelButton")

$BaseFile.Text   = $defaultBase
$Base64File.Text = $defaultB64
$OutputFile.Text = $defaultOutput

$BrowseBase.Add_Click({
    $d = New-Object System.Windows.Forms.OpenFileDialog
    $d.Filter = "PowerShell Scripts (*.ps1)|*.ps1|All Files (*.*)|*.*"
    $d.InitialDirectory = Split-Path $BaseFile.Text

    if($d.ShowDialog() -eq "OK"){
        $BaseFile.Text = $d.FileName
    }
})

$BrowseB64.Add_Click({
    $d = New-Object System.Windows.Forms.OpenFileDialog
    $d.Filter = "Base64 Files (*.txt)|*.txt|All Files (*.*)|*.*"
    $d.InitialDirectory = Split-Path $Base64File.Text

    if($d.ShowDialog() -eq "OK"){
        $Base64File.Text = $d.FileName
    }
})

$BrowseOutput.Add_Click({
    $d = New-Object System.Windows.Forms.SaveFileDialog
    $d.FileName = $OutputFile.Text
    if($d.ShowDialog() -eq "OK"){
        $OutputFile.Text = $d.FileName
    }
})

$ResetButton.Add_Click({
    $BaseFile.Text   = $defaultBase
    $Base64File.Text = $defaultB64
    $OutputFile.Text = $defaultOutput
})

$CreateButton.Add_Click({
    $script:baseFile   = $BaseFile.Text
    $script:b64File    = $Base64File.Text
    $script:outFile    = $OutputFile.Text
    $window.DialogResult = $true
})

$CancelButton.Add_Click({
    $window.DialogResult = $false
})

if(-not $window.ShowDialog()){
    return
}

Write-Verbose "Base File   : $baseFile" -Verbose
Write-Verbose "Base64 File : $b64File" -Verbose
Write-Verbose "Output File : $outFile" -Verbose

if (!(Test-Path $baseFile)) {
    Write-Verbose "Base file not found." -Verbose
    Write-Host "$baseFile not found." -ForegroundColor Red
    pause
    exit 1
}

if (!(Test-Path $b64File)) {
    Write-Verbose "Base64 file not found." -Verbose
    Write-Host "$b64File not found." -ForegroundColor Red
    pause
    exit 1
}

Write-Verbose "Reading input files..." -Verbose

$base = Get-Content $baseFile -Raw
$lines = Get-Content $b64File

if ($lines.Count % 2 -ne 0) {
    Write-Verbose "Invalid base64.txt format." -Verbose
    Write-Host "base64.txt must contain an even number of lines." -ForegroundColor Red
    pause
    exit 1
}

$out = ""
$out += "# Base64 Strings`r`n"

Write-Verbose "Processing base64 variables..." -Verbose

for ($i = 0; $i -lt $lines.Count; $i += 2) {
    $name = $lines[$i].Trim()
    $value = $lines[$i + 1]
    Write-Verbose "Embedding variable '$name'" -Verbose
    $out += "`$$name = `"$value`"`r`n"
}

$out += "`r`n"
$out += $base.TrimStart()

Write-Verbose "Writing output..." -Verbose

Set-Content $outFile -Value $out -Encoding UTF8

Write-Verbose "Done." -Verbose
Write-Host "Created $outFile" -ForegroundColor Green

Start-Sleep 1