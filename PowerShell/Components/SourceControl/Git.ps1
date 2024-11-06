"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Git'
#-------------------------------------------------------------------------------

# Core installation
Assert-WinGetPackage -Name 'Git.Git' -Confirm { (git version).Split(' ')[2] }

# Global configuration
git config --global core.autocrlf 'true'
git config --global core.safecrlf 'true'
