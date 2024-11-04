"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'CCleaner'
#-------------------------------------------------------------------------------

# Core installation
Assert-WinGetPackage -Name 'Piriform.CCleaner'

# Remove desktop shortcut
Remove-FromWindowsDesktop -Name 'CCleaner'
