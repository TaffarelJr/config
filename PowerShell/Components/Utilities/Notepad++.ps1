"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Notepad++'
#-------------------------------------------------------------------------------

Assert-WinGetPackage -Name 'Notepad++.Notepad++'
