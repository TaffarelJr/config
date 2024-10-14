"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'GitVersion'
#-------------------------------------------------------------------------------

Assert-WinGetPackage -Name 'GitTools.GitVersion' -Confirm { gitversion /version }
