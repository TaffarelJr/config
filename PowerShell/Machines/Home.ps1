"$PSScriptRoot\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment
Assert-ComputerName

$componentDir = "$PSScriptRoot\..\Components"

. "$componentDir\PackageManagers\_All.ps1" # Do this first
. "$componentDir\OS\_All.ps1"
. "$componentDir\Shells\_All.ps1"
. "$componentDir\Utilities\_All.ps1" -CCleaner
. "$componentDir\Browsers\_All.ps1"
. "$componentDir\CloudStorage\_All.ps1" -GoogleDrive -Dropbox
