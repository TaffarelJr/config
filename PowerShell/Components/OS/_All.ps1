"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-ComponentGroup 'Operating System Components'
#-------------------------------------------------------------------------------

. "$PSScriptRoot\Windows.ps1"
. "$PSScriptRoot\WindowsExplorer.ps1"
. "$PSScriptRoot\WindowsSearch.ps1"
