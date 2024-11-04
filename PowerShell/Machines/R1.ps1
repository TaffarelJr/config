"$PSScriptRoot\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

$componentDir = "$PSScriptRoot\..\Components"

# Standard components
. "$componentDir\PackageManagers\_All.ps1" # Do this first
. "$componentDir\OS\_All.ps1"
. "$componentDir\Shells\_All.ps1"
. "$componentDir\Utilities\_All.ps1"
. "$componentDir\Browsers\_All.ps1" -Firefox
. "$componentDir\CloudStorage\_All.ps1"

# Developer tools
. "$componentDir\SourceControl\_All.ps1"
