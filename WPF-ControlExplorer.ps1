##########################################################################
## WPF CONTROL EXPLORER                                                 ##
## v1.0                                                                 ##
## Author: Trevor Jones                                                 ##
## Released: 26-Sep-2016                                                ##
## More Info: http://smsagent.wordpress.com/tools/wpf-control-explorer/ ##
##########################################################################

<#
.Synopsis
   Exposes the properties, methods and events of the built-in WPF controls commonly used in WPF Windows desktop applications
.Notes
   Do not run from an existing PowerShell console session as the script will close it.  Right-click the script and run with PowerShell.
#>

#region UserInterface
# Load Assemblies
Add-Type -AssemblyName PresentationFramework

# Define XAML code
[xml]$xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="WPF Control Explorer" Height="824" Width="457.334" ResizeMode="CanMinimize" WindowStartupLocation="CenterScreen">
    <Grid>
        <GroupBox x:Name="groupBox" HorizontalAlignment="Left" VerticalAlignment="Top" Height="77" Width="440"/>
        <Grid>
            <Label x:Name="label" Content="Control" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" FontSize="18"/>
            <Label x:Name="label_Copy" Content=".Net Class" HorizontalAlignment="Left" Margin="10,46,0,0" VerticalAlignment="Top" FontSize="14"/>
            <ComboBox x:Name="CB_Control" HorizontalAlignment="Left" Margin="108,15,0,0" VerticalAlignment="Top" Width="325" Height="30" FontSize="18"/>
            <TextBlock x:Name="TB_Class" HorizontalAlignment="Left" Margin="108,51,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="322" Height="22" FontSize="14"/>
        </Grid>
        <GroupBox x:Name="groupBox1" Header="" HorizontalAlignment="Left" Margin="0,80,0,0" VerticalAlignment="Top" Height="77" Width="440"/>
        <Grid>
            <Label x:Name="label_Copy1" Content="Member" HorizontalAlignment="Left" Margin="10,95,0,0" VerticalAlignment="Top" FontSize="18"/>
            <ComboBox x:Name="CB_Member" HorizontalAlignment="Left" Margin="108,95,0,0" VerticalAlignment="Top" Width="325" Height="30" FontSize="18"/>
            <Label x:Name="label_Copy2" Content="Count" HorizontalAlignment="Left" Margin="10,125,0,0" VerticalAlignment="Top" FontSize="14"/>
            <TextBlock x:Name="TB_MemberCount" HorizontalAlignment="Left" Margin="111,130,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="322" Height="22" FontSize="14"/>
        </Grid>
        <GroupBox x:Name="GB_Filters" Header="Filters" HorizontalAlignment="Left" Margin="0,164,0,0" VerticalAlignment="Top" Height="93" Width="440"/>
        <Grid>
            <Label x:Name="label1" Content="Methods:" HorizontalAlignment="Left" Margin="10,181,0,0" VerticalAlignment="Top"/>
            <StackPanel x:Name="SP_Methods" HorizontalAlignment="Center" Height="26" Margin="117,181,10,0" VerticalAlignment="Top" Width="315" Orientation="Horizontal" IsEnabled="False">
                <Label x:Name="label2" Content="All"/>
                <CheckBox x:Name="CB_all" VerticalContentAlignment="Center"/>
                <Label x:Name="label3" Content="add_"/>
                <CheckBox x:Name="CB_add" VerticalContentAlignment="Center"/>
                <Label x:Name="label4" Content="get_"/>
                <CheckBox x:Name="CB_get" VerticalContentAlignment="Center"/>
                <Label x:Name="label5" Content="remove_"/>
                <CheckBox x:Name="CB_remove" VerticalContentAlignment="Center"/>
                <Label x:Name="label6" Content="set_"/>
                <CheckBox x:Name="CB_set" VerticalContentAlignment="Center"/>
                <Label x:Name="label7" Content="No &#39;__&#39;"/>
                <CheckBox x:Name="CB_NoUnderscore" VerticalContentAlignment="Center"/>
            </StackPanel>
            <TextBox x:Name="TB_Filter" HorizontalAlignment="Left" Height="36" Margin="10,212,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="422" VerticalContentAlignment="Center" FontSize="16"/>
            <ListBox x:Name="LB_Member" HorizontalAlignment="Left" Height="386" Margin="10,262,0,0" VerticalAlignment="Top" Width="422" FontSize="18"/>
            <GroupBox x:Name="groupBox3" Header="Definition" HorizontalAlignment="Left" Margin="0,653,0,0" VerticalAlignment="Top" Height="62" Width="437">
                <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                    <TextBox x:Name="TB_Definition" TextWrapping="Wrap" BorderThickness="0" IsReadOnly="True"/>
                </ScrollViewer>
            </GroupBox>
            <GroupBox x:Name="groupBox4" Header="Static Properties" HorizontalAlignment="Left" Margin="0,720,0,0" VerticalAlignment="Top" Height="62" Width="437">
                <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                    <ListBox x:Name="LB_Static" BorderThickness="0" />
                </ScrollViewer>
            </GroupBox>
        </Grid>
    </Grid>
</Window>
"@

# Load XAML elements into a hash table
$script:hash = [hashtable]::Synchronized(@{})
$hash.Window = [Windows.Markup.XamlReader]::Load((New-Object -TypeName System.Xml.XmlNodeReader -ArgumentList $xaml))
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]") | ForEach-Object -Process {
    $hash.$($_.Name) = $hash.Window.FindName($_.Name)
}
#endregion



#region PopulateInitialData
# Define the list of controls
$Controls = @(
"Border",
"Button",
"Calendar",
"Canvas",
"CheckBox",
"ComboBox",
"ContentControl",
"DataGrid",
"DatePicker",
"DockPanel",
"DocumentViewer",
"Ellipse",
"Expander",
"Grid",
"GridSplitter",
"GroupBox",
"Image",
"Label",
"ListBox",
"ListView",
"MediaElement",
"Menu",
"NavigationWindow",
"PasswordBox",
"ProgressBar",
"RadioButton",
"Rectangle",
"RichTextBox",
"ScrollBar",
"ScrollViewer",
"Separator",
"Slider",
"StackPanel",
"StatusBar",
"TabControl",
"TextBlock",
"TextBox",
"ToolBar",
"ToolBarPanel",
"ToolBarTray",
"TreeView",
"ViewBox",
"WebBrowser",
"Window",
"WrapPanel"
)

# Define the list of member types
$Members = @("Property","Method","Event")

# Load the .Net type names in the current domain and filter for controls in the WPF
$ControlTypes = [AppDomain]::CurrentDomain.GetAssemblies() | foreach {$_.GetTypes()} | where {$_.Name -in $Controls -and $_.Module -match "PresentationFramework.dll"}| Select Name,FullName

# Populate the combo boxes with controls and member types
$Hash.CB_Control.ItemsSource = [array]$Controls
$Hash.CB_Member.ItemsSource = [array]$Members
#endregion



#region Event Handling
# When selection changed on the Control combobox
$Hash.CB_Control.Add_SelectionChanged({
    # Blank everything
    $Hash.CB_Member.SelectedValue = ''
    $Hash.LB_Member.ItemsSource = ''
    $Hash.TB_Definition.Text = ''
    $Hash.LB_Static.ItemsSource = ''
    $Hash.TB_Filter.Text = ''
    $Hash.TB_MemberCount.Text  = ''
    # Populate the .Net class textblock
    $DotNetClass = $ControlTypes | Where {$_.Name -eq $This.SelectedItem} | Select -ExpandProperty FullName
    $Hash.TB_Class.Text = $DotNetClass
})

# When selection changed on the Member combobox
$Hash.CB_Member.Add_SelectionChanged({
    $Hash.TB_Filter.Text = ''
    # Only run if something has been selected
    If ($This.SelectedIndex -ne "-1")
    {
        # Create a control of the selected type
        $ControlType = $ControlTypes | Where {$_.Name -eq $hash.CB_Control.SelectedItem}
        $Control = New-Object ($ControlType.FullName)
        # Find and populate the members of the selected member type
        $script:Members = $Control | Get-Member -MemberType $This.SelectedItem -Force | Select Name,Definition
        $Hash.LB_Member.ItemsSource = [array]$Members.Name
        $Hash.TB_MemberCount.Text = $Members.Count
        # If 'method', enable the methods stackpanel in the filter section
        If ($This.SelectedItem -eq "Method")
        {
            $Hash.SP_Methods.IsEnabled = $True
            $Hash.CB_all.IsChecked = $True
        }
        Else
        {
            $Hash.SP_Methods.IsEnabled = $False
            $hash.CB_all.IsChecked = $False
        }
        # Make sure the checkboxes are not checked
        $Hash.CB_add.IsChecked = $False
        $Hash.CB_remove.IsChecked = $False
        $Hash.CB_set.IsChecked = $False
        $Hash.CB_NoUnderscore.IsChecked = $False
        $Hash.CB_get.IsChecked = $False
    }

})

# When selection changed on Member listbox
$Hash.LB_Member.Add_SelectionChanged({
    # Find the definition and populate the definition textbox
    $Definition = $Members | where {$_.Name -eq $This.SelectedItem} | Select -ExpandProperty Definition
    $Hash.TB_Definition.Text = $Definition
    # If 'property', we need to get the static members also, where available
    If ($Hash.CB_Member.SelectedItem -eq "Property")
    {
        $script:StaticMembers = ''
        # Only run if the definition contains something in the System namespace
        If ($Definition -match 'System.')
        {
            $ClassName = $Definition.Split(' ')[0]
            try
            {
                # Get the list of static member names
                $script:StaticMembers = New-Object -TypeName $ClassName -ErrorAction Stop | Get-Member -Static -MemberType Property -ErrorAction Stop | Select -ExpandProperty Name
            }
            catch
            { 
                $Hash.LB_Static.ItemsSource = ""
            }
            if ($StaticMembers -ne "Empty")
            {
                # Populate the static list box with the static members
                $Hash.LB_Static.ItemsSource = [array]$StaticMembers
            }
        }
        Else
        {
            $Hash.LB_Static.ItemsSource = ""
        }
    }
    Else
    {
        $Hash.LB_Static.ItemsSource = ""
    }
})

# When the filter textbox is used
$Hash.TB_Filter.Add_TextChanged({
    [System.Windows.Data.CollectionViewSource]::GetDefaultView($Hash.LB_Member.ItemsSource).Filter = [Predicate[Object]]{             
        Try {
            $args[0] -match [regex]::Escape($This.Text)
        } Catch {
            $True
        }
    } 
})

#region Checkbox event handling
# If checkbox checked, uncheck the other checkboxes, and populate the member list box based on the checkbox selections
$Hash.CB_all.Add_Checked({
    $hash.CB_add.IsChecked = $False
    $Hash.CB_remove.IsChecked = $False
    $Hash.CB_set.IsChecked = $False
    $Hash.CB_NoUnderscore.IsChecked = $False
    $Hash.CB_get.IsChecked = $False
    $Hash.TB_Filter.Text = ''

    $Hash.LB_Member.ItemsSource = [array]$Members.Name
})

$Hash.CB_add.Add_Checked({
    $hash.CB_all.IsChecked = $False
    $Hash.CB_remove.IsChecked = $False
    $Hash.CB_set.IsChecked = $False
    $Hash.CB_NoUnderscore.IsChecked = $False
    $Hash.CB_get.IsChecked = $False
    $Hash.TB_Filter.Text = ''

    $Hash.LB_Member.ItemsSource = [array]($Members | where {$_ -match "add_"} | Select -ExpandProperty Name)
})

$Hash.CB_get.Add_Checked({
    $hash.CB_all.IsChecked = $False
    $Hash.CB_remove.IsChecked = $False
    $Hash.CB_set.IsChecked = $False
    $Hash.CB_NoUnderscore.IsChecked = $False
    $Hash.CB_add.IsChecked = $False
    $Hash.TB_Filter.Text = ''

    $Hash.LB_Member.ItemsSource = [array]($Members | where {$_ -match "get_"} | Select -ExpandProperty Name) 
})

$Hash.CB_remove.Add_Checked({
    $hash.CB_all.IsChecked = $False
    $Hash.CB_get.IsChecked = $False
    $Hash.CB_set.IsChecked = $False
    $Hash.CB_NoUnderscore.IsChecked = $False
    $Hash.CB_add.IsChecked = $False
    $Hash.TB_Filter.Text = ''

    $Hash.LB_Member.ItemsSource = [array]($Members | where {$_ -match "remove_"} | Select -ExpandProperty Name)
})

$Hash.CB_set.Add_Checked({
    $hash.CB_all.IsChecked = $False
    $Hash.CB_get.IsChecked = $False
    $Hash.CB_remove.IsChecked = $False
    $Hash.CB_NoUnderscore.IsChecked = $False
    $Hash.CB_add.IsChecked = $False
    $Hash.TB_Filter.Text = ''

    $Hash.LB_Member.ItemsSource = [array]($Members | where {$_ -match "set_"} | Select -ExpandProperty Name)
})

$Hash.CB_NoUnderscore.Add_Checked({
    $hash.CB_all.IsChecked = $False
    $Hash.CB_get.IsChecked = $False
    $Hash.CB_remove.IsChecked = $False
    $Hash.CB_set.IsChecked = $False
    $Hash.CB_add.IsChecked = $False
    $Hash.TB_Filter.Text = ''

    $Hash.LB_Member.ItemsSource = [array]($Members | where {$_ -notmatch "_"} | Select -ExpandProperty Name)
})

# Create Unchecked events to restore all results if a checkbox gets unchecked, and clear the text filter
$hash.CB_NoUnderscore,$Hash.CB_get,$Hash.CB_remove,$Hash.CB_set,$Hash.CB_add | foreach {
    $_.Add_UnChecked({
        If ($hash.CB_NoUnderscore.IsChecked -ne $True -and $hash.CB_get.IsChecked -ne $True -and $hash.CB_remove.IsChecked -ne $True -and $hash.CB_set.IsChecked -ne $True -and $hash.CB_add.IsChecked -ne $True)
        {
            $Hash.CB_all.IsChecked = $True
            $Hash.TB_Filter.Text = ''
        }
    })
}
#endregion
#endregion



#region Display the UI
# Display Window
# If code is running in ISE, use ShowDialog()...
if ($psISE)
{
    $null = $Hash.window.Dispatcher.InvokeAsync{$Hash.Window.ShowDialog()}.Wait()
}
# ...otherwise run as an application
Else
{
    # Make PowerShell Disappear
    $windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
    $asyncwindow = Add-Type -MemberDefinition $windowcode -Name Win32ShowWindowAsync -Namespace Win32Functions -PassThru
    $null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)
 
    $app = New-Object -TypeName Windows.Application
    $app.Run($Hash.Window)
}
#endregion