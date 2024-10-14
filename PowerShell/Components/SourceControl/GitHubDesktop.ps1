"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'GitHub Desktop'
#-------------------------------------------------------------------------------

Assert-WinGetPackage -Name 'GitHub.GitHubDesktop'
