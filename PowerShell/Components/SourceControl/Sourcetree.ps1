"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Sourcetree'
#-------------------------------------------------------------------------------

Assert-WinGetPackage -Name 'Atlassian.Sourcetree'
