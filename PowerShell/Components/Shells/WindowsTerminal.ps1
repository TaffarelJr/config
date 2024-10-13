"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Windows Terminal'
#-------------------------------------------------------------------------------

Assert-WinGetPackage 'Microsoft.WindowsTerminal'
