"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Microsoft Edge'
#-------------------------------------------------------------------------------

Assert-WinGetPackage -Name 'Microsoft.Edge'
