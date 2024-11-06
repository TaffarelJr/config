"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component '7Zip'
#-------------------------------------------------------------------------------

# Prepare PATH environment variable
Assert-PathEnvVar -Path 'C:\Program Files\7-Zip'

# Core installation
Assert-WinGetPackage -Name '7zip.7zip' -Confirm {
    (7z | Select-Object -Skip 1 -First 1).Split(' ')[1]
}
