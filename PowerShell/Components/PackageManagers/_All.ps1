"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-ComponentGroup 'Package Managers'
#-------------------------------------------------------------------------------

. "$PSScriptRoot\MicrosoftStore.ps1"
. "$PSScriptRoot\WinGet.ps1"
. "$PSScriptRoot\Chocolatey.ps1"
