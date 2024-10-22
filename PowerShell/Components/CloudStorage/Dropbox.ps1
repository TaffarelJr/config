"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Dropbox'
#-------------------------------------------------------------------------------

Assert-WinGetPackage -Name 'Dropbox.Dropbox'
