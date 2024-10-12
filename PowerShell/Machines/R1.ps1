"$PSScriptRoot\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

$componentDir = "$PSScriptRoot\..\Components"

# Standard components
. "$componentDir\PackageManagers\_All.ps1" # Do this first
. "$componentDir\OS\_All.ps1"
