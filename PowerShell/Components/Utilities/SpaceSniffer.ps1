"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'SpaceSniffer'
#-------------------------------------------------------------------------------

# Core installation
$package = 'UderzoSoftware.SpaceSniffer'
Assert-WinGetPackage -Name $package

# Pin it to the Start Menu
$installDir = Get-WinGetPackageDir -Name $package
Assert-PinnedToStartmenu -Path "$installDir\SpaceSniffer.exe"
