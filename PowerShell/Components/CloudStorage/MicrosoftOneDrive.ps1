"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Microsoft OneDrive'
#-------------------------------------------------------------------------------

Assert-WinGetPackage -Name 'Microsoft.OneDrive'
