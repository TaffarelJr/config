"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-ComponentGroup 'Shell/Terminal Windows'
#-------------------------------------------------------------------------------

. "$PSScriptRoot\Cmd.ps1"
. "$PSScriptRoot\WindowsTerminal.ps1"
. "$PSScriptRoot\PowerShell.ps1"
