Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

function Show-CreateADSWindow {

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Create ADS" Height="300" Width="450">

<Grid Margin="15">

<Grid.RowDefinitions>
<RowDefinition Height="Auto"/>
<RowDefinition Height="Auto"/>
<RowDefinition Height="Auto"/>
<RowDefinition Height="Auto"/>
<RowDefinition Height="*"/>
</Grid.RowDefinitions>


<TextBlock Text="ADS Name"/>

<TextBox Name="NameBox"
         Grid.Row="1"/>


<StackPanel Grid.Row="2" Margin="0,10,0,0">

<RadioButton Name="TextMode"
             Content="Enter text"
             IsChecked="True"/>

<RadioButton Name="FileMode"
             Content="Read from file"/>

</StackPanel>


<StackPanel Grid.Row="3"
            Orientation="Horizontal"
            Margin="0,10,0,0">

<TextBox Name="DataBox"
         Width="330"
         Height="100"
         AcceptsReturn="True"
         TextWrapping="Wrap"
         VerticalScrollBarVisibility="Auto"/>

<Button Name="Browse"
        Content="..."
        Width="40"/>

</StackPanel>


<Button Grid.Row="4"
        Name="Create"
        Content="Create"
        Height="35"
        VerticalAlignment="Bottom"/>

</Grid>

</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader ([xml]$xaml)
$win = [Windows.Markup.XamlReader]::Load($reader)


$name = $win.FindName("NameBox")
$data = $win.FindName("DataBox")
$textMode = $win.FindName("TextMode")
$fileMode = $win.FindName("FileMode")
$browse = $win.FindName("Browse")
$create = $win.FindName("Create")


$browse.Visibility = "Hidden"


$fileMode.Add_Checked({
    $browse.Visibility = "Visible"
    $data.Height = 25
    $data.AcceptsReturn = $false
})


$textMode.Add_Checked({
    $browse.Visibility = "Hidden"
    $data.Height = 120
    $data.AcceptsReturn = $true
})

$browse.Add_Click({

$dialog = New-Object System.Windows.Forms.OpenFileDialog

if($dialog.ShowDialog() -eq "OK"){
    $data.Text = $dialog.FileName
}

})


$create.Add_Click({

if(-not $name.Text){
    [System.Windows.MessageBox]::Show("Enter ADS name")
    return
}


try {

$adsPath = "$($FileBox.Text):$($name.Text)"


if($fileMode.IsChecked){

    if(-not (Test-Path $data.Text)){
        throw "Source file not found"
    }

    [IO.File]::WriteAllBytes(
        $adsPath,
        [IO.File]::ReadAllBytes($data.Text)
    )

}
else {

    [IO.File]::WriteAllText(
        $adsPath,
        $data.Text
    )

}


$Status.Text = "Created ADS: $($name.Text)"

Get-Streams

$win.Close()

}

catch {

[System.Windows.MessageBox]::Show($_.Exception.Message)

}

})


$win.ShowDialog() | Out-Null

}

$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="ADS Manager" Height="600" Width="650">

<Grid Margin="15">

<Grid.RowDefinitions>
<RowDefinition Height="Auto"/>
<RowDefinition Height="Auto"/>
<RowDefinition Height="*"/>
<RowDefinition Height="Auto"/>
</Grid.RowDefinitions>


<StackPanel Grid.Row="0">

<TextBlock Text="Target File"/>

<StackPanel Orientation="Horizontal">
<TextBox Name="FileBox" Width="500"/>
<Button Name="Browse" Content="..." Width="40"/>
</StackPanel>

</StackPanel>


<StackPanel Grid.Row="1" Margin="0,10,0,10">

<Button Name="Refresh" Content="Refresh ADS List"/>

</StackPanel>

<ListView Name="ADSList" Grid.Row="2" Margin="0,0,0,15">

<ListView.View>
<GridView>

<GridViewColumn Header="Name" Width="200"
DisplayMemberBinding="{Binding Name}"/>

<GridViewColumn Header="Size" Width="100"
DisplayMemberBinding="{Binding Size}"/>

</GridView>

</ListView.View>

</ListView>


<StackPanel Grid.Row="3">


<StackPanel Orientation="Horizontal">

<Button Name="Create" Content="Create ADS" Width="100"/>
<Button Name="View" Content="View" Width="80"/>
<Button Name="Export" Content="Export" Width="80"/>
<Button Name="Delete" Content="Delete" Width="80"/>

</StackPanel>

<TextBlock Name="Status"/>

</StackPanel>

</Grid>

</Window>
"@


$reader = New-Object System.Xml.XmlNodeReader ([xml]$xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$FileBox = $window.FindName("FileBox")
$ADSList = $window.FindName("ADSList")
$ADSName = $window.FindName("ADSName")
$DataBox = $window.FindName("DataBox")
$Status = $window.FindName("Status")

$Browse = $window.FindName("Browse")
$Refresh = $window.FindName("Refresh")
$Create = $window.FindName("Create")
$View = $window.FindName("View")
$Export = $window.FindName("Export")
$Delete = $window.FindName("Delete")


function Get-Streams {

    $ADSList.Items.Clear()

    if (-not (Test-Path $FileBox.Text)) {
        return
    }

    Get-Item $FileBox.Text -Stream * |
    Where-Object {$_.Stream -ne "::$DATA"} |
    ForEach-Object {

        $ADSList.Items.Add(
            [PSCustomObject]@{
                Name = $_.Stream
                Stream = $_.Stream
                Size = $_.Length
            }
        )

    }
}

if ($args.Count -gt 0) {
    $FileBox.Text = $args[0]
    Get-Streams | Out-Null
}


$Browse.Add_Click({

$dialog = New-Object System.Windows.Forms.OpenFileDialog

if($dialog.ShowDialog() -eq "OK") {

$FileBox.Text = $dialog.FileName
Get-Streams

}

})


$Refresh.Add_Click({

Get-Streams

})


$Create.Add_Click({
    Show-CreateADSWindow
})


$View.Add_Click({

$item=$ADSList.SelectedItem

if($item){

$data=Get-Content `
"$($FileBox.Text):$($item.Name)" `
-Raw

[System.Windows.MessageBox]::Show($data)

}

})


$Export.Add_Click({

$item = $ADSList.SelectedItem

if (-not $item) {
    $Status.Text = "Select an ADS first."
    return
}

$ext = [IO.Path]::GetExtension($FileBox.Text).TrimStart(".")

$dialog = New-Object System.Windows.Forms.SaveFileDialog
$dialog.Filter = "$ext Files (*.$ext)|*.$ext|All Files (*.*)|*.*"
$dialog.DefaultExt = $ext
$dialog.AddExtension = $true

if ($dialog.ShowDialog() -eq "OK") {

    try {
        $data = [IO.File]::ReadAllBytes("$($FileBox.Text):$($item.Stream)")
        
        [IO.File]::WriteAllBytes($dialog.FileName, $data)

        $Status.Text = "Exported ADS."

    }
    catch {
        Write-Host "$($item.Stream)"
        $Status.Text = $_.Exception.Message
        $Status.Text = $($item.Stream)
    }
}

})


$Delete.Add_Click({

$item=$ADSList.SelectedItem

if($item){

Remove-Item -Path $FileBox.Text -Stream $item.Name

$Status.Text="Deleted ADS."

Get-Streams

}

})


$window.ShowDialog() | Out-Null