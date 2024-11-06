"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Firefox (Developer Edition)'
#-------------------------------------------------------------------------------

# Core installation
Assert-WinGetPackage -Name 'Mozilla.Firefox.DeveloperEdition'

# Remove desktop shortcut
Remove-FromWindowsDesktop -Name 'Firefox*'
