param(
    [switch]$Firefox
)

"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-ComponentGroup 'Internet Browsers'
#-------------------------------------------------------------------------------

. "$PSScriptRoot\MicrosoftEdge.ps1"
. "$PSScriptRoot\GoogleChrome.ps1"

if ($Firefox) {
    . "$PSScriptRoot\Firefox.ps1"
}
