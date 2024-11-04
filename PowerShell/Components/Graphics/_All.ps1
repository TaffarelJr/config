"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-ComponentGroup 'Graphics Editors'
#-------------------------------------------------------------------------------

. "$PSScriptRoot\Paint.NET.ps1"
. "$PSScriptRoot\Gimp.ps1"
. "$PSScriptRoot\Inkscape.ps1"
. "$PSScriptRoot\Hugin.ps1"
. "$PSScriptRoot\Shotcut.ps1"
