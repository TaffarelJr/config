"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Hugin'
#-------------------------------------------------------------------------------

Assert-WinGetPackage -Name 'Hugin.Hugin'
