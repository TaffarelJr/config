"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Shotcut'
#-------------------------------------------------------------------------------

Assert-WinGetPackage -Name 'Meltytech.Shotcut'
