"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Gimp'
#-------------------------------------------------------------------------------

Assert-WinGetPackage -Name 'GIMP.GIMP'
