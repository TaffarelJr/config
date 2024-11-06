param(
    [switch]$Developer
)

"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-ComponentGroup 'Operating System Components'
#-------------------------------------------------------------------------------

. "$PSScriptRoot\Windows.ps1"

if ($Developer) {
    . "$PSScriptRoot\WindowsExplorer.ps1" -ShowSuperHidden
}
else {
    . "$PSScriptRoot\WindowsExplorer.ps1"
}

. "$PSScriptRoot\WindowsSearch.ps1"
