"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Inkscape'
#-------------------------------------------------------------------------------

# Core installation
Assert-WinGetPackage -Name 'Inkscape.Inkscape'

# Remove desktop shortcut
Remove-FromWindowsDesktop -Name 'Inkscape'
