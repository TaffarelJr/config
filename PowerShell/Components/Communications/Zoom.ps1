"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Zoom'
#-------------------------------------------------------------------------------

# Core installation
Assert-WinGetPackage -Name 'Zoom.Zoom'

# Remove desktop shortcut
Remove-FromWindowsDesktop -Name 'Zoom*'
