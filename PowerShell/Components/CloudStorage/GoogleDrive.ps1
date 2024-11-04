"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Google Drive'
#-------------------------------------------------------------------------------

Assert-WinGetPackage -Name 'Google.GoogleDrive'
