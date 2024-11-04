param(
    [switch]$CCleaner
)

"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-ComponentGroup 'System Utilities'
#-------------------------------------------------------------------------------

. "$PSScriptRoot\7Zip.ps1"
. "$PSScriptRoot\Notepad++.ps1"
. "$PSScriptRoot\SpaceSniffer.ps1"

if ($CCleaner) {
    . "$PSScriptRoot\CCleaner.ps1"
}
