"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-ComponentGroup 'Communication Tools'
#-------------------------------------------------------------------------------

. "$PSScriptRoot\Slack.ps1"
. "$PSScriptRoot\Zoom.ps1"
. "$PSScriptRoot\Webex.ps1"
