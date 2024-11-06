$moduleDir = "$PSScriptRoot\..\..\Modules"
"$moduleDir\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-Component 'PowerShell 2'
#-------------------------------------------------------------------------------

# PowerShell 2 is now recognized as a security risk
# that can be used to run malicious scripts.
# It's replaced by PowerShell 5 in modern Windows.
Write-Host "Removing ..."
Disable-WindowsOptionalFeature -FeatureName 'MicrosoftWindowsPowerShellV2Root' -Online

#-------------------------------------------------------------------------------
Start-Component '(Windows) PowerShell 5'
#-------------------------------------------------------------------------------

# PowerShell 5 is built into (and updated with) Windows.
# No need to install or update it here.

# Core configuration
Invoke-PowerShell5 -ModuleDir $moduleDir -ScriptBlock {
    Assert-PowerShellConfiguration
}

#-------------------------------------------------------------------------------
Start-Component 'PowerShell (Core) 7'
#-------------------------------------------------------------------------------

# Core installation
Assert-WinGetPackage -Name 'Microsoft.PowerShell' -Confirm { (pwsh -v).Split(' ')[1] }

# Core configuration
Write-Host
Invoke-PowerShell7 -ModuleDir $moduleDir -ScriptBlock {
    Assert-PowerShellConfiguration
}

# Ensure PowerShell 7 is the default in Windows Terminal
$config = Get-WindowsTerminalConfig
$obj = $config.profiles.list | Where-Object { $_.Source -Like '*.PowershellCore' }
if (($null -ne $obj) -and ($config.defaultProfile -ne $obj.guid)) {
    Write-Host 'Making PowerShell 7 the default in Windows Terminal ...'
    $config.defaultProfile = $obj.guid
    Set-WindowsTerminalConfig $config
}
