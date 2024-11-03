"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-ComponentGroup 'Source Control Tools'
#-------------------------------------------------------------------------------

. "$PSScriptRoot\Git.ps1"
. "$PSScriptRoot\GitVersion.ps1"
. "$PSScriptRoot\TortoiseGit.ps1"
. "$PSScriptRoot\GitHubDesktop.ps1"
. "$PSScriptRoot\Sourcetree.ps1"
