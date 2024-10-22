"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Google Chrome'
#-------------------------------------------------------------------------------

# Core installation
Assert-WinGetPackage -Name 'Google.Chrome'

# Remove desktop shortcut
Remove-FromWindowsDesktop -Name 'Google Chrome'
