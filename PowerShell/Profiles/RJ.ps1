"$PSScriptRoot\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-ComponentGroup 'Profile: RJ'
#-------------------------------------------------------------------------------

# Configuration Settings:

$devDrive = 'C:\Dev'

#-------------------------------------------------------------------------------
Start-Component 'Windows Search'
#-------------------------------------------------------------------------------

# Indexing Options -> Index these locations:
Assert-WindowsSearchLocation -Path $devDrive
