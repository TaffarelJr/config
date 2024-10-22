param(
    [switch]$GoogleDrive,
    [switch]$Dropbox
)

"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-ComponentGroup 'Cloud Storage Solutions'
#-------------------------------------------------------------------------------

. "$PSScriptRoot\MicrosoftOneDrive.ps1"

if ($GoogleDrive) {
    . "$PSScriptRoot\GoogeDrive.ps1"
}

if ($Dropbox) {
    . "$PSScriptRoot\Dropbox.ps1"
}
