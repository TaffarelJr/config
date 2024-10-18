"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component '7Zip'
#-------------------------------------------------------------------------------

# Core installation
Assert-WinGetPackage -Name '7zip.7zip'

# Add it to the PATH environment variable
Assert-PathEnvVar -Path 'C:\Program Files\7-Zip'
