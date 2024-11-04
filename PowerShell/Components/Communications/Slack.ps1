"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Slack'
#-------------------------------------------------------------------------------

Assert-WinGetPackage -Name 'SlackTechnologies.Slack'
