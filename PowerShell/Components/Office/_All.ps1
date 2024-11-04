"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-ComponentGroup 'Office Productivity Software'
#-------------------------------------------------------------------------------

. "$PSScriptRoot\MicrosoftOffice.ps1"

Write-Host
Write-Host 'Visio isn''t available via automation yet.'
Write-Host 'Instead, download and install manually from'
Write-Host 'https://portal.office.com/account'
Read-Host '<press any key to continue>'
# . "$PSScriptRoot\MicrosoftVisio.ps1"
