"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Microsoft Office'
#-------------------------------------------------------------------------------

Assert-WinGetPackage -Name 'Microsoft.Office'
