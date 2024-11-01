$moduleDir = "$PSScriptRoot\..\Modules"
"$moduleDir\*.psm1" | Get-ChildItem | Import-Module -Force
Initialize-Environment

#-------------------------------------------------------------------------------
Start-ComponentGroup 'Profile: RJ'
#-------------------------------------------------------------------------------

# Configuration Settings:

$devDrive = 'C:\Dev'

$devFont = [PSCustomObject]@{
    Name    = 'FiraCode NF'
    Package = 'firacodenf'
}

$ohMyPosh = [PSCustomObject]@{
    PowerShell = '$Env:POSH_THEMES_PATH\powerlevel10k_rainbow.omp.json'
}

#-------------------------------------------------------------------------------
Start-Component 'Windows Search'
#-------------------------------------------------------------------------------

# Indexing Options -> Index these locations:
Assert-WindowsSearchLocation -Path $devDrive

#-------------------------------------------------------------------------------
Start-Component 'Fonts'
#-------------------------------------------------------------------------------

Assert-ChocolateyPackage -Name $devFont.Package

#-------------------------------------------------------------------------------
Start-Component 'Windows Terminal'
#-------------------------------------------------------------------------------

Write-Host 'Validating configuration ...'
$config = Get-WindowsTerminalConfig

$changed = `
($config.profiles.defaults | Assert-Property -Name 'font') -bor `
($config.profiles.defaults.font | Assert-PropertyValue -Name 'face' -Value $devFont.Name) -bor `
($config.profiles.defaults.font | Assert-PropertyValue -Name 'size' -Value 11) -bor `
($config.profiles.defaults.font | Assert-PropertyValue -Name 'weight' -Value 'normal') -bor `
($config.profiles.defaults | Assert-PropertyValue -Name 'useAcrylic' -Value $True) -bor `
($config.profiles.defaults | Assert-PropertyValue -Name 'opacity' -Value 80)

if ($changed) {
    Write-Host 'Saving changes...'
    Set-WindowsTerminalConfig $config
}

#-------------------------------------------------------------------------------
Start-Component 'Oh-My-Posh'
#-------------------------------------------------------------------------------

Assert-WinGetPackage -Name 'JanDeDobbeleer.OhMyPosh'
oh-my-posh enable autoupgrade

#-------------------------------------------------------------------------------
Start-Component '(Windows) PowerShell 5'
#-------------------------------------------------------------------------------

$theme = if ($ohMyPosh.PowerShell) {
    " --config `"$($ohMyPosh.PowerShell)`""
}
else { $null }

Invoke-PowerShell5 -ModuleDir $moduleDir -Arguments $theme -ScriptBlock {
    param ($theme)

    Write-Host 'Installing theme ...'
    Assert-FileContentBlock `
        -Path $Profile.CurrentUserAllHosts  `
        -Find '# Load Oh-My-Posh theme.*?(\s*$|(\r\n){2,}|\n{2,})' `
        -Content @"
# Load Oh-My-Posh theme
oh-my-posh init pwsh$theme | Invoke-Expression
"@
}

#-------------------------------------------------------------------------------
Start-Component 'PowerShell (Core) 7'
#-------------------------------------------------------------------------------

Invoke-PowerShell7 -ModuleDir $moduleDir -Arguments $theme -ScriptBlock {
    param ($theme)

    Write-Host 'Installing theme ...'
    Assert-FileContentBlock `
        -Path $Profile.CurrentUserAllHosts  `
        -Find '# Load Oh-My-Posh theme.*?(\s*$|(\r\n){2,}|\n{2,})' `
        -Content @"
# Load Oh-My-Posh theme
oh-my-posh init pwsh$theme | Invoke-Expression
"@
}
