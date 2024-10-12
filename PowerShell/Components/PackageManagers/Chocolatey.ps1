using namespace System.Net

"$PSScriptRoot\..\..\Modules\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'Chocolatey'
#-------------------------------------------------------------------------------

Write-host 'Downloading and running install script ...'
$uri = 'https://community.chocolatey.org/install.ps1'
Invoke-Expression ((New-Object WebClient).DownloadString($uri))

# Make sure environment variable is set and profile is loaded
$path = Convert-Path "$((Get-Command choco).Path)\..\.."
Assert-EnvVar -Name 'ChocolateyInstall' -Value $path -Target Machine
Import-ChocolateyProfile
Update-SessionEnvironment # Reload the environment -- part of Chocolatey

# Both CLI and PowerShell module should be available
Confirm-Installation -ScriptBlock { choco --version }
Confirm-Installation -Label 'PowerShell module' -ScriptBlock { (Get-ChocolateyVersion).ToString() }
